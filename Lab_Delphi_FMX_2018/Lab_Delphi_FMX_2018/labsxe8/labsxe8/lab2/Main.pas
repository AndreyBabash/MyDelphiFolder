unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Colors, FMX.Gestures, FMX.Objects, FMX.Platform.Android;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    ColorPicker1: TColorPicker;
    Label2: TLabel;
    GestureManager1: TGestureManager;
    Rectangle1: TRectangle;
    RadioButton1: TRadioButton;
    Label3: TLabel;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Button2: TButton;
    PaintBox1: TPaintBox;
    ToolBar2: TToolBar;
    Label4: TLabel;
    Label5: TLabel;
    Switch1: TSwitch;
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
    procedure Switch1Switch(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  thickness:integer;
  ltsel:integer;
  size:integer;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.GGlass.fmx ANDROID}
{$R *.Macintosh.fmx MACOS}
{$R *.Windows.fmx MSWINDOWS}

// Подтверждение выхода из приложения

procedure ExitConfirm;
begin

// Вывод диалогового окна

    MessageDlg('Хотите выйти!', System.UITypes.TMsgDlgType.mtInformation,
    [
      System.UITypes.TMsgDlgBtn.mbYes,
      System.UITypes.TMsgDlgBtn.mbNo
    ], 0,

      procedure(const AResult: TModalResult)
      begin
        case AResult
          of

          mrYES:

          begin

            MainActivity.finish;    // Выход из приложения

          end;

          mrNo:

            begin

            end;

        end;
      end
    )

end;

// Изменение толщины линии

procedure ThicknessInc(var l:Tlabel);
begin
 thickness:=thickness+1;
 if thickness>10 then thickness:=10;
 l.Text:='Толщина линии: '+inttostr(thickness);
end;


procedure ThicknessDec(var l:Tlabel);
begin
  thickness:=thickness-1;
  if thickness<1 then thickness:=1;
  l.Text:='Толщина линии: '+inttostr(thickness)
end;


// Выбор типа линии
procedure TForm1.Button2Click(Sender: TObject);
begin
  if radiobutton1.IsChecked then ltsel:=1;
  if radiobutton2.IsChecked then ltsel:=2;
  if radiobutton3.IsChecked then ltsel:=3;

  Rectangle1.Visible:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  thickness:=1;
  size:=40;
  ltsel:=1;
  Label2.Text:='Толщина линии: '+inttostr(thickness);
end;

procedure TForm1.FormGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin

// Определяем доступный жест и обрабатываем его

case EventInfo.GestureID of
// Движение влево (увеличиваем толщину линии выводимой графики)
  sgiLeft:

    begin
      ThicknessInc(Label2);
      PaintBox1.Repaint;
    end;
// Движение вправо (уменьшаем толщину линии выводимой графики)
  sgiRight:

    begin
      ThicknessDec(Label2);
      PaintBox1.Repaint;
    end;

// При прорисовке круга
// Показываем интерфейс настройки типа линии и ее цвета

  sgiCircle:

    begin
    // показываем настройки
      Rectangle1.Visible:=true;
    // перерисовываем PaintBox (он служит для вывода графики)
      PaintBox1.Repaint;
    end;

end;


end;
// Нажатие клавиши
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
//*************************************************//
 if Key = vkVolumeUp then
 begin
         Key:=0;
         size:=size-5;
  if size<5 then size:=5;
    PaintBox1.Repaint;
 end;
//**************************************************//

//*************************************************//
 if Key = vkVolumeDown then
 begin
         Key:=0;
         size:=size+5;
 if size>150 then size:=150;
    PaintBox1.Repaint;
 end;
//**************************************************//

//*************************************************//
 if Key = vkHardwareBack then
 begin
         Key:=0;
         ExitConfirm;
 end;
//**************************************************//

end;

// Отпускание клавиши
procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
//*************************************************//
 if Key = vkVolumeUp then
 begin
  Key:=0;
 end;
//**************************************************//

//*************************************************//
 if Key = vkVolumeDown then
 begin
  Key:=0;
 end;
//**************************************************//

//*************************************************//
 if Key = vkHardwareBack then
 begin
  Key:=0;
 end;
//**************************************************//

end;

procedure TForm1.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
  var p1,p2:tpoint;       // точки р1 и р2
  x0,y0:integer;      // координаты центра
begin

// Цвет формы

  PaintBox1.Canvas.Stroke.Color:=ColorPicker1.Color;

// Выбор типа линии

  case ltsel of
    1: PaintBox1.Canvas.Stroke.Dash:=TStrokeDash.Solid;      // Сполшная
    2: PaintBox1.Canvas.Stroke.Dash:=TStrokeDash.Dot;        // Точечная
    3: PaintBox1.Canvas.Stroke.Dash:=TStrokeDash.Dash;       // Штриховая
  end;


  PaintBox1.Canvas.Stroke.Thickness:=thickness;             //  Толщина линии

// Рисовать графику следует между блоками BeginScene и EndScene

  PaintBox1.Canvas.BeginScene;

 // Координаты центра формы (div деление нацело)

 x0:=Round(PaintBox1.Width/2);
 y0:=Round(PaintBox1.Height/2);

// Первая линия

 p1.X:=x0+size;
 p1.Y:=y0+size;

 p2.X:=x0+size;
 p2.Y:=y0-size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

 // Вторая линия

 p1.X:=x0+size;
 p1.Y:=y0+size;

 p2.X:=x0-size;
 p2.Y:=y0+size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

 // Третья линия

 p1.X:=x0-size;
 p1.Y:=y0+size;

 p2.X:=x0-size;
 p2.Y:=y0-size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

  // Четвертая линия

 p1.X:=x0-size;
 p1.Y:=y0-size;

 p2.X:=x0+size;
 p2.Y:=y0-size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

 // Перекрестная 1

 p1.X:=x0-size;
 p1.Y:=y0-size;

 p2.X:=x0+size;
 p2.Y:=y0+size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

 // Перекрестная 2

 p1.X:=x0-size;
 p1.Y:=y0+size;

 p2.X:=x0+size;
 p2.Y:=y0-size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

 PaintBox1.Canvas.EndScene;

end;
// Подтверждение віхода из приложения при переключении Switch
procedure TForm1.Switch1Switch(Sender: TObject);
begin
if Switch1.IsChecked then
    begin
      ExitConfirm;
      switch1.IsChecked:=false;
    end;
end;

end.
