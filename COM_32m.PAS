unit com_32m;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;


type

  TBaudRate = (cbr110, cbr300, cbr600, cbr1200, cbr2400, cbr4800,
	       cbr9600, cbr14400, cbr19200, cbr38400, cbr56000,
	       cbr57600, cbr115200, cbr128000, 
         cbr230400, cbr256000, cbr460800, cbr921600);
  TParity = (paNone,paOdd,paEven,paMark,paSpace);
  TStopbits = (sb1_0,sb1_5,sb2_0);
  TDatabits=(da4, da5, da6, da7, da8);


  TCom_32 = class(TComponent)
  private

    FCT: TComStat;
    FDCB: TDCB;
    FDeviceName: String;
    FBaudRate: TBaudRate;
    FParity: TParity;
    FStopbits: TStopbits;
    FDatabits: TDatabits;
    FReadBufferSize: Integer;
    FWriteBufferSize: Integer;

    procedure SetBaudRate(Value: TBaudRate);
    procedure SetParity(Value: TParity);
    procedure SetStopbits(Value: TStopBits);
    procedure SetDatabits(Value: TDatabits);
  protected
    {Protected declarations}
  public
    FHandle: THandle;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    function Enabled: Boolean;
    function Write(const Buf; Count: Integer): Integer;
    function Read(var Buf; Count: Integer): Integer;
    function InQueCount: Integer;
    function OutQueCount: Integer;
    procedure PurgeIn;
    procedure PurgeOut;
    function DTR(State: Boolean): boolean;
    function RTS(State: Boolean): boolean;
    function BREAK(State: Boolean): boolean;
    function GetCTS:boolean;
    function GetDSR:boolean;
    function GetRI:boolean;
    function GetCD:boolean;

  published
    property DeviceName: string read FDeviceName write FDeviceName;
    property BaudRate: TBaudRate read FBaudRate write SetBaudRate;
    property Parity: TParity read FParity write SetParity;
    property Stopbits: TStopbits read FStopbits write SetStopbits;
    property Databits: TDatabits read FDatabits write SetDatabits;
    property ReadBufferSize: Integer read FReadBufferSize write FReadBufferSize;
    property WriteBufferSize: Integer read FWriteBufferSize write FWriteBufferSize;
  end;


implementation



{TCom_32}
// DONE
constructor TCom_32.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  FHandle := INVALID_HANDLE_VALUE;
  FDeviceName := 'COM1';
  FBaudRate := cbr2400;
  FParity := paNone;
  FStopbits := sb1_0;
  FDatabits := da8;
  FReadBufferSize := 4096;
  FWriteBufferSize := 2048;
end;

destructor TCom_32.Destroy;
begin
  Close;
  Inherited Destroy;
end;

// DONE
function TCom_32.Enabled: Boolean;
begin
  Result := FHandle <> INVALID_HANDLE_VALUE;
end;

// DONE
procedure TCom_32.Open;
var
  CommTimeouts: TCommTimeouts;
