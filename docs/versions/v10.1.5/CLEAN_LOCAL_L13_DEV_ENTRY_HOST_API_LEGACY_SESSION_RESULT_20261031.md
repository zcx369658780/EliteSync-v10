# Laravel13 clean local entry, host API and synthetic legacy session result
Date: 2026-10-31. Task V1015_CLEAN_LOCAL_L13_DEV_ENTRY_HOST_API_LEGACY_SESSION_20261031; formal task Blob bd5aa7ee6fc4682ece9136d3b025e6b5d421ef80.

**LOCAL_L13_VENDOR_READY / HOST_LOOPBACK_API_REACHABILITY_PASS / L11_BINARY_TO_L13_SYNTHETIC_SESSION_COMPATIBILITY_PASS / FOCUSED_REGRESSION_PARTIAL / SERVICES_STOPPED / ASTRA_REVIEW_PENDING.**

## Exact source and new entry
Candidate sole Parent is invocation fresh main **310456834fd653229b27748e44912de5ba9df66f**, Root **058fee5d498f98e381920c85d83300ec59b9ebaf**. Accepted apps **3468a3dd97da7accfda2539a0f8d8f68931a6110**, services **049a8676cc90b3b830e32a524c172720e800fa37** remain unchanged. Astra acceptance71afd7e2da6d1ad56bb53664ec347fe0aa5364ba / Blob542a34926fddf2e53917a1e362ebded8e8dc43ce was read fresh.

New independent entry alias CLEAN_L13_DEV_20261031 contains5322 files/141638016bytes from exact main. Every archive path/mode/Blob, native trees and native main Commit identity were checked; a shallow Git boundary was recorded. Source Git status is clean before/after work. Volume/file identity: [3028074659, 562949958255059]. Private absolute path and full SHA256 inventory are LOCAL_ONLY. No default entry switch or product source/main ref change occurred. This candidate adds five docs-only files: Result, Manifest, Handoff and two generic manual scripts.

## Frozen real runtime
Existing Docker Desktop4.97.0 / Engine29.9.2 linux/amd64 signatures, executable/process identity, desktop-linux context and named-pipe server PID matched. License basis is Owner's earlier small-business free-use confirmation; no new terms accepted. No Desktop/WSL/global tools start/restart/install/upgrade.

Official PHP8.4.27 bookworm and MariaDB10.11.19 jammy Index→linux/amd64 Manifest→Config→RootFS closure matched local images. OCI Index image Id was not mistaken for Config Digest. Ubi9 was not used or cleaned. One offline task-owned PHP build added pdo_mysql and unzip; unzip SHA256 matched signed Debian package metadata and InRelease signature was verified with the image's Debian archive keyring. Composer2.11.1 matched its official SHA256.

All114 immutable lock-ref archives were metered from official codeload into a new cache. Actual PHP8.4.27 Composer validate --strict, install --no-scripts --no-plugins --no-interaction and check-platform-reqs passed; lock Blob e236fbc960c1dd08c1fecb9aeed4926b4cab3933 unchanged, solver0. First install failed because read-only cache mode was unset; actual Composer source/cache files were inspected, then second/final install passed. No network/platform guard was relaxed. Two existing PSR-4 fixture warnings remain.

## Actual Windows loopback and independent DB
A new labeled schema/volume was verified empty before migration. Principal, hostname, server_id, nonprotected port52463 and effective Laravel APP_DB_CONNECTION=mysql matched the task;90 tables resulted. No old/real DB was accessed.

The initial IPv6-only MariaDB socket refused IPv4; only the empty task DB container was recreated with its explicit interface IPv4. Initial internal-only API networking did not realize the published port: Windows connection-refused, container DB-backed health PASS. API recreation added an own frontend bridge with IP masquerading disabled while DB stayed internal. Realized host binding is exactly127.0.0.1, API binds its explicit container IP, never0.0.0.0. No global firewall/route/ACL/Desktop setting changed. Repairs consumed2/2 controlled restart/recreation slots.

Real Windows Python HTTP with proxies/redirects disabled passed health200, anonymous401, invalid bearer401, pre-recreation token200, wrong-password422, login200, new token200 and final health200; including initial failure, host requests9. Independent MariaDB readback found one synthetic user/four tokens surviving API recreation. **Populated MariaDB process/volume restart was NOT_RUN: restart budget exhausted.** This is not crash recovery.

Windows CIM found no matching listener despite working host HTTP; the observation is retained. Realized Docker bindings were127.0.0.1; complete OS-wide exposure/egress enforcement is not newly claimed. Runtime external requests0.

