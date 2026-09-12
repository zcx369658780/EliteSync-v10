---
name: soul-ui-scout
description: Reverse engineer the Soul Android app UI and feature structure on Windows emulator or device using ADB-backed UI automation. Use when the task is to inspect Soul page flows, capture screenshots, dump UI hierarchy, record navigation paths, enumerate visible features, or produce structured Markdown notes for competitor analysis.
---

  # Soul UI Scout

  ## Authority

  The current explicit task and `AGENTS.md` outrank this skill. Use it only when
  the task expressly authorizes the named device/emulator, visible UI scope,
  navigation, screenshots, hierarchy dumps, and deliverable. This skill never
  creates device, ADB, research, private-data, interaction, or write authority.

  ## Purpose

  Use this skill to explore Soul one screen at a time and convert what you see into a repeatable feature map.

  Keep the work low-risk:
  - inspect visible UI only
  - avoid payment, security, deletion, or account-abuse paths
  - prefer screenshots and hierarchy dumps over inference

  ## Input

  Expect the task to name a current module:
  - 首页
  - 发现
  - 聊天
  - 个人
  - 设置

  If the user names another module, map it to the closest above category before proceeding.

  ## Workflow

  For each page:

  1. Capture a screenshot.
  2. Dump the UI hierarchy.
  3. Record the module and current page name.
  4. List all visible first-level entries.
  5. Open one second-level entry at a time when it is low risk.
  6. Record the resulting page, visible features, and whether the path is a leaf or a navigable branch.
  7. Back out to the previous page with `BACK`.
  8. Repeat until the module is covered.

  ## Naming and Evidence

  - Name screenshots in a stable, searchable way.
  - Include module, page, and step number in the filename or note.
  - Keep one folder per session or per module if the run is large.
  - Record both the forward path and the return path.

  ## Output

  Write a Markdown report using the template in:

  - [`references/report-template.md`](references/report-template.md)

  Always include:
  - 模块
  - 页面名
  - 功能名
  - 页面入口
  - 核心操作
  - 回读路径
  - 截图编号
  - 对 EliteSync 的参考价值

  ## Safety Constraints

  Do not:
  - enter payment flows
  - enter account security or recovery areas
  - delete accounts
  - add or message strangers unless the user explicitly authorizes it
  - bypass auth, OTP, or moderation controls

  If a page looks sensitive, stop and ask for confirmation before continuing.

  ## Practical Guidance

  - Prefer screenshots plus hierarchy dumps over guesswork.
  - Reuse the same pattern for every module so the final report is easy to compare across apps.
  - If a branch is unstable, log that it is unstable instead of retrying indefinitely.
  - When in doubt, back out and continue with the next page.
