;; 윈도우 작업스케줄러에 계정 adminstrators에 가장 높은 권한으로 실행함.

;키체인저 테스트

#Persistent ;핫키를 포함하지 않는 스크립트도 꺼지지 않게 한다
#SingleInstance Force ; 스크립트를 동시에 한개만 실행
;#NoEnv ;변수명을 해석할 때, 환경 변수를 무시한다 (속도 상승)
SetBatchLines, -1 ; 스크립트 최고속도로

setworkingdir,%a_scriptdir%

Menu, Tray, Icon, icon.ico

; Menu, Tray, DeleteAll
Menu, Tray, Add , 로그보기
Menu, Tray, Add ; separator
Menu, Tray, Add , 모니터끄기
Menu, Tray, Add , 화면잠금
Menu, Tray, Add ; separator
Menu, Tray, Add , exit
Menu, Tray, NoStandard

Gui, Add, ListBox, x10 y+10 w350 h200 vLogList,
Gui, Add, Text,,
Gui, Add, Text, , 절전모드 시간:
Gui, Add, Slider, w300 vMySlider Range0-3 TickInterval1, 1
Gui, Add, Text,,안 함
Gui, Add, Text,x+65, 25분
Gui, Add, Text,x+65, 1시간
Gui, Add, Text,x+65, 2시간

;sleep, 10000

SetTimer, wsl_auto, -30000 ;시간 음수로 하면 한번만 실행하고 꺼짐

SetFormat, Float, 0.2

mosquitto := "C:\Program Files\mosquitto\mosquitto_pub.exe"
global 잠금시간 := 10
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

    Gui, Submit, Nohide
    if ((MySlider = 1 && A_TimeIdle > 1분*25)
        ||(MySlider = 2 && A_TimeIdle > 1분*60)
        ||(MySlider = 3 && A_TimeIdle > 1분*120))
    {
        ;addlog("절전모드: "A_TimeIdle)
        절전모드()
        sleep, 20000
        MouseMove, 0,0,0,R
        MouseMove, 0,0,0,R
    }

    timeidle_sec := A_TimeIdle/1000
    Run, %mosquitto% -h 192.168.0.51 -t desktop/timeidle -u goldrx89 -P nukeqbc -m %timeidle_sec%, , hide

    sleep, 1분
}
;Gui, Show
return

exit:
ExitApp

로그보기:
    Gui, Show
return

모니터끄기:
    ; ^SC046:: ; Ctrl + ScrollLock::
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
    DllCall( "PowrProf\SetSuspendState", UInt, 0, UInt,0, UInt,0 ) ;절전모드
    ;Run, psshutdown.exe -d -t 0
    ;Hibernate( A_Now, 60, "Seconds" )
}

curl()
{

}

wsl_auto()
{
    ;32비트 ahk로 64비트 cmd 또는 powershell을 사용하려면 가상의 sysnative 폴더로 사용
    ;https://github.com/Microsoft/WSL/issues/1105
    ;Run, C:\Windows\sysnative\cmd.exe /c wsl_auto_service.bat,, hide
    ;Run, wsl_auto_service.bat,,
    ;addlog("wsl_auto_service")
    ;wsl2 자동 포트포워딩
    ; Run, C:\Windows\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy remotesigned ./ports_wsl.ps1 ,, hide
    ; addlog("wsl 포트포워딩 완료")
}

탭숨기기()
{
    ;  CoordMode, Pixel, Window
    ; CoordMode, Mouse, Window

    WinGet, hWndList, List, ahk_exe msedge.exe
    ; addlog(hWndList)

    Loop, % hWndList ;.Length()
    {
        hWnd := hWndList%A_Index%
        ; addlog(hWnd)

        WinGetTitle, Title, ahk_id %hWnd%
        ; addlog(Title)
        IfInString, Title, 애드벌룬 상세내역
            continue
        IfInString, Title, 모바일 게임
            continue
        IfInString, Title, TradingView
            continue

        WinGet, minmax, MinMax, ahk_id %hWnd%
        WinActivate, ahk_id %hWnd%
        sleep, 100
        PixelGetColor, color, 95, 11
        addlog(color)
        if (color = 0xC5750C)
        {
            ControlClick, x67 y20, ahk_id %hWnd%,,,, NA
        }

        if (minmax = -1)
            WinMinimize, ahk_id %hWnd%
        ; ControlClick, x67 y20, ahk_id %hWnd%,,,, NA
    }
    ; ControlClick, x50 y20, ahk_id %hWndList1% ;다시 처음창으로

    WinMinimize, ahk_class com.dcinside.app.android
    ; WinMinimize, 애드벌룬 상세내역
    ; WinMinimize, 모바일 게임
    addlog("탭숨기기")
}

;101키 키보드의 오른쪽 한자키 컨트롤키로 맵핑
SC11D:: RCtrl

global nLog := 1 ;;기록
AddLog(String) ;;애드로그
{
    Gui, Font, S7 CDefault, Verdana
    GuiControl, Font, LogList
    nowTime := "" A_HOUR ":" A_MIN " "
    LogList .= nowTime String "|"
    GuiControl, , LogList, %LogList%
    nLog++
    GuiControl, Choose, LogList, %nLog%
    Gui, Font, S8 CDefault, Verdana
}

Hibernate(T="", O=0, U="H" ){ ; by SKAN  www.autohotkey.com/forum/viewtopic.php?t=50733
    T += %O%,%U%
    EnvSub, T, 16010101, S
    VarSetCapacity(FT,8), DllCall( "LocalFileTimeToFileTime", Int64P,T:=T*10000000,UInt,&FT )
    If hTmr := DllCall( "CreateWaitableTimer", UInt,0, UInt,0, UInt,0 ) ;예약타이머 생성
        If DllCall( "SetWaitableTimer", UInt,hTmr, UInt,&FT, UInt,1000, Int,0, Int,0, UInt,1 ) ;예약타이머 세팅
            ;If DllCall( "PowrProf\SetSuspendState", UInt, 0, UInt,0, UInt,0 )  ;절전모드
            If DllCall( "PowrProf\SetSuspendState", UInt,1, UInt,0, UInt,0 ) ;최대절전모드
            {
                ;DllCall( "WaitForSingleObject", UInt,hTmr,Int,-1 ) ;대기시간동안 오토핫키 멈추게 하는 명령어
                DllCall( "CloseHandle",UInt,hTmr ) ;핸들 클로즈함과 동시에 예약도 사라짐
            }
    Return A_LastError
}

; Examples:
; Hibernate( 20100101 ) ; until a future Timestamp ( New Year )
; Hibernate( A_Now, 600, "Seconds" )
; Hibernate( A_Now, 30, "Minutes" )
; Hibernate( A_Now, 2, "Hours" ) or Hibernate( Null, 2 )
; Hibernate( A_Now, 7, "Days" )

^f4::
    탭숨기기()
return

; ^f5::

; return

; ^f9::
;     절전모드()

; return

; For the PC screen only: %windir%\System32\DisplaySwitch.exe /internal
; For Duplicate: %windir%\System32\DisplaySwitch.exe /clone
; For Extend: %windir%\System32\DisplaySwitch.exe /extend
; For Second screen only: %windir%\System32\DisplaySwitch.exe /external