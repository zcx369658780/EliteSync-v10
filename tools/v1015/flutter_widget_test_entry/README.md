# v10.1.5 private Flutter test entry (nonproduction)

This is reviewable tool source, not a production SDK change. Default invocation reads
the bundled locks and prints `DRY_RUN_ONLY / EXECUTE_DISABLED`; it creates no tool
output and launches no process. Python standard library only; use a trusted Python
with `-I -B`. Run the script by its explicit local path, never through shell aliases.

## Current capability and blocker

`INSPECT_ONLY_OR_PATCH_INPUT_REQUIRED / STATIC_OR_PURE_SELFTEST_ONLY`.
Owner erratum Git Blob `a0eec472b58d53bc25084a395efc0748779d73f8` supersedes
**only the original Hook source SHA256 field** of historical task
`0854b37fdc9f11c55088ed2d2f93816a27bc2fa9`:
`SUPERSEDED_BY_OWNER_ERRATUM_FOR_HOOK_SOURCE_SHA256_ONLY`.
The old 62-character value remains rejected and retained in immutable history:
`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d08c393dad9`.
The corrected 64-character reference in `hook_original_sha256` is:
`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d4d08c393dad9`.
It agrees with 5aa3 evidence index Blob `657deb5e748a7d0d216b5b1c589ed3b86254734f`,
Astra Blob `715bc340042675df86a0c791c49eb1852bb9b5ce`, and the unchanged
`accepted_reference_original_sha256`. All other lock fields, versions, permissions,
closed-task lists and batch limits are unchanged. `contract_blob` deliberately still
identifies the original contract; this later erratum is its one-field authority.

Validating reference format is **not** source or patch qualification. Current state:
`PATCH_INPUT_NOT_QUALIFIED / SOURCE_BYTES_NOT_VERIFIED_THIS_TASK /
PREPARE_NOT_RUN / EXECUTE_NOT_RUN / RUNTIME_NOT_AUTHORIZED`.
No historical LOCAL_ONLY source or patch bytes were read or reproduced in this
erratum task. The prior memory-only reference-byte proof is historical evidence.
The vendor patch is not included; supply the exact previously reviewed LOCAL_ONLY
original plus canonical LF diff under a future authorized task. If unavailable,
report `PRIVATE_PATCH_SOURCE_NOT_AVAILABLE`; a supplied missing path fails closed
with `INPUT_MISSING`. Never manufacture or substitute a merely equivalent patch.
The CRLF raw and LF canonical hashes remain distinct. Only a complete actual input
hash chain can establish `SOURCE_AND_PATCH_INPUT_QUALIFIED`, and that would still
not authorize prepare, real Flutter execution or functional acceptance.

## Interfaces

Commands below are templates; the execute command is **not authorized by this task**.
Replace placeholders only in a new, separately approved LOCAL_ONLY configuration.
Do not commit the resulting paths or grant.

```text
python -I -B <tool>/entry.py
python -I -B <tool>/entry.py inspect --config <local-config.json>
python -I -B <tool>/entry.py plan --config <local-config.json>
python -I -B <tool>/entry.py prepare --config <local-config.json> --grant <new-grant.json>
python -I -B <tool>/entry.py recover --root <same-prepared-root>
python -I -B <tool>/entry.py execute --root <same-prepared-root> --grant <new-grant.json> --action widget
```

- `inspect/plan`: read and hash only. With valid future locks and config, output a
  plan hash, estimated logical bytes and disabled execution state. No copying,
  downloading, dependency resolution, Flutter or Dart launch.
- `prepare`: requires a new authority, explicit logical/allocated budget and absent
  task-owned target. Copy listed input bytes, apply strict single-file diff only to
  the private Hook copy, verify target hash, flush per-action ledger and manifests.
  No real SDK preparation was performed under this zero-runtime erratum authority.
- `recover`: read the same root and ledger. Reject a copied/moved root, task mismatch,
  modified artifacts, broken chain or incomplete prepare. It never resumes copying
  or launches a process automatically. Incomplete/uncertain execution requires
  reconciliation and fresh Owner decision, with the spent attempt retained.
- `execute`: future Windows adapter, **not runtime-tested here**. Check a fresh grant,
  input hashes, same root, qualification receipt and remaining batch budget. Reserve
  and flush before Popen. Failure/uncertain launch consumes the attempt; no refund.
  Receipt `PROCESS_EXIT_ZERO_TEST_RESULTS_UNVERIFIED` is not test acceptance. A future
  authorized run must independently parse JSON test events, count each named case,
  and bind its stdout/exit to the exact source before reporting test PASS.

