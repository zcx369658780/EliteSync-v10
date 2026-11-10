@echo off
if not exist "C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem" goto key_missing
if not exist "C:\Program Files\Git\usr\bin\openssl.exe" goto openssl_missing
echo AUTH90_READY_FOR_NATIVE_PASSPHRASE_PROMPT
"C:\Program Files\Git\usr\bin\openssl.exe" pkey -in "C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem" -noout
if errorlevel 1 goto unlock_failed
if not errorlevel 0 goto unlock_failed
echo AUTH90_UNLOCK_EXIT_ZERO
goto hold

:key_missing
echo AUTH90_FAILURE=KEY_MISSING
goto hold

:openssl_missing
echo AUTH90_FAILURE=OPENSSL_MISSING
goto hold

:unlock_failed
echo AUTH90_FAILURE=UNLOCK_NONZERO
goto hold

:hold
echo AUTH90_PRESS_ANY_KEY_TO_CLOSE
pause
