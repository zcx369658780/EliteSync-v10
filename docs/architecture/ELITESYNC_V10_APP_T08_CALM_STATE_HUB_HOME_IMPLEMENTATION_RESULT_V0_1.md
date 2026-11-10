# EliteSync v10｜APP-T08 Calm State Hub Home Implementation Result｜v0.1

Status: `CANDIDATE — READY FOR FRESH INDEPENDENT ACCEPT/REJECT REVIEW`

Date: 2026-09-13 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority and fixed start

- Fresh-fetched `origin/main`: `a1c5111c31f0c4a621648d24142ad785c07c9050`.
- APP-T08 task blob: `35b040a8d0d3ebb6b48f22d84290882b805eb6eb`.
- Candidate branch: `review/app-t08-calm-state-hub-home-implementation-v0-1`.
- Candidate worktree was created directly from the fixed `origin/main`.

This candidate replaces only the fixed Match-first Home with the bounded Calm State Hub. Home remains a projection/navigation surface and does not own or mutate Readiness, Match, Connection, Conversation, or Relationship.

## 2. Exact changed files

1. `apps/flutter_elitesync_module/lib/features/home/presentation/pages/home_page.dart`
2. `apps/flutter_elitesync_module/lib/features/home/presentation/state/calm_home_projection.dart`
3. `apps/flutter_elitesync_module/test/features/home/presentation/pages/home_page_test.dart`
4. `docs/architecture/ELITESYNC_V10_APP_T08_CALM_STATE_HUB_HOME_IMPLEMENTATION_RESULT_V0_1.md`

No router, Readiness, Match, Connection, Conversation/Chat, Discover, Settings/Privacy/Notifications, Relationship, backend/API/database/service, dependency/build, or global Browser/model/notify source was modified.

## 3. Home projection inputs

The production Home projection uses only the accepted current authority boundary:

- Readiness authority: `NOT YET ESTABLISHED`;
- Match enrollment/mutation authority: `NOT YET ESTABLISHED`;
- authoritative runtime Product Connection source: `NOT YET ESTABLISHED`;
- production Conversation access: `NOT YET ESTABLISHED` and fail closed;
- Relationship: Phase 2, excluded from the MVP current-state list.

No runtime provider is watched to enrich these cards. The projection is a constant, privacy-minimal presentation snapshot. Its vocabulary distinguishes `authoritative`, `notYetEstablished`, and `unknown`; `UNKNOWN` is rendered literally rather than converted to absence or failure.

## 4. Authority boundaries

Home does not infer state from authentication, route availability, local data, remote feed data, Match legacy state, Connection/Conversation rows, or message activity.

Preserved:

`authenticated != ready`

`UNKNOWN != ABSENT`

`Match != Connection != Conversation != Relationship`

Visiting Home performs navigation only when the user chooses an entry. It does not opt into Match, request or accept Connection, grant messaging consent, open/send Conversation as a lifecycle mutation, or create Relationship state.

## 5. First-frame information hierarchy

The first frame contains exactly three primary areas:

1. `当前状态 · Current state`
2. `下一步 · Next decision`
3. `可选支持 · Optional support`

The layout is calm, deliberate, and low-density. It contains no feed, urgency, countdown, gamified score, progress percentage, candidate content, or multiple competing primary actions.

The copy follows:

`状态清楚 -> 权限清楚 -> 下一步清楚 -> 原因清楚 -> 退出路径清楚`

It states that Home is summary-only, visiting changes no lifecycle state, unavailable authority is not user failure or ineligibility, and the user may stop and return later.

## 6. Current-state mapping

| Domain | Current Home projection | Meaning |
|---|---|---|
| Readiness | `状态尚未建立` | Authentication is not treated as readiness evidence |
| Match | `权限尚未建立` | No Match enrollment or mutation authority is invented |
| Connection | `状态尚未建立` | No runtime Product Connection source is connected |
| Conversation | `权限尚未建立` | No `CN_ACTIVE` plus mutual messaging-consent evidence is available |
| Relationship | omitted | Phase 2; not inferred or shown as an MVP current-state card |

The state area contains no peer/candidate identity, message text or preview, unread count, Compatibility total score, private Matching Inputs, or Safety/report/block evidence.

