# EliteSync v10｜Next IP-13H Laravel HTTP Transport Adapter Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-19 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `866930281c5a55fd8a9ec5e56f5d7ff2aa95ada3`

## 1. Objective

Implement the first bounded Laravel HTTP adapter over the accepted IP-13F transport-neutral request/response contract, exactly as selected and accepted by IP-13G.

This slice creates one v2 HTTP endpoint, one dedicated invokable controller, one targeted Feature test, and one result document.

The HTTP layer remains a transport adapter only. It must not become a source authority, domain writer, permission grant, bearer capability, authentication authority, protected-action executor, production API authority or real-data path.

Controlling invariants:

- `HTTP_TRANSPORT != SOURCE_AUTHORITY`
- `HTTP_STATUS != DOMAIN_OUTCOME`
- `ROUTE != PERMISSION`
- `CONTROLLER != DOMAIN_WRITER`
- `MIDDLEWARE_PASS != PROTECTED_ACTION_GRANT`
- `TRANSPORT_SUCCESS != DOMAIN_SUCCESS`
- `IP_13F_ENVELOPE_REMAINS_CANONICAL_TRANSPORT_SEMANTICS`

Future slice name:

`NEXT-IP-13H-LARAVEL-HTTP-TRANSPORT-ADAPTER-IMPLEMENTATION-V0-1`

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from exactly that commit.
5. Verify the three new output paths are absent.
6. Verify and record blobs for:
   - `services/backend-laravel/routes/api.php`
   - `services/backend-laravel/bootstrap/app.php`
   - `services/backend-laravel/app/Domain/TransportNeutralApplicationRequestResponseContract.php`
   - `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
   - `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
   - IP-13F acceptance
   - IP-13G result
   - IP-13G acceptance
   - `services/backend-laravel/phpunit.xml`
   - `services/backend-laravel/composer.json`
   - `services/backend-laravel/composer.lock`
7. Stop rather than adapt if authority/base/path differs.

Recommended branch:

`review/next-ip-13h-laravel-http-transport-adapter-v0-1`

## 3. Exact tracked write scope

Exactly these four paths are authorized:

1. modify `services/backend-laravel/routes/api.php`
2. create `services/backend-laravel/app/Http/Controllers/Api/V2/Contracts/TransportEnvelopeController.php`
3. create `services/backend-laravel/tests/Feature/Api/V2/TransportEnvelopeTest.php`
4. create `docs/architecture/ELITESYNC_V10_LARAVEL_HTTP_TRANSPORT_ADAPTER_IMPLEMENTATION_RESULT_V0_1.md`

No other tracked file may change.

The route-file modification is limited to:
- one new controller import; and
- one new POST route inside the existing `Route::prefix('v2')->middleware('secure.transport')->group(...)`.

No line inside the v1 route group may change.

## 4. Exact route

Add exactly:

`POST /api/v2/contracts/application-envelope`

using:

`App\Http\Controllers\Api\V2\Contracts\TransportEnvelopeController`

as a dedicated invokable controller.

The route must remain inside the existing v2 `secure.transport` group.

Do not add:
- v1 alias;
- compatibility route;
- auth middleware;
- throttle middleware;
- route parameters;
- route name;
- extra middleware.

## 5. Controller boundary

The controller must:

1. be a dedicated single-action controller with `__invoke`;
2. accept Laravel `Request`;
3. receive a `TransportNeutralApplicationRequestResponseContract`;
4. obtain only the decoded JSON body object;
5. pass only that decoded body array unchanged to `handle()` exactly once;
6. not merge query parameters, headers, route parameters, IP address, user-agent, authenticated user, middleware data, trace data, timestamps or defaults;
7. map only IP-13F transport disposition / bounded condition to HTTP status;
8. return the complete IP-13F envelope directly as JSON;
9. add no `success`, `data`, permission, domain-success or auth wrapper.

The controller must not import/call/inject:
- IP-13E directly;
- IP-13D directly;
- IP-13A directly;
- PDO/repository classes;
- v1 controllers.

