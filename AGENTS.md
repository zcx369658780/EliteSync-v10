# EliteSync-v10 工程约定

生效：2026-11-14。当前版本依据[Owner接受v10.1.11并授权v10.1.12](docs/decisions/OWNER_V10_1_11_ACCEPTANCE_AND_V10_1_12_AUTHORIZATION_20261114.md)，方向延续[后端功能优先决定](docs/decisions/OWNER_V10_1_5_CLOSEOUT_AND_BACKEND_FIRST_20261113.md)；普通工程自治及简化验证继续沿用[11月10日决定](docs/decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。历史事实及已耗记录不重写。

## 产品目标

Owner已确认项目交接及选定旧版主要功能接续完成。当前完善可实际使用的EliteSync APP、真实后端、持久数据库及必要独立Web管理面板。先完成业务功能与最小可操作界面，必要安全封装随功能收口处理，再集中打磨UI、信息结构与文案。现有鉴权、私信权限与数据隔离保留。

整个v10以功能、体验与UI为目标，不安排公司、内测或运营。v10.1.5已按Owner决定收尾；v10.1.6—v10.1.9按各自已接受范围保留。v10.1.10六项AC及手机补证获顾问范围接受，Owner整版最终接受沿原记录PENDING。v10.1.11六项AC的声明工程范围已获顾问与Owner接受，AC11-02为限定能力接受，R1-01 CLOSED；其NOT_RUN/UNKNOWN与外部限制继续保留。当前授权版本为v10.1.12「集中UI、信息结构与文案完善」。

## 当前执行范围

执行[路线图](docs/architecture/ELITESYNC_V10_FUNCTION_BACKEND_UI_ROADMAP_20261113_V2_0.md)和[v10.1.12任务](docs/versions/v10.1.12/task_order.md)、[计划](docs/versions/v10.1.12/plan.md)、[启动Prompt](docs/versions/v10.1.12/CODEX_START_PROMPT.txt)。按“我的/设置 → 消息/聊天 → 首页/进展 → 匹配/社交/特色工具 → 必要Web页面”推进。集中统一导航职责、组件、密度、字体、颜色、主题、普通/高级信息层级、返回/键盘、大字/可访问性和全状态文案。不新增大型业务，不改变既有后端合同、算法、关系、隐私和安全权限。

任务分支：`codex/v10.1.12-ui-information-architecture-20261114`；唯一父基线：`2f3058d39a936063768ffb895f577d97a088e04c`。产品源码基线：`47e1b4fd8fad3dd8165d1be6dc9f059095290e75`。GitHub任务发布不代表Windows本地已同步，Codex先核实际工程并保护dirty/index，再安全同步。

## 入口与自主执行

先核实际仓库根、remote、分支、HEAD和工作区/index；只读[ACTIVE_STATE](docs/workflow/ACTIVE_STATE.md)当前入口与当前目标必要源码，规则见[CURRENT_WORKFLOW](docs/workflow/CURRENT_WORKFLOW.md)。不递归旧handoff、全部Sources、SDK清单或历史日志。

Owner负责方向和保留决定；顾问提供路线；Codex负责工程拆解、实现、调试、必要测试、审查、工程验收及常规Git。在已授权目标内连续完成工作，不逐动作请求许可，不把普通实现修复变成新的任务审批。

普通可恢复错误自行修复。遇错设备/账号、真实数据、不可逆操作、明确额度/时间边界或Owner停止时，只停止受影响动作，其余授权工作可继续。

## 精简验证

默认仅做受影响代码检查、定向测试和有限代表性旅程回归。文档整理只检查内容/链接/差异/Git状态，不构建APK或启动设备服务。最终功能标准保留；未完成事项明确列出，不因简化测试改成PASS。

自测、工程审查、外部独立验收、Owner接受、main集成及发布分别记录；NOT_RUN/UNKNOWN如实使用。

## 资产与权限

保护原D:\\EliteSync-v10的未提交成果和index、当前开发目录及无关%SystemDrive%/。不盲pull/reset/rebase/stash/clean/prune，不force push，不夹带无关内容。GitHub远端不是本地未提交代码、私有配置、APK、素材、许可证、SQL/数据库和私有工具的备份。

普通工程长期授权继续有效：必要开发库迁移、定向测试、Debug APK、本机独立开发服务、虚构数据、必要双模拟器、已有许可免费官方依赖和常规Git可自主执行。不操作Owner手机，不访问真实用户或生产数据，不接新供应商/付费服务，不合main、不正式发布、不开展公司/内测/运营。

## 历史保留

真实Push为REAL_PUSH_PROVIDER_PENDING；历史非注入SFU/RPC精确根因UNKNOWN；v10.1.11遗忘密码重置和真实身份核验正向链等按原报告NOT_RUN。版本验收不追溯改变这些事实。相识后破冰、约见、共同计划、纪念日继续只留接口。
