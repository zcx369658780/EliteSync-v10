# EliteSync v10 H-01 BIB-03 Non-README Method-Selection Governance Review Task Sheet v0.1

## 1. Status and authority

Status:

`PROPOSED — GOVERNANCE METHOD-SELECTION REVIEW ONLY — ZERO READS/PROBES/SEARCH/ENUMERATION — NO METHOD EXECUTION`

Repository: `zcx369658780/EliteSync-v10`

Review branch:

`review/h01-bib03-non-readme-method-selection-governance-v0-1`

Exact live-main authority required:

`eccd54af2b9c67202d6b37ff10997cee1ea28244`

Accepted method-options artifact:

`docs/architecture/ELITESYNC_V10_H01_BIB03_NON_README_METHOD_OPTIONS_REVIEW_V0_1.md`

Required accepted artifact blob:

`cc3207cb131ddd0f164d755c88140f6f0a73f065`

Preserve audit note:

`POST-E3 PROMOTION PUSH-OPERATION COUNT = UNKNOWN / NOT INDEPENDENTLY VERIFIABLE`

## 2. Frozen option set

Selection may consider exactly and only:

1. `NR-METHOD-01 — Owner-supplied exact immutable source identity`
2. `NR-METHOD-02 — Owner-supplied exact non-README locator`
3. `NR-METHOD-03 — Single exact known non-README metadata-object probe`
4. `NR-METHOD-04 — Single exact authoritative external metadata endpoint probe`

Do not add, merge, split, rename, score, rank, recommend, prefer, or default an option.

## 3. Sole selection rule

Determine only which options are executable under already accepted durable state at the start of this gate.

An option is eligible only if every prerequisite already exists exactly and unambiguously before substantive review. This gate must not obtain missing prerequisites by asking for new Owner input, reading content, probing metadata, calling endpoints, searching, enumerating, inferring, reconstructing README-derived facts, or using external knowledge.

Selection rule:

- exactly `1` eligible option => Outcome A may select that option class only;
- `0` eligible options => EXPECTED OUTCOME B, fail closed;
- more than `1` eligible option => EXPECTED OUTCOME B, fail closed with no ranking or tie-break.

Do not use cost, convenience, speed, familiarity, plausibility, likelihood, or implementation preference as a selector.

## 4. Option eligibility tests

### NR-METHOD-01

Eligible only if one exact immutable Owner-supplied source identity, with all fields required for exact verification, is already accepted at gate start.

### NR-METHOD-02

Eligible only if one exact independent Owner-supplied non-README locator is already accepted at gate start.

### NR-METHOD-03

Eligible only if one exact accepted non-README metadata-object identity already exists at gate start. Runtime discovery is forbidden.

### NR-METHOD-04

Eligible only if one exact authoritative external metadata endpoint and exact query key are already accepted at gate start. Runtime discovery is forbidden.

## 5. Permanent boundaries

Preserve:

- accepted read ledger = exactly `12`
- unauthorized documentary/technical reads = exactly `1`
- remaining README/documentary content accesses = exactly `0`
- source-locator candidates emitted = `0`
- package-URI normalizations = `0`
- source identity candidates emitted / accepted = `0 / 0`
- bounded concrete identification basis instances = `0`
- source-target bindings = `0`
- U-12 concrete targets = `0`

`METHOD OPTIONS != METHOD EXECUTION`

`METHOD SELECTION != PROBE/READ AUTHORITY`

`E3 != README LOCATOR SELECTION AUTHORITY`

README content, README locator identities, incident exposure, and memory of the lawful README read remain excluded.

## 6. Explicit prohibitions

This gate performs zero:

- README/blob access or reconstruction;
- technical/config/source-content reads;
- metadata/network probes;
- repository/source/web search;
- repository-wide or directory-wide enumeration;
- source-path hypothesis creation;
- locator reconstruction/ranking/selection/normalization;
- source candidate emission/acceptance;
- basis-instance acceptance;
- source-target binding;
- source read/inspection;
- evidence collection;
- PUI reconsideration;
- technical design/implementation;
- LC-03/LC-04/Phase 36;
- FD02 access/search/hash/inspection/use.

Preserve exactly:

`NO REPOSITORY-WIDE OR DIRECTORY-WIDE FILE/PATH ENUMERATION IS AUTHORIZED.`

## 7. Higher-level frozen governance

Preserve all accepted ADRs, durable UNKNOWNs, legal/Safety boundaries, U-14 exclusion, U-12 exact-scope rules, D-02 unresolved state, `D02-DURABLE-UNKNOWN-01`, U-15 unresolved state, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database non-inspection, deferred PUI, PUI-PREREQ-12 = `0`, and technical design, implementation, LC-03, LC-04, Phase 36 as unauthorized.

## 8. Result artifact

For a non-blocked result create exactly:

`docs/architecture/ELITESYNC_V10_H01_BIB03_NON_README_METHOD_SELECTION_GOVERNANCE_REVIEW_V0_1.md`

### Outcome A

Use only when exactly one option satisfies all accepted prerequisites:

`NON-README SOURCE-IDENTIFICATION METHOD SELECTION = EXACTLY ONE CURRENTLY ELIGIBLE OPTION SELECTED BY PREDECLARED PREREQUISITE SATISFACTION ONLY — NO PROBE/READ/SEARCH/ENUMERATION — NO EXECUTION AUTHORITY CREATED`

The artifact must identify only the selected option class and explain which already-accepted prerequisites made it uniquely eligible. It must not create an execution task sheet.

### EXPECTED OUTCOME B

Use when zero or multiple options are eligible:

`EXPECTED OUTCOME B — NO UNIQUE NON-README METHOD SELECTABLE UNDER CURRENT DURABLE PREREQUISITES — FAIL CLOSED — NO RANKING OR TIE-BREAK`

### OPERATIONAL BLOCKED

`OPERATIONAL BLOCKED — NO NON-README METHOD-SELECTION GOVERNANCE DETERMINATION MADE`

## 9. Candidate accounting and publication

For any non-blocked candidate:

- candidate non-README method-selection gates executed = `1`
- accepted non-README method-selection gates = unchanged pending GPT L3 acceptance
- methods executed = `0`
- execution task sheets created = `0`
- reads/probes/search/enumeration = `0 / 0 / 0 / 0`

Commit exactly the one result artifact with message:

`docs: review H-01 BIB-03 non-README method selection`

Publish only to the same review branch by one non-force push if all publication prerequisites pass. Do not promote `main`.

Stop before execution-task authoring or any technical/source activity.