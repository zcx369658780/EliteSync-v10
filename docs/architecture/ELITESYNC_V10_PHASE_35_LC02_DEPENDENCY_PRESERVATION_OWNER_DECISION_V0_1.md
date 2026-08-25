# EliteSync-v10 Phase 35 LC-02 Dependency Preservation Owner Decision V0.1

Status: `OWNER OPTION C ACCEPTED — ONE BOUNDED LC-02 CALL AUTHORIZED — NO LEGAL OR IMPLEMENTATION AUTHORITY`

Repository recording date: `2026-08-25`

## 1. Scope

This document records the Owner's bounded decision for the remaining Phase 35 LC-02 research-quality blocker. It is not substantive legal analysis, a formal legal opinion, a compliance conclusion, an UNKNOWN disposition, product implementation planning, or authorization for LC-03, LC-04, or Phase 36.

## 2. Owner decision

The Owner accepts recovery option C:

```text
MODEL PROPOSITION STRUCTURE
+
DETERMINISTIC POST-RESPONSE DEPENDENCY VALIDATION
```

Reason: the remaining blocker is proposition-level preservation of material statutory dependencies already recorded in the unchanged LC-02 dossier.

The required recovery mechanism is:

1. every material proposition uses a discrete structure containing a `Dependency / Exception` field;
2. Codex normalizes only the nine dependencies already recorded in the dossier manifest;
3. after the model response, Codex deterministically checks every cited source/article pair against that normalized map;
4. every required dependency must appear explicitly in the `Dependency / Exception` field and qualify the `Legal Anchor Proposition` itself;
5. a failed proposition is not repaired by Codex and causes fail-closed rejection.

This is a research-quality contract only. It creates no substantive legal conclusion and no product authority.

## 3. Authorization

Exactly one additional bounded LC-02 DeepSeek call is authorized after all preflight gates pass.

- Model: `deepseek-v4-pro`
- Reasoning: `high`
- Request timeout: 600 seconds per API request
- Maximum turns: 12
- Retry: none
- Fallback: none
- Second model call: not authorized

The existing three-file LC-02 dossier remains the sole bounded research package. It must not be modified, broadened, regenerated, or replaced.

## 4. Preserved contracts

The already-demonstrated closed two-layer classification contract remains unchanged. The current helper and `search_text` path contracts remain unchanged. No helper redesign, quota increase, turn increase, model change, whole-law ingestion, broader corpus, new secondary sources, or general helper capability is authorized.

Required helper HEAD:

`774b47abb946da8683cbd9893426ffa174ee06c4`

The accepted issue-specific packaging rule remains:

`LONG LEGAL TEXTS SHOULD DEFAULT TO ISSUE-SPECIFIC, PROVENANCE-PRESERVING EXTRACT PACKAGES RATHER THAN WHOLE-LAW SINGLE-CALL INPUTS.`

## 5. Dependency contract boundary

The execution-time dependency map must be derived mechanically from the dossier's nine-record manifest and must distinguish:

- explicit numbered cross-references;
- a generic unnumbered retention dependency for Article 47 that the dossier says cannot be closed without inventing a regime;
- self-contained exception or condition text in Articles 24 and 25.

No dependency may be invented. The nine manifest rows contain six citing articles with non-empty numbered dependency sets and three rows with no external numbered dependency: Article 47's generic unnumbered dependency and Articles 24/25's self-contained limitations. For numbered dependencies, each dependent source/article must be explicit in the proposition. Generic wording cannot substitute for a recorded numbered dependency. For the three empty numbered-dependency sets, deterministic dependency-field validation uses the no-recorded-dependent-reference sentinel; separate source/substantive checks must still preserve the dossier-recorded generic or self-contained limitation without manufacturing an external citation or self-dependency.

## 6. Governance boundary

- LC-01 remains `COMPLETE FOR CURRENT PRE-ALPHA PURPOSE`.
- LC-02 remains `UNRESOLVED` until a new artifact passes deterministic gates and later GPT L3/Owner review.
- LC-03 and LC-04 remain `NOT AUTHORIZED`.
- Phase 36 remains `NOT AUTHORIZED / NOT INFERRED`.
- U-01 through U-15 remain `BLOCKING`.
- OD-01 through OD-06 remain unchanged.
- ADR-001 through ADR-005 remain unchanged.
- Phase 11 remains unchanged.

No database/schema, API, Backend, Flutter, infrastructure, deployment, migration, production AI, Ranking, analytics, Safety Operations, retention/deletion, rights-request, consent, or other technical implementation is authorized.

No formal legal opinion, compliance conclusion, processing authority, guilt determination, or implementation authority is created by this decision record.

## 7. Stop boundary

If preflight or deterministic post-response validation fails, fail closed. Do not repair the response, retry, change model, expand the dossier, retain partial legal conclusions, or infer successor authority.

This decision authorizes one bounded LC-02 model call only. It does not authorize a second retry.
