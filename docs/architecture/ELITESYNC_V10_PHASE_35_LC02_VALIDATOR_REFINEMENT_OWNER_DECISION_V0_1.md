# EliteSync-v10 Phase 35 LC-02 Validator Refinement Owner Decision V0.1

Status: `OWNER RETAINS OPTION C — REFINED VALIDATOR ACCEPTED — ONE BOUNDED LC-02 CALL CONDITIONALLY AUTHORIZED`

Repository recording date: `2026-08-26`

## 1. Decision scope

The Owner retains the Option C core mechanism:

```text
MODEL PROPOSITION STRUCTURE
+
DETERMINISTIC POST-RESPONSE VALIDATION
```

The Owner accepts the GPT L3 recommendation to validate legal-meaning relationships through machine-readable fields instead of exact natural-language strings or terminal punctuation.

This decision record creates no legal conclusion, formal legal opinion, compliance conclusion, processing authority, architecture acceptance, UNKNOWN disposition, or implementation authority.

## 2. Previous failure disposition

- The previous 15 fixed-sentence punctuation failures are classified for recovery purposes as `NON-SUBSTANTIVE VALIDATOR FALSE NEGATIVE`.
- Terminal punctuation is no longer a legal acceptance gate.
- `LC02-P-016` had the correct retained `Dependency / Exception` set, but its substantive free-text qualification status is `UNDETERMINED FROM RETAINED EVIDENCE`.
- The deleted model output was not inspected, reconstructed, recovered, or inferred.
- Historical failure classifications remain valid against the contracts in force when those executions occurred; this decision refines only the future contract.

## 3. Refined machine contract

Every material proposition must include a `Legal Anchor Qualification` field adjacent to its `Legal Anchor Proposition`. Together they form the complete legal-anchor representation; consumers must not discard the qualification field.

Allowed qualification token types are:

- `NONE`
- `NUMBERED_DEPENDENCY=<source/article reference>`
- `GENERIC_UNNUMBERED_LIMITATION=<citing source/article reference>`
- `SELF_CONTAINED_LIMITATION=<citing source/article reference>`

The validator normalizes tokens into sets. Token order, harmless surrounding whitespace, and a terminal English or Chinese full stop are not legally significant. Exact free-text qualification sentences and terminal punctuation are not acceptance gates.

Substantive dependency validation remains strict:

1. the dossier manifest's expected numbered dependency set;
2. the `Dependency / Exception` numbered set; and
3. the `Legal Anchor Qualification` `NUMBERED_DEPENDENCY` set

must be equal. Missing or invented dependencies fail. Dossier-recorded Article 47 generic and Article 24/25 self-contained limitations must use their corresponding structured tokens. No semantic guesswork may repair a machine-field mismatch.

For `NO DIRECT LEGAL ANCHOR IN SUPPLIED DOSSIER`, the Legal Anchor Proposition must be present and non-empty, but no fixed English sentence or terminal period is required. The closed legal-anchor and application classification enums remain unchanged.

## 4. Mandatory rehearsal and conditional call authority

The actual refined validator must pass the 17 specified synthetic fixtures with `0` unexpected outcomes before any model invocation.

Exactly one new bounded LC-02 DeepSeek call is authorized only after all repository, helper, dossier, nine-row dependency-map, Owner-record synchronization, and synthetic-rehearsal gates pass.

- Model: `deepseek-v4-pro`
- Reasoning: `high`
- Request timeout: 600 seconds per API request
- Maximum turns: 12
- Retry: none
- Fallback: none
- Repair call: none
- Second call under this authorization: not authorized

The unchanged three-file LC-02 dossier remains the sole input package. No dossier change, helper change, model change, quota increase, turn increase, whole-law ingestion, broader corpus, or new secondary source is authorized.

## 5. Preserved governance boundary

- LC-01 remains `COMPLETE FOR CURRENT PRE-ALPHA PURPOSE`.
- LC-02 remains `UNRESOLVED` pending deterministic validation, GPT L3 substantive critique, and Owner acceptance.
- U-01 through U-15 remain `BLOCKING`.
- OD-01 through OD-06, ADR-001 through ADR-005, and Phase 11 remain unchanged.
- LC-03 and LC-04 remain `NOT AUTHORIZED`.
- Phase 36 remains `NOT AUTHORIZED / NOT INFERRED`.
- No database/schema, API, Backend, Flutter, infrastructure, deployment, migration, production AI, Safety Operations, retention/deletion, rights-request, consent, Ranking, analytics, or other product implementation is authorized.

If rehearsal or post-response validation fails, fail closed. Do not repair, retry, salvage partial conclusions, expand scope, or infer successor authority.
