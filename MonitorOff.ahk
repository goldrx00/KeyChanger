#Persistent ;핫키를 포함하지 않는 스크립트도 꺼지지 않게 한다
#SingleInstance Force ; 스크립트를 동시에 한개만 실행
#NoEnv ;변수명을 해석할 때, 환경 변수를 무시한다 (속도 상승)
SetBatchLines, -1 ; 스크립트 최고속도로


Menu, Tray, Add , 로그보기

Gui, Add, ListBox, x10 y+10 w350 h200 vLogList,
;Gui, Show
return

로그보기:
    Gui, Show
return

ScrollLock::
    MonitOff(MonitVar) ;hotkey to toggle the monitor on and off 
return

; Ctrl+M키를 누르면 모니터가 꺼진다. 다시 단축키를 눌러야만 모니터가 켜진다.



MonitOff(ByRef x) {
    SetTimer, MonitOffLabel, % (x:=!x) ? "1000" : "Off" ;toggle the var and turn the timer on or off
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


;화면잠금
;Run rundll32.exe user32.dll`,LockWorkStation ;Windows key + L 

;모니터끄기
;SendMessage,0x112,0xF170,2,,Program Manager ; Ctrl+o키를 누르면 모니터가 꺼지고 아무 키 입력이나 마우스로 움직이면 모니터가 켜진다.


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

; ^f3::
;     AddLog("zzzz")
;     SendMessage,0x112,0xF170,2,,Program Manager 
;     ;Run rundll32.exe user32.dll`,LockWorkStation ;Windows key + L 
; return

; ^f4::
;     AddLog("zzzz")
   
; return