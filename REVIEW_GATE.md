# EliteSync v10｜本地风险门

按变更的最高风险分类；具体任务的更严格限制优先。审查记录保持短，写清结果、来源、测试和未解决风险。一个任务只有一个主要结果。

| 等级 | 常见范围 | 必需门 |
|---|---|---|
| LEVEL 0 Mechanical | 文档、格式、命名、测试夹具、快照、元数据 | Work/Codex 执行并自检，可本地接受；不需要独立审查。语义或权限改变不属于此级。 |
| LEVEL 1 Routine Engineering | 明确规格内的 Flutter presentation、UI、read-only adapter/endpoint、普通缺陷 | Work 发布任务 → Codex 实现与 targeted tests → Work 轻量实质审查。 |
| LEVEL 2 Architecture/Data Risk | auth、数据模型、DB migration、write API、privacy、relationship state、notification、环境/发布链、破坏兼容 | 独立 Work 审查；按任务列明负向用例、回退和数据边界。 |
| LEVEL 3 Product/Release Critical | matching/safety/privacy 核心政策、生产 DB、不可逆 schema、生产部署、APK/release claim、收费 | Owner 或明确授权的 Work 高风险门；真实数据、不可逆与生产动作仍须逐项明确授权。 |

LEVEL 0/1 可以在已授权范围内连续推进，Work 不必每轮请 Owner 转发消息。LEVEL 2/3 在对应门前停下。候选作者的自检不能代替该等级要求的独立审查；旧已发布任务的固定 SHA、预算与停点不因本文件放宽。

始终分别标记 `docs-only`、`Flutter presentation-only`、`backend`、`DB`、`release-chain`。本地代码、模拟器 debug APK、生产后端、签名发布各有不同证据，不能互相推导。GitHub 默认只用于备份、里程碑或发布；同步必须显式授权范围，失败不阻断本地已授权任务。
