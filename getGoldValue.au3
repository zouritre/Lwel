#NoTrayIcon
#include <Constants.au3>
#include <ScreenCapture.au3>
#include <GDIPlus.au3>
#include <WinAPIHObj.au3>

While 1

	; Initialise la bibliothèque GDI+
	_GDIPlus_Startup()

	Local $hHBmp = _ScreenCapture_Capture("", 682, 742, 738, 758, False)
	Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBmp) ; Convertit le bitmap GDI en GDI+
	_WinAPI_DeleteObject($hHBmp) ; Libère la ressource du bitmap GDI car elle n'est plus utile

	Local $hBitmap_Scaled = _GDIPlus_ImageResize($hBitmap, 114, 34)

	; Enregistre l'image résultante
	_GDIPlus_ImageSaveToFile($hBitmap_Scaled, @WorkingDir & "\goldValue.bmp")

	; Nettoie les ressources
	_GDIPlus_ImageDispose($hBitmap)
	_GDIPlus_ImageDispose($hBitmap_Scaled)

	; Arrête la bibliothèque GDI+
	_GDIPlus_Shutdown()

	$cmd_Pid = Run(@ComSpec & " /k", "", @SW_HIDE, $STDIN_CHILD)
	StdinWrite($cmd_Pid, "py " & @WorkingDir & "\processGoldValueFromImage.py" & @CRLF)
	StdinWrite($cmd_Pid)
	Sleep(15000)
WEnd