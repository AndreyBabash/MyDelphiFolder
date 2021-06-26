unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Media, FMX.Controls.Presentation,
   System.Permissions,
  {$IFDEF ANDROID}
  Androidapi.Helpers, Androidapi.JNI.Os,
  FMX.Platform.Android,
  Androidapi.JNI.GraphicsContentViewText,
  {$ENDIF}
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
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SetFlashlightState(Active : Boolean);
  public
    { Public declarations }
    FPermissionCamera: string;
    FPermissionCallPhone: string;
  end;

var
  MyForm: TMyForm;
  flag:boolean;

implementation

{$R *.fmx}


procedure TMyForm.Button1Click(Sender: TObject);
var i:integer; {$IFDEF ANDROID} Vibrator: JVibrator;  {$ENDIF}
begin
{$IFDEF ANDROID}
  Vibrator := TJVibrator.Wrap(SharedActivity.getSystemService(TJContext.JavaClass.VIBRATOR_SERVICE));

  if Vibrator.hasVibrator() then

    Vibrator.vibrate(Round(TrackBar2.Value));
{$ENDIF}
end;
// выход из приложения
procedure TMyForm.Button2Click(Sender: TObject);
begin
  {$IFDEF ANDROID}
    MainActivity.Finish;
  {$ENDIF}
end;


procedure TMyForm.FormCreate(Sender: TObject);
begin
  Circle1.Position.X:=0;
  Circle1.Position.Y:=0;
end;

procedure TMyForm.FormShow(Sender: TObject);
begin
{$IFDEF ANDROID}
    FPermissionCamera:=JStringToString(TJManifest_permission.JavaClass.CAMERA);
    FPermissionCallPhone:=JStringToString(TJManifest_permission.JavaClass.CALL_PHONE);
    PermissionsService.RequestPermissions([FPermissionCamera,FPermissionCallPhone],
  procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
  var i:integer;
  begin
       for i:=0 to Length(AGrantResults) do
       begin
          if AGrantResults[i] = TPermissionStatus.Granted then
          begin
            case i of
            0:
              begin
                flag:=true;
                CameraComponent1.Active:=false;
                ShowMessage('Использование Камеры разрешено');
              end;
            1:
              ShowMessage('Звонки разрешены');
            end;
          end
          Else
          begin
            case i of
            0:
                ShowMessage('Использование Камеры запрещено пользователем');
            1:
                ShowMessage('Звонки запрещены пользователем');
            end;
          end;
       end;
  end)
{$ENDIF}
end;
// включить-выключить подсветку
procedure TMyForm.SetFlashlightState(Active : Boolean);
begin
  if Active then
  begin
    CameraComponent1.TorchMode := TTorchMode.tmModeOn;
  end else
    CameraComponent1.TorchMode := TTorchMode.tmModeOff;
end;

// включать выключать вспышку (таймер и компонент камеры)
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
// включить выключить акселерометр
procedure TMyForm.Switch2Switch(Sender: TObject);
begin
  if Switch2.IsChecked then
  begin
  {$IFDEF ANDROID}
    MotionSensor1.Active:=not MotionSensor1.Active;
    {$ENDIF}
    Timer2.Enabled:=not Timer2.Enabled;
  end;

end;



// мигание подсветкой
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
Circle1.Position.Y:=0;
{$IFDEF ANDROID}
// Включить датчик движения
MotionSensor1.Sensor.Start;
{$ENDIF}
// Ограничения, чтоб круг далеко не ушел за рамки формы
if Circle1.Position.X>=PaintBox1.Width then Circle1.Position.X:=0
else
begin
  Circle1.Position.X:=Circle1.Position.X+5;
end;

{$IFDEF ANDROID}
// Отображать координаты датчика
Label2.Text:='X='+FloattoStrf(MotionSensor1.Sensor.AccelerationX, ffGeneral,2,5);
Label3.Text:='Y='+FloattoStrf(MotionSensor1.Sensor.AccelerationY, ffGeneral,2,5);
{$ENDIF}
end;

// настройка периода таймера
procedure TMyForm.TrackBar1Change(Sender: TObject);
begin
  Timer1.Interval:=Round(Trackbar1.Value);
end;

end.
