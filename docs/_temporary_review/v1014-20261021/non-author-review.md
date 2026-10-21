# v10.1.4 bounded non-author static review

Reviewer: separate non-author helper `/root/v1013_non_author_review`.
Scope: frozen version diff, current authorization/locking/capacity/Safety/appeal/APP boundaries. No DB/API/device executions by reviewer. One consolidated review with closure checks of the same findings.

Findings preserved:

1. P1 legacy audit/user detail exposed new Safety reasons/appeal text and sanction/report associations outside the new workspace.
2. P1 legacy restore could deactivate a Safety sanction without a named case appeal review.
3. P2 user-first expired event read rolled terminal writes back with its 404.
4. P2 restricted accounts lacked an APP-visible current revision for voluntary withdrawal.

Fixes: legacy queries exclude the new domain, new-domain governance audits carry a filtered Safety prefix, Safety restore requires the exact report scope supplied by the named review service; expiry commits before user projection denial; restricted accounts get only their own minimal current exit ticket and APP cancel action. Existing independent restrictions and legacy non-Safety contracts retained. Added regressions include no-effect legacy restore rejection, old-view redaction, user-first expiry and restricted withdrawal.

Final static closure statement from reviewer:

“本轮发现已收敛关闭，固定源码范围内未见剩余静态阻断。旧用户页现已排除 Safety 关联处罚，并新增不可见断言；此前旧读取／restore旁路、到期回滚和受限用户退出入口问题均已见源码修复。50 tests／1134 assertions、Widget及RR结果属于主代理执行回报，本代理未独立运行或核验原始回执。不构成 Astra ACCEPTED。”

Fixed source: 3e5afb33c87812ffa2970741c4ea97a4c649da91
Root: a1984f36c0b95d1d78f6c34e06937850972b3ebb
apps: b502d776c8e5f916f2d4074b90a39d0547b896fa
services: 4316c195d201b8f31db70e86a7d7710437f28137


## Same-review final closure (append; previous findings retained)

Author's real HTTP organizer-role negative initially returned event 200 / Web 403 (exit 1). Fixed current organizer role/phone/account authority under user locks; actual repeat returned 404/403 and restored the synthetic administrator role. Added Feature coverage. Attendance projection now removes the used action; COMPLETED permits only an existing participant's voluntary exit.

The same non-author reviewer checked the final two-file change and stated: “两文件窄差异已核对，未发现新增静态阻断：COMPLETED 仅新增本人退出能力，仍要求已有 active 注册；退出撤销 grant，保留活动 COMPLETED 及历史，不产生 Finding／处罚。”

Final identity checked by reviewer: e7e246dc70f72846a05a31e022efadee0838ab83 / e9ca41a1347fdeebdedca18de6f8eed767b59d5c / apps b502d776c8e5f916f2d4074b90a39d0547b896fa / services 45869d8b765ca8c645a04f747bb67be03a5bd632.

Reviewer did not independently run DB, API, AVD, or tests. The execution-side follow-up subsequently confirmed actual APP read/withdrawal after restart and unchanged decision/review/sanction full values. This is CODEX_REPORTED, not Astra acceptance.
