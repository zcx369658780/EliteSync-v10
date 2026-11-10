# EliteSync v10｜Codex Workspace / Project-Skill Remediation Task｜v0.1

Status: `AUTHORIZED — LOCAL WORKSPACE CLEANUP + PROJECT-SKILL REMEDIATION ONLY — APP-T06 PAUSED`

Date: 2026-09-13 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority

Fresh-start expected `origin/main` before this task is:

`7f7bcbf242dcefe3ac1a5c25408e3a52adc94da7`

Read FIRST:

`AGENTS.md`

Then read this task sheet.

APP-T06 is temporarily paused. Do not execute APP-T06 while this remediation task is in progress.

## 2. Purpose

Resolve the known local detached/dirty workspace and curate project-level Codex skills so that future EliteSync tasks start from a clean, reproducible, repository-versioned execution environment.

This task is maintenance/governance only. It does not modify APP product behavior or restart any product task.

## 3. Known starting facts

The prior read-only audit reported:

- repository root worktree is detached at `d1b45cc5...`;
- `AGENTS.md` appears modified relative to the detached HEAD but its local content/blob equals current `origin/main`;
- project `.agents/skills/` content is currently untracked;
- skill deletions in Git status = 0;
- eight project-level skill entries were found;
- the following are incompatible or risky:
  - `elitesync-fast-start` — obsolete workflow / nonexistent documents / default full-worktree status;
  - `elitesync-version-start` — EliteSync 6.0 / old acceptance system;
  - `elitesync-evidence-closeout` — automatic runtime/UI evidence and old `*_HANDOFF_MASTER.md` workflow;
  - `elitesync-dirty-worktree` — useful concept, but defaults to full-worktree inspection/staging beyond task authority;
  - `elitesync-runtime-slice` — useful only after removing automatic handoff to obsolete evidence-closeout;
  - `design-taste-frontend` — project junction to an external/global skill; not appropriate as project authority and explicitly mismatched to multi-step product UI work;
  - `codebase-memory` — useful project skill;
  - `soul-ui-scout` — useful project skill with templates/YAML present.

The executor must fresh-verify these bounded facts before acting.

## 4. Workspace preservation before cleanup

For this maintenance task ONLY, bounded workspace status inspection is explicitly authorized.

Before deleting, restoring, switching, or cleaning anything:

