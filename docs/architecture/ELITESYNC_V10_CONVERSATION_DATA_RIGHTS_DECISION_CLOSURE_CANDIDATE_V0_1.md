# EliteSync v10｜Conversation Data-Rights Decision-Closure Candidate｜v0.1

Status: `CANDIDATE — TRACK 2 PRODUCT / LEGAL / DATA-RIGHTS DECISION ONLY — NOT LEGAL ADVICE — NOT PRODUCTION READY`

Repository: `zcx369658780/EliteSync-v10`

Fresh decision base: `8490663d38a6e8c2b7ec3e73f29ba416047d947f`

Task authority: `docs/architecture/ELITESYNC_V10_NEXT_LDR01_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_TASK_V0_1.md`

Research access date: `2026-09-13`

## 1. Executive decision summary

This candidate closes the product meaning of Conversation retention, export, deletion, revocation, and closed history without claiming a universal legal result or authorizing implementation.

Recommended product posture for Owner decision:

1. Live Conversation and retained history are separate authorities. Revoking messaging consent, pausing Connection, or closing Connection stops future messaging authority before it implies historical deletion.
2. `Mute`, `Pause Conversation`, `Close Conversation`, `Block`, `Report`, `Hide from my view`, `Export`, and `Delete` remain distinct actions. None may borrow another action's authority or copy.
3. Historical content may be eligible for a separate read-only history authority while it is lawfully retained, but it is never `CV_ACTIVE`, never permits new sending, and is not guaranteed until the applicable retention, participant, Safety, and regional rules are established.
4. `Hide from my view` changes only the requesting participant's presentation. It is not backend erasure and does not change the peer's view.
5. A deletion request is an adjudicated data-right/product request, not an instant promise that every shared copy or another participant's independently held rights will be erased.
6. Export is a scoped copy/access operation. Data about the requester, requester-authored content, shared content, metadata, and system-derived information require separate inclusion and redaction decisions; “export my data” must not mean an unfiltered transcript by default.
7. Withdrawal of consent stops future processing that depends on that consent. It does not, by itself, invalidate previously lawful processing or retroactively erase already-shared history.
8. Conversation content remains `CONVERSATION_SHARED_PRIVATE` and unavailable for unrelated Match, ranking, Compatibility scoring, advertising, or model training by default.
9. Exact durations, legal bases, statutory exceptions, request deadlines, age rules, and region-specific rights remain `REGION-SPECIFIC AUTHORITY REQUIRED` until material launch facts are established.
10. No export, delete, revoke, retention, or history control may be represented as available before both backend authority and applicable legal/data-rights authority exist.

This candidate does not provide legal advice, determine which law applies, or establish production legal readiness.

## 2. Binding product boundaries

Preserve exactly:

- `Match != Connection != Conversation != Relationship`
- `UNKNOWN != ABSENT`
- `DEFERRED != MISSING`
- `STATE VOCABULARY != AUTHORITY`
- `ROUTE IDENTITY != CONSENT`
- `TRANSPORT FAILURE != DOMAIN OUTCOME`
- `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`
- `CURRENT SOURCE EXISTS != MUST KEEP`
- Block != Report
- Report != Finding
- Allegation != Finding
- immediate protection != guilt/punishment
- private Conversation != default Match/ranking/training data
- no globally public MVP Profile authority
- candidate-scoped Showcase
- no authoritative Compatibility total score

Live Product Conversation continues to require both authoritative `CN_ACTIVE` and separate authoritative mutual messaging consent. This Track 2 candidate neither supplies those authorities nor weakens B01-D fail-closed behavior.

## 3. Decision labels

- `PRODUCT DECISION CANDIDATE`: recommended product meaning awaiting Owner acceptance.
- `SUPPORTED LEGAL CONSTRAINT`: a constraint supported within the cited source's jurisdiction and applicability only.
- `REGION-SPECIFIC AUTHORITY REQUIRED`: the conclusion depends on launch geography, regulated role, age model, legal basis, or other unestablished facts.
- `IMPLEMENTATION DEFERRED`: product semantics can be stated, but no technical behavior is authorized here.
- `UNKNOWN`: available evidence is insufficient; no safe result is inferred.

