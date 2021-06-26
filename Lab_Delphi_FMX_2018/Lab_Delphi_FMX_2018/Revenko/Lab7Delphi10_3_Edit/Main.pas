unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Maps,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.MultiView, FMX.ListBox,
  FMX.Layouts, System.Sensors, System.Sensors.Components
  {$IFDEF ANDROID}
  , FMX.Platform.Android, Androidapi.JNI.Widget, FMX.Helpers.Android, AndroidApi.Helpers,
  FMX.Edit, FMX.Objects
  {$ENDIF};

type
  TMyForm = class(TForm)
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    DrawerBtn: TButton;
    Label1: TLabel;
    MyMap: TMapView;
    ButtonAddMarker: TButton;
    ButtonDeleteMarker: TButton;
    MyMultiView: TMultiView;
    ScrollBox1: TScrollBox;
    Label2: TLabel;
    ListBox1: TListBox;
    ListBoxGroupHeader1: TListBoxGroupHeader;
    ListBoxItem1: TListBoxItem;
    TrackBarRotate: TTrackBar;
    ListBoxGroupHeader2: TListBoxGroupHeader;
    ListBoxItem2: TListBoxItem;
    TrackBarTilt: TTrackBar;
    ListBoxGroupHeader3: TListBoxGroupHeader;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ListBoxGroupHeader4: TListBoxGroupHeader;
    ListBoxItem6: TListBoxItem;
    LocationSwitch: TSwitch;
    MyLocationSensor: TLocationSensor;
    ButtonDrawLine: TButton;
    DeleteLineBtn: TButton;
    Layout1: TLayout;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Edit1: TEdit;
    Edit2: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure LocationSwitchSwitch(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MyLocationSensorLocationChanged(Sender: TObject;
      const OldLocation, NewLocation: TLocationCoord2D);
    procedure MyMapMarkerClick(Marker: TMapMarker);
    procedure ButtonAddMarkerClick(Sender: TObject);
    procedure ButtonDeleteMarkerClick(Sender: TObject);
    procedure MyMultiViewStartHiding(Sender: TObject);
    procedure MyMultiViewStartShowing(Sender: TObject);
    procedure ListBoxItem3Click(Sender: TObject);
    procedure ListBoxItem4Click(Sender: TObject);
    procedure ListBoxItem5Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure TrackBarRotateChange(Sender: TObject);
    procedure TrackBarTiltChange(Sender: TObject);
    procedure ButtonDrawLineClick(Sender: TObject);
    procedure DeleteLineBtnClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    // ������ ��������������
    MyLocationMarker:TMapMarker;
    // ������ ������������
    MyMarker:TMapMarker;
    // ���������� �������� �������������� � ������������
    MyLocationPoint:TPointF;
    MyMarkerPoint:TPointF;
    // �������� �����
    MyLineDescriptor:TMapPolylineDescriptor;
    // �����
    MyLine:TMapPolyline;
    // ����� ��������� �����
    Points:TArray<TMapCoordinate>;
  end;

var
  MyForm: TMyForm;

implementation

{$R *.fmx}


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

            {$IFDEF ANDROID}
              MainActivity.finish;    // ����� �� ����������
            {$ENDIF}

            {$IFDEF MSWINDOWS}
              Application.Terminate;
            {$ENDIF}


          end;

          mrNo:

            begin

            end;

        end;
      end
    )

end;

// ��������� ���������������� ������ �� �����
procedure TMyForm.Button1Click(Sender: TObject);
begin
  MyMarkerPoint.X:=Double.Parse(Edit1.Text);
  MyMarkerPoint.Y:=Double.Parse(Edit2.Text);
  MyMap.Visible := True;
  Layout1.Visible := False;
end;

procedure TMyForm.Button2Click(Sender: TObject);
begin
  MyMap.Visible := False;
  Layout1.Visible := not Layout1.Visible;
end;

