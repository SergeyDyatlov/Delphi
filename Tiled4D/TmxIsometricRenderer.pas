unit TmxIsometricRenderer;

interface

uses
  System.Types, Vcl.Graphics, TmxMap, TmxTileLayer, TmxObjectGroup;

type
  TTmxIsometricRenderer = class
  private
    FMap: TTmxMap;
    function ScreenToTileCoords(X, Y: Integer): TPoint;
    function TileToScreenCoords(X, Y: Integer): TPoint;
    function GetTileCoords(X, Y: Integer): TPoint;
    procedure DrawGrid(Canvas: TCanvas; Exposed: TRect);
    procedure DrawTileLayer(Canvas: TCanvas; Layer: TTmxTileLayer; Exposed: TRect);
    procedure DrawObjectGroup(Canvas: TCanvas; Group: TTmxObjectGroup; Exposed: TRect);
  public
    constructor Create(AMap: TTmxMap);
    procedure Draw(Canvas: TCanvas; Exposed: TRect);
  end;

implementation

uses
  TmxTileset, TmxLayer, Math;

{ TTmxIsometricRenderer }

constructor TTmxIsometricRenderer.Create(AMap: TTmxMap);
begin
  FMap := AMap;
end;

procedure TTmxIsometricRenderer.Draw(Canvas: TCanvas; Exposed: TRect);
var
  Layer: TTmxLayer;
  TileLayer: TTmxTileLayer;
  ObjectGroup: TTmxObjectGroup;
begin
  DrawGrid(Canvas, Exposed);
  for Layer in FMap.Layers do
  begin
    if Layer.Visible then
    begin
      case Layer.LayerType of
        ltTileLayer:
          begin
            TileLayer := Layer as TTmxTileLayer;
            DrawTileLayer(Canvas, TileLayer, Exposed);
          end;
        ltObjectGroup:
          begin
            ObjectGroup := Layer as TTmxObjectGroup;
            DrawObjectGroup(Canvas, ObjectGroup, Exposed);
          end;
      end;
    end;
  end;
end;

procedure TTmxIsometricRenderer.DrawGrid(Canvas: TCanvas; Exposed: TRect);
var
  X, Y: Integer;
  LineCoords: TPoint;
begin
  for Y := 0 to FMap.Height do
  begin
    LineCoords := TPoint.Create(0, Y * FMap.TileHeight);
    LineCoords.Offset(FMap.TileHeight div 2, -FMap.TileHeight div 2);
    LineCoords.Offset(Exposed.Left, Exposed.Top);
    LineCoords := ScreenToTileCoords(LineCoords.X, LineCoords.Y);
    Canvas.MoveTo(LineCoords.X, LineCoords.Y);
    LineCoords := TPoint.Create(FMap.Width * FMap.TileHeight, Y * FMap.TileHeight);
    LineCoords.Offset(FMap.TileHeight div 2, -FMap.TileHeight div 2);
    LineCoords.Offset(Exposed.Left, Exposed.Top);
    LineCoords := ScreenToTileCoords(LineCoords.X, LineCoords.Y);
    Canvas.LineTo(LineCoords.X, LineCoords.Y);
  end;
  for X := 0 to FMap.Width do
  begin
    LineCoords := TPoint.Create(X * FMap.TileHeight, 0);
    LineCoords.Offset(FMap.TileHeight div 2, -FMap.TileHeight div 2);
    LineCoords.Offset(Exposed.Left, Exposed.Top);
    LineCoords := ScreenToTileCoords(LineCoords.X, LineCoords.Y);
    Canvas.MoveTo(LineCoords.X, LineCoords.Y);
    LineCoords := TPoint.Create(X * FMap.TileHeight, FMap.Height * FMap.TileHeight);
    LineCoords.Offset(FMap.TileHeight div 2, -FMap.TileHeight div 2);
    LineCoords.Offset(Exposed.Left, Exposed.Top);
    LineCoords := ScreenToTileCoords(LineCoords.X, LineCoords.Y);
    Canvas.LineTo(LineCoords.X, LineCoords.Y);
  end;
end;

procedure TTmxIsometricRenderer.DrawObjectGroup(Canvas: TCanvas; Group: TTmxObjectGroup;
  Exposed: TRect);
var
  TmxObject: TTmxObject;
  TopLeft, TopRight, BottomLeft, BottomRight: TPoint;
  TextWidth, TextHeight: Integer;
begin
  for TmxObject in Group.Objects do
  begin
    TopLeft := ScreenToTileCoords(TmxObject.X, TmxObject.Y);
    TopRight := ScreenToTileCoords(TmxObject.X + TmxObject.Width, TmxObject.Y);
    BottomRight := ScreenToTileCoords(TmxObject.X + TmxObject.Width,
      TmxObject.Y + TmxObject.Height);
    BottomLeft := ScreenToTileCoords(TmxObject.X, TmxObject.Y + TmxObject.Height);

    Canvas.Brush.Color := clSkyBlue;
    Canvas.Polygon([TopLeft, TopRight, BottomRight, BottomLeft]);

    TextWidth := Canvas.TextWidth(TmxObject.Name);
    TextHeight := Canvas.TextHeight(TmxObject.Name);
    TopLeft.Offset(-TextWidth div 2, -TextHeight - 2);
    Canvas.TextOut(TopLeft.X, TopLeft.Y, TmxObject.Name);
  end;
end;

procedure TTmxIsometricRenderer.DrawTileLayer(Canvas: TCanvas; Layer: TTmxTileLayer;
  Exposed: TRect);
var
  StartCoords: TPoint;
  EndCoords: TPoint;
  TileCoords: TPoint;
  Y, X: Integer;
  Cell: TTmxCell;
begin
  StartCoords.X := Max(0, 0 - Exposed.Left);
  StartCoords.Y := Max(0, 0 - Exposed.Top);
  EndCoords.X := Min(FMap.Width, StartCoords.X + Exposed.Width);
  EndCoords.Y := Min(FMap.Height, StartCoords.Y + Exposed.Height);
  StartCoords.X := Max(0, EndCoords.X - Exposed.Width);
  StartCoords.Y := Max(0, EndCoords.Y - Exposed.Height);

  for Y := StartCoords.Y to EndCoords.Y - 1 do
  begin
    for X := StartCoords.X to EndCoords.X - 1 do
    begin
      Cell := Layer.GetCell(X, Y);
      if (Cell = nil) then
        Continue;

      TileCoords := TPoint.Create(X * FMap.TileHeight, Y * FMap.TileHeight);
      TileCoords.Offset(Exposed.Left, Exposed.Top);
      TileCoords := ScreenToTileCoords(TileCoords.X, TileCoords.Y);
      TileCoords.Offset(0, -(Cell.Tile.Height - FMap.TileHeight));
      Canvas.Draw(TileCoords.X, TileCoords.Y, Cell.Tile.Image);
    end;
  end;
end;

function TTmxIsometricRenderer.GetTileCoords(X, Y: Integer): TPoint;
begin
  Result.X := X div FMap.TileHeight;
  Result.Y := Y div FMap.TileHeight;
end;

function TTmxIsometricRenderer.ScreenToTileCoords(X, Y: Integer): TPoint;
begin
  Result.X := X - Y;
  Result.Y := (X + Y) div 2;
end;

function TTmxIsometricRenderer.TileToScreenCoords(X, Y: Integer): TPoint;
begin
  Result.X := (2 * Y + X) div 2;
  Result.Y := -X + Result.X;
end;

end.
