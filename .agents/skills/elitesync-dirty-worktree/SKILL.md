---
name: elitesync-dirty-worktree
description: Inspect and organize a dirty EliteSync Git worktree one authorized theme at a time while preserving unrelated changes. Use before bounded cleanup, staging, or archival work.
---

# elitesync-dirty-worktree

## Authority

The current explicit task and `AGENTS.md` outrank this skill. This skill helps
with dirty-worktree handling only when the current task expressly authorizes
that handling. It never creates read, write, index, cleanup, or Git authority.

## Purpose

Inspect or organize an authorized, precisely bounded part of a dirty EliteSync
worktree while preserving unrelated user work and staged state.

## Trigger

- The current task explicitly authorizes dirty-worktree inspection, preservation,
  cleanup, staging, or archival work.
- The task identifies the affected root and the permitted path or operation scope.

A dirty worktree alone is not a trigger and does not authorize inspection.

## Required workflow

1. Read the task's exact authority, root, path allowlist, stop conditions, and
   protected state before running Git inspection.
2. Inspect only the paths and status/index facts expressly authorized by the task.
   Do not default to full-repository status, diff, or index inspection.
3. Before any destructive cleanup, copy every affected modified or untracked file
   to the authorized preservation location and verify a size/hash manifest.
4. Protect unrelated modifications and staged state. If their classification or
   overlap is unclear, stop the affected operation and report the blocker.
5. Run staging, restore, checkout, reset, clean, stash, deletion, or ref movement
   only when the current task explicitly authorizes that exact operation and scope.
6. Report inspected paths, preserved paths, actions taken, exclusions, and the
   final bounded state.

## Stop condition

- The task's bounded dirty-worktree outcome is established; or
- required authority, preservation, identity, or path classification is absent,
  in which case report the exact blocker without entering an automatic staging
  or cleanup flow.

## Must not do

- Do not infer authority from a non-empty status.
- Do not automatically run full-repository status/index inspection.
- Do not automatically stage, stash, clean, restore, checkout, reset, or delete.
- Do not use `git add .`, broad pathspecs, or repo-wide destructive commands.
- Do not overwrite, unstage, discard, or commit unrelated user work.
- Do not clean before the authorized preservation copy and manifest verify.
