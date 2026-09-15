# EliteSync v10｜IP-11D Implementation Target Selection Decision｜v0.1

Status: `CANDIDATE — FRESH INDEPENDENT ACCEPT/REJECT REVIEW REQUIRED — TARGET DIRECTION SELECTED — NO IMPLEMENTATION AUTHORITY`

Date: 2026-09-16 (Asia/Shanghai)

Repository: `zcx369658780/EliteSync-v10`

Task-publication commit / decision base: `8280d5e2856d0d9bb4e675fc148d9f2f7a45a228`

Task blob: `0d1b27acfa990334bde9d54480d64152b9b00705`

## 1. Decision

`SELECT_BACKEND_DIRECTION_FIRST`

Selected first direction:

- `services/backend-laravel/`

Non-selected direction:

- `apps/android/`
- `apps/flutter_elitesync_module/`
- `RETAINED_FOR_LATER_IMPLEMENTATION_ROUTE — NOT REJECTED`

This selects the backend direction only for the next bounded pre-implementation readiness step and, if all later gates close, for consideration as the first implementation direction. It does not authorize source edits, dependency acquisition, tooling execution, build/test/runtime, deployment, production, private/real data, legal conclusions or Safety Operations.

## 2. Decision rationale

The accepted future first-slice shape is:

`ONE PURE COMMON AUTHORITY-EVIDENCE / SOURCE-CONDITION / IMMUTABLE-INTENT CONTRACT SLICE WITH SYNTHETIC FIXTURES ONLY`

The backend direction is the cleaner first host because:

1. Accepted IP-01 is explicitly a technology-neutral **common backend implementation contract**. Its authority evidence, source condition, revision/currentness/freshness and immutable-intent obligations map directly to a pure backend contract slice.
2. Accepted IP-08 supplies semantic mutation/reconciliation/projection/revalidation contracts without requiring an endpoint, protocol or wire choice. A backend pure contract can preserve that semantic boundary without implementing transport.
3. Accepted IP-09 supplies logical authority/provenance, source-local lineage/revision and immutable-intent identities without requiring tables, database selection or migrations. A backend pure contract can represent these semantics without persistence realization.
4. Accepted IP-11C establishes a standalone Laravel project with `app/`, `tests/`, Composer declarations, lock evidence and PHPUnit configuration. These are declaration facts only, but they expose a plausible narrow source/test boundary.
5. The client direction is a coupled Android-host/Flutter-module direction. Its accepted declarations add Gradle, Java/Kotlin, Flutter/Dart, AAR integration, host/module coordination and client non-authority concerns. The exact Android unit/instrumentation test roots are absent; the Flutter widget test delegates through a main entry whose production delegate was outside the IP-11C allowlist.
6. Placing the common authority contract first in the client direction creates greater risk of confusing client-held state with source authority, contrary to accepted IP-10. It would also invite unrelated UI, route, cache, device and platform choices that the required pure slice must avoid.
7. The backend direction still has unresolved PHP/Composer/PHPUnit, dependency and exact source/test placement facts. Selection does not erase them; it makes them the subject of exactly one narrow pre-implementation readiness task.

This decision is based on accepted repository evidence and slice fit, not general industry preference, framework popularity, familiarity, aesthetics or scalability claims.

## 3. Accepted evidence provenance

| Evidence | Accepted identity / blob | Decision consequence |
|---|---|---|
| IP-11C acceptance | accepted candidate `acae179a9e72017507c678380afd75ba10557213`; result blob `4de32034ccc6da6e2242758041a901a8ee6338df` | Establishes one client host/module direction and one independent Laravel backend direction; creates no implementation authority. |
| Post-IP01..IP10 execution-entry acceptance | accepted candidate `adc7efc65fbda2e7ac09740bd07adb412169b2d4`; result blob `d7949ce56f28b9e01045e30f57444c14d0daf065` | Accepts the pure common-contract synthetic slice shape and requires technology selection, readiness evidence and a later Owner implementation gate. |
| IP-01 acceptance | accepted candidate `2d3f1aa2ef827f770f55540262bee459f56030f0`; result blob `c4cb07b598216b95fadff6280a36bc8d5a79cc25` | Fixes common backend authority/evidence/intent semantics without technology mechanism. |
| IP-08 acceptance | accepted candidate `ad79c7852c2e0b32f10d7662d633f89fbf8e0c6f`; result blob `26f8a6707579a257207b536b10fcbec50bc3939c` | Fixes semantic mutation, reconciliation, projection and revalidation interfaces without wire realization. |
| IP-09 acceptance | accepted candidate `e0e523bf78f0b2ba92364da83867a6c74578f761`; result blob `875ee961055dda9d18eedb99ab19e7a615215a4a` | Fixes logical identities, lineage/revision and outcome correlation without physical persistence. |
| IP-10 acceptance | accepted candidate `996128a5a2213d0e1e05bb99de3abb561dbae931`; result blob `1da7dddc42cd5e237de29705dd146b940b3d6509` | Requires the client to remain a non-authoritative consumer; cautions against locating source authority in client state. |