No `SUPPORTED LEGAL CONSTRAINT` in this document is a finding that the cited law applies to EliteSync.

## 4. LDR-01 through LDR-06 decision matrix

| Area | Product decision candidate | Supported legal constraint | Region-specific authority required | Implementation status |
|---|---|---|---|---|
| LDR-01 Retention | Retain by purpose and content class; live access, history access, and service retention are distinct; use minimization and scheduled review; do not promise a universal period | EU GDPR Art. 5 requires purpose limitation, minimization, and storage limitation where applicable; PRC PIPL Arts. 17 and 19 require notice of retention period and the shortest period necessary absent other law | Applicable law, lawful basis, exact period, age rules, legal holds, security/fraud records, account-exit rules | `IMPLEMENTATION DEFERRED` |
| LDR-02 Export | Export is a scoped request covering defined classes, not an automatic raw transcript; protect the peer's information and explain exclusions | EU GDPR Arts. 15 and 20 distinguish access/copy from portability and protect others' rights; PRC PIPL Art. 45 provides access/copy and conditional transfer; UK ICO guidance narrows portability | Applicable right, controller role, identity verification, request deadline, peer-content balancing, exceptions, transfer conditions | `IMPLEMENTATION DEFERRED` |
| LDR-03 Deletion | Separate hide-for-me, deletion of requester-controlled data, account/data deletion request, shared-content request, and service erasure; never label all as “Delete chat” | EU GDPR Art. 17 and UK ICO guidance make erasure conditional and non-absolute; PRC PIPL Art. 47 states deletion grounds and limited preservation where law or technical difficulty applies; California OAG describes deletion with exceptions | Applicable erasure right, exceptions, children/age rules, peer rights, legal obligations, backup treatment, complaint/appeal process | `IMPLEMENTATION DEFERRED` |
| LDR-04 Revoke | Messaging-consent revoke stops future send authority; optional-purpose revoke stops future use for that purpose; neither silently promises historical erasure | EU GDPR Art. 7(3) and PRC PIPL Art. 15 state withdrawal does not affect lawfulness/validity of pre-withdrawal consent-based processing | Which processing relies on consent, consequences for history, other lawful bases, notice and request-handling rules | `IMPLEMENTATION DEFERRED` |
| LDR-05 Closed history | Closing/pausing stops future messaging authority; historical read, export, delete request, service retention, and peer visibility are evaluated separately | Storage limitation, access/copy, erasure conditions, and others' rights prevent equating closure with one universal data outcome where the cited regimes apply | Default history availability, duration, post-block/Safety restrictions, peer visibility, death/account closure, regional rights | `IMPLEMENTATION DEFERRED` |
| LDR-06 Regional boundary | Adopt clear global product vocabulary and privacy-preserving defaults; gate legal promises and operational rights by accepted launch-region authority | EU/EEA, UK, PRC, and California sources expose materially different scope, conditions, terminology, and exceptions | Launch regions, establishment/targeting, controller/processor or personal-information-handler role, age model, hosting/transfers, applicable sector rules | `IMPLEMENTATION DEFERRED` |

## 5. LDR-01 — Conversation retention semantics

### 5.1 Retention classes

