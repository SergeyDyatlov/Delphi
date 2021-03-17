unit TmxTileset;

interface

uses
  System.Generics.Collections, TmxImage, PngImage;

type
  TTmxTileset = class;

  TTmxTile = class
  private
    FId: Integer;
    FTileset: TTmxTileset;
    FImage: TPngImage;
    FWidth: Integer;
    FHeight: Integer;
  public
    constructor Create(AId: Integer; ATileset: TTmxTileset);
    destructor Destroy; override;
    property Id: Integer read FId write FId;
    property Tileset: TTmxTileset read FTileset write FTileset;
    property Image: TPngImage read FImage write FImage;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  end;

  TTmxTileDictionary = TObjectDictionary<Integer, TTmxTile>;

  TTmxTileset = class
  private
    FFirstGId: Integer;
    FName: string;
    FTileWidth: Integer;
    FTileHeight: Integer;
    FTileCount: Integer;
    FColumns: Integer;
    FImage: TTmxImage;
    FTiles: TTmxTileDictionary;
  public
    constructor Create(AFirstGId: Integer);
    destructor Destroy; override;
    procedure LoadFromFile(const FileName: string);
    property FirstGId: Integer read FFirstGId write FFirstGId;
    property Name: string read FName write FName;
    property TileWidth: Integer read FTileWidth write FTileWidth;
    property TileHeight: Integer read FTileHeight write FTileHeight;
    property TileCount: Integer read FTileCount write FTileCount;
    property Columns: Integer read FColumns write FColumns;
    property Image: TTmxImage read FImage write FImage;
    property Tiles: TTmxTileDictionary read FTiles write FTiles;
  end;

implementation

uses
  System.Types, Vcl.Graphics, Winapi.Windows;

{ TTmxTileset }

constructor TTmxTileset.Create(AFirstGId: Integer);
begin
  FFirstGId := AFirstGId;
  FImage := TTmxImage.Create;
  FTiles := TTmxTileDictionary.Create([doOwnsValues]);
end;

destructor TTmxTileset.Destroy;
begin
  FTiles.Free;
  FImage.Free;
  inherited;
end;

procedure TTmxTileset.LoadFromFile(const FileName: string);

  function CopyPNG(const Image: TPngImage; const R: TRect): TPngImage;
  var
    I: Integer;
  begin
    Result := TPngImage.CreateBlank(COLOR_RGBALPHA, 8, R.Width, R.Height);
    BitBlt(Result.Canvas.Handle, 0, 0, R.Width, R.Height, Image.Canvas.Handle, R.Left,
      R.Top, SRCCOPY);

    for I := 0 to R.Height - 1 do
    begin
      if not Assigned(Result.AlphaScanline[I]) or
        not Assigned(Image.AlphaScanline[I + R.Top]) then
        Break;

      CopyMemory(Result.AlphaScanline[I], PByte(Integer(Image.AlphaScanline[I + R.Top]) +
        R.Left), R.Width);
    end;
  end;

var
  Image: TPngImage;
  RowCount, ColCount: Integer;
  X, Y: Integer;
  TileId: Integer;
  Tile: TTmxTile;
  ImageRect: TRect;
begin
  Image := TPngImage.Create;
  try
    Image.LoadFromFile(FileName);

    RowCount := FImage.Width div FTileWidth;
    ColCount := FImage.Height div FTileHeight;

    TileId := 0;
    for Y := 0 to ColCount - 1 do
    begin
      for X := 0 to RowCount - 1 do
      begin
        ImageRect.Left := X * FTileWidth;
        ImageRect.Top := Y * FTileHeight;
        ImageRect.Width := FTileWidth;
        ImageRect.Height := FTileHeight;

        Tile := TTmxTile.Create(TileId, Self);
        FTiles.Add(TileId, Tile);
        Tile.Image := CopyPNG(Image, ImageRect);

        Inc(TileId);
      end;
    end;
  finally
    Image.Free;
  end;
end;

{ TTmxTile }

constructor TTmxTile.Create(AId: Integer; ATileset: TTmxTileset);
begin
  FId := AId;
  FTileset := ATileset;
  FWidth := FTileset.TileWidth;
  FHeight := FTileset.TileHeight;
end;

destructor TTmxTile.Destroy;
begin
  FImage.Free;
  inherited;
end;

end.
