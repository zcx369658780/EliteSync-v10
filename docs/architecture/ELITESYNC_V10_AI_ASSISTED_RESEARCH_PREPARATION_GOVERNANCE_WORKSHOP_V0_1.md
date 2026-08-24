# EliteSync 10.0 AI-Assisted Research Preparation Governance Workshop V0.1

Status: PROPOSED — AWAITING GPT L3 AND OWNER REVIEW

Date: 2026-08-24

Authority snapshot: GitHub `main` at `c8c69d808e61167233e7d1f9625abef123491d81` before this documentation workshop.

Scope: Define governance rules for AI-assisted research preparation. This workshop does not execute specialist review, contact any external party, collect or process data, create technical design, or authorize implementation.

## 0. Governing principles

- AI/tool output is not specialist authority.
- AI/tool output is not evidence by default.
- AI/tool output cannot replace Owner, privacy/legal, Safety/moderation, research-methodology, institutional, or other qualified human authority.
- Fluency, citations, agreement among tools, repeated generation, or human preference does not convert AI output into evidence or authority.
- Every AI-assisted artifact retains its classification, provenance, limitations, and verification state through later use.

This document and any AI/tool contribution to it are classified as `AI-assisted research preparation`.

## 1. Allowed AI-assisted activities

Within an explicitly authorized documentation or research-preparation scope, AI tools may assist with:

1. **Question refinement:** clarify wording, separate assumptions, identify ambiguities, propose non-leading questions, and map questions to known UNKNOWN items without answering or disposing them.
2. **Evidence organization:** organize Owner-supplied or independently verified source metadata, build claim/source maps, identify missing fields, group conflicting material, and prepare provenance checklists.
3. **Source summarization:** draft a traceable summary of an identified source while preserving exact locators, uncertainty, conflicts, and the distinction between source text and AI interpretation.
4. **Research planning support:** outline non-executed methods, alternatives, validity risks, evidence needs, stop conditions, confidentiality considerations, and future human-review questions.
5. **Document preparation:** draft, format, compare, consistency-check, and validate bounded workshop records, evidence templates, review templates, and handoffs.

Allowed assistance remains preparation. It does not authorize source acquisition, external disclosure, specialist execution, participant research, data activity, or downstream decision changes.

## 2. Forbidden AI substitution

AI tools must not be represented or used as:

- legal advice, a legal opinion, licensed counsel, jurisdiction selection, or a compliance declaration;
- a Safety/moderation decision-maker, case reviewer, guilt assessor, emergency handler, person-level risk scorer, or operational authority;
- a qualified specialist, specialist identity, specialist credential, specialist authority, or `Specialist Review Record` author;
- an Owner decision, inferred Owner intent, acceptance, rejection, deferral, authorization, or disposition;
- evidence certification, source authenticity certification, provenance authority, peer review, independent review, or factual guarantee;
- participant evidence, user research, data analysis, model result, experiment result, metric approval, or signal approval;
- product, architecture, Database, API, Backend, Flutter, Implementation Planning, code, migration, infrastructure, deployment, or production authority.

No prompt, persona, system message, multi-model consensus, confidence score, model label, or vendor claim can waive these prohibitions.

## 3. Output classification model

| Class | Definition | Required provenance | Authority and permitted effect |
| --- | --- | --- | --- |
| `AI-assisted preparation` | AI/tool-generated question refinement, organization, summarization, planning support, drafting, or validation aid | AI preparation record in Section 4, linked sources, human reviewer, limitations, and verification state | No authority; not evidence by default; cannot resolve an UNKNOWN or change OD, ADR, Phase 11, design, or implementation state |
| `Source evidence` | A human-accessible source independently identified, provenance-checked, and assessed for applicability | Issuer/author, title, exact locator, version/effective/publication date, checked date, scope, applicability, corrections/conflicts, limitations, and claim mapping | May support analysis within its scope; is not a specialist finding or Owner decision |
| `Specialist finding` | A bounded conclusion or interpretation authored by a named, qualified, Owner-authorized specialist within an approved scope and corpus | Complete `Specialist Review Record`, reviewer qualification/authority/conflicts, evidence corpus, reasoning, limitations, unresolved questions, and expiry | Advisory and evidence-bounded; may inform later Owner review; never changes project state automatically |
| `Owner decision` | An explicit Owner record deciding an exact question after considering applicable evidence, review, and limitations | Decision ID, Owner wording, date, scope, outcome, rationale, linked evidence/reviews, limitations, expiry/stop condition, and downstream impact | Sole product/architecture decision authority within the exact recorded scope; omitted matters remain unchanged |

