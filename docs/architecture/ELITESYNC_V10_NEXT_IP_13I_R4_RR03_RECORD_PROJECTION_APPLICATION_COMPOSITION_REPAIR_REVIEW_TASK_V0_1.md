# EliteSync v10｜Next IP-13I-R4 Runtime Readiness RR03 Privacy-Minimal Logical Record / Projection and Application-Composition Contract Repair Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY CONTRACT REPAIR REVIEW — NO IMPLEMENTATION AUTHORITY — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-19 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `185deeb89c8254625ad84582cd623e65b2b24489`

## 1. Objective

Repair the exact contract gap accepted in IP-13I-R3 so that a future synthetic/dev-only Runtime Readiness slice can represent and transport RR03 without semantic loss.

This review must define the minimum additive representation required for:

- RR03 derived classification;
- prerequisite-set state/identity/revision;
- exact privacy-minimal multi-source dependency vector;
- per-dependency source condition/currentness/freshness;
- bounded derivation reason categories;
- correction/revocation/supersession invalidation;
- projection currentness/lag;
- separate persistence/application/transport/HTTP dispositions.

It must also define the exact application-composition contract that can reuse accepted IP-13E/IP-13F semantics without creating a sixth family or making persistence authoritative.

This task is document-only.

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review branch/worktree from exactly that commit.
5. Verify the single output path below is absent.
6. Read only the exact evidence paths listed in Section 3.
7. Stop rather than adapt if base/path differs.

Recommended branch:

`review/next-ip-13i-r4-rr03-record-projection-composition-repair-v0-1`

## 3. Exact authorized evidence set

Read only:

1. `AGENTS.md`
2. IP-13I-R3 result
3. IP-13I-R3 acceptance
4. `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
5. `services/backend-laravel/app/Domain/RuntimeReadinessDerivedEvaluator.php`
6. Runtime Readiness acceptance
7. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
8. IP-13A acceptance
9. `services/backend-laravel/app/Domain/LogicalPersistenceAdapterConformanceContract.php`
10. IP-13B acceptance
11. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
12. IP-13D acceptance
13. `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
14. IP-13E acceptance
15. `services/backend-laravel/app/Domain/TransportNeutralApplicationRequestResponseContract.php`
16. IP-13F acceptance
17. IP-13H acceptance
18. IP-08 cross-domain interface plan
19. IP-09 logical persistence plan

No repository search/discovery or directory enumeration is authorized.

## 4. Exact tracked write scope

Create exactly:

`docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_RR03_RECORD_PROJECTION_AND_APPLICATION_COMPOSITION_CONTRACT_REPAIR_REVIEW_RESULT_V0_1.md`

No existing tracked file may change.

## 5. Required RR03 representation decision

The review must choose exactly one of these representation models:

### Model 1 — Additive generic derived-projection payload

Extend the generic logical-record/projection contract conceptually with one bounded optional privacy-minimal derived payload that is only valid for explicitly accepted derived-projection families.

The review must determine:
- exact payload key;
- exact allowed subkeys;
- whether generic contracts can validate it without domain-specific authority leakage;
- how IP-13B conformance would compare it;
- how IP-13D would store it opaquely;
- how IP-13E projection retrieval would expose it.

### Model 2 — Typed RR03 companion projection

Keep the generic IP-13A record shape unchanged and define a separately typed RR03 companion projection logically associated with one stored logical record.

The review must determine:
- companion identity;
- correlation/binding to the generic logical record;
- lifecycle and invalidation behavior;
- whether storage now requires a second physical representation;
- whether this would exceed accepted persistence semantics or require a new persistence family.

### Model 3 — No persistence for RR03 in first slice

Evaluate readiness and return only the derived result through a domain adapter; no RR03 materialization occurs.

The review must determine:
- whether this abandons the stated goal of bridging evaluator→persistence→application→transport→HTTP;
- whether IP-13E/IP-13F can still be reused without semantic overload;
- whether the first slice should deliberately exclude persistence.

