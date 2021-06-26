unit MainAbout;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TAboutActivity = class(TForm)
    ToolBar1: TToolBar;
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutActivity: TAboutActivity;

implementation

uses Main;

{$R *.fmx}

procedure TAboutActivity.Button1Click(Sender: TObject);
begin
  MainForm.Show;
  AboutActivity.Visible:=false;
end;

end.
