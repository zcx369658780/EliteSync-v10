# EliteSync v10｜NEXT BA-07-SR01 APP-T09 Notification Presentation Provenance Resolution Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — SOURCE/PROVENANCE RESOLUTION ONLY — NO TECHNICAL-DESIGN OR IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `69551904c2e67b507283dcc25efdde6312f9de02`

## 1. Purpose

Resolve only the two BA-07 provenance blockers reported by candidate `bc1ec61efe83be48cb5e9b803436585b84807541`:

1. whether an accepted APP-T09 generic-notification-presentation foundation exists under a different exact repository path/name/provenance;
2. if it exists, fix its exact result path/blob, candidate commit/provenance, acceptance path/blob/commit, and the exact semantics that BA-07 may consume;
3. if it does not exist on current `main`, establish that absence precisely and determine whether APP-T12/B01 or another already accepted artifact supplies an equivalent bounded presentation contract sufficient for BA-07 without inventing APP-T09 contents.

This task does not redesign BA-07, modify the BA-07 candidate, implement notifications, or authorize backend/client work.

## 2. Fixed start

Fresh-fetch `origin/main` and require exactly:

`69551904c2e67b507283dcc25efdde6312f9de02`

Read `AGENTS.md` first.

Verify task-sheet blob after publication before substantive work.

## 3. Exact bounded sources first

Read only:

1. `docs/architecture/ELITESYNC_V10_NEXT_BA_07_NOTIFICATION_DOMAIN_EVENT_PAYLOAD_DELIVERY_AUTHORITY_TECHNICAL_DESIGN_TASK_V0_1.md`
2. candidate commit `bc1ec61efe83be48cb5e9b803436585b84807541` and only its notification-design artifact
3. `docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-F only
5. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-07 only

Do not enumerate directories.
Do not access application source/tests.
Do not access the old repository.

## 4. Authorized high-density provenance search

Because the exact paths are already known missing, this task authorizes repository-default-branch code search limited to `docs/architecture`, `docs/product`, and `docs/decisions` for the following exact tokens/phrases only:

- `APP-T09`
- `APP_T09`
- `generic notification`
- `notification presentation`
- `generic notification presentation`
- `notification foundation`
- `lock-screen`
- `lock screen`
- `status_author`
- `notification payload`
- `notification copy`
- `privacy-minimal notification`

No synonym expansion beyond this list.
No recursive directory listing.
No broad `notification`-only search.

Open only plausible documentation/governance hits.

## 5. Required validation matrix

Complete all independently evaluable checks before stopping. Do not stop at the first missing hit.

At minimum validate and report each of the following:

1. exact requested APP-T09 acceptance path exists/absent;
2. exact requested APP-T09 result path exists/absent;
3. `APP-T09` token hit count;
4. `APP_T09` token hit count;
5. generic-notification phrase hit count;
6. notification-presentation phrase hit count;
7. whether any plausible result artifact establishes generic external copy;
8. whether any plausible acceptance artifact independently accepts that result;
9. whether candidate/result/acceptance ancestry is provable;
10. whether accepted result blob remains unchanged on current main;
11. whether in-app vs external/lock-screen audience separation is established;
12. whether route/payload identity is explicitly non-authorizing;
13. whether external copy is generic/privacy-minimal by default;
14. whether private Conversation content is excluded from external copy;
15. whether notification delivery/open/dismiss are separated from domain outcomes;
16. whether APP-T12-B01 `status_author` establishes fail-closed profile-like loading;
17. whether APP-T12 merely corroborates APP-T09 or is itself sufficient for the bounded BA-07 presentation requirement;
18. whether B01-F independently establishes generic external copy and audience separation;
19. whether BA-07 task itself explicitly supplies the generic-external requirement;
20. whether any missing APP-T09 detail is actually necessary to the four-layer BA-07 semantic contract;
21. whether any missing APP-T09 detail is only historical provenance/detail verification;
22. whether accepting BA-07 without APP-T09 would invent or overclaim historical provenance;
23. whether a substitute accepted artifact can be bound without semantic expansion;
24. whether any source conflict exists;
25. whether any remaining blocker is product-semantic vs provenance-only;
26. whether any retained unknown must be added;
27. whether BA-07 candidate needs modification vs acceptance-note qualification only;
28. whether BA-07 can be independently accepted after this source-resolution result;
29. exact candidate scope remains one file;
30. no implementation/legal/Safety/private-data authority is created.

Output totals:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N`

List every retained unknown and every blocker.

## 6. Resolution outcomes

### Outcome A — exact APP-T09 accepted chain found

Record exact paths, commits, blobs, ancestry, and the bounded semantics BA-07 may consume.

### Outcome B — exact APP-T09 chain absent, equivalent accepted authority sufficient

Record exact substitute accepted source(s), prove they establish all BA-07-required generic-presentation semantics, and explicitly state that APP-T09 historical provenance remains unavailable but is non-blocking for BA-07 semantic acceptance.

### Outcome C — no sufficient accepted authority

Preserve the exact missing semantic/provenance facts and classify BA-07 as still blocked. Do not invent them.

## 7. Exact output

Produce exactly one candidate:

`docs/architecture/ELITESYNC_V10_APP_T09_NOTIFICATION_PRESENTATION_PROVENANCE_RESOLUTION_RESULT_V0_1.md`

Write only that file.

Recommended branch:

`review/next-ba-07-sr01-app-t09-notification-presentation-provenance-resolution-v0-1`

After publishing, report branch, candidate, sole parent, tree, result blob, exact scope, validation totals, retained unknowns/blockers, and `git diff --check`; then STOP.

Do not merge or self-accept.
Do not modify BA-07 candidate.
Do not start implementation or any successor task.

Expected success classifications:

`APP-T09 PROVENANCE RESOLVED — ACCEPTED SOURCE CHAIN FIXED — BA-07 READY FOR INDEPENDENT ACCEPTANCE`

or

`APP-T09 EXACT CHAIN ABSENT — EQUIVALENT ACCEPTED NOTIFICATION PRESENTATION AUTHORITY SUFFICIENT — HISTORICAL PROVENANCE GAP RETAINED — BA-07 READY FOR INDEPENDENT ACCEPTANCE`

Hard-stop classification:

`APP-T09 PROVENANCE / REQUIRED PRESENTATION AUTHORITY REMAINS INCOMPLETE — BA-07 ACCEPTANCE BLOCKED — NO RULES INVENTED`
