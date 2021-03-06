unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  {$IFDEF ANDROID}
  	AndroidApi.Helpers, FMX.Platform.Android, Androidapi.JNI.Widget, FMX.Helpers.Android,
 	{$ENDIF}
  FMX.Controls.Presentation, FMX.Colors, FMX.Gestures, FMX.Objects, FMX.Layouts,
  FMX.Ani;

const PI = 3.14;

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
    Layout1: TLayout;
    FloatAnimation1: TFloatAnimation;
    FloatAnimation2: TFloatAnimation;
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
    color:TAlphaColor;
    linetype:TStrokeDash;
    thickness:Integer;
  end;

var
  Form1: TForm1;


implementation

{$R *.fmx}


// ????????????? ?????? ?? ??????????

procedure ExitConfirm;
begin

// ????? ??????????? ????

    MessageDlg('?????? ?????!', System.UITypes.TMsgDlgType.mtInformation,
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
          {$IFDEF ANDROID}
            MainActivity.finish;    // ????? ?? ??????????
          {$ENDIF}
        	{$IFDEF MSWINDOWS}
          	Application.Terminate;    // ????? ?? ??????????
          {$ENDIF}
          end;

          mrNo:

            begin

            end;

        end;
      end
    )

end;

// ????????? ??????? ?????

procedure ThicknessInc(var l:Tlabel);
begin
  with Form1 do
  begin
      thickness:=thickness+1;
    if thickness>10 then thickness:=10;
    l.Text:='??????? ?????: '+inttostr(thickness);
  end;
end;


procedure ThicknessDec(var l:Tlabel);
begin
with Form1 do
  begin
  thickness:=thickness-1;
  if thickness<1 then thickness:=1;
  l.Text:='??????? ?????: '+inttostr(thickness);
  end;
end;


// ????? ???? ?????
procedure TForm1.Button2Click(Sender: TObject);
begin
  if radiobutton1.IsChecked then linetype:=TStrokeDash.Solid;
  if radiobutton2.IsChecked then linetype:=TStrokeDash.Dot;
  if radiobutton3.IsChecked then linetype:=TStrokeDash.Dash;

  color:=ColorPicker1.Color;
  FloatAnimation2.StartValue:=0;
  FloatAnimation2.StopValue:=Layout1.Width;
  FloatAnimation2.Start;

 // Layout1.Visible:=false;
  PaintBox1.Repaint;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  thickness:=1;
  Label2.Text:='??????? ?????: '+inttostr(thickness);
  color:=TAlphaColors.Aqua;
  linetype:=TStrokeDash.Solid;
end;

procedure TForm1.FormGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin

// ?????????? ????????? ???? ? ???????????? ???

case EventInfo.GestureID of
// ???????? ????? (??????????? ??????? ????? ????????? ???????)
  sgiLeft:

    begin
      ThicknessInc(Label2);
      PaintBox1.Repaint;
    end;
// ???????? ?????? (????????? ??????? ????? ????????? ???????)
  sgiRight:

    begin
      ThicknessDec(Label2);
      PaintBox1.Repaint;
    end;

// ??? ?????????? ?????
// ?????????? ????????? ????????? ???? ????? ? ?? ?????

  sgiCircle:

    begin
    // ?????????? ?????????
      Layout1.Visible:=true;
      Layout1.Position.X:=0;
      Layout1.Position.Y:=-Layout1.Height;
      FloatAnimation1.StartValue:=-Layout1.Height;
      FloatAnimation1.StopValue:=0;
      FloatAnimation1.Start;
    // ?????????????? PaintBox (?? ?????? ??? ?????? ???????)
      PaintBox1.Repaint;
    end;

end;


end;

// ??????? ???????
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
{$IFDEF ANDROID}
//*************************************************//
 if Key = vkVolumeUp then
 begin
         Key:=0;
         color:=TAlphaColors.Red;
         PaintBox1.Repaint;
 end;
//**************************************************//

