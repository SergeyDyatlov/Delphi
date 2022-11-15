unit TmxMapRenderer;

interface

uses
  System.Types, System.UITypes, FMX.Types, TmxMap, TmxTileLayer, TmxObjectGroup,
  TmxTileset, TmxLayer, FMX.Graphics;

type
  TTmxMapRenderer = class
  private
    FMap: TTmxMap;
    FCamera: TRect;
  protected
    function ScreenToTileCoords(X, Y: Double): TPointF; overload; virtual;
    function ScreenToTileCoords(Coords: TPointF): TPointF; overload; virtual;
    function TileToScreenCoords(X, Y: Double): TPointF; overload; virtual;
    function TileToScreenCoords(Coords: TPointF): TPointF; overload; virtual;

    procedure DrawGrid(Canvas: TCanvas); virtual;
    procedure DrawObjectGroup(Canvas: TCanvas; Group: TTmxObjectGroup); virtual;
    procedure DrawTileLayer(Canvas: TCanvas; Layer: TTmxTileLayer); virtual;
    procedure DrawCell(Canvas: TCanvas; Cell: TTmxCell; ScreenRect: TRectF);
  public
    constructor Create(AMap: TTmxMap); virtual;
    procedure Draw(Canvas: TCanvas); virtual;
    property Map: TTmxMap read FMap;
    property Camera: TRect read FCamera write FCamera;
  end;

implementation

{ TTmxMapRenderer }

constructor TTmxMapRenderer.Create(AMap: TTmxMap);
begin
  FMap := AMap;
end;

function TTmxMapRenderer.ScreenToTileCoords(X, Y: Double): TPointF;
begin

end;

procedure TTmxMapRenderer.Draw(Canvas: TCanvas);
var
  Layer: TTmxLayer;
  TileLayer: TTmxTileLayer;
  ObjectGroup: TTmxObjectGroup;
begin
  DrawGrid(Canvas);
  for Layer in Map.Layers do
  begin
    if not Layer.Visible then
      Continue;

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
  end;
end;

procedure TTmxMapRenderer.DrawCell(Canvas: TCanvas; Cell: TTmxCell;
  ScreenRect: TRectF);
var
  SrcRect, DstRect: TRectF;
  Bitmap: TBitmap;
begin
  SrcRect := Cell.Tile.Bitmap.Bounds;
  DstRect := ScreenRect;
  DstRect.Offset(-Camera.Left, -Camera.Top);
  DstRect.Offset(0, -DstRect.Height);

  Bitmap := TBitmap.Create;
  try
    Bitmap.Assign(Cell.Tile.Bitmap);
    if Cell.FlippedHorizontaly then
      Bitmap.FlipHorizontal;
    if Cell.FlippedVerticaly then
      Bitmap.FlipVertical;

    Canvas.DrawBitmap(Bitmap, SrcRect, DstRect, 1);
  finally
    Bitmap.Free;
  end;
end;

procedure TTmxMapRenderer.DrawGrid(Canvas: TCanvas);
begin

end;

procedure TTmxMapRenderer.DrawObjectGroup(Canvas: TCanvas;
  Group: TTmxObjectGroup);
begin

end;

procedure TTmxMapRenderer.DrawTileLayer(Canvas: TCanvas; Layer: TTmxTileLayer);
begin

end;

function TTmxMapRenderer.ScreenToTileCoords(Coords: TPointF): TPointF;
begin
  Result := ScreenToTileCoords(Coords.X, Coords.Y);
end;

function TTmxMapRenderer.TileToScreenCoords(X, Y: Double): TPointF;
begin

end;

function TTmxMapRenderer.TileToScreenCoords(Coords: TPointF): TPointF;
begin
  Result := TileToScreenCoords(Coords.X, Coords.Y);
end;

end.