Only the eight task-authorized evidence documents were read. No implementation source, manifest, cache or artifact was inspected in IP-11D.

## 4. Direction comparison

| Criterion | Client direction | Backend direction | Decision effect |
|---|---|---|---|
| Declared structure | Android application host plus embedded Flutter module | independent Laravel project | Backend is the smaller single target direction. |
| Pure common-contract fit | possible in principle, but placement risks client-authority confusion and host/module coupling | direct fit with accepted common backend contract | Backend preferred. |
| IP-01 fit | indirect consumer-side fit | direct common-backend fit | Backend preferred. |
| IP-08 fit | would tend toward client transport/generated-client concerns | can preserve semantic interface without choosing wire/endpoint | Backend preferred. |
| IP-09 fit | client must not turn cached/logical identity into authority | can model logical identity/revision without selecting storage | Backend preferred. |
| IP-10 constraint | introduces explicit client non-authority obligations | keeps client non-authority outside first slice | Backend preferred. |
| Synthetic boundary | Flutter widget entry exists; Android exact test roots absent | PHPUnit suites and test root declared | Backend has the clearer declared unit-test boundary. |
| Tool surfaces | Gradle + Java/Kotlin + Flutter/Dart + AAR integration | PHP + Composer + PHPUnit | Backend has fewer declared toolchain surfaces for this slice. |
| Dependency state | Flutter lock present; Android lock status unestablished; AAR coupling declared | Composer lock present; dependency availability unestablished | Both remain unknown; backend is less cross-tool coupled. |
| UI/device/platform assumptions | material risk | unnecessary for pure contract | Backend preferred. |
| Network/provider need | avoidable only with careful client isolation | unnecessary for pure contract | Backend preferred. |
| Storage/database need | not needed, but client cache concerns arise | not needed; IP-09 stays logical only | Backend preferred. |
| Real/private data | excluded | excluded | tie; both can be synthetic. |
| Legal/Safety policy | excluded | excluded | tie; neither gains authority. |
| Reversibility | cross-module placement risk | one bounded pure contract/test slice in one project | Backend preferred. |
| Review size | likely spans host/module or requires choosing one client layer | can remain one source/test contract slice | Backend preferred. |
| New authority surface | client state/route/cache/UI boundaries enter earlier | only selected backend direction plus later exact path/tool gates | Backend is narrower. |

## 5. Selected slice boundary, still not authorized

The future slice, if separately authorized after readiness and Owner gates, must be limited to one pure contract unit that demonstrates with conspicuously synthetic fixtures:

- authority owner/scope, actor/role, subject/participants and audience/purpose binding;
- source-owned condition taxonomy including `UNKNOWN != ABSENT`;
- source-local lineage/revision comparison only, with no global revision;
- currentness and freshness as separate evidence dimensions;
- immutable logical-intent identity and changed-semantic-input rejection;
- idempotency identity as correlation, never permission or success;
- authoritative outcome states including transport-ambiguous unknown outcome;
- correction/revocation/supersession invalidation without lifecycle reset;
- privacy-minimal output with no private content;
- no endpoint, wire, database, queue, transaction, provider or client implementation.

Synthetic fixtures must contain invented identifiers, revisions, conditions, intents and outcomes only. They must include no real identity, profile, verification evidence, Conversation content, notification token, telemetry, credential, external participant, production endpoint or provider call.

