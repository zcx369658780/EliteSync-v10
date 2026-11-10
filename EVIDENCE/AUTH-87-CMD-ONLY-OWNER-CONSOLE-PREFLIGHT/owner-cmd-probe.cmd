@echo off
echo AUTH87_VISIBLE_PROBE
if not exist "C:\Windows\System32\choice.exe" goto choice_unavailable
"C:\Windows\System32\choice.exe" /C Y /N /M AUTH87_PRESS_Y_ONCE
if errorlevel 2 goto choice_failed
if errorlevel 1 goto choice_accepted
goto choice_failed

:choice_accepted
echo AUTH87_KEY_ACCEPTED
goto hold

:choice_unavailable
echo AUTH87_FAILURE=CHOICE_UNAVAILABLE
goto hold

:choice_failed
echo AUTH87_FAILURE=CHOICE_NOT_ACCEPTED
goto hold

:hold
echo AUTH87_PRESS_ANY_KEY_TO_CLOSE
pause
