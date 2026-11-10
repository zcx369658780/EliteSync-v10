# EliteSync v10｜Root Worktree Cleanup and Local Main Resync Task｜v0.1

Status: `AUTHORIZED — ROOT WORKTREE CLEANUP / LOCAL MAIN RESYNC ONLY — APP-T06 REMAINS PAUSED`

Date: 2026-09-13 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority

Read FIRST:

`AGENTS.md`

Then read:

- `docs/architecture/ELITESYNC_V10_PROJECT_SKILL_REMEDIATION_PARTIAL_ACCEPTANCE_V0_1.md`;
- this task sheet.

Accepted project-skill candidate commit:

`904c44821fb190941d3c496103902257bb35db52`

Accepted preservation manifest SHA-256:

`05785AFE03DEDC9EAA48345328F266DD879564AD613ED9E68F6E0B7C1D4D36F0`

APP-T06 remains paused. This task does not execute or modify APP-T06 product scope.

## 2. Sole objective

Clean and resynchronize the original root worktree `D:\EliteSync-v10` without losing any pre-cleanup local material, using the already established external preservation package as the recovery source.

Target end state, if no new blocker appears:

- root worktree is on local `main`;
- local `main == origin/main` by fast-forward-only synchronization;
- root worktree has no modified or untracked files;
- the three accepted project skills are present as tracked Git files, not local-only copies;
- obsolete/unadopted project skills are absent from the root worktree;
- APP-T06 has not run.

## 3. Preservation gate

Preservation root:

`D:\EliteSync-v10-local-preservation-20260913`

Manifest:

`D:\EliteSync-v10-local-preservation-20260913\manifest.csv`

Before deleting or restoring any root-worktree path:

1. recompute the manifest file SHA-256 and require exact match:
   `05785AFE03DEDC9EAA48345328F266DD879564AD613ED9E68F6E0B7C1D4D36F0`;
2. re-verify every manifest row's preserved file size and SHA-256;
3. if any preservation file/row/hash is missing or mismatched, STOP before cleanup.

Do not rewrite the preservation package in this task.

## 4. Authorized bounded status inspection

This task expressly authorizes a root-worktree status inspection sufficient to compare current state against the already preserved manifest.

Record:

- current root HEAD and detached/branch state;
- local `main` SHA;
- fresh `origin/main` SHA;
- `git worktree list` only to determine whether local `main` is checked out elsewhere;
- root modified/untracked paths.

The expected pre-cleanup historical state was:

- detached HEAD `d1b45cc5da30bba3f377ef4ead2c677d0fb6eb88`;
- one tracked modification: `AGENTS.md`;
- preserved manifest covers 29 affected files.

If new modified/untracked paths exist that are not covered by the verified preservation manifest, STOP cleanup and report those exact new paths.

## 5. AGENTS.md handling

Before restoring or switching:

1. compare root `AGENTS.md` bytes to fresh `origin/main:AGENTS.md`;
2. if byte-identical, it is safe to restore the index/worktree state for `AGENTS.md` to current `origin/main` solely to remove the detached-HEAD tracked-difference marker;
3. if not byte-identical, STOP cleanup and report the mismatch; do not overwrite it.

No content edit to `AGENTS.md` is authorized.

## 6. Explicit untracked cleanup scope

After the preservation gate passes, remove from the root worktree only untracked paths represented in the verified preservation manifest.

This includes the prior local skill/material set such as:

- `.agents/skills/design-taste-frontend/**`;
- `.agents/skills/elitesync-cross-layer-blocker/**`;
- `.agents/skills/elitesync-dirty-worktree/**` local copy;
- `.agents/skills/elitesync-evidence-closeout/**`;
- `.agents/skills/elitesync-fast-start/**`;
- `.agents/skills/elitesync-runtime-slice/**` local copy;
- `.agents/skills/elitesync-version-start/**`;
- `.agents/skills/soul-ui-scout/**` local copy;
- local-only preserved architecture documents including `ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` and `ELITESYNC_V10_FD02_EXPANDED_STATIC_TECHNICAL_DISCOVERY_REPORT_V0_1.md`;
- all other untracked paths enumerated by the verified manifest.

Important:

- do not use broad `git clean -fdx`;
- do not delete any path not represented by the verified manifest;
- removal from the root worktree is safe only because the preservation package has already been independently hash-verified;
- removing `elitesync-cross-layer-blocker` from the active root worktree does not declare its historical content invalid; it remains preserved externally and simply has no current project authority.

## 7. Switch and fast-forward

After root modified/untracked blockers have been cleared:

1. verify no other worktree has local `main` checked out;
2. switch the root worktree to local `main` using normal non-force semantics;
3. fast-forward local `main` to fresh `origin/main` using FF-only semantics;
4. do not merge, rebase, reset --hard, force checkout, or force-update refs;
5. if local `main` is not a pure ancestor of `origin/main` at execution time, STOP and report topology rather than resolving divergence.

## 8. Post-sync project-skill verification

After successful fast-forward, verify the root worktree obtains these three project skills from tracked Git state:

- `.agents/skills/elitesync-dirty-worktree/SKILL.md`;
- `.agents/skills/elitesync-runtime-slice/SKILL.md`;
- `.agents/skills/soul-ui-scout/SKILL.md` plus its tracked support files.

Verify these are absent from active project skill state:

- `elitesync-fast-start`;
- `elitesync-version-start`;
- `elitesync-evidence-closeout`;
- `design-taste-frontend` project junction/link;
- `elitesync-cross-layer-blocker`.

Do not require a project-local `codebase-memory` skill. That erroneous requirement was withdrawn by acceptance.

Verify no `.agents/skills/` entry is an external symlink/junction.

## 9. Global environment boundary

Browser/model/notify remain report-only in this task.

Do not modify, reinstall, repair, copy, or delete any global plugin/model/notify configuration.

It is sufficient to preserve the last established findings unless current read-only inspection shows they changed:

- Browser `26.908.40834` manifest declares `./skills/` but bundled skills directory is empty and `control-in-app-browser` is missing;
- global default model observed as `gpt-5.6-sol / medium`;
- global `notify` target executable observed missing.

Do not block root cleanup merely because those global issues remain unresolved.

## 10. Result artifact

Create exactly one result artifact in a separate clean task worktree/branch or, if this task operates only on local root state and the repository needs the result committed, use a fresh clean result branch from fresh `origin/main`:

`docs/architecture/ELITESYNC_V10_ROOT_WORKTREE_CLEANUP_AND_LOCAL_MAIN_RESYNC_RESULT_V0_1.md`

Suggested result branch:

`review/root-worktree-cleanup-local-main-resync-v0-1`

The result must report:

- fresh `origin/main`;
- preservation-manifest re-verification;
- starting root HEAD/branch/status;
- exact removed root untracked paths or manifest row count;
- `AGENTS.md` byte-identity check and action;
- switch-to-main result;
- local-main FF-only result;
- final local `main` and `origin/main` SHAs;
- final root cleanliness;
- tracked project-skill verification;
- obsolete/unadopted skill absence;
- external-link/junction verification;
- unchanged global issue summary;
- explicit confirmation APP-T06 was not executed.

The result candidate may contain only that result artifact. Do not change project skills again in this task; they are already accepted on `main`.

Do not self-accept.
Do not start APP-T06.

Expected successful classification:

`ROOT WORKTREE CLEAN — LOCAL MAIN RESYNCHRONIZED — PROJECT SKILLS TRACKED — READY FOR INDEPENDENT ACCEPTANCE AND APP-T06 REDISPATCH`
