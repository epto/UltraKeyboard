@echo off
color 1f
title Estensione Keyboard
cls
if "%PROCESSOR_ARCHITECTURE%" == "" goto erro
if not exist "%PROCESSOR_ARCHITECTURE%\EPTO-IT1.dll" goto erro
copy /Y "%PROCESSOR_ARCHITECTURE%\EPTO-IT1.dll" "%SYSTEMROOT%\system32\EPTO-IT1.dll"
regedit /s keyb.reg
echo Premere un tasto per riavviare il sistema.
pause
color 7
cls
echo Shutdown
shutdown /r /t 10
goto ende
:erro
title Errore
color 1c
cls
echo Non riseco a capire quale architettura di sistema e' questa!
echo Potrebbe anche essere che non ho i file per questa architettura di sistema.
echo Architettura rilevata: "%PROCESSOR_ARCHITECTURE%"
pause
color 7
cls
echo Installazione fallita
echo erro
:ende
