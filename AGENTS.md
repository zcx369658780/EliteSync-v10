# EliteSync-v10 工程约定

生效：2026-11-16。当前状态依据[v10.1.16 Owner接受记录](docs/versions/v10.1.16/OWNER_ACCEPTANCE_20261116.md)及[V3.0阶段B3补充决定](docs/architecture/ELITESYNC_V10_PRODUCT_ROADMAP_V3_0_ADDENDUM_20261116_PHASE_B3_AUTHORIZATION.md)，当前路线权威为[产品路线图V3.0](docs/architecture/ELITESYNC_V10_PRODUCT_ROADMAP_V3_0.md)，普通工程自治及简化验证继续沿用[11月10日决定](docs/decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。历史事实及已耗记录不重写。


历史实机授权记录：Owner曾明确授权Codex操作当前接入手机完成v10.1.14补证，该工作已完成，结果见v10.1.14实机报告。v10.1.17有限手机反馈已单独归档；Owner现已接受v10.1.17和v10.1.18。当前UI-AUDIT-01明确只用Android模拟器采集截图，不操作Owner手机。

## 产品目标

Owner已确认项目交接及选定旧版主要功能接续完成。当前完善可实际使用的EliteSync APP、真实后端、持久数据库及独立Web管理面板。先完成业务功能与最小可操作界面，必要安全封装随功能收口处理，最后集中打磨UI和文字。现有鉴权、私信权限与数据隔离保留。

整个v10以功能、体验与UI为目标，不安排公司、内测或运营。v10.1.5已按Owner决定收尾，v10.1.6—v10.1.9按各自已接受范围保留。v10.1.10六项AC及手机补证获顾问范围接受，Owner整版最终接受沿原记录PENDING。v10.1.11六项AC声明工程范围已获顾问与Owner接受，AC11-02为限定能力接受，R1-01 CLOSED；原NOT_RUN/UNKNOWN继续保留。v10.1.12六项AC具名代表性范围已获顾问接受，R1-01 CLOSED；Owner整版接受仍单独记PENDING。v10.1.13六项AC具名代表性范围已获顾问与Owner接受，NO_R1/NO_R2；原NOT_RUN/UNKNOWN/UNVERIFIED继续保留。v10.1.14六项AC和1011402实机补证已获顾问及Owner具名代表性范围接受，NO_R1/NO_R2，三项P2及NOT_RUN边界保留。v10.1.15「生活方式探索与渐进式偏好」（V3.0阶段B1）已获Owner具名范围接受：AC15-01/03/04/05/06接受，AC15-02因图像模型精确身份UNKNOWN继续PARTIAL；R1-01 CLOSED、NO_R2。v10.1.16「统一用户状态与后台自动化中心」（V3.0阶段B2）已获Owner接受：七项AC具名范围接受，R1-01 CLOSED、第二轮顾问复核PASS、NO_R2；历史UNKNOWN/FAIL/NOT_RUN继续保留。v10.1.17「全APP低操作成本重构与功能整合」（V3.0阶段B3）已获GPT顾问具名范围接受并于2026-11-16获Owner整版接受，历史NOT_RUN/UNKNOWN继续保留。v10.1.18「UI表达与交互一致性收口」已获顾问具名范围接受并于2026-11-16获Owner整版接受。当前授权任务为UI-AUDIT-01：基于1011804候选进行模拟器UI现状审计和功能逻辑链盘点；本任务不改产品代码。B4运行时AI及阶段C外部服务仍未授权。

## 2026-11-16 当前交付状态

v10.1.13已获独立顾问验收及Owner接受，六项AC按具名代表性范围接受，NO_R1/NO_R2。实际范围、原失败和限制见[顾问验收](docs/versions/v10.1.13/ADVISOR_ACCEPTANCE_20261115.md)、[Owner接受](docs/versions/v10.1.13/OWNER_ACCEPTANCE_20261115.md)、[实施报告](docs/versions/v10.1.13/IMPLEMENTATION_REPORT.md)和[manifest](docs/versions/v10.1.13/artifact_manifest.json)。

v10.1.14阶段A六项AC及1011402手机补证已获顾问和Owner具名代表性范围接受（ACCEPTED_IN_NAMED_SCOPE — NO_R1 — NO_R2）。三项P2和NOT_RUN/UNKNOWN/UNVERIFIED继续保留。分支为`codex/v10.1.14-product-readiness-core-journeys-20261115`，唯一父基线`5dd0c9e6625699947f8dd0755ff568a3edfe0b04`，任务文档固定提交`866ccb269603ab451f84e948fa23d7361362f33f`。编码前九份文档逐Blob核对并生成路线ACK，完整记录见[同步回执](docs/versions/v10.1.14/LOCAL_DOCS_SYNC_RECEIPT.json)。

最终APP源码`88540f7f4d5a64500996b67eb04bfd9aba7c0af3`，候选`10.1.14-dev / 1011402`。社区单视频、20图文+5视频本机语料、P1草稿修复、核心旅程代表验证、独立备份恢复及Owner手动评估包已交付，范围见[实施报告](docs/versions/v10.1.14/IMPLEMENTATION_REPORT.md)和[manifest](docs/versions/v10.1.14/artifact_manifest.json)。低内存进程回收后草稿丢失保留P2。Owner随后授权实机补证，1011402在Xiaomi/Android16完成具名范围，语音67和视频69为手机+模拟器验证，耳机、人耳听感、双实机及跨公网矩阵NOT_RUN。实际结果见[实机报告](docs/versions/v10.1.14/PHONE_TEST_REPORT_20261115.md)。顾问与Owner均已接受具名代表性范围（NO_R1/NO_R2）；详见[Owner接受](docs/versions/v10.1.14/OWNER_ACCEPTANCE_20261115.md)。

v10.1.15已获Owner具名范围接受，AC15-02保持PARTIAL；完整记录见[Owner接受](docs/versions/v10.1.15/OWNER_ACCEPTANCE_20261115.md)、[顾问验收](docs/versions/v10.1.15/ADVISOR_ACCEPTANCE_20261115.md)和[R1复核](docs/versions/v10.1.15/R1_01_REREVIEW_20261115.md)。

v10.1.16 B2已获Owner接受，记录见[Owner接受](docs/versions/v10.1.16/OWNER_ACCEPTANCE_20261116.md)和[第二轮顾问验收](docs/versions/v10.1.16/ADVISOR_R1_REREVIEW_20261116.md)。v10.1.17 B3已获顾问及Owner整版接受，记录见[Owner接受](docs/versions/v10.1.17/OWNER_ACCEPTANCE_20261116.md)、[顾问验收](docs/versions/v10.1.17/ADVISOR_ACCEPTANCE_20261116.md)和[实机反馈](docs/versions/v10.1.17/OWNER_DEVICE_FEEDBACK_20261116.md)。v10.1.18已获顾问及Owner整版接受，记录见[Owner接受](docs/versions/v10.1.18/OWNER_ACCEPTANCE_20261116.md)及[顾问验收](docs/versions/v10.1.18/ADVISOR_ACCEPTANCE_20261116.md)。当前任务是[UI-AUDIT-01任务书](docs/workflow/UI_CURRENT_STATE_AUDIT_TASK_20261116.md)，Codex启动指令见[START PROMPT](docs/workflow/UI_CURRENT_STATE_AUDIT_START_PROMPT_20261116.txt)。审计固定候选1011804，不修改产品代码。

Owner已接受v10.1.17和v10.1.18。当前UI-AUDIT-01仅使用Android模拟器和虚构QA账号，不操作Owner手机；先采集1011804真实界面和功能逻辑，不开始UI实现。下一阶段视觉基调已由Owner明确为构成主义为主的二次元卡通画风；讨论阶段使用低分辨率设定图/低保真方向稿。B4运行时AI及阶段C身份/信用/Push/支付等仍未授权。

## 2026-11-16 UI现状审计任务

当前任务：`UI-AUDIT-01`，分支`codex/ui-current-state-audit-20261116`，任务书见[UI现状审计任务](docs/workflow/UI_CURRENT_STATE_AUDIT_TASK_20261116.md)，启动指令见[Codex Prompt](docs/workflow/UI_CURRENT_STATE_AUDIT_START_PROMPT_20261116.txt)。固定审计候选为`10.1.18-dev / 1011804`，包名`com.elitesync.v1018dev`，APP源码`1afa6940c37bc1b40aa3d05ea46fb47002f6455c`。

本任务仅采集模拟器主要页面截图、梳理当前功能逻辑链和简化机会；不改产品源码、API/Web、数据库schema、业务配置或版本号，不操作Owner手机，不合main、不发布。任务完成后停止，等待Owner与顾问讨论信息架构、交互逻辑及视觉方案。下一阶段视觉方向为构成主义为主的二次元卡通画风，讨论图采用低分辨率设定图。

## 入口与自主执行

先核实际仓库根、remote、分支、HEAD 和工作区/index；只读 [ACTIVE_STATE](docs/workflow/ACTIVE_STATE.md) 短入口及当前目标必要源码，规则见 [CURRENT_WORKFLOW](docs/workflow/CURRENT_WORKFLOW.md)。不再递归阅读旧交接、全部 Sources、SDK 清单或测试档案。

Owner负责方向和保留决定；顾问提供路线；Codex负责工程拆解、实现、调试、必要测试、审查、工程验收及常规 Git。在已授权目标内连续完成一项功能，可以跨 APP、后端、数据库和管理面板，不逐动作请求许可，不把普通实现修复变成新的任务审批。

普通可恢复错误自行修复，正常页面变化、导航、短暂等待和有限重读不自动导致整段 STOP。遇错设备/账号、真实数据、不可逆操作、明确额度/时间边界或 Owner 停止时，只停止受影响动作，其余授权工作可继续。

## 精简验证

默认仅做受影响代码的检查与定向测试；有必要时做一次最短功能验证。无代码变化、失败或具体未解决风险，不重复全量回归、全资产哈希或已通过的检查。文档整理只检查内容、链接、差异和 Git 状态，不构建 APK、不启动设备或服务。

不为普通小修强制多模型审批、新建冻结 case、复制 SDK/AVD/源码快照、生成多份同义报告。检查应直接证明功能或关键缺陷；不以测试数量、控制器通过或文档完成代替产品进展。只有具体高风险变更或既有明确要求才需要独立审查。

最终功能标准保留；开发中未完成事项明确列出，不因简化测试改成 PASS。自测、工程审查、外部独立验收、Owner 接受及发布分别记录；NOT_RUN/UNKNOWN 如实使用。

## 资产与权限

此前资产清理阶段已结束，既有版本摘要和恢复说明保留；当前以保护稳定工程及独有本地资料、完成本版功能为目标。GitHub 不覆盖未提交代码、私有配置、APK、素材、许可证、SQL/数据库及私有工具；这些仅保留必要的一份，不冒充已有远端备份。不为清理再复制整套工程。

保护原 D:\EliteSync-v10 的未提交成果和 index、当前开发目录及无关 %SystemDrive%/。不盲 pull/reset/rebase/stash/clean/prune，不 force push，不夹带无关内容。远端历史归档不是 main 合并或功能接受。

设备、真实用户/生产数据、外部服务、费用、重大架构/版本和发布仍由 Owner 决定。旧 STOP、已耗次数和余额不追溯修改，不因规则简化自动恢复任何运行。历史测试脚本只作参考，退役路径不能作为现行可执行合同。资产清理阶段已结束。Owner 已授权继续 APP 功能开发；实际联测可等功能完成后进行，届时允许同时使用两个模拟器。v10.1.14手机补证已完成并单独记录；v10.1.17有限Owner实机反馈已归档；当前v10.1.18不操作Owner手机，交付后由Owner自行决定验收。Owner 已长期授权普通功能工程、定向验证与必要APK构建、本机独立开发服务及虚构数据库、必要双模拟器联测、已有许可的免费官方依赖和常规Git。优先源码功能，不为普通重编/启动/安装反复申请；旧执行器/已耗记录不复活。Owner 要求停下时及时保存并手动交接，长期授权本身继续有效。

Owner于2026-11-12具体授权验收说明、120张测试截图、画廊/控件元数据和29份去敏证据摘要上传独立验收分支，范围及发布清单见[验收入口](https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/README.md)。完整原始回执、APK、素材、凭据、许可证、SQL/数据库与设备原始日志由Owner本机保管。有意义节点维护ACTIVE_STATE单一当前入口及必要进度，常规同步授权分支，失败记PENDING_SYNC。

## 历史决策

11月12日已有功能验收阶段已结束，原报告与测试结论见[v10.1.5收尾](docs/versions/v10.1.5/CLOSEOUT_20261113.md)。Owner当日要求保存并手动交接的[历史记录](docs/workflow/V1015_ADVISOR_ACCEPTANCE_HANDOFF_20261112.md)保留，后续版本按各自明确授权接续。

2026-11-14 [Owner接受v10.1.9并授权v10.1.10的决定](docs/decisions/OWNER_V10_1_9_ACCEPTANCE_AND_V10_1_10_AUTHORIZATION_20261114.md)作为历史依据保留。v10.1.9六项AC获顾问与Owner范围接受，V1019-R1-01 CLOSED，无需R2。v10.1.10任务分支为`codex/v10.1.10-self-knowledge-specialty-tools-20261114`，固定父基线为`8e74d1f7496f066a586afb1e5653ed563b64c46d`，其[实施报告](docs/versions/v10.1.10/IMPLEMENTATION_REPORT.md)记录实际交付。MBTI不作诊断或匹配硬筛选，双人盘使用本人已确认或明确手填输入，既有用途权限继续适用。

此后[Owner单独授权v10.1.11](docs/decisions/OWNER_V10_1_10_ADVISOR_ACCEPTANCE_AND_V10_1_11_AUTHORIZATION_20261114.md)。v10.1.10的历史停止条件及开工指令按其当时范围保留在版本档案中，当前入口见本文件当前交付状态、ACTIVE_STATE和CURRENT_WORKFLOW。
