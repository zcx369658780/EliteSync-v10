# EliteSync v10 APP-T11 Legacy Match Cutover Task v0.1

Status: `AUTHORIZED — BOUNDED PRODUCT IMPLEMENTATION — LEGACY MATCH CUTOVER ONLY`

Read `AGENTS.md`, accepted APP-T01, APP-T02, APP-T05/06/07/10 acceptances, then this task.

Objective: make the accepted canonical Match path the sole target Match behavior and retire only legacy participant-linked Match seams whose consumers are statically proven replaced.

First perform a bounded static consumer inventory for:
- the legacy branch in `MatchPortalPage`;
- `matchCountdownProvider`, `matchResultProvider`, `matchDetailProvider`;
- legacy countdown/result/detail/intention/feedback pages and routes;
- legacy Match notification routing;
- `eligibleMatch` / `legacyPeer` only where they are direct legacy-Match compatibility forms.

Rules:
1. `MatchPortalPage` must resolve canonical Match for target production behavior.
2. Legacy direct Match routes should redirect to accepted Progress/canonical Match where safe.
3. A legacy seam may be retired only when no active consumer remains after cutover.
4. Mixed canonical/legacy files must keep canonical members intact.
5. If an active consumer remains outside this task's authorized scope, retain that seam and report the exact residual dependency.
6. APP-T07 Conversation privacy/consent gates must remain unchanged and stronger than route compatibility.
7. Do not create new domain authority, backend endpoints, persistence, or lifecycle states.

Authorized areas: legacy Match presentation pages/providers/repository methods/data-source methods identified by APP-T02, `app_route_names.dart`, `app_router.dart`, directly affected notification routing, and directly affected Chat route compatibility types. Canonical Match lifecycle semantics, Connection, Conversation consent/access authority, Readiness, Home, Privacy Control Center, Relationship, backend architecture, build/dependency configuration, and global configuration are out of scope.

Verification: static consumer checks, `dart format`, `git diff --check`, and narrow tests / `flutter analyze --no-pub` only if an existing valid package graph is present. Do not run `pub get` merely to create evidence. If package graph is absent, executable tests/analyze remain `NOT ESTABLISHED`.

Required result:
`docs/architecture/ELITESYNC_V10_APP_T11_LEGACY_MATCH_CUTOVER_RESULT_V0_1.md`

Report exact changed paths, before/after consumer inventory, canonical replacement for each retired seam, retained compatibility debt/blockers, proof Conversation gates remain intact, verification, and bounded APP-T12 readiness.

Suggested branch: `review/app-t11-legacy-match-cutover-v0-1`

Do not merge, self-accept, or start APP-T12.

Expected classification:
`APP-T11 LEGACY MATCH CUTOVER ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`
