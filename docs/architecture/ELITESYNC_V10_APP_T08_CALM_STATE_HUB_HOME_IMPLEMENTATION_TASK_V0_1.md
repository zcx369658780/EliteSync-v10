# EliteSync v10｜APP-T08 Calm State Hub Home Implementation Task｜v0.1

Status: `AUTHORIZED — BOUNDED PRODUCT IMPLEMENTATION — HOME ONLY`

Date: 2026-09-13 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Read `AGENTS.md`, the accepted APP-T01 target contract, APP-T02 migration inventory, APP-T07 acceptance, and this task before execution.

Objective: replace the current fixed Match CTA Home with the Owner-approved Calm State Hub.

The first frame must remain low-density and contain at most three primary areas: Current state, Next decision, and Optional support.

Home is a projection/navigation surface. It must not become the owner of Readiness, Match, Connection, Conversation, or Relationship state.

Use only already-established or explicitly unknown state. `UNKNOWN != ABSENT`.

Required behavior:
- show a concise state summary without inventing unavailable lifecycle facts;
- show at most one primary next action;
- when Readiness is not established, the next action points to `/me/readiness`;
- otherwise use only a next step supported by accepted state; if none is available, route neutrally to Progress;
- do not mutate lifecycle state from Home;
- keep Match, Connection, Conversation, and Relationship semantically separate;
- do not restore Discover as a top-level feed.

Rendering Home must not initiate additional remote retrieval merely to fill cards. If a source would require such retrieval, show state/authority as not established instead.

Authorized source scope:
- may modify `apps/flutter_elitesync_module/lib/features/home/presentation/pages/home_page.dart`;
- may create Home-only files under `apps/flutter_elitesync_module/lib/features/home/domain/`, `presentation/state/`, and `presentation/widgets/`;
- may add narrow tests under `apps/flutter_elitesync_module/test/features/home/`;
- no router change is expected; if another source area is required, stop and report the blocker.

Verification: `dart format`, `git diff --check`, exact source assertions, and narrow Home tests / `flutter analyze --no-pub` only when an existing package graph is present. If it is absent, report executable checks as `NOT ESTABLISHED`.

Required result artifact:
`docs/architecture/ELITESYNC_V10_APP_T08_CALM_STATE_HUB_HOME_IMPLEMENTATION_RESULT_V0_1.md`

Suggested branch:
`review/app-t08-calm-state-hub-home-implementation-v0-1`

Do not merge to `main`, self-accept, or start APP-T09.

Expected classification:
`APP-T08 CALM STATE HUB HOME ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`
