# EliteSync-v10 工程约定

生效：2026-11-14。当前版本依据[Owner授权v10.1.11](docs/decisions/OWNER_V10_1_10_ADVISOR_ACCEPTANCE_AND_V10_1_11_AUTHORIZATION_20261114.md)，方向延续[后端功能优先决定](docs/decisions/OWNER_V10_1_5_CLOSEOUT_AND_BACKEND_FIRST_20261113.md)；普通工程自治及简化验证继续沿用[11月10日决定](docs/decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。历史事实及已耗记录不重写。

## 产品目标

Owner已确认项目交接及选定旧版主要功能接续完成。当前完善可实际使用的EliteSync APP、真实后端、持久数据库及独立Web管理面板。先完成业务功能与最小可操作界面，必要安全封装随功能收口处理，最后集中打磨UI和文字。现有鉴权、私信权限与数据隔离保留。

整个v10以功能、体验与UI为目标，不安排公司、内测或运营。v10.1.5已按Owner决定收尾，v10.1.6 R1、v10.1.7、v10.1.8 R1及v10.1.9均已按约定开发范围获顾问与Owner接受。v10.1.10六项AC及手机补证已获顾问范围接受，Owner整版最终接受沿原记录PENDING。当前v10.1.11已工程集中交付，等待顾问验收。集中UI/文字版本v10.1.12仍未授权，不得自动启动。新破冰、约见、共同计划、纪念日仅留接口。

## 2026-11-14 当前执行范围

v10.1.11「账号支持与功能质量收口」已工程集中交付，等待新顾问验收。原工程固定提交为`3888c6eb63ecfb6798a80387f4b27cd891a10457`，任务分支为`codex/v10.1.11-account-support-quality-20261114`。约定范围见[任务](docs/versions/v10.1.11/task_order.md)及[计划](docs/versions/v10.1.11/plan.md)，实际交付及限制见[实施报告](docs/versions/v10.1.11/IMPLEMENTATION_REPORT.md)和[manifest](docs/versions/v10.1.11/artifact_manifest.json)。顾问验收、Owner接受、main集成与发布分别记录。

当前仅执行Owner转交的R1-01文档修正，更新本文件并核对ACTIVE_STATE与CURRENT_WORKFLOW的一致性，保存到原v10.1.11任务分支并完成远端固定回读，随后停下供顾问治理复核。验证范围为文档内容、链接、差异与Git身份。v10.1.12仍未授权，不得自动启动。

真实Push为REAL_PUSH_PROVIDER_PENDING，历史非注入SFU/RPC精确根因为UNKNOWN，未验硬件/自然期限及旧失败分别保留。已接受的通信、好友/搭子/活动与自我认识工具按具名范围继承。

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

设备、真实用户/生产数据、外部服务、费用、重大架构/版本和发布仍由 Owner 决定。旧 STOP、已耗次数和余额不追溯修改，不因规则简化自动恢复任何运行。历史测试脚本只作参考，退役路径不能作为现行可执行合同。资产清理阶段已结束。Owner 已授权继续 APP 功能开发；实际联测可等功能完成后进行，届时允许同时使用两个模拟器。手机由 Owner 使用，不连接或操作手机，不要求 Owner 保持手机就位。Owner 已长期授权普通功能工程、定向验证与必要APK构建、本机独立开发服务及虚构数据库、必要双模拟器联测、已有许可的免费官方依赖和常规Git。优先源码功能，不为普通重编/启动/安装反复申请；旧执行器/已耗记录不复活。Owner 要求停下时及时保存并手动交接，长期授权本身继续有效。

Owner于2026-11-12具体授权验收说明、120张测试截图、画廊/控件元数据和29份去敏证据摘要上传独立验收分支，范围及发布清单见[验收入口](https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/README.md)。完整原始回执、APK、素材、凭据、许可证、SQL/数据库与设备原始日志由Owner本机保管。有意义节点维护ACTIVE_STATE单一当前入口及必要进度，常规同步授权分支，失败记PENDING_SYNC。

## 历史决策

11月12日已有功能验收阶段已结束，原报告与测试结论见[v10.1.5收尾](docs/versions/v10.1.5/CLOSEOUT_20261113.md)。Owner当日要求保存并手动交接的[历史记录](docs/workflow/V1015_ADVISOR_ACCEPTANCE_HANDOFF_20261112.md)保留，后续版本按各自明确授权接续。

2026-11-14 [Owner接受v10.1.9并授权v10.1.10的决定](docs/decisions/OWNER_V10_1_9_ACCEPTANCE_AND_V10_1_10_AUTHORIZATION_20261114.md)作为历史依据保留。v10.1.9六项AC获顾问与Owner范围接受，V1019-R1-01 CLOSED，无需R2。v10.1.10任务分支为`codex/v10.1.10-self-knowledge-specialty-tools-20261114`，固定父基线为`8e74d1f7496f066a586afb1e5653ed563b64c46d`，其[实施报告](docs/versions/v10.1.10/IMPLEMENTATION_REPORT.md)记录实际交付。MBTI不作诊断或匹配硬筛选，双人盘使用本人已确认或明确手填输入，既有用途权限继续适用。

此后[Owner单独授权v10.1.11](docs/decisions/OWNER_V10_1_10_ADVISOR_ACCEPTANCE_AND_V10_1_11_AUTHORIZATION_20261114.md)。v10.1.10的历史停止条件及开工指令按其当时范围保留在版本档案中，当前入口见本文件当前执行范围、ACTIVE_STATE和CURRENT_WORKFLOW。