## 6. Exact immediate successor task

Run exactly one subsequent PRE-IMPLEMENTATION task, after this candidate is independently accepted:

`NEXT-IP-11E-BACKEND-PURE-COMMON-CONTRACT-SOURCE-TEST-BOUNDARY-AND-TOOLING-READINESS-DISCOVERY-V0-1`

Required objective:

> Against a fresh fixed accepted commit and an Owner-supplied literal allowlist under `services/backend-laravel/`, establish only the exact existing source namespace/path and unit-test placement suitable for one pure common authority-evidence/source-condition/immutable-intent contract slice; establish named PHP, Composer and PHPUnit executable/version availability under a fixed read-only command budget; distinguish declared/locked dependencies from locally available dependencies; and report all missing facts without editing source, acquiring/resolving dependencies, invoking project code, building, testing, running, migrating, generating, inspecting caches/artifacts, accessing production/real data, or using Sandbox/DEP13/B12.

The task must stop rather than invent a class/file namespace, test convention, dependency, adapter, database, endpoint or framework mechanism. It produces one readiness evidence document only. It does not implement the slice and does not create the final Owner implementation gate.

## 7. Remaining gates after selection

1. Fresh independent ACCEPT/REJECT review of this IP-11D candidate.
2. Accepted IP-11E backend source/test/tooling readiness evidence.
3. Any separately authorized dependency-availability/remediation or build-harness evidence required by IP-11E findings.
4. One exact Owner implementation gate binding the accepted commit, one named pure slice, literal source/test paths, commands/attempt budget, synthetic-only fixtures and exclusions.
5. One implementation candidate and fresh independent review.

No item above authorizes production, real/private data, legal conclusions, Safety Operations or the client direction.

## 8. Independently checkable validation matrix