### 3.1 Classification and promotion rules

- Classification follows origin and authority, not writing quality or file location.
- AI output may identify candidate sources, but the candidate and every material claim must be independently checked against the actual source before it can be cited as source evidence.
- An AI summary remains `AI-assisted preparation` even after its underlying source is verified. The verified source, not the summary, is the evidence.
- Source evidence does not become a specialist finding without a separately authorized, named, qualified reviewer and complete `Specialist Review Record`.
- A specialist finding does not become an Owner decision. Only explicit Owner wording creates an Owner decision.
- GPT L3 review is an independent review gate, not Owner authority, specialist authority, or source evidence.
- Promotion is never automatic, transitive, retroactive, or based on silence, completeness, consensus, recommendation, or confidence.
- Each transformation must retain the original item, original class, tool/human actor, date, source links, changes, verification, and limitations.
- Missing provenance, unverifiable authority, unsupported claims, scope drift, conflicts, stale/expired material, inaccessible sources, or failed human verification require `NOT VERIFIED` and stop promotion.

## 4. AI-assisted preparation record requirements

Every material AI-assisted contribution retained in a project artifact must have a proportionate record containing:

```text
Preparation record ID:
Artifact/path and section:
Tool identity and provider:
Model name and disclosed version/build:
Execution date/time and environment:
Purpose and authorized task scope:
Prompt/instruction summary or exact prompt where safe:
Context supplied and explicit exclusions:
Source inputs and locators:
Output used and transformations made:
Output locator/version/hash when available:
Human reviewer identity/role:
Human review date, scope, criteria, and conclusion:
Human review performed:
Verification status: NOT VERIFIED | PARTIALLY VERIFIED | VERIFIED AGAINST NAMED SOURCES
Verification method and checked locators:
Known limitations, uncertainty, conflicts, and omissions:
Confidentiality/data classification check:
Stop/escalation events:
```

### 4.1 Tool and model identity

Record the actual tool/product and provider plus the model/version displayed or otherwise available at execution time. If the exact model or build is unavailable, record `UNKNOWN — NOT DISCLOSED`; never infer it. Record material configuration only when known and safe to retain.

### 4.2 Prompt and context

Retain enough prompt/instruction and context information to explain the purpose, constraints, supplied sources, and expected output. Do not record secrets, credentials, personal/sensitive/private-interaction/Safety data, confidential content, or prohibited external material. If safe prompt retention is impossible, record a bounded summary and the omission reason.

### 4.3 Human reviewer

Name or role-identify the accountable human reviewer and what they checked. An AI tool cannot be its own human reviewer. Human review does not by itself convert preparation into source evidence, specialist finding, independent GPT L3 acceptance, or Owner decision.

### 4.4 Verification

- Verify material factual claims against the actual named source and exact locator.
- Check source identity, version/date, applicability, corrections/retractions, conflicts, and transfer limits.
- Compare quotations and numbers exactly; never rely on model recall.
- Label unsupported, inaccessible, ambiguous, or stale claims `NOT VERIFIED` and exclude them from decision support.
- Preserve contrary, negative, null, and decision-reversing evidence.
- Re-verify when the source, model, task scope, applicable jurisdiction/population, or material project context changes.

### 4.5 Limitations

Record hallucination risk, omission risk, summarization loss, context truncation, source-access limitations, model/version uncertainty, bias, non-determinism, dynamic retrieval, tool updates, non-replayable dependencies, privacy/confidentiality limits, and any domain competence the tool does not possess. If exact reproduction is unavailable, record `NOT FULLY REPRODUCIBLE` and its impact. A generic disclaimer is insufficient when a material limitation is known.

## 5. OpenCode, DeepSeek, and ChatGPT boundary

The same governance applies to OpenCode, DeepSeek, ChatGPT, Codex, and any other AI-enabled coding, search, writing, analysis, or orchestration tool.

### 5.1 Allowed use

- Perform the Section 1 activities within the exact authorized task and allowed files.
- Inspect public or Owner-supplied non-confidential sources when that source access is separately authorized.
- Produce clearly labeled preparation drafts, source maps, question lists, templates, consistency checks, and verification checklists.
- Report tool identity, model/version when disclosed, prompt/context boundary, human review, limitations, and verification state.

