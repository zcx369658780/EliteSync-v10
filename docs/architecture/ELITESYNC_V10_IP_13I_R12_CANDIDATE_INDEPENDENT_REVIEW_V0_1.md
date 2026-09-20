# EliteSync v10｜IP-13I-R12 Candidate Independent Review｜v0.1

Status: `REJECTED — ADAPTER CORE FLOW SOUND BUT DERIVED PURPOSE MAPPING CONFLICTS WITH ACCEPTED PERSISTABLE DOMAIN-UNKNOWN CONTRACT — HTTP REMAINS DEFERRED — NARROW DOCUMENT-ONLY CONTRACT CORRECTION REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh review base / current `origin/main`:
`7df2a86046bf429f5f4e16c15b13230cde070404`

Reviewed branch:
`review/next-ip-13i-r12-canonical-match-persistence-application-adapter-v0-1`

Reviewed candidate:
`c18d79c968dddf3a26c4d189f783a1354a4fca86`

Candidate sole parent:
`7df2a86046bf429f5f4e16c15b13230cde070404`

Candidate tree:
`eecc327c1a3b3f0f332a648c42d04448a60978a7`

Candidate blobs:
- adapter: `f1f151b4cb96352521b0823072857153e2ccb4e4`
- targeted Unit test: `c99ea59a270e4ff23a3b9fa016eec95db3cccdc3`
- implementation result: `524d67ba1b46724e41cb350317f4310304a775e2`

## 1. Topology, scope and runtime evidence

Independent review confirmed:

- candidate is exactly one commit ahead / zero behind the R12 authority;
- exactly the three authorized paths are added;
- no existing tracked path changes;
- reported candidate blobs match the immutable candidate;
- protected IP-13A/IP-13D/IP-13E/IP-13F/evaluator/Common Authority/Composer objects remain unchanged.

The targeted run is accepted as evidence of the exercised fixture set:

- Composer Case B once, exit 0;
- `114 installs / 0 updates / 0 removals`;
- targeted PHPUnit once, exit 0;
- `9 tests / 122 assertions`;
- failures/errors/warnings = `0 / 0 / 0`;
- deprecations = `1`;
- no retry;
- no post-run adapter/test correction;
- one `git diff --check` PASS.

The deprecation is not the rejection cause.

## 2. Sound candidate portions retained as evidence

Static review found no blocker in:

- exactly two public operations;
- strict synthetic structural gate;
- ordinary one-evaluator-call flow;
- invalidation fresh-evaluate + one-invalidate flow;
- no caller-supplied prior result;
- collision-free invalidation target check;
- fifteen-category reason reduction;
- selected source-evidence matching;
- deterministic Match payload and identity construction;
- one shared IP-13E submit source location;
- conditional exact-lineage retrieve for accepted storage dispositions;
- direct canonical payload array equality for readback;
- sticky terminal invalidation;
- dependency-invalidated exact materialization remaining unusable;
- no generic IP-13E invalidation call in dependency-scoped flow;
- no IP-13F/HTTP dependency.

These are not acceptance of the candidate; they bound the correction scope.

## 3. Blocking contract contradiction

Accepted R9-R1 states that after the structural gate, a proposal whose evidence is structurally valid but whose exact required-binding satisfaction is not established remains a valid persistable domain `UNKNOWN` derivation.

The Canonical Match evaluator implements that distinction. In particular, a structurally valid proposal can produce:

`PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`

when:

`proposal.required_bindings.purpose != proposal.protected_use_scope`

without making the input structurally malformed.

R10 then specified that the derived generic binding `purpose` is copied from the proposal required bindings.

R12 candidate implements exactly that mapping:

`'purpose' => $sourceBindings['purpose']`

However, accepted R11 persistence requires for every Canonical Match derived record:

`bindings.purpose = payload.protected_use_scope`

Therefore for the structurally valid semantic-uncertainty case:

1. structural gate passes;
2. evaluator truthfully returns domain `UNKNOWN` with bounded reason `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`;
3. R12 builds a record whose derived `bindings.purpose` remains the mismatched source-required purpose;
4. R11 rejects the record as `INVALID_RECORD_REJECTED`;
5. the accepted R9-R1 requirement that this domain `UNKNOWN` remain losslessly persistable is not met.

This is a real mapping defect, not a transport, HTTP, storage-runtime or test-environment failure.

## 4. Why this was not caught by the targeted test

The targeted test fixtures construct proposal bindings with:

`purpose = SYNTHETIC_MATCH_REVIEW`

and proposal:

`protected_use_scope = SYNTHETIC_MATCH_REVIEW`.

No targeted case exercised a structurally valid proposal whose required-binding purpose differed from its protected-use scope.

The green receipt therefore does not establish the missing accepted domain-UNKNOWN branch.

## 5. Preferred correction direction

Preferred correction:

- derived Match `bindings.purpose` must equal the derived payload's `protected_use_scope`;
- source proposal `required_bindings.purpose` remains untouched inside source evidence/input;
- a source-required purpose mismatch remains an evaluator domain fact and may produce `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`;
- the derived record must not copy that mismatched source-required purpose into its own derived-purpose binding;
- the correction creates no source authority and does not repair source evidence.

Conceptually:

`SOURCE_REQUIRED_PURPOSE != DERIVED_RECORD_PURPOSE`

when the source required binding is semantically unsatisfied.

The derived record purpose expresses the bounded protected use for which the derivation was requested; it does not assert that source evidence satisfied that purpose.

This direction aligns:
- R9-R1 persistable domain uncertainty;
- R11 exact persistence envelope;
- Match non-authority boundaries.

It must be independently fixed in contract text before code correction because R10 and the R12 task currently explicitly say to copy proposal purpose.

## 6. Candidate disposition

Candidate:

`c18d79c968dddf3a26c4d189f783a1354a4fca86`

is rejected for acceptance.

It must not be merged/transplanted to main.

The next task must be document-only:

`IP-13I-R12-R1 CANONICAL MATCH DERIVED-PURPOSE BINDING CONTRACT CORRECTION REVIEW`

The review must decide the exact derived-purpose source and exact minimal later adapter/test correction.

No IP-13A/IP-13D change is currently indicated because R11 already enforces the preferred derived-purpose invariant.

No HTTP review is authorized until the application adapter is accepted.

## 7. Final classification

`IP-13I-R12 CANDIDATE REJECTED — CORE ORDINARY/STICKY-INVALIDATION APPLICATION FLOW RETAINED AS EVIDENCE — DERIVED bindings.purpose COPIED FROM SEMANTICALLY UNSATISFIED PROPOSAL REQUIRED BINDING CAUSES A R9-R1-PERSISTABLE PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE UNKNOWN TO BE REJECTED BY ACCEPTED R11 — GREEN TARGETED FIXTURES DID NOT EXERCISE THIS BRANCH — NARROW DOCUMENT-ONLY DERIVED-PURPOSE CONTRACT CORRECTION REQUIRED BEFORE ADAPTER ACCEPTANCE — HTTP REMAINS DEFERRED`
