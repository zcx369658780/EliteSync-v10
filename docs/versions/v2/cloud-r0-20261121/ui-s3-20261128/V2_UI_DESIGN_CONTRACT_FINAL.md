# EliteSync V2｜冻结设计合同

2026-11-28。Owner 在 `V2-UI-S3-CONSOLIDATED-DESIGN-IMPLEMENTATION-20261128` 接受方案 2 交互原型与 UI-S2 背景修订，授权 Flutter 集中实施。

> 各个界面的背景 UI 不应只是纯色，而应体现结构主义＋二次元的极简清新画风。

Owner 在背景修改版的原始评价随设计依据保留。

> 我认为这一版设计的很好

| 固定依据 | 身份 |
| --- | --- |
| 现有功能与定向修复 | 源码 `ae5c2c1883118634fc165a51929e0963730873ba`，交付 `a3c6f549e780bd6cd2ffe33f44ac77963b878b5d` |
| 方案 2 原型与 Owner 原确认 | `746f9b96c6e1e3dae2444bd4e39662ca547bceb8` |
| 背景修改版 | `ad3b54dafd8cbb2e2dc2335e78bfa8d25cbf731b`，tree `9dac63d0f7119fe4162136f699949afe9977f348` |

[方案 2 原型](../ui-s1-20261128/V2_UI_S1_ADVISOR_REVIEW_20261128.md) · [24 状态与重点前后对照](../ui-s1-20261128/background-review/V2_UI_S1_DIRECTION_2_BACKGROUND_REVIEW_20261128.md) · [背景 Token](../ui-s1-20261128/background-review/UI_S1_D2_BACKGROUND_TOKENS.md) · [UI-S0 操作成本](../ui-s0-20261127/INTERACTION_COST_MATRIX.csv) · [UI-S0 原文案](../ui-s0-20261127/USER_VISIBLE_COPY_INVENTORY.csv) · [UI-S0-R 功能合同](../ui-s0-r-20261128/V2_UI_S0_R_FUNCTIONAL_REMEDIATION_REPORT.md)

## 视觉与操作

- 一级导航为首页、匹配、消息、我的。首页优先显示当前任务、我的三盘、好友动态；其余合法入口随下方功能区保留。引导按需查看。Lifestyle 五场景及必要问卷保留，保存与推进以既有成功回执为准。
- 基础画布、内容承载面、主题分区、装饰构成四层背景。自然场景服务首页、欢迎和 Lifestyle。几何结构表达三盘和关系进度。人物情境用于 Buddy 或低内容密度场景，低干扰局部纹理用于表单、聊天和隐私。背景在内容后绘制、忽略触控且不占滚动空间。
- 八字淡青绿、紫微灰蓝、西洋淡紫灰沿用固定 Token。现有后端结果是盘面唯一数据来源，当前与历史保持各自版本，保留独立输入、设置、历史、来源与高级入口。独立算法准确性按 RC-E 原限定结论。
- 产品范围以现行已接受业务和接口为准，原型提供设计指导。原型图从未表现的已接受功能也进入实施覆盖表。保持候选快照 v1/v2、双方决定、独立联系和聊天许可、撤权、Block、举报、退出及隐私。保留附件原编号恢复、展示草稿持久化和发布审核分离。
- R04-A 的普通注册在协议正文、来源和版本核实前暂停，服务端拒绝创建。已有账号登录继续遵循既有在线与可信离线合同。独立 TEST_ONLY 数据从本地隔离准备流程产生。密码强度保持至少八字符并含字母和数字。
- 背景素材仅使用可说明来源的设计资产或程序绘制的几何与纹理，原型整页及历史 43 张 PNG 不进入 APP。媒体原件、账号、数据库、旧 APK 和原始证据各沿保护约定。

## 工程层级

| 层 | Flutter 实施依据 |
| --- | --- |
| 画布 | `UiS3Backdrop` 使用方案 2 已通过的画布、承载面和分区。深色模式沿用系统主题入口，装饰降低强度。 |
| 字体和节奏 | 现有 `AppTypography`、`AppSpacing` 和系统字体缩放继续生效。常用标题层级为 24、20、18 和 16 sp，可读正文为 16、14 sp。 |
| 组件 | 现有主题负责主次按钮、字段、标签、列表、分割线和状态组件。主要操作使用深青 `#1B5958`，正文使用 `#153C3D`。 |
| 主题分区 | 八字 `#EDF5EF`、紫微 `#EDF2F8`、西洋占星 `#F2EFF6`。紫微宫位与西洋盘面保留实际结果的名称、星曜与位置来源。 |
| 装饰 | 河岸、Buddy 与 Lifestyle 使用项目已有绘图。几何与纹理交给 `UiS3Canvas` 在内容下绘制，装饰层忽略触控和阅读顺序。 |

[素材清单](UI_S3_BACKGROUND_ASSET_MANIFEST.csv) · [实现与保留功能表](UI_S3_SCREEN_AND_FEATURE_COVERAGE.csv)

工程证据以本地隔离 Laravel、MariaDB、新 APK 及两个 Android 模拟器为准。真实设备和发布状态沿各自授权。UI-S4 继续原 C/S/I/N/W/B 口径。总体 `R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`。
