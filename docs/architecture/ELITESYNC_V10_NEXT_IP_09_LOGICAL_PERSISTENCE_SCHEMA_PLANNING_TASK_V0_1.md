# EliteSync v10｜NEXT IP-09 Logical Persistence / Schema Planning Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — DOCUMENTARY LOGICAL PERSISTENCE/SCHEMA PLANNING ONLY — NO IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `6ba5ac023c812a69c422f081ac3e0b9e972a30f6`

## 1. Purpose

Produce one technology-neutral logical persistence/schema plan over accepted IP-01 through IP-08. This task defines durable logical records, identities, lineages, relations, invariants, atomicity obligations, projection materialization boundaries, correction/supersession semantics, and retention/unknown boundaries without choosing a concrete database or schema technology.

No code, migrations, DDL, ORM, database engine, table/index/key implementation, service topology, storage vendor, transaction primitive, queue/event-log mechanism, runtime execution, private-data processing, legal conclusion, Safety authority, or production permission is authorized.

## 2. Required reads

Fresh-fetch `main`; follow `AGENTS.md`; then read only the accepted IP-01 through IP-08 acceptance/result artifacts and directly dependent accepted BA-01 through BA-07 semantic sources as necessary. Do not enumerate directories or broaden discovery.

## 3. Exact output

Write exactly:

`docs/architecture/ELITESYNC_V10_LOGICAL_PERSISTENCE_SCHEMA_PLAN_V0_1.md`

## 4. Required logical model families

Define technology-neutral logical persistence responsibilities for at minimum:

- common authority evidence/provenance record;
- source-local lineage and revision identity;
- immutable logical-intent/idempotency correlation record;
- authoritative mutation outcome/reconciliation record;
- Runtime Readiness claim records, prerequisite-set identity and derived-readiness dependency vector;
- Match participation context;
- Match proposal context and participant decision slots;
- Product Connection aggregate/request;
- Messaging Consent context/request;
- Conversation live-read/live-send derived gate evidence;
- Calm Home read-model materialization/projection cache boundary, if any, as non-authoritative projection only;
- Notification L1 source reference, L2 eligibility decision, L3 payload identity, and L4 delivery-attempt evidence as separate logical records;
- correction/revocation/supersession relations;
- projection lag/currentness metadata boundaries;
- privacy-minimal auditability/correlation data;
- policy/configuration reference seams;
- historical/terminal identity handling;
- downstream client/API-facing projection identities without turning them into authority.

## 5. Required invariants

Preserve:

- no global revision;
- no cross-domain revision ordering;
- same-lineage comparison only;
- terminal identities remain terminal;
- fresh aggregate/context required where accepted;
- one-sided Match acceptance stays inside `PENDING`;
- mutual Match acceptance requires two current slots for one proposal;
- current aggregate `CN_ACTIVE` remains necessary but insufficient for Conversation;
- current bound `MC_ACTIVE` remains separately required;
- live read and live send remain separate;
- Home remains zero-writer;
- Notification source/eligibility/payload/delivery records remain separate;
- transport observations never overwrite domain outcomes;
- idempotency identity never becomes authority;
- correction/supersession never becomes lifecycle reset;
- projection/cache records never become source-of-truth writers.

## 6. Atomicity / consistency obligations

For each logical family classify whether it requires one of the accepted semantic classes, including:

- `SINGLE_AUTHORITY_DECISION_BOUNDARY_REQUIRED`;
- `CONJUNCTIVE_SNAPSHOT_EVALUATION_REQUIRED`;
- `EVENTUALLY_PROJECTABLE_AFTER_AUTHORITATIVE_OUTCOME`;
- `INDEPENDENT_SOURCE_COMPOSITION_NO_GLOBAL_ATOMICITY`;
- `DEPENDENT_INVALIDATION_PROPAGATION_REQUIRED`;
- `TRANSPORT_OBSERVATION_ONLY`.

Do not choose transactions, isolation levels, locks, CAS, uniqueness constraints, foreign-key mechanisms, event sourcing, queues, brokers, or distributed-transaction technology.

## 7. Privacy / retention boundary

For each record family state the minimum semantic data that must exist and explicitly separate:

- authority-required durable semantics;
- projection-only material;
- audit/correlation semantics;
- private-data content that is out of scope;
- retention/deletion/export/legal-hold/data-right seams that remain unresolved;
- production-only policy/legal requirements.

Do not invent retention periods, deletion behavior, backup policy, hosting region, encryption mechanism, data residency rule, or lawful-basis conclusion.

## 8. Retained-seam classification

For every retained seam state whether it blocks:

- IP-09 core;
- one logical record/model slice;
- IP-10 client planning;
- later implementation execution;
- migration/deployment only;
- production only.

## 9. High-density validation

Include at least **320 independently checkable validation rows**.

Report:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N / DEFERRED = N`

Do not stop after the first ordinary unknown or blocker; complete all independent rows still evaluable.

## 10. Explicit non-goals

Do not choose or implement:

- SQL/NoSQL/database engine;
- tables/columns/indexes/keys/DDL;
- ORM/entities/models;
- concrete primary-key format;
- storage engine/partitioning/sharding;
- transaction/locking/CAS/isolation mechanism;
- queue/event-log/broker;
- endpoint/wire/schema serialization;
- language/framework/service topology;
- cloud/storage vendor;
- encryption/KMS mechanism;
- migration scripts;
- Flutter/client code.

## 11. Stop boundary

Create one candidate branch, recommended:

`review/next-ip-09-logical-persistence-schema-planning-v0-1`

Publish only the exact output file, report branch/candidate/sole parent/tree/blob/scope and `git diff --check`, then STOP.

Do not self-accept, merge, implement, or start IP-10.

Expected success classification:

`LOGICAL PERSISTENCE / SCHEMA PLAN ESTABLISHED — TECHNOLOGY-NEUTRAL AUTHORITY / LINEAGE / AGGREGATE / PROJECTION / INVALIDATION MODEL EXPLICIT — RETENTION/LEGAL/TECHNOLOGY SEAMS PRESERVED — NO DATABASE/SCHEMA IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
