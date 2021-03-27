#NoTrayIcon
#include <functionsLib.au3>
#include <Json.au3>

Local $abilities[] = ["z", "r", "a", "e"]

Local Const $goldValueFilePath = @WorkingDir & "\goldValue.txt"

Local $hfileOpen, $fileRead, $backToBuy = False, $x, $y, $x1, $y1, $xEnnemy, $yEnnemy, $ennemyFound, $ennemyRangeDetection, $ennemyColor = 0x410703, $i = 0
Local $towerRangeDetection = 0, $stayAtRangeVal = 235, $goldValueToBack = 2000, $lastGoldValue = 500, $nextItemToBuyIndex = 0, $indexI = 0
Global $itemsFromSet[1][2]
$itemsFromSet[0][0] = "NoSet"

Func moveToT2()
	MouseClick($MOUSE_CLICK_MIDDLE, 906, 688, 1, 1)
EndFunc   ;==>moveToT2

Func checkHP()
	Local $state = "Full"
	$checkLowHP = PixelSearch(355, 736, 400, 739, 0x010D07, 5)
	$checkFullHP = PixelSearch(583, 733, 605, 735, 0x010D07, 5)
	If IsArray($checkLowHP) Then
		$state = "Low"
		Return $state
	ElseIf IsArray($checkFullHP) = 0 Then
		$state = "fullHP"
		Return $state
	Else
		$state = "highEnough"
		Return $state
	EndIf
EndFunc   ;==>checkHP

Func getItemsAndChampionFromDataset()

	; get all items and their prices from dataset

	Local $itemsDataset = FileReadToArray(@WorkingDir & "\itemsToBuy\riot_item.csv")

	Local $iMax = UBound($itemsDataset) + 1, $jMax = 3, $allItems[$iMax][$jMax], $splitter ; Func getItemsFromDataset

	If @error Then
		MsgBox($MB_SYSTEMMODAL, "", "Il y a une erreur de lecture du fichier riot_item.CSV. @error: " & @error) ; Une erreur s'est produite lors de la lecture du fichier.
	EndIf
	For $i = 0 To UBound($itemsDataset) - 1     ; Boucle dans le tableau.
		$splitter = StringSplit($itemsDataset[$i], ",")     ;converti la chaine reçu en tableau
		For $j = 0 To $jMax - 1
			$allItems[$i][$j] = $splitter[$j + 1]
		Next
	Next
;~ 	_ArrayDisplay($allItems)
;~ 		MsgBox(0, "", "ID: " & $allItems[1][0] & @CRLF & "Nom: " & $allItems[1][1] & @CRLF & "Prix: " & $allItems[1][2])

	;All items and their price etc from dataset are now accessible with $allItems variable.

	;read wich champion is being played and get his ID number

	$hfileOpen = FileOpen("config.ini", $FO_READ)
	$fileRead = FileReadLine($hfileOpen, 4)
	FileClose($hfileOpen)

	Local $championDataset = FileReadToArray(@WorkingDir & "\itemsToBuy\riot_champion.csv")
	Local $allChampions[$iMax][$jMax]
	Local $championID

	$iMax = UBound($championDataset) + 1
	$jMax = 2

	If @error Then
		MsgBox($MB_SYSTEMMODAL, "", "Il y a une erreur de lecture du fichier riot_champion.CSV. @error: " & @error) ; Une erreur s'est produite lors de la lecture du fichier.
	EndIf
	For $i = 0 To UBound($championDataset) - 1     ; Boucle dans le tableau.
		$splitter = StringSplit($championDataset[$i], ",")      ;converti la chaine reçu en tableau
		For $j = 0 To $jMax - 1
			$allChampions[$i][$j] = $splitter[$j + 1]
			If $j = 1 Then
				If $allChampions[$i][$j] = $fileRead Then
					$championID = $allChampions[$i][$j - 1]
				EndIf
			EndIf
		Next
	Next