| Context | Product decision candidate | Must not mean | Unclosed authority |
|---|---|---|---|
| Active Conversation content | Retain only for the accepted private Conversation purpose and an applicable, disclosed retention rule; keep future send/read subject to current gates | indefinite retention; Match/ranking/training availability; public Profile data | exact period, legal basis, age and regional requirements |
| Messaging consent revoked | End future send authority that depends on mutual messaging consent; preserve history only under a separate lawful retention and history-access decision | retroactive invalidity; automatic erase; continued `CV_ACTIVE` | post-revoke read/export/delete scope by region and Owner decision |
| Product Connection paused | `CN_ACTIVE` is absent, so no live `CV_ACTIVE` or new messaging; separately evaluate retained history | guilt, punishment, deletion, absence of prior Conversation | whether read-only history remains available and for how long |
| Product Connection closed | End live messaging authority; evaluate history, export, deletion request, retention, and peer visibility separately | deleted, invisible, erased, blocked, reported, or guilty | default history policy and applicable regional rights |
| Account closure or deletion request | Stop ordinary account access and open a scoped account/data-rights process; classify shared content and retained records rather than promising total instant erasure | automatic erasure of every peer-held or legally required record | applicable erasure scope, identity handling, timelines, exceptions |
| Operational/security records | Keep separate from user-visible Conversation history and retain only on a documented lawful/minimum-necessary basis | ordinary chat history, Safety finding, guilt, Compatibility input, indefinite warehouse | applicable basis, categories, access controls, exact schedule |

### 5.2 Retention rule

`PRODUCT DECISION CANDIDATE`: every retained class must have a named purpose, accountable owner, start/end trigger, review trigger, and deletion or irreversible-de-identification outcome. A content-class schedule is required before technical design, but this candidate does not choose durations.

`SUPPORTED LEGAL CONSTRAINT`: where EU GDPR applies, Article 5(1)(b), (c), and (e) require purpose limitation, data minimization, and storage limitation. Where PRC PIPL applies, Articles 17 and 19 require notice of the storage period and, absent contrary law, the shortest period necessary for the processing purpose.

`REGION-SPECIFIC AUTHORITY REQUIRED`: no single retention duration is established because launch geography, applicable law, age model, lawful bases, contractual promises, and required operational/security records are unknown.

## 6. LDR-02 — Export semantics

### 6.1 What an export request means

`PRODUCT DECISION CANDIDATE`: “Export” means a scoped request for a portable or human-usable copy of eligible information associated with the authenticated requester. It must identify included classes, excluded/redacted classes, the relevant time scope, and whether it is a product copy, legal access response, or legal portability response. Those are related but not interchangeable.

| Information class | Candidate treatment | Reason for separate treatment |
|---|---|---|
| Data about the requester | Eligible for scoped access/copy subject to identity, applicability, and exceptions | Core subject-access category, but exact legal scope varies |
| Requester-authored Conversation content | Candidate for inclusion where retained and requester-authorized | Authorship does not remove peer privacy or third-party content |
| Peer-authored/shared Conversation content | Do not promise wholesale inclusion; assess requester-related content, peer rights, redaction, and applicable law | One participant cannot authorize another participant's personal information |
| Conversation metadata | Include only requester-related, intelligible, purpose-relevant fields where authorized | Metadata can expose peer activity, security signals, or internal operations |
| System-derived information | Classify separately; explain whether it is observed, inferred, or decision-support output; exclude protected internal/third-party material where lawful | Derived information is not automatically “provided by” the requester or portable |
| Operational/Safety-restricted records | Not part of ordinary Conversation export; route only through separately authorized legal/Safety handling | Export must not reveal reporters, restricted evidence, controls, or allegations as findings |

### 6.2 Export constraints

- `SUPPORTED LEGAL CONSTRAINT`: EU GDPR Article 15 provides access and a copy of personal data, while Article 15(4) protects the rights and freedoms of others. Article 20 portability is narrower: it applies to specified personal data provided by the data subject under consent or contract and automated processing, and Article 20(4) also protects others' rights and freedoms.
- `SUPPORTED LEGAL CONSTRAINT`: UK ICO portability guidance likewise limits portability to qualifying information provided to a controller, under consent/contract and automated processing, and recognizes adverse effects on others' rights.
- `SUPPORTED LEGAL CONSTRAINT`: PRC PIPL Article 45 establishes access/copy and a conditional route for transfer where regulator-set conditions are met.
- `REGION-SPECIFIC AUTHORITY REQUIRED`: exact inclusion, redaction, identity assurance, response deadline, refusal ground, transfer entitlement, and appeal route.
- `IMPLEMENTATION DEFERRED`: format, archive layout, delivery channel, cryptography, job design, and service boundary.

