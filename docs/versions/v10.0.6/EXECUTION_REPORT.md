# v10.0.6 candidate — real city persistence and Blade disable loop

Status: **CODEX_IMPLEMENTED_AND_RUNTIME_VERIFIED_SCOPED / AWAITING_ASTRA_FINAL_ACCEPTANCE**. This report is execution evidence, not independent acceptance. Main was not merged; no successor started.

## Fixed authority and source

- Frozen plan: `dbe02b9ba603b79820f77ee28663787e405ccc4f`, Blob `77eee557325449543710fc4d5fe2b10aa712fa46`.
- Fixed code start: `3a78c2c81859db682369fd6e03f6d98a3c2bbeb2`, Tree `59969abfc9d04185769b22af5f7ea5d629007a33`.
- Branch: `codex/v10.0.6-restoration-admin`; worktree `C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`.
- Build/test product source anchor: `6a6642aa457188866a1b8cd6d9cc733aff86a0c4`, Tree `faede5665a4ffa386bf23257af08a2b46be89351`. Later candidate changes are operational scripts, restoration ledger and evidence; APP/backend source and test bytes remain identical to this anchor. Manifest gives each object's identity; final candidate commit/tree is delivered separately to avoid a self-referential hash.
- Live main readback at delivery preparation: `f59767526615925470551d97c6cb2c1720c5bb83`. Its later documents did not change the frozen code start and were not merged into this candidate.

## Actual module changes

Android adds an explicit local debug build path with consistent host/Dart localhost8000 endpoints, empty WS target and disabled Baidu bootstrap. The existing MainActivity→new Flutter AAR→main_prod chain remains. Nonlocal defaults remain.

Flutter adds independent city POST followed by fresh strict GET equality confirmation, while preserving full profile save/recompute. Session rejection clears authentication and profile snapshots, shows a login notice, and protects against late network/cache results from a previous user. Local restoration configuration prevents unrelated bootstrap/RTC warmup; it does not mock auth/profile HTTP. Home/Guard authority is unchanged.

Laravel adds strict shared administrator access (active role=admin AND explicit phone list), shared transactional disable/token/session revocation, active-account checks and refresh recheck; Blade login/logout/search/disable with CSRF; dedicated three-account seed with exact DB/environment guard and repeat-state preservation. Existing city endpoint/domain behavior is reused. No BE-12/message lifecycle or matching algorithm was expanded.

## Environment actually used

Dedicated MariaDB10.11.18 container `elitesync-v1006-db`, volume `elitesync-v1006-db-data`, database `elitesync_v1006_dev`, binding **127.0.0.1:43316**. Official image digest `mariadb@sha256:8020e05c4c498d06c87f0a1db010eb79bd6f8fb30e9b763d4690c34ce1e61008`. 57 migrations and exactly three fictional users: admin ID1, target ID2, control ID3. Data records are marked test/synthetic to exclude matching; software mock/synthetic switches were false.

PHP8.5.3/Composer2.9.5, Flutter3.41.7/Dart3.11.5, JDK17.0.18, Gradle8.14/AGP8.11.1/Kotlin2.2.20 unchanged. Locked dependencies installed/reused; no SDK/lock upgrade. Dedicated Gradle home uses existing cache and configured proxy; global settings untouched. Official Flutter storage source applied per process.

AVD `elitesync_v1006_api36`, existing36.1 x86_64 image, explicit serial `emulator-5580`, reverse tcp8000→8000. Laravel PHP binds127.0.0.1:8001; a threaded loopback-only transport front binds8000 and forwards actual Laravel responses. This solves Windows PHP's speculative-browser-connection stall without adding mock responses or business logic.

The repository uses **APP_SESSION_DRIVER**, not SESSION_DRIVER. Initial private config used the latter and fixture receipts showed0 DB sessions. Final private config/startup check uses APP_SESSION_DRIVER=database. A real Laravel ordinary-user session fixture then produced1 persistent row, without granting administrator access. This is explicit test setup, not a browser login claim. Actual Web disable deleted it; replay returned401. Both failed fixture attempts remain.

## Real combined operations, same user IDs

1. Installed current-source debug APK. Actual APP logged in ID2, entered existing edit-profile page, saved `V1006 City A` using **保存城市**. UI displayed server-readback confirmation. API GET and MariaDB users.city matched; astro rows remained0.
2. Left/re-entered page, performed actual APP logout/relogin, then restarted MariaDB and Laravel without seed and cold-started APP. Fresh API/DB/UI readback still matched ID2/city. Cached identity is recorded only as identity/cleanup evidence, never as persistence proof.
3. Actual Edge browser logged in administrator ID1, queriedID2, confirmed and submitted disable form. Success response: **用户 2 已禁用，令牌和持久会话已撤销。** DB recorded disabled=true/moderation_status=banned, city unchanged, target tokens0/sessions0.
4. Still-mounted APP city save received401, cleared session/profile caches and returned login with **登录已失效或账号已被禁用，请重新登录。** No success was shown. Cold start remained logged out.
5. Old target profile GET/city POST/refresh returned401; new target login403. Normal control ID3 login200, real city POST200 and fresh GET `V1006 Control City`; control disabled=false.
6. Repeated MariaDB and Laravel restart, without seed or target fixture recreation after disable. ID2 city/banned state/tokens0/sessions0 persisted, ID3 city/normal persisted. API rejection/control results unchanged. Actual browser reread showed ID2禁用/ID3正常; logout then direct/admin navigation returned login.