;~ MsgBox(0, "", $championID)
;~ 	_ArrayDisplay($allChampions)

	; get path of league directory

	$hfileOpen = FileOpen("config.ini", $FO_READ)
	$fileRead = FileReadLine($hfileOpen, 1)
	FileClose($hfileOpen)

	Local $leagueDir = StringTrimRight($fileRead, 16), $itemSetsPath = $leagueDir & "Config\ItemSets.json", $numberOfSets = 0

;~ 	MsgBox(0, "", $itemSetsPath)

	$hfileOpen = FileOpen($itemSetsPath, $FO_READ)
	$fileRead = FileRead($hfileOpen)
	FileClose($hfileOpen)

	$oJson = Json_Decode($fileRead)
	$res = Json_ObjGet($oJson, "itemSets")
	$numberOfSets = UBound($res)

;~ 	MsgBox(0, "", $numberOfSets)

	; Now we get all items in user itemSet from League config folder and match it to the champion actually selected to bot with

	For $i = 0 To UBound($res) - 1 ; loop chaque set d'objet
		$oJson = Json_Decode(Json_Encode($res[$i]))
		$res1 = Json_ObjGet($oJson, "associatedChampions") ; array
		If UBound($res1) > 0 Then
			For $j = 0 To UBound($res1) - 1 ; vérifie chaque champion à qui est attribué le set
				If $res1[$j] = $championID Then
					;stock tout les items du set dans le tableau $itemsFromSet pour être réutilisé dans buyItems()
					;puis ExitLoop
					$res = Json_ObjGet($oJson, "blocks")
					If UBound($res) = 1 Then ; si il y a un block dans le set
						For $i = 0 To UBound($res) - 1
							$oJson = Json_Decode(Json_Encode($res[$i]))
							$res1 = Json_ObjGet($oJson, "items")
							If UBound($res1) > 0 Then ; si il y a au moins un item dans le block
								For $j = 0 To UBound($res1) - 1
									ReDim $itemsFromSet[UBound($itemsFromSet) + 1][2]
									$oJson = Json_Decode(Json_Encode($res1[$j]))
									$res2 = Json_ObjGet($oJson, "id") ; contient l'id de chaque item du set
									;MsgBox(0, "", $res2)
									For $k = 1 To UBound($allItems)
;~ 									MsgBox(0, "", "Item du set: " & $res2 & @CRLF & "Item du dataset: " & $allItems[$k][0])
										If $res2 = $allItems[$k][0] Then
											$itemsFromSet[$j][0] = $allItems[$k][1] ; nom de l'item
											$itemsFromSet[$j][1] = $allItems[$k][2] ; prix de l'item
											ExitLoop
										EndIf
									Next
								Next
							Else
								$itemsFromSet[0][0] = "Erreur de formattage"
								MsgBox(48, "", "Mauvais formattage de l'item set. Aucun items dans le set" & @CRLF & "La parti va continuer.")
							EndIf
						Next
						ExitLoop
					Else ; s'il n'y a pas de block dans le set
						$itemsFromSet[0][0] = "Erreur de formattage"
						MsgBox(48, "", "Mauvais formattage de l'item set. Doit impérativement avoir un block au minimum et un block au maximum" & @CRLF & "La parti va continuer.")
						ExitLoop
					EndIf
				EndIf
			Next
		EndIf
		If $itemsFromSet[0][0] = "Erreur de formattage" Then
			$itemsFromSet[0][0] = "NoSet"
			ExitLoop
		ElseIf $itemsFromSet[0][0] <> "NoSet" Then
			ExitLoop
		EndIf
	Next

EndFunc   ;==>getItemsAndChampionFromDataset

Func buyItems()

	Local $notBought, $nextItem

	If $itemsFromSet[0][0] <> "NoSet" Then
;~ 		_ArrayDisplay($itemsFromSet)
		;buy items from the array $itemsFromSet
		If $indexI <= UBound($itemsFromSet) - 2 Then
			Send("p")
			Sleep(1000)
			Sleep(1000)
			For $i = $nextItemToBuyIndex To UBound($itemsFromSet) - 1
				If $indexI <= UBound($itemsFromSet) - 2 Then
					If $lastGoldValue >= $itemsFromSet[$i][1] Then
