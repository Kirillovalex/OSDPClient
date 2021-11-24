{


                             ПРОЕКТ "OSDP Client"


}


unit MainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  main_thread, Menus , variables,
  StdCtrls, ExtCtrls, ComCtrls, Buttons,
  Grids, jpeg,  registry,
  inifiles , printers , Clipbrd

  ;

const
   INPUTBOXMESSAGE = WM_USER + 200;


   SLEEP_WAIT_THREAD = 0;//250;

type
  TMainForm = class(TForm)
    Timer1: TTimer;
    Panel6: TPanel;
    Label57: TLabel;
    LabelInfo: TLabel;
    Panel_port: TPanel;
    Label11: TLabel;
    Label266: TLabel;
    Label267: TLabel;
    LabelTX: TLabel;
    LabelRX: TLabel;
    ComboboxCOMPORT: TComboBox;
    BitBtnSaveSettings: TBitBtn;
    BitBtnRefreshcomport: TBitBtn;
    ButtonConnect: TButton;
    RadioGroupBaudRate: TRadioGroup;
    Label1: TLabel;
    Memo1: TMemo;
    Label2: TLabel;
    Label3: TLabel;
    Memo2: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    Panel2: TPanel;
    Label4: TLabel;
    EditADDR: TEdit;
    UpDownADDR: TUpDown;
    Editiii: TEdit;
    UpDown2: TUpDown;
    Label5: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Label6: TLabel;
    Edit1: TEdit;
    UpDown3: TUpDown;
    ComboBox1: TComboBox;
    Label7: TLabel;
    Edit2: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    Edit3: TEdit;
    UpDown4: TUpDown;
    Label10: TLabel;
    Edit4: TEdit;
    UpDown5: TUpDown;
    Label12: TLabel;
    Edit5: TEdit;
    UpDown6: TUpDown;
    Label13: TLabel;
    Edit6: TEdit;
    UpDown7: TUpDown;
    Label14: TLabel;
    Edit7: TEdit;
    UpDown8: TUpDown;
    Button12: TButton;
    Label15: TLabel;
    Edit8: TEdit;
    Label16: TLabel;
    Edit9: TEdit;
    Label17: TLabel;
    Edit10: TEdit;
    Label18: TLabel;
    Edit11: TEdit;
    Label19: TLabel;
    Edit12: TEdit;
    Label20: TLabel;
    Edit13: TEdit;
    Label21: TLabel;
    Edit14: TEdit;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    Edit18: TEdit;
    Edit19: TEdit;
    ComboBox5: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Edit20: TEdit;
    Label30: TLabel;
    ComboBox8: TComboBox;
    Edit21: TEdit;
    Label31: TLabel;
    Label32: TLabel;
    LabelCardNumber: TLabel;
    LabelSaratov: TLabel;


    procedure FormCreate(Sender: TObject);

    procedure _REFRESHCOMPORTS();


//    procedure Start_Connection();
    function ComPortAvailable(Port: PChar): Boolean;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);



    procedure Timer1Timer(Sender: TObject);



    procedure Info(s:string;cl:dword);


    procedure SetCaption(s:string);





    procedure ButtonConnectClick(Sender: TObject);
    procedure BitBtnRefreshcomportClick(Sender: TObject);



    procedure __LoadSettings();
    procedure __SaveSettings();


    procedure GetNowTime_FillEdits();

    procedure BitBtnSaveSettingsClick(Sender: TObject);


    procedure ComSettingsActualization();
    function GetADDRGetSQN():boolean;

    procedure Button1Click(Sender: TObject);

    procedure FillHexMemo(mem:TMemo;buf:array of byte; lng:word;beginpacket:integer);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Panel6MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private
    { Private declarations }
  public
    { Public declarations }

  m_prot:CMain_Thread;

  end;

var
  MainForm: TMainForm;

  first_login:longword=0;


  global_repaint:longword;

  need_sound:byte=0;     // надо играть
  already_sound:byte=0;  // уже играем



implementation

uses  // data
      com_32m,
      osdp_client,
      
      mmsystem,
      ShellApi,
      DateUtils ;

{$R *.dfm}


