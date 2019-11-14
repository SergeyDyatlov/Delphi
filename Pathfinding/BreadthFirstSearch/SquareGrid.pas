unit SquareGrid;

interface

uses System.Types, Vcl.Graphics, Winapi.Windows, System.Generics.Collections;

const
  TileSize = 48;

type
  TSquareGrid = class
  private
    FWidth: Integer;
    FHeight: Integer;
    FConnections: TList<TPoint>;
    FWalls: TList<TPoint>;
    function InBounds(Node: TPoint): boolean;
    function Passable(Node: TPoint): boolean;
  public
    constructor Create(AWidth, AHeight: Integer);
    destructor Destroy; override;
    function GetNeighbors(Node: TPoint): TArray<TPoint>;
    procedure Draw(Canvas: TCanvas);
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property Walls: TList<TPoint> read FWalls write FWalls;
  end;

implementation

constructor TSquareGrid.Create(AWidth, AHeight: Integer);
begin
  FConnections := TList<TPoint>.Create;
  FConnections.Add(Point(1, 0));
  FConnections.Add(Point(-1, 0));
  FConnections.Add(Point(0, 1));
  FConnections.Add(Point(0, -1));
  FWalls := TList<TPoint>.Create;
  FWidth := AWidth;
  FHeight := AHeight;
end;

destructor TSquareGrid.Destroy;
begin
  FWalls.Free;
  FConnections.Free;
  inherited;
end;

procedure TSquareGrid.Draw(Canvas: TCanvas);
var
  X, Y: Integer;
  CellRect: TRect;
  I: Integer;
begin
  for I := 0 to FWalls.Count - 1 do
  begin
    X := FWalls[I].X * TileSize;
    Y := FWalls[I].Y * TileSize;
    CellRect := Bounds(X, Y, TileSize, TileSize);
    Canvas.FillRect(CellRect);
  end;
end;

function TSquareGrid.GetNeighbors(Node: TPoint): TArray<TPoint>;
var
  Neighbors: TList<TPoint>;
  Neighbor: TPoint;
  Connection: TPoint;
begin
  Neighbors := TList<TPoint>.Create;
  try
    for Connection in FConnections do
    begin
      Neighbor := Node + Connection;
      if not InBounds(Neighbor) then
        Continue;
      if not Passable(Neighbor) then
        Continue;
      Neighbors.Add(Neighbor);
    end;
    Result := Neighbors.ToArray;
  finally
    Neighbors.Free;
  end;
end;

function TSquareGrid.InBounds(Node: TPoint): boolean;
begin
  Result := True;
  if (Node.X < 0) or (Node.X > FWidth - 1) then
    Exit(False);
  if (Node.Y < 0) or (Node.Y > FHeight - 1) then
    Exit(False);
end;

function TSquareGrid.Passable(Node: TPoint): boolean;
begin
  Result := not FWalls.Contains(Node);
end;

end.
