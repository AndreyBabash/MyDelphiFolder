unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Maps,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.MultiView, FMX.ListBox,
  FMX.Layouts, System.Sensors, System.Sensors.Components, System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.URLClient, Json
  {$IFDEF ANDROID}
  , FMX.Platform.Android, Androidapi.JNI.Widget, FMX.Helpers.Android, AndroidApi.Helpers,
  System.ImageList, FMX.ImgList, SyncObjs
  {$ENDIF};

// ��������� ��� �������� ���������� � ����������
type TransportOptions = record
  imei: Int64;
  gov_number: string;
  route_id: string;
  route_short_name: string;
  route_long_name: string;
  route_type: string;
  time: string;
  longitude: Double;
  latitude: Double;
  satellites: Integer;
  speed: Integer;
end;

  // ����� 1
type TMyThread = class(TThread)
   private
    procedure ShowProgress;
    procedure AddMarkerToMap;
    procedure ButtonEnabled;
    procedure ButtonDisabled;
    procedure DeleteMarkers;
   public
   	procedure Execute; override;
 end;

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
    ImageList1: TImageList;
    Button1: TButton;
    ProgressBar1: TProgressBar;
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
    procedure MyMapMarkerDoubleClick(Marker: TMapMarker);
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
    transportinfo:string;
    // ������ ���������� � ����������
    TransportArr:TArray<TransportOptions>;
    // ������ �������� ����������
    DevicesMarkerArr:TArray<TMapMarker>;
    StopSynchronize:TCriticalSection;
    mythread:TMyThread;
    incvalue:integer;
    JSONMyArr:TJSONArray;
    MyMarkerDescr: TMapMarkerDescriptor; // �������� �������� ���� �������
    function idHttpGet(const aURL: string): string;
    procedure IconIdentification(var rt:string; var ImageList:TImageList; var MapDescriptor:TMapMarkerDescriptor);
  end;

const MapType: array [1..3] of TMapType =(TMapType.Normal, TMapType.Satellite, TMapType.Hybrid);


var
  MyForm: TMyForm;

implementation

{$R *.fmx}


// ���������� ������
procedure TMyThread.ShowProgress;
begin
  MyForm.ProgressBar1.Value:=MyForm.incvalue;
end;

procedure TMyThread.AddMarkerToMap;
begin
  MyForm.DevicesMarkerArr[MyForm.incvalue] := MyForm.MyMap.AddMarker(MyForm.MyMarkerDescr); // ����������� ������� �������� � ��������� �� �����
end;


procedure TMyThread.ButtonEnabled;
begin
  MyForm.Button1.Enabled:=True;
end;


procedure TMyThread.ButtonDisabled;
begin
  MyForm.Button1.Enabled:=False;
end;


procedure TMyThread.DeleteMarkers;
var i:integer;
begin
  // ������� ��� ������� � ����������� �� "�������"
  for i:=0 to MyForm.JSONMyArr.Size-1 do
  begin
  // ���������, ���� �� ������ �� �����
      if MyForm.DevicesMarkerArr[i]<>nil then
      begin
        MyForm.DevicesMarkerArr[i].Remove;  // ������� ������
        MyForm.DevicesMarkerArr[i]:=nil;    // ����������� ������� "�������"
      end;
  end;
end;

procedure TMyThread.Execute;
var responsejson:string;
    JSON:TJSONObject; i:integer;
    MarkerLocation: TMapCoordinate; // ���������� �������
begin

    MyForm.StopSynchronize.Enter;
    Synchronize(ButtonDisabled);

 // �������� ���������� � �������������� ���������� � ������� json

    responsejson:=UTF8Encode(MyForm.idHttpGet(MyForm.transportinfo));
    responsejson:='{"mainarr":'+responsejson+'}';

    JSON := TJSONObject.ParseJSONValue(responsejson) as TJSONObject;
    MyForm.JSONMyArr:=TJSONArray(JSON.Get('mainarr').JsonValue);
    FormatSettings.DecimalSeparator:='.';

    // ������������� ������ ������������� �������
    SetLength(MyForm.TransportArr,MyForm.JSONMyArr.Size);

    MyForm.ProgressBar1.Max:=MyForm.JSONMyArr.Size;

  // ������������� ������ �������
  SetLength(MyForm.DevicesMarkerArr,MyForm.JSONMyArr.Size);

  // ������� ��� ������� � ����������� �� "�������"
 { for i:=0 to MyForm.JSONMyArr.Size-1 do
  begin
  // ���������, ���� �� ������ �� �����
      if MyForm.DevicesMarkerArr[i]<>nil then
      begin
        MyForm.DevicesMarkerArr[i].Remove;  // ������� ������
        MyForm.DevicesMarkerArr[i]:=nil;    // ����������� ������� "�������"
      end;
  end;  }

  Synchronize(DeleteMarkers);

  // �������� ���������� � ����������
  for i:=0 to MyForm.JSONMyArr.Size-1 do
  begin
    MyForm.TransportArr[i].imei:=Int64.Parse(TJSONPair(TJSONObject(MyForm.JSONMyArr.Get(i)).Get('imei')).JsonValue.Value);
    MyForm.TransportArr[i].gov_number:=TJSONPair(TJSONObject(MyForm.JSONMyArr.Get(i)).Get('gov_number')).JsonValue.Value;
    MyForm.TransportArr[i].route_id:=TJSONPair(TJSONObject(MyForm.JSONMyArr.Get(i)).Get('route_id')).JsonValue.Value;
    MyForm.TransportArr[i].route_short_name:=TJSONPair(TJSONObject(MyForm.JSONMyArr.Get(i)).Get('route_short_name')).JsonValue.Value;
    MyForm.TransportArr[i].route_long_name:=TJSONPair(TJSONObject(MyForm.JSONMyArr.Get(i)).Get('route_long_name')).JsonValue.Value;
    MyForm.TransportArr[i].route_type:=TJSONPair(TJSONObject(MyForm.JSONMyArr.Get(i)).Get('route_type')).JsonValue.Value;
    MyForm.TransportArr[i].time:=TJSONPair(TJSONObject(MyForm.JSONMyArr.Get(i)).Get('time')).JsonValue.Value;
    MyForm.TransportArr[i].longitude:=Double.Parse(TJSONPair(TJSONObject(MyForm.JSONMyArr.Get(i)).Get('longitude')).JsonValue.Value);
    MyForm.TransportArr[i].latitude:=Double.Parse(TJSONPair(TJSONObject(MyForm.JSONMyArr.Get(i)).Get('latitude')).JsonValue.Value);
    MyForm.TransportArr[i].satellites:=Integer.Parse(TJSONPair(TJSONObject(MyForm.JSONMyArr.Get(i)).Get('satellites')).JsonValue.Value);
    MyForm.TransportArr[i].speed:=Integer.Parse(TJSONPair(TJSONObject(MyForm.JSONMyArr.Get(i)).Get('speed')).JsonValue.Value);
    MyForm.incvalue:=i;
    Synchronize(ShowProgress);
    //ProgressBar1.Value:=i+1;
    //Application.ProcessMessages;
    Sleep(10);
  end;

  //
  SetLength(MyForm.DevicesMarkerArr,MyForm.JSONMyArr.Size);
  MyForm.ProgressBar1.Max:=MyForm.JSONMyArr.Size;

  // ������� ��� ������� �� �����
  for i:=0 to MyForm.JSONMyArr.Size-1 do
  begin
  // ���������, ���� �� ��� ������ �� ����� (��������� �� "�������")
  if MyForm.DevicesMarkerArr[i]=nil then
    begin

        MarkerLocation.Latitude:=MyForm.TransportArr[i].latitude;
        MarkerLocation.Longitude:=MyForm.TransportArr[i].longitude;

        MyForm.MyMarkerDescr := TMapMarkerDescriptor.Create(MarkerLocation, MyForm.TransportArr[i].route_long_name);  // ������� �������� �������

        MyForm.IconIdentification(MyForm.TransportArr[i].route_short_name,MyForm.ImageList1,MyForm.MyMarkerDescr);

        MyForm.MyMarkerDescr.Snippet:='��������: '+MyForm.TransportArr[i].speed.ToString+' ��/�'+#13#10
        +'�����: '+MyForm.TransportArr[i].time+#13#10+'�����: '+MyForm.TransportArr[i].gov_number+#13#10+
        '�������: '+MyForm.TransportArr[i].route_short_name+#13#10+'��� ��������: '+MyForm.TransportArr[i].route_type+
        #13#10+'imei: '+MyForm.TransportArr[i].imei.ToString;
        MyForm.MyMarkerDescr.Draggable := False;
        MyForm.incvalue:=i;
        Synchronize(AddMarkerToMap);
        //MyForm.DevicesMarkerArr[i] := MyForm.MyMap.AddMarker(MyMarkerDescr); // ����������� ������� �������� � ��������� �� �����
    end;
     MyForm.incvalue:=i;
     Synchronize(ShowProgress);

  end;
  Synchronize(ButtonEnabled);
  MyForm.StopSynchronize.Leave;

