@echo off
setlocal DisableDelayedExpansion
set "PS=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
set "GUARD=D:\EliteSync-v10\EVIDENCE\AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR\usb-preflight.ps1"
set "OPENSSL=C:\Program Files\Git\usr\bin\openssl.exe"
set "CERT=E:\elitesync-v10-db-backup-recipient-20260925.cert.pem"
set "TEMPDIR=C:\Users\zcxve\AppData\Local\Temp\elitesync-auth101-synthetic"
set "MARKER=%TEMPDIR%\synthetic-marker.txt"
set "CMS=%TEMPDIR%\synthetic-cms.der"
set "DECRYPTED=%TEMPDIR%\synthetic-decrypted-marker.txt"
set "CATEGORY=UNKNOWN_FAILURE"
set "STEP_EXIT=1"
set "RESULT=1"

if not exist "%PS%" goto POWERSHELL_MISSING
if not exist "%GUARD%" goto GUARD_MISSING
"%PS%" -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "try { $i=Get-Item -LiteralPath '%GUARD%' -Force -ErrorAction Stop; if ($i.PSIsContainer -or ($i.Attributes -band [IO.FileAttributes]::ReparsePoint)) { exit 1 }; if ((Get-FileHash -LiteralPath '%GUARD%' -Algorithm SHA256 -ErrorAction Stop).Hash -cne '5CAEA4AA65C11B36C3DD88AAEE6F49CEEC6ED47E4C7950BFCD6EA7AD467C2E29') { exit 1 }; exit 0 } catch { exit 1 }" >nul 2>nul
if errorlevel 1 goto GUARD_IDENTITY_FAILED

"%PS%" -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File "%GUARD%"
set "STEP_EXIT=%ERRORLEVEL%"
if not "%STEP_EXIT%"=="0" goto PREFLIGHT_FAILED

mkdir "%TEMPDIR%" >nul 2>nul
if errorlevel 1 goto TEMP_CREATE_FAILED
if not exist "%TEMPDIR%\" goto TEMP_CREATE_FAILED
if exist "%MARKER%" goto TEMP_TARGET_PRESENT
if exist "%CMS%" goto TEMP_TARGET_PRESENT
if exist "%DECRYPTED%" goto TEMP_TARGET_PRESENT

"%PS%" -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "try { $b=[Text.Encoding]::ASCII.GetBytes('AUTH101_USB_KEY_ONLY_20260925' + [Environment]::NewLine); $s=[IO.File]::Open('%MARKER%',[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None); try { $s.Write($b,0,$b.Length) } finally { $s.Dispose() }; if ((Get-Item -LiteralPath '%MARKER%' -ErrorAction Stop).Length -ne 31) { exit 1 }; exit 0 } catch { exit 1 }" >nul 2>nul
if errorlevel 1 goto MARKER_FAILED
if exist "%CMS%" goto TEMP_TARGET_PRESENT

"%OPENSSL%" cms -encrypt -binary -aes-256-cbc -in "%MARKER%" -out "%CMS%" -outform DER "%CERT%"
set "STEP_EXIT=%ERRORLEVEL%"
if not "%STEP_EXIT%"=="0" goto ENCRYPT_FAILED
if not exist "%CMS%" goto ENCRYPT_FAILED
if exist "%DECRYPTED%" goto TEMP_TARGET_PRESENT

"%OPENSSL%" cms -decrypt -binary -inform DER -in "%CMS%" -recip "%CERT%" -inkey "E:\elitesync-v10-db-backup-recipient-20260925.key.pem" -out "%DECRYPTED%"
set "STEP_EXIT=%ERRORLEVEL%"
if not "%STEP_EXIT%"=="0" goto DECRYPT_FAILED
if not exist "%DECRYPTED%" goto DECRYPT_FAILED

"C:\Windows\System32\fc.exe" /b "%MARKER%" "%DECRYPTED%" >nul 2>nul
set "STEP_EXIT=%ERRORLEVEL%"
if not "%STEP_EXIT%"=="0" goto COMPARE_FAILED

del /f /q "%MARKER%" >nul 2>nul
if errorlevel 1 goto CLEANUP_FAILED
if exist "%MARKER%" goto CLEANUP_FAILED
del /f /q "%CMS%" >nul 2>nul
if errorlevel 1 goto CLEANUP_FAILED
if exist "%CMS%" goto CLEANUP_FAILED
del /f /q "%DECRYPTED%" >nul 2>nul
if errorlevel 1 goto CLEANUP_FAILED
if exist "%DECRYPTED%" goto CLEANUP_FAILED
rmdir "%TEMPDIR%" >nul 2>nul
if errorlevel 1 goto CLEANUP_FAILED
if exist "%TEMPDIR%" goto CLEANUP_FAILED
set "CATEGORY=A_MATCH_AND_CLEAN"
set "STEP_EXIT=0"
set "RESULT=0"
goto END

:POWERSHELL_MISSING
set "CATEGORY=POWERSHELL_MISSING"
goto END
:GUARD_MISSING
set "CATEGORY=GUARD_MISSING"
goto END
:GUARD_IDENTITY_FAILED
set "CATEGORY=GUARD_IDENTITY_FAILED"
goto END
:PREFLIGHT_FAILED
set "CATEGORY=PREFLIGHT_FAILED"
goto END
:TEMP_CREATE_FAILED
set "CATEGORY=TEMP_CREATE_FAILED"
goto END
:TEMP_TARGET_PRESENT
set "CATEGORY=TEMP_TARGET_PRESENT"
goto END
:MARKER_FAILED
set "CATEGORY=MARKER_FAILED"
goto END
:ENCRYPT_FAILED
set "CATEGORY=ENCRYPT_FAILED"
goto END
:DECRYPT_FAILED
set "CATEGORY=DECRYPT_FAILED"
goto END
:COMPARE_FAILED
set "CATEGORY=COMPARE_FAILED"
goto END
:CLEANUP_FAILED
set "CATEGORY=CLEANUP_FAILED"
goto END
:END
if not "%RESULT%"=="0" if "%STEP_EXIT%"=="0" set "STEP_EXIT=1"
echo AUTH101_RESULT=%CATEGORY%;EXIT=%STEP_EXIT%
echo AUTH101_PRESS_ANY_KEY_TO_CLOSE
pause >nul
exit /b %RESULT%