## 6. Construction boundary

Do not modify service providers or bootstrap.

Use Laravel's existing container auto-wiring only if the exact accepted concrete dependency chain resolves without new binding.

If controller construction cannot resolve in the targeted Feature test without modifying an unauthorized file, STOP and report the blocker. Do not create a helper, singleton, provider binding or bootstrap change.

A test-only container binding is permitted inside the exact Feature test solely where necessary to:
- supply a shared synthetic IP-13F instance for same-process correlation/conflict testing; or
- inject a deterministic test double of IP-13F for an explicit controller-failure test.

Such test-only binding creates no runtime or production binding authority.

## 7. Exact HTTP status mapping

Map only these accepted transport cases:

- IP-13F `DELIVERED_TO_APPLICATION` -> HTTP `200`
- `REQUEST_REJECTED + MALFORMED_REQUEST_ENVELOPE` -> `400`
- `REQUEST_REJECTED + UNKNOWN_TOP_LEVEL_FIELD` -> `400`
- `REQUEST_REJECTED + MALFORMED_FAMILY_PAYLOAD` -> `400`
- `UNKNOWN + UNSUPPORTED_FAMILY` -> `400`
- `REQUEST_REJECTED + REQUEST_IDENTITY_PAYLOAD_CONFLICT` -> `409`
- `REQUEST_REJECTED + APPLICATION_DISPATCH_REJECTED` -> `500`
- any unrecognized disposition/condition pair -> fail-closed `500`

Hard semantic rules:

- `MISSING` remains HTTP 200 when delivered.
- `DENIED` remains HTTP 200 when delivered.
- `UNKNOWN` remains HTTP 200 when delivered.
- `STALE`, `SUPERSEDED`, `INVALIDATED` remain HTTP 200 when delivered.
- source-carried `REJECTED` remains HTTP 200 when delivered.
- 2xx does not mean domain success.
- 4xx does not mean authoritative domain rejection.
- 409 is request-correlation conflict only, not source revision/domain conflict.

Do not throw ValidationException/Auth/Authorization/HttpException for expected IP-13F outcomes.

## 8. Request-body rule

The HTTP body must be passed as decoded JSON object with exactly the canonical semantic keys controlled by IP-13F:

- `request_identity`
- `family`
- `semantic_payload`

Do not pre-validate canonical semantics with Laravel `FormRequest` or `$request->validate()`.

Malformed or extra fields must reach IP-13F unchanged so IP-13F remains the canonical envelope validator.

If the body cannot be represented as an array/object at all, the controller may fail closed to an IP-13F-compatible malformed request envelope without inventing semantic fields.

## 9. Response-body rule

Return the full IP-13F response envelope directly.

Mandatory fields must survive JSON serialization, including all explicit false non-authority fields.

Do not filter away false values.

Do not expose:
- raw private fixture/source material;
- private extensions;
- debug exception messages in non-debug mode;
- controller/container internals.

## 10. Authentication boundary

Do not add `auth:sanctum` or any auth/session/token middleware.

Authentication remains `RETAINED_UNKNOWN`.

Do not infer actor/role/subject/participant/audience/purpose from:
- authenticated user;
- header/token;
- cookie/session;
- route;
- IP;
- user-agent;
- secure.transport pass.

`secure.transport` remains transport-security middleware only and creates no source/domain permission.

## 11. Mandatory Feature-test obligations

The exact Feature test must cover at least:

