program Lab_1;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {MainForm},
  MainAbout in 'MainAbout.pas' {AboutActivity};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutActivity, AboutActivity);
  Application.Run;
end.
