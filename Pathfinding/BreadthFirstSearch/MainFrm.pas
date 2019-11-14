unit MainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.Generics.Collections, SquareGrid;

type
  TSearchPath = TDictionary<TPoint, TPoint>;

  TMainForm = class(TForm)
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FGrid: TSquareGrid;
    FSearchPath: TSearchPath;
    { Private declarations }
    procedure DrawGrid(Canvas: TCanvas; RowCount, ColCount, CellSize: Integer);
    procedure BreadthFirstSearch(Grid: TSquareGrid;
      StartPoint, EndPoint: TPoint);

  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  StartPoint: TPoint = (X: 4; Y: 1);
  EndPoint: TPoint = (X: 18; Y: 13);

implementation

{$R *.dfm}

uses CanvasUtils, System.Types;

procedure TMainForm.BreadthFirstSearch(Grid: TSquareGrid;
  StartPoint, EndPoint: TPoint);
var
  Frontier: TQueue<TPoint>;
  Current, Next: TPoint;
  Neighbors: TArray<TPoint>;
begin
  FSearchPath.Clear;
  Frontier := TQueue<TPoint>.Create;
  try
    Frontier.Enqueue(StartPoint);
    FSearchPath.Add(StartPoint, Point(0, 0));
    while Frontier.Count > 0 do
    begin
      Current := Frontier.Dequeue;
      if Current = EndPoint then
        Break;

      Neighbors := FGrid.GetNeighbors(Current);
      for Next in Neighbors do
      begin
        if not FSearchPath.ContainsKey(Next) then
        begin
          Frontier.Enqueue(Next);
          FSearchPath.Add(Next, Current - Next);
        end;
      end;
    end;
  finally
    Frontier.Free;
  end;
end;

procedure TMainForm.DrawGrid(Canvas: TCanvas;
  RowCount, ColCount, CellSize: Integer);
var
  X, Y: Integer;
  GridWidth, GridHeight: Integer;