1. `git fetch origin`.
2. Record exact current HEAD, local `main`, `origin/main`, and `git worktree list`.
3. Run a bounded `git status --short --untracked-files=all` on the affected root worktree because this task specifically authorizes workspace cleanup.
4. Create an external preservation directory OUTSIDE the repository, suggested:
   `D:\EliteSync-v10-local-preservation-20260913\`
5. Copy every currently modified/untracked file from the affected root worktree into that external preservation directory, preserving relative paths.
6. Create a manifest with original path, size and SHA-256 for every preserved file.
7. Do not use `git clean` before this preservation manifest is complete and verified.

For an untracked file that has the same path on `origin/main`, compare content identity before cleanup. If byte-identical, mark `REMOTE_IDENTICAL`. If different or absent from `origin/main`, mark `LOCAL_ONLY_PRESERVED` and keep the external backup.

No local-only document or skill may be discarded without the external preservation copy and manifest.

## 5. Project-skill policy

After preservation, curate the project-level skills as follows.

### 5.1 Remove from project-level active skill set

Do not carry these into the repository-versioned project skills:

- `elitesync-fast-start`
- `elitesync-version-start`
- `elitesync-evidence-closeout`
- `design-taste-frontend` junction/link

Their preserved copies remain in the external preservation directory only.

### 5.2 Keep and version-control

Repository-version the following project skills under `.agents/skills/`:

- `codebase-memory`
- `soul-ui-scout`
- `elitesync-dirty-worktree` — only after remediation below
- `elitesync-runtime-slice` — only after remediation below

If any of these four is not actually one of the audited eight entries, STOP that individual skill action and report the mismatch; do not invent content.

### 5.3 Required remediation: `elitesync-dirty-worktree`

Revise it so that:

- it never performs default full-repository `git status`, index inspection, staging, stash, clean, restore, checkout or reset;
- it activates only when the current task explicitly authorizes dirty-worktree handling;
- inspection is path/scope bounded by the task;
- preservation precedes destructive cleanup;
- unrelated user modifications/staged state remain protected;
- if cleanup authority is absent, it reports the blocker and stops instead of entering an automatic staging flow.

### 5.4 Required remediation: `elitesync-runtime-slice`

Revise it so that:

- it does not automatically invoke or hand off to `elitesync-evidence-closeout`;
- runtime/test/evidence work occurs only when the current task expressly authorizes the exact command/evidence scope;
- absence of runtime authorization results in stop/report, not automatic evidence collection;
- it does not create extra handoff/result artifacts beyond the current task deliverable.

### 5.5 Project-skill precedence

All retained skills must state or preserve the rule:

`current task / AGENTS.md / explicit authority > skill suggestion`

A skill may help execute an authorized task; it never creates new read/write/runtime authority.

## 6. Global environment findings — verification/report only

Do NOT modify global Codex/plugin/model/notify configuration in this task.

Read-only verify and report:

1. Browser plugin version `26.908.40834`: manifest declares `./skills/` but corresponding skill directory is empty / `control-in-app-browser` missing, if still true.
2. Global default model currently `gpt-5.6-sol / medium` rather than the previously stated `gpt-6-astra`, if still true.
3. Global `notify` target points to a missing executable, if still true.

Do not repair Browser by copying from any different version. Do not change the global default model. Do not remove/change `notify` in this task.

These findings are separate host-global issues and must not block repository cleanup unless they prevent the exact Git/skill operations authorized here.

## 7. Repository skill candidate

Perform repository-versioned skill work in a separate clean worktree created from fresh `origin/main`.

Suggested branch:

`review/project-skill-remediation-v0-1`

Candidate scope may include only:

- `.agents/skills/codebase-memory/**`
- `.agents/skills/soul-ui-scout/**`
- `.agents/skills/elitesync-dirty-worktree/**`
- `.agents/skills/elitesync-runtime-slice/**`
- one remediation result artifact:
  `docs/architecture/ELITESYNC_V10_CODEX_WORKSPACE_PROJECT_SKILL_REMEDIATION_RESULT_V0_1.md`

Do not add the four removed/deprecated skill entries.
Do not add external junctions/symlinks as project authority.
Do not modify product code, APP tasks, AGENTS.md, build files, dependencies, plugins or global config.

## 8. Root-worktree cleanup and sync

After the external backup exists and the project-skill candidate has been safely created from fresh `origin/main`, clean the original root worktree conservatively:

1. Re-verify that the only tracked modification is the known `AGENTS.md` case. If any additional tracked modification exists, STOP cleanup and report it.
2. Re-verify local `AGENTS.md` content is byte-identical to `origin/main:AGENTS.md` before discarding the detached-HEAD modification marker.
3. Remove only the preserved untracked paths identified by this task from the original root worktree. Do not broad `git clean -fdx`.
4. Restore only the known `AGENTS.md` tracked modification as necessary to permit safe branch switching, after its content has been preserved and identity against `origin/main` confirmed.
5. Switch the root worktree to local `main` only if no other worktree currently has `main` checked out and the switch is safe.
6. Fast-forward local `main` to `origin/main` using fast-forward-only semantics.
7. Do not force-reset local `main`; if topology or another worktree prevents safe fast-forward, stop and report.
8. Final root worktree should be on `main` and clean, or report the exact bounded blocker if that cannot be achieved safely.

## 9. Verification

Required checks:

- external preservation manifest exists and hashes verify;
- repository candidate contains exactly the four retained project-skill directories plus one result artifact;
- deprecated project skills are absent from candidate scope;
- no symlink/junction under `.agents/skills/` points outside repository;
- retained skill SKILL.md files are readable and internally consistent with `AGENTS.md` authority rules;
- `git diff --check` on candidate;
- candidate worktree clean after commit;
- original root worktree final branch/state reported;
- no product source changes;
- no APP-T06 execution.

## 10. Required result

Create exactly:

`docs/architecture/ELITESYNC_V10_CODEX_WORKSPACE_PROJECT_SKILL_REMEDIATION_RESULT_V0_1.md`

Report:

- starting/final root-worktree state;
- preservation directory + manifest SHA-256;
- exact local-only files preserved;
- exact project skills removed from active project set;
- exact project skills retained/versioned;
- summary of edits to `elitesync-dirty-worktree` and `elitesync-runtime-slice`;
- exact candidate changed paths;
- global Browser/model/notify read-only findings;
- local-main/origin-main synchronization outcome;
- verification results;
- any blockers;
- explicit statement that APP-T06 was not executed.

## 11. Stop condition

Commit and push the project-skill candidate branch.

Do not merge to `main`.
Do not self-accept.
Do not execute APP-T06.

Expected success classification:

`WORKSPACE CLEANUP ESTABLISHED — PROJECT SKILLS CURATED AND VERSION-CONTROLLED — GLOBAL ISSUES REPORTED — READY FOR INDEPENDENT ACCEPTANCE AND APP-T06 REDISPATCH`
