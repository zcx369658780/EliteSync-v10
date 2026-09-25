@echo off
setlocal DisableDelayedExpansion
set "PS=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
set "SCRIPT=D:\EliteSync-v10\EVIDENCE\AUTH-96-ENCRYPTED-USB-KEY-RECOVERY-PAIR-COPY\owner-copy-encrypted-key-pair.ps1"
set "RESULT=1"

if not exist "%PS%" goto POWERSHELL_MISSING
if not exist "%SCRIPT%" goto SCRIPT_MISSING

"%PS%" -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "try { $item = Get-Item -LiteralPath '%SCRIPT%' -Force -ErrorAction Stop; if ($item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { exit 1 }; if ((Get-FileHash -LiteralPath '%SCRIPT%' -Algorithm SHA256 -ErrorAction Stop).Hash -cne 'A79C3715E2DD08085D8BD0AEEEBE5388A0A9C2ADE197C656C6DD7EF032C6EB6C') { exit 1 }; exit 0 } catch { exit 1 }"
if errorlevel 1 goto SCRIPT_IDENTITY_FAILED

echo AUTH97_SCRIPT_IDENTITY_OK
"%PS%" -NoProfile -ExecutionPolicy RemoteSigned -File "%SCRIPT%"
set "PS_EXIT=%ERRORLEVEL%"
if not "%PS_EXIT%"=="0" goto SCRIPT_NONZERO
echo AUTH97_RESULT=SCRIPT_EXIT_ZERO
echo AUTH97_POWERSHELL_EXIT=0
set "RESULT=0"
goto END

:POWERSHELL_MISSING
echo AUTH97_FAILURE=POWERSHELL_MISSING
goto END
:SCRIPT_MISSING
echo AUTH97_FAILURE=SCRIPT_MISSING
goto END
:SCRIPT_IDENTITY_FAILED
echo AUTH97_FAILURE=SCRIPT_IDENTITY_FAILED
goto END
:SCRIPT_NONZERO
echo AUTH97_RESULT=SCRIPT_EXIT_NONZERO
echo AUTH97_POWERSHELL_EXIT=%PS_EXIT%
goto END
:END
echo AUTH97_PRESS_ANY_KEY_TO_CLOSE
pause >nul
exit /b %RESULT%