procedure TMyForm.ButtonAddMarkerClick(Sender: TObject);
var MarkerLocation: TMapCoordinate; // ���������� �������
    MyMarkerDescr: TMapMarkerDescriptor; // �������� �������� ���� �������
begin
// ���������, ���� �� ��� ������ �� ����� (��������� �� "�������")
  if MyMarker=nil then
  begin
	  MarkerLocation := TMapCoordinate.Create(MyMarkerPoint);  // ��������� ���������� �� TPointF � TMapCoordinate
    MyMarkerDescr := TMapMarkerDescriptor.Create(MarkerLocation, '��� ��� ������)');  // ������� �������� �������
    MyMarkerDescr.Draggable := True;  // ������ ����� ���������� �� �����
    MyMarker := MyMap.AddMarker(MyMarkerDescr); // ����������� ������� �������� � ��������� �� �����
  end;
end;

// ������� ������
procedure TMyForm.ButtonDeleteMarkerClick(Sender: TObject);
begin
// ���������, ���� �� ������ �� �����
      if MyMarker<>nil then
      begin
        MyMarker.Remove;  // ������� ������
        MyMarker:=nil;    // ����������� ������� "�������"
      end;
end;

// ������ �����
procedure TMyForm.ButtonDrawLineClick(Sender: TObject);
begin
// ���������, ���� �� ��� ����� �� �����
  if MyLine=nil then
  begin
    // ������������� ������ ������������� ������� (��� ���������� ����� ����� ��� �����)
    SetLength(Points,2);
    //  ����� ����� ��������� ������ �������������� � ���������������� ������
    //  ������� ����� �� ������ ��������� �������������� ��������
    Points[0] := TMapCoordinate.Create(MyLocationPoint);
    Points[1] := TMapCoordinate.Create(MyMarkerPoint);
    // ������� �������� ����� �� ������ �����
    MyLineDescriptor := TMapPolylineDescriptor.Create(Points);
    // ������������� ������� �����
    MyLineDescriptor.StrokeWidth := 20;
    // ������������� ���� �����
    MyLineDescriptor.StrokeColor := TAlphaColors.YellowGreen;
    // ��������� ����� �� �����
    MyLine := MyMap.AddPolyline(MyLineDescriptor);
  end
  else
  begin
  // ���� ����� ��� ��������� - �������
    Myline.Remove;
    Myline := nil;
  end;
end;

// �������� �����
procedure TMyForm.DeleteLineBtnClick(Sender: TObject);
begin
// ���� ����� ���� �� ����� - �������
  if MyLine<>nil then
  begin
    Myline.Remove;
    Myline := nil;
  end;
end;

procedure TMyForm.FormCreate(Sender: TObject);
begin
// ���������� ����������������� ������� (������ � �������)
  MyMarkerPoint.X:=41.2;
  MyMarkerPoint.Y:=40.5;
end;

// ��� ������� ������ ����� ����������� ������ ������ �� ����������
procedure TMyForm.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if Key = vkHardwareBack then ExitConfirm;
end;

// ��� ���������� ������ �� ������
procedure TMyForm.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if Key = vkHardwareBack then Key := 0;
end;

// ������������� ��� �����                                  //
procedure TMyForm.ListBoxItem3Click(Sender: TObject);
begin
  MyMap.MapType := TMapType.Normal;
end;

procedure TMyForm.ListBoxItem4Click(Sender: TObject);
begin
  MyMap.MapType := TMapType.Satellite;
end;

procedure TMyForm.ListBoxItem5Click(Sender: TObject);
begin
  MyMap.MapType := TMapType.Hybrid;
end;

