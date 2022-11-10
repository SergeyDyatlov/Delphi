unit TmxIsometricRenderer;

interface

uses
  System.Types, System.UITypes, FMX.Types, TmxMap, TmxTileLayer, TmxObjectGroup,
  FMX.Graphics;

type
  TTmxIsometricRenderer = class
  private
    FMap: TTmxMap;
    FCamera: TRect;
    function ScreenToPixelCoords(X, Y: Single): TPointF;
    function PixelToScreenCoords(X, Y: Single): TPointF;
    function ScreenToTileCoords(X, Y: Single): TPointF; overload;
    function ScreenToTileCoords(Coords: TPointF): TPointF; overload;
    function TileToScreenCoords(X, Y: Single): TPointF; overload;
    function TileToScreenCoords(Coords: TPointF): TPointF; overload;

    procedure DrawGrid(Canvas: TCanvas);
    procedure DrawTileLayer(Canvas: TCanvas; Layer: TTmxTileLayer);
    procedure DrawObjectGroup(Canvas: TCanvas; Group: TTmxObjectGroup);
  public
    constructor Create(AMap: TTmxMap);
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas);
    property Camera: TRect read FCamera write FCamera;
  end;

implementation

uses
  TmxTileset, TmxLayer, System.Math, System.Math.Vectors;

{ TTmxIsometricRenderer }

constructor TTmxIsometricRenderer.Create(AMap: TTmxMap);
begin
  FMap := AMap;
end;

destructor TTmxIsometricRenderer.Destroy;
begin

  inherited;
end;

procedure TTmxIsometricRenderer.Draw(Canvas: TCanvas);
var
  Layer: TTmxLayer;
  TileLayer: TTmxTileLayer;
  ObjectGroup: TTmxObjectGroup;
begin
  DrawGrid(Canvas);
  for Layer in FMap.Layers do
  begin
    // if Layer.Visible then
    // begin
    case Layer.LayerType of
      ltTileLayer:
        begin
          TileLayer := Layer as TTmxTileLayer;
          DrawTileLayer(Canvas, TileLayer);
        end;
      ltObjectGroup:
        begin
          ObjectGroup := Layer as TTmxObjectGroup;
          DrawObjectGroup(Canvas, ObjectGroup);
        end;
    end;
    // end;
  end;
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

  ScreenRect.Inflate(FMap.TileWidth div 2, FMap.TileHeight div 2);

  StartX := Trunc(ScreenToTileCoords(ScreenRect.Left, ScreenRect.Top).X);
  StartY := Trunc(ScreenToTileCoords(ScreenRect.Right, ScreenRect.Top).Y);
  EndX := Trunc(ScreenToTileCoords(ScreenRect.Right, ScreenRect.Bottom).X);
  EndY := Trunc(ScreenToTileCoords(ScreenRect.Left, ScreenRect.Bottom).Y);

  StartX := Max(0, StartX);
  StartY := Max(0, StartY);
  EndX := Min(FMap.Width, EndX);
  EndY := Min(FMap.Height, EndY);

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
      Canvas.FillText(Bounds, TmxObject.Name, False, 100,
        [TFillTextFlag.RightToLeft], TTextAlign.Center, TTextAlign.Center);
      Canvas.FillPolygon(Points, 20);
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
  StartCoords.Offset(-FMap.TileWidth / 2, FMap.TileHeight);

  InTopHalf := StartCoords.Y - FCamera.Top > FMap.TileHeight / 2;
  InLeftHalf := FCamera.Left - StartCoords.X < FMap.TileWidth / 2;

  if InTopHalf then
  begin
    if InLeftHalf then
    begin
      TileRow.Offset(-1, 0);
      StartCoords.Offset(-FMap.TileWidth / 2, 0);
    end
    else
    begin
      TileRow.Offset(0, -1);
      StartCoords.Offset(FMap.TileWidth / 2, 0);
    end;
    StartCoords.Offset(0, -FMap.TileHeight / 2);
  end;

  Shifted := InTopHalf xor InLeftHalf;

  Y := StartCoords.Y * 2;
  while Y - FMap.TileHeight * 2 < FCamera.Bottom * 2 do
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
      X := X + FMap.TileWidth;
    end;

    if not Shifted then
    begin
      Inc(TileRow.X);
      StartCoords.Offset(FMap.TileWidth / 2, 0);
      Shifted := True;
    end
    else
    begin
      Inc(TileRow.Y);
      StartCoords.Offset(-FMap.TileWidth / 2, 0);
      Shifted := False;
    end;
    Y := Y + FMap.TileHeight;
  end;
end;

function TTmxIsometricRenderer.PixelToScreenCoords(X, Y: Single): TPointF;
var
  TileX, TileY: Single;
  OriginX: Single;
begin
  OriginX := FMap.Height * FMap.TileWidth / 2;

  TileX := X / FMap.TileHeight;
  TileY := Y / FMap.TileHeight;

  Result.X := (TileX - TileY) * FMap.TileWidth / 2 + OriginX;
  Result.Y := (TileX + TileY) * FMap.TileHeight / 2;
end;

function TTmxIsometricRenderer.ScreenToPixelCoords(X, Y: Single): TPointF;
var
  TileX, TileY: Single;
  OriginX: Single;
begin
  OriginX := X - FMap.Height * FMap.TileWidth / 2;

  TileX := OriginX / FMap.TileWidth;
  TileY := Y / FMap.TileHeight;

  Result.X := (TileX + TileY) * FMap.TileHeight;
  Result.Y := (TileY - TileX) * FMap.TileHeight;
end;

function TTmxIsometricRenderer.ScreenToTileCoords(Coords: TPointF): TPointF;
begin
  Result := ScreenToTileCoords(Coords.X, Coords.Y);
end;

function TTmxIsometricRenderer.ScreenToTileCoords(X, Y: Single): TPointF;
var
  TileX, TileY: Single;
  OriginX: Single;
begin
  OriginX := X - FMap.Height * FMap.TileWidth / 2;

  TileX := OriginX / FMap.TileWidth;
  TileY := Y / FMap.TileHeight;

  Result.X := TileX + TileY;
  Result.Y := TileY - TileX;
end;

function TTmxIsometricRenderer.TileToScreenCoords(X, Y: Single): TPointF;
var
  OriginX: Single;
begin
  OriginX := FMap.Height * FMap.TileWidth / 2;

  Result.X := (X - Y) * FMap.TileWidth / 2 + OriginX;
  Result.Y := (X + Y) * FMap.TileHeight / 2;
end;

function TTmxIsometricRenderer.TileToScreenCoords(Coords: TPointF): TPointF;
begin
  Result := TileToScreenCoords(Coords.X, Coords.Y);
end;

end.
