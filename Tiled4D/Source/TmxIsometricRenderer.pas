unit TmxIsometricRenderer;

interface

uses
  System.Types, System.UITypes, FMX.Types, TmxMap, TmxTileLayer, TmxObjectGroup,
  TmxTileset, TmxLayer, TmxMapRenderer, FMX.Graphics;

type
  TTmxIsometricRenderer = class(TTmxMapRenderer)
  protected
    function ScreenToPixelCoords(X, Y: Double): TPointF;
    function PixelToScreenCoords(X, Y: Double): TPointF;
    function ScreenToTileCoords(X, Y: Double): TPointF; override;
    function TileToScreenCoords(X, Y: Double): TPointF; override;

    procedure DrawGrid(Canvas: TCanvas); override;
    procedure DrawObjectGroup(Canvas: TCanvas; Group: TTmxObjectGroup); override;
    procedure DrawTileLayer(Canvas: TCanvas; Layer: TTmxTileLayer); override;
  public
    constructor Create(AMap: TTmxMap); override;
    destructor Destroy; override;
  end;

implementation

uses
  System.Math, System.Math.Vectors;

{ TTmxIsometricRenderer }

constructor TTmxIsometricRenderer.Create(AMap: TTmxMap);
begin
  inherited;

end;

destructor TTmxIsometricRenderer.Destroy;
begin

  inherited;
end;

procedure TTmxIsometricRenderer.DrawGrid(Canvas: TCanvas);
var
  ScreenRect: TRect;
  StartX, StartY, EndX, EndY: Integer;
  StartPoint, EndPoint: TPointF;
  X, Y: Integer;
  CanvasState: TCanvasSaveState;
begin
  ScreenRect := Camera;

  ScreenRect.Inflate(Map.TileWidth div 2, Map.TileHeight div 2);

  StartX := Trunc(ScreenToTileCoords(ScreenRect.Left, ScreenRect.Top).X);
  StartY := Trunc(ScreenToTileCoords(ScreenRect.Right, ScreenRect.Top).Y);
  EndX := Trunc(ScreenToTileCoords(ScreenRect.Right, ScreenRect.Bottom).X);
  EndY := Trunc(ScreenToTileCoords(ScreenRect.Left, ScreenRect.Bottom).Y);

  StartX := Max(0, StartX);
  StartY := Max(0, StartY);
  EndX := Min(Map.Width, EndX);
  EndY := Min(Map.Height, EndY);

  Canvas.BeginScene;
  CanvasState := Canvas.SaveState;
  try
    Canvas.Stroke.Color := TAlphaColors.Green;
    Canvas.Stroke.Kind := TBrushKind.Solid;

    for Y := StartY to EndY do
    begin
      StartPoint := TileToScreenCoords(StartX, Y);
      StartPoint.Offset(-Camera.Left, -Camera.Top);
      EndPoint := TileToScreenCoords(EndX, Y);
      EndPoint.Offset(-Camera.Left, -Camera.Top);
      Canvas.DrawLine(StartPoint, EndPoint, 20);
    end;

    for X := StartX to EndX do
    begin
      StartPoint := TileToScreenCoords(X, StartY);
      StartPoint.Offset(-Camera.Left, -Camera.Top);
      EndPoint := TileToScreenCoords(X, EndY);
      EndPoint.Offset(-Camera.Left, -Camera.Top);
      Canvas.DrawLine(StartPoint, EndPoint, 20);
    end;
  finally
    Canvas.RestoreState(CanvasState);
    Canvas.EndScene;
  end;

end;

procedure TTmxIsometricRenderer.DrawObjectGroup(Canvas: TCanvas;
  Group: TTmxObjectGroup);
var
  TmxObject: TTmxObject;
  Position: TPointF;
  Bounds: TRectF;
  Points: TPolygon;
  TextWidth: Double;
begin
  for TmxObject in Group.Objects do
  begin
    Position := TPointF.Create(TmxObject.X, TmxObject.Y);
    Bounds := TRectF.Create(Position, TmxObject.Width, TmxObject.Height);

    SetLength(Points, 4);
    Points[0] := PixelToScreenCoords(Bounds.Left, Bounds.Top);
    Points[0].Offset(-Camera.Left, -Camera.Top);
    Points[1] := PixelToScreenCoords(Bounds.Right, Bounds.Top);
    Points[1].Offset(-Camera.Left, -Camera.Top);
    Points[2] := PixelToScreenCoords(Bounds.Right, Bounds.Bottom);
    Points[2].Offset(-Camera.Left, -Camera.Top);
    Points[3] := PixelToScreenCoords(Bounds.Left, Bounds.Bottom);
    Points[3].Offset(-Camera.Left, -Camera.Top);

    Canvas.BeginScene;
    try
      Canvas.FillPolygon(Points, 20);

      TextWidth := Canvas.TextWidth(TmxObject.Name);
      Position := PixelToScreenCoords(TmxObject.X, TmxObject.Y);
      Position.Offset(-TextWidth / 2, -TmxObject.Height);
      Bounds := TRectF.Create(Position, TextWidth, TmxObject.Height);
      Bounds.Offset(-Camera.Left, -Camera.Top);

      Canvas.FillText(Bounds, TmxObject.Name, False, 100,
        [TFillTextFlag.RightToLeft], TTextAlign.Center, TTextAlign.Center);
    finally
      Canvas.EndScene;
    end;
  end;