Choose exactly one model or state that none is sound.

## 6. Minimum privacy-minimal RR03 payload

If Model 1 or 2 is selected, define the minimum fields required to represent RR03 without raw/private evidence.

At minimum evaluate:

- `derived_fact_class` = `EFFECTIVE_READINESS`
- `classification` = `READY | NOT_READY | UNKNOWN`
- `prerequisite_set_state` = known/unknown
- `prerequisite_set_identity`
- prerequisite-set source-local revision reference
- `protected_use_scope`
- bounded `reason_categories`
- ordered or canonically normalized dependency entries containing only:
  - opaque dependency identity
  - dependency fact class
  - authority owner/scope/context
  - source-local lineage/revision
  - source condition
  - currentness
  - freshness
  - prerequisite outcome where semantically needed
- derived projection invalidation state/relation
- no raw evidence
- no actor secrets/credentials
- no private Conversation/message material
- no hidden Safety material

The review must determine whether participant/subject/audience/purpose fields remain in existing generic bindings rather than duplicated inside the payload.

## 7. Revision and authority model

The repair must preserve:

- no global revision;
- no synthetic aggregate revision computed from dependencies;
- each dependency keeps its own source-local revision;
- the generic record's single source revision, if retained, cannot claim to summarize or order the dependency vector;
- readiness classification remains derived and non-authoritative;
- authoritative outcome remains `UNKNOWN` unless independently source-carried;
- currentness/freshness of the derived projection must not overwrite per-dependency currentness/freshness;
- invalidation of any referenced dependency can make the projection unusable without lifecycle reset/reopen;
- dependency-vector ordering must be canonical/deterministic but not authority-bearing.

The review must explicitly decide what the generic record's own `source_revision` means for RR03 if Model 1 is selected.

## 8. Identity / intent / duplicate semantics

Define:

- logical record identity rule;
- lifecycle identity rule;
- logical intent rule;
- how exact duplicate is determined;
- what changed input means;
- whether two evaluations over the same prerequisite-set identity but different selected dependency revisions are distinct records/intents;
- whether a later same-set evaluation supersedes the earlier projection or coexists as a distinct derived record;
- how correction/revocation/supersession applies.

Do not create LWW/arrival-order semantics.

## 9. Application composition repair

Define the exact bounded application adapter contract.

At minimum assess this candidate internal sequence:

1. validate synthetic input;
2. run `RuntimeReadinessDerivedEvaluator::derive()`;
3. build privacy-minimal repaired RR03 representation;
4. invoke existing IP-13E `submitAuthoritativeMutation()` for storage/correlation only if persistence is selected;
5. invoke existing IP-13E `retrieveCurrentProjection()` only if needed to verify/read back the materialized projection;
6. expose one domain-adapter result that keeps:
   - readiness classification;
   - persistence disposition;
   - projection/read disposition;
   - authoritative outcome;
   - revalidation/invalidation requirements;
   - non-authority fields
   separate.

Decide:
- whether the adapter itself is a new domain-specific application adapter class;
- whether it may internally compose two existing IP-13E methods;
- whether this composition creates a new IP-13E family (it must not);
- whether IP-13F can remain unchanged;
- how a later HTTP endpoint receives the domain-adapter result without creating a sixth transport family.

## 10. Transport repair decision

After repairing the record/application composition, choose exactly one future transport model:

### T1 — Dedicated Runtime Readiness v2 endpoint

`POST /api/v2/runtime-readiness/evaluations`

The dedicated controller calls the new bounded Runtime Readiness application adapter, not IP-13F directly.

The review must decide whether this is acceptable while IP-13F remains canonical only for the generic application-envelope endpoint, or whether this creates an unacceptable parallel transport contract.

### T2 — Generic envelope remains the only HTTP entry

The readiness domain adapter must somehow be invoked through one existing IP-13F family.

