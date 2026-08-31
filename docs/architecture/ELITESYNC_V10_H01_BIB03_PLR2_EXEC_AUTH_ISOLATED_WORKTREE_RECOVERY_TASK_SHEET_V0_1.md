# EliteSync v10 H-01 BIB-03 PLR-2 Execution-Authorization Isolated-Worktree Recovery Task Sheet v0.1

## 1. Task identity

Status:

`OPERATIONAL RECOVERY ONLY — NO PLR-2 GOVERNANCE DETERMINATION — NO CONTENT READ — FAIL CLOSED`

Repository:

`zcx369658780/EliteSync-v10`

Recovery task ID:

`H01-BIB03-PLR2-EXEC-AUTH-ISOLATED-WORKTREE-RECOVERY-01`

Durable main authority:

`05edf222a46ad7fc0e0de2d5031c59a6a6910144`

Target governance review branch:

`review/h01-bib03-plr2-execution-authorization-governance-v0-1`

Target governance task-sheet commit:

`ec1da5dd1bdc165edf8b3c9df98e8efd6dd7ac5c`

Target governance task-sheet blob:

`05b33bcbc189713fe2197b0dfe1f823712ecc6f0`

This recovery task exists only because the prior execution attempt failed to switch the current worktree to the exact review branch and then observed a nonzero staged state. The current worktree must be treated as quarantined for this recovery: do not inspect, modify, stage, unstage, restore, reset, stash, clean, commit, or otherwise repair its staged/unstaged content.

## 2. Exact remote authority gate

Fresh-fetch only these two exact known refs into their exact remote-tracking refs:

- `refs/heads/main -> refs/remotes/origin/main`
- `refs/heads/review/h01-bib03-plr2-execution-authorization-governance-v0-1 -> refs/remotes/origin/review/h01-bib03-plr2-execution-authorization-governance-v0-1`

Require:

`origin/main = 05edf222a46ad7fc0e0de2d5031c59a6a6910144`

and:

`origin/review/h01-bib03-plr2-execution-authorization-governance-v0-1 = ec1da5dd1bdc165edf8b3c9df98e8efd6dd7ac5c`

Do not search or enumerate refs, files, paths, branches, or repository contents.

## 3. Current worktree quarantine

The existing worktree may have a nonzero staged state. That condition is not to be repaired in this task.

Allowed observation only:

- `git diff --quiet`
- `git diff --cached --quiet`
- `git stash list`
- `git worktree list --porcelain`
- exact `git rev-parse` / exact `git show-ref --verify` calls for refs named in this task

Do not inspect the names or contents of staged/unstaged paths in the quarantined worktree.

A nonzero staged or unstaged state in the quarantined worktree does NOT by itself block creation of a separate isolated worktree, provided no operation mutates that quarantined state.

## 4. Authorized isolated-worktree recovery

Use one new sibling worktree directory dedicated to this review. Preferred exact path on the reported Windows environment:

`D:\EliteSync-v10-plr2-exec-auth-review`

Check only whether that exact path already exists. Do not enumerate its parent directory.

If the exact path already exists, return:

`OPERATIONAL BLOCKED — ISOLATED WORKTREE PATH ALREADY EXISTS — NO REPAIR ATTEMPTED`

and stop.

If it does not exist, create a new worktree detached at the exact target governance task-sheet commit:

`ec1da5dd1bdc165edf8b3c9df98e8efd6dd7ac5c`

The existing worktree must remain untouched.

Inside the new isolated worktree:

1. Verify `HEAD = ec1da5dd1bdc165edf8b3c9df98e8efd6dd7ac5c`.
2. Verify staged and unstaged changes are both zero.
3. Verify the exact remote review ref remains `ec1da5dd1bdc165edf8b3c9df98e8efd6dd7ac5c`.
4. Check only the exact local ref `refs/heads/review/h01-bib03-plr2-execution-authorization-governance-v0-1`.
5. If that exact local branch does not exist, create it at exactly `ec1da5dd1bdc165edf8b3c9df98e8efd6dd7ac5c` and switch the isolated worktree to it.
6. If that exact local branch exists and points exactly to `ec1da5dd1bdc165edf8b3c9df98e8efd6dd7ac5c`, switch the isolated worktree to it only if Git confirms it is not checked out in another worktree.
7. If the exact local branch exists but points anywhere else, or is already checked out elsewhere, return `OPERATIONAL BLOCKED` and stop without repair.
8. Verify the isolated worktree is now on the exact review branch at exact commit `ec1da5dd1bdc165edf8b3c9df98e8efd6dd7ac5c` with staged/unstaged `0 / 0`.

Do not execute the PLR-2 execution-authorization governance review in this recovery task.

## 5. No-content / no-successor boundary

This operational recovery authorizes zero documentary/technical/source-content reads except the exact known governance task sheet if needed for authority verification.

Do NOT read or re-read the locked README.

Do NOT reproduce, reuse, inspect, search, parse, hash, or otherwise process incident-exposed README content.

Do NOT perform source-locator extraction, package-URI normalization, source-path hypothesis/probe, source candidate/basis/binding activity, source read/inspection, evidence collection, PUI reconsideration, technical design, implementation, LC-03, LC-04, or Phase 36.

FD02 remains protected and excluded. Do not open/read/hash/re-hash/modify/move/delete/stage/commit/cite/select/allowlist/inspect/search/use FD02.

Preserve exactly:

`NO REPOSITORY-WIDE OR DIRECTORY-WIDE FILE/PATH ENUMERATION IS AUTHORIZED.`

Do not use `rg --files`, `find`, `fd`, `git ls-files`, discovery `git ls-tree`, recursive `ls`, recursive `dir`, `tree`, repository/directory globs, GitHub code search, filename search, or `git grep`.

## 6. Frozen governance/accounting

Preserve:

`CUMULATIVE ACCEPTED TECHNICAL/CONFIG/SOURCE-CONTENT READS = EXACTLY 11`

`UNAUTHORIZED DOCUMENTARY/TECHNICAL CONTENT READS = EXACTLY 1`

- accepted PLR-2 recovery/reauthorization gates = `1`
- accepted PLR-2 governance reviews = `1`
- PLR-2 execution-authorization governance determinations = `0`
- PLR-2 execution task sheets = `0`
- PLR-2 authorized read budgets = `0`
- PLR-2 valid executions = `0`
- incident-derived facts carried forward = `0`

No counter may change during this recovery task.

## 7. Git prohibitions

No reset.
No restore.
No checkout of files.
No unstage.
No stash creation/application/drop/pop.
No cleanup.
No work discard.
No rebase.
No merge commit.
No non-FF merge.
No force update.
No commit.
No push.
No modification of `main` or the remote review branch.

The only state-creating Git action authorized is creation of the isolated worktree and, if absent, creation of the exact local review branch at the exact known commit inside that isolated worktree.

## 8. Required result and stop point

Successful result:

`OPERATIONAL RECOVERY COMPLETE — ISOLATED CLEAN REVIEW WORKTREE ESTABLISHED — GOVERNANCE DETERMINATION STILL NOT EXECUTED`

Report:

- exact `origin/main`;
- exact remote review ref;
- quarantined original worktree branch and only its staged/unstaged zero-vs-nonzero status (no path/content inspection);
- isolated worktree exact path;
- isolated worktree branch;
- isolated `HEAD`;
- isolated staged/unstaged status;
- stash state;
- commits = `0`;
- pushes = `0`;
- all prohibited content/source/successor actions = `0`.

Then STOP before executing the PLR-2 execution-authorization governance review.