// универсальный Wiegand с проверкой четности
// 0 - все OK           1 - не распознано
function Wiegand_Converting(buf:array of byte;len:byte;var outbuf:array of byte;var error:byte):boolean;
const MAX_WIGAND_ARRAY_SIZE=128;

var
  half:byte;
  sum1:byte;
  sum2:byte;
  iii:integer;
  tmpmod,tmpmod2:byte;

begin    
    half := len div 2;
    sum1 := 0;
    sum2 := 0;
    error := 0;

    if ((len<>26)and(len<>34)and(len<>42)and(len<>50)and(len<>58)) 
    then
    begin error := 1; result:=false; exit; end; // (  |  )

    if (len > MAX_WIGAND_ARRAY_SIZE) then begin error := 1;result:=false; exit; end;
  
    for iii := 0 to (MAX_WIGAND_ARRAY_SIZE div 8)-1 do
      outbuf[iii] := 0;

    for iii := 1 to (len-1)-1 do
    begin

      // -----------------------------------------------------------------------
      if (iii<half)
      then sum1:=sum1+buf[iii]
      else sum2:=sum2+buf[iii];// для подсчета четности/нечетности
      // -----------------------------------------------------------------------
      if (iii mod 8) = 0 then tmpmod:=1  else tmpmod:=0;
      if (iii mod 8) = 0 then tmpmod2:=0 else tmpmod2:=1;

        outbuf[(iii div 8) - tmpmod] := outbuf[(iii div 8) - tmpmod] + (buf[iii] shl ((8*((iii div 8) + (tmpmod2))) - iii));

    end;

  if ((sum1 mod 2) <> buf[0]) then error := 1;    // Первый бит чётности (старшей половины кода) ставится в 1 если количество единиц в его половине кода нечётное.
  if ((sum2 mod 2) = buf[len-1]) then error := 1;// Последний бит чётности (младшей половины кода) ставится в 1 если количество единиц в его половине кода чётное.

  result:=true;

end;



function Wiegand_to_CardNumber(buf:array of byte;len:byte;var outbuf:array of byte;var lng:byte; var error:byte):boolean;
const MAX_WIGAND_ARRAY_SIZE=128;

var
  iii:integer;
  jjj:integer;
  last_bit:byte;
  tmpmod:byte;

begin
    error := 0;

    if ((len = 24) or (len = 32) or (len = 40) or (len = 48) or (len = 56) )
     then begin

            for iii:=0 to len-1 do
            begin
              outbuf[iii] := buf[iii];
            end;
            lng := len div 8;
            error := 0; result:=true; exit;

           end;


    if ((len<>26)and(len<>34)and(len<>42)and(len<>50)and(len<>58))
    then
    begin error := 1; result:=false; exit; end; // (  |  )



    if (len > MAX_WIGAND_ARRAY_SIZE) then begin error := 1;result:=false; exit; end;



    if (len mod 8) = 0 then tmpmod:=0 else tmpmod:=1;
    lng :=  (len div 8) + tmpmod;

    last_bit := len mod 8;
    if last_bit<>0 then last_bit:= last_bit -1;

    for iii := 0 to (lng - 1) do
      outbuf[iii] := 0;



    for iii := 0 to (lng - 1) do
    begin

      // взяли 7 бит (старший отрезали)
      outbuf[iii]:= (buf[iii] and $7F) shl 1;

       if (iii =(lng - 1))
        then outbuf[iii]:= outbuf[iii] and (not (1 shr last_bit))

        else outbuf[iii]:= outbuf[iii] + ((buf[iii+1] and $80) shr 7);

    end;

    if ((len - 2) mod 8) = 0  then tmpmod:=0 else tmpmod:=1;
    lng:=((len - 2) div 8)  + tmpmod;

    result:=true;

end;




procedure TMainForm.GetNowTime_FillEdits();
var SystemTime: TSystemTime;
    Year,Month,Day:word;

begin
// ----------------------------------------
  DateTimeToSystemTime(Now(),SystemTime);

  Edit2.Text :=inttostr(SystemTime.wYear);
  Updown4.position := SystemTime.wMonth;
  Updown5.position := SystemTime.wDay;
  Updown6.position := SystemTime.wHour;
  Updown7.position := SystemTime.wMinute;
  Updown8.position := SystemTime.wSecond;