begin
  Close;
  FHandle := CreateFile(PChar('\\.\'+FDeviceName), GENERIC_READ or GENERIC_WRITE,0, nil, OPEN_EXISTING, 0, 0);
  if Enabled then
  begin
    SetupComm(FHandle, FReadBufferSize, FWriteBufferSize);

    GetCommTimeOuts(FHandle, CommTimeouts);
    CommTimeouts.ReadIntervalTimeout := 250;
    CommTimeouts.ReadTotalTimeoutMultiplier := 0;
    CommTimeouts.ReadTotalTimeoutConstant := 0;
    CommTimeouts.WriteTotalTimeoutMultiplier := 0;
    CommTimeouts.WriteTotalTimeoutConstant := 0;
    SetCommTimeouts(FHandle, CommTimeouts);

    SetBaudrate(FBaudrate);
    SetParity(FParity);
    SetStopbits(FStopbits);
    SetDatabits(FDatabits);

  end;
end;


// WORK
procedure TCom_32.Close;
begin
  if Enabled then
  begin
    PurgeComm(FHandle, PURGE_RXABORT + PURGE_RXCLEAR);
    CloseHandle(FHandle);
    FHandle := INVALID_HANDLE_VALUE;
  end;
end;

function TCom_32.Write(const Buf; Count: Integer): Integer;
var rez:DWORD;
begin
  if not WriteFile(FHandle, Buf, Count, rez, nil) then Result := -1 else result:=rez;
end;

function TCom_32.Read(var Buf; Count: Integer): Integer;
var rez:DWORD;
begin
  if not ReadFile(FHandle, Buf, Count, rez,nil) then Result := -1 else result:=rez;
end;



// DONE
procedure TCom_32.SetBaudRate(Value: TBaudRate);
const
  CBR: array[TBaudRate] of Integer = (CBR_110, CBR_300, CBR_600, CBR_1200, CBR_2400,
		       CBR_4800, CBR_9600, CBR_14400, CBR_19200, CBR_38400,
		       CBR_56000, CBR_57600, CBR_115200, CBR_128000,
           230400, CBR_256000, 460800, 921600);
begin
  FBaudRate := Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    FDCB.BaudRate := CBR[FBaudRate];
    SetCommState(FHandle, FDCB);
  end;
end;

// DONE
procedure TCom_32.SetParity(Value: TParity);
const
  PAR: array[TParity] of byte = (NOPARITY, ODDPARITY, EVENPARITY,
				 MARKPARITY, SPACEPARITY);
begin
  FParity := Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    FDCB.Parity := PAR[FParity];
    SetCommState(FHandle, FDCB);
  end;
end;

// DONE
procedure TCom_32.SetStopbits(Value: TStopbits);
const
  STB: array[TStopbits] of byte = (ONESTOPBIT, ONE5STOPBITS, TWOSTOPBITS);
begin
  FStopbits := Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    FDCB.Stopbits := STB[FStopbits];
    SetCommState(FHandle, FDCB);
  end;
end;

// DONE
procedure TCom_32.SetDataBits(Value: TDatabits);
const
  DAB: array[TDatabits] of byte = (4, 5, 6, 7, 8);
begin
  FDataBits:=Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    FDCB.Bytesize := DAB[FDatabits];
    SetCommState(FHandle, FDCB);
  end;
end;

function TCom_32.InQueCount: Integer;
var
  Errors: dword;
begin
  ClearCommError(FHandle, Errors, @FCT);
  Result := FCT.cbInQue;
end;

function TCom_32.OutQueCount: Integer;
var
  Errors: dword;
begin
  ClearCommError(FHandle, Errors, @FCT);
  Result := FCT.cbOutQue;
end;

procedure TCom_32.PurgeIn;
begin
  PurgeComm(FHandle, PURGE_RXABORT or PURGE_RXCLEAR);
end;

procedure TCom_32.PurgeOut;
begin
  PurgeComm(FHandle, PURGE_TXABORT or PURGE_TXCLEAR);
end;

function TCom_32.DTR(State: boolean): boolean;
const
   DTR: array[boolean] of byte = (CLRDTR, SETDTR);
begin
  Result := EscapeCommFunction(FHandle, DTR[State]);
end;

function TCom_32.RTS(State: boolean): boolean;
const
  RTS: array[boolean] of byte = (CLRRTS, SETRTS);
begin
  Result := EscapeCommFunction(FHandle, RTS[State]);
end;

function TCom_32.BREAK(State: Boolean): boolean;
const
  BREAK: array[boolean] of byte = (CLRBREAK, SETBREAK);
begin
  Result := EscapeCommFunction(FHandle, BREAK[State]);
end;

function TCom_32.GetCTS:boolean;
var Status:DWord;
begin
Status:=0;
GetCommModemStatus(FHandle,Status);
if (Status and MS_CTS_ON)<>0 then result:=true else result:=false;
end;

function TCom_32.GetDSR:boolean;
var Status:DWord;
begin
Status:=0;
GetCommModemStatus(FHandle,Status);
if (Status and MS_DSR_ON)<>0 then result:=true else result:=false;
end;

function TCom_32.GetRI:boolean;
var Status:DWord;
begin
Status:=0;
GetCommModemStatus(FHandle,Status);
if (Status and MS_RING_ON)<>0 then result:=true else result:=false;
end;

function TCom_32.GetCD:boolean;
var Status:DWord;
begin
Status:=0;
GetCommModemStatus(FHandle,Status);
if (Status and MS_RLSD_ON)<>0 then result:=true else result:=false;
end;


end.
