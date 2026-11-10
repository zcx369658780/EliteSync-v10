# EliteSync v10｜IP-13I-R18 Candidate Independent Review｜v0.1

Status: `REJECTED — PROTECTED-BINDING RECOVERY IS PHP-ARRAY-ORDER-SENSITIVE — POST-PASS TEST EXECUTION DEVIATED FROM STOP RULE — NO INTEGRATION / NO DOWNSTREAM AUTHORIZATION`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Independent verdict

`REJECT`

Immutable candidate:

`64dd8f8dccbbb3582656f98a70b1e36c6449fe0b`

against frozen authority:

`19dee11e6c873f0a3292cbdc6f275e0839b7aeee`.

Verified topology:

- candidate sole parent: `19dee11e6c873f0a3292cbdc6f275e0839b7aeee`;
- candidate tree: `5d0eed1e95f1bb0566cd921a8d908b4741e62916`;
- comparison: ahead 1 / behind 0;
- exact scope: six authorized paths only;
- branch `impl/ip-13i-r18-product-connection-persistence-application-v0-1` points exactly to candidate;
- result blob: `31523004ffd8d7d8511bcd667bcdea8d78cc5cd5`.

The topology and most implementation direction are sound. Rejection is caused by one concrete application mapping defect plus one execution-contract deviation. The candidate is not integrated.

## 2. Verified candidate blobs

- IP-13A: `6178bc7290a9e542a39155756c9dd9e43d9eb0b2`;
- IP-13D: `678881a6c5868170270f4a400351966dd2e69a95`;
- Product Connection persistence test: `e4e6b946e5bace72da0bf36db6fd49caa328d00f`;
- Product Connection application adapter: `824f6950a0358d13675fb6cc79ce6c9eeaf45434`;
- Product Connection adapter test: `b1680ef749a7e30b7d696988809360c86ee51171`;
- R18 result: `31523004ffd8d7d8511bcd667bcdea8d78cc5cd5`.

The reported Phase A gate was `48 tests / 1606 assertions / 0 failures / 0 errors / 0 skips`. The final reported candidate test receipt ends at `128 tests / 2789 assertions / 0 failures / 0 errors / 0 skips`, with one deprecation and two PHPUnit deprecations. The reviewer did not rerun project commands.

## 3. Blocking finding R18-F1 — protected binding depends on PHP associative insertion order

Accepted R17-R3 requires protected binding to be computed field-by-field from the original required/source Common Authority bindings. The eleven corresponding fields must be exactly equal in value; participant set and Connection descriptor requirements are then checked separately. Common Authority itself treats bindings as named fields: its shape validator sorts key names, and `evaluateProtected()` compares each binding by key.

The R18 adapter instead implements:

`$required === $source`

inside `protectedBindingSatisfied()`.

PHP strict array equality also requires the same key order. But the adapter's own structural gate `hasExactKeys()` sorts keys before comparison, so two binding objects with the same exact eleven field names and the same exact values can both pass the structural gate while differing only in associative insertion order.

Concrete static counterexample:

1. construct valid `required_bindings` in canonical key insertion order;
2. construct `source_evidence.bindings` with the same eleven keys and exactly equal corresponding values, but insert those associative keys in another order;
3. both containers pass the adapter's exact-key/type gate;
4. the repaired evaluator/Common Authority field-wise protected evaluation does not make insertion order authoritative;
5. adapter recovery computes `protected_binding_satisfied=false` solely because `$required === $source` is false;
6. a known evaluator result can therefore be converted into a persistence dependency that is not fully usable;
7. the Product Connection persistence matrix can then reject the record or make the application outcome unusable even though no accepted binding value differs.

Thus application behavior is sensitive to serialization/insertion order that is not an accepted authority dimension.

Required correction: compare the eleven named binding values exactly by key, not the associative-array insertion order. Do not sort participant values for this required/source equality; preserve the accepted exact field value comparison. The separate Connection participant-set check remains set-based as already specified.

Add a regression where required/source bindings contain identical named values but different associative key insertion order and prove `protected_binding_satisfied=true` and the expected protected-valid materialization. Also retain a true field-value mismatch case that yields false.

## 4. Secondary finding R18-F2 — final-gate stop rule was exceeded after a pass

R18 task Section 11 states:

`A passing run ends the test budget.`

The result records:

- attempt 1: three failures;
- attempt 2: zero failures/errors;
- after that passing run, a contract audit changed the candidate;
- attempt 3 then ran and passed.

The total count stayed within the numeric maximum of three, and the final candidate did receive a passing run. However, attempt 3 occurred after the task's explicit first-pass stop condition had already been reached. The result's statement that the final execution was simply “within the maximum three-process budget” omits this separate stop-rule deviation.

This did not create a repository-scope or network violation and does not by itself establish a product defect. It is nevertheless an execution-contract deviation and must not be repeated.

For the correction task, perform all authorized static contract audit before the first test run. Once a test command passes, do not edit or rerun in that task.

## 5. Sound implementation retained as rejection evidence

The following parts are consistent with the inspected contract and may be reused by a correction candidate without re-deciding architecture:

- Product Connection family added to IP-13A;
- IP-13D exact typed-payload retention without physical schema change;
- reference/SQLite Product Connection persistence test direction;
- four explicit application operations;
- repaired evaluator call topology;
- selected-evidence recovery by public dependency vector;
- exact typed payload and deterministic record construction direction;
- one IP-13E submit and conditional retrieve;
- strict readback including direct typed-payload equality;
- generic projection invalidation separated from typed dependency invalidation;
- exact 52-key non-authority result direction;
- no HTTP/IP-13F/downstream work.

These are retained findings only; the rejected candidate is not accepted wholesale.

## 6. Correction scope recommendation

A bounded R18-R1 correction does not need to redesign or reimplement Phase A.

It may reuse the rejected candidate's exact IP-13A, IP-13D and persistence-test blobs unchanged, because R18-F1 is confined to the application protected-binding calculation/test coverage and no independent defect was established in those Phase A blobs.

The correction candidate should:

1. reconstruct the five code/test paths from the rejected candidate on a fresh accepted task base;
2. keep IP-13A, IP-13D and Product Connection persistence-test blobs byte-identical to the rejected candidate;
3. correct only the Product Connection application adapter and adapter test;
4. create a fresh R18-R1 correction result, not reuse the rejected R18 result as an accepted result;
5. run the full final combined regression once initially, with at most one correction rerun if that first run fails because of the authorized correction;
6. stop immediately on the first passing run.

No Phase A rerun is required if the three Phase A blobs remain exact and the final combined command includes their persistence regression.

## 7. Preserved boundaries

R17-R3 remains accepted. Package A remains accepted. The Product Connection persistence/application architecture is not reopened.

No Product Connection HTTP, IP-13F, Messaging/Conversation, client, production, auth/session/token, real/private-data or deployment authority is created.

## 8. Final classification

`IP-13I-R18 REJECTED — SIX-PATH TOPOLOGY VERIFIED — PHASE-A PERSISTENCE DIRECTION RETAINABLE — APPLICATION PROTECTED-BINDING CALCULATION INCORRECTLY DEPENDS ON PHP ASSOCIATIVE KEY ORDER — POST-PASS TEST STOP RULE DEVIATION RECORDED — NO CANDIDATE INTEGRATION — BOUNDED R18-R1 CORRECTION REQUIRED`
