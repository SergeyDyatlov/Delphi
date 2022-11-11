unit TmxIsometricRenderer;

interface

uses
  System.Types, System.UITypes, FMX.Types, TmxMap, TmxTileLayer, TmxObjectGroup,
  TmxTileset, TmxLayer, TmxMapRenderer, FMX.Graphics;

type
  TTmxIsometricRenderer = class(TTmxMapRenderer)
  private
    FCamera: TRect;
  protected
    function ScreenToPixelCoords(X, Y: Single): TPointF;
    function PixelToScreenCoords(X, Y: Single): TPointF;
    function ScreenToTileCoords(X, Y: Single): TPointF; override;
    function TileToScreenCoords(X, Y: Single): TPointF; override;

    procedure DrawGrid(Canvas: TCanvas); override;
    procedure DrawObjectGroup(Canvas: TCanvas; Group: TTmxObjectGroup); override;
    procedure DrawTileLayer(Canvas: TCanvas; Layer: TTmxTileLayer); override;
  public
    constructor Create(AMap: TTmxMap); override;
    destructor Destroy; override;
    property Camera: TRect read FCamera write FCamera;
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
  StartCoords: TPoint;
  Brush: TStrokeBrush;
  CanvasState: TCanvasSaveState;
begin
  ScreenRect := FCamera;

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
    Brush := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColors.Green);

    for Y := StartY to EndY do
    begin
      StartPoint := TileToScreenCoords(StartX, Y);
      StartPoint.Offset(-FCamera.Left, -FCamera.Top);
      EndPoint := TileToScreenCoords(EndX, Y);
      EndPoint.Offset(-FCamera.Left, -FCamera.Top);
      Canvas.DrawLine(StartPoint, EndPoint, 20, Brush);
    end;

    for X := StartX to EndX do
    begin
      StartPoint := TileToScreenCoords(X, StartY);
      StartPoint.Offset(-FCamera.Left, -FCamera.Top);
      EndPoint := TileToScreenCoords(X, EndY);
      EndPoint.Offset(-FCamera.Left, -FCamera.Top);
      Canvas.DrawLine(StartPoint, EndPoint, 20, Brush);
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
  TextWidth: Single;
begin
  for TmxObject in Group.Objects do
  begin
    Position := TPointF.Create(TmxObject.X, TmxObject.Y);
    Bounds := TRectF.Create(Position, TmxObject.Width, TmxObject.Height);

    SetLength(Points, 4);
    Points[0] := PixelToScreenCoords(Bounds.Left, Bounds.Top);
    Points[0].Offset(-FCamera.Left, -FCamera.Top);
    Points[1] := PixelToScreenCoords(Bounds.Right, Bounds.Top);
    Points[1].Offset(-FCamera.Left, -FCamera.Top);
    Points[2] := PixelToScreenCoords(Bounds.Right, Bounds.Bottom);
    Points[2].Offset(-FCamera.Left, -FCamera.Top);
    Points[3] := PixelToScreenCoords(Bounds.Left, Bounds.Bottom);
    Points[3].Offset(-FCamera.Left, -FCamera.Top);

    Canvas.BeginScene;
    try
      Canvas.FillPolygon(Points, 20);

      TextWidth := Canvas.TextWidth(TmxObject.Name);
      Position := PixelToScreenCoords(TmxObject.X, TmxObject.Y);
      Position.Offset(-TextWidth / 2, -TmxObject.Height);
      Bounds := TRectF.Create(Position, TextWidth, TmxObject.Height);
      Bounds.Offset(-FCamera.Left, -FCamera.Top);

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
  Y, X: Single;
  Cell: TTmxCell;
  SrcRect, DstRect: TRectF;
begin
  TileCoords := ScreenToTileCoords(FCamera.Left, FCamera.Top);
  TileRow := Point(Floor(TileCoords.X), Floor(TileCoords.Y));
  StartCoords := TileToScreenCoords(TileRow.X, TileRow.Y);
  StartCoords.Offset(-Map.TileWidth / 2, Map.TileHeight);

  InTopHalf := StartCoords.Y - FCamera.Top > Map.TileHeight / 2;
  InLeftHalf := FCamera.Left - StartCoords.X < Map.TileWidth / 2;

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
  while Y - Map.TileHeight * 2 < FCamera.Bottom * 2 do
  begin
    TileCol := TileRow;

    X := StartCoords.X;
    while X < FCamera.Right do
    begin
      Cell := Layer.GetCell(TileCol.X, TileCol.Y);
      if Assigned(Cell) then
      begin
        SrcRect := Cell.Tile.Image.Bounds;
        DstRect := TRectF.Create(PointF(X, Y / 2));
        DstRect.Width := Cell.Tile.Width;
        DstRect.Height := Cell.Tile.Height;

        DstRect.Offset(-FCamera.Left, -FCamera.Top);
        DstRect.Offset(0, -Cell.Tile.Height);
        Canvas.DrawBitmap(Cell.Tile.Image, SrcRect, DstRect, 20);
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

function TTmxIsometricRenderer.PixelToScreenCoords(X, Y: Single): TPointF;
var
  TileX, TileY: Single;
  OriginX: Single;
begin
  OriginX := Map.Height * Map.TileWidth / 2;

  TileX := X / Map.TileHeight;
  TileY := Y / Map.TileHeight;

  Result.X := (TileX - TileY) * Map.TileWidth / 2 + OriginX;
  Result.Y := (TileX + TileY) * Map.TileHeight / 2;
end;

function TTmxIsometricRenderer.ScreenToPixelCoords(X, Y: Single): TPointF;
var
  TileX, TileY: Single;
  OriginX: Single;
begin
  OriginX := X - Map.Height * Map.TileWidth / 2;

  TileX := OriginX / Map.TileWidth;
  TileY := Y / Map.TileHeight;

  Result.X := (TileX + TileY) * Map.TileHeight;
  Result.Y := (TileY - TileX) * Map.TileHeight;
end;

function TTmxIsometricRenderer.ScreenToTileCoords(X, Y: Single): TPointF;
var
  TileX, TileY: Single;
  OriginX: Single;
begin
  OriginX := X - Map.Height * Map.TileWidth / 2;

  TileX := OriginX / Map.TileWidth;
  TileY := Y / Map.TileHeight;

  Result.X := TileX + TileY;
  Result.Y := TileY - TileX;
end;

function TTmxIsometricRenderer.TileToScreenCoords(X, Y: Single): TPointF;
var
  OriginX: Single;
begin
  OriginX := Map.Height * Map.TileWidth / 2;

  Result.X := (X - Y) * Map.TileWidth / 2 + OriginX;
  Result.Y := (X + Y) * Map.TileHeight / 2;
end;

end.