## 7. Next-decision selection rule

The projection model encodes:

1. when Readiness authority is not established or is unknown, the sole primary CTA routes to `/me/readiness`;
2. when Readiness is authoritative, only an explicitly supplied authoritative next decision may be used;
3. when Readiness is authoritative but no authoritative next decision is available, the neutral fallback routes to `/progress`.

The current production projection therefore shows exactly one primary CTA, `前往准备状态`, targeting `/me/readiness`. It does not route directly to Match, Connection mutation, messaging consent, Conversation content, or Relationship.

## 8. Optional-support disposition

One visually secondary `TextButton` points to the already-established `/me/privacy-settings` surface. It does not mutate privacy, consent, or lifecycle state from Home.

Discover is not restored as a top-level feed. No Phase-2 Explore or Support Library implementation is claimed.

## 9. No-side-effect evidence

`home_page.dart` and `calm_home_projection.dart` import no Riverpod provider, repository, data source, API client, feed controller, Conversation provider, Match countdown/result provider, private Profile provider, or participant/candidate entity.

Rendering Home therefore does not watch or invoke:

- Conversation list/detail/messages;
- peer/thread data;
- legacy Match countdown/result;
- current Home/Discover remote feed;
- private Profile values;
- participant/candidate records.

The only actions are explicit navigation callbacks to Readiness or privacy settings. No remote/private retrieval, cache read, mutation, telemetry, or synthetic lifecycle success was added.

## 10. Narrow synthetic tests

The Home test source covers:

- the Readiness-first, authoritative-next, and neutral Progress selection rules;
- literal `UNKNOWN` preservation;
- exactly three primary areas;
- four privacy-minimal MVP domain rows and no Relationship row;
- exactly one `FilledButton` primary CTA and one secondary `TextButton`;
- navigation to Readiness and privacy settings;
- explanatory separation and no-side-effect copy;
- absence of candidate, message-preview, unread, score, countdown, opt-in urgency, and Discover-feed copy;
- dark-theme CTA contrast and ordinary phone-width construction.

Because the existing package graph is absent, these executable tests are present as bounded synthetic coverage but were not run.

## 11. Retained UNKNOWN / not-established boundaries

- Readiness runtime authority as consumed by Home: `NOT YET ESTABLISHED`.
- Match enrollment/mutation authority: `NOT YET ESTABLISHED`.
- Product Connection runtime source and mutations: `NOT YET ESTABLISHED`.
- Conversation runtime access remains fail closed until authoritative `CN_ACTIVE` plus mutual messaging consent.
- Relationship remains Phase 2 and is not inferred.
- Exact Phase-2 Explore/Support Library: not implemented.
- Private Home enrichment and remote feed data classification: not adopted as lifecycle authority.

## 12. Verification ledger

| Check | Outcome |
|---|---|
| Fresh fetch and fixed `origin/main` | PASS — `a1c5111c31f0c4a621648d24142ad785c07c9050` |
| Task blob | PASS — `35b040a8d0d3ebb6b48f22d84290882b805eb6eb` |
| Dedicated branch/worktree start | PASS |
| `dart format` over exact changed Dart files | PASS, with expected `flutter_lints` URI warnings because package graph is absent |
| `git diff --check` | PASS |
| Exact allowlist/structure/route/no-side-effect assertions | PASS |
| Narrow Home tests | `NOT ESTABLISHED` — package graph absent; not run |
| `flutter analyze --no-pub` | `NOT ESTABLISHED` — package graph absent; not run |
| `pub get` | NOT RUN |
| Flutter runtime / emulator / ADB | NOT RUN |
| Backend/network/private-data execution | NOT RUN |

The formatting warning does not establish executable analysis or test success and is not a product failure.

## 13. Blockers and bounded APP-T09 readiness

No blocker prevents publication of this bounded candidate for independent review. The retained authority gaps intentionally keep Home neutral and prevent richer lifecycle recommendations.

APP-T09 is not started or authorized by this result. It is recommended as bounded-ready only after a fresh independent APP-T08 ACCEPT verdict and separate Owner dispatch. This result does not grant that successor authority.

## 14. Candidate classification

`APP-T08 CALM STATE HUB HOME ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`