CLI exits: 0 = requested inspection/preparation/receipt completed (not functional
acceptance), 2 = blocked/rejected input. Unexpected runtime failures remain failures
with an uncertain ledger reservation; do not retry by changing root or task ID.

## Input and authority protocol

`config.example.json` is deliberately inert. Supply a new task ID, approved local
input roots, `owned_parent`, new `target`, explicit byte ceilings, exact `patch_diff`
and a complete `artifacts` array. Each row has `source`, `relative`, `sha256`, `role`;
tracked app files also have `tracked:true` and Git mode. No network/device namespace,
reparse point, symlink, hardlink, parent traversal, Windows reserved name, duplicate
case-insensitive output or source/target crossover is allowed. Windows volumes must
be fixed local volumes. `complete_offline_manifest:true` is a trusted operator
attestation, not discovery or proof that arbitrary third-party code is safe.

Required roles and their exact output locations are defined in `inspect_plan`:
private Dart, Dart VM, engine, Git, where, Flutter source entry, version receipt,
original Hook, tool resolver and app resolver. Include **all** transitive SDK/cache/
package files in the hashed manifest. The 729 tracked app blobs must reconstruct
the fixed apps Tree. Resolver URIs must stay inside the future target and reach
manifested files. No `pub get`, snapshot fallback, lockfile change or SDK upgrade.
Estimated allocation conservatively rounds file bytes; native allocation is checked
while preparing and before/during any future runtime. A future task must separately
qualify directory/metadata reserve and peak runtime space on its actual volume.

Grant fields: `owner_authorized:true`, new `task_id`, published 40-hex `task_blob`,
fixed `source_parent`, exact `plan_sha256`, allowed `actions`, UTC `not_before` and
`expires_at`; execute also needs integer `runtime_batches` and an in-root immutable
qualification receipt/hash. See `grant_check` for enforced bounds. The current and
previous closed task IDs/Blobs are rejected. A local JSON boolean is **not** a
cryptographic Owner identity check. The trusted human operator must first fresh-read
GitHub authority and verify the new frozen scope; creating a JSON file is no grant.

Qualification must bind the plan hash and attest write closure, process guard and new
Owner scope. Windows adapter starts suspended, attaches a kill-on-close Job, then
resumes; it samples fixed program images and records hashes/exit. The only outside
OS host exception is independently hashed conhost. This is **not a general sandbox**:
sampling cannot exclude every transient child; it is not suitable for malicious Dart,
native libraries or untrusted config. The Hook's byte-exact private patch supplies
its own direct-exe/argv/environment checks; `hook_arguments` independently checks the
two permitted argument shapes but does not intercept vendor Process.start calls.
Do not disable necessary native assets hooks or weaken the process guard.

## Offline synthetic checks

```text
python -I -B <tool>/test_entry.py
```

Set `ELITESYNC_SELFTEST_ROOT` to an existing new task-owned private temp directory
first. Tests create only inert synthetic bytes in that directory, then clean those
synthetic files. Executable-looking files are never launched; runtime positives use
an injected fake launcher. The execution task additionally replaced process/network
APIs with rejecting stubs. These checks establish control-flow and rejection
contracts, not real Flutter, Windows process isolation, Keystore or device behavior.

## Receipts, failures and reuse

Use `receipt.template.json` without private paths/tokens. Preserve raw stdout,
stderr, command details and full ledgers locally. Public evidence contains hashes,
counts and immutable Git references only. Hash-chain validation detects accidental
ledger changes, not an adversary able to rewrite the entire chain. Exclusive lock
failure is `CONCURRENT_OR_STALE_LOCK`; never automatically delete the lock/recreate
the root. Typical terminal failures include `SOURCE_HASH_MISMATCH`,
`PATCH_DIFF_HASH_MISMATCH`, `PATCH_TARGET_HASH_MISMATCH`,
`TARGET_EXISTS_RECOVER_LEDGER`, `DEPENDENCY_PATH_OUTSIDE_TARGET`,
`LEDGER_CHAIN_BROKEN`, `PREPARED_ROOT_MOVED_OR_COPIED`,
`UNCERTAIN_RUNTIME_CONSUMED_NO_RETRY`, `RUNTIME_BUDGET_EXHAUSTED`.

Do not repeat already accepted MariaDB 23 Feature/152 assertions or private-runner
11-file/77 Widget tests without new authority. This task has zero real runtime budget.
Any different Flutter/Dart/Hook version, input hash, patch or runtime policy requires
new provenance and review. No automatic main integration, AC05 closure, G2 release,
successor dispatch or v10.1.6 startup.
