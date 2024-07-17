unit MainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.Generics.Collections, SquareGrid, BreadthFirstSearch;

type
  TPathFinder = class(TBreadthFirstSearch<TPoint>)
  private
    FGrid: TSquareGrid;
  protected
    function GetNeighbors(Point: TPoint): TArray<TPoint>; override;
  public
    constructor Create(AGrid: TSquareGrid);
    property Grid: TSquareGrid read FGrid;
  end;

  TMainForm = class(TForm)
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FGrid: TSquareGrid;
    FSearchPath: TArray<TPoint>;
    FPathFinder: TPathFinder;
    { Private declarations }
    procedure DrawGrid(Canvas: TCanvas; RowCount, ColCount, CellSize: Integer);
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

procedure TMainForm.DrawGrid(Canvas: TCanvas;
  RowCount, ColCount, CellSize: Integer);
var
  Col, Row: Integer;
  GridWidth, GridHeight: Integer;
  StartPoint, EndPoint: TPoint;
  CellText: string;
  TextWidth, TextHeight: Integer;
  TextX, TextY: Integer;
begin
  GridWidth := ColCount * CellSize;
  GridHeight := RowCount * CellSize;

  for Col := 0 to ColCount do
  begin
    StartPoint := Point(Col * CellSize, 0);
    EndPoint := Point(Col * CellSize, GridHeight);
    DrawLine(Canvas, StartPoint, EndPoint);
  end;

  for Row := 0 to RowCount do
  begin
    StartPoint := Point(0, Row * CellSize);
    EndPoint := Point(GridWidth, Row * CellSize);
    DrawLine(Canvas, StartPoint, EndPoint);
  end;

  Canvas.Brush.Style := bsClear;
  for Row := 0 to RowCount - 1 do
  begin
    for Col := 0 to ColCount - 1 do
    begin
      CellText := Format('%d, %d', [Col, Row]);
      TextWidth := Canvas.TextWidth(CellText);
      TextHeight := Canvas.TextHeight(CellText);

      TextX := (Col * CellSize) + (CellSize div 2) - (TextWidth div 2);
      TextY := (Row * CellSize) + (CellSize div 2) - (TextHeight div 2);

      Canvas.TextOut(TextX, TextY, CellText);
    end;
  end;
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
  FGrid.Walls.Add(Point(2, 1));
  FGrid.Walls.Add(Point(2, 0));
  FGrid.Walls.Add(Point(1, 6));
  FGrid.Walls.Add(Point(2, 6));
  FGrid.Walls.Add(Point(3, 6));

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

  FGrid.Walls.Add(Point(24, 0));
  FGrid.Walls.Add(Point(24, 1));
  FGrid.Walls.Add(Point(24, 2));
  FGrid.Walls.Add(Point(24, 3));
  FGrid.Walls.Add(Point(25, 3));
  FGrid.Walls.Add(Point(26, 3));
  FGrid.Walls.Add(Point(27, 3));

  FPathFinder := TPathFinder.Create(FGrid);
  FSearchPath := FPathFinder.Search(StartPoint, EndPoint);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FPathFinder.Free;
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
  FSearchPath := FPathFinder.Search(StartPoint, EndPoint);
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
  for Current in FPathFinder.Visited.Keys do
  begin
    X := Current.X * TileSize;
    Y := Current.Y * TileSize;
    Canvas.FillRect(Bounds(X, Y, TileSize, TileSize));
  end;

  Canvas.Brush.Color := clBlack;
  DrawGrid(Canvas, 15, 28, TileSize);

  Canvas.Brush.Color := clHighlight;
  for Current in FSearchPath do
  begin
    X := Current.X * TileSize;
    Y := Current.Y * TileSize;
    Canvas.FillRect(Bounds(X, Y, TileSize, TileSize));
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

{ TPathFinder }

constructor TPathFinder.Create(AGrid: TSquareGrid);
begin
  inherited Create;
  FGrid := AGrid;
end;

function TPathFinder.GetNeighbors(Point: TPoint): TArray<TPoint>;
begin
  Result := FGrid.GetNeighbors(Point);
end;

initialization

ReportMemoryLeaksOnShutdown := True;

end.
