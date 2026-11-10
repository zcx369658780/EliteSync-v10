# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Host Wrapper Reconstruction Acceptance｜v0.1

Status: `ACCEPTED — PROSPECTIVE ARGV/QUOTING CONTRACT ESTABLISHED — OWNER-PREAUTHORIZED B CONTROLLED SHARE EXPERIMENT MAY BE PUBLISHED — NO DEP13 AUTHORITY`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Independent acceptance authority

Acceptance-base `main`:

`250e89ffd8d314422f3bc436f711fe49a0a423d2`

Accepted C candidate:

- branch: `review/h01-bib03-u15-td01-m3-post-r7-host-wrapper-reconstruction-v0-1`
- commit: `43041b00c8bfc7983ed698e293933f89b9e9d936`
- sole parent: `250e89ffd8d314422f3bc436f711fe49a0a423d2`
- tree: `32ade6d13a41f27998f7b6347e72940c96b7e4fc`
- wrapper path: `tools/recovery/Invoke-EliteSyncWsbShare.ps1`
- wrapper blob: `b3a751e18d713c98b56d66972d501292544a847f`
- wrapper SHA-256: `2776034B4BD42FA5D25EB2997B59EDEE5AEFF3668C567788BBCB3CF222A3BE64`
- result path: `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_HOST_WRAPPER_RECONSTRUCTION_RESULT_V0_1.md`
- result blob: `56ce487b5334b368df969bd39f8742bbb32b326e`
- result SHA-256: `04511DBD6D0C4EB2B7D7D4D9EBD458FB838308614E6EA93697209FB553F77230`

FIRST handoff remains:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

## 2. Acceptance findings

The C candidate is accepted as a valid bounded host-wrapper reconstruction.

The wrapper establishes a prospective, auditable process-launch contract:

- default mode is `DRY_RUN_ONLY`;
- argument construction uses discrete string tokens;
- future operational launch uses `System.Diagnostics.ProcessStartInfo.ArgumentList.Add` with `UseShellExecute=false`;
- executable path is assigned separately through `FileName`;
- no opaque shell command string, `Invoke-Expression`, `Start-Process`, or `ProcessStartInfo.Arguments` is used;
- caller-supplied host/sandbox path text is not slash-normalized, canonicalized, case-changed, trimmed, or silently rewritten;
- `SandboxPath` omission is distinguishable from a supplied value and omits the `--sandbox-path` option entirely;
- deterministic JSON receipt generation was verified in dry-run mode;
- operational mode is guarded by explicit mode selection, explicit activation token, process-scoped matching activation-token environment value, pre-existing evidence directory, exact executable existence, and evidence-file non-overwrite gates.

The dry-run evidence establishes the historical failed token set can be serialized deterministically without invoking `wsb.exe`; it also establishes the future B-shaped argv interface with `SandboxPath` omitted.

## 3. Accepted classification

Accepted C classification:

`HOST WRAPPER RECONSTRUCTED — PROSPECTIVE ARGV/QUOTING CONTRACT ESTABLISHED`

Historical wrapper behavior remains unknown and is not retroactively reconstructed.

Prospective wrapper ambiguity is closed for future separately authorized use.

## 4. Preserved immutable state

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Current rebound/quarantined Sandbox ID:

`7ebc163d-7e92-4a63-8218-47c03d5db697`

Preserved continuation namespace:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`

It remains immutable historical evidence and must not be cleared, reused, renamed, overwritten, repaired, repurposed, or used as the B experiment evidence namespace.

## 5. Negative acceptance findings

C performed no operational `wsb` execution, no runtime Sandbox observation, no guest access, no share retry, no B namespace creation, no DEP13, dependency acquisition, Gradle/M3/AAR/M2, Android Studio/emulator use, README/FD02 read, broad enumeration, or protected-index inspection.

The wrapper's existence alone creates no operational authority.

## 6. B publication authority

The Owner explicitly pre-authorized Option B after valid independent acceptance of C.

Therefore, absent a new contradiction, a separate B task may now be published automatically for exactly one bounded writable `wsb share` experiment.

The B experiment must:

1. fresh-bind current `main` and the accepted C wrapper blob;
2. perform a bounded runtime identity gate and require exactly one running Sandbox matching `7ebc163d-7e92-4a63-8218-47c03d5db697`;
3. establish a brand-new task-owned host evidence namespace outside the repository and distinct from every historical continuation namespace;
4. use the accepted installed `wsb.exe` identity and accepted C wrapper;
5. use writable mode;
6. omit `SandboxPath` so the installed CLI/native layer selects its default destination;
7. execute exactly one operational `wsb share` attempt;
8. capture the prospective wrapper argv receipt, stdout, stderr, exit code, and result metadata;
9. STOP immediately after that one share result;
10. perform no guest access, no `wsb exec`, no materialization, no DEP13, and no automatic downstream progression.

Success of the single share does not itself establish fixed-guest recovery completion and does not authorize DEP13.

Failure of the single share must also stop without a second experiment.

## 7. Android Studio emulator route preservation

The Owner's standing permission to use the local Android Studio emulator for later testing/development remains recorded.

It is not part of B. If B fails or the Sandbox route remains impractical after independent B acceptance, a later bounded route-decision task may explicitly separate:

- Sandbox-specific evidence obligations that remain unresolved; and
- Android/Flutter testing/development that can continue safely on the local emulator.

The emulator must not silently substitute for Sandbox-specific DEP13 evidence.

## 8. Durable boundaries

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

DEP13 remains blocked until fixed-guest recovery continuation actually succeeds and is independently accepted.

## 9. Acceptance result

`ACCEPT — C WRAPPER RECONSTRUCTION VALID — PROSPECTIVE PROCESS-LAUNCH AMBIGUITY CLOSED — PUBLISH OWNER-PREAUTHORIZED ONE-SHOT B CONTROLLED SHARE EXPERIMENT — NO DEP13 AUTHORITY`