begin
  GridWidth := ColCount * CellSize;
  GridHeight := RowCount * CellSize;
  for X := 0 to ColCount do
    DrawLine(Canvas, Point(X * CellSize, 0), Point(X * CellSize, GridHeight));
  for Y := 0 to RowCount do
    DrawLine(Canvas, Point(0, Y * CellSize), Point(GridWidth, Y * CellSize));
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FGrid := TSquareGrid.Create(28, 15);
  FGrid.Walls.Add(Point(10, 7));
  FGrid.Walls.Add(Point(11, 7));
  FGrid.Walls.Add(Point(12, 7));
  FGrid.Walls.Add(Point(13, 7));
  FGrid.Walls.Add(Point(14, 7));
  FGrid.Walls.Add(Point(15, 7));
  FGrid.Walls.Add(Point(16, 7));
  FGrid.Walls.Add(Point(7, 7));
  FGrid.Walls.Add(Point(6, 7));
  FGrid.Walls.Add(Point(5, 7));
  FGrid.Walls.Add(Point(5, 5));
  FGrid.Walls.Add(Point(5, 6));
  FGrid.Walls.Add(Point(1, 6));
  FGrid.Walls.Add(Point(2, 6));
  FGrid.Walls.Add(Point(3, 6));
  FGrid.Walls.Add(Point(5, 10));
  FGrid.Walls.Add(Point(5, 11));
  FGrid.Walls.Add(Point(5, 12));
  FGrid.Walls.Add(Point(5, 9));
  FGrid.Walls.Add(Point(5, 8));
  FGrid.Walls.Add(Point(12, 8));
  FGrid.Walls.Add(Point(12, 9));
  FGrid.Walls.Add(Point(12, 10));
  FGrid.Walls.Add(Point(12, 11));
  FGrid.Walls.Add(Point(15, 14));
  FGrid.Walls.Add(Point(15, 13));
  FGrid.Walls.Add(Point(15, 12));
  FGrid.Walls.Add(Point(15, 11));
  FGrid.Walls.Add(Point(15, 10));
  FGrid.Walls.Add(Point(17, 7));
  FGrid.Walls.Add(Point(18, 7));
  FGrid.Walls.Add(Point(21, 7));
  FGrid.Walls.Add(Point(21, 6));
  FGrid.Walls.Add(Point(21, 5));
  FGrid.Walls.Add(Point(21, 4));
  FGrid.Walls.Add(Point(21, 3));
  FGrid.Walls.Add(Point(22, 5));
  FGrid.Walls.Add(Point(23, 5));
  FGrid.Walls.Add(Point(24, 5));
  FGrid.Walls.Add(Point(25, 5));
  FGrid.Walls.Add(Point(18, 10));
  FGrid.Walls.Add(Point(20, 10));
  FGrid.Walls.Add(Point(19, 10));
  FGrid.Walls.Add(Point(21, 10));
  FGrid.Walls.Add(Point(22, 10));
  FGrid.Walls.Add(Point(23, 10));
  FGrid.Walls.Add(Point(14, 4));
  FGrid.Walls.Add(Point(14, 5));
  FGrid.Walls.Add(Point(14, 6));
  FGrid.Walls.Add(Point(14, 0));
  FGrid.Walls.Add(Point(14, 1));
  FGrid.Walls.Add(Point(9, 2));
  FGrid.Walls.Add(Point(9, 1));
  FGrid.Walls.Add(Point(7, 3));
  FGrid.Walls.Add(Point(8, 3));
  FGrid.Walls.Add(Point(10, 3));
  FGrid.Walls.Add(Point(9, 3));
  FGrid.Walls.Add(Point(11, 3));
  FGrid.Walls.Add(Point(2, 5));
  FGrid.Walls.Add(Point(2, 4));
  FGrid.Walls.Add(Point(2, 3));
  FGrid.Walls.Add(Point(2, 2));
  FGrid.Walls.Add(Point(2, 0));
  FGrid.Walls.Add(Point(2, 1));
  FGrid.Walls.Add(Point(0, 11));
  FGrid.Walls.Add(Point(1, 11));
  FGrid.Walls.Add(Point(2, 11));
  FGrid.Walls.Add(Point(21, 2));
  FGrid.Walls.Add(Point(20, 11));
  FGrid.Walls.Add(Point(20, 12));
  FGrid.Walls.Add(Point(23, 13));
  FGrid.Walls.Add(Point(23, 14));
  FGrid.Walls.Add(Point(24, 10));
  FGrid.Walls.Add(Point(25, 10));
  FGrid.Walls.Add(Point(6, 12));
  FGrid.Walls.Add(Point(7, 12));
  FGrid.Walls.Add(Point(10, 12));
  FGrid.Walls.Add(Point(11, 12));
  FGrid.Walls.Add(Point(12, 12));
  FGrid.Walls.Add(Point(5, 3));
  FGrid.Walls.Add(Point(6, 3));
  FGrid.Walls.Add(Point(5, 4));

  FSearchPath := TSearchPath.Create;
  BreadthFirstSearch(FGrid, EndPoint, StartPoint);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FSearchPath.Free;
  FGrid.Free;
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    StartPoint.X := X div TileSize;
    StartPoint.Y := Y div TileSize;
  end
  else if Button = mbRight then
  begin
    EndPoint.X := X div TileSize;
    EndPoint.Y := Y div TileSize;
  end;
  BreadthFirstSearch(FGrid, EndPoint, StartPoint);
  Invalidate;
end;

procedure TMainForm.FormPaint(Sender: TObject);
var
  X, Y: Integer;
  Current: TPoint;
begin
  Canvas.Brush.Color := clWindowFrame;
  FGrid.Draw(Canvas);

  Canvas.Brush.Color := clSkyBlue;
  for Current in FSearchPath.Keys do
  begin
    X := Current.X * TileSize;
    Y := Current.Y * TileSize;
    Canvas.FillRect(Bounds(X, Y, TileSize, TileSize));
  end;

  Canvas.Brush.Color := clBlack;
  DrawGrid(Canvas, 15, 28, TileSize);

  Canvas.Brush.Color := clHighlight;
  Current := StartPoint + FSearchPath[StartPoint];
  while Current <> EndPoint do
  begin
    X := Current.X * TileSize;
    Y := Current.Y * TileSize;
    Canvas.FillRect(Bounds(X, Y, TileSize, TileSize));
    Current := Current + FSearchPath[Current];
  end;

  Canvas.Brush.Color := clGreen;
  X := StartPoint.X * TileSize;
  Y := StartPoint.Y * TileSize;
  Canvas.FillRect(Bounds(X, Y, TileSize, TileSize));

  Canvas.Brush.Color := clRed;
  X := EndPoint.X * TileSize;
  Y := EndPoint.Y * TileSize;
  Canvas.FillRect(Bounds(X, Y, TileSize, TileSize));
end;

initialization

ReportMemoryLeaksOnShutdown := True;

end.
