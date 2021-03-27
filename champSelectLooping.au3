#NoTrayIcon
#include <functionsLib.au3>

Global $sFilePath = "config.ini"
Global $hFileOpenRead = FileOpen($sFilePath, $FO_READ)
Global $sFileReadChampion = FileReadLine($hFileOpenRead, 4)
FileClose($hFileOpenRead)

Local $searchLockIn, $verifyLockIn, $locked = False, $baseChamp = $sFileReadChampion, $reLoop = False, $iADC = 0
Local $marksman = ["null", "Caitlyn", "Twitch", "Ashe", "Jinx", "Lucian", "Sivir", "Varus", "Vayne", "Miss Fortune", "Tristana", "Aphelios"]
Local $imaxADC = UBound($marksman)

Func champSelectLooping($readChampion)
	nextNav('.\images\searchChampion.bmp') ;search bar
	Sleep(250)
	While 1
		If $reLoop = False Then
			Send($readChampion)
		ElseIf $reLoop = True And $iADC <= $imaxADC - 1 Then
			If $marksman[$iADC] = $baseChamp Then
				$iADC += 1
			EndIf
			MouseClick("left", 916, 106, 2) ; delete existing input in search area
			Sleep(150)
			Send($marksman[$iADC])
		EndIf
		Sleep(750)
		MouseClick("left", 383, 173)
		$searchLockIn = _ImageSearchArea('.\images\lockIn.bmp', 1, 0, 0, 1280, 720, $x, $y, 10)
		Sleep(150)
		If $searchLockIn = 0 Then
			For $i = 0 To 3
				$searchLockIn = _ImageSearchArea('.\images\lockIn.bmp', 1, 0, 0, 1280, 720, $x, $y, 10)
				If $searchLockIn = 0 Then
					$locked = False
					Sleep(150)
				ElseIf $searchLockIn = 1 Then
					MouseClick("left", $x, $y, 1, 3)
					Sleep(150)
					$verifyLockIn = _ImageSearchArea('.\images\searchChampion.bmp', 1, 0, 0, 1280, 720, $x, $y, 10)
					If $verifyLockIn = 0 Then
						$locked = True
						ExitLoop
					ElseIf $verifyLockIn = 1 Then
						$locked = False
						ExitLoop
					EndIf
				EndIf
			Next
		ElseIf $searchLockIn = 1 Then
			MouseClick("left", $x, $y, 1, 3)
			Sleep(150)
			$verifyLockIn = _ImageSearchArea('.\images\searchChampion.bmp', 1, 0, 0, 1280, 720, $x, $y, 10)
			If $verifyLockIn = 0 Then
				$locked = True
			ElseIf $verifyLockIn = 1 Then
				$locked = False
			EndIf
		EndIf
		If $locked = True Then
			writelog("Ready!")
			ExitLoop
		ElseIf $locked = False Then
			;select another champ
			$reLoop = True
			$iADC =+ 1
		EndIf
	WEnd

EndFunc   ;==>champSelectLooping

champSelectLooping($sFileReadChampion)




