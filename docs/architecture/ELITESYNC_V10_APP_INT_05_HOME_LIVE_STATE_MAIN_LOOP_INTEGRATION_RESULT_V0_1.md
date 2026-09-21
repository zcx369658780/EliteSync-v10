# EliteSync v10｜APP-INT-05 Home Live-State + Main-Loop Integration Result｜v0.1

Status: COMPLETE
Date: 2026-09-22
Authority: `77ab03389c3cce6dc7498d8a76f1873bdcfc44fd`
Branch: `impl/app-int-05-home-live-state-v0-1`

## Delivered slice

- Added the explicit `useSyntheticHomeProjection` gate. Its default is `false`; only `main_demo.dart` enables it.
- Added a read-only Home projection provider. When the gate is disabled it returns the existing static fail-closed `CalmHomeProjection.current` before subscribing to synthetic state.
- In the synthetic dev demo, Home watches only `navigationGuardProvider`, `matchRoundProjectionProvider`, `connectionPresentationProvider`, and `conversationAccessProvider`.
- Extended Home presentation authority with `syntheticDevelopment` and visibly labels the four summaries as Synthetic.
- Match summary uses `CanonicalMatchLifecycleAdapter`; loading/error states remain unknown rather than inventing a proposal.
- Home keeps the existing Current state / Next decision / Optional support structure and exactly one primary navigation action. Home performs no lifecycle mutation.

## Main-loop result

The next decision follows the existing presentation state:

1. readiness not ready -> `meReadiness`;
2. Match unavailable -> `progressMatch`;
3. Connection non-active -> `progressConnection`;
4. Connection active and Conversation non-active -> `messages` for messaging consent;
5. Conversation active -> `messages`.

Connection invalidation is consumed from the existing providers: closing the synthetic Connection changes Home to `CN_CLOSED`, observes Conversation as `CV_LOCKED`, and returns the primary action to Connection.

## Validation receipt

- `flutter pub get --enforce-lockfile`: PASS; `pubspec.lock` remained `b56c4b2c45bab65106c12e4d75d6c5b34209aeb4`.
- `flutter analyze --no-pub`: 2 attempts. Attempt 1 found three task-change errors; the bounded correction removed them. Attempt 2 reported 0 errors and 18 pre-existing info/warning diagnostics; the command returned 1 because of those baseline diagnostics.
- Targeted Flutter command: 2 attempts. Attempt 1 exposed a Home next-decision selection defect; attempt 2 PASS, 17 tests.
- Gradle cache: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-04-gradle-home`.
- Dependency gate, without refresh: PASS on attempt 1 in 43.212 seconds.
- `:app:assembleDebug`: PASS on attempt 1 in 137.293 seconds.
- APK: `build\host\outputs\apk\debug\app-debug.apk`, 1,380,317,731 bytes.
- Emulator: `sdk_gphone64_x86_64`, `emulator-5554`, Android API 36.
- Installation: the first replacement install reported insufficient storage; the task-authorized old generated host uninstall succeeded, then fresh install succeeded.
- Cold launch: PASS; package `com.elitesync.flutter_elitesync_module.host`, launcher `.MainActivity`, process PID 4320.

## Android interaction proof

In one cold-launched process:

1. Home visibly showed `READY · Synthetic`, `MT_PROPOSAL_PRESENTED · Synthetic`, `CN_NONE · Synthetic`, and `CV_LOCKED · Synthetic`; its primary action was `查看连接`.
2. The Home action opened Connection. Request then simulated recipient accept produced `CN_ACTIVE`.
3. Returning Home showed `CN_ACTIVE · Synthetic`, `CV_LOCKED · Synthetic`, and primary action `前往消息同意`.
4. The Home action opened Messages. Request messaging consent then simulated recipient accept produced `CV_ACTIVE`.
5. Returning Home showed `CN_ACTIVE · Synthetic`, `CV_ACTIVE · Synthetic`, and primary action `查看消息`.
6. Returning to Connection and closing it produced `CN_CLOSED`.
7. Returning Home showed `CN_CLOSED · Synthetic`, `CV_LOCKED · Synthetic`, and primary action `查看连接`.
8. The process remained alive with no crash.

PID-scoped log observation covered 82 lines after the cold launch:

- production EliteSync API requests: 0;
- real WebSocket: 0;
- RTC / LiveKit: 0;
- fatal / crash: 0.

The only observed URL was the debug Dart VM service on loopback `127.0.0.1`.

## Scope

No bounded-repair file outside the normal eight-path write set was used. Generated `.android/`, `.dart_tool/`, `build/`, APK, Gradle cache, logs, screenshots, and UI dumps are excluded from publication.

Final classification:

`APP-INT-05 COMPLETE — HOME CALM STATE HUB CONSUMES LIVE SYNTHETIC READINESS/MATCH/CONNECTION/CONVERSATION PRESENTATION — NEXT DECISION UPDATES THROUGH MAIN LOOP — CONNECTION INVALIDATION REFLECTED IMMEDIATELY — ANDROID MAIN-LOOP PROOF PASS — NO PRODUCTION API/SOCKET/RTC — READY FOR MAIN-LOOP PERSISTENCE + RECOVERY HARDENING`
