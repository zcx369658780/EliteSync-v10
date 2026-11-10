# EliteSync v10｜IP-13I-R6-R1 Corrected Candidate Independent Review｜v0.1

Status: `REJECTED — PROVENANCE-LEDGER WORDING/READ-SCOPE CONTRADICTION — R6 SEMANTIC CONTRACT PRESERVED — SECOND CORRECTION-ONLY RERUN REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh review base / current `origin/main`: `4bd5d7e09b9e4c0e34196281dedc891612f3d3db`

Reviewed branch: `review/next-ip-13i-r6-r1-evidence-ledger-correction-v0-1`

Reviewed candidate: `79c6b1f788cd4d8f0eb825f915ade41b71f56ba5`

Candidate sole parent: `4bd5d7e09b9e4c0e34196281dedc891612f3d3db`

Corrected result blob: `733318a00cff9d093f33da7196accd90e8e6912c`

## 1. Independent verification passed

The candidate topology is correct:

- exactly one commit ahead of the R6-R1 task-publication base;
- merge base equals `4bd5d7e09b9e4c0e34196281dedc891612f3d3db`;
- exactly one tracked path is added;
- the path is the authorized corrected R6 result document.

The intended correction identities are correct:

- original R6 task blob:
  `e62bf3d99d5c88af877f50f70241defae24140a8`
- R6-R1 correction task blob:
  `1adc024d88e1118b3aa5f1c4595f644977d50d26`
- prior independent rejection blob:
  `ed8f808f78d2177d1e35ada3483b7374022d61c1`

Programmatic semantic comparison also established:

- Section 1 is byte-for-byte unchanged from the rejected R6 result;
- Sections 3 through 15 are byte-for-byte unchanged from the rejected R6 result;
- the substantive R6 decision remains `A. DEDICATED_ENDPOINT_CONTRACT_SOUND`;
- no endpoint/request/response/HTTP/privacy/IP-13F/future-test/future-write-scope semantic change is present.

The five accepted R5 blobs remain the expected identities.

## 2. Rejection reason

The corrected candidate contains an internal provenance contradiction.

Section 16 states:

`This correction-only rerun ... read only the R6-R1-authorized exact paths`

The R6-R1 task's exact read scope does not authorize directly rereading all original IP-13E/IP-13F/IP-13H/current-session fixed inputs.

However, Section 2 labels the full carried-forward original ledger as:

`Exact input read`

and lists those old IP-13E/IP-13F/IP-13H/current-session paths as if they were directly read again during R6-R1.

Both claims cannot simultaneously be true.

This is a provenance/evidence-record defect, not a semantic-contract defect.

The original R6 evidence for those inherited inputs was already independently cross-checked in the prior rejection review. R6-R1 did not need to reopen those files. The corrected result should distinguish:

1. inputs directly read during the R6-R1 correction; and
2. original R6 fixed-input identities carried forward from the rejected R6 artifact and independently verified by the prior review.

## 3. Required correction

A second correction-only task may modify only the publication/provenance portions of the R6 result.

The next corrected result must:

- keep Section 1 and Sections 3–15 byte-for-byte unchanged;
- keep all substantive semantic conclusions unchanged;
- retain the corrected original R6 task blob;
- retain the R6-R1 task blob and prior rejection blob;
- replace the ambiguous Section 2 `Exact input read` presentation with two explicit provenance groups:
  - `Directly read in this correction rerun`;
  - `Carried-forward original R6 fixed-input ledger, previously independently verified`;
- state explicitly that carried-forward entries were not reopened merely to restate them;
- keep Section 16 consistent with the exact authorized read scope;
- update only the new correction-task/review metadata necessarily introduced by the second correction.

No code/runtime/semantic work is authorized.

## 4. Integration disposition

The corrected candidate `79c6b1f788cd4d8f0eb825f915ade41b71f56ba5` is not authorized for integration.

The rejected R6 candidate `b80c6ea9f9a920bcf489afbbf05ebebae86c9faa` also remains rejected and unmerged.

Final classification:

`IP-13I-R6-R1 CANDIDATE REJECTED — CORRECTED OBJECT IDENTITIES AND R6 SEMANTICS VERIFIED — ONE REMAINING PROVENANCE-LEDGER CONTRADICTION BETWEEN EXACT READ SCOPE AND “EXACT INPUT READ” LABELING — NO SEMANTIC CONTRACT REJECTION — SECOND CORRECTION-ONLY R6-R2 REQUIRED`
