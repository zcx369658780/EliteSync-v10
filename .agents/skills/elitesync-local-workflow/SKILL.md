---
name: elitesync-local-workflow
description: Execute an issued EliteSync-v10 local Work-to-Codex task and prepare its bounded candidate for Work review. Use when TASK_CURRENT.md assigns a task to Codex; this skill does not authorize product work by itself.
---

# EliteSync local workflow

1. Confirm the repository root, local Git branch, HEAD, and working-tree state. Read [CURRENT.md](../../../CURRENT.md), then the relevant parts of [PRODUCT_DECISIONS.md](../../../PRODUCT_DECISIONS.md), [TASK_CURRENT.md](../../../TASK_CURRENT.md), and [REVIEW_GATE.md](../../../REVIEW_GATE.md). Local files, code, and evidence establish current state; remote access and prior chat do not gate an authorized local task.
2. Before execution, extract the current Task ID, status, assignee, risk level, allowed paths, verification budget, and stop conditions. Act only on an `ISSUED` task expressly assigned to Codex and matching the current dispatch. Treat preparatory, paused, review-pending, or accepted states as non-execution states. Do not infer permission for a deferred task or reset an older task's fixed budget.
3. Keep edits and checks within that task's authority. Preserve unrelated staged, modified, and untracked content. For an authorized runtime slice, also use `elitesync-runtime-slice`; for expressly authorized dirty-worktree operations, use `elitesync-dirty-worktree`. Neither skill grants additional scope.
4. Deliver a candidate diff, targeted verification results, and the task's short `EVIDENCE/<task-id>/` summary when authorized. Label checks that did not run, and distinguish author completion from Work acceptance and synthetic evidence from real or production evidence.
5. Stop at the task's review gate. Work owns task issuance, independent ACCEPT/REJECT, accepted-state updates, and successors under the root [AGENTS.md](../../../AGENTS.md) and [REVIEW_GATE.md](../../../REVIEW_GATE.md); Owner retains protected decisions. Do not self-accept, create a successor, commit, push, or perform backup/recovery or protected actions without their own task authority.
