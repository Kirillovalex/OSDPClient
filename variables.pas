unit variables;

interface
uses Com_32m, classes,StdCtrls;




const PROGRAMVERSION='25.11.2021';// 

//const PROGRAM_INI='SimpleOSDPTerminal.ini';

const C_SECTION='Software\Microsoft\Windows\CurrentVersion\Policies\System\';
const C_KEY='DisableTaskMgr';
const TASKMANAGER_DISABLE=FALSE;
const TASKMANAGER_ENABLE=TRUE;


const BIGSTAND_NAME='OSDP Client (Open Supervised Device Protocol)';


// не сохранять в БД
//const DONT_SAVE_DATA=true;


const CAPTION_BUTTON_MODE_AP  = 'Режим работы с AP';
const CAPTION_BUTTON_MODE_KEY = 'Режим работы с KEY';

const AUTORUN_SECTION='SOFTWARE\Microsoft\Windows\CurrentVersion\Run\';
const AUTORUN_KEY='OSDPClient';



type

TComSettings=record
Port		:string;
BaudRate	:TBaudRate;
DataBits	:TDataBits;
Parity		:TParity;
StopBits	:TStopBits;
end;




TTxRx = record
tx,rx:longword;
end;

TStat = record
  ir,hr,di,co:TTxRx;
end;


TAlarm = record
  online:boolean;
  warning:boolean;
  error:boolean;

  warning_mask:word;
  error_mask:word;
  status_mask:word;

  duty:boolean;
  //memo:Tstrings;
  memo:TMEMO;
  status:string;

end;


//type AOFB=Array of byte;




var
  Port1Settings:TComSettings;



  need_terminate:boolean=false;

  Number_Page:byte=0;










implementation


end.



