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

// ������������� ������ �� ����������

procedure ExitConfirm;
begin

// ����� ����������� ����

    MessageDlg('������ �����!', System.UITypes.TMsgDlgType.mtInformation,
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

            MainActivity.finish;    // ����� �� ����������

          end;

          mrNo:

            begin

            end;

        end;
      end
    )

end;

// ��������� ������� �����

procedure ThicknessInc(var l:Tlabel);
begin
 thickness:=thickness+1;
 if thickness>10 then thickness:=10;
 l.Text:='������� �����: '+inttostr(thickness);
end;


procedure ThicknessDec(var l:Tlabel);
begin
  thickness:=thickness-1;
  if thickness<1 then thickness:=1;
  l.Text:='������� �����: '+inttostr(thickness)
end;


// ����� ���� �����
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
  Label2.Text:='������� �����: '+inttostr(thickness);
end;

procedure TForm1.FormGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin

// ���������� ��������� ���� � ������������ ���

case EventInfo.GestureID of
// �������� ����� (����������� ������� ����� ��������� �������)
  sgiLeft:

    begin
      ThicknessInc(Label2);
      PaintBox1.Repaint;
    end;
// �������� ������ (��������� ������� ����� ��������� �������)
  sgiRight:

    begin
      ThicknessDec(Label2);
      PaintBox1.Repaint;
    end;

// ��� ���������� �����
// ���������� ��������� ��������� ���� ����� � �� �����

  sgiCircle:

    begin
    // ���������� ���������
      Rectangle1.Visible:=true;
    // �������������� PaintBox (�� ������ ��� ������ �������)
      PaintBox1.Repaint;
    end;

end;


end;
// ������� �������
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

// ���������� �������
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
  var p1,p2:tpoint;       // ����� �1 � �2
  x0,y0:integer;      // ���������� ������
begin

// ���� �����

  PaintBox1.Canvas.Stroke.Color:=ColorPicker1.Color;

// ����� ���� �����

  case ltsel of
    1: PaintBox1.Canvas.Stroke.Dash:=TStrokeDash.Solid;      // ��������
    2: PaintBox1.Canvas.Stroke.Dash:=TStrokeDash.Dot;        // ��������
    3: PaintBox1.Canvas.Stroke.Dash:=TStrokeDash.Dash;       // ���������
  end;


  PaintBox1.Canvas.Stroke.Thickness:=thickness;             //  ������� �����

// �������� ������� ������� ����� ������� BeginScene � EndScene

  PaintBox1.Canvas.BeginScene;

 // ���������� ������ ����� (div ������� ������)

 x0:=Round(PaintBox1.Width/2);
 y0:=Round(PaintBox1.Height/2);

// ������ �����

 p1.X:=x0+size;
 p1.Y:=y0+size;

 p2.X:=x0+size;
 p2.Y:=y0-size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

 // ������ �����

 p1.X:=x0+size;
 p1.Y:=y0+size;

 p2.X:=x0-size;
 p2.Y:=y0+size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

 // ������ �����

 p1.X:=x0-size;
 p1.Y:=y0+size;

 p2.X:=x0-size;
 p2.Y:=y0-size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

  // ��������� �����

 p1.X:=x0-size;
 p1.Y:=y0-size;

 p2.X:=x0+size;
 p2.Y:=y0-size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

 // ������������ 1

 p1.X:=x0-size;
 p1.Y:=y0-size;

 p2.X:=x0+size;
 p2.Y:=y0+size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

 // ������������ 2

 p1.X:=x0-size;
 p1.Y:=y0+size;

 p2.X:=x0+size;
 p2.Y:=y0-size;

 PaintBox1.Canvas.DrawLine(p1,p2,1.0);

 PaintBox1.Canvas.EndScene;

end;
// ������������� ����� �� ���������� ��� ������������ Switch
procedure TForm1.Switch1Switch(Sender: TObject);
begin
if Switch1.IsChecked then
    begin
      ExitConfirm;
      switch1.IsChecked:=false;
    end;
end;

end.