## 7. LDR-03 — Deletion semantics

### 7.1 Distinct operations

| User-facing concept | Product meaning candidate | Effect on peer | Effect on service retention |
|---|---|---|---|
| `Hide from my view` | Remove or suppress the Conversation from the requester's ordinary UI | None | None; not erasure |
| Delete requester-controlled draft/local data | Delete data that has not become shared content and remains solely under the requester-controlled scope | None | Only the defined requester-controlled copy |
| Request deletion of authored shared content | Submit a scoped request for authority evaluation; do not promise “delete for everyone” | Unknown until peer/legal/product rules are accepted | Unknown until applicable authority decides |
| Account/data deletion request | Start a verified, scoped rights/account process across product data classes | Does not automatically determine peer-held visibility | Apply accepted per-class outcome and lawful exceptions |
| Service erasure | Authoritative removal or irreversible de-identification under an accepted rule | May affect peer view only if that outcome is separately authorized and disclosed | Ends ordinary service retention for the erased class |
| Preserve minimum operational/security record | Restrict to the separately justified minimum and prohibit ordinary product use | No ordinary Conversation visibility | Continue only for the accepted basis and period |

`PRODUCT DECISION CANDIDATE`: the product must never offer a single ambiguous `Delete chat` control. Each control must state whether it hides locally, submits a request, deletes only requester-controlled material, affects peer visibility, or erases service-held data.

`SUPPORTED LEGAL CONSTRAINT`: erasure is not universally absolute. EU GDPR Article 17 defines triggers and exceptions; UK ICO official guidance expressly describes it as conditional and non-absolute. PRC PIPL Article 47 defines deletion grounds and provides that, where a legally required period has not expired or deletion is technically difficult, processing must be limited to storage and necessary security measures. California's Attorney General describes a right to delete for covered California consumers “with some exceptions.”

`REGION-SPECIFIC AUTHORITY REQUIRED`: which right applies, lawful exceptions, peer/third-party balancing, minor protections, backup handling, verification, response period, refusal notice, and appeal/complaint mechanisms.

## 8. LDR-04 — Revoke semantics

### 8.1 Messaging consent

`PRODUCT DECISION CANDIDATE`: revoking mutual messaging consent invalidates the future messaging-consent input to B01-D. The live Conversation gate must fail closed immediately for new send authority. A revoked participant cannot be treated as having consented because a route, existing row, cached grant, unread count, transport session, or the other participant still exists.

Historical read, export, deletion request, service retention, and peer visibility remain separate decisions. Revocation is not evidence of guilt, a Safety finding, a Report, a Block, objective incompatibility, or Relationship state.

### 8.2 Optional-purpose consent

`PRODUCT DECISION CANDIDATE`: revocation for an optional purpose stops future use for that purpose. Private Conversation remains unavailable for unrelated Match, ranking, Compatibility scoring, advertising, analytics enrichment, or model training by default; absence of optional consent cannot be replaced by a broad product-terms inference.

### 8.3 Non-retroactivity and other bases

- `SUPPORTED LEGAL CONSTRAINT`: EU GDPR Article 7(3) states that withdrawal does not affect the lawfulness of consent-based processing before withdrawal and requires withdrawal to be as easy as giving consent.
- `SUPPORTED LEGAL CONSTRAINT`: PRC PIPL Article 15 states that withdrawal does not affect the validity of consent-based processing performed before withdrawal and requires a convenient withdrawal method.
- `REGION-SPECIFIC AUTHORITY REQUIRED`: whether consent is the applicable basis for each purpose; whether another lawful basis applies; required notices; downstream retention; and the exact effect on prior content.
- `IMPLEMENTATION DEFERRED`: consent ledger, event propagation, access invalidation, and user controls.

## 9. LDR-05 — Closed-history state matrix

