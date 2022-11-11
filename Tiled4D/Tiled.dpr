program Tiled;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainFrm in 'MainFrm.pas' {MainForm},
  TmxImage in 'Source\TmxImage.pas',
  TmxIsometricRenderer in 'Source\TmxIsometricRenderer.pas',
  TmxLayer in 'Source\TmxLayer.pas',
  TmxMap in 'Source\TmxMap.pas',
  TmxObjectGroup in 'Source\TmxObjectGroup.pas',
  TmxOrthogonalRenderer in 'Source\TmxOrthogonalRenderer.pas',
  TmxTileLayer in 'Source\TmxTileLayer.pas',
  TmxTileset in 'Source\TmxTileset.pas',
  Keyboard in 'Keyboard.pas',
  TmxMapRenderer in 'Source\TmxMapRenderer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
