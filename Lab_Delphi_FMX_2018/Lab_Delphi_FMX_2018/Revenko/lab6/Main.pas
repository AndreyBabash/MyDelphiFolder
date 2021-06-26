unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Objects, FMX.Gestures;

type
  TForm2 = class(TForm)
    procedure FormTouch(Sender: TObject; const Touches: TTouches;
      const Action: TTouchAction);
  private
    { Private declarations }
    FCountTouch: Integer;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

uses
  System.TypInfo;

procedure TForm2.FormTouch(Sender: TObject; const Touches: TTouches;
  const Action: TTouchAction);
var
  i, j: Integer;
  MyNewCircle:TCircle; // Динамические окружности
  LabelNew:TLabel;     // Динамические надписи
begin

// Опрашиваем количество прикосновений


  if FCountTouch <> Length(Touches) then

  begin

// Удаляем все компоненты на форме

    Form2.DeleteChildren;

// В зависимости от числа прикосновений создаем окружности

    for i := 1 to Length(Touches) do
    begin

      MyNewCircle := TCircle.Create(Form2);
      MyNewCircle.Parent := Form2;
      MyNewCircle.Name := 'C' + i.ToString;
      MyNewCircle.Size.Height:=40;
      MyNewCircle.Size.Width:=40;

// Закрашиваем окружности в определенный цвет
// в зависимости от прикосновения

      case i of

        1: MyNewCircle.Fill.Color:=TAlphaColors.Red;
        2: MyNewCircle.Fill.Color:=TAlphaColors.Blue;
        3: MyNewCircle.Fill.Color:=TAlphaColors.Green;
        4: MyNewCircle.Fill.Color:=TAlphaColors.Chocolate;
        5: MyNewCircle.Fill.Color:=TAlphaColors.Greenyellow;
        else
          begin
            MyNewCircle.Fill.Color:=TAlphaColors.Aqua;
          end;
      end;

// Создаем надписи для вывода координат касания

      LabelNew := TLabel.Create(Form2);
      LabelNew.Parent := Form2;
      LabelNew.Name := 'Label' + i.ToString;
      LabelNew.AutoSize := True;
      LabelNew.TextSettings.Trimming := TTextTrimming.None;
      LabelNew.TextSettings.WordWrap := False;
      LabelNew.TextSettings.FontColor := TAlphaColors.Red;

    end;

  end;


  for j := 0 to Length(Touches)-1 do
  begin

// Выводим окружности в зависимости от координат касания

      with Form2.FindComponent('C' + IntToStr(j+1)) as TCircle do
      begin
          Position.X := Trunc(Touches[j].Location.X);
          Position.Y := Trunc(Touches[j].Location.Y);
      end;

// Выводим надписи и координаты касаний

      with Form2.FindComponent('Label' + IntToStr(j+1)) as TLabel do
      begin

          Position.X := Trunc(Touches[j].Location.X+30);
          Position.Y := Trunc(Touches[j].Location.Y+30);

          Text := 'Касание № - ' + (j+1).ToString + ' ('
          + Trunc(Touches[j].Location.X).ToString + 'x'
          + Trunc(Touches[j].Location.Y).ToString + ')';
      end;
  end;

// Подсчет касаний

 FCountTouch := Length(Touches);




end;

end.
