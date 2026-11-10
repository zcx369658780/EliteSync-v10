# EliteSync v10｜NEXT IP-08 Cross-Domain API / Interface Planning Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — DOCUMENTARY API/INTERFACE PLANNING ONLY — NO IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `3eabe67f843ac2bf3643f5fd691ff1e3f412ea8a`

## 1. Purpose and authority

Produce one technology-neutral cross-domain API/interface planning artifact that consumes the independently accepted IP-01 through IP-07 documentary implementation plans without changing their semantics.

This task may define semantic interface responsibilities, request/response obligation classes, authority-binding requirements, concurrency/reconciliation obligations, projection/read obligations, protected-action revalidation contracts, error/condition classes, downstream persistence/client contract needs, and exact retained seams.

This task does not authorize endpoint implementation, wire format, protocol selection, OpenAPI/GraphQL schema generation, database schema, service topology, framework/language selection, code generation, SDK/client work, deployment, private-data processing, production traffic, legal conclusions, or Safety Operations.

## 2. Required reads

After fresh-fetching `main`, read `AGENTS.md` first. Then read only the accepted IP-01 through IP-07 acceptance artifacts and their accepted result artifacts, plus the accepted post-BA01..BA07 implementation-entry review and the common read-model/implementation-planning contracts where directly needed.

Do not enumerate directories or broaden discovery.

## 3. Exact output

Write exactly:

`docs/architecture/ELITESYNC_V10_CROSS_DOMAIN_API_INTERFACE_PLAN_V0_1.md`

## 4. Required semantic interface families

Plan technology-neutral interface families for at minimum:

- authoritative mutation submission;
- authoritative-outcome reconciliation;
- current projection retrieval;
- protected-action revalidation;
- correction/revocation/supersession observation;
- Readiness prerequisite-set and derived-readiness consumption;
- Match participation/proposal/decision operations;
- Product Connection request/decision/pause/resume/close operations;
- Messaging Consent request/decision/revoke operations;
- Conversation live-read/live-send decision evaluation;
- Calm Home read-only composition inputs and output envelope;
- Notification source-event / eligibility / payload / delivery-evidence boundaries.

The plan must preserve each domain owner, exact subject/participant bindings, audience/purpose, actor/role, aggregate/context identity, revision/currentness, freshness, correction/revocation/supersession, logical-intent/idempotency and privacy-minimality requirements.

## 5. Request/response semantic obligations

For each interface family, define without choosing field names or protocol syntax:

- minimum semantic request inputs;
- authority owner and exact scope;
- authenticated actor and role requirements where applicable;
- subject/participant and aggregate/context bindings;
- audience/purpose binding;
- expected revision/currentness/freshness obligations;
- logical-intent/idempotency identity semantics;
- authoritative outcome classes;
- unknown/unavailable/stale/superseded/incomparable/projection-lag handling;
- privacy-minimal response obligations;
- action-time revalidation requirements;
- correction/revocation invalidation behavior;
- downstream consumer restrictions.

## 6. Cross-domain non-substitution

Make explicit that:

- Readiness does not create Match;
- Match does not create Product Connection;
- Product Connection does not create Messaging Consent;
- `CN_ACTIVE` alone does not create Conversation live read/send;
- Messaging Consent does not create Connection;
- Conversation activity does not create Relationship;
- Calm Home is zero-writer and cannot mutate source domains;
- Notification layers cannot rewrite source-domain outcomes;
- route/deep-link/payload/cache/client state/transport success cannot create authority;
- there is no global cross-domain revision or last-received-wins ordering.

## 7. Error / condition contract

Reuse and preserve the accepted technology-neutral condition taxonomy. Do not translate it into HTTP status codes, exception types, GraphQL errors, protobuf enums, SDK errors, or database constraints.

At minimum preserve distinct treatment of:

- authoritative domain outcome;
- domain validation rejection;
- authority binding mismatch;
- audience/purpose mismatch;
- actor/role mismatch;
- revision conflict/stale intent;
- unknown authoritative outcome after transport failure;
- authority unavailable;
- evidence stale;
- evidence superseded;
- revision incomparable/currentness unknown;
- projection lag;
- transport timeout/failure;
- malformed/ambiguous idempotency reuse;
- retained policy prerequisite unestablished.

## 8. Interface consistency and versioning semantics

Define technology-neutral obligations for:

- source-local revision vectors rather than global revision;
- compatibility between request intent and controlling source revision;
- backward/forward semantic compatibility only where accepted authority allows it;
- no implicit replay against a newer revision;
- no cross-domain timestamp ordering;
- one immutable semantic intent per idempotency identity;
- exact duplicate reconciliation;
- stale client projection behavior;
- correction/revocation invalidation;
- payload/deep-link revalidation at use time.

Do not choose version-number syntax, URL versioning, schema registry, event versioning framework, migration protocol, or deployment strategy.

## 9. Retained seams and downstream classification

For every unresolved item inherited from IP-01 through IP-07, classify whether it blocks:

- IP-08 core interface planning;
- one domain interface slice only;
- IP-09 logical persistence/schema planning;
- IP-10 client integration planning;
- later implementation execution;
- production only.

Do not turn an unresolved policy/provider/legal seam into a permissive API default.

## 10. High-density validation

Include at least 300 independently checkable validation rows.

Report:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N / DEFERRED = N`

Do not stop after the first ordinary unknown or blocker; complete every independent row still evaluable.

## 11. Explicit non-goals

Do not choose or implement:

- REST / GraphQL / RPC / event-bus style;
- endpoint paths / methods;
- wire field names / JSON / protobuf / serialization;
- OpenAPI / GraphQL schema / generated SDK;
- authentication protocol implementation;
- schema/database/index/key design;
- service/module/deployment topology;
- transactions/locks/CAS/queues/event logs;
- language/framework;
- provider/channel/platform;
- clock/scheduler;
- Flutter/client code;
- telemetry/analytics expansion;
- production or real/private-data processing.

## 12. Stop boundary

Create one candidate branch, recommended:

`review/next-ip-08-cross-domain-api-interface-planning-v0-1`

Publish only the exact output file, report branch/candidate/sole parent/tree/blob/scope and `git diff --check`, then STOP.

Do not self-accept, merge, implement, or start IP-09/IP-10.

Expected success classification:

`CROSS-DOMAIN API/INTERFACE PLAN ESTABLISHED — TECHNOLOGY-NEUTRAL MUTATION / PROJECTION / REVALIDATION / ERROR CONTRACTS EXPLICIT — DOMAIN AUTHORITY BOUNDARIES PRESERVED — NO ENDPOINT/WIRE/SCHEMA IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