end;

procedure TMainForm.FillHexMemo(mem:TMemo;buf:array of byte; lng:word;beginpacket:integer);
var tmpstring:string;
    addstring:string;
    iii:integer;


    outbuf:array[0..255] of byte;
    len:byte;
    lngC:byte;
    tmplenadd:byte;
    kkk:integer;
    cn:string;
    error:byte;
begin
 //
  LabelCardNumber.Caption:='';

  addstring:='';
  for iii:=0 to (lng - 1) do
  begin
    tmpstring:=inttohex(buf[iii],2);
    addstring:=addstring+' 0x'+ tmpstring;
  end;

  // detecting
  if m_prot<>nil then if m_prot.m_osdp.Started
  then
  begin

    addstring:=addstring+' ['+m_prot.m_osdp.DetectOSDPCommand(buf[beginpacket + CMD_POSITION])+']';
  end;
  // ==============================

  if (buf[beginpacket + CMD_POSITION] = osdp_RAW)
  then
  begin
    len := buf[beginpacket + CMD_POSITION +3];

    if Wiegand_to_CardNumber(buf[beginpacket + CMD_POSITION+5], len, outbuf, lngC, error)
    then
    begin
      cn:='';
      for kkk:=0 to (lngC -1) do
        cn := cn + ' 0x' + inttohex(outbuf[kkk],2);

      LabelCardNumber.Caption:= 'CARD:' + cn;
    end;

  end;
  mem.Lines.Add(addstring);

end;



procedure TMainForm.Info(s:string;cl:dword);
var color:dword;
begin

// --

  if s='' then LabelInfo.Visible:=false
          else LabelInfo.Visible:=true;


  color:=clGray;

  if (cl=MB_ICONINFORMATION) then color:=clGreen;

  if (cl=MB_ICONEXCLAMATION) then color:=clRed;


  LabelInfo.Color:=color;
  LabelInfo.Caption:='  '+s+'  ';
  LabelInfo.Repaint;
  Application.ProcessMessages;

end;



procedure TMainForm.SetCaption(s:string);
begin
// -------------------------------------

  self.Caption:=s;

  self.LabelSaratov.Caption:=PROGRAMVERSION + ' Saratov';
end;


function TMainForm.ComPortAvailable(Port: PChar): Boolean;
 var
   DeviceName: array[0..80] of Char;
   ComFile: THandle;
begin
   StrPCopy(DeviceName, Port);

   ComFile := CreateFile(DeviceName, GENERIC_READ or GENERIC_WRITE, 0, nil,
     OPEN_EXISTING,
     FILE_ATTRIBUTE_NORMAL, 0);

   Result := ComFile <> INVALID_HANDLE_VALUE;
   CloseHandle(ComFile);
 end;






procedure TMainForm.__LoadSettings();
var _ConfigFile:TiniFile;
    port_str:string;
    baudrate_num:Longword;

    br:TBaudRate;



    ind:word;
begin
//----------------------------
  // _ConfigFile:= TIniFile.Create(ExtractFilePath(ParamStr(0))+ExtractFilename(ParamStr(0))+'.config');
  //  _ConfigFile:= TIniFile.Create(ExtractFilePath(ParamStr(0))+ PROGRAM_INI );

   _ConfigFile:= TIniFile.Create(ExtractFilePath(ParamStr(0))+StringReplace(ExtractFileName(ParamStr(0)),ExtractFileExt(ParamStr(0)),'',[])+'.ini');
   // showmessage(ExtractFilePath(ParamStr(0))+StringReplace(ExtractFileName(ParamStr(0)),ExtractFileExt(ParamStr(0)),'',[])+'.ini');
   port_str:=    _ConfigFile.ReadString('CONNECTION','Port'      ,'FIND');
   baudrate_num:=_ConfigFile.ReadInteger('CONNECTION','BaudRate'  ,9600);
   OSDP_ADDR := _ConfigFile.ReadInteger('OSDP','ADDR' , 1);



   _ConfigFile.Free;





