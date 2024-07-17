program BFS;

uses
  Vcl.Forms,
  MainFrm in 'MainFrm.pas' {MainForm},
  CanvasUtils in 'CanvasUtils.pas',
  SquareGrid in 'SquareGrid.pas',
  BreadthFirstSearch in 'BreadthFirstSearch.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
