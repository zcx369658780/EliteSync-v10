# EliteSync v10｜APP-RUN-01 Android Synthetic Runtime Proof Acceptance｜v0.1

Status: `ACCEPTED — ANDROID EMULATOR RUNTIME PROOF ESTABLISHED — LOCAL SYNTHETIC/DEV ENTRY VERIFIED — CLIENT INTEGRATION LANE OPEN`

Date: 2026-09-21 (Asia/Singapore).

## Independent verdict

`ACCEPT`

Candidate:

`4a9784a36a799f4354bb61e677789e7177187908`

Authority / sole parent:

`6b7cef6d2a002db08f26c6c4c97a397c477d409c`

Candidate tree:

`b2e1f79df28be22f4cbe7d9c087b77af0b4b08ea`

Accepted blobs:

- `apps/flutter_elitesync_module/lib/main_demo.dart`: `3d983548fbb6e880e04c2c8ec9804523b9e4654c`
- `apps/flutter_elitesync_module/lib/app/bootstrap/app_bootstrap.dart`: `8d85959ea355213820881015ea822eeebf1b6007`
- `apps/flutter_elitesync_module/lib/app/app.dart`: `400d7bdf243f4ae7d0e05cc135547d3951dba075`
- `apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart`: `9fa5d2c186394565602c566a2f360ecc8184609e`
- result: `32481e91d26939c2fecbd6b046de4b3c15e03eea`

## Review findings

The candidate scope is exactly the five authorized tracked paths.

The demo entry is explicitly dev/synthetic, uses loopback `127.0.0.1:9`, enables mock-domain flags, disables LiveKit/RTC, and enters the local visual fixture rather than production login.

RTC bootstrap is now gated on `AppEnv.useLiveKitRtc` in both current bootstrap watch locations. Existing production entries retain `useLiveKitRtc=true`, so this change does not silently disable production-default RTC behavior.

The focused test fixes the intended demo environment contract.

The execution receipt establishes:

- locked dependency materialization with unchanged `pubspec.lock`;
- direct C-drive generated-host Android assemble success;
- debug APK installation on Android 16 / API 36 emulator;
- launcher/process start;
- visible local synthetic/dev first frame;
- one successful swipe interaction without crash;
- no observed production EliteSync API or RTC polling during the bounded proof.

The reviewer did not independently open the executor's local screenshot files because they were not published as repository artifacts. Acceptance relies on the immutable source/result candidate plus the bounded build/install/runtime receipt, and does not claim independent visual inspection of those local images.

The visible 31-pixel debug overflow is retained as a non-blocking presentation limitation for later client work; it does not invalidate launch/interactivity proof.

## Boundary

This acceptance establishes one Android synthetic/dev runtime proof only.

It does not establish production networking, real auth/session, real participant data, production Connection writer authority, Messaging/Conversation production access, iOS runtime, release signing, store readiness, or deployment.

Final classification:

`APP-RUN-01 ACCEPTED — ANDROID SYNTHETIC/DEV APP PROCESS + FIRST FRAME + INTERACTION VERIFIED — LOCKED BUILD PATH ESTABLISHED — PRODUCTION API/RTC ISOLATED IN DEMO ENTRY — READY FOR CLIENT INTEGRATION IMPLEMENTATION`
