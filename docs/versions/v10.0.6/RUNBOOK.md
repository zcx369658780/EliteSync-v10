# v10.0.6 dedicated local development runbook

Use only the Owner-authorized dedicated development resources. These are actual local steps, not production deployment. Do not copy the original root .env, import old data or reuse a real account. The tested worktree/SDK versions/artifact hashes are in [execution report](EXECUTION_REPORT.md).

## Existing retained environment

Worktree `C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`. Database container `elitesync-v1006-db`, persistent volume `elitesync-v1006-db-data`, loopback43316, DB `elitesync_v1006_dev`. Private development credentials/configuration are retained locally under the evidence root's `secrets/` and backend `.env`; they are not downloadable from this candidate.

Do not initialize/seed again to demonstrate persistence. Target ID2 is intentionally banned at the end of verification; normal ID3 remains usable. A future fresh validation dataset must be explicitly identified instead of silently resetting final evidence.

## Fresh reproduction within the same approved scope

1. Check container/volume/path ownership and port availability before creation. Reuse only the known owned resources. Do not kill unrelated port owners or delete old assets.
2. Create a private `docker.env` with MARIADB_DATABASE=elitesync_v1006_dev, dedicated MARIADB_USER plus freshly generated MARIADB_PASSWORD/MARIADB_ROOT_PASSWORD. Do not put secrets in command argv/logs. Container creation uses `--env-file <private-file>`:

```powershell
docker volume create --label elitesync.version=v10.0.6 elitesync-v1006-db-data
docker run -d --name elitesync-v1006-db --label elitesync.version=v10.0.6 --env-file <private-docker.env> -p 127.0.0.1:43316:3306 -v elitesync-v1006-db-data:/var/lib/mysql mariadb@sha256:8020e05c4c498d06c87f0a1db010eb79bd6f8fb30e9b763d4690c34ce1e61008
```

These create commands apply only to absent owned resources. Existing tested resources need only `docker start`; this task's final resources are not deleted or recreated.

3. Under services/backend-laravel, install locked dependencies with `composer install --no-interaction`; no update. Generate a dedicated ignored `.env` with APP_ENV=local, APP_DEBUG=false, APP_URL=http://127.0.0.1:8000, fresh APP_KEY, DB_CONNECTION=mysql, DB_HOST=127.0.0.1, DB_PORT=43316, DB_DATABASE=elitesync_v1006_dev and the private dedicated DB credentials. **APP_SESSION_DRIVER=database** is required (this repository does not read SESSION_DRIVER); APP_SESSION_CONNECTION=mysql may be explicit. SESSION_COOKIE=elitesync_v1006_session; SESSION_SECURE_COOKIE=false for this loopback HTTP dev environment. CACHE_STORE=file, QUEUE_CONNECTION=sync, MAIL_MAILER=log. ADMIN_PHONES must explicitly contain only the fictional admin19900000601; ALLOW_PUBLIC_DEV_MATCHING=false. Do not publish APP_KEY/passwords.
4. Private V1006_CREDENTIALS_FILE points to JSON `{"accounts":{"admin":{"phone":"19900000601","password":"<private generated>"},"target":{"phone":"19900000602","password":"<private generated>"},"control":{"phone":"19900000603","password":"<private generated>"}}}`. Those are the only seeded accounts. Seeder requires dedicated local DB and refuses collisions with other generation records. Repeat seeding preserves existing city/disabled state.
5. From repo root, first initialization only:

```powershell
pwsh -NoProfile -File docs/versions/v10.0.6/start-dev.ps1 -Initialize -EvidenceDirectory <fresh-local-run-path>
```

Subsequent startup omits `-Initialize`. Script validates exact DB/config/container label, waits for readiness, creates generated runtime directories, starts real PHP Laravel8001 and threaded loopback transport8000. All business responses come from Laravel; no mock backend. Raw safe PHP/front logs go to the fresh path. Stop only verified owned PIDs. Preserve volume and private configuration. No migration/seed is performed on ordinary restart.

## Build and installed APP

Use existing Flutter3.41.7/JDK17.0.18/SDK36.1. Resolve locked pub dependencies in apps/flutter_elitesync_module without upgrading lockfiles. Dedicated Gradle home must carry existing configured proxy/cache; do not alter global settings. Then:

```powershell
pwsh -NoProfile -File docs/versions/v10.0.6/build-local.ps1 -GradleHome <dedicated-gradle-home>
```

The host build regenerates android-x64 release AAR using --no-pub and ELITESYNC_V1006_LOCAL_BUILD=true, then debug APK. Existing Kotlin/AGP/Gradle versions remain. Required missing locked build dependencies may download from trusted sources as approved; no global upgrade. The release-mode AAR is an existing host dependency, not a production release.

Use only dedicated AVD elitesync_v1006_api36, existing Android36.1 x86_64 image and explicit serial emulator-5580 (verify ownership if already running). No wipe of other AVDs:

```powershell
adb -s emulator-5580 reverse tcp:8000 tcp:8000
adb -s emulator-5580 install -r apps/android/app/build/outputs/apk/debug/app-debug.apk
```

Check actual Bootstrap/BuildConfig/Dart endpoint consistency: localhost8000, WS empty, local debug=true, mock/synthetic=false, native Baidu bootstrap=false. Actual app uses existing MainActivity/Flutter entry and real auth/profile HTTP.

## Reproduction scenario and limits

Before ban: target login→existing Me/private profile/edit page→change city→**保存城市**→server confirmation. Fresh GET/api/v1/profile/basic and SQL readback must match same ID. Leave/re-enter, logout/login, then container and Laravel restart without seed; fresh reads must remain identical. Full save/recompute button remains but algorithms are outside this test.

Independent browser localhost8000/admin: admin login→queryID2→explicit confirm→disable. Verify ID2 banned, tokens/sessions0; old token profile/city/refresh rejected, new login403. Still-mounted APP next save must return login notice and clear caches, never display success. Normal ID3 real login/city POST+GET remain successful. Restart again without seed; both users' states persist. Browser logout then GET/admin must fail closed.

Finite test commands are preserved verbatim in evidence receipt JSON. PHP Feature tests use their isolated test database (SQLite configured by existing phpunit.xml), not the final persistent MariaDB acceptance dataset. MariaDB proof is the actual APP/Web/API/DB run. Flutter tests use --no-pub; final16-file Dart analysis checks stdout **No issues found!** as well as exit0.

Do not restore backups, touch original3306, use production credentials, start BE-12/private messages/RTC/matching, upgrade SDK or start a successor. Astra acceptance remains outstanding.
