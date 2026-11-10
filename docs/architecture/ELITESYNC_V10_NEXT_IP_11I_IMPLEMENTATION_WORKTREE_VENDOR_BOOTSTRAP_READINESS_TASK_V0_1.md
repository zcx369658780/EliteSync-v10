# EliteSync v10｜Next IP-11I Implementation-Worktree Vendor Bootstrap Readiness Task｜v0.1

Status: `OWNER-AUTHORIZED REMEDIATION — IMPLEMENTATION-WORKTREE READINESS ONLY — NO BUSINESS IMPLEMENTATION AUTHORITY`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Current task-authority main at publication time: `93e3c78c2b37b689f01d57eae5f49788e3c42d12`

Owner-authorized implementation base: `ef63312531504f06d77370cf095143da329cfa7f`

Blocked implementation task: `NEXT-IP-11H-BACKEND-PURE-COMMON-AUTHORITY-EVIDENCE-CONTRACT-IMPLEMENTATION-V0-1`

## 1. Purpose

Establish only the local project-vendor/test-launcher readiness required by IP-11H inside the exact implementation worktree rooted at `ef63312531504f06d77370cf095143da329cfa7f`.

This task does not implement IP-11H, create any tracked source/test/result file, run PHPUnit tests, or change implementation authority.

The reason for this task is explicit: accepted IP-11F proved vendor/PHPUnit readiness in a separate readiness worktree, but `vendor/**` is untracked/ignored and therefore is not inherited by a fresh worktree created from the accepted implementation base.

## 2. Exact worktree requirement

Use the already-created local IP-11H implementation worktree if it still satisfies all of the following:

- HEAD exactly `ef63312531504f06d77370cf095143da329cfa7f`;
- no tracked modifications;
- no staged modifications;
- the three IP-11H tracked output paths are still absent;
- it is the worktree intended for the subsequent IP-11H implementation.

If that exact local worktree no longer satisfies these conditions, create one fresh isolated worktree/branch from exactly `ef63312531504f06d77370cf095143da329cfa7f` and record that replacement. Do not branch from live `main`.

Do not rebase, merge, cherry-pick or otherwise move the implementation base.

## 3. Exact target directory

All project commands run only in:

`services/backend-laravel/`

## 4. Preflight requirements

Before any project command:

1. fresh-fetch `origin/main` only for governance provenance;
2. record current task-authority commit;
3. verify implementation worktree HEAD remains exactly `ef63312531504f06d77370cf095143da329cfa7f`;
4. verify `composer.json` and `composer.lock` exist and record SHA-256 + Git blob identities;
5. verify all three IP-11H tracked output paths are absent;
6. verify no tracked/staged change exists;
7. record exact pre-state of:
   - `vendor/autoload.php`
   - `vendor/bin/phpunit`.

If either vendor readiness locator is already present, do not reinstall; proceed directly to bounded PHPUnit version readiness check, subject to the command budget below.

## 5. Exact command budget

### Case A — vendor readiness locators both already present

Run exactly one command:

`vendor/bin/phpunit --version`

No Composer command is authorized.

### Case B — either readiness locator is missing

Run exactly one Composer attempt:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

Then, only if the Composer command exits `0` and exact `vendor/bin/phpunit` exists, run exactly one:

`vendor/bin/phpunit --version`

No retry is authorized for either command.

## 6. Composer constraints

Composer is authorized only to materialize packages already fixed by the committed `composer.lock` into local untracked/ignored `vendor/**` for this implementation worktree.

Do not:

- run `composer update`;
- change `composer.json` or `composer.lock`;
- use `--ignore-platform-reqs`;
- run Composer scripts or plugins;
- run `dump-autoload` separately;
- add/remove packages;
- use a different package source or alternate dependency file;
- copy vendor from another worktree;
- symlink vendor from another worktree;
- commit or stage vendor content.

Network access, if needed, is authorized only for package retrieval fixed by the committed lock during the single Composer install attempt.

## 7. Exact post-readiness checks

After the bounded command budget:

- verify exact presence of `vendor/autoload.php`;
- verify exact presence of `vendor/bin/phpunit`;
- record PHPUnit version outcome if attempted;
- verify `composer.json` and `composer.lock` remain byte-identical and Git-blob-identical;
- verify no tracked/staged project change exists;
- do not enumerate vendor;
- do not run PHPUnit tests;
- do not run `git diff --check` because no tracked authoring is expected from this readiness task.

## 8. Explicit prohibitions

Do not:

- create or modify the three IP-11H tracked output files;
- implement any business/common-contract code;
- run PHPUnit tests;
- run Artisan;
- run migrations, seeders, generators or cache commands;
- run application/runtime entrypoints;
- modify source, tests, config, routes, models, services or domain files;
- inspect credentials, environment secrets or production configuration;
- process real/private data;
- contact provider/product APIs;
- access Sandbox/DEP13/B12;
- reopen M1/M2/M3;
- commit or push any implementation candidate.

## 9. Result handling

This remediation task is local-readiness-only. Do not create a tracked result document.

Return a truthful execution report in chat containing:

- implementation worktree path and HEAD;
- whether Case A or Case B applied;
- Composer command attempt count/exit and package operation summary if run;
- `vendor/autoload.php` post-state;
- `vendor/bin/phpunit` post-state;
- PHPUnit version attempt count/exit/output if run;
- pre/post `composer.json` SHA-256 and Git blob;
- pre/post `composer.lock` SHA-256 and Git blob;
- tracked/staged change counts;
- explicit confirmation that no PHPUnit tests or implementation writes occurred.

## 10. Success classification

Success only if both exact readiness locators exist and the single PHPUnit version check exits `0`:

`IP-11I IMPLEMENTATION-WORKTREE VENDOR/PHPUNIT READINESS ESTABLISHED — IMPLEMENTATION BASE PRESERVED — READY TO RE-RUN IP-11H PRE-WRITE GATE — NO BUSINESS IMPLEMENTATION PERFORMED`

If Composer or PHPUnit version readiness fails, report the exact blocker and STOP. Do not remediate further.
