# EliteSync v10｜Next IP-11F Backend Vendor Bootstrap and PHPUnit Readiness Remediation Task｜v0.1

Status: `OWNER-AUTHORIZED BOUNDED REMEDIATION TASK — PRE-IMPLEMENTATION ONLY — NO BUSINESS IMPLEMENTATION AUTHORITY`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

## 1. Objective

Close only the exact IP-11E vendor/test-harness readiness blockers for the selected backend direction `services/backend-laravel/`.

This task may establish a local project vendor tree strictly from the already committed `composer.lock`, then verify the two exact readiness locators and the PHPUnit executable/version. It must not implement product/business code, run tests, run Artisan, migrate, generate code, start services, inspect real/private data, or create production authority.

## 2. Fixed input facts

Accepted IP-11E facts:

- PHP available: `8.5.3`
- Composer available: `2.9.5`
- `composer.json` present
- `composer.lock` present
- `vendor/autoload.php` absent
- `vendor/bin/phpunit` absent
- source boundary: `app/Domain/`
- unit-test boundary: `tests/Unit/`

## 3. Exact write/read scope

Repository working directory for project-tool commands:

`services/backend-laravel/`

Allowed project-generated write scope:

- `services/backend-laravel/vendor/**` only

The following tracked/project files MUST remain byte-identical:

- `services/backend-laravel/composer.json`
- `services/backend-laravel/composer.lock`
- all files under `services/backend-laravel/app/**`
- all files under `services/backend-laravel/tests/**`
- all route/config/database/source files

No other repository path may be modified.

## 4. Command budget

After fresh-fetch and governance reads, the project command budget is exactly:

1. One Composer install attempt from the committed lock:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

2. If and only if command 1 exits successfully and `vendor/bin/phpunit` exists, one version-only check:

`vendor/bin/phpunit --version`

No retry is authorized.

No other Composer command is authorized.

## 5. Network and side-effect boundary

Network access is authorized only as required by the single bounded Composer install attempt to obtain packages already fixed by `composer.lock`.

The install MUST NOT:

- update dependencies
- modify `composer.lock`
- run Composer scripts
- run Composer plugins
- execute Artisan
- run migrations
- generate application code
- run tests
- start the application
- contact product/provider APIs
- process real/private data

If Composer requests a semantic choice, lock update, credential, plugin enablement, script execution, unsupported platform override, or changed dependency resolution, STOP without workaround.

Do not use `--ignore-platform-reqs` or any equivalent override.

## 6. Required pre/post evidence

Before the install attempt record:

- fixed task/base commit
- SHA-256 or Git blob identity of `composer.json`
- SHA-256 or Git blob identity of `composer.lock`
- absence/presence of exact `vendor/autoload.php`
- absence/presence of exact `vendor/bin/phpunit`

After the attempt record:

- Composer exit code and concise bounded outcome
- whether `vendor/autoload.php` exists
- whether `vendor/bin/phpunit` exists
- PHPUnit version command outcome if permitted
- post identities of `composer.json` and `composer.lock`
- `git diff --check`
- tracked working-tree changes, which must exclude all paths except the result document

Do not enumerate the vendor tree beyond the two exact readiness locators.

## 7. Success/stop outcomes

Choose exactly one:

### Outcome A

`BACKEND VENDOR/PHPUNIT READINESS ESTABLISHED — LOCKFILE PRESERVED — READY FOR FINAL OWNER IMPLEMENTATION-GATE DRAFTING — NO TESTS OR BUSINESS IMPLEMENTATION RUN`

Requires:

- Composer install exit 0
- `composer.json` unchanged
- `composer.lock` unchanged
- exact `vendor/autoload.php` present
- exact `vendor/bin/phpunit` present
- one `vendor/bin/phpunit --version` check succeeds
- no source/test/config tracked changes

### Outcome B

`BACKEND VENDOR BOOTSTRAP FAILED OR INCOMPLETE — EXACT BLOCKER RECORDED — IMPLEMENTATION GATE REMAINS CLOSED`

Use for any non-zero install, missing required locator, failed PHPUnit version check, or platform/dependency blocker that does not require an unauthorized workaround.

### Outcome C

`STOPPED BEFORE/AT REMEDIATION BOUNDARY — UNAUTHORIZED SIDE EFFECT OR SEMANTIC CHOICE REQUIRED`

Use if proceeding would require lock mutation, scripts/plugins, platform bypass, credentials, broader path writes, source changes, or any other unapproved action.

## 8. Validation matrix

Provide at least 120 independently checkable rows.

Report:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N`

All unknowns and blockers must be explicit.

## 9. Required artifact

Publish exactly one result document:

`docs/architecture/ELITESYNC_V10_IP_11F_BACKEND_VENDOR_BOOTSTRAP_AND_PHPUNIT_READINESS_REMEDIATION_RESULT_V0_1.md`

Candidate must contain exactly that tracked file relative to its sole parent. Do not commit `vendor/**` or any generated dependency files.

## 10. Durable exclusions

- no business/domain implementation
- no source/test edits
- no PHPUnit test execution
- no Artisan
- no migrations
- no generators
- no production/runtime execution
- no real/private data
- no Sandbox/DEP13/B12
- M1 remains exhausted
- M2 remains deferred
- M3 remains blocked
- client direction remains retained for later and untouched

Then STOP for fresh independent ACCEPT/REJECT review.
