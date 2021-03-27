While 1
	ProcessClose("UI.exe")
	Sleep(1000)
;~ 	WinWaitClose("UI.exe")
	Run("UI.exe")
	If WinWait("Lwel", "", 5) = 0 Then
		Run("restart.exe")
		ExitLoop
	EndIf
	MouseClick("primary", 1854, 832)
	If WinWait("[CLASS:RCLIENT]", "", 20) = 0 Then
		Run("restart.exe")
		ExitLoop
	EndIf
	ExitLoop
WEnd