//----------------  1  ------------
  //EditADDR.Text:=IntToStr(OSDP_ADDR);
  UpDownADDR.Position:=OSDP_ADDR;

  Port1Settings.Port:=port_str;
  self.ComboboxCOMPORT.Text:=Port1Settings.Port;





  case baudrate_num of
  9600:  begin br:=cbr9600;      ind:=0;  end;
  19200: begin br:=cbr19200;     ind:=1;  end;
  38400: begin br:=cbr38400;     ind:=2;  end;
  57600: begin br:=cbr57600;     ind:=3; end;
  115200:begin br:=cbr115200;    ind:=4; end;
  921600:begin br:=cbr115200;    ind:=5; end;
  else   begin br:=cbr9600;      ind:=0;  end;
  end;

  self.RadioGroupBaudRate.ItemIndex:=ind;
  Port1Settings.BaudRate:=br;




  Port1Settings.DataBits:=da8;
  Port1Settings.Parity:=paNone;
  Port1Settings.StopBits:=sb1_0;



end;





procedure TMainForm.__SaveSettings();
var _ConfigFile:TiniFile;
  
    baudrate_num:Longword;

begin

  ComSettingsActualization();



  case Port1Settings.BaudRate of
  cbr9600:    begin baudrate_num:=9600;    end;
  cbr19200:   begin baudrate_num:=19200;   end;
  cbr38400:   begin baudrate_num:=38400;   end;
  cbr57600:   begin baudrate_num:=57600;   end;
  cbr115200:  begin baudrate_num:=115200;  end;
  cbr921600:  begin baudrate_num:=921600;  end;

  else        begin baudrate_num:=9600;    end;
  end;




//----------------------------
  // _ConfigFile:= TIniFile.Create(ExtractFilePath(ParamStr(0))+ExtractFilename(ParamStr(0))+'.config');
  // _ConfigFile:= TIniFile.Create(ExtractFilePath(ParamStr(0))+ PROGRAM_INI );
  _ConfigFile:= TIniFile.Create(ExtractFilePath(ParamStr(0))+StringReplace(ExtractFileName(ParamStr(0)),ExtractFileExt(ParamStr(0)),'',[])+'.ini');

 // showmessage(ExtractFilePath(ParamStr(0))+StringReplace(ExtractFileName(ParamStr(0)),ExtractFileExt(ParamStr(0)),'',[])+'.ini');

   _ConfigFile.WriteString('CONNECTION','Port',      Port1Settings.Port);

   _ConfigFile.WriteInteger('CONNECTION','BaudRate', baudrate_num);

   _ConfigFile.WriteString('OSDP','ADDR', inttostr(OSDP_ADDR));

   _ConfigFile.Free;


end;















// действия при загрузке приложения
procedure TMainForm.FormCreate(Sender: TObject);
var deltaW:integer;
    deltaH:integer;
    myRect: TGridRect;

    iii:integer;
begin
  DecimalSeparator:='.';
  application.UpdateFormatSettings:=false;

//showmessage(Application.ExeName);halt;

   GetNowTime_FillEdits();
{
   self.Width:=Screen.Width;
   self.Top:=0;
   self.Left:=0;
   self.WindowState:=wsMaximized;
}
//   pagecontrol1.ActivePageIndex:=0; // графики
//   pagecontrol3.ActivePageIndex:=0; // первый график

  try
   // mkdir
   //if
//   CreateDir(ExtractFilePath(ParamStr(0))+INFO_DIR);
   //then ShowMessage('Новый каталог создан');



 finally
 end;


 self._REFRESHCOMPORTS();

 //Port1Settings.Port:='com20';
  __LoadSettings;




  self.SetCaption(BIGSTAND_NAME);

end;

