# EliteSync v10｜IP-13I-R17-R2 Product Connection Duplicate-Resolution Order-Invariance Evaluator Repair Acceptance｜v0.1

Status: `ACCEPTED — OPTION-A EVALUATOR REPAIR + PERMUTATION REGRESSION VERIFIED — FRESH MAPPING RE-REVIEW GATE OPEN`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Independent verdict

`ACCEPT`

Fresh independent review accepts immutable candidate:

`18bec94d22062b69e780a07ef747a40289c52005`

against frozen R17-R2 implementation authority:

`347449705f673badcd38611bb9cc65e75af70183`

Verified:

- candidate sole parent: `347449705f673badcd38611bb9cc65e75af70183`;
- candidate tree: `c65637d87e10cd96a61fb8f50a996cb8398278b1`;
- comparison: ahead 1 / behind 0;
- committed scope: exactly three paths;
- remote implementation branch points exactly to candidate;
- result blob: `47caffe068ea377ee3f7c5a94bace3f2bb2141aa`.

Current main at review time is the later tool-resume task commit `be075f2d806276df1969cd3b38613da69d0bb65e`. That movement is exactly the previously authorized document-only in-flight continuation and does not require candidate rebase.

## 2. Accepted code blobs

- evaluator before: `35a889ee5460e5c374a5a99bd93bebae49718c5b`;
- evaluator accepted after: `a2a2fefe2178834aa5051200cf2d1ecc3d4ea885`;
- evaluator Unit test before: `dc408a781d58ddf5c52f6cb0a140e642d3c30775`;
- evaluator Unit test accepted after: `c68f82adf44af65ca80e51d7fc73bf1522b81980`;
- result: `47caffe068ea377ee3f7c5a94bace3f2bb2141aa`.

No Common Authority, persistence, application, HTTP, client, Composer/config or downstream code is part of the candidate.

## 3. Independent implementation review

The repaired shared duplicate resolver now:

1. preserves existing caller-level empty, cross-Connection and participant checks;
2. validates one common evidence identity across the full duplicate set;
3. rejects any source-local namespace mismatch with the existing incomparable reason;
4. computes the maximal comparable revision independent of input order;
5. retains only maximal candidates for current semantic-conflict evaluation;
6. returns the existing equal-revision conflict reason when maximal semantic signatures differ;
7. otherwise returns the common maximal semantic evidence.

This implements accepted R17-R1 Option A. Strictly older comparable evidence is not deleted or rewritten; it is dominated only for the current duplicate-resolution outcome.

The implementation introduces no new reason, public API, global revision, LWW, timestamp, arrival-order, representative-index, permission, Connection mutation or source-authority semantics.

## 4. Regression review

The existing Unit test is extended in place rather than replaced.

The added assertions cover:

- original state R17-F1 across all 6 permutations;
- the alternative maximal state semantic variant;
- identical and conflicting maximal state ties;
- a four-item comparable state chain across all 24 permutations;
- state incomparable namespace / different identity in both orders;
- newer unusable state controlling selection before existing usability failure;
- direct transition R17-F1 analogue across all 6 permutations;
- maximal transition conflicts in expected-state revision and from/to semantics;
- dominated lower transition semantic differences across all 24 permutations;
- transition incomparable namespace / different identity;
- all pre-existing evaluator tests in the same file.

Permutation helpers compare complete evaluator results, not only classification.

## 5. Tooling/test receipt disposition

The prior first R17-R2 attempt stopped correctly because `vendor/bin/phpunit` was absent and no PHPUnit process ran.

The authorized R17-R2-R1 continuation then:

- observed PHP 8.5.3;
- observed Composer 2.9.5;
- ran exactly one offline locked Composer materialization with `COMPOSER_DISABLE_NETWORK=1`, `--no-scripts`, and `--no-plugins`;
- reported `114 installs / 0 updates / 0 removals`;
- materialized ignored `vendor/` without tracked dependency/config changes;
- ran the exact targeted PHPUnit command once.

Reported targeted result:

`53 tests / 261 assertions / 0 failures / 0 errors / 0 skips`

with two PHPUnit deprecations. The deprecations do not invalidate the targeted pass and are not silently treated as zero warnings.

The independent reviewer did not rerun project commands; this acceptance relies on the immutable code/test diff plus the bounded executor receipt and does not claim additional runtime evidence.

## 6. Preserved contract

Preserve unchanged:

- exact six structural diagnostics;
- exact 8/19 persisted reason vocabularies;
- accepted R15-R1 reason boundary;
- accepted R16-R1 dependency-presence/context/revision/currentness/freshness/invalidation/terminal matrices;
- Binding Model A;
- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`;
- `GENERIC_PROJECTION_INVALIDATION != PRODUCT_CONNECTION_DEPENDENCY_INVALIDATION`;
- `EXACT_MATERIALIZATION != PROTECTED_USE_VALIDITY`;
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`;
- `Match != Connection != Conversation != Relationship`.

## 7. Next gate

Old R17 candidate remains rejected and is not revived.

The R17-F1 blocker is now resolved at both policy and evaluator implementation/test levels.

The next authorized planning gate may now be a fresh Product Connection domain-to-application mapping re-review using:

- complete retained/corrected R16 source closure;
- accepted R17-R1 policy;
- accepted repaired evaluator blob `a2a2fefe2178834aa5051200cf2d1ecc3d4ea885`;
- prior R17 sound fragments only as rejected-candidate evidence.

No persistence/application/HTTP implementation is authorized by this acceptance itself. No R18 is opened here.

## 8. Acceptance classification

`IP-13I-R17-R2 ACCEPTED — OPTION-A ORDER-INVARIANT DUPLICATE RESOLUTION IMPLEMENTED — STATE + TRANSITION PERMUTATION REGRESSION ACCEPTED — 53 TESTS / 261 ASSERTIONS TARGETED RECEIPT PASSED — R17-F1 POLICY + IMPLEMENTATION BLOCKER CLOSED — OLD R17 REMAINS REJECTED — FRESH MAPPING RE-REVIEW GATE OPEN`