Published screenshots and safe DB/API receipts in [evidence](evidence/) corroborate the chains. Browser and APP operation narratives are Codex observations; Astra has not rerun or independently accepted them yet.

## Actual automated checks

| Check | Result | Original evidence |
|---|---|---|
| Nine directly related Flutter test files, --no-pub |62/62 PASS, exit0|flutter-final-03 stdout/stderr/receipt|
|16 changed Dart source/test files|**No issues found!**, exit0|dart-final-04|
|V1006AdminWebTest + AuthPasswordApiTest|21 tests/123 assertions, exit0;2 vendor deprecations|php-final-01|
|Four scoped existing AdminApiTest cases|4 tests/38 assertions, exit0;2 vendor deprecations|php-admin-scoped|
|Final AAR/host debug build|BUILD SUCCESSFUL, exit0|android-build-09|
|Actual APK install|Success, exit0|apk-install|
|Final Python transport parse|OK, exit0|operations-syntax|

PHP checks include empty-list rejection even local, whitelisted ordinary role rejection on Web/API, enforced valid-CSRF illegal-role POST refusal, missing-CSRF419, logout guest check, disabled token/refresh/profile/new-login refusal, city invalid input and no algorithm rows. The normal-user actual browser login was also rejected. Feature test CSRF is explicitly enabled instead of relying on Laravel's unit-test bypass.

Initial Flutter regressions and exit0 lint findings were retained and fixed; final analysis stdout was inspected. Broader initial PHP suite30 retained five unrelated questionnaire/matching missing-bank errors; no assertions removed. Relevant scoped suite25 passes, not a full backend PASS. Composer final install readback reports nothing to install/update/remove, with2 PSR4 fixture warnings. PHP8.5 vendor deprecations and build strip/NDK warnings remain disclosed. Initial Composer install and migration full raw streams were not captured; later install/migration status/seed/DB evidence does not impersonate those missing original streams.

Build attempts01–06 failed environment/plugin/dependency resolution;07 was explicitly cancelled after a stalled mirror download (exit4294967295),08 wrong working-directory command failed;09 succeeds from official source with android-x64. Verbose registry/thread debug logs remain local and are excluded from publication. First health probes after DB restart failed during warmup; normal startup readiness polling succeeded. No service/data reseed occurred during persistence checks.

## Artifacts and accessibility

- AAR relative path: `apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`;3,953,207 bytes; SHA256 `6521ff058334f16b24994ed03c8ee8271d0c886efbb7232ce65a93371448b9ad`.
- APK: `apps/android/app/build/outputs/apk/debug/app-debug.apk`;213,058,140 bytes; SHA256 `213c1a3a7081c339626e841706fad08d88e793e8610c93492d297be20cd3f965`.
- Both paths are under the above Windows worktree, local-only; no GitHub release/download URL is claimed. `libapp.so` hash matches both containers (`45b6ba7bf6bb5e2aa1e344a1e4b38ad6c4c45b82494a6f23d5c44bfbcf19e01f`);9 compared Flutter assets match.
- Necessary source/tests/safe logs/screenshots/manifest are in the fixed GitHub candidate. Larger local diagnostic originals remain under `C:/Users/zcxve/.codex/visualizations/2026/10/12/01a13084-65a4-7c71-bf32-fa60a68d2099/v1006`; private credentials/tokens/cookies/config are deliberately unpublished.
- [RUNBOOK](RUNBOOK.md) describes startup, initialization and build. Existing owned volume/private configuration retained; no long-running monitor is created.

## Protection and retained gaps

Original D:/EliteSync-v10 HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`, index/status/AGENTS supplement and **105 actually captured named files** match before/after exactly. Actual staged0/tracked43/untracked-normal209 equals this invocation's original snapshot; historical208 is not asserted. The historical109-file set was not fully rehashed;105 is the explicit measured scope. Unrelated worktrees/EVIDENCE were not targeted or cleaned. Normal shared Git object registration/commits are allowed; no manual prune/reset/clean/stash/main merge.

**NOT_RUN:** original3306, SQL/VHDX content/import/mount/decryption, historical/private data, real accounts/SMS/production/physical devices, full questionnaire/algorithms/matching/RTC/chat/business modules and all-app suite; BE-12/V57/H1/H2/D0/M6/production permissions remain closed. No complete historical restoration or production readiness claim. Ordinary APP logout was observed to clear local authentication/cache; revocation of all server tokens on ordinary logout is not claimed. Ban revocation is independently measured.

AC-01–AC-06 are presented with scoped implementation/runtime evidence for Astra review; AC-07 requires fixed publication followed by **Astra independent final acceptance**. This candidate does not self-accept, integrate main or authorize v10.0.7.
