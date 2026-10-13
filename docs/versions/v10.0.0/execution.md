# v10.0.0 execution and candidate delivery

Status: EXECUTOR_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE.
This is A+B+D execution under Owner manual dispatch to 01a13084-65a4-7c71-bf32-fa60a68d2099/local. It is not final acceptance or a production release.

## Fixed authority and code identity
- Frozen plan: GitHub commit 8072ba51ad1dde2e3c3262a418af54531dcec7e0, plan blob ae84a65e3636fa51a188c687154cb51856f58bf9. The included plan.md is byte-identical.
- Code parent: 4bebc8f394248e254c1368a06fbdee5d2c883301.
- Candidate branch: codex/v10-0-0-boundary-closure-20261013.
- The final commit/tree are the Git objects containing this report and manifest.json, reported in the Owner delivery receipt; no recursive self-commit claim is embedded.
- Isolated worktree: separate checkout; original D:/EliteSync-v10 main and default index preserved.
- source-intake.json selects 26 files: exactly eleven Unit files, twelve transitive Domain sources and composer.json/composer.lock/phpunit.xml. Every intake object matched the code parent; no LOCAL_ONLY source import was necessary for this exact closure.
- The sole existing tracked source/test delta is 232 added lines in ProductConnectionPersistenceApplicationAdapterTest.php. No product source changed. phpunit.v100.xml is an exact eleven-file test configuration, not a new product configuration.
- Original R18 remains rejected; R18-R1 is historically accepted. The adapter/test accepted blobs remain the pre-version baseline, not a claim that the expanded test blob is unchanged.
- Shared repository/SQLite and MC adapter/test retain current BE-05/BE-08 identities; no rollback to the old R18 Phase-A objects.

## Changes and added discrimination
The original test methods/assertions are retained. Five data-driven test methods introduce 139 named datasets: 48 missing/extra-key cases; 44 type cases; 43 valid-type field-value mismatches (existing audience/source/current case is not duplicated); two participant binding-pair permutation positives; two descriptor participant-set mismatch negatives. Current/transition and required/source sides are covered.
Structural malformed bindings must reject. Coherent but nonmatching named fields are persisted/read back as UNKNOWN and unusable; repeated submissions are exact duplicates and permission remains false. Participant binding-list order/type semantics stay distinct from descriptor-set equivalence. These tests call the real ProductConnection adapter and SQLite :memory: application submit/retrieve/readback paths, not mocked core functions.

## Actual validation and the retained failure
- run-001 was an infrastructure launch failure: '--colors never' made PHPUnit interpret 'never' as a test filename. No tests started. The wrapper then failed parsing zero-byte JUnit; wrapper exit 1 is observed, child exit UNKNOWN because it was not persisted before the wrapper exception. Original stdout/stderr/zero-byte JUnit and separate diagnostic are retained; no code/test failure is fabricated.
- The wrapper was corrected to '--colors=never' and to persist the child receipt before parsing.
- run-002: PHP 8.5.3, PHPUnit 11.5.55; exact eleven classes verified from JUnit. Exit 0; 301 tests, 4056 assertions; failures 0, errors 0, skips 0. One PHP deprecation and two PHPUnit metadata deprecations remain visible in the untouched stdout.
- All run-002 selected source/test/config input hashes remained unchanged through execution. The final manifest checks the same inputs again.
- Existing ignored vendor dependencies were copied locally into the isolated candidate, with no Composer/install/download/upgrade. The autoload probe confirms the adapter/repository/SQLite classes load from this checkout, not the dirty original tree. vendor binaries are not published; lockfile and runtime metadata identify the dependency route.
- Supporting independent read-only static review found no actionable code/scope findings. It is separate from the executor runtime result and does not replace Astra.
- No unchanged-code reassurance rerun was performed after the successful exact combination.
- Test runner elapsed time: 1.484 seconds. Complete task walltime and token/credit consumption: UNKNOWN, not measured. No historical one-shot budget was revived.