{
///////////////!!!!!!!!!!!!!!!!!!!!!
// старт/стоп общения
procedure TMainForm.Start_Connection();
begin
// -------------------------
// _____________________________________________________________________________
///  if edit7.text='' then begin MessageBox(handle,'Не выбран Com-порт','Ошибка',MB_ICONEXCLAMATION+MB_OK);exit;end;
// _____________________________________________________________________________



if N1.Caption='СТАРТ'
then begin

     if m_prot<>nil
        then begin
        m_prot.mf_StopService();
        m_prot.Free();
        m_prot:=nil;
        end;

    m_prot:=CModbus_Thread.Create();

    // ________________________________







    // ________________________________

   ///if (not m_prot.mf_StartService(Port1Settings))
   if (not m_prot.mf_StartService(Port1Settings.Port))
   then begin
        m_prot.Free();
        m_prot:=nil;
        MessageBox(handle,'Порт не открыт','Обмена не будет',MB_ICONEXCLAMATION+MB_OK);
        end
   else begin
        m_prot.Resume;

        N1.Caption:='СТОП';
        end;
    end
else begin
     N1.Caption:='СТАРТ';
     if m_prot<>nil
     then begin
        m_prot.mf_StopService();
        m_prot.Free();
        m_prot:=nil;
        end;





     end;


// -------------------------
end;
}
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  // off taskmgr
//  if self.__Get_TaskMgr_Status=TASKMANAGER_DISABLE  then
//  self.__Set_TaskMgr_Status(TASKMANAGER_ENABLE);



//SecurityOff();
// -------------------------------
  if m_prot<>nil
  then begin
    m_prot.mf_StopService();
    m_prot.Free();
    m_prot:=nil;
    end;
// --------------------------------

end;







procedure TMainForm.Timer1Timer(Sender: TObject);
var iii:integer;
    v:single;
    md:word;

    f:single;
    my_tx,my_rx:DWORD;
    s:string;
begin

   //  exit;



    if m_prot=nil then exit;
    if not m_prot.m_osdp.Started then exit;


// -----------------
   m_prot.m_osdp.GetTXTR(my_tx,my_rx);
   str(my_tx,s); labelTX.caption:=s;
   str(my_rx,s); labelRX.caption:=s;
   //f:=m_prot.mf_GetPercent();
  // str(f:0:6,s);EditConnectionPercent.Text:=s;
// -----------------









end;





 




procedure TMainForm.BitBtnSaveSettingsClick(Sender: TObject);
begin
  self.__SaveSettings();
end;