### 5.2 Forbidden use

- Do not use a model persona or delegated agent as privacy/legal, Safety/moderation, research-methodology, fairness, accessibility, operations, user-research, or other specialist authority.
- Do not ask one model to certify, independently validate, or authorize another model's output as specialist evidence.
- Do not treat cross-model agreement as evidence, independent specialist review, GPT L3 acceptance, or Owner decision.
- Do not use tools to search for, identify, profile, contact, engage, hire, or commission specialists without separate exact authorization.
- Do not use tools for external contact, participant recruitment, interviews, surveys, observation, testing, recording, data collection, restricted/private-data access, sensitive-data processing, or production access.
- Do not use tools to execute legal review, Safety review, methodology review, specialist findings, technical design, implementation planning, or code under Phase 20B.

### 5.3 Tool-specific notes

- **OpenCode:** Coding capability does not create implementation authority. In Phase 20B it may assist only with bounded document preparation and validation; no source-code or technical-design work is authorized.
- **DeepSeek:** If a later task separately authorizes invocation, the only formal path is `C:\Users\zcxve\.codex\helpers\Invoke-DeepSeekFileTask.ps1`. DeepSeek MCP delegate and MCP ping are not approved specialist, evidence, authority, or startup-gate paths. The CLI remains a tool transport only; its output is `AI-assisted preparation`, never specialist authority or evidence by default. Phase 20B does not authorize invoking it.
- **ChatGPT/Codex:** Architecture/product review or orchestration roles do not substitute for Owner or specialist authority. Generated governance prose remains proposed preparation until the required review and Owner outcome.

Tool brand, plan tier, model size, reasoning mode, browsing, connectors, plugins, or agent delegation do not change classification or authority.

## 6. Confidentiality and data boundary

- Use only public or Owner-approved non-confidential conceptual inputs within the authorized purpose.
- Apply data minimization: provide no context that is unnecessary for the preparation task.
- Never submit secrets, credentials, personal data, sensitive data, private-interaction content, Safety data, participant data, case material, production data, or repository-private/confidential material to an AI/tool unless a later exact authorization and applicable governance explicitly permit it.
- External upload, retention, training use, logging, connector access, workspace sharing, and onward disclosure must be treated as data processing; unknown terms or destinations require stopping.
- Do not infer that local execution, enterprise branding, a privacy toggle, or vendor assurance establishes confidentiality or legal authority.

## 7. Downstream consistency state

| Area | Phase 20B result |
| --- | --- |
| AI/tool output | `AI-assisted research preparation`; not authority or evidence by default |
| Source evidence | Requires independent provenance and applicability verification |
| Specialist findings | Require named qualified authorized specialist and complete record |
| Owner decisions | Require explicit Owner wording |
| Specialist execution/external contact | `NOT AUTHORIZED` and not performed |
| Participant/data activity | `NOT AUTHORIZED` and not performed |
| U-01 through U-15 | Remain `BLOCKING` |
| OD-01 through OD-06 | No change |
| ADR-001 through ADR-005 | No change |
| Phase 11 gates | No change |
| Database/API/Backend/Flutter Design | `NOT AUTHORIZED` |
| Implementation Planning/Implementation/code | `NOT AUTHORIZED` |

No new ADR, specialist finding, evidence certification, Owner disposition, or execution authority is created by this workshop.

## 8. Validation and stop

Validation must confirm:

- all five allowed AI-assisted activities are defined;
- legal advice, Safety decisions, specialist findings, Owner decisions, evidence certification, and compliance claims are prohibited substitutions;
- the four output classes remain distinct and promotion requires exact provenance and human verification;
- the preparation record covers tool identity, model/version, prompt/context, purpose, human reviewer, limitations, and verification;
- OpenCode, DeepSeek, ChatGPT, Codex, and other AI tools remain governed as preparation tools only;
- AI was not treated as authority or as an evidence source by default;
- no specialist review, external contact, participant activity, data collection/access/processing, production access, technical design, implementation planning, or code occurred;
- no UNKNOWN, OD, ADR, or Phase 11 gate changed.

Stop after documentation completion. Wait for GPT L3 independent review and explicit Owner review before treating this governance proposal as accepted.
