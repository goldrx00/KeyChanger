;; 윈도우 작업스케줄러에 계정 adminstrators에 가장 높은 권한으로 실행함.


#Persistent ;핫키를 포함하지 않는 스크립트도 꺼지지 않게 한다
#SingleInstance Force ; 스크립트를 동시에 한개만 실행
;#NoEnv ;변수명을 해석할 때, 환경 변수를 무시한다 (속도 상승)
SetBatchLines, -1 ; 스크립트 최고속도로

setworkingdir,%a_scriptdir%

Menu, Tray, Icon, icon.ico

Menu, Tray, DeleteAll
Menu, Tray, Add , 로그보기
Menu, Tray, Add , 모니터끄기
Menu, Tray, Add , 화면잠금

Gui, Add, ListBox, x10 y+10 w350 h200 vLogList,

;32비트 ahk로 64비트 cmd 또는 powershell을 사용하려면 가상의 sysnative 폴더로 사용
;https://github.com/Microsoft/WSL/issues/1105
Run, C:\Windows\sysnative\cmd.exe /c wsl_auto_service.bat,, hide
;wsl2 자동 포트포워딩
Run, C:\Windows\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy remotesigned ./ports_wsl.ps1 ,, hide

SetFormat, Float, 0.2

global 잠금시간 := 15
global 화면끄기시간 := 5
global 1분 := 60000
loop,
{
    if (Mod(a_index,5)=0)
        addlog("Timeidle: " A_TimeIdle/1000)
    ; if(A_TimeIdle > 1분*화면끄기시간)
    ; {
    ;     화면끄기()
    ; }
    if (A_TimeIdle > 1분*잠금시간)
    {
        화면잠금()
    }
    sleep, 1분
    ;sleep,10000
} 
;Gui, Show
return

로그보기:
    Gui, Show
return

모니터끄기:
;^SC046:: ; Ctrl + ScrollLock::
    ;MonitOff(MonitVar) ;hotkey to toggle the monitor on and off
;^sc0146:: ;pause break
Pause up:: ;up을 쓰면 키를 뗄 때 반응하게 된다. 화면 켜지는 일이 없도록
    
    화면끄기()

return


;한번 누르면 모니터 꺼진채로 유지하고 다시 누르면 켜짐
MonitOff(ByRef x) {
    SetTimer, MonitOffLabel, % (x:=!x) ? "500" : "Off" ;toggle the var and turn the timer on or off
    If(x) { ;if it turned on turn monitor off
        SendMessage,0x112,0xF170,2,,Program Manager
    }
    Else { ;if it turned off move the mouse to wake up the screen
        MouseMove, 0,0,0,R
    }
    Return

    MonitOffLabel:
        If(A_TimeIdle<1000) ;if there has been activity
        SendMessage,0x112,0xF170,2,,Program Manager
    Return
}

화면잠금()
{
    addlog("화면잠금")
    Run rundll32.exe user32.dll`,LockWorkStation ;Windows key + L 
    return
}

화면끄기()
{    
    ;addlog("화면끄기")
    ;shell := ComObjCreate("WScript.Shell")
    ; cmd.exe를 통하여 명령어 하나를 실행합니다.    
    SendMessage,0x112,0xF170,2,,Program Manager
    ;Run, MonitorOff.bat,, hide

}

절전모드()
{
    addlog("절전모드")
    ;Run, rundll32.exe powrprof.dll SetSuspendState
    ;Run, psshutdown.exe -d -t 0
    ;Hibernate( A_Now, 60, "Seconds" )
}

curl()
{
  
}

;101키 키보드의 오른쪽 한자키 컨트롤키로 맵핑
SC11D:: RCtrl

global nLog := 1 ;;기록
AddLog(String) ;;애드로그
{
	Gui,  Font, S7 CDefault, Verdana
	GuiControl,  Font, LogList
	nowTime := "" A_HOUR ":" A_MIN " "
	LogList .= nowTime String "|"
	GuiControl, , LogList, %LogList%	
	nLog++
    GuiControl,  Choose, LogList, %nLog%
	Gui,  Font, S8 CDefault, Verdana
}

^f9::
    ; AddLog("zzzz")
    ; ; shell := ComObjCreate("WScript.Shell")
    ; ; exec := shell.Exec(ComSpec " /c " "wsl sudo service ssh start")
    ; ; ret := exec.StdOut.ReadAll()
    ; ;run, bash.exe
    ; ;Run, wsl.exe -d ubuntu -e “cd ~”
    ; ;run, C:\Users\goldrx89\Desktop\monitor.bat
    ; ;Run, powershell /c wsl_auto_service.bat , , ;hide
    ; ;Run, wsl_auto_service.bat
    ; Run, C:\Windows\sysnative\cmd.exe /c wsl_auto_service.bat ;https://github.com/Microsoft/WSL/issues/1105    
    ; Run, C:\Windows\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Unrestricted ./ports_wsl.ps1,, ;hide
    ; ;Run, ports_wsl.ps1 -ExecutionPolicy Unrestricted
    ; AddLog("kkkk")
return

; ^f4::
;     Hibernate( A_Now, 60, "Seconds" )
   
; return


Hibernate(T="", O=0,  U="H" ){ ; by SKAN  www.autohotkey.com/forum/viewtopic.php?t=50733
    T += %O%,%U%                
    EnvSub, T, 16010101, S
    VarSetCapacity(FT,8), DllCall( "LocalFileTimeToFileTime", Int64P,T:=T*10000000,UInt,&FT )
    If hTmr := DllCall( "CreateWaitableTimer", UInt,0, UInt,0, UInt,0 )
    If DllCall( "SetWaitableTimer", UInt,hTmr, UInt,&FT, UInt,1000, Int,0, Int,0, UInt,1 )
    If DllCall( "PowrProf\SetSuspendState", UInt,1, UInt,0, UInt,0 )
    DllCall( "WaitForSingleObject", UInt,hTmr,Int,-1 ), DllCall( "CloseHandle",UInt,hTmr )
    Return A_LastError
}

; Examples:
; Hibernate( 20100101 ) ; until a future Timestamp ( New Year )
; Hibernate( A_Now, 600, "Seconds" )
; Hibernate( A_Now, 30, "Minutes" )
; Hibernate( A_Now, 2, "Hours" ) or Hibernate( Null, 2 )
; Hibernate( A_Now, 7, "Days" )