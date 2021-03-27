#NoTrayIcon
#include <functionsLib.au3>

Local $PIDchampSelectLooping = 0, $PIDchampSelectAlreadyTakenChamp = 0, $ingameLogic

Func startGame($readPath, $readGameMode, $readID, $readPassword)

	Send("#r")
	WinWait("Run", "", 3)
	Send("" & $readPath & "{Enter}")
	While WinExists("[CLASS:RCLIENT]") <> 1
		Sleep(1000)
	WEnd
	Sleep(2000)
	WinMove("[CLASS:RCLIENT]", "", 0, 0)
	Sleep(100)
	writelog("Connecting")
	nextNav('.\images\username.bmp')
	Send($readID)
	Sleep(1000)
	Send("{TAB}")
	Sleep(1000)
	Send($readPassword)
	Sleep(1000)
	nextNav('.\images\loginButton.bmp')
	Sleep(10000)
	While WinExists("[CLASS:RCLIENT]") <> 1
		Sleep(1000)
	WEnd
	Sleep(250)
	WinMove("[CLASS:RCLIENT]", "", 0, 0)
	Sleep(250)
	writelog("Creating lobby")
	nextNavBoucle('.\images\play.bmp')
	Sleep(50)
	$doubleClickPlay = MouseGetPos()
	MouseClick("primary", $doubleClickPlay[0], $doubleClickPlay[1])
	Sleep(250)
	nextNav('.\images\coopIA.bmp')
	Sleep(250)
	Switch $readGameMode
		Case 'Intro'
			nextNav('.\images\intro.bmp')

		Case 'Beginner'
			nextNav('.\images\beginner.bmp')

		Case 'Intermediate'
			nextNav('.\images\intermediate.bmp')
	EndSwitch
	Sleep(1000)
	nextNavBoucle('.\images\confirm.bmp')
	Sleep(250)
	While 1
		Sleep(200)
		_FileCreate("log.txt")
		nextNavBoucle('.\images\findMatch.bmp')
		Sleep(1000)
		While WinExists("[CLASS:RiotWindowClass]") <> 1
			$acceptMatch = _ImageSearchArea('.\images\acceptMatch.bmp', 1, 0, 0, 1280, 720, $x, $y, 10)
			$acceptMatch2 = _ImageSearchArea('.\images\acceptMatch2.bmp', 1, 0, 0, 1280, 720, $x, $y, 10)
			$acceptMatch3 = _ImageSearchArea('.\images\acceptMatch3.bmp', 1, 0, 0, 1280, 720, $x, $y, 10)
			$acceptMatch4 = _ImageSearchArea('.\images\acceptMatch4.bmp', 1, 0, 0, 1280, 720, $x, $y, 10)
			If $acceptMatch = 1 Or $acceptMatch2 = 1 Or $acceptMatch3 = 1 Or $acceptMatch4 = 1 Then
				MouseClick("primary", 643, 560)
				writelog("Looking for a match")
				Sleep(500)
				If ProcessExists($PIDchampSelectLooping) Then
					ProcessClose($PIDchampSelectLooping)
					Sleep(200)
					$PIDchampSelectLooping = Run("champSelectLooping.exe")
				Else
					$PIDchampSelectLooping = Run("champSelectLooping.exe")
				EndIf
				Sleep(500)
				MouseMove(527, 323)
				Sleep(5000)
			Else
				Sleep(5000)
			EndIf
		WEnd
		Sleep(250)
		If ProcessExists($PIDchampSelectLooping) Then
			ProcessClose($PIDchampSelectLooping)
		EndIf
		Sleep(500)
		Sleep(1000)
		$ingameLogic = Run("inGameLogic.exe")
		While 1
			$search = _ImageSearchArea(".\images\gameStarted.bmp", 1, 0, 0, 1280, 720, $x, $y, 10)
			$gameStarted1 = _ImageSearchArea(".\images\atBase.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
			$gameStarted2 = _ImageSearchArea(".\images\atBase1.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
			$gameStarted3 = _ImageSearchArea(".\images\atBase2.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
			$gameStarted4 = _ImageSearchArea(".\images\atBase3.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
			$gameStarted5 = _ImageSearchArea(".\images\atBase4.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
			$gameStarted6 = _ImageSearchArea(".\images\atBase5.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
			If $gameStarted1 <> 0 Or $gameStarted2 <> 0 Or $gameStarted3 <> 0 Or $gameStarted4 <> 0 Or $gameStarted5 <> 0 Or $gameStarted6 <> 0 Or $search <> 0 Then
				$search = 0
				ExitLoop
			Else
				Sleep(1000)
			EndIf
		WEnd
		Sleep(1000)
		writelog("Game started")
		Local $getGoldValue = Run(@WorkingDir & "\getGoldValue.exe")
		Local $i = 0, $iCheckSum = PixelChecksum(271, 743, 277, 747), $abilityOrder[] = ["{LEFT}", "{RIGHT}", "{DOWN}", "{LEFT}", "{UP}", "{LEFT}", "{DOWN}", "{RIGHT}", "{DOWN}", "{UP}", "{RIGHT}", "{LEFT}", "{RIGHT}", "{RIGHT}", "{UP}", "{LEFT}", "{DOWN}"]
		Sleep(1000)
		While WinExists("[CLASS:RiotWindowClass]") = 1
			While $i < 17
				While $iCheckSum = PixelChecksum(271, 743, 277, 747)
					Sleep(500)
				WEnd
				$search = _ImageSearchArea(".\images\gameStarted.bmp", 1, 0, 0, 1280, 720, $x, $y, 10)
				If $search = 1 And WinExists("[CLASS:RiotWindowClass]") = 1 Then
					Send($abilityOrder[$i])
					Sleep(100)
					$i += 1
					Sleep(500)
				ElseIf WinExists("[CLASS:RiotWindowClass]") = 0 Then
					ExitLoop
				Else
					Sleep(1000)
				EndIf
			WEnd
			Sleep(5000)
		WEnd
		ProcessClose($ingameLogic)
		Sleep(75)
		ProcessClose($getGoldValue)
		FileDelete("goldValue.bmp")
		FileDelete("goldValue.txt")
		FileDelete("goldValueProcessed.bmp")
		Sleep(500)
		While WinExists("[CLASS:RCLIENT]") <> 1
			MouseClick($MOUSE_CLICK_PRIMARY, 1920, 0, 3) ;fait disparaitre menu contextuel si missclick droit sur bureau juste après la game
			Sleep(1000)
		WEnd
		WinMove("[CLASS:RCLIENT]", "", 0, 0)
		Sleep(50)
		MouseClick($MOUSE_CLICK_PRIMARY, 1920, 0, 3)
		writelog("Honoring a player")
		Sleep(250)
		$honor = _ImageSearchArea(".\images\skipHonor.bmp", 1, 0, 0, 1280, 720, $x, $y, 10)
		While $honor <> 1
			$honor = _ImageSearchArea(".\images\skipHonor.bmp", 1, 0, 0, 1280, 720, $x, $y, 10)
			Sleep(500)
		WEnd
		MouseClick("left", 142, 343)
		Sleep(3000)
		While 1
			MouseMove(524, 205)
			$validateRewards = _ImageSearchArea(".\images\endGameRewards.bmp", 1, 0, 0, 1280, 768, $x, $y, 10)
			$validateRewards1 = _ImageSearchArea(".\images\endGameRewards1.bmp", 1, 0, 0, 1280, 768, $x, $y, 10)
			$validateRewards2 = _ImageSearchArea(".\images\endGameRewards2.bmp", 1, 0, 0, 1280, 768, $x, $y, 10)
			$error = _ImageSearchArea(".\images\error.bmp", 1, 0, 0, 1280, 768, $x, $y, 10)
			$error1 = _ImageSearchArea(".\images\error1.bmp", 1, 0, 0, 1280, 768, $x, $y, 10)
			$error2 = _ImageSearchArea(".\images\error2.bmp", 1, 0, 0, 1280, 768, $x, $y, 10)
			$playAgain = _ImageSearchArea(".\images\PlayAgain.bmp", 1, 0, 0, 1280, 768, $x, $y, 10)
			$PlayAgain1 = _ImageSearchArea(".\images\PlayAgain1.bmp", 1, 0, 0, 1280, 768, $x, $y, 10)
			$PlayAgain2 = _ImageSearchArea(".\images\PlayAgain2.bmp", 1, 0, 0, 1280, 768, $x, $y, 10)
			If verifyIfNexNavTrue($validateRewards, $validateRewards1, $validateRewards2) = 1 Then
				MouseClick("left", 647, 687)
			ElseIf verifyIfNexNavTrue($playAgain, $PlayAgain1, $PlayAgain2) = 1 Then
				Sleep(1000)
				MouseClick("left", 535, 684)
				ExitLoop
			ElseIf verifyIfNexNavTrue($error, $error1, $error2) = 1 Then
				MouseClick("primary", 638, 394)
			EndIf
		WEnd
		writelog("Play again!")
		Sleep(250)
		MouseMove(524, 205)
	WEnd

EndFunc   ;==>startGame

$hconfigRead = FileOpen("config.ini", $FO_READ)
$readPath = FileReadLine($hconfigRead, 1)
$readGameMode = FileReadLine($hconfigRead, 5)
$readID = FileReadLine($hconfigRead, 2)
$readPassword = FileReadLine($hconfigRead, 3)
FileClose($hconfigRead)
If ProcessExists("RiotClientUx.exe") Then
	ProcessClose("RiotClientUx.exe")
ElseIf ProcessExists("LeagueClient.exe") Then
	ProcessClose("LeagueClient.exe")
EndIf
Sleep(1000)
startGame($readPath, $readGameMode, $readID, $readPassword)