## Executor evidence against frozen AC
| AC | Evidence and present status |
|---|---|
| AC-01 | Fixed parent, selected identities, scoped final manifest and original-root preservation checks; EVIDENCED. |
| AC-02 | Named shape/type/value and two participant semantics, plus retained insertion-order regression; EVIDENCED by run-002. |
| AC-03 | Exactly eleven JUnit classes, raw streams/exit/deprecations and infrastructure-failure chain; EVIDENCED. |
| AC-04 | Real in-memory/SQLite and application integration tests execute submit/readback/invalidation/rejection paths; EVIDENCED within synthetic/dev-test scope. |
| AC-05 | Safe candidate code, tests, raw evidence and manifest are provided on a fixed GitHub candidate commit. Publication/ref readback is in the Owner receipt; independent assessment belongs to Astra. |
| AC-06 | Finite retained-gap classifications below; EVIDENCED. |
| AC-07 | Executor delivery completed; Astra acceptance/retrospective PENDING. Do not declare all-AC final PASS. |

## Finite retained-gap register
| Object | Classification | Boundary |
|---|---|---|
| R18 original | RETAINED_OUT_OF_SCOPE | Original REJECT preserved. |
| R18-R1 correction | ALREADY_ACCEPTED | Not reimplemented; current expanded tests have their own identity. |
| BE-05 repository and BE-08 current-state MC adapter | ALREADY_ACCEPTED | Current dependency identities retained; no live writer/source permission. |
| New binding boundary datasets + current exact eleven-file validation | CLOSED_BY_V10_0_0 | Executor evidence complete, final acceptance pending Astra. |
| Existing Flutter synthetic journey / other App/EliteSync candidates / BE-12 route guard | RETAINED_OUT_OF_SCOPE | Preserved in original root; not imported or altered by this version. |
| C backend-to-Flutter consumer bridge | RETAINED_OUT_OF_SCOPE | Deferred; no live read/send bridge claim. |
| V57/H1; H2/D0 and old task queue | RETAINED_OUT_OF_SCOPE | No activation/dispatch/execution. |
| Formal platform/Driver/JVM/14case/SDK/device qualification | RETAINED_OUT_OF_SCOPE | NOT_RUN; NOT_READY/RuntimeReady=false/M6 CLOSED retained. |
| Real data, production DB/API/SSH, credentials, backup recovery, deployment | RETAINED_OUT_OF_SCOPE | Not accessed or authorized. |
| App-specific Sources/Instructions full association | UNKNOWN | No necessary inaccessible input encountered for this scope. |

## Reproduction and identity verification
Checkout the fixed candidate commit from the delivery URL, retain the frozen parent reference, and supply the existing compatible PHP 8.5.3/PHPUnit 11.5.55 dependencies from a trusted preexisting local installation. This version did not authorize installing/upgrading them. Do not connect real DB/services or create a real .env.
In the checkout root, run:
`python docs/versions/v10.0.0/tools/run_frozen_suite.py --label independent-run`
The script uses C:/tools/php85/php.exe, the isolated backend working directory, a generated exact-eleven-file configuration, test-only environment values, untouched stdout/stderr and JUnit. Another host can directly execute the documented argv with its equivalent existing PHP entry point; record adaptations.
manifest.json records both runtime-byte SHA256 and canonical Git blob identities: CRLF checkout bytes can differ from GitHub LF blobs. Evidence files have -text attributes, so published raw bytes retain their recorded SHA256. Manifest/report do not claim their own recursive hashes.
The included preparation helper is an execution record for the exact Owner source root, not a command to run against an unrelated project or a completed candidate. Do not run it on the published candidate.

Stop: EXECUTOR_DELIVERED — AWAITING ASTRA INDEPENDENT ACCEPTANCE AND RETROSPECTIVE. No merge to main, release, or successor version.