;~ 						MsgBox(0, "", "Can buy" & $itemsFromSet[$i][0])
						Send("^l")
						Sleep(200)
						Send($itemsFromSet[$i][0])
						Sleep(500)
						MouseClick("left", 62, 122, 1, 4)
						Sleep(750)
						MouseClick("right", 62, 122, 1, 4)
						$lastGoldValue -= $itemsFromSet[$i][1]
						$indexI += 1
						Sleep(500)
						MouseMove(1, 1, 4)
					Else
;~ 						MsgBox(0, "", "Finished buying")
;~ 						MsgBox(0, "", "Prochain achat: " & $itemsFromSet[$indexI][0])
						ExitLoop
					EndIf
				Else
;~ 					MsgBox(0, "", "Full stuff")
					ExitLoop
				EndIf
			Next
;~ 			MsgBox(0, "", "Golds left: " & $lastGoldValue)
			$nextItemToBuyIndex = $indexI
			Sleep(1000)
			MouseClick("left", 1, 1)
			Sleep(100)
			Send("p")
		Else
;~ 			MsgBox(0, "", "Full stuff")
			;do nothing
		EndIf
	Else
;~ 		MsgBox(0, "", "Do nothing")
		;do nothing
	EndIf
	$lastGoldValue = 0 ; DERNIERE LIGNE !!
EndFunc   ;==>buyItems

