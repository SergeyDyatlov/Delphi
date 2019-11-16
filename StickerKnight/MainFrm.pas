unit MainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, TmxMap,
  System.Generics.Collections, Vcl.Imaging.pngimage, TmxObjectGroup,
  Vcl.ExtCtrls;

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
    procedure DrawObjectGroup(ObjectGroup: TTmxObjectGroup);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  TmxUtils, System.Types, TmxTileset, TmxLayer;

{$R *.dfm}

procedure TMainForm.DrawObjectGroup(ObjectGroup: TTmxObjectGroup);
var
  TmxObject: TTmxObject;
  Tileset: TTmxTileset;
  TileId: Integer;
  Image: TPngImage;
  ObjRect: TRect;
begin
  for TmxObject in ObjectGroup.Objects do
  begin
    Tileset := FMap.Tilesets[0];
    TileId := TmxObject.Gid - Tileset.FirstGid;
    if TileId >= 0 then
    begin
      Image := FTextures[TileId];

      ObjRect.Left := 0;
      ObjRect.Top := 0;
      ObjRect.Right := Round(TmxObject.Width);
      ObjRect.Bottom := Round(TmxObject.Height);
      // выравнивание по левому нижнему краю
      ObjRect.Offset(Round(TmxObject.X), Round(TmxObject.Y) - ObjRect.Bottom);
      FBuffer.Canvas.StretchDraw(ObjRect, Image);
    end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Tileset: TTmxTileset;
  TileKey: Integer;
  Tile: TTmxTile;
  Image: TPngImage;
begin
  FBuffer := TBitmap.Create;

  FMap := TTmxMap.Create;
  FMap.Load('map\sandbox2.tmx');

  FTextures := TObjectDictionary<Integer, TPngImage>.Create([doOwnsValues]);

  Tileset := FMap.Tilesets[0];
  for TileKey in Tileset.Tiles.Keys do
  begin
    Tile := Tileset.Tiles[TileKey];

    Image := TPngImage.Create;
    Image.LoadFromFile(Tile.Image.Source);
    Image.Transparent := True;
    FTextures.Add(TileKey, Image);
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
  X, Y, I: Integer;
  Layer: TTmxLayer;
  Gid: Integer;
  Tileset: TTmxTileset;
  TileId: Integer;
  Position: TPoint;
begin
  FBuffer.Canvas.Brush.Color := FMap.BackgroundColor;
  FBuffer.Canvas.FillRect(ClientRect);

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