The matrix below is a product-semantic candidate. `CONDITIONAL` means a separate authority must affirmatively permit the operation; it is not a default grant.

| Context | Send new content | Read prior content | Export prior content | Request deletion | Service retention | Peer visibility |
|---|---|---|---|---|---|---|
| `CN_ACTIVE` + current mutual messaging consent | `ALLOWED ONLY BY B01-D AUTHORITATIVE GATE` | `ALLOWED ONLY BY B01-D AUTHORITATIVE GATE` | `CONDITIONAL — scoped export authority` | `AVAILABLE AS REQUEST, NOT GUARANTEED OUTCOME` | `CONDITIONAL — accepted purpose/schedule` | `CONDITIONAL — current Conversation audience` |
| Messaging consent revoked | `DENIED` | `CONDITIONAL — separate history authority; never CV_ACTIVE` | `CONDITIONAL — scoped rights/export authority` | `AVAILABLE AS REQUEST, NOT RETROACTIVE PROMISE` | `CONDITIONAL — no consent-based future use; assess other accepted basis` | `CONDITIONAL — not automatically removed` |
| Connection paused (`CN_PAUSED`) | `DENIED` | `CONDITIONAL — separate history authority` | `CONDITIONAL` | `AVAILABLE AS REQUEST` | `CONDITIONAL` | `CONDITIONAL` |
| Connection closed (`CN_CLOSED`) | `DENIED` | `CONDITIONAL — separate read-only history authority` | `CONDITIONAL` | `AVAILABLE AS REQUEST` | `CONDITIONAL — per-class schedule and applicable law` | `CONDITIONAL — closure alone does not remove history` |
| Requester hides Conversation | Unchanged by hide alone; live gates still govern | Hidden from requester's ordinary view | Unchanged; separate export authority | Separate action | Unchanged | Unchanged |
| Account closure/deletion request pending | `DENIED` | `CONDITIONAL — account-exit/rights handling only` | `CONDITIONAL — verified request process` | `PENDING AUTHORITY DECISION` | `CONDITIONAL — per-class adjudication` | `CONDITIONAL — no automatic peer erasure` |
| Authoritative erasure completed for a class | `DENIED` for erased live authority | `UNAVAILABLE` for erased content, without claiming the person/history never existed | Excludes erased content unless an applicable retained rights record requires otherwise | Completed only for defined scope | No ordinary retention of erased class | Removed only to the extent the authoritative outcome covers peer-visible copies |
| Separately justified operational/security record | Not Conversation content | Not ordinary history | Not ordinary export; rights process may still apply | Separately adjudicated | Minimum necessary, access-restricted, time-bounded by applicable authority | Not peer-visible |

`PRODUCT DECISION CANDIDATE`: closed history, if authorized, is a read-only product surface with its own audience, freshness, retention, and restriction evidence. It cannot satisfy or bypass the two live B01-D inputs.

`UNKNOWN`: the default availability and duration of read-only history after revoke, pause, close, Block, account exit, or a Safety restriction remain unestablished until Owner and region-specific authority decide them.

## 10. LDR-06 — Region-specific applicability and unknown register

