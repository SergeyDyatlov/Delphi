unit CanvasUtils;

interface

uses
  Winapi.Windows, System.Classes, Vcl.Graphics;

procedure DrawLine(Canvas: TCanvas; StartPoint, EndPoint: TPoint);

implementation

procedure DrawLine(Canvas: TCanvas; StartPoint, EndPoint: TPoint);
begin
  Canvas.MoveTo(StartPoint.X, StartPoint.Y);
  Canvas.LineTo(EndPoint.X, EndPoint.Y);
end;

end.