Select only if a truthful existing-family mapping is possible after record repair.

### T3 — No HTTP yet

Implement/test only the domain adapter and persistence composition first; HTTP remains deferred.

Choose exactly one T1/T2/T3.

No route is created in R4.

## 11. Future runtime bridge

Define the exact future targeted test(s) implied by the selected repair.

If HTTP is selected, require one Feature test spanning:
`synthetic readiness input → evaluator → repaired RR03 record/projection → sqlite::memory: → IP-13E composition → selected transport → HTTP`.

If T3 is selected, require one targeted integration/unit test spanning evaluator→persistence→IP-13E adapter result, with HTTP as a later slice.

Mandatory assertions:
- READY/NOT_READY/UNKNOWN preserved;
- unknown set preserved;
- dependency vector lossless and privacy-minimal;
- per-dependency revisions/conditions/currentness/freshness preserved;
- no global revision;
- exact duplicate/change-input semantics;
- invalidation;
- classification separate from storage/outcome/transport;
- no raw/private evidence leak;
- no authentication inference;
- no downstream-domain authority.

## 12. Required decision outputs

The result must contain:

- `RR03_REPRESENTATION_MODEL`
- `RR03_PAYLOAD_STATUS`
- `RR03_REVISION_MODEL_STATUS`
- `RR03_IDENTITY_INTENT_STATUS`
- `IP13B_CONFORMANCE_IMPACT`
- `IP13D_STORAGE_IMPACT`
- `APPLICATION_COMPOSITION_STATUS`
- `IP13F_IMPACT`
- `TRANSPORT_MODEL_DECISION`
- `FUTURE_RUNTIME_BRIDGE_STATUS`
- `NEXT_BOUNDED_TASK`

## 13. Success criteria

A successful R4 must fully resolve:

1. one minimum RR03 representation;
2. one deterministic revision/dependency model;
3. one identity/intent/invalidation model;
4. conformance impact;
5. physical adapter impact;
6. application composition;
7. whether IP-13F changes or remains unchanged;
8. one future transport model;
9. exact next implementation/review task boundary.

If any remains materially unresolved, select a narrower document-only task instead of implementation.

## 14. Explicit prohibitions

Do not:
- modify IP-13A/B/D/E/F or any source;
- create new code/routes/controllers/tests;
- run Composer/PHPUnit/Artisan/route:list;
- run migrations/generators/runtime;
- access persistent DB/provider/network/client;
- process real/private data;
- change auth/session/token;
- perform legal/Safety or production/deployment work;
- create the successor task.

## 15. Command budget

No runtime command is authorized.

After final authoring run exactly once:

`git diff --check`

Read-only Git/provenance reads of exact authorized evidence are allowed.

## 16. Required result document

Record:
- task-publication commit;
- candidate SHA / sole parent / tree / ahead-behind;
- exact one-file scope;
- result SHA-256/blob;
- evidence blobs read;
- Model 1/2/3 decision;
- exact RR03 payload;
- revision model;
- identity/intent/invalidation semantics;
- IP-13B/IP-13D impact;
- application-composition contract;
- T1/T2/T3 decision;
- future runtime bridge;
- eleven decision outputs;
- exact next-task boundary;
- retained non-authorities;
- `git diff --check`;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification if fully resolved:

`IP-13I-R4 RR03 RECORD/PROJECTION AND APPLICATION-COMPOSITION CONTRACT REPAIR REVIEW COMPLETE — MINIMUM PRIVACY-MINIMAL RR03 REPRESENTATION / MULTI-SOURCE DEPENDENCY MODEL / APPLICATION COMPOSITION / TRANSPORT PATH RESOLVED WITHOUT GLOBAL REVISION OR AUTHORITY SUBSTITUTION — FIRST IMPLEMENTATION SLICE CAN NOW BE BOUNDED — READY FOR FRESH INDEPENDENT REVIEW`

Otherwise report the exact remaining seam and STOP.
