unit TmxOrthogonalRenderer;

interface

uses
  System.Types, System.UITypes, FMX.Types, TmxMap, TmxTileLayer, TmxObjectGroup,
  TmxTileset, TmxLayer, TmxMapRenderer, FMX.Graphics;

type
  TTmxOrthogonalRenderer = class(TTmxMapRenderer)
  protected
    function ScreenToTileCoords(X, Y: Double): TPointF; override;
    function TileToScreenCoords(X, Y: Double): TPointF; override;

    procedure DrawGrid(Canvas: TCanvas); override;
    procedure DrawObjectGroup(Canvas: TCanvas; Group: TTmxObjectGroup);
      override;
    procedure DrawTileLayer(Canvas: TCanvas; Layer: TTmxTileLayer); override;
  public
    constructor Create(AMap: TTmxMap); override;
    destructor Destroy; override;
  end;

implementation

uses
  System.Math, System.Math.Vectors;

{ TTmxOrthogonalRenderer }

constructor TTmxOrthogonalRenderer.Create(AMap: TTmxMap);
begin
  inherited;

end;

destructor TTmxOrthogonalRenderer.Destroy;
begin

  inherited;
end;

procedure TTmxOrthogonalRenderer.DrawGrid(Canvas: TCanvas);
begin

end;

procedure TTmxOrthogonalRenderer.DrawObjectGroup(Canvas: TCanvas;
  Group: TTmxObjectGroup);
var
  TmxObject: TTmxObject;
  Position: TPointF;
  DstRect: TRectF;
begin
  for TmxObject in Group.Objects do
  begin
    if not TmxObject.Cell.IsEmpty then
    begin
      Position := PointF(TmxObject.X, TmxObject.Y);
      DstRect := TRectF.Create(Position, TmxObject.Width, TmxObject.Height);
      DrawCell(Canvas, TmxObject.Cell, DstRect, Group.Opacity);
    end;
  end;
end;

procedure TTmxOrthogonalRenderer.DrawTileLayer(Canvas: TCanvas;
  Layer: TTmxTileLayer);
var
  X, Y: Integer;
  Cell: TTmxCell;
  Position: TPointF;
  DstRect: TRectF;
begin
  Y := Floor(Camera.Top / Map.TileHeight);
  while Y < Ceil(Camera.Bottom / Map.TileHeight) do
  begin
    X := Floor(Camera.Left / Map.TileWidth);
    while X < Ceil(Camera.Right / Map.TileWidth) do
    begin
      Cell := Layer.GetCell(X, Y);
      if not Cell.IsEmpty then
      begin
        Position := PointF(X * Map.TileWidth, Y * Map.TileHeight);
        DstRect := TRectF.Create(Position, Cell.Tile.Width, Cell.Tile.Height);
        DrawCell(Canvas, Cell, DstRect, Layer.Opacity);
      end;
      Inc(X);
    end;
    Inc(Y);
  end;
end;

function TTmxOrthogonalRenderer.ScreenToTileCoords(X, Y: Double): TPointF;
begin
  Result.X := X / Map.TileWidth;
  Result.Y := Y / Map.TileHeight;
end;

function TTmxOrthogonalRenderer.TileToScreenCoords(X, Y: Double): TPointF;
begin
  Result.X := X * Map.TileWidth;
  Result.Y := Y * Map.TileHeight;
end;

end.
