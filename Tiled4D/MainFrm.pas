unit MainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, TmxMap, TmxIsometricRenderer, Keyboard;

type
  TMainForm = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FMap: TTmxMap;
    FRenderer: TTmxIsometricRenderer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  Winapi.Windows, System.Diagnostics;

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FMap := TTmxMap.Create;
  FMap.LoadFromFile('Maps\Cave\abandoned_mine.tmx');

  FRenderer := TTmxIsometricRenderer.Create(FMap);
  FRenderer.Camera := TRect.Create(Point(0, 0), 960, 540);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FRenderer.Free;
  FMap.Free;
end;

procedure TMainForm.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
//  Canvas.Clear(TAlphaColors.Black);
  FRenderer.Draw(Canvas);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  FRenderer.Camera.Width := Width;
  FRenderer.Camera.Height := Height;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  if IsKeyDown(VK_LEFT) then
    FRenderer.Camera.Offset(-6, 0);
  if IsKeyDown(VK_UP) then
    FRenderer.Camera.Offset(0, -6);
  if IsKeyDown(VK_RIGHT) then
    FRenderer.Camera.Offset(6, 0);
  if IsKeyDown(VK_DOWN) then
    FRenderer.Camera.Offset(0, 6);

  Invalidate;
end;

initialization

ReportMemoryLeaksOnShutdown := True;

end.