end;


procedure TMyForm.IconIdentification(var rt: string; var ImageList: TImageList; var MapDescriptor: TMapMarkerDescriptor);
var j:integer; const route_short: array [1..15] of string =('6', '7-�','5','33','16�','5A','32','11','23','2','8','7','1','7A','31');
begin
  for j:=1 to 15 do
  begin
    if rt=route_short[j] then
    begin
      MapDescriptor.Icon:=ImageList.Source[0].Source.Items[0].MultiResBitmap[j-1].Bitmap;
      Break;
    end
  end;
end;


{procedure IconIdentification(var rt:string; var ImageList:TImageList; var MapDescriptor:TMapMarkerDescriptor);
var j:integer; const route_short: array [1..15] of string =('6', '7-�','5','33','16�','5A','32','11','23','2','8','7','1','7A','31');
begin
  for j:=1 to 15 do
  begin
    if rt=route_short[j] then
    begin
      MapDescriptor.Icon:=ImageList.Source[0].Source.Items[0].MultiResBitmap[j-1].Bitmap;
      Break;
    end
  end;
end;    }


// ������� ��� �������� ������� �� ������ � ��������� ������ �� ��������� http
function TMyForm.idHttpGet(const aURL: string): string;
// uses  System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.URLClient;
var
  Resp: TStringStream;
  Return: IHTTPResponse;
begin
  Result := '';
  with TNetHTTPClient.Create(nil) do
  begin
    Resp := TStringStream.Create('', TEncoding.UTF8);
    Return := Get( { TURI.URLEncode } (aURL), Resp);
    Result := Resp.DataString;
    Resp.Free;
    Free;
  end;
end;

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
// ��������� �����
		mythread:=TMyThread.Create(True);
	with mythread do
	begin
		FreeOnTerminate:=True;
    {$IFDEF MSWINDOWS}
  	Priority:=tpLower;
    {$ENDIF}
  	Start;
	end;
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
  transportinfo:='https://city.dozor.tech/ua/kramatorsk/devices';
  StopSynchronize:=TCriticalSection.Create;
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
  //MyMap.MapType := TMapType.Normal;
 MyMap.MapType := MapType[1];
end;

procedure TMyForm.ListBoxItem4Click(Sender: TObject);
begin
 // MyMap.MapType := TMapType.Satellite;
  MyMap.MapType := MapType[2];

end;

procedure TMyForm.ListBoxItem5Click(Sender: TObject);
begin
 // MyMap.MapType := TMapType.Hybrid;
  MyMap.MapType := MapType[3];
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

procedure TMyForm.MyMapMarkerDoubleClick(Marker: TMapMarker);
var MarkerTitle:string;
begin
// ����������� ����������
	  MarkerTitle:=Marker.Descriptor.Snippet;
    // � ����������� �� ����������� ������� "����"
{$IFDEF ANDROID}
    TJToast.JavaClass.makeText(TAndroidHelper.Context, StrToJCharSequence(MarkerTitle), TJToast.JavaClass.LENGTH_LONG).show;
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