//*************************************************//
 if Key = vkVolumeDown then
 begin
         Key:=0;
         color:=TAlphaColors.Blue;
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
{$ENDIF}
{$IFDEF MSWINDOWS}
//*************************************************//
 if Key = vkUp then
 begin
         Key:=0;
         color:=TAlphaColors.Green;
         PaintBox1.Repaint;
 end;
//**************************************************//

if Key = vkInsert then
begin
  // ?????????? ?????????
      Layout1.Visible:=true;
    // ?????????????? PaintBox (?? ?????? ??? ?????? ???????)
      Layout1.Position.X:=0;
      Layout1.Position.Y:=-Layout1.Height;
      FloatAnimation1.StartValue:=-Layout1.Height;
      FloatAnimation1.StopValue:=0;
      FloatAnimation1.Start;

      PaintBox1.Repaint;
end;

//*************************************************//
 if Key = vkDown then
 begin
         Key:=0;
         color:=TAlphaColors.Black;
         PaintBox1.Repaint;
 end;
//**************************************************//

//*************************************************//
 if Key = vkEscape then
 begin
         Key:=0;
         ExitConfirm;
 end;
//**************************************************//

//*************************************************//
 if Key = vkRight then
 begin
      ThicknessDec(Label2);
      PaintBox1.Repaint;
 end;
//**************************************************//

//*************************************************//
 if Key = vkLeft then
 begin
      ThicknessInc(Label2);
      PaintBox1.Repaint;
 end;
//**************************************************//

//*************************************************//
 if Key = vkInsert then
 begin
 			// ?????????? ?????????
      Layout1.Visible:=true;
    	// ?????????????? PaintBox (?? ?????? ??? ?????? ???????)
      PaintBox1.Repaint;
 end;
//**************************************************//

 {$ENDIF}
end;

// ?????????? ???????
procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
{$IFDEF ANDROID}
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
{$ENDIF}
{$IFDEF MSWINDOWS}
//*************************************************//
 if Key = vkUp then
 begin
  Key:=0;
 end;
//**************************************************//

//*************************************************//
 if Key = vkDown then
 begin
  Key:=0;
 end;
//**************************************************//

//*************************************************//
 if Key = vkEscape then
 begin
  Key:=0;
 end;
//**************************************************//
//*************************************************//
 if Key = vkRight then
 begin
  Key:=0;
 end;
//**************************************************//

//*************************************************//
 if Key = vkLeft then
 begin
  Key:=0;
 end;
//**************************************************//
//*************************************************//
 if Key = vkInsert then
 begin
  Key:=0;
 end;
//**************************************************//
 {$ENDIF}
end;



procedure TForm1.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
  var p1,p2:tpoint;       // ????? ?1 ? ?2
begin

// ???? ?????

  PaintBox1.Canvas.Stroke.Color:=color;

// ????? ???? ?????

  PaintBox1.Canvas.Stroke.Dash:=linetype;      // ????????

  //  ??????? ?????
  PaintBox1.Canvas.Stroke.Thickness:=thickness;

  // ???????? ??????? ??????? ????? ??????? BeginScene ? EndScene

  PaintBox1.Canvas.BeginScene;

// ?????? ?????

  p1.X:=10;
  p1.Y:=10;

  p2.X:=10;
  p2.Y:=Round(PaintBox1.Height)-10;

  PaintBox1.Canvas.DrawLine(p1,p2,1.0);


// ?????? ?????

  p1.X:=10;
  p1.Y:=10;

  p2.X:=Round(PaintBox1.Width)-10;
  p2.Y:=10;

  PaintBox1.Canvas.DrawLine(p1,p2,1.0);

// ????????? ?????

  p1.X:=10;
  p1.Y:=Round(PaintBox1.Height)-10;

  p2.X:=Round(PaintBox1.Width)-10;
  p2.Y:=Round(PaintBox1.Height)-10;

  PaintBox1.Canvas.DrawLine(p1,p2,1.0);


  PaintBox1.Canvas.EndScene;

end;

// ????????????? ?????? ?? ?????????? ??? ???????????? Switch
procedure TForm1.Switch1Switch(Sender: TObject);
begin
if Switch1.IsChecked then
    begin
      ExitConfirm;
      switch1.IsChecked:=false;
    end;
end;

end.
