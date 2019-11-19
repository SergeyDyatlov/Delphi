unit TmxUtils;

interface

uses
  Winapi.Windows, System.SysUtils, TmxMap, TmxTileset, System.UITypes,
  Vcl.Graphics;

function GetTilesetByGid(Map: TTmxMap; Gid: Integer): TTmxTileset;
function GetImageRectByTileId(Tileset: TTmxTileset; Gid: Integer): TRect;
function HtmlToColor(Color: string): TColor;

implementation

function GetImageRectByTileId(Tileset: TTmxTileset; Gid: Integer): TRect;
var
  RowCount: Integer;
begin
  RowCount := Tileset.Image.Width div Tileset.TileWidth;
  Result.Left := (Gid mod RowCount) * Tileset.TileWidth;
  Result.Top := (Gid div RowCount) * Tileset.TileHeight;
  Result.Width := Tileset.TileWidth;
  Result.Height := Tileset.TileHeight;
end;

function GetTilesetByGid(Map: TTmxMap; Gid: Integer): TTmxTileset;
var
  Tileset: TTmxTileset;
  Key: Integer;
begin
  Result := nil;
  for Key in Map.Tilesets.Keys do
  begin
    Tileset := Map.Tilesets[Key];
    if Tileset.FirstGid <= Gid then
      Exit(Tileset);
  end;
end;

function HtmlToColor(Color: string): TColor;
var
  Value: string;
begin
  Value := StringReplace(Color, '#', '', [rfReplaceAll]);
  Value := '$00' + Copy(Value, 5, 2) + Copy(Value, 3, 2) + Copy(Value, 1, 2);
  Result := StringToColor(Value);
end;

end.