end;

procedure TTmxIsometricRenderer.DrawTileLayer(Canvas: TCanvas;
  Layer: TTmxTileLayer);
var
  StartCoords, TileCoords: TPointF;
  TileRow, TileCol: TPoint;
  InTopHalf, InLeftHalf, Shifted: Boolean;
  Y, X: Double;
  Cell: TTmxCell;
  Position: TPointF;
  DstRect: TRectF;
begin
  TileCoords := ScreenToTileCoords(Camera.Left, Camera.Top);
  TileRow := Point(Floor(TileCoords.X), Floor(TileCoords.Y));
  StartCoords := TileToScreenCoords(TileRow.X, TileRow.Y);
  StartCoords.Offset(-Map.TileWidth / 2, Map.TileHeight);

  InTopHalf := StartCoords.Y - Camera.Top > Map.TileHeight / 2;
  InLeftHalf := Camera.Left - StartCoords.X < Map.TileWidth / 2;

  if InTopHalf then
  begin
    if InLeftHalf then
    begin
      TileRow.Offset(-1, 0);
      StartCoords.Offset(-Map.TileWidth / 2, 0);
    end
    else
    begin
      TileRow.Offset(0, -1);
      StartCoords.Offset(Map.TileWidth / 2, 0);
    end;
    StartCoords.Offset(0, -Map.TileHeight / 2);
  end;

  Shifted := InTopHalf xor InLeftHalf;

  Y := StartCoords.Y * 2;
  while Y - Map.TileHeight * 2 < Camera.Bottom * 2 do
  begin
    TileCol := TileRow;

    X := StartCoords.X;
    while X < Camera.Right do
    begin
      Cell := Layer.GetCell(TileCol.X, TileCol.Y);
      if Assigned(Cell) and not Cell.IsEmpty then
      begin
        Position := PointF(X, Y / 2);
        DstRect := TRectF.Create(Position, Cell.Tile.Width, Cell.Tile.Height);
        DrawCell(Canvas, Cell, DstRect, Layer.Opacity);
      end;

      Inc(TileCol.X);
      Dec(TileCol.Y);
      X := X + Map.TileWidth;
    end;

    if not Shifted then
    begin
      Inc(TileRow.X);
      StartCoords.Offset(Map.TileWidth / 2, 0);
      Shifted := True;
    end
    else
    begin
      Inc(TileRow.Y);
      StartCoords.Offset(-Map.TileWidth / 2, 0);
      Shifted := False;
    end;
    Y := Y + Map.TileHeight;
  end;
end;

function TTmxIsometricRenderer.PixelToScreenCoords(X, Y: Double): TPointF;
var
  TileX, TileY: Double;
  OriginX: Double;
begin
  OriginX := Map.Height * Map.TileWidth / 2;

  TileX := X / Map.TileHeight;
  TileY := Y / Map.TileHeight;

  Result.X := (TileX - TileY) * Map.TileWidth / 2 + OriginX;
  Result.Y := (TileX + TileY) * Map.TileHeight / 2;
end;

function TTmxIsometricRenderer.ScreenToPixelCoords(X, Y: Double): TPointF;
var
  TileX, TileY: Double;
  OriginX: Double;
begin
  OriginX := X - Map.Height * Map.TileWidth / 2;

  TileX := OriginX / Map.TileWidth;
  TileY := Y / Map.TileHeight;

  Result.X := (TileX + TileY) * Map.TileHeight;
  Result.Y := (TileY - TileX) * Map.TileHeight;
end;

function TTmxIsometricRenderer.ScreenToTileCoords(X, Y: Double): TPointF;
var
  TileX, TileY: Double;
  OriginX: Double;
begin
  OriginX := X - Map.Height * Map.TileWidth / 2;

  TileX := OriginX / Map.TileWidth;
  TileY := Y / Map.TileHeight;

  Result.X := TileX + TileY;
  Result.Y := TileY - TileX;
end;

function TTmxIsometricRenderer.TileToScreenCoords(X, Y: Double): TPointF;
var
  OriginX: Double;
begin
  OriginX := Map.Height * Map.TileWidth / 2;

  Result.X := (X - Y) * Map.TileWidth / 2 + OriginX;
  Result.Y := (X + Y) * Map.TileHeight / 2;
end;

end.
