unit TmxTileset;

interface

uses
  System.Generics.Collections, TmxImage, FMX.Graphics;

type
  TTmxTileset = class;

  TTmxTile = class
  private
    FId: Integer;
    FTileset: TTmxTileset;
    FImage: TBitmap;
    FWidth: Integer;
    FHeight: Integer;
    FSource: string;
  public
    constructor Create(AId: Integer; ATileset: TTmxTileset);
    destructor Destroy; override;
    property Id: Integer read FId write FId;
    property Tileset: TTmxTileset read FTileset write FTileset;
    property Bitmap: TBitmap read FImage write FImage;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property Source: string read FSource write FSource;
  end;

  TTmxTileDictionary = TObjectDictionary<Integer, TTmxTile>;

  TTmxTileset = class
  private
    FFirstGId: Cardinal;
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
    property FirstGId: Cardinal read FFirstGId write FFirstGId;
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
  System.Types, System.UITypes;

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
var
  Image: TBitmap;
  RowCount, ColCount: Integer;
  X, Y: Integer;
  TileId: Integer;
  Tile: TTmxTile;
  DstRect, SrcRect: TRectF;
begin
  Image := TBitmap.Create;
  try
    Image.LoadFromFile(FileName);

    RowCount := FImage.Width div FTileWidth;
    ColCount := FImage.Height div FTileHeight;

    TileId := 0;
    for Y := 0 to ColCount - 1 do
    begin
      for X := 0 to RowCount - 1 do
      begin
        Tile := TTmxTile.Create(TileId, Self);
        FTiles.Add(TileId, Tile);

        SrcRect.Left := X * FTileWidth;
        SrcRect.Top := Y * FTileHeight;
        SrcRect.Width := FTileWidth;
        SrcRect.Height := FTileHeight;

        DstRect.Left := 0;
        DstRect.Top := 0;
        DstRect.Width := FTileWidth;
        DstRect.Height := FTileHeight;

        Tile.Bitmap.SetSize(FTileWidth, FTileHeight);
        Tile.Bitmap.Canvas.BeginScene;
        Tile.Bitmap.Canvas.DrawBitmap(Image, SrcRect, DstRect, 20);
        Tile.Bitmap.Canvas.EndScene;

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
  FImage := TBitmap.Create;
end;

destructor TTmxTile.Destroy;
begin
  FImage.Free;
  inherited;
end;

end.
