unit MainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, TmxMap,
  System.Generics.Collections, Vcl.Imaging.pngimage, TmxObjectGroup,
  Vcl.ExtCtrls, TmxTileLayer;

type
  TMainForm = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FMap: TTmxMap;
    FTextures: TObjectDictionary<Integer, TPngImage>;
    FBuffer: TBitmap;
    procedure DrawTileLayer(TileLayer: TTmxTileLayer);
    procedure DrawObjectGroup(ObjectGroup: TTmxObjectGroup);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  TmxUtils, System.Types, TmxTileset, TmxLayer, IsoUtils;

{$R *.dfm}

procedure TMainForm.DrawObjectGroup(ObjectGroup: TTmxObjectGroup);
var
  ObjectIndex: Integer;
  TmxObject: TTmxObject;
  Tileset: TTmxTileset;
  TileId: Integer;
  Image: TPngImage;
  ObjRect: TRect;
begin
  for ObjectIndex := 0 to ObjectGroup.ObjectCount - 1 do
  begin
    TmxObject := ObjectGroup.Objects[ObjectIndex];

    ObjRect.Left := 0;
    ObjRect.Top := 0;
    ObjRect.Right := Round(TmxObject.Width);
    ObjRect.Bottom := Round(TmxObject.Height);
    // выравнивание по левому нижнему краю
    ObjRect.Offset(Round(TmxObject.X), Round(TmxObject.Y) - ObjRect.Bottom);

    if TmxObject.Gid > 0 then
    begin
      Tileset := GetTilesetByGid(FMap, TmxObject.Gid);
      TileId := TmxObject.Gid - Tileset.FirstGid;
      Image := FTextures[TileId];
      FBuffer.Canvas.StretchDraw(ObjRect, Image);
    end;
  end;
end;

procedure TMainForm.DrawTileLayer(TileLayer: TTmxTileLayer);
var
  I, Y, X: Integer;
  Layer: TTmxTileLayer;
  Gid: Integer;
  Tileset: TTmxTileset;
  Position: TPoint;
  TileId: Integer;
begin
  for Y := 0 to FMap.Height - 1 do
  begin
    for X := 0 to FMap.Width - 1 do
    begin
      for I := 0 to FMap.TileLayers.Count - 1 do
      begin
        Layer := FMap.TileLayers[I];
        if not Layer.Visible or (Layer.Data[Y, X] = 0) then
          Continue;

        Gid := Layer.Data[Y, X];
        if TileId >= 0 then
        begin
          Position := TPoint.Create(X * FMap.TileHeight, Y * FMap.TileHeight);
          Position := PosToIso(Position);
          Position.Offset(FMap.Width * FMap.TileHeight, 0);
          FBuffer.Canvas.Draw(Position.X, Position.Y, FTextures[Gid]);
        end;
      end;
    end;
  end;
end;

function CopyPNG(const Image: TPngImage; const R: TRect): TPngImage;
var
  I: Integer;
begin
  Result := TPngImage.CreateBlank(COLOR_RGBALPHA, 8, R.Width, R.Height);
  BitBlt(Result.Canvas.Handle, 0, 0, R.Width, R.Height, Image.Canvas.Handle,
    R.Left, R.Top, SRCCOPY);

  for I := 0 to R.Height - 1 do
  begin
    if not Assigned(Result.AlphaScanline[I]) or
      not Assigned(Image.AlphaScanline[I + R.Top]) then
      Break;

    CopyMemory(Result.AlphaScanline[I],
      PByte(Integer(Image.AlphaScanline[I + R.Top]) + R.Left), R.Width);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Tileset: TTmxTileset;
  TileId: Integer;
  Tile: TTmxTile;
  Image: TPngImage;
  RowCount, ColCount: Integer;
  X, Y: Integer;
  TextureRect: TRect;
  Texture: TPngImage;
begin
  FBuffer := TBitmap.Create;

  FMap := TTmxMap.Create;
  FMap.Load('map\sandbox2.tmx');
//  FMap.Load('tmx\objects.tmx');
//  FMap.Load('maps\cave\abandoned_mine.tmx');

  FTextures := TObjectDictionary<Integer, TPngImage>.Create([doOwnsValues]);

  for Tileset in FMap.Tilesets.Values do
  begin
    if not Tileset.Image.Source.IsEmpty then
    begin
      Image := TPngImage.Create;
      try
        Image.LoadFromFile(Tileset.Image.Source);
        RowCount := Tileset.Image.Height div Tileset.TileHeight;
        ColCount := Tileset.Image.Width div Tileset.TileWidth;
        TileId := 0;
        for X := 0 to ColCount - 1 do
        begin
          for Y := 0 to RowCount - 1 do
          begin
            TextureRect := GetImageRectByTileId(Tileset, TileId);
            Texture := CopyPNG(Image, TextureRect);
            FTextures.Add(TileId + Tileset.FirstGid, Texture);
            Inc(TileId);
          end;
        end;
      finally
        Image.Free;
      end;
    end;

    for TileId in Tileset.Tiles.Keys do
    begin
      Tile := Tileset.Tiles[TileId];

      Image := TPngImage.Create;
      Image.LoadFromFile(Tile.Image.Source);
      FTextures.Add(TileId, Image);
    end;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FTextures.Free;
  FMap.Free;
  FBuffer.Free;
end;

procedure TMainForm.FormPaint(Sender: TObject);
var
  ObjectGroup: TTmxObjectGroup;
  TileLayer: TTmxTileLayer;
begin
  FBuffer.Canvas.Brush.Color := FMap.BackgroundColor;
  FBuffer.Canvas.FillRect(ClientRect);

  for TileLayer in FMap.TileLayers do
    DrawTileLayer(TileLayer);

  for ObjectGroup in FMap.ObjectGroups do
    DrawObjectGroup(ObjectGroup);

  Canvas.Draw(0, 0, FBuffer);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  FBuffer.Width := ClientWidth;
  FBuffer.Height := ClientHeight;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  Invalidate;
end;

initialization

ReportMemoryLeaksOnShutdown := True;

end.