| ID | Check | Evidence / disposition | Result |
|---|---|---|---|
| V001 | Task base provenance | `8280d5e2856d0d9bb4e675fc148d9f2f7a45a228` | PASS |
| V002 | Task blob provenance | `0d1b27acfa990334bde9d54480d64152b9b00705` | PASS |
| V003 | IP-11C acceptance identity | candidate `acae179a...`; accepted result blob `4de32034...` | PASS |
| V004 | IP-11C accepted direction count | exactly two independent directions | PASS |
| V005 | Client direction provenance | Android host plus embedded Flutter module | PASS |
| V006 | Backend direction provenance | independent Laravel project | PASS |
| V007 | Post-IP01..IP10 acceptance identity | candidate `adc7efc...`; result blob `d7949ce...` | PASS |
| V008 | Accepted first-slice shape | one pure common authority/evidence/intent contract slice | PASS |
| V009 | IP-01 acceptance identity | candidate `2d3f1aa...`; result blob `c4cb07b...` | PASS |
| V010 | IP-08 acceptance identity | candidate `ad79c78...`; result blob `26f8a67...` | PASS |
| V011 | IP-09 acceptance identity | candidate `e0e523b...`; result blob `875ee96...` | PASS |
| V012 | IP-10 acceptance identity | candidate `996128a...`; result blob `1da7ddd...` | PASS |
| V013 | Required choice cardinality | exactly one direction selected | PASS |
| V014 | Selected direction | backend only | PASS |
| V015 | Selected root | `services/backend-laravel/` | PASS |
| V016 | Client disposition | retained for later route | PASS |
| V017 | Client rejection status | explicitly not rejected | PASS |
| V018 | Third direction | none invented | PASS |
| V019 | General industry preference | not used | PASS |
| V020 | Framework popularity | not used | PASS |
| V021 | Familiarity preference | not used | PASS |
| V022 | Aesthetic preference | not used | PASS |
| V023 | Undocumented scalability claim | not used | PASS |
| V024 | Accepted evidence-only basis | eight authorized documents only | PASS |
| V025 | Source inspection | none performed | PASS |
| V026 | Manifest reinspection | none performed | PASS |
| V027 | Repository enumeration/search | none performed | PASS |
| V028 | Historical repository access | none performed | PASS |
| V029 | Technology direction scope | first direction only | PASS |
| V030 | Implementation authority consequence | none created | PASS |
| V031 | Production authority consequence | none created | PASS |
| V032 | Real/private-data authority consequence | none created | PASS |
| V033 | Client host identity | Android application host accepted | PASS |
| V034 | Client embedded identity | Flutter module accepted | PASS |
| V035 | Client coherence | Android consumes Flutter AAR by declaration | PASS |
| V036 | Client project count | coupled host/module pair | PASS |
| V037 | Client Gradle surface | declared and availability unknown | PASS |
| V038 | Client Java/Kotlin surface | declared and availability unknown | PASS |
| V039 | Client Flutter/Dart surface | declared and availability unknown | PASS |
| V040 | Client AAR integration surface | explicitly declared | PASS |
| V041 | Android unit-test locator | exact root absent in accepted IP-11C | PASS |
| V042 | Android instrumentation-test locator | exact root absent in accepted IP-11C | PASS |
| V043 | Flutter widget-test locator | exact entry present by accepted evidence | PASS |
| V044 | Flutter main delegation seam | delegates to non-IP-11C-allowlisted production entry | PASS |
| V045 | Client UI risk | must be excluded from pure slice | PASS |
| V046 | Client route risk | must not become authority | PASS |
| V047 | Client cache risk | must not become current authority | PASS |
| V048 | Client state risk | must not become source authority | PASS |
| V049 | Client device/platform risk | unnecessary for pure slice | PASS |
| V050 | Client provider/network risk | unnecessary for pure slice | PASS |
| V051 | Client broad-work risk | higher due host/module boundary | PASS |
| V052 | Client later-route preservation | explicit and reversible | PASS |
| V053 | Backend project identity | standalone Laravel Composer project | PASS |
| V054 | Backend source root | `app/` declared/present by accepted evidence | PASS |
| V055 | Backend test root | `tests/` declared/present by accepted evidence | PASS |
| V056 | Backend test configuration | PHPUnit Unit/Feature suites declared | PASS |
| V057 | Backend lock evidence | Composer lock present by accepted evidence | PASS |
| V058 | Backend runtime declaration | PHP `^8.2` | PASS |
| V059 | Backend framework declaration | Laravel `^11.31` | PASS |
| V060 | Backend test dependency declaration | PHPUnit `^11.0.1` | PASS |
| V061 | Backend locked framework fact | Laravel `v11.48.0` | PASS |
| V062 | Backend locked PHPUnit fact | PHPUnit `11.5.55` | PASS |
| V063 | Backend command entry | `artisan` declared | PASS |
| V064 | Backend autoload boundary | `App\\` to `app/` | PASS |
| V065 | Backend test autoload boundary | `Tests\\` to `tests/` | PASS |
| V066 | Backend independent direction | not subordinate to client pair | PASS |
| V067 | Backend UI requirement | none for pure contract | PASS |
| V068 | Backend device requirement | none for pure contract | PASS |
| V069 | Backend provider requirement | none for pure contract | PASS |
| V070 | Backend database requirement | none for pure contract | PASS |
| V071 | Backend endpoint requirement | none for pure contract | PASS |
| V072 | Backend deployment requirement | none for pure contract | PASS |
| V073 | Pure slice eligibility — client | possible in principle | PASS |
| V074 | Pure slice eligibility — backend | direct accepted-contract fit | PASS |
| V075 | Private-data avoidance — client | possible with synthetic isolation | PASS |
| V076 | Private-data avoidance — backend | possible with synthetic contract fixtures | PASS |
| V077 | Production avoidance — client | possible but cross-tool surface remains | PASS |
| V078 | Production avoidance — backend | direct; no external system required | PASS |
| V079 | Legal seam avoidance — client | possible only by excluding product UI/policy | PASS |
| V080 | Legal seam avoidance — backend | direct for common semantic contract | PASS |
| V081 | Safety seam avoidance — client | possible only by excluding product flows | PASS |
| V082 | Safety seam avoidance — backend | direct for pure common contract | PASS |
| V083 | Provider avoidance — client | requires excluding declared integration surfaces | PASS |
| V084 | Provider avoidance — backend | no provider needed | PASS |
| V085 | Unrelated policy avoidance — client | greater risk from client rendering/action concerns | PASS |
| V086 | Unrelated policy avoidance — backend | pure contract remains policy-input agnostic | PASS |
| V087 | Broad UI avoidance — client | requires extra boundary policing | PASS |
| V088 | Broad UI avoidance — backend | naturally outside slice | PASS |
| V089 | Broad infrastructure avoidance — client | AAR/host build coupling raises surface | PASS |
| V090 | Broad infrastructure avoidance — backend | no database/queue/deployment required | PASS |
| V091 | Review-cycle fit — client | weaker due coupled targets | PASS |
| V092 | Review-cycle fit — backend | one pure source/test slice in principle | PASS |
| V093 | IP-01 authority owner/scope | included in future slice | PASS |
| V094 | IP-01 actor/role binding | included in future slice | PASS |
| V095 | IP-01 subject/participant binding | included in future slice | PASS |
| V096 | IP-01 audience/purpose binding | included in future slice | PASS |
| V097 | Source-condition taxonomy | included in future slice | PASS |
| V098 | `UNKNOWN != ABSENT` | mandatory synthetic case | PASS |
| V099 | Source-local revision | mandatory synthetic case | PASS |
| V100 | No global revision | preserved | PASS |
| V101 | Same-lineage comparison | preserved | PASS |
| V102 | Currentness/freshness separation | mandatory synthetic case | PASS |
| V103 | Immutable intent identity | mandatory synthetic case | PASS |
| V104 | Changed semantic input | must reject identity reuse | PASS |
| V105 | Idempotency/permission separation | preserved | PASS |
| V106 | Idempotency/success separation | preserved | PASS |
| V107 | Transport ambiguity | unknown authoritative outcome supported | PASS |
| V108 | Reconciliation semantics | IP-08 fit without transport realization | PASS |
| V109 | Projection semantics | source authority preserved | PASS |
| V110 | Revalidation semantics | semantic only; no endpoint selected | PASS |
| V111 | Logical authority/provenance | IP-09 fit without database | PASS |
| V112 | Correction/revocation/supersession | invalidation without lifecycle reset | PASS |
| V113 | Synthetic identifiers | invented only | PASS |
| V114 | Synthetic revisions | invented only | PASS |
| V115 | Synthetic conditions | invented only | PASS |
| V116 | Synthetic intents | invented only | PASS |
| V117 | Synthetic outcomes | invented only | PASS |
| V118 | Real identity exclusion | explicit | PASS |
| V119 | Verification evidence exclusion | explicit | PASS |
| V120 | Conversation content exclusion | explicit | PASS |
| V121 | Device/provider token exclusion | explicit | PASS |
| V122 | Telemetry exclusion | explicit | PASS |
| V123 | Credential exclusion | explicit | PASS |
| V124 | External participant exclusion | explicit | PASS |
| V125 | Production endpoint exclusion | explicit | PASS |
| V126 | Database/schema choice | not made | PASS |
| V127 | Endpoint/wire choice | not made | PASS |
| V128 | Queue/transaction/provider choice | not made | PASS |
| V129 | Exact successor count | one | PASS |
| V130 | Successor class | pre-implementation readiness discovery | PASS |
| V131 | Successor target | backend direction only | PASS |
| V132 | Successor source/test objective | exact pure-contract placement evidence | PASS |
| V133 | Successor tooling objective | PHP/Composer/PHPUnit availability only | PASS |
| V134 | Successor dependency distinction | declared/locked is not locally available | PASS |
| V135 | Successor write boundary | one evidence document; no source edit | PASS |
| V136 | Successor execution boundary | no acquire/build/test/run/migrate/generate | PASS |
| V137 | Successor path boundary | Owner-supplied literal allowlist | PASS |
| V138 | Successor stop boundary | stop rather than invent mechanism/path | PASS |
| V139 | Exact backend source namespace/file | not established by accepted evidence | RETAINED_UNKNOWN |
| V140 | Exact backend unit-test file/namespace | not established by accepted evidence | RETAINED_UNKNOWN |
| V141 | PHP executable availability | not checked | RETAINED_UNKNOWN |
| V142 | PHP executable version | not checked | RETAINED_UNKNOWN |
| V143 | Composer executable availability | not checked | RETAINED_UNKNOWN |
| V144 | Composer executable version | not checked | RETAINED_UNKNOWN |
| V145 | PHPUnit runner availability | not checked | RETAINED_UNKNOWN |
| V146 | Locked dependency local availability | not checked | RETAINED_UNKNOWN |
| V147 | Composer dependency resolution | not checked | RETAINED_UNKNOWN |
| V148 | Autoloader availability | not checked | RETAINED_UNKNOWN |
| V149 | Backend build/bootstrap viability | not run | RETAINED_UNKNOWN |
| V150 | Backend test viability | not run | RETAINED_UNKNOWN |
| V151 | Missing `.env.example` consequence | accepted declaration seam remains unresolved | RETAINED_UNKNOWN |
| V152 | Exact class/file naming convention | must be discovered, not invented | RETAINED_UNKNOWN |
| V153 | Exact fixture/test-double convention | must be discovered, not invented | RETAINED_UNKNOWN |
| V154 | Need for additional dependency | unknown; first slice should prefer none | RETAINED_UNKNOWN |
| V155 | Allowed project command budget | must be set by later Owner task | RETAINED_UNKNOWN |
| V156 | Allowed generated/write paths | none now; later validation task must specify | RETAINED_UNKNOWN |
| V157 | Final implementation commit/path binding | not yet established | RETAINED_UNKNOWN |
| V158 | Final Owner implementation gate | not issued | RETAINED_UNKNOWN |
| V159 | Backend implementation execution | blocked until IP-11D acceptance, IP-11E readiness and exact Owner gate | BLOCKED |
| V160 | Client implementation execution | retained for later route and not authorized by this selection | BLOCKED |

