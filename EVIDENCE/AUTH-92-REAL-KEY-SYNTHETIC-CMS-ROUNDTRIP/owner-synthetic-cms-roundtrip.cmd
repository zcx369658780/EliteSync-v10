@echo off
setlocal DisableDelayedExpansion
set "KEY=C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem"
set "CERT=C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.cert.pem"
set "OPENSSL=C:\Program Files\Git\usr\bin\openssl.exe"
set "MARKER=D:\EliteSync-v10\EVIDENCE\AUTH-92-REAL-KEY-SYNTHETIC-CMS-ROUNDTRIP\synthetic-marker.txt"
set "CMS=D:\EliteSync-v10\EVIDENCE\AUTH-92-REAL-KEY-SYNTHETIC-CMS-ROUNDTRIP\synthetic-cms.der"
set "DECRYPTED=D:\EliteSync-v10\EVIDENCE\AUTH-92-REAL-KEY-SYNTHETIC-CMS-ROUNDTRIP\synthetic-decrypted-marker.txt"
set "RESULT=1"

if not exist "%KEY%" goto KEY_MISSING
if not exist "%CERT%" goto CERT_MISSING
if not exist "%OPENSSL%" goto OPENSSL_MISSING
if exist "%MARKER%" goto TARGET_PRESENT
if exist "%CMS%" goto TARGET_PRESENT
if exist "%DECRYPTED%" goto TARGET_PRESENT

> "%MARKER%" echo AUTH92_SYNTHETIC_ONLY_20260925
if errorlevel 1 goto MARKER_FAILED
if not exist "%MARKER%" goto MARKER_FAILED
for %%F in ("%MARKER%") do if not "%%~zF"=="32" goto MARKER_FAILED

"%OPENSSL%" cms -encrypt -binary -aes-256-cbc -in "%MARKER%" -out "%CMS%" -outform DER "%CERT%"
if errorlevel 1 goto ENCRYPT_FAILED
if not exist "%CMS%" goto ENCRYPT_FAILED

"%OPENSSL%" cms -decrypt -binary -inform DER -in "%CMS%" -recip "%CERT%" -inkey "%KEY%" -out "%DECRYPTED%"
if errorlevel 1 goto DECRYPT_FAILED
if not exist "%DECRYPTED%" goto DECRYPT_FAILED

fc /b "%MARKER%" "%DECRYPTED%" >nul 2>nul
if errorlevel 1 goto COMPARE_FAILED

del /f /q "%MARKER%" >nul 2>nul
if errorlevel 1 goto CLEANUP_FAILED
if exist "%MARKER%" goto CLEANUP_FAILED
del /f /q "%CMS%" >nul 2>nul
if errorlevel 1 goto CLEANUP_FAILED
if exist "%CMS%" goto CLEANUP_FAILED
del /f /q "%DECRYPTED%" >nul 2>nul
if errorlevel 1 goto CLEANUP_FAILED
if exist "%DECRYPTED%" goto CLEANUP_FAILED

echo AUTH92_ROUNDTRIP_MATCH_AND_CLEAN
set "RESULT=0"
goto END

:KEY_MISSING
echo AUTH92_FAILURE=KEY_MISSING
goto END
:CERT_MISSING
echo AUTH92_FAILURE=CERT_MISSING
goto END
:OPENSSL_MISSING
echo AUTH92_FAILURE=OPENSSL_MISSING
goto END
:TARGET_PRESENT
echo AUTH92_FAILURE=TARGET_PRESENT
goto END
:MARKER_FAILED
echo AUTH92_FAILURE=MARKER_FAILED
goto END
:ENCRYPT_FAILED
echo AUTH92_FAILURE=ENCRYPT_FAILED
goto END
:DECRYPT_FAILED
echo AUTH92_FAILURE=DECRYPT_FAILED
goto END
:COMPARE_FAILED
echo AUTH92_FAILURE=COMPARE_FAILED
goto END
:CLEANUP_FAILED
echo AUTH92_FAILURE=CLEANUP_FAILED
goto END
:END
echo AUTH92_PRESS_ANY_KEY_TO_CLOSE
pause >nul
exit /b %RESULT%
