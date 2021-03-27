#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <functionsLib.au3>

Local $champToBot[] = ["Aphelios", "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Jhin", "Jinx", "Kai'Sa", "Kalista", "Kindred", "Kog'Maw", "Lucian", "Miss Fortune", "Senna", "Sivir", "Tristana", "Twitch", "Varus", "Vayne", "Xayah"]
Local $iMax = UBound($champToBot)
Local $initPID = 0, $j = 1, $logs = "", $champList
MsgBox(0, "", @ScriptDir)
Local $hFileOpenRead = FileOpen(@ScriptDir & "config.ini", $FO_READ)
Local $sFileReadPath = FileReadLine($hFileOpenRead, 1)
Local $sFileReadID = FileReadLine($hFileOpenRead, 2)
Local $sFileReadPassword = FileReadLine($hFileOpenRead, 3)
Local $sFileReadChampionDefault = FileReadLine($hFileOpenRead, 4)

;~ For $i = 0 To $iMax - 1
;~ 	If $sFileReadChampionDefault = $champToBot[$i] Then
;~ 		_ArraySwap($champToBot, 0, $i)
;~ 	EndIf
;~ Next

FileClose($hFileOpenRead)

For $i = 0 To $iMax - 1
	$champList = $champList & "|" & $champToBot[$i]
Next

#Region ### START Koda GUI section ### Form=c:\users\timou\desktop\lwel\usergui.kxf
$userGUI = GUICreate("Lwel", 351, 405, 1553, 585)
GUISetFont(8, 800, 0, "MV Boli")
GUISetBkColor(0xC0C0C0)
$Start = GUICtrlCreateButton("Start", 264, 208, 75, 25)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x000080)
$path = GUICtrlCreateInput($sFileReadPath, 64, 8, 281, 24)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x3399FF)
$gameMode = GUICtrlCreateCombo("Intro", 104, 48, 241, 21, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Beginner|Intermediate")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x3399FF)
GUICtrlSetData(-1, "Beginner|Intermediate")
$champion = GUICtrlCreateCombo($sFileReadChampionDefault, 104, 88, 241, 21, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, $champList)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x3399FF)
$GameModeLab = GUICtrlCreateLabel("Game mode", 16, 48, 71, 20)
GUICtrlSetColor(-1, 0xFF0000)
$pathLab = GUICtrlCreateLabel("Path", 24, 8, 32, 20)
GUICtrlSetColor(-1, 0xFF0000)
$championLab = GUICtrlCreateLabel("Champion", 24, 88, 60, 20)
GUICtrlSetColor(-1, 0xFF0000)
$idText = GUICtrlCreateInput($sFileReadID, 104, 128, 241, 24)
GUICtrlSetBkColor(-1, 0xFF00FF)
$ID = GUICtrlCreateLabel("ID", 40, 118, 17, 20)
GUICtrlSetColor(-1, 0x0000FF)
$passwordText = GUICtrlCreateInput($sFileReadPassword, 104, 168, 241, 24)
GUICtrlSetBkColor(-1, 0xFF00FF)
$Password = GUICtrlCreateLabel("Password", 24, 168, 59, 20)
GUICtrlSetColor(-1, 0x0000FF)
$LogsArea = GUICtrlCreateEdit("", 8, 240, 337, 161)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x808080)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###



While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Start
			$readPath = GUICtrlRead($path)
			$readGameMode = GUICtrlRead($gameMode)
			$readChampion = GUICtrlRead($champion)
			$readID = GUICtrlRead($idText)
			$readPassword = GUICtrlRead($passwordText)
			_FileWriteToLine("config.ini", 1, $readPath, True, True)
			_FileWriteToLine("config.ini", 2, $readID, True, True)
			_FileWriteToLine("config.ini", 3, $readPassword, True, True)
			_FileWriteToLine("config.ini", 4, $readChampion, True, True)
			_FileWriteToLine("config.ini", 5, $readGameMode, True, True)
			_FileCreate("log.txt")
			If FileExists("goldValue.bmp") Then
				FileDelete("goldValue.bmp")
			EndIf
			If FileExists("goldValue.txt") Then
				FileDelete("goldValue.txt")
			EndIf
			If FileExists("goldValueProcessed.bmp") Then
				FileDelete("goldValueProcessed.bmp")
			EndIf
			GUICtrlSendMsg($LogsArea, $EM_LIMITTEXT, -1, 0)
			$initPID = Run("init.exe")
;~ 			writelog("League starting")
;~ 			While 1
;~ 				$logs = readLog("log.txt", $j)
;~ 				If $logs <> "" Then
;~ 					_GUICtrlEdit_AppendText($LogsArea, $logs & @CRLF)
;~ 					$j += 1
;~ 				EndIf
;~ 			WEnd
	EndSwitch
WEnd