| Material fact | Current status | Why it matters | Required closure authority |
|---|---|---|---|
| Launch country/region set | `UNKNOWN` | Determines potentially applicable rights, notices, timelines, exceptions, and regulator | Owner launch decision plus qualified jurisdiction-specific review |
| Establishment, targeting, and user-location facts | `UNKNOWN` | Several regimes have territorial rules beyond repository/developer location | Verified operating model and legal applicability assessment |
| Controller/processor/personal-information-handler roles | `UNKNOWN` | Determines obligations, responsibility, notices, and request handling | Entity/processing-role map plus qualified legal review |
| Contracting/legal entity | `UNKNOWN` | Identifies accountable party and applicable contractual/regulatory duties | Owner/company authority |
| Age/eligibility model | `UNKNOWN` | Child/minor rules may change consent, erasure, retention, and verification | Separate Owner/product/legal decision |
| Purpose-by-purpose lawful basis | `UNKNOWN` | Revocation and erasure consequences depend on basis and purpose | Qualified legal review after purpose inventory |
| Hosting, subprocessors, and cross-border transfers | `UNKNOWN` | May trigger transfer, localization, contractual, or notice requirements | Later deployment facts and region-specific authority |
| Conversation data classification | `UNKNOWN` beyond `CONVERSATION_SHARED_PRIVATE` | User text may contain sensitive or third-party information without becoming a public Profile | Data inventory and region-specific classification review without private-data inspection |
| Rights request verification and timelines | `UNKNOWN` | Rules and permitted identity checks vary | Applicable-law decision and later implementation contract |
| Legal holds, fraud/security, and Safety records | `UNKNOWN` | Some records may need separate preservation or restricted access | Specific lawful basis, scope, owner, and duration; not a blanket exception |
| Backups and technical deletion constraints | `UNKNOWN` | Applicable regimes may distinguish active use, storage-only restriction, and eventual erasure | Region-specific authority followed by implementation design |
| Deceased-user and representative rights | `UNKNOWN` | Regimes differ materially | Launch-region-specific authority |

No jurisdiction is inferred from repository location, user location, developer location, app-store availability, source language, or historical assumptions.

## 11. Authoritative-source evidence table

| Source organization | Exact source and date | Relevant provision / heading | Jurisdiction and applicability | Supports | Does not establish for EliteSync |
|---|---|---|---|---|---|
| Publications Office of the European Union / EUR-Lex | Regulation (EU) 2016/679, OJ publication `2016-05-04`; accessed `2026-09-13`; https://eur-lex.europa.eu/eli/reg/2016/679/oj | Arts. 3, 5(1)(b)(c)(e), 7(3), 12, 15, 17, 20, 25 | EU/EEA scope subject to Article 3 and other material facts | Purpose limitation, minimization, storage limitation; easy withdrawal without retroactive effect; access/copy; erasure conditions/exceptions; portability scope; protection of others' rights | That GDPR applies; any lawful basis; exact duration; exact shared-message inclusion/deletion; production compliance |
| UK Information Commissioner's Office | “Right to erasure”; page update date not stated; accessed `2026-09-13`; https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/individual-rights/individual-rights/right-to-erasure/ | “What is the right to erasure?”, “When does the right to erasure apply/not apply?” | UK GDPR guidance for organizations within its scope | Erasure is conditional, not absolute; grounds and exceptions must be assessed | UK applicability; outcome for a particular message, peer, backup, or record; legal advice |
| UK Information Commissioner's Office | “Right to data portability”; page update date not stated; accessed `2026-09-13`; https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/individual-rights/individual-rights/right-to-data-portability/ | “When does the right apply?”, “What does the right apply to?”, “information about others” | UK GDPR guidance for organizations within its scope | Portability is limited to qualifying provided/observed data under consent or contract and automated processing; others' rights may constrain transmission | That all exports are portability; raw transcript entitlement; UK applicability; exact format |
| UK Information Commissioner's Office | “What is valid consent?”; page update date not stated; accessed `2026-09-13`; https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/lawful-basis/consent/what-is-valid-consent/ | Article 7 conditions; right to withdraw consent easily and at any time | UK GDPR guidance where consent is relied upon | Consent requires objective, freely given, specific, informed, unambiguous evidence and a withdrawal path | That consent is EliteSync's lawful basis; historical erasure; product messaging-consent implementation |
| Cyberspace Administration of China, reproducing the National People's Congress text | 《中华人民共和国个人信息保护法》, published `2021-08-20`; accessed `2026-09-13`; https://www.cac.gov.cn/2021-08/20/c_1631050028355286.htm | Arts. 3, 15, 17, 19, 45, 47, 50 | PRC territorial scope under Article 3 and other material facts | Convenient withdrawal and non-retroactive validity; retention notice and shortest-necessary period; access/copy and conditional transfer; deletion grounds; request mechanism | That PIPL applies; exact period; exact shared-content outcome; transfer entitlement; production readiness |
| California Department of Justice, Office of the Attorney General | “California Consumer Privacy Act (CCPA)”, updated `2026-08-28`; accessed `2026-09-13`; https://oag.ca.gov/privacy/ccpa | Rights overview; resident/applicability FAQ | Covered California consumers and covered businesses subject to CCPA/CPRA | Rights include know, delete with exceptions, correct, and limit; the page expressly limits consumer rights to California residents | That CCPA applies; that every Conversation record is deletable; exact exceptions, shared-content outcome, or implementation |

