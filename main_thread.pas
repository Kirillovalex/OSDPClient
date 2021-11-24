unit main_thread;

interface

uses 

windows,classes,syncobjs,sysutils, com_32m,
variables, forms  , dialogs, 
osdp_client ;



type CMain_Thread = class (TThread)
    protected
        procedure Execute();override;// непосредственно запросы - ответы
    private
        m_terminated:boolean;   // капитуляция
        m_sect:TCriticalSection;// синхронизация на переменные
        m_interval:DWORD;       // приблизительный интервал опроса
        //m_tx,m_rx:DWORD;        // статистика
    public
        m_osdp:COSDPClient;





        Disable_RX:boolean;// Для отсылки  - ставим в true - опрос прекратится, затем обязательно ставим в false



        constructor Create();
        destructor Destroy();override;
        ///function mf_StartService(Port1Settings:TComSettings):boolean;
        function mf_StartService(ps:TComSettings):boolean;


        procedure mf_StopService();

        function Started():boolean;



        function mf_GetPercent():extended;// получить статистику непрохождения




        function FLAGSneed():boolean;


end;

implementation

constructor CMain_Thread.Create();
var iii:integer;
begin
    inherited Create(false);



    Disable_RX:=false;
    m_osdp:=nil;
    self.FreeOnTerminate:=false;
    m_sect:=TCriticalSection.Create;
    m_terminated:=true;
    m_interval:=100;



    self.Priority := tpLowest;


end;

destructor CMain_Thread.Destroy();
var iii:integer;
begin

    mf_StopService();
    m_sect.Free();

    inherited Destroy;
end;

function CMain_Thread.FLAGSneed():boolean;
begin
    result:= false;//self.need_Set_T_water or
             //self.need_Set_T_water_back or
             //self.need_Set_Start_Stop;






end;




function CMain_Thread.mf_StartService(ps:TComSettings):boolean;
//function CModbus_Thread.mf_StartService(portname:string):boolean;
begin
    result:=false;

    Disable_RX:=false;
    
    m_osdp:=COSDPClient.Create();
    if m_osdp=nil then exit;
    ///m_modbus.mf_StartService(PS);
    m_osdp.mf_StartService(ps);
    if (not m_osdp.Started())
    then begin
        m_osdp.Free;
        m_osdp:=nil;
        exit;
        end;
    m_terminated:=false;
    self.Resume();
    result:=true;
end;

function CMain_Thread.Started():boolean;
begin
    result:=m_osdp.Started();
end;

procedure CMain_Thread.mf_StopService();
begin
    if m_terminated then exit;
    m_terminated:=true;
    Sleep(200);
    TerminateThread(self.Handle,0);
    m_osdp.mf_StopService();
    m_osdp.Free();
    m_osdp:=nil;
end;

procedure CMain_Thread.Execute();
var dw:DWORD;
    iii:integer;

    good_rx:boolean;
begin
    dw:=GetTickCount();
    while (1=1) do
    begin


        while ((GetTickCount()-dw)<m_interval) and (not m_terminated) do sleep(1);
        dw:=GetTickCount();

        while (m_terminated) do Sleep(1);//
          begin
            if (Disable_RX) then continue;


          end;




        //                                                         пока внешний поток не поскидывает флаги
        while      (not terminated) and
       (
         FLAGSneed()

        // *****
        )
         do sleep(1);


    end;
end;

function CMain_Thread.mf_GetPercent():extended;// получить статистику непрохождения
var rez:extended;
begin
{

    rez:=100;
    try
    self.m_sect.Enter;
    if m_osdp<>nil then m_modbus.GetTXTR(m_tx,m_rx);
    if (m_tx=0) then rez:=100 else rez:=(m_tx-m_rx)/0.01/m_tx;
    self.m_sect.Leave;
    except end;
    result:=rez;
}
end;








end.
