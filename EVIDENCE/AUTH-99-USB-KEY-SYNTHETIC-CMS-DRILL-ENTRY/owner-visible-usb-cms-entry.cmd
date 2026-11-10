@echo off
setlocal DisableDelayedExpansion
set "PS=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
set "SCRIPT=D:\EliteSync-v10\EVIDENCE\AUTH-99-USB-KEY-SYNTHETIC-CMS-DRILL-ENTRY\owner-usb-cms-roundtrip.ps1"
set "RESULT=1"

if not exist "%PS%" goto POWERSHELL_MISSING
if not exist "%SCRIPT%" goto SCRIPT_MISSING

"%PS%" -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "try { $item = Get-Item -LiteralPath '%SCRIPT%' -Force -ErrorAction Stop; if ($item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { exit 1 }; if ((Get-FileHash -LiteralPath '%SCRIPT%' -Algorithm SHA256 -ErrorAction Stop).Hash -cne '04727B2C060017A6091C5FCF157A21CFC2F62EDA6C232A45CDBC5A23FE946B8F') { exit 1 }; exit 0 } catch { exit 1 }"
if errorlevel 1 goto SCRIPT_IDENTITY_FAILED

echo AUTH99_SCRIPT_IDENTITY_OK
"%PS%" -NoProfile -ExecutionPolicy RemoteSigned -File "%SCRIPT%"
set "PS_EXIT=%ERRORLEVEL%"
if not "%PS_EXIT%"=="0" goto SCRIPT_NONZERO
echo AUTH99_ENTRY=SCRIPT_EXIT_ZERO
echo AUTH99_POWERSHELL_EXIT=0
set "RESULT=0"
goto END

:POWERSHELL_MISSING
echo AUTH99_ENTRY_FAILURE=POWERSHELL_MISSING
goto END
:SCRIPT_MISSING
echo AUTH99_ENTRY_FAILURE=SCRIPT_MISSING
goto END
:SCRIPT_IDENTITY_FAILED
echo AUTH99_ENTRY_FAILURE=SCRIPT_IDENTITY_FAILED
goto END
:SCRIPT_NONZERO
echo AUTH99_ENTRY=SCRIPT_EXIT_NONZERO
echo AUTH99_POWERSHELL_EXIT=%PS_EXIT%
goto END
:END
echo AUTH99_PRESS_ANY_KEY_TO_CLOSE
pause >nul
exit /b %RESULT%
