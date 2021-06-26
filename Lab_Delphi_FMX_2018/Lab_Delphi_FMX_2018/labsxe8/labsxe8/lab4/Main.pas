unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Media, FMX.Controls.Presentation,

 // Androidapi.JNIBridge,
  Androidapi.Helpers, Androidapi.JNI.Os,
//  Androidapi.JNI.App,
//  AndroidApi.JNI.Media,
  FMX.Platform.Android,
  Androidapi.JNI.GraphicsContentViewText,
//  Androidapi.JNI.JavaTypes,

  FMX.ListBox, FMX.Layouts, System.Sensors,
  FMX.Objects, FMX.TabControl, System.Sensors.Components;

type
  TMyForm = class(TForm)
    ToolBar1: TToolBar;
    CameraComponent1: TCameraComponent;
    Switch1: TSwitch;
    Label1: TLabel;
    TrackBar1: TTrackBar;
    Timer1: TTimer;
    Button1: TButton;
    ListBox1: TListBox;
    ListBoxGroupHeader1: TListBoxGroupHeader;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxGroupHeader2: TListBoxGroupHeader;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    TrackBar2: TTrackBar;
    ListBoxGroupHeader3: TListBoxGroupHeader;
    ListBoxItem8: TListBoxItem;
    MotionSensor1: TMotionSensor;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    PaintBox1: TPaintBox;
    Circle1: TCircle;
    Timer2: TTimer;
    Label2: TLabel;
    Button2: TButton;
    Label3: TLabel;
    StyleBook1: TStyleBook;
    Switch2: TSwitch;
    procedure Switch1Switch(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Switch2Switch(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    procedure SetFlashlightState(Active : Boolean);
  public
    { Public declarations }
  end;

var
  MyForm: TMyForm;
  flag:boolean;

implementation

{$R *.fmx}



procedure TMyForm.Button1Click(Sender: TObject);
var i:integer; Vibrator: JVibrator;
begin

  Vibrator := TJVibrator.Wrap(SharedActivity.getSystemService(TJContext.JavaClass.VIBRATOR_SERVICE));

  if Vibrator.hasVibrator() then

    Vibrator.vibrate(Round(TrackBar2.Value));

end;
// ����� �� ����������
procedure TMyForm.Button2Click(Sender: TObject);
begin
  MainActivity.Finish;
end;


procedure TMyForm.FormShow(Sender: TObject);
begin
  flag:=true;
  CameraComponent1.Active:=false;
end;
// ��������-��������� ���������
procedure TMyForm.SetFlashlightState(Active : Boolean);
begin
  if Active then
  begin
    CameraComponent1.TorchMode := TTorchMode.tmModeOn;
  end else
    CameraComponent1.TorchMode := TTorchMode.tmModeOff;
end;

// �������� ��������� ������� (������ � ��������� ������)
procedure TMyForm.Switch1Switch(Sender: TObject);
begin

if Switch1.IsChecked then

begin
      CameraComponent1.Active:=true;
      Timer1.Enabled:=true;
end

else
begin
      Timer1.Enabled:=false;
      CameraComponent1.Active:=false;
end;

end;
// �������� ��������� ������������
procedure TMyForm.Switch2Switch(Sender: TObject);
begin
  if Switch2.IsChecked then
  begin
    MotionSensor1.Active:=not MotionSensor1.Active;
    Timer2.Enabled:=not Timer2.Enabled;
  end;

end;



// ������� ����������
procedure TMyForm.Timer1Timer(Sender: TObject);
begin

if CameraComponent1.HasFlash then
begin

  if flag then
    begin
        SetFlashlightState(True);
        flag:=false;
    end
  else
    begin
        SetFlashlightState(False);
        flag:=true;
    end;

end;

end;

procedure TMyForm.Timer2Timer(Sender: TObject);
begin
// �������� ������ ��������
MotionSensor1.Sensor.Start;

// ������� ����� �������� ���������� �������
Circle1.Position.X:=MotionSensor1.Sensor.AccelerationX*100+PaintBox1.Width/2;
Circle1.Position.Y:=MotionSensor1.Sensor.AccelerationY*100+PaintBox1.Height/2;

// �����������, ���� ���� ������ �� ���� �� ����� �����
if Circle1.Position.X>=PaintBox1.Width then Circle1.Position.X:=PaintBox1.Width/2;
if Circle1.Position.Y>=PaintBox1.Height then Circle1.Position.Y:=PaintBox1.Height/2;

if Circle1.Position.X<=0 then Circle1.Position.X:=PaintBox1.Width/2;
if Circle1.Position.Y<=0 then Circle1.Position.Y:=PaintBox1.Height/2;

// ���������� ���������� �������
Label2.Text:='X='+FloattoStrf(MotionSensor1.Sensor.AccelerationX, ffGeneral,2,5);
Label3.Text:='Y='+FloattoStrf(MotionSensor1.Sensor.AccelerationY, ffGeneral,2,5);

end;

// ��������� ������� �������
procedure TMyForm.TrackBar1Change(Sender: TObject);
begin
  Timer1.Interval:=Round(Trackbar1.Value);
end;

end.