## Actual L11→L13 synthetic binary session
7805 hash-verified backup dependency PHP/JSON files/37757768bytes were copied into a new private closure. No old .env, APP_KEY, real session/cookie/account/DB was copied/read/run. Actual Laravel11.48.0 SessionGuard, Store, FileSessionHandler and EncryptCookies generated a fictional login cookie/wire bytes with a fresh test key; actual Laravel13.39.0 used the same new key/store.

Seven cases passed: positive login, wrong key, tamper, provider revocation, logout, old-cookie replay denial, expired-file denial. Expiry used controlled mtime of a new synthetic file, not physical120-minute waiting. An initial harness assertion mistook SessionGuard.id()!=null for authentication; id can remain when a provider denies the user. Original failure was preserved; final harness uses check(), framework bytes unchanged, all seven cases rerun.

This proves isolated framework-binary synthetic compatibility, not a full old-business HTTP/production-cookie migration. REAL_LEGACY_L11_COOKIE_NOT_PROVEN remains.

## Regression and bounded observations
Mixed Feature/Unit batch: **60 tests /284 assertions /58 passed /2 errors**. Both AuthQuestionnaireApiTest errors come from backend-only mounting omitting accepted root question_bank JSON. Framework/session/connection checks passed. No assertions/tests/product source were weakened or skipped.

The exact PHPUnit command and SQLite :memory: isolation were PREPARE-logged. Nested SQLite migrate:fresh1 and failed seed batches2 were conservatively attributed from actual test/source readback after that parent command; no retrospective sub-operation PREPARE was fabricated. Including MariaDB, migration2/2 and seed2/2 are charged. No further migration/seed/restart was performed. Root question-bank mounting remains an explicit entry/test gap; the batch is PARTIAL, not green.

Other retained local failures: Windows PowerShell duplicate type-data/module load (existing PowerShell7 used without policy change); missing new Git-ref parent directory (only owned metadata resumed); official registry CDN redirect allowlist extension with exact expected hash; unsupported Composer cache config command; original network and session-harness failures; CIM listener observation. Raw failures are LOCAL_ONLY.

## Budget, protection and shutdown
Prepublication snapshot: 1602.19s/14400s; local logical 398787599 /allocated 450310000bytes, plus conservative4GiB charge for all new engine image/container/volume/log allocation, within16GiB. DB apparent166897132 /allocated167419904bytes; full engine accounting retained. This upper bound is not exact VHD attribution. Counters: {"container_http": 2, "container_restarts": 2, "feature_batches": 1, "host_http": 9, "migrations": 2, "offline_builds": 1, "php_cli": 42, "seeds": 2, "service_groups": 3, "source_digests": 7, "supply_bytes": 103825408, "supply_requests": 133, "vendor_installs": 2}. Supply byte charges conservatively include body/header allowances. Final readback/seal totals are in LOCAL_ONLY terminal receipts.

Old Laravel11.48.0 HEAD4bebc8f394248e254c1368a06fbdee5d2c883301, dirty252,refs527,index/HEAD unchanged. Backup11066 files/240617393bytes, Manifest SHA2563f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d: all identities/sizes and160 bounded SHA samples passed; old restore proof retained, not rerun. Old18 captured views/two ACL/122 originals/3183Seed/five roots and13 seals preserved. No old write/move/delete/ACL change.

All four running own containers stopped; old task variants also stopped. New source/vendor, images, containers and synthetic volume preserved; manual scripts parser-checked, not used to spend an extra restart. No autostart/default switch. Handoff gives guarded manual operation and rollback boundaries.

No acceptance is self-signed. v10.1.5 ACs10 PARTIAL/1 OPEN, AC05 OPEN,G2 false, real Push pending,v10.1.6 NOT_STARTED. Windows E_NOTIMPL, prior fixture/budget incidents, restricted identity, OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN, OS_ENFORCEMENT_NOT_PROVEN and EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED remain. Production/real users, Flutter/Gradle/APK/ADB, RTC/AEC, real H264 and physical15/30 days NOT_RUN.

Evidence: DIRECT_GITHUB_OBJECT / CODEX_REPORTED_LOCAL_RUNTIME_OR_STATIC / LOCAL_ONLY_RAW / NOT_RUN / NOT_PROVEN. Secrets/cookies/vendor/DB/raw paths are LOCAL_ONLY. Enclosing native Git objects and final fresh receipt bind candidate Commit/Parent/Root/paths without circular self-SHA. After readback permanently STOP, no successor or budget reuse.
