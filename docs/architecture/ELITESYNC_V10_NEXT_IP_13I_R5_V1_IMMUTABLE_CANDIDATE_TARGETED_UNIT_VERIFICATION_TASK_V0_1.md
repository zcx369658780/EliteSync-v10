# EliteSync v10｜Next IP-13I-R5-V1 Immutable Candidate Targeted Unit Verification Task｜v0.1

Status: `OWNER-AUTHORIZED — VERIFICATION ONLY — IMMUTABLE CANDIDATE — NO AUTHORING / NO RETRY / FRESH INDEPENDENT CLOSEOUT REQUIRED`

Date: 2026-09-19 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Verification target candidate: `d2acd8d656c2e26a97b5c4102ec02b5caeefc5f1`

Expected candidate sole parent: `41577d783794d4c7bc53f4848a300453f7bdcfea`

Expected candidate tree: `8754dd0b1f693e4e1392def8cf9bc15e204f3e8f`

Expected final blobs:

- IP-13A source:
  `2877f5804710abf7c8eba87a9d59925ad5cc405d`
- IP-13D source:
  `a81535d174015bb0ecaa9f8caeaabb7490c4354b`
- Runtime Readiness persistence application adapter:
  `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5`
- final statically corrected targeted test:
  `081dbb62597a25b0e230e1e78332033c11821529`
- implementation result:
  `365fc83575ef2e601f19f92281af3ec3821a6fcd`

## 1. Objective

Establish runtime evidence for the final immutable IP-13I-R5 candidate after the consumed original targeted run.

The original one-shot targeted test exited `1` with one failure caused by a test-only positional assertion. Production code canonicalizes the RR03 dependency list. The failing test assumed the stale dependency remained at list index `0`; canonical ordering instead placed `synthetic-member-a` first and stale `synthetic-member-b` second.

The final test blob statically corrects only that assertion by locating the dependency by `dependency_identity = synthetic-member-b`.

No production source was changed for this post-run correction.

This verification authorizes one fresh targeted PHPUnit attempt against the exact immutable candidate and no authoring.

## 2. Mandatory identity gate

Before execution:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Confirm this verification task exists on current main.
4. Fetch candidate `d2acd8d656c2e26a97b5c4102ec02b5caeefc5f1`.
5. Verify:
   - sole parent exactly `41577d783794d4c7bc53f4848a300453f7bdcfea`;
   - tree exactly `8754dd0b1f693e4e1392def8cf9bc15e204f3e8f`;
   - all five expected final blobs exactly match.
6. Use an isolated worktree with HEAD exactly at the candidate.
7. Confirm tracked/staged changes are `0 / 0` before execution.
8. Confirm the final test blob:
   - still mutates `members[0]` to make `synthetic-member-b` stale;
   - asserts the stale projected dependency by `dependency_identity`, not fixed canonical list index.
9. Stop if any identity differs.

Do not modify any tracked file.

## 3. Static verification boundary

Before runtime, confirm without editing:

- RR03 production dependency ordering is canonical/deterministic;
- the final test assertion queries the stale member by identity;
- IP-13A/IP-13D/adapter blobs are exactly the frozen production blobs listed above;
- no post-run production correction exists.

This is verification only; do not improve or refactor anything.

## 4. Vendor bootstrap

Check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist:
- Composer Case A;
- do not run Composer.

Otherwise run exactly once from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry.
No update.
No scripts/plugins.
Generated vendor artifacts remain untracked/uncommitted.
`composer.json` and `composer.lock` must remain byte/blob identical.

Expected manifest blobs:

- `composer.json`: `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`
- `composer.lock`: `66327f584d3961c2b53391bb012047dda9cc9d23`

## 5. Exact runtime verification budget

Run exactly once:

`vendor/bin/phpunit tests/Unit/RuntimeReadinessPersistenceApplicationAdapterTest.php`

No retry.

Do NOT run:

- any other PHPUnit command;
- other Unit tests;
- Feature tests;
- full suite;
- coverage;
- mutation;
- Artisan;
- `route:list`;
- migrations;
- generators;
- server;
- HTTP/client;
- provider/network;
- production;
- real/private-data operations;
- legal/Safety operations.

Do NOT run `git diff --check`; this verification performs no authoring.

## 6. Required runtime receipt

Report:

- verification task-publication commit;
- candidate SHA / sole parent / tree;
- five confirmed final blobs;
- worktree HEAD;
- confirmation final test uses identity-based stale dependency lookup;
- confirmation production canonical dependency ordering remains unchanged;
- Composer Case A/B and exact receipt if run;
- targeted PHPUnit attempt count;
- exit code;
- tests;
- assertions;
- failures/errors;
- warnings;
- deprecations;
- tracked/staged changes after verification;
- manifest/lock pre/post identities if Composer ran;
- explicit confirmation no prohibited operation ran.

If targeted PHPUnit exits `0` with all targeted tests passing, classify exactly:

`IP-13I-R5-V1 IMMUTABLE CANDIDATE TARGETED UNIT VERIFICATION PASS — FINAL STATICALLY CORRECTED RR03 TEST BLOB RUNTIME PASS ESTABLISHED — IP-13I-R5 CANDIDATE READY FOR FRESH INDEPENDENT ACCEPT/REJECT CLOSEOUT`

Otherwise report exact failure and STOP.

Do not commit, amend, rebase, merge, push candidate changes, move `main`, or create a successor task.