These sources were used as bounded examples of authoritative constraints and jurisdictional variation. They are not a complete global legal survey.

## 12. Impact on Track 1 B01-D and Privacy Control Center

### B01-D Conversation runtime gate

The accepted live gate remains unchanged:

1. current authoritative `CN_ACTIVE`; and
2. separate current authoritative mutual messaging consent.

This candidate adds a conceptual boundary only: a future read-only historical-access authority, if Owner-accepted and legally authorized, must be distinct from `CV_ACTIVE`, must never permit sending, and must expose its own subject/audience, history scope, retention state, restriction state, revision, and freshness evidence. Until that authority exists, history access remains fail-closed.

Revocation, `CN_PAUSED`, and `CN_CLOSED` remove the prerequisites for live Conversation. They do not become local deletion events, peer-visibility decisions, Safety findings, or Relationship outcomes.

### Privacy Control Center

The Privacy Control Center should eventually represent only capabilities whose backend and legal authority are established. It must:

- label `Hide from my view`, access/copy, portability/export, authored-content deletion request, account deletion request, messaging-consent revoke, optional-purpose revoke, and service retention separately;
- state scope, expected effect, peer effect, and whether an action is a request or completed outcome;
- show `NOT YET ESTABLISHED`, `REGION-SPECIFIC AUTHORITY REQUIRED`, or an equivalent fail-closed presentation instead of a fake control;
- preserve private Conversation as a distinct purpose area and prohibit unrelated Match/ranking/training use by default;
- avoid promising deletion from backups, peer-held views, legal/security records, or all systems unless the authoritative outcome covers that exact scope.

No UI or backend change is authorized by this candidate.

## 13. Technical-design blockers and non-blockers

### Blocks later Conversation data-rights technical design

1. Owner acceptance or revision of the product semantics in Sections 5–10.
2. Launch regions and material territorial/applicability facts.
3. Accountable entity and controller/processor/personal-information-handler role map.
4. Age/eligibility model and any minor-specific product posture.
5. Purpose-by-purpose legal-basis decision, including whether consent supports each optional purpose.
6. Per-class retention schedule and review/delete trigger for active content, closed history, account-exit data, and operational/security records.
7. Owner decision on default read-only history availability after revoke, pause, close, Block, and account exit.
8. Region-specific rules for access/copy, portability, deletion, objections/revocation, exceptions, verification, timelines, refusals, and appeals.
9. Safety/legal-hold boundaries that are specific, minimum-necessary, access-restricted, and not a blanket retention exception.

### Does not block acceptance of this semantic candidate

- endpoint, schema, table, archive format, service, queue, worker, job, migration, or storage implementation choices;
- Flutter presentation implementation;
- tooling/package-graph restoration;
- compatibility-debt removal;
- exact Match proposal expiry or optional signal allowlists;
- Phase 2 Explore/Relationship work;
- Sandbox/DEP13/B12/M2/M3 work.

Those items are downstream or out of scope, not reasons to invent a legal/product answer here.

## 14. Exact Owner decisions still required

Independent review does not make these Owner decisions. The Owner must explicitly accept, revise, or reject:

