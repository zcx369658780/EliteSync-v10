# EliteSync V2｜Owner RC-D 最终产品决定

2026-11-27，北京时间。归档依据为 Owner 任务单 `V2-RC-D-OWNER-DECISIONS-ARCHIVE-20261127`。

**归档出口 `RC_D_OWNER_DECISIONS_ARCHIVED`**

**阶段与发布状态 `RC_E_NOT_STARTED / UI_S_DEFERRED / R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`**

活动开发分支为 `codex/v2-function-completion-20261121`。审议材料固定在 `78d76e3e0aa58a4a64c8497fa7792cb10e828f89`，其 Git tree 为 `41f61956a214cdd598bb18bb75c7339a9d0f8323`。原报告保留当时的提案与待审状态，由本文件记录 Owner 本次实际选择。 [RC-D 固定审议材料](https://github.com/zcx369658780/EliteSync-v10/blob/78d76e3e0aa58a4a64c8497fa7792cb10e828f89/docs/versions/v2/cloud-r0-20261121/V2_RC_D_OWNER_DECISION_DOSSIER_20261127.md)

## 沿用的历史 Owner 决定

| 项目 | 已接受决定 |
| --- | --- |
| NEW-PC-04｜既有匹配候选形象 | 沿用 O05-X 方案 A。发布新版时，既有候选的快照不自动更新。新版默认面向未来新形成且当前有权的候选。既有候选按原快照及当前有效权限读取，失权时隐藏。 |

[Owner O04/O05 历史决定](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_O04_O05_DATA_REUSE_AVATAR_PUBLICATION_20261119.md)

## 本轮新增的 Owner 决定

| 项目 | 选定方案与范围 |
| --- | --- |
| NEW-PC-05｜官方内容 | 方案 A。首期范围为官方原创专题和站内受控编辑推荐，正式转载不纳入首期。站内推荐继续按用户对原作品的当前权限读取。访客正式正文继续使用空配置，实际素材发布须有具名授权。 |
| D0｜旧排盘 | 方案 A。旧 `POST /api/v1/profile/astro` 继续返回 409。保留现有有限的只读兼容，包括现行 `GET /api/v1/profile/astro`、`/summary` 与 `/chart` 的本人私有投影，继续使用 `/profile/natal` 进行正式输入与保存。 |
| D4｜对象级数据权利（RC-D04） | 方案 A。真实对象删除请求渠道暂不可用，继续使用 `REQUEST_CHANNEL_UNAVAILABLE`。合成状态沿 TEST_ONLY 记录。真实受理和完成回执须有对应的实际证据。 |
| E1｜真实身份核验 | 方案 A。暂不接入真实 KYC，正式匹配保留真实身份核验门禁。运营审核和合成凭证各沿原范围。 |
| E2｜通知 | 方案 A。首期仅使用站内通知，真实 Push 暂不接入。 |
| E3｜法律、数据及资产 | 方案 A。先核实法律依据、数据来源和第三方资产权利，缺少依据的相关功能继续关闭。F-01 `READABILITY_PARTIAL`、43 PNG `PENDING_BINARY_UPLOAD` 按原证据记录。 |

## 决定的效力与归档停点

本次 Owner 指令授权归档。顾问意见与技术提案保留在审议材料中。实际素材权利、法律和留存依据、真实受理与供应商条件沿各自的证据状态。

后续由 Owner 与网页 GPT 顾问确定 RC-E 的具体范围。RC-E 与 UI-S 均等待后续具名授权。
