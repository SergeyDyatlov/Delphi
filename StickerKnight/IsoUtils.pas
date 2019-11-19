unit IsoUtils;

interface

uses
  Winapi.Windows;

function IsoToPos(Point: TPoint): TPoint;
function PosToIso(Point: TPoint): TPoint;
function GetTileCoord(Point: TPoint; TileSize: Integer): TPoint;

implementation

function IsoToPos(Point: TPoint): TPoint;
begin
//  Result.X := (2 * Point.Y + Point.X) div 2;
//  Result.Y := -Point.X + Result.X;

  Result.X := (2 * Point.Y + Point.X) div 2;
  Result.Y := (2 * Point.Y - Point.X) div 2;
end;

function PosToIso(Point: TPoint): TPoint;
begin
  Result.X := Point.X - Point.Y;
  Result.Y := (Point.X + Point.Y) div 2;
end;

function GetTileCoord(Point: TPoint; TileSize: Integer): TPoint;
begin
  Result.X := Point.X div TileSize;
  Result.Y := Point.Y div TileSize;
end;

end.