1. selected POST route exists under `/api/v2`;
2. no v1 alias exists;
3. route executes within `secure.transport` expectations without adding auth semantics;
4. canonical body reaches IP-13F unchanged;
5. query/header/IP/user-agent values are not merged;
6. malformed request envelope -> 400 with direct IP-13F envelope;
7. unknown top-level field -> 400;
8. malformed family payload -> 400;
9. unsupported family -> 400 and IP-13F `UNKNOWN`;
10. same request identity + same payload can return identical cached envelope;
11. same request identity + changed payload -> 409 with no second semantic dispatch;
12. delivered mutation with authoritative outcome UNKNOWN -> 200 and no domain-success claim;
13. source-carried REJECTED -> 200;
14. MISSING -> 200, not 404;
15. DENIED -> 200, not 403;
16. UNKNOWN -> 200 when delivered;
17. STALE -> 200;
18. SUPERSEDED -> 200;
19. INVALIDATED -> 200;
20. GRANTED remains descriptive/non-bearer, `protected_action_executed=false`, and execution-time revalidation remains true;
21. all mandatory non-authority false fields survive JSON;
22. private synthetic sentinel does not leak;
23. `APPLICATION_DISPATCH_REJECTED` -> 500 with no domain meaning;
24. an unrecognized disposition/condition pair -> fail-closed 500;
25. expected IP-13F conditions do not use Laravel 422/401/403 exception mapping;
26. v1 route source is unchanged except no lines in v1 group;
27. no auth/session/token semantics are added;
28. no production/real-data authority is created.

The test may use conspicuous synthetic-only request/evidence fixtures.

## 12. Existing exception renderer

Do not modify `bootstrap/app.php`.

Expected IP-13F outcomes must be returned deterministically by the controller.

Unexpected uncaught framework/runtime exceptions may flow to the existing global renderer. The targeted test may verify safe non-debug 500 behavior only if it can do so without modifying bootstrap or unrelated files.

## 13. Explicit prohibitions

Do not modify/create:

- service providers;
- `bootstrap/app.php`;
- middleware;
- FormRequest;
- API resources;
- auth/session/token implementation;
- v1 routes/controllers;
- IP-13F/IP-13E/IP-13D/IP-13A source/tests;
- Eloquent/models;
- migrations/schema;
- persistent database;
- production config;
- queues/events/jobs;
- provider/network;
- client/UI;
- telemetry expansion;
- real/private data;
- legal/Safety policy;
- retention/deletion/TTL/legal hold.

No deployment or production operation.

## 14. Same-worktree vendor bootstrap

Check only:
- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, Composer Case A and do not run Composer.

Otherwise exactly one authorized command from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. Manifest/lock must remain byte/blob identical.

## 15. Exact command budget

Exactly one targeted Feature PHPUnit attempt:

`vendor/bin/phpunit tests/Feature/Api/V2/TransportEnvelopeTest.php`

No retry.

Do not run:
- full suite;
- other Feature tests;
- Unit tests;
- coverage;
- mutation tests;
- Artisan;
- `route:list`;
- migrations;
- generators;
- server;
- provider/network commands.

After final authoring run exactly once:

`git diff --check`

Read-only Git commands needed for topology/scope/publication are allowed.

## 16. Result document

Record:

- task-publication commit;
- candidate SHA / sole parent / tree / ahead-behind;
- exact four-path write scope;
- route-file pre/post blob and exact changed lines summary;
- controller/test/result SHA-256 + blobs;
- fixed input blobs;
- exact route/method/controller;
- controller construction proof;
- exact body pass-through rule;
- exact HTTP status mapping proof;
- evidence that delivered semantic conditions remain 200;
- request-correlation 409 proof;
- exception/fail-closed 500 proof;
- mandatory non-authority preservation;
- v1 isolation proof;
- authentication retained UNKNOWN;
- Composer receipt;
- targeted Feature test receipt;
- warnings/deprecations;
- `git diff --check`;
- manifest/lock pre/post identities;
- retained unknowns/non-authorities;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification:

`IP-13H LARAVEL HTTP TRANSPORT ADAPTER IMPLEMENTED FOR BOUNDED V2 CONTRACT ENDPOINT — POST /api/v2/contracts/application-envelope DELEGATES ONLY TO ACCEPTED IP-13F — TRANSPORT-ONLY 200/400/409/500 MAPPING PRESERVES DOMAIN DISTINCTIONS — V1 LEGACY / AUTH / PERSISTENCE / PRODUCTION BOUNDARIES PRESERVED — TARGETED FEATURE TEST PASS — NO PRODUCTION/REAL-DATA AUTHORITY CREATED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
