unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMXTee.Engine, FMXTee.Procs, FMXTee.Chart, FMX.TabControl, FMX.Edit,
  {$IFDEF ANDROID}
  	AndroidApi.Helpers, FMX.Platform.Android, Androidapi.JNI.Widget, FMX.Helpers.Android,
 	{$ENDIF}
  FMX.Objects, FMX.Controls.Presentation, FMXTee.Series, FMX.ListBox, Math,
  FMX.ComboEdit, System.Notification;

type
  TMainForm = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    Edit2: TEdit;
    Label4: TLabel;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Chart1: TChart;
    TrackBar1: TTrackBar;
    Label5: TLabel;
    Series1: TLineSeries;
    Button3: TButton;
    Button1: TButton;
    Button4: TButton;
    ProgressBar1: TProgressBar;
    NotificationCenter1: TNotificationCenter;
    ComboEdit1: TComboEdit;
    procedure TrackBar1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  type MyOpt=array[1..3] of Double;


var
  MainForm: TMainForm;
  step:real;
  xn,xk,y:real;
  Options:MyOpt;

implementation

{$R *.fmx}

// Наша функция

function myf(x:real):real;
begin
  if (x<=0) and (x>=-10) then myf:=Power(x,3)
  else if (x>0) and (x<=10) then myf:=Sqr(exp(x))*x;
end;


procedure TMainForm.Button1Click(Sender: TObject);
var f:textfile; i:integer;
begin
// Загрузка изображения из карты памяти
{$IFDEF ANDROID}
  Image1.Bitmap.LoadFromFile('/mnt/sdcard/'+ComboEdit1.Text);
{$ENDIF}
{$IFDEF MSWINDOWS}
  Image1.Bitmap.LoadFromFile('C:\'+ComboEdit1.Text);
{$ENDIF}
// Сохранение настроек начальных значений в текстовый файл
  Options[1]:=xn;
  Options[2]:=xk;
  Options[3]:=step;
{$IFDEF ANDROID}
  assignfile(f,'/mnt/sdcard/myopt_lab4.txt');
{$ENDIF}
{$IFDEF MSWINDOWS}
  assignfile(f,'c:\myopt_lab4.txt');
{$ENDIF}
  rewrite(f);

    for i := 1 to 3 do
    begin
      writeln(f,Options[i]);
    end;

  closefile(f);
{$IFDEF ANDROID}
   		TJToast.JavaClass.makeText(TAndroidHelper.Context, StrToJCharSequence('Настройки сохранены в файл!'), TJToast.JavaClass.LENGTH_LONG).show;
{$ENDIF}
{$IFDEF MSWINDOWS}
  ShowMessage('Настройки сохранены в файл!');
{$ENDIF}
end;

// Поиск файлов изображений на карте памяти

procedure TMainForm.Button3Click(Sender: TObject);
var f:tsearchrec;
begin
{$IFDEF ANDROID}
 if findfirst('/mnt/sdcard/*.jpg',faanyfile,f)<>0 then exit;
{$ENDIF}
{$IFDEF MSWINDOWS}
 if findfirst('C:\*.jpg',faanyfile,f)<>0 then exit;
{$ENDIF}

 ComboEdit1.Items.Add(f.name);

while findnext(f)=0 do
begin
 ComboEdit1.Items.Add(f.Name);
end;

 findclose(f);

end;

procedure TMainForm.Button4Click(Sender: TObject);
var Notification:TNotification; x:real;
begin

  Chart1.Series[0].Clear;

// Ввод данных                                    //
try
  xn:=StrToFloat(Edit1.Text);
except on EConvertError do
  begin
    ShowMessage('Неверное начальное значение!');
    Exit;
  end;
end;

try
  xk:=StrToFloat(Edit2.Text);
except on EConvertError do
  begin
    ShowMessage('Неверное конечное значение!');
    Exit;
  end;
end;

//************************************************//

x:=xn;

ProgressBar1.Min:=xn;
Progressbar1.Max:=xk;

while(xk>x) do
begin

  Application.ProcessMessages;

  y:=myf(x);
  x:=x+step;

  Chart1.Series[0].AddXY(x,y);
  ProgressBar1.Value:=x;

end;

// Вывод уведомления

if NotificationCenter1.Supported then
begin

  Notification:=NotificationCenter1.CreateNotification;

  try

    Notification.Name:='Lab4';
    Notification.AlertBody:='График построен!';
    Notification.FireDate:=Now+EncodeTime(0,0,5,0);
    NotificationCenter1.ScheduleNotification(Notification);

  finally

    Notification.DisposeOf;

  end;

end;


end;

procedure TMainForm.FormShow(Sender: TObject);
var f:textfile; i:integer;
begin

{$IFDEF ANDROID}
if FileExists('/mnt/sdcard/myopt_lab4.txt') then
{$ENDIF}
{$IFDEF MSWINDOWS}
if FileExists('C:\myopt_lab4.txt') then
{$ENDIF}
begin

{$IFDEF ANDROID}
  assignfile(f,'/mnt/sdcard/myopt_lab4.txt');
{$ENDIF}
{$IFDEF MSWINDOWS}
  assignfile(f,'C:\myopt_lab4.txt');
{$ENDIF}

  reset(f);

    for i := 1 to 3 do
    begin
      readln(f,Options[i]);
    end;

    Edit1.Text:=Options[1].ToString();
    Edit2.Text:=Options[2].ToString();
    TrackBar1.Value:=Options[3];

  closefile(f);
end;

end;

procedure TMainForm.TrackBar1Change(Sender: TObject);
begin
  Label5.Text:='Значение шага '+FloatToStr(Trackbar1.Value);
  step:=Trackbar1.Value;
end;

end.

