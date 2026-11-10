@echo off
if exist "C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem" goto target_exists
if not exist "C:\Program Files\Git\usr\bin\openssl.exe" goto openssl_missing
echo AUTH88_READY_FOR_NATIVE_PASSPHRASE_PROMPT
"C:\Program Files\Git\usr\bin\openssl.exe" genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -aes-256-cbc -out "C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem"
if errorlevel 1 goto generation_failed
if not errorlevel 0 goto generation_failed
if not exist "C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem" goto output_missing
echo AUTH88_GEN_EXIT_ZERO
echo AUTH88_OUTPUT_PRESENT
goto hold

:target_exists
echo AUTH88_FAILURE=TARGET_ALREADY_EXISTS
goto hold

:openssl_missing
echo AUTH88_FAILURE=OPENSSL_MISSING
goto hold

:generation_failed
echo AUTH88_FAILURE=GENERATION_NONZERO
goto hold

:output_missing
echo AUTH88_FAILURE=OUTPUT_MISSING
goto hold

:hold
echo AUTH88_PRESS_ANY_KEY_TO_CLOSE
pause