Func attemptBack()
	While 1
		$ennemyFound = _ImageSearchArea(".\images\ennemyFound.bmp", 1, 0, 0, 1024, 768, $xEnnemy, $yEnnemy, 10)
		$atBase1 = _ImageSearchArea(".\images\atBase.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
		$atBase2 = _ImageSearchArea(".\images\atBase1.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
		$atBase4 = _ImageSearchArea(".\images\atBase3.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
		$atBase3 = _ImageSearchArea(".\images\atBase2.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
		$atBase6 = _ImageSearchArea(".\images\atBase5.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
		$atBase5 = _ImageSearchArea(".\images\atBase4.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
		$atBase6 = PixelSearch(310, 732, 315, 740, 0x703E28, 2)         ;Pixel drap rouge sur taureau vendeur
		$justDied = _ImageSearchArea(".\images\justDied.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
		$justDied1 = PixelSearch(310, 732, 315, 740, 0x010D07, 5)         ;Pixel HP = 0
		If $ennemyFound = 1 And checkHP() <> "Low" And checkTowers() = 0 Then
			attackChampions()
		ElseIf $ennemyFound = 1 Then
			writelog("Fleeing")
			moveToT2()
			Sleep(2000)
		ElseIf $atBase1 = 1 Or $atBase2 = 1 Or $atBase3 = 1 Or $atBase4 = 1 Or $atBase5 = 1 Or IsArray($atBase6) = 1 Then
			MouseClick("right", 839, 754, 1, 6)         ;stop deplacement involontaire dans le spawn
			ExitLoop
		ElseIf $justDied <> 0 Or $justDied1 <> 0 = 1 Then
			ExitLoop
		Else
			writelog("Return to base")
			Send("{b}")
			Sleep(500)
		EndIf
	WEnd
EndFunc   ;==>attemptBack

Func attackChampions()
	writelog("Attacking")
	While $ennemyFound = 1 And checkHP() <> "Low"
		$xEnnemy += 53
		$yEnnemy += 65
		MouseClick("right", $xEnnemy, $yEnnemy, 1, 3)
		Send($abilities[$i])
		If checkTowers() = 0 Then
			If stayAtRange($xEnnemy, $yEnnemy) < $stayAtRangeVal Then
				MouseClick("middle", 359, 483, 1, 3)
			EndIf
			$ennemyFound = _ImageSearchArea(".\images\ennemyFound.bmp", 1, 0, 0, 1024, 768, $xEnnemy, $yEnnemy, 10)
			If $i < 3 Then
				$i += 1
			Else
				$i = 0
			EndIf
		ElseIf checkTowers() = 1 Then
			$i = 0
			writelog("Tower detected")
			ExitLoop
		EndIf
	WEnd
EndFunc   ;==>attackChampions

Func checkTowers()
	Local $T2Aggro = _ImageSearchArea('.\images\T2Aggro.bmp', 1, 0, $towerRangeDetection, 1024, 768, $x, $y, 10)
	Local $towersAfterT2 = _ImageSearchArea('.\images\towersAfterT2.bmp', 1, 0, $towerRangeDetection, 1024, 768, $x, $y, 10)
	If $T2Aggro = 1 Or $towersAfterT2 = 1 Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>checkTowers

Func pushBehindMinions()
	While 1
		While checkHP() <> "Low"
			$backToBuy = False
			$allyMinionsPos = _ImageSearchArea('.\images\allyMinionPos.bmp', 1, 450, 0, 1024, 390, $x1, $y1, 10)
			If $allyMinionsPos = 1 And checkTowers() = 1 Then
				$x += 75
				$y += 85
				writelog("Tower detected")
				$ennemyFound = _ImageSearchArea(".\images\ennemyFound.bmp", 1, 0, 0, 1024, 768, $xEnnemy, $yEnnemy, 10)
				If $ennemyFound = 1 Then
					$distance = stayAtRange($xEnnemy, $yEnnemy)
					If $distance < $stayAtRangeVal Then
						moveToT2()
						writelog("Fleeing")
						Sleep(1000)
					Else
						MouseClick("right", $x, $y, 1, 3)
					EndIf
				Else
					MouseClick("right", $x, $y, 1, 6)
				EndIf
			ElseIf $allyMinionsPos = 0 Then
				moveToT2()
				writelog("Going safe")
				Sleep(1500)
			ElseIf $allyMinionsPos = 1 Then
				$hfileOpen = FileOpen($goldValueFilePath, $FO_READ)
				$fileRead = FileReadLine($hfileOpen, 1)
				$goldValue = Number($fileRead)
				If $lastGoldValue <= $goldValue Then
					$lastGoldValue = $goldValue
				Else
					$goldValue = $lastGoldValue
				EndIf
				If IsNumber($goldValue) And $goldValue >= $goldValueToBack Then ; return to base if gold >2000
					$backToBuy = True
					ExitLoop
				EndIf
				FileClose($hfileOpen)
				If checkTowers() = 0 Then
					$ennemyFound = _ImageSearchArea(".\images\ennemyFound.bmp", 1, 0, 0, 1024, 768, $xEnnemy, $yEnnemy, 10)
					If $ennemyFound = 1 Then
						attackChampions()
					Else
						MouseClick($MOUSE_CLICK_SECONDARY, $x1 + 29, $y1 + 32)
						writelog("Following minions")
					EndIf
				EndIf
			EndIf
;~ 			Sleep(100) ; time between clicks
		WEnd
		If $backToBuy = False Then
			writelog("Fleeing")
			MouseMove(359, 483, 1)
			Send("{d}")
			Sleep(30)
			moveToT2()
			Send("{f}") ; use heal then flash when low hp
			Sleep(5000)
			writelog("Looking for safe spot")
			attemptBack()
		ElseIf $backToBuy = True Then
			writelog("Going base to buy")
			moveToT2()
			Sleep(5000)
			attemptBack()
		EndIf
		Sleep(500)
		writelog("Buying")
		buyItems()
		Sleep(1000)
		While checkHP() <> "fullHP"
			Sleep(1000)
		WEnd
		writelog("Moving to lane")
		moveToT2()
		Sleep(10000)
	WEnd
EndFunc   ;==>pushBehindMinions

;~ At game start ===>

WinMove("[CLASS:RiotWindowClass]", "", 0, 0)
Sleep(2000)
getItemsAndChampionFromDataset()

While 1
	$search = _ImageSearchArea(".\images\gameStarted.bmp", 1, 0, 0, 1024, 768, $x, $y, 10)
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
buyItems()
Sleep(1000)
Send("{DOWN}")
Sleep(15000)
writelog("Moving to lane")
moveToT2()
Sleep(30000)
pushBehindMinions()


