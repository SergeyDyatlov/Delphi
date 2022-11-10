unit TmxTileLayer;

interface

uses
  TmxLayer, TmxTileset, System.Generics.Collections;

type
  TTmxCell = class
  private
    FTileset: TTmxTileset;
    FTileId: Integer;
    function GetTile: TTmxTile;
  public
    constructor Create(ATileset: TTmxTileset; ATileId: Integer);
    property Tileset: TTmxTileset read FTileset write FTileset;
    property TileId: Integer read FTileId write FTileId;
    property Tile: TTmxTile read GetTile;
  end;

  TTmxTileLayer = class(TTmxLayer)
  private
    FGrid: array of array of TTmxCell;
    FWidth: Integer;
    FHeight: Integer;
    procedure SetSize(AWidth, AHeight: Integer);
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
  public
    constructor Create(const AName: string); override;
    destructor Destroy; override;
    procedure Clear;
    procedure SetCell(Cell: TTmxCell; X, Y: Integer);
    function GetCell(X, Y: Integer): TTmxCell;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
  end;

implementation

{ TTmxCell }

constructor TTmxCell.Create(ATileset: TTmxTileset; ATileId: Integer);
begin
  FTileset := ATileset;
  FTileId := ATileId;
end;

function TTmxCell.GetTile: TTmxTile;
begin
  if FTileset.Tiles.ContainsKey(FTileId) then
    Result := FTileset.Tiles[FTileId]
  else
    Result := nil;
end;

{ TTmxTileLayer }

procedure TTmxTileLayer.Clear;
var
  X, Y: Integer;
begin
  for X := 0 to Width - 1 do
  begin
    for Y := 0 to Height - 1 do
      GetCell(X, Y).Free;
  end;
end;

constructor TTmxTileLayer.Create(const AName: string);
begin
  inherited;
  LayerType := ltTileLayer;
end;

destructor TTmxTileLayer.Destroy;
begin
  Clear;
  inherited;
end;

function TTmxTileLayer.GetCell(X, Y: Integer): TTmxCell;
begin
  if (X in [0 .. FWidth - 1]) and (Y in [0 .. FHeight - 1]) then
    Result := FGrid[Y, X]
  else
    Result := nil;
end;

procedure TTmxTileLayer.SetCell(Cell: TTmxCell; X, Y: Integer);
begin
  FGrid[Y, X] := Cell;
end;

procedure TTmxTileLayer.SetHeight(const Value: Integer);
begin
  FHeight := Value;
  SetSize(Width, Value);
end;

procedure TTmxTileLayer.SetSize(AWidth, AHeight: Integer);
begin
  SetLength(FGrid, Height, Width);
end;

procedure TTmxTileLayer.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  SetSize(Value, Height);
end;

end.
