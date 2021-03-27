#include <ImageSearch.au3>
#include <AutoItConstants.au3>
#include <FileConstants.au3>
#include <File.au3>

Global $scriptPaused = False, $hWriteLog = "", $openLog, $readLog

Global $y = 0, $x = 0, $search = 0

Func HotKeyPressed()
	Switch @HotKeyPressed ; Le dernier raccourci utilisé.
		Case "{F5}"         ; la chaîne est le raccourci SHIFT + &.
			$scriptPaused = Not $scriptPaused
			While $scriptPaused
				Sleep(100)
				ToolTip('Pause', 0, 0)
			WEnd
			ToolTip("")
		Case "{F4}" ; La chaîne est le raccourci {F4}.
			If ProcessExists("champSelectLooping.exe") Then
				ProcessClose("champSelectLooping.exe")
			EndIf
			Sleep(250)
			If ProcessExists("init.exe") Then
				ProcessClose("init.exe")
			EndIf
			Sleep(250)
			If ProcessExists("getGoldValue.exe") Then
				ProcessClose("getGoldValue.exe")
			EndIf
			Sleep(250)
			If ProcessExists("inGameLogic.exe") Then
				ProcessClose("inGameLogic.exe")
			EndIf
			Sleep(250)
;~ 			If ProcessExists($sFileReadTakenChampPID) Then
;~ 				ProcessClose($sFileReadTakenChampPID)
;~ 			EndIf
;~ 			If ProcessExists($sFileReadInGameLogicPID) Then
;~ 				ProcessClose($sFileReadInGameLogicPID)
;~ 			EndIf
;~ 			If ProcessExists($sFileReadGoldValuePID) Then
;~ 				ProcessClose($sFileReadGoldValuePID)
;~ 			EndIf
;~ 			FileClose($hFileOpenRead)
			If FileExists("goldValue.bmp") Then
				FileDelete("goldValue.bmp")
			EndIf
			If FileExists("goldValue.txt") Then
				FileDelete("goldValue.txt")
			EndIf
			If FileExists("goldValueProcessed.bmp") Then
				FileDelete("goldValueProcessed.bmp")
			EndIf
			Exit
	EndSwitch
EndFunc   ;==>HotKeyPressed

HotKeySet("{F4}", "HotKeyPressed")
HotKeySet("{F5}", "HotKeyPressed")

Func stayAtRange($xCoordEnnemy, $yCoordEnnemy)
	Local $myChampxCoord = 521, $myChampyCoord = 346, $distance
	$distance = Sqrt((($xCoordEnnemy + 53) - $myChampxCoord) ^ 2 + (($yCoordEnnemy + 65) - $myChampyCoord) ^ 2)
	Return $distance
EndFunc   ;==>stayAtRange

Func readLog($pathToFile, $lineToRead)
	$openLog = FileOpen($pathToFile, $FO_READ)
	$readLog = FileReadLine($openLog, $lineToRead)
	FileClose($openLog)
	Return $readLog
EndFunc   ;==>readLog

Func writelog($message)
	$hWriteLog = FileOpen("log.txt", $FO_APPEND)
	_FileWriteLog($hWriteLog, $message & @CRLF)
	FileClose($hWriteLog)
EndFunc   ;==>writelog

Func nextNav($imagePath)
	$search = _ImageSearchArea($imagePath, 1, 0, 0, 1280, 720, $x, $y, 10)
	Sleep(250)
	While $search = 0
		$search = _ImageSearchArea($imagePath, 1, 0, 0, 1280, 720, $x, $y, 10)
		If $search = 1 Then
			ExitLoop
		Else
			Sleep(250)
		EndIf
	WEnd
	Sleep(150)
	MouseClick($MOUSE_CLICK_PRIMARY, $x, $y, 1, 4)
	$search = 0
EndFunc   ;==>nextNav

Func nextNavBoucle($imagePath)
	$navValidated = False
	While 1
		nextNav($imagePath)
		MouseMove(0, 0)
		Sleep(250)
		For $i = 1 To 3
			$search = _ImageSearchArea($imagePath, 1, 0, 0, 1280, 720, $x, $y, 10)
			If $search = 1 Then
				$navValidated = False
				ExitLoop
			ElseIf $search = 0 Then
				If $i = 3 Then
					$navValidated = True
					MouseMove(0, 0)
				EndIf
			EndIf
		Next
		If $navValidated = True Then
			ExitLoop
		Else
			Sleep(250)
		EndIf
	WEnd
EndFunc   ;==>nextNavBoucle

Func verifyIfNexNavTrue($val1, $val2, $val3)
	If $val1 = 1 Or $val2 = 1 Or $val3 = 1 Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>verifyIfNexNavTrue