procedure TMainForm.ButtonConnectClick(Sender: TObject);
begin
{
   //   LIc_EDIT.Visible:=false;


  // ----------------------------------------------
 if  UpperCase(Port1Settings.Port)='FIND'
 then Port1Settings.Port:=FormSettings.__FINDCOMPORT();
  // ----------------------------------------------
  if (UpperCase(Port1Settings.Port)='NONE')
  then messageBox(handle,'На компьютере не найдены COM-порты', 'Ошибка',MB_OK+MB_ICONEXCLAMATION)
  else begin
         if (ComPortAvailable(PCHAR(Port1Settings.Port)))
         then Start_Connection()
         else messageBox(handle,'Выбранный COM-порт недоступен', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
       end
  // ----------------------------------------------
}
  ComSettingsActualization();
// _____________________________________________________________________________
  if self.ComboboxCOMPORT.text='' then begin MessageBox(handle,'Не выбран COM-порт','Ошибка',MB_ICONEXCLAMATION+MB_OK);exit;end;
// _____________________________________________________________________________


if UpperCase(ButtonConnect.Caption)='CONNECT'
then begin
       Button13Click(Sender);
       Button14Click(Sender);

     if m_prot<>nil
        then begin
        m_prot.mf_StopService();
        m_prot.Free();
        m_prot:=nil;
        end;


   // _____________________________________________________________________________
   if (not ComPortAvailable(PCHAR('\\.\'+ComboboxCOMPORT.text))) then begin messageBox(handle,'Выбранный COM-порт недоступен', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);exit;end;
   // _____________________________________________________________________________



    m_prot:=CMain_Thread.Create();

    // ________________________________

    // ________________________________

   if (not m_prot.mf_StartService(Port1Settings))
   then begin
        m_prot.Free();
        m_prot:=nil;
        MessageBox(handle,'Порт не открыт','Обмена не будет',MB_ICONEXCLAMATION+MB_OK);
        end
   else begin
        m_prot.Resume;

        ButtonConnect.Caption:='STOP';
        end;
    end
else begin
     ButtonConnect.Caption:='Connect';
     if m_prot<>nil
     then begin
        m_prot.mf_StopService();
        m_prot.Free();
        m_prot:=nil;
        end;
     end;





end;

procedure TMainForm.BitBtnRefreshcomportClick(Sender: TObject);
begin
  self._REFRESHCOMPORTS;
end;




procedure TMainForm._REFRESHCOMPORTS();
var
  reg : TRegistry;
  ts : TStrings;
  i : integer;

  _tempTXT:string;
  _tempTXT2:string;

begin
  _tempTXT:= ComboboxCOMPORT.Text;


  ComboboxCOMPORT.Clear;
  ComboboxCOMPORT.Text:=_tempTXT;



  reg := TRegistry.Create;
  reg.RootKey := HKEY_LOCAL_MACHINE;
  reg.OpenKey('hardware\devicemap\serialcomm',
              false);
  ts := TStringList.Create;
  reg.GetValueNames(ts);
  for i := 0 to ts.Count -1 do begin
    ComboboxCOMPORT.Items.add(reg.ReadString(ts.Strings[i]));


  end;
  ts.Free;
  reg.CloseKey;
  reg.free;
end;
// ====================================================

procedure TMainForm.ComSettingsActualization();
var
    br:TBaudRate;

begin


  Port1Settings.Port:=ComboboxComport.Text;


  case RadioGroupBaudrate.ItemIndex of
  0:   begin br:=cbr9600;      end;
  1:   begin br:=cbr19200;     end;
  2:   begin br:=cbr38400;     end;
  3:  begin br:=cbr57600;     end;
  4:  begin br:=cbr115200;    end;
  5:  begin br:=cbr921600;    end;

  else begin br:=cbr9600;      end;
  end;
  Port1Settings.BaudRate:=br;



  Port1Settings.DataBits:=da8;
  Port1Settings.Parity:=paNone;
  Port1Settings.StopBits:=sb1_0;




  OSDP_ADDR := strtoint(EditADDR.Text);



end;

procedure TMainForm.Button1Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;

begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;

  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_POLL(OSDP_ADDR,sqn+CTRL_MASK_CRC16,p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;

function TMainForm.GetADDRGetSQN():boolean;//1 - хорошо 0 -  плохо
var err:integer;
    f:integer;

begin
//
  result:=true;

  val(EditAddr.Text,f,err);

  if err<>0 then begin result:=false; end;
  if ((f<0)or(f>$7F)) then begin  result:=false; end;

  OSDP_ADDR:=f;

  sqn:=updown2.Position;

end;

procedure TMainForm.Button13Click(Sender: TObject);
begin
  memo1.Clear;
end;

procedure TMainForm.Button14Click(Sender: TObject);
begin
  memo2.Clear;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;

begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;

  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_ID(OSDP_ADDR,sqn+CTRL_MASK_CRC16,p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;

procedure TMainForm.Button3Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;

begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;

  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_CAP(OSDP_ADDR,sqn+CTRL_MASK_CRC16,p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;


procedure TMainForm.Button4Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;

begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;

  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_LSTAT(OSDP_ADDR,sqn+CTRL_MASK_CRC16,p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;

procedure TMainForm.Button5Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;

begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;

  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_ISTAT(OSDP_ADDR,sqn+CTRL_MASK_CRC16,p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;


procedure TMainForm.Button6Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;

begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;

  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_OSTAT(OSDP_ADDR,sqn+CTRL_MASK_CRC16,p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;


procedure TMainForm.Button7Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;

begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;

  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_RSTAT(OSDP_ADDR,sqn+CTRL_MASK_CRC16,p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;


procedure TMainForm.Button8Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;
    b:array[0..11] of byte;
    timer:word;

    f:integer;
    err:integer;


begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;

  val(edit13.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильный номер считывателя', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[0]:=f;

  val(edit14.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильный номер светодиода', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[1]:=f;

  // temporary
  b[2]:=combobox2.ItemIndex;

  val(edit16.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильное ON time', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[3]:=f;

  val(edit17.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильное OFF time', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[4]:=f;

  b[5]:=combobox4.ItemIndex;
  b[6]:=combobox5.ItemIndex;

  val(edit15.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильный таймер', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  Timer:=f;

  // permanent
  b[7]:=combobox3.ItemIndex;

  val(edit18.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильное ON time', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[8]:=f;

  val(edit19.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильное OFF time', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[9]:=f;

  b[10]:=combobox6.ItemIndex;
  b[11]:=combobox7.ItemIndex;



  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_LED(OSDP_ADDR,sqn+CTRL_MASK_CRC16,b[0],b[1],b[2],b[3],b[4],b[5],b[6],Timer,b[7],b[8],b[9],b[10],b[11],p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;

procedure TMainForm.Button9Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;

    f:integer;
    err:integer;

    b:array[0..4] of byte;

begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;

  val(edit8.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильный номер считывателя', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[0]:=f;

  val(edit9.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильная тональность', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[1]:=f;

  val(edit10.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильное ON time', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[2]:=f;

  val(edit11.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильное OFF time', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[3]:=f;

  val(edit12.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильное количество повторов', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[4]:=f;


  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_BUZ(OSDP_ADDR,sqn+CTRL_MASK_CRC16,b[0],b[1],b[2],b[3],b[4],p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;


procedure TMainForm.Button10Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;

    f:integer;
    err:integer;

    year:word;
    month,day,hours,minutes,seconds:byte;

begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;



  val(edit8.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильный год', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  year:=f;

  month:=updown4.Position;
  day:=updown5.Position;
  hours:=updown6.Position;
  minutes:=updown7.Position;
  seconds:=updown8.Position;



  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_TDSET(OSDP_ADDR,sqn+CTRL_MASK_CRC16,year,month,day,hours,minutes,seconds,p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;


procedure TMainForm.Button11Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;

    n_addr:byte;
    n_baudrate:dword;

    f:integer;
    err:integer;

begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  // =====
  val(edit1.Text,f,err);
  if (err<>0)then begin messageBox(handle,'Неправильный новый адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit;  end;
  n_addr:=f;
  // =====
  n_baudrate:=strtoint(combobox1.text);
  // =====

  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_COMSET(OSDP_ADDR,sqn+CTRL_MASK_CRC16,n_addr,n_baudrate,p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;


procedure TMainForm.Button12Click(Sender: TObject);
begin
  GetNowTime_FillEdits();
end;

procedure TMainForm.Button15Click(Sender: TObject);
var dw:DWORD;
    OK:boolean;
    werr:word;

    p:array[0..512] of byte;
    b:array[0..11] of byte;
    timer:word;

    f:integer;
    err:integer;

    
begin
//
// _____________________________________________________________________________
  if m_prot=nil then begin exit;end;
  if not m_prot.m_osdp.Started then exit;
// _____________________________________________________________________________


  if not GetADDRGetSQN() then begin messageBox(handle,'Неправильный адрес', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;

  val(edit20.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильный номер канала', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  b[0]:=f;

  // control code
  b[1]:=combobox8.ItemIndex;

  val(edit21.Text,f,err);
  if (err<>0) then begin messageBox(handle,'Неправильный таймер', 'Ошибка',MB_OK+MB_ICONEXCLAMATION); exit; end;
  Timer:=f;




  (Sender as TButton).Enabled:=false;

  self.m_prot.Disable_RX:=true;
  sleep(SLEEP_WAIT_THREAD);

  werr:=m_prot.m_osdp.client_osdp_OUT(OSDP_ADDR,sqn+CTRL_MASK_CRC16,b[0],b[1],Timer,p);

  /////////showmessage(inttostr(werr));

  OK:=(werr=ERR_OK);
  self.m_prot.Disable_RX:=false;
  if (not OK)
    then begin
               //messageBox(handle,'Команда не записана', 'Ошибка',MB_OK+MB_ICONEXCLAMATION);
               INFO('Команда не записана',MB_ICONEXCLAMATION);
         end
    else begin
               //messagebox(handle,'Команда записана','OK',MB_OK+MB_ICONINFORMATION);
               INFO('Команда записана',MB_ICONINFORMATION);
         end;

  (Sender as TButton).Enabled:=true;

// ***
end;


procedure TMainForm.Panel6MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

begin
{
  if (ssShift in Shift) then
  begin
    button17.Visible := not button17.Visible;
    edit22.Visible := not edit22.Visible;


    Button18MFG.Visible:= not Button18MFG.Visible;

  end;
  }

end;

end.