//*********************************************************//
// ��� ������������ ����� ���������� ��� ������������ LocationSensor
procedure TMyForm.LocationSwitchSwitch(Sender: TObject);
begin
	if LocationSwitch.IsChecked then
  begin
		MyLocationSensor.Active:=true;
    {$IFDEF ANDROID}
			TJToast.JavaClass.makeText(TAndroidHelper.Context, StrToJCharSequence('Location Sensor On'), TJToast.JavaClass.LENGTH_LONG).show;
		{$ENDIF}
  end
	else
	begin
		MyLocationSensor.Active:=false;
    {$IFDEF ANDROID}
			TJToast.JavaClass.makeText(TAndroidHelper.Context, StrToJCharSequence('Location Sensor Off'), TJToast.JavaClass.LENGTH_LONG).show;
		{$ENDIF}
	end;
end;

// ���������� ������� ��������� ��������������
procedure TMyForm.MyLocationSensorLocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
var MyMarkerLocationDescr: TMapMarkerDescriptor; MyLocation: TMapCoordinate;
begin
      // �������������� �����
	      MyMap.Repaint;
      // ����������� ���������� ������ ��������������
	      MyLocationPoint.X := NewLocation.Latitude;
        MyLocationPoint.Y := NewLocation.Longitude;

   // ���������, ���� �� �� ����� ������ �������� ��������������
    if MyLocationMarker=nil then
    begin
    // ���������� �������������� (����������� ����������� GPS ������� ��� Wi-Fi �����)
	      MyLocation := TMapCoordinate.Create(MyLocationPoint);
    // ���������� ����� �������� ����������� ��������������
        MyMap.Location := MyLocation;
    // ������� �������� �������
        MyMarkerLocationDescr := TMapMarkerDescriptor.Create(MyLocation,'� �����!)));');
    // ����������� ������� ��� �������
          with MyMarkerLocationDescr do
          begin
            Draggable := False;  // ������ �� ����������� �� �����
            Visible := True;     // ��������� �������
            Appearance := TMarkerAppearance.Billboard; // ������� ��� - �������� ������
            Snippet := Format('Lat/Lon: %s,%s',[FloatToStrF(MyLocationPoint.X,ffGeneral,4,2),FloatToStrF(MyLocationPoint.Y,ffGeneral,4,2)]); // �������� ��� ���������
          end;

        MyLocationMarker := MyMap.AddMarker(MyMarkerLocationDescr);  // ��������� ������ �� �����
        MyMap.Zoom:=30; // ��� ����� 30
    end
    else
    // ���� ������ ��� ���������� �� ����� - �������
    begin
        MyLocationMarker.Remove;
        MyLocationMarker := nil;
    end;
end;

// ���������� ������ �� ��������
procedure TMyForm.MyMapMarkerClick(Marker: TMapMarker);
var MarkerTitle:string;
begin
// ����������� ��������
	  MarkerTitle:=Marker.Descriptor.Title;
    // � ����������� �� �������� ������� "����"
{$IFDEF ANDROID}
	if MarkerTitle<>'� �����!)));' then
    TJToast.JavaClass.makeText(TAndroidHelper.Context, StrToJCharSequence('����������: '+Marker.Descriptor.Position.Latitude.ToString+' '+Marker.Descriptor.Position.Longitude.ToString), TJToast.JavaClass.LENGTH_LONG).show
  else
    TJToast.JavaClass.makeText(TAndroidHelper.Context, StrToJCharSequence('��� ������!)))'), TJToast.JavaClass.LENGTH_LONG).show;
{$ENDIF}
end;

// ��� ������� MultiView ���������� �����
procedure TMyForm.MyMultiViewStartHiding(Sender: TObject);
begin
  if not MyMap.Visible then MyMap.Visible:=true;
end;

// ��� ��������� MultiView �������� �����
procedure TMyForm.MyMultiViewStartShowing(Sender: TObject);
begin
  if MyMap.Visible then MyMap.Visible:=not MyMap.Visible;
end;

// ������� �����
procedure TMyForm.TrackBarRotateChange(Sender: TObject);
begin
  MyMap.Bearing := TrackBarRotate.Value;
end;

// ������ �����
procedure TMyForm.TrackBarTiltChange(Sender: TObject);
begin
  MyMap.Tilt := TrackBarTilt.Value;
end;

end.