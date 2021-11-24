unit osdp_client;

interface
uses Windows,Classes,syncobjs,com_32m, variables,crc16_osdp, forms,SysUtils, dialogs;

const	ERR_OK        = 0;   // OK
const	ERR_TIMEOUT   = 1;   // TIMEOUT
const	ERR_INV_RESP  = 2;   // Invalid Response
const	ERR_CRC       = 3;   // CRC Error
const	ERR_WR_PORT   = 8;   // Write Comm Error
const	ERR_RD_PORT   = 9;   // Read Comm Error
const	ERR_NOT_INT   = 10;  // Open Comm error






const COUNT_OF_REPEAT=1;



const CMD_POSITION = 5;


type COSDPClient = class
    protected

        m_terminated:boolean;
        m_com:TCom_32;
        m_dwSilentInterval:DWORD;
        m_lTimeOut:DWORD;
        m_sect:TCriticalSection;
        m_comsect:TCriticalSection;
        m_tx,m_rx:DWORD;
        function mf_SendGetPack(var buf:array of byte; var lng:integer):WORD;

        function client_osdp_simple_concept_command(cmd:byte;Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;

    private
    public
        constructor Create();
        destructor Destroy();override;
        function mf_StartService(ps:TComSettings):boolean;
        //function mf_StartService(portname:string):boolean; 
        procedure mf_StopService();
        function Started():boolean;
        function GetTXTR(var tx:DWORD; var rx:DWORD):boolean;
        // return ERR_XXX Code
        // function mb_LoopbackTest(nAddr:WORD):WORD;



	      function client_osdp_POLL(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
	      function client_osdp_ID(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
	      function client_osdp_CAP(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
	      function client_osdp_LSTAT(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
	      function client_osdp_ISTAT(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
	      function client_osdp_OSTAT(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
	      function client_osdp_RSTAT(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
	      function client_osdp_LED(Addr:byte;CTRL:byte;Reader_Num:byte;LED_Num:byte;Temp_mode:byte;Temp_ON_time:byte;Temp_OFF_time:byte;Temp_ON_color:byte;Temp_OFF_color:byte;Temp_timer:word;Perm_mode:byte;Perm_ON_time:byte;Perm_OFF_time:byte;Perm_ON_color:byte;Perm_OFF_color:byte; var anRegValues:array of byte):WORD;
       	function client_osdp_BUZ(Addr:byte;CTRL:byte;Reader_Num:byte;Tone:byte;ON_time:byte;OFF_time:byte;count:byte;var anRegValues:array of byte):WORD;
	      function client_osdp_TDSET(Addr:byte;CTRL:byte;year:word;month:byte;day:byte;hour:byte;minute:byte;second:byte;var anRegValues:array of byte):WORD;
	      function client_osdp_COMSET(Addr:byte;CTRL:byte;new_Addr:byte;new_baudrate:longword;var anRegValues:array of byte):WORD;


	      function client_osdp_OUT(Addr:byte;CTRL:byte;OUT_Num:byte;Control_Code:byte;Timer:word; var anRegValues:array of byte):WORD;


        function client_osdp_MFG(Addr:byte;CTRL:byte;VENDOR:DWORD;SubCMD:byte;buf:array of byte;buflen:word;var anRegValues:array of byte):WORD;

        function DetectOSDPCommand(inputCMD:byte):string;

end;

const SOM = $53; // Start of Message

const REPLY_ADDICTION = $80; //

const CTRL_MASK_CRC16 = $04;

// Commands

const osdp_POLL     = $60;
const osdp_ID       = $61;//  ID Report Request  Id type
const osdp_CAP      = $62;//  PD Capabilities Request  Reply type
const osdp_DIAG     = $63;//  Diagnostic Function Command  Request code
const osdp_LSTAT    = $64;//  Local Status Report Request  None
const osdp_ISTAT    = $65;//  Input Status Report Request  None
const osdp_OSTAT    = $66;//  Output Status Report Request  None
const osdp_RSTAT    = $67;//  Reader Status Report Request  None
const osdp_OUT      = $68;//  Output Control Command  Output settings
const osdp_LED      = $69;//  Reader Led Control Command  LED settings
const osdp_BUZ      = $6A;//  Reader Buzzer Control Command  Buzzer settings
const osdp_TEXT     = $6B;//  Text Output Command  Text settings
const osdp_RMODE    = $6C;//  … removed …
const osdp_TDSET    = $6D;//  Time and Date Command  Time and Date
const osdp_COMSET   = $6E;//  PD Communication Configuration Command  Com settings
const osdp_DATA     = $6F;//  Data Transfer Command  Raw Data
const osdp_XMIT     = $70;//  … removed …
const osdp_PROMPT   = $71;//  Set Automatic Reader Prompt Strings  Message string
const osdp_SPE      = $72;//  … removed …
const osdp_BIOREAD  = $73;//  Scan and Send Biometric Data  Requested Return
const osdp_BIOMATCH = $74;//  Scan and Match Biometric Template  Biometric Template
const osdp_KEYSET   = $75;//  Encryption Key Set Command  Encryption Key
const osdp_CHLNG    = $76;//  Challenge and Secure Session Initialization Rq.  Challenge Data
const osdp_SCRYPT   = $77;//  Server Cryptogram  Encryption Data
const osdp_CONT     = $79;//  Continue Sending Multi-Part Message  None
const osdp_MFG      = $80;//  Manufacturer Specific Command  Any
const osdp_SCDONE   = $A0;//  … removed …
const osdp_XWR      = $A1;//  See appendix  Defined in Appendix E


// Custom Command
const CUSTOM_osdp_BOOTLOADER     = $EE;
const CUSTOM_osdp_SERIAL         = $ED;



// Replies
const osdp_ACK      = $40;//  Command accepted, nothing else to report  None
const osdp_NAK      = $41;//  Command not processed  Reason for rejecting command
const osdp_PDID     = $45;//  PD ID Report  Report data
const osdp_PDCAP    = $46;//  PD Capabilities Report  Report data
const osdp_LSTATR   = $48;//  Local Status Report  Report data
const osdp_ISTATR   = $49;//  Input Status Report  Report data
const osdp_OSTATR   = $4A;//  Output Status Report  Report data
const osdp_RSTATR   = $4B;//  Reader Status Report  Report data
const osdp_RAW      = $50;//  Reader Data – Raw bit image of card data  Card data
const osdp_FMT      = $51;//  Reader Data – Formatted character stream  Card data
const osdp_PRES     = $52;//  … removed …
const osdp_KPD      = $53;//  Keypad Data  Keypad data
const osdp_COM      = $54;//  PD Communications Configuration Report  Comm data
const osdp_SCREP    = $55;//  … removed …
const osdp_SPER     = $56;//  … removed …
const osdp_BIOREADR = $57;//  Biometric Data  Biometric data
const osdp_FPMATCHR = $58;//  Biometric Match Result  Result
const osdp_CCRYPT   = $76;//  Client's ID, Random Number, and Cryptogram  Encryption Data
const osdp_RMACI    = $78;//  Initial R-MAC  Encryption Data
const osdp_MFGREP   = $90;//  Manufacturer Specific Reply  Any
const osdp_BUSY     = $79;//  PD is Busy reply
const osdp_XRD      = $B1;//  See appendix  Defined in Appendix E

// MFG DEFINED  SUBCOMMAND
const osdp_MFG_Command_ID_Read_KeyCalib  = $01;
const osdp_MFG_Command_ID_Write_KeyCalib = $02;
const osdp_MFG_Command_ID_GetPollCounter = $03;
const osdp_MFG_Command_ID_Read_ConfigAP  = $04;
const osdp_MFG_Command_ID_Write_ConfigAP = $05;

var OSDP_ADDR:byte=0;
    SQN:byte=0;

implementation

uses  mainformunit;

// Detecting osdp command 
function COSDPClient.DetectOSDPCommand(inputCMD:byte):string;
begin
// -----------------------------------------------------------------------------
  result:='';

  case inputCMD of
  // replies
  osdp_ACK:result:='osdp_ACK';
  osdp_NAK:result:='osdp_NAK';
  osdp_PDID:result:='osdp_PDID';
  osdp_PDCAP:result:='osdp_PDCAP';
  osdp_LSTATR:result:='osdp_LSTATR';
  osdp_ISTATR:result:='osdp_ISTATR';
  osdp_OSTATR:result:='osdp_OSTATR';
  osdp_RSTATR:result:='osdp_RSTATR';
  osdp_RAW:result:='osdp_RAW';
  osdp_FMT:result:='osdp_FMT';
  osdp_PRES:result:='osdp_PRES';
  osdp_KPD:result:='osdp_KPD';
  osdp_COM:result:='osdp_COM';
  osdp_SCREP:result:='osdp_SCREP';
  osdp_SPER:result:='osdp_SPER';
  osdp_BIOREADR:result:='osdp_BIOREADR';
  osdp_FPMATCHR:result:='osdp_FPMATCHR';
  osdp_CCRYPT:result:='osdp_CCRYPT or osdp_CHLNG';
  osdp_RMACI:result:='osdp_RMACI';
  osdp_MFGREP:result:='osdp_MFGREP';
  osdp_BUSY:result:='osdp_BUSY or osdp_CONT';
  osdp_XRD:result:='osdp_XRD';
  // commands
  osdp_POLL:result:='osdp_POLL';
  osdp_ID:result:='osdp_ID';
  osdp_CAP:result:='osdp_CAP';
  osdp_DIAG:result:='osdp_DIAG';
  osdp_LSTAT:result:='osdp_LSTAT';
  osdp_ISTAT:result:='osdp_ISTAT';
  osdp_OSTAT:result:='osdp_OSTAT';
  osdp_RSTAT:result:='osdp_RSTAT';
  osdp_OUT:result:='osdp_OUT';
  osdp_LED:result:='osdp_LED';
  osdp_BUZ:result:='osdp_BUZ';
  osdp_TEXT:result:='osdp_TEXT';
  osdp_RMODE:result:='osdp_RMODE';
  osdp_TDSET:result:='osdp_TDSET';
  osdp_COMSET:result:='osdp_COMSET';
  osdp_DATA:result:='osdp_DATA';
  osdp_XMIT:result:='osdp_XMIT';
  osdp_PROMPT:result:='osdp_PROMPT';
  osdp_SPE:result:='osdp_SPE';
  osdp_BIOREAD:result:='osdp_BIOREAD';
  osdp_BIOMATCH:result:='osdp_BIOMATCH';
  osdp_KEYSET:result:='osdp_KEYSET';
  //osdp_CHLNG:result:='osdp_CHLNG';
  osdp_SCRYPT:result:='osdp_SCRYPT';
  //osdp_CONT:result:='osdp_CONT';
  osdp_MFG:result:='osdp_MFG';
  osdp_SCDONE:result:='osdp_SCDONE';
  osdp_XWR:result:='osdp_XWR';

  else begin result:=''; end;
  end;
end;


function COSDPClient.mf_SendGetPack(var buf:array of byte;var lng:integer):WORD;
var crc16:word;
    dw:DWORD;
    buf_ptr:integer;


begin
        result:=ERR_NOT_INT;
   
        crc16:=Calc_CRC16_OSDP(buf,lng-2);
        buf[lng-2]:=LOBYTE(crc16);
        buf[lng-1]:=HIBYTE(crc16);
        //Block resource;
        m_comsect.Enter();
        if (Started()) and (not m_terminated)
        then begin

                move(buf[0],buf[1],lng);
                buf[0]:=$FF;
                inc(lng);

                mainform.FillHexMemo(mainform.Memo1,buf,lng,1);

                inc(m_tx);

                PurgeComm(m_Com.fHandle,(PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR));


                m_com.Write(buf,lng);

                lng:=0;

                result:=ERR_TIMEOUT; sleep(10);
                dw:=GetTickCount();





                //SetCommTimeouts(m_com.fhandle,cto_rx);
                while (m_com.InQueCount()=0) and (not m_terminated) and ((GetTickCount()-dw)<m_lTimeOut) do sleep(1);
                if (m_com.InQueCount()<>0)
                then begin
                     result:=ERR_RD_PORT;
                     lng:=m_com.Read(buf,512);
                     end;


                buf_ptr:=0;
                //if buf[0]=$FF then cmd_pos:=1;

                while (buf[buf_ptr]=$FF) and (lng > 0) do
                begin
                  inc(buf_ptr);
                  dec(lng);
                end;



                if lng<>0 then
                mainform.FillHexMemo(mainform.Memo2,buf,lng+buf_ptr,buf_ptr);

                if (lng>=7) and (not m_terminated)
                then begin
                        result:=ERR_CRC;

                        if (buf_ptr <> 0) then begin
                                              move(buf[buf_ptr],buf[0],lng);
                                            end;





                        crc16:=(buf[lng-1] shl 8) or buf[lng-2];
                        //showmessage(inttohex(crc16,2));
                        //showmessage(inttohex(Calc_CRC16_OSDP(AOFB(dword(@buf)+1),lng-2-buf_ptr),2));
                        //showmessage(inttohex(DWORD(@buf[0]),2));
                        //showmessage(inttohex(DWORD(@buf[1]),2));

                        //showmessage(inttohex(Calc_CRC16_OSDP(buf,lng-2),2));

                        if (crc16=Calc_CRC16_OSDP(buf,lng-2))
                        then begin
                                lng:=lng-2;
                                result:=ERR_OK;
                                inc(m_rx);
                        end;
                end;

             end;

        m_comsect.Leave();
end;



constructor COSDPClient.Create();
begin
        inherited Create();
        m_tx:=0;m_rx:=0;
        m_com:=TCom_32.Create(nil);
        m_comsect:=TCriticalSection.Create;
        m_sect:=TCriticalSection.Create;
        m_terminated:=true;
        m_dwSilentInterval:=50;
        //m_lTimeOut:=1000;
        //m_lTimeOut:=50;
        // m_lTimeOut:=500;
        m_lTimeOut:=200;
end;



destructor COSDPClient.Destroy();
begin
        mf_StopService();
        m_com.Free();
        m_sect.Free();
        m_comsect.Free();
        inherited Destroy;
end;



function COSDPClient.GetTXTR(var tx:DWORD; var rx:DWORD):boolean;
begin
        m_comsect.Enter();
        tx:=m_tx;rx:=m_rx;
        m_comsect.Leave();
        result:=true;
end;


function COSDPClient.mf_StartService(ps:TComSettings):boolean;
var dwSilentInterval:DWORD;
    dcb:TDCB;
    par:single;
    cto:COMMTIMEOUTS;
begin
        if (Started()) then mf_StopService();
        m_com.DeviceName:=ps.Port;
         m_com.BaudRate:=ps.BaudRate;


        m_com.Parity:=paNone;
        m_com.Stopbits:=sb1_0;
        m_com.Databits:=da8;

        m_com.Open();
        if (not Started()) then begin result:=false;exit;end;

        GetCommState(m_com.fhandle,dcb);
        par:=dcb.ByteSize;
        dwSilentInterval := round(((par+4.0)*4.0*1000.0)/(dcb.BaudRate))+1;
        if (dwSilentInterval>m_dwSilentInterval) then m_dwSilentInterval:=dwSilentInterval;
        GetCommTimeouts(m_com.fhandle,cto);
        cto.ReadIntervalTimeout:=m_dwSilentInterval;//Max Char Interval
        cto.ReadTotalTimeoutMultiplier:=round(((par+4.0)*(1.0)*1000.0)/(dcb.BaudRate));
        if (cto.ReadTotalTimeoutMultiplier<=0)then cto.ReadTotalTimeoutMultiplier:=1;
	cto.ReadTotalTimeoutConstant:=m_lTimeOut;
	cto.WriteTotalTimeoutMultiplier:=m_dwSilentInterval;
	cto.WriteTotalTimeoutConstant:=m_lTimeOut;
        SetCommTimeouts(m_com.fhandle,cto);
        m_terminated:=false;
        result:=true;
end;



procedure COSDPClient.mf_StopService();
begin
        m_terminated:=true;
        PurgeComm(m_Com.fHandle,(PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR));
        m_com.Close();
end;


function COSDPClient.Started():boolean;
begin
        result:=m_com.Enabled();
end;



// -----------------------------------------------------------------------------
//                        simple concept
// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_simple_concept_command(cmd:byte;Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
var abyQuery:array[0..511] of byte;
    nReplyLength:word;
    iRetry:longint;
    QUERY_LENGHT:integer;
    iii:integer;
begin
        QUERY_LENGHT:=8;

        result:=ERR_INV_RESP;
        iRetry:=0;

        while ((iRetry<COUNT_OF_REPEAT)and(ERR_OK<>result))do
        begin

          //osdp message
	        abyQuery[0]:=SOM;
	        abyQuery[1]:=Addr;
	        abyQuery[2]:=LOBYTE(QUERY_LENGHT);
	        abyQuery[3]:=HIBYTE(QUERY_LENGHT);
	        abyQuery[4]:=CTRL;
	        abyQuery[5]:=CMD;

          result:=mf_SendGetPack(abyQuery,QUERY_LENGHT);

          if (result=ERR_OK) then
          begin
			      if ((abyQuery[0]<>SOM)or(abyQuery[1]<>(Addr+REPLY_ADDICTION)))
            then begin result:=ERR_INV_RESP;exit;end
			      else begin
	                 nReplyLength:= ((abyQuery[3] shl 8) + abyQuery[2]);

                   for iii:=0 to nReplyLength do
	                 begin
                     anRegValues[iii] := abyQuery[iii];
				           end;

			           end;
	   	    end;// if (result=ERR_OK)
	     	 inc(iRetry);
	     end;// while
end;
// -----------------------------------------------------------------------------





// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_POLL(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
var CMD:byte;
begin
        CMD:=osdp_POLL;
        result:=self.client_osdp_simple_concept_command(CMD,Addr,CTRL,anRegValues);
end;
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_ID(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
var abyQuery:array[0..511] of byte;
    nReplyLength:word;
    nRespByte:longint;
    iRetry:longint;
    QUERY_LENGHT,CMD:integer;
    iii:integer;
begin
        QUERY_LENGHT:=9;
        CMD:=osdp_ID;

        result:=ERR_INV_RESP;
        iRetry:=0;

        while ((iRetry<COUNT_OF_REPEAT)and(ERR_OK<>result))do
        begin

          //osdp message
	        abyQuery[0]:=SOM;
	        abyQuery[1]:=Addr;
	        abyQuery[2]:=LOBYTE(QUERY_LENGHT);
	        abyQuery[3]:=HIBYTE(QUERY_LENGHT);
	        abyQuery[4]:=CTRL;
	        abyQuery[5]:=CMD;
          abyQuery[6]:=0;

          result:=mf_SendGetPack(abyQuery,QUERY_LENGHT);

          if (result=ERR_OK) then
          begin
			      if ((abyQuery[0]<>SOM)or(abyQuery[1]<>(Addr+REPLY_ADDICTION)))
            then begin result:=ERR_INV_RESP;exit;end
			      else begin
	                 nReplyLength:= ((abyQuery[3] shl 8) + abyQuery[2]);

                   for iii:=0 to nReplyLength do
	                 begin
                     anRegValues[iii] := abyQuery[iii];
				           end;

			           end;
	   	    end;// if (result=ERR_OK)
	     	 inc(iRetry);
	     end;// while
end;

// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_CAP(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
var abyQuery:array[0..511] of byte;
    nReplyLength:word;
    nRespByte:longint;
    iRetry:longint;
    QUERY_LENGHT,CMD:integer;
    iii:integer;
begin
        QUERY_LENGHT:=9;
        CMD:=osdp_CAP;

        result:=ERR_INV_RESP;
        iRetry:=0;

        while ((iRetry<COUNT_OF_REPEAT)and(ERR_OK<>result))do
        begin

          //osdp message
	        abyQuery[0]:=SOM;
	        abyQuery[1]:=Addr;
	        abyQuery[2]:=LOBYTE(QUERY_LENGHT);
	        abyQuery[3]:=HIBYTE(QUERY_LENGHT);
	        abyQuery[4]:=CTRL;
	        abyQuery[5]:=CMD;
	        abyQuery[6]:=0;

          result:=mf_SendGetPack(abyQuery,QUERY_LENGHT);

          if (result=ERR_OK) then
          begin
			      if ((abyQuery[0]<>SOM)or(abyQuery[1]<>(Addr+REPLY_ADDICTION)))
            then begin result:=ERR_INV_RESP;exit;end
			      else begin
	                 nReplyLength:= ((abyQuery[3] shl 8) + abyQuery[2]);

                   for iii:=0 to nReplyLength do
	                 begin
                     anRegValues[iii] := abyQuery[iii];
				           end;

			           end;
	   	    end;// if (result=ERR_OK)
	     	 inc(iRetry);
	     end;// while
end;
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_LSTAT(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
var CMD:byte;
begin
        CMD:=osdp_LSTAT;
        result:=self.client_osdp_simple_concept_command(CMD,Addr,CTRL,anRegValues);
end;
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_ISTAT(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
var CMD:byte;
begin
        CMD:=osdp_ISTAT;
        result:=self.client_osdp_simple_concept_command(CMD,Addr,CTRL,anRegValues);
end;
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_OSTAT(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
var CMD:byte;
begin
        CMD:=osdp_OSTAT;
        result:=self.client_osdp_simple_concept_command(CMD,Addr,CTRL,anRegValues);
end;
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_RSTAT(Addr:byte;CTRL:byte;var anRegValues:array of byte):WORD;
var CMD:byte;
begin
        CMD:=osdp_RSTAT;
        result:=self.client_osdp_simple_concept_command(CMD,Addr,CTRL,anRegValues);
end;
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_LED(Addr:byte;CTRL:byte;Reader_Num:byte;LED_Num:byte;Temp_mode:byte;Temp_ON_time:byte;Temp_OFF_time:byte;Temp_ON_color:byte;Temp_OFF_color:byte;Temp_timer:word;Perm_mode:byte;Perm_ON_time:byte;Perm_OFF_time:byte;Perm_ON_color:byte;Perm_OFF_color:byte; var anRegValues:array of byte):WORD;
var abyQuery:array[0..511] of byte;
    nReplyLength:word;
    nRespByte:longint;
    iRetry:longint;
    QUERY_LENGHT,CMD:integer;
    iii:integer;
begin
        QUERY_LENGHT:=$16;
        CMD:=osdp_LED;

        result:=ERR_INV_RESP;
        iRetry:=0;

        while ((iRetry<COUNT_OF_REPEAT)and(ERR_OK<>result))do
        begin

          //osdp message
	        abyQuery[0]:=SOM;
	        abyQuery[1]:=Addr;
	        abyQuery[2]:=LOBYTE(QUERY_LENGHT);
	        abyQuery[3]:=HIBYTE(QUERY_LENGHT);
	        abyQuery[4]:=CTRL;
	        abyQuery[5]:=CMD;
          abyQuery[6]:=Reader_Num;
          abyQuery[7]:=LED_Num;
          abyQuery[8]:=Temp_mode;
          abyQuery[9]:=Temp_ON_time;
          abyQuery[10]:=Temp_OFF_time;
          abyQuery[11]:=Temp_ON_color;
          abyQuery[12]:=Temp_OFF_color;
          abyQuery[13]:=LOBYTE(Temp_timer);
          abyQuery[14]:=HIBYTE(Temp_timer);
          abyQuery[15]:=Perm_mode;
          abyQuery[16]:=Perm_ON_time;
          abyQuery[17]:=Perm_OFF_time;
          abyQuery[18]:=Perm_ON_color;
          abyQuery[19]:=Perm_OFF_color;






          result:=mf_SendGetPack(abyQuery,QUERY_LENGHT);

          if (result=ERR_OK) then
          begin
			      if ((abyQuery[0]<>SOM)or(abyQuery[1]<>(Addr+REPLY_ADDICTION)))
            then begin result:=ERR_INV_RESP;exit;end
			      else begin
	                 nReplyLength:= ((abyQuery[3] shl 8) + abyQuery[2]);

                   for iii:=0 to nReplyLength do
	                 begin
                     anRegValues[iii] := abyQuery[iii];
				           end;

			           end;
	   	    end;// if (result=ERR_OK)
	     	 inc(iRetry);
	     end;// while
end;
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_BUZ(Addr:byte;CTRL:byte;Reader_Num:byte;Tone:byte;ON_time:byte;OFF_time:byte;count:byte;var anRegValues:array of byte):WORD;
var abyQuery:array[0..511] of byte;
    nReplyLength:word;
    nRespByte:longint;
    iRetry:longint;
    QUERY_LENGHT,CMD:integer;
    iii:integer;
begin
        QUERY_LENGHT:=$0D;
        CMD:=osdp_BUZ;

        result:=ERR_INV_RESP;
        iRetry:=0;

        while ((iRetry<COUNT_OF_REPEAT)and(ERR_OK<>result))do
        begin

          //osdp message
	        abyQuery[0]:=SOM;
	        abyQuery[1]:=Addr;
	        abyQuery[2]:=LOBYTE(QUERY_LENGHT);
	        abyQuery[3]:=HIBYTE(QUERY_LENGHT);
	        abyQuery[4]:=CTRL;
	        abyQuery[5]:=CMD;
	        abyQuery[6]:=Reader_Num;
	        abyQuery[7]:=Tone;
	        abyQuery[8]:=ON_time;
	        abyQuery[9]:=OFF_time;
	        abyQuery[10]:=count;

          result:=mf_SendGetPack(abyQuery,QUERY_LENGHT);

          if (result=ERR_OK) then
          begin
			      if ((abyQuery[0]<>SOM)or(abyQuery[1]<>(Addr+REPLY_ADDICTION)))
            then begin result:=ERR_INV_RESP;exit;end
			      else begin
	                 nReplyLength:= ((abyQuery[3] shl 8) + abyQuery[2]);

                   for iii:=0 to nReplyLength do
	                 begin
                     anRegValues[iii] := abyQuery[iii];
				           end;

			           end;
	   	    end;// if (result=ERR_OK)
	     	 inc(iRetry);
	     end;// while
end;
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_TDSET(Addr:byte;CTRL:byte;year:word;month:byte;day:byte;hour:byte;minute:byte;second:byte;var anRegValues:array of byte):WORD;
var abyQuery:array[0..511] of byte;
    nReplyLength:word;
    nRespByte:longint;
    iRetry:longint;
    QUERY_LENGHT,CMD:integer;
    iii:integer;
begin
        QUERY_LENGHT:=$0F;
        CMD:=osdp_TDSET;

        result:=ERR_INV_RESP;
        iRetry:=0;

        while ((iRetry<COUNT_OF_REPEAT)and(ERR_OK<>result))do
        begin

          //osdp message
	        abyQuery[0]:=SOM;
	        abyQuery[1]:=Addr;
	        abyQuery[2]:=LOBYTE(QUERY_LENGHT);
	        abyQuery[3]:=HIBYTE(QUERY_LENGHT);
	        abyQuery[4]:=CTRL;
	        abyQuery[5]:=CMD;
	        abyQuery[6]:=LOBYTE(year);
	        abyQuery[7]:=HIBYTE(year);
	        abyQuery[8]:=month;
	        abyQuery[9]:=day;
	        abyQuery[10]:=hour;
	        abyQuery[11]:=minute;
	        abyQuery[12]:=second;

          result:=mf_SendGetPack(abyQuery,QUERY_LENGHT);

          if (result=ERR_OK) then
          begin
			      if ((abyQuery[0]<>SOM)or(abyQuery[1]<>(Addr+REPLY_ADDICTION)))
            then begin result:=ERR_INV_RESP;exit;end
			      else begin
	                 nReplyLength:= ((abyQuery[3] shl 8) + abyQuery[2]);

                   for iii:=0 to nReplyLength do
	                 begin
                     anRegValues[iii] := abyQuery[iii];
				           end;

			           end;
	   	    end;// if (result=ERR_OK)
	     	 inc(iRetry);
	     end;// while
end;
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
function COSDPClient.client_osdp_COMSET(Addr:byte;CTRL:byte;new_Addr:byte;new_baudrate:longword;var anRegValues:array of byte):WORD;
var abyQuery:array[0..511] of byte;
    nReplyLength:word;
    nRespByte:longint;
    iRetry:longint;
    QUERY_LENGHT,CMD:integer;
    iii:integer;
begin
        QUERY_LENGHT:=$0D;
        CMD:=osdp_COMSET;

        result:=ERR_INV_RESP;
        iRetry:=0;

        while ((iRetry<COUNT_OF_REPEAT)and(ERR_OK<>result))do
        begin

          //osdp message
	        abyQuery[0]:=SOM;
	        abyQuery[1]:=Addr;
	        abyQuery[2]:=LOBYTE(QUERY_LENGHT);
	        abyQuery[3]:=HIBYTE(QUERY_LENGHT);
	        abyQuery[4]:=CTRL;
	        abyQuery[5]:=CMD;
	        abyQuery[6]:=new_Addr;
	        abyQuery[7]:=(new_baudrate  and $000000FF);
	        abyQuery[8]:=(new_baudrate  and $0000FF00) shr 8;
	        abyQuery[9]:=(new_baudrate  and $00FF0000) shr 16;
	        abyQuery[10]:=(new_baudrate and $FF000000) shr 24 ;

          result:=mf_SendGetPack(abyQuery,QUERY_LENGHT);

          if (result=ERR_OK) then
          begin
			      if ((abyQuery[0]<>SOM)or(abyQuery[1]<>(Addr+REPLY_ADDICTION)))
            then begin result:=ERR_INV_RESP;exit;end
			      else begin
	                 nReplyLength:= ((abyQuery[3] shl 8) + abyQuery[2]);

                   for iii:=0 to nReplyLength do
	                 begin
                     anRegValues[iii] := abyQuery[iii];
				           end;

			           end;
	   	    end;// if (result=ERR_OK)
	     	 inc(iRetry);
	     end;// while
end;
// -----------------------------------------------------------------------------


function COSDPClient.client_osdp_OUT(Addr:byte;CTRL:byte;OUT_Num:byte;Control_Code:byte;Timer:word; var anRegValues:array of byte):WORD;
var abyQuery:array[0..511] of byte;
    nReplyLength:word;
    nRespByte:longint;
    iRetry:longint;
    QUERY_LENGHT,CMD:integer;
    iii:integer;
begin
        QUERY_LENGHT:=$C;
        CMD:=osdp_OUT;

        result:=ERR_INV_RESP;
        iRetry:=0;

        while ((iRetry<COUNT_OF_REPEAT)and(ERR_OK<>result))do
        begin

          //osdp message
	        abyQuery[0]:=SOM;
	        abyQuery[1]:=Addr;
	        abyQuery[2]:=LOBYTE(QUERY_LENGHT);
	        abyQuery[3]:=HIBYTE(QUERY_LENGHT);
	        abyQuery[4]:=CTRL;
	        abyQuery[5]:=CMD;
          abyQuery[6]:=OUT_Num;
          abyQuery[7]:=Control_Code;
          abyQuery[8]:=LOBYTE(Timer);
          abyQuery[9]:=HIBYTE(Timer);





          result:=mf_SendGetPack(abyQuery,QUERY_LENGHT);

          if (result=ERR_OK) then
          begin
			      if ((abyQuery[0]<>SOM)or(abyQuery[1]<>(Addr+REPLY_ADDICTION)))
            then begin result:=ERR_INV_RESP;exit;end
			      else begin
	                 nReplyLength:= ((abyQuery[3] shl 8) + abyQuery[2]);

                   for iii:=0 to nReplyLength do
	                 begin
                     anRegValues[iii] := abyQuery[iii];
				           end;

			           end;
	   	    end;// if (result=ERR_OK)
	     	 inc(iRetry);
	     end;// while
end;
// -----------------------------------------------------------------------------











// reserve / unused
function COSDPClient.client_osdp_MFG(Addr:byte;CTRL:byte;VENDOR:DWORD;SubCMD:byte;buf:array of byte;buflen:word;var anRegValues:array of byte):WORD;
var abyQuery:array[0..511] of byte;
    nReplyLength:word;
    nRespByte:longint;
    iRetry:longint;
    QUERY_LENGHT,CMD:integer;
    iii:integer;
begin
        QUERY_LENGHT:=$8 + 4 + buflen;
        CMD:=osdp_MFG;

        result:=ERR_INV_RESP;
        iRetry:=0;

        while ((iRetry<COUNT_OF_REPEAT)and(ERR_OK<>result))do
        begin

          //osdp message
	        abyQuery[0]:=SOM;
	        abyQuery[1]:=Addr;
	        abyQuery[2]:=LOBYTE(QUERY_LENGHT);
	        abyQuery[3]:=HIBYTE(QUERY_LENGHT);
	        abyQuery[4]:=CTRL;
	        abyQuery[5]:=CMD;
          abyQuery[6]:=VENDOR and $000000FF;
          abyQuery[7]:=(VENDOR and $0000FF00) shr 8;
          abyQuery[8]:=(VENDOR and $00FF0000) shr 16;
          abyQuery[9]:=SubCMD;
          move(buf,abyQuery[10],buflen);





          result:=mf_SendGetPack(abyQuery,QUERY_LENGHT);

          if (result=ERR_OK) then
          begin
			      if ((abyQuery[0]<>SOM)or(abyQuery[1]<>(Addr+REPLY_ADDICTION)))
            then begin result:=ERR_INV_RESP;exit;end
			      else begin
	                 nReplyLength:= ((abyQuery[3] shl 8) + abyQuery[2]);

                   for iii:=0 to nReplyLength do
	                 begin
                     anRegValues[iii] := abyQuery[iii];
				           end;

			           end;
	   	    end;// if (result=ERR_OK)
	     	 inc(iRetry);
	     end;// while
end;











end.