**PASS = 138 / RETAINED_UNKNOWN = 20 / BLOCKED = 2**

## 9. Every retained unknown

| IDs | Retained unknown group | Effect |
|---|---|---|
| V139–V140 | Exact backend source/test placement | IP-11E must establish literal namespace/path boundaries before any code gate. |
| V141–V145 | PHP/Composer/PHPUnit availability and versions | IP-11E must distinguish declarations from installed tooling. |
| V146–V148 | Dependency/autoloader availability and resolution | No availability or resolution claim exists; acquisition remains unauthorized. |
| V149–V150 | Backend bootstrap/build/test viability | No command has run; declaration evidence cannot prove execution. |
| V151 | Missing `.env.example` consequence | Must remain explicit; no alternate locator or default may be invented. |
| V152–V154 | Class/test/fixture convention and dependency need | Must be discovered or kept minimal; no framework mechanism may be assumed. |
| V155–V156 | Future command and write budget | Requires a fresh exact Owner task; current budget is zero. |
| V157–V158 | Final commit/path binding and implementation gate | Remain prerequisites after readiness acceptance. |

## 10. Every blocker

| ID | Blocker | Exact effect | Non-effect |
|---|---|---|---|
| V159 | Backend execution prerequisites remain open | blocks any backend code, dependency, build or test execution | does not block selecting backend as the first direction or running a separately authorized read-only IP-11E task |
| V160 | Client direction is deliberately deferred | blocks treating IP-11D as client implementation authority | does not reject, deprecate or permanently exclude the client direction |

## 11. Preserved closed lanes

- `TOOL_AVAILABILITY = NOT_CHECKED`
- `DEPENDENCY_RESOLUTION = NOT_CHECKED`
- `BUILD = NOT_RUN`
- `TEST = NOT_RUN`
- `RUNTIME = NOT_RUN`
- `CACHE_ARTIFACT_STATE = NOT_CHECKED`
- M1 = exhausted
- M2 = deferred
- M3 = blocked
- Sandbox/DEP13/B12 = unauthorized/unestablished
- production/private-real-data/legal/Safety authority = absent

## 12. Terminal classification

`SELECT_BACKEND_DIRECTION_FIRST`

`RETAINED_FOR_LATER_IMPLEMENTATION_ROUTE — NOT REJECTED`

`FIRST IMPLEMENTATION DIRECTION SELECTED — NON-SELECTED DIRECTION RETAINED — NEXT PRE-IMPLEMENTATION READINESS TASK IDENTIFIED — NO IMPLEMENTATION AUTHORITY CREATED`