1. **D-01 — Semantic separation:** approve the distinct meanings of hide, mute, pause, close, block, report, export, deletion request, service erasure, and revoke.
2. **D-02 — Future authority effect:** approve immediate loss of live send authority when messaging consent is revoked or `CN_ACTIVE` is absent.
3. **D-03 — Historical-access posture:** choose whether read-only history is the default candidate after revoke/pause/close, or remains unavailable unless separately requested; either choice remains subject to region-specific authority.
4. **D-04 — Peer visibility posture:** choose when an authoritative deletion outcome may alter the other participant's view and what neutral presentation replaces removed content; no “delete for everyone” promise exists yet.
5. **D-05 — Export product scope:** choose whether the product offers a voluntary export beyond minimum legal access/portability rights, and approve the class-by-class inclusion/redaction posture.
6. **D-06 — Account-exit posture:** approve how account closure differs from a data deletion request and whether limited rights-request/history access remains available during closure handling.
7. **D-07 — Retention governance:** approve the requirement for per-class purpose, owner, trigger, review, and outcome before implementation; exact durations wait for material facts and legal authority.
8. **D-08 — Private-content purpose boundary:** affirm that private Conversation is unavailable for unrelated Match/ranking/training/advertising use by default.
9. **D-09 — Regional dispatch inputs:** establish launch-region, entity/role, age-model, hosting/transfer, and purpose inventory facts before commissioning jurisdiction-specific closure.
10. **D-10 — No fake capabilities:** affirm that Privacy Control Center controls remain unavailable/fail-closed until their backend and legal authorities exist.

Acceptance of D-01 through D-10 would close the common product-semantic layer only. It would not decide jurisdiction-specific legal compliance or authorize implementation.

## 15. Explicit non-goals

This candidate does not:

- provide legal advice, a legal opinion, or a complete jurisdictional survey;
- infer launch geography, applicable law, regulated role, age eligibility, legal basis, or production readiness;
- choose universal retention durations or legal/security exceptions;
- implement or specify backend/API/database/schema/service/export/deletion/retention/consent systems;
- modify Flutter/product source or create user-visible controls;
- inspect private participant, Profile, Conversation, report, finding, or Safety data;
- alter Match, Connection, Conversation, Relationship, Safety, Block, Report, or notification authority;
- authorize private Conversation for Match, ranking, Compatibility, public reputation, advertising, analytics enrichment, or training;
- acquire dependencies, restore tooling, run Flutter/Dart/Gradle, remove compatibility debt, start Phase 2, or resume Sandbox/DEP13/B12/M2/M3;
- decide exact Match expiry or optional AI/personality/astrology/reference-signal allowlists;
- merge, self-accept, or create successor authority.

## 16. Recommended bounded follow-up

Only after fresh independent review and explicit Owner acceptance/revision of this candidate:

1. record the Owner decisions D-01 through D-10 in a separate accepted decision artifact;
2. dispatch a bounded launch-material-facts task to establish regions, accountable entity/roles, age model, purpose inventory, and hosting/transfer facts without implementation;
3. dispatch region-specific qualified legal/data-rights reviews, each with exact jurisdiction and material facts;
4. consolidate accepted global product semantics with jurisdiction-specific constraints into a rights/retention authority contract;
5. independently review that consolidated contract before any technical design;
6. only then propose bounded implementation-planning tasks for B01-D history authority and Privacy Control Center capability evidence;
7. preserve Track 3 tooling restoration as a separate subsequent task under Owner dispatch.

Every step requires its own authorization. This sequence does not authorize code, dependencies, product UI, private-data inspection, or Track 3.

## 17. Completion and stop boundary

This candidate can be reviewed through exact document/source checks, URL reachability, single-path Git scope, and `git diff --check`. Product tests and toolchain evidence are neither relevant nor authorized.

Completion classification:

`CONVERSATION DATA-RIGHTS DECISION CANDIDATE ESTABLISHED — PRODUCT/LEGAL/REGION-SPECIFIC BOUNDARIES EXPLICIT — NO IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW / OWNER DECISIONS`

Publication is the terminal action. This candidate is not accepted legal advice, does not establish production legal readiness, does not authorize Track 3, and does not begin implementation.
