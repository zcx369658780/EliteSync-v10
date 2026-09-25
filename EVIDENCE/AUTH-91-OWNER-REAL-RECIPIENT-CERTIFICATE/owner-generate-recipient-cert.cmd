@echo off
if not exist "C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem" goto key_missing
if exist "C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.cert.pem" goto cert_exists
if not exist "C:\Program Files\Git\usr\bin\openssl.exe" goto openssl_missing
echo AUTH91_READY_FOR_NATIVE_PASSPHRASE_PROMPT
"C:\Program Files\Git\usr\bin\openssl.exe" req -new -x509 -sha256 -days 365 -key "C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem" -out "C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.cert.pem" -subj /CN=EliteSync-v10-DB-Backup-Recipient -addext basicConstraints=critical,CA:FALSE -addext keyUsage=critical,digitalSignature,keyEncipherment -batch
if errorlevel 1 goto generation_failed
if not errorlevel 0 goto generation_failed
if not exist "C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.cert.pem" goto output_missing
echo AUTH91_REQ_EXIT_ZERO
echo AUTH91_CERT_OUTPUT_PRESENT
goto hold

:key_missing
echo AUTH91_FAILURE=KEY_MISSING
goto hold

:cert_exists
echo AUTH91_FAILURE=CERT_ALREADY_EXISTS
goto hold

:openssl_missing
echo AUTH91_FAILURE=OPENSSL_MISSING
goto hold

:generation_failed
echo AUTH91_FAILURE=REQ_NONZERO
goto hold

:output_missing
echo AUTH91_FAILURE=OUTPUT_MISSING
goto hold

:hold
echo AUTH91_PRESS_ANY_KEY_TO_CLOSE
pause
