# EliteSync-v10 Phase 35 Track C Legal Research Packaging Rule and Helper Output Contract V0.1

Status: `ACCEPTED OWNER DECISION — HELPER OUTPUT CONTRACT REPAIR COMPLETE`

Repository recording date: `2026-08-25`

## 1. Scope

This record durably captures the Owner-approved Track C legal-source packaging rule and the bounded helper output-contract repair performed within Phase 35.

This is not Phase 35A or Phase 36. It is not substantive legal analysis, a formal legal opinion, a compliance conclusion, an UNKNOWN disposition, a product-architecture decision, or implementation authority.

`DEEPSEEK CALLS: 0`

`NO PARTIAL LEGAL RESPONSE INSPECTED, RECOVERED, RECONSTRUCTED, OR REUSED`

## 2. Owner decisions

The Owner authorized:

`PHASE_35_MINIMAL_OUTPUT_CONTRACT_REPAIR — AUTHORIZED`

The Owner accepted the following durable Track C research-packaging principle:

`LONG LEGAL TEXTS SHOULD DEFAULT TO ISSUE-SPECIFIC, PROVENANCE-PRESERVING EXTRACT PACKAGES RATHER THAN WHOLE-LAW SINGLE-CALL INPUTS.`

This principle governs research input preparation. It does not permit omission of material authority, arbitrary truncation, removal of provenance, promotion of AI interpretation over official text, or reuse of one issue-specific package for a materially different legal question without fresh source review.

## 3. Packaging rule

For bounded Track C AI-assisted legal research preparation:

1. Start from the specific issue cluster and known product facts rather than a whole-law corpus.
2. Use current official primary sources as the evidence authority.
3. Retain exact source identity, issuer/type, effective and amendment status, official locator, access date, article number, verbatim bounded text, and local-source hash where a local copy is created.
4. Include only provisions materially connected to the issue, with neighboring text only when required to preserve the provision's context.
5. Keep official text, official explanation, AI interpretation, AI inference, and legal uncertainty visibly distinct.
6. Preserve traceability to the repository authority and official source; compression may reduce navigation burden but must not destroy provenance.
7. If the necessary material cannot fit safely within the active output/input contract, segment the research by issue and preserve a cross-package manifest. Do not silently truncate or weaken the evidence set.
8. A segmented package remains preparation-only. It creates no legal conclusion, compliance acceptance, data-processing authority, technical design authority, or implementation authority.

## 4. Established write-quota diagnosis

The deterministic local diagnosis established:

| Classification | State | Record |
| --- | --- | --- |
| WQ-A — safe quota too small | `NOT ESTABLISHED` | No quota increase was justified or authorized. |
| WQ-B — model-facing quota contract unclear | `CONFIRMED` | The prior system prompt and tool schema did not disclose the byte budgets or full-file rewrite accounting. |
| WQ-C — inefficient repeated full-document rewriting | `HIGHLY LIKELY` | One full write followed by repeated whole-document replacements was consistent with cumulative-budget exhaustion; deleted legal content was not inspected. |

Existing runtime values remain unchanged:

- maximum resulting file size: `300,000 UTF-8 bytes`;
- task-wide cumulative successful-write budget: `500,000 UTF-8 bytes`;
- total read budget: `1,000,000 bytes`;
- per-file read limit: `300,000 bytes`;
- file-read count: `100`;
- max turns: `12`;
- request timeout: `600 seconds`;
- API response-byte limit: `4,000,000 bytes`;
- model token limit: not defined by the helper.

`write_file` charges the complete resulting UTF-8 file size. `replace_text` also charges the complete resulting updated file size rather than only the replacement fragment. There is no append tool. The cumulative budget is shared across turns. An over-quota operation is rejected before disk mutation, creates no partial output, and consumes no additional budget. Successful writes retain temporary-file plus atomic-replace behavior.

## 5. Minimal helper repair

Helper repository baseline:

`be11598254cef82a55145c00e5ebc2870fd94d0c`

Repaired helper commit:

`dca66a9087ada5cfb122bad2357cd6b76ab0e3a5`

The repair changed only:

- `deepseek_file_worker.py` — model-facing system instruction and write-tool descriptions;
- `test_deepseek_file_worker.py` — exact boundary, cumulative-rewrite, model-contract, and schema-contract tests;
- `README.md` — durable output-contract documentation;
- `INSTALL_LOCK.json` — source/test hashes, test count, and recording timestamp.

The system instruction now communicates the effective task limits, full-result accounting for `write_file` and `replace_text`, cumulative-budget exhaustion risk, absence of append, one-final-write guidance for long reports, and segmentation behavior when an artifact cannot fit safely.

The repair did not change quota values, add append support, alter the model, reasoning effort, timeout, max turns, API path, retry behavior, sandbox/path controls, or authentication handling.

## 6. Deterministic validation

- DeepSeek or other model calls: `0`.
- Local unit tests: `60 passed`, `1 skipped` because Windows symlink privilege was unavailable.
- Python compilation: `PASS`.
- Source hash lock: `PASS`.
- Test hash lock: `PASS`.
- Exact single-file boundary: 300,000 bytes `PASS`; 300,001 bytes `BLOCKED` before mutation.
- Exact cumulative boundary: 500,000 bytes `PASS`; additional byte `BLOCKED` before mutation.
- Full-document rewrite accounting: `PASS`.
- Model-facing contract includes effective byte limits and long-report strategy: `PASS`.
- Tool schemas state full-result accounting and absence of append: `PASS`.

No API/model smoke test was run or authorized by this task.

## 7. Governance preservation and stop

- U-01 through U-15: unchanged and `BLOCKING`.
- OD-01 through OD-06: unchanged.
- ADR-001 through ADR-005: unchanged.
- Phase 11 gates: unchanged.
- No legal analysis, official compliance conclusion, data-processing authorization, consent implementation, Safety retention, analytics, model training, Ranking, deployment, technical design, or product code was authorized or performed.
- No Phase 35 substantive retry was authorized or consumed.
- No Phase 36 authority was created or inferred.

Stop after the helper contract repair and durable packaging-rule recording. Any further substantive Phase 35 legal-AI call requires separate explicit Owner authorization.
