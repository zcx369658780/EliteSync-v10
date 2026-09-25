@echo off
setlocal DisableDelayedExpansion
if not exist "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" (
    echo AUTH85_FAILURE=POWERSHELL_NOT_FOUND
    goto hold
)
if not exist "D:\EliteSync-v10\EVIDENCE\AUTH-85-OWNER-DESKTOP-CONSOLE-ENTRY-PREFLIGHT\probe.ps1" (
    echo AUTH85_FAILURE=PROBE_NOT_FOUND
    goto hold
)
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop'; try { & 'D:\EliteSync-v10\EVIDENCE\AUTH-85-OWNER-DESKTOP-CONSOLE-ENTRY-PREFLIGHT\probe.ps1' } catch { Write-Output 'AUTH85_FAILURE=PROBE_LAUNCH_EXCEPTION'; exit 1 }"
set "probe_exit=%ERRORLEVEL%"
echo AUTH85_POWERSHELL_EXIT=%probe_exit%
if not "%probe_exit%"=="0" echo AUTH85_FAILURE=POWERSHELL_NONZERO
:hold
echo AUTH85_PRESS_ANY_KEY_TO_CLOSE
pause
endlocal
