# EliteSync V2｜UI-S4 顾问复审补充报告

2026-11-28，任务 `V2-UI-S4-ADVISOR-SUPPLEMENT-20261128`。Owner 已接受 UI-S4 阶段性交付及顾问补充建议。工程结论为 `UI_S4_QUANTITATIVE_ACCEPTANCE_PARTIAL`，发布状态为 `R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`。 [Owner 决定](../../../../decisions/OWNER_V2_UI_S4_PARTIAL_DELIVERY_ACCEPTANCE_20261128.md) · [顾问意见单](V2_UI_S4_ADVISOR_SUPPLEMENTAL_REVIEW_20261128.md)

## 固定身份

- 产品源码 `0ca97a15c35e9730a3c1c68a03fbdc5c09afd0f9`，tree `8c1adbd7ee1b15a6b2c04565b6da9cb125a`。原固定交付 `4d68befd028d60124985bdfe909df8a28e9e542c`，tree `8d383447788d83dd02022128a8770556b573dc35`。开工时活动分支本地和远端 tip 均为 `0ff738fbab8e8107ca96912803d2ac8a33e135f1`，活动工作树及暂存区干净。
- 唯一功能验收包 `com.elitesync.v2uis4qa / 1011818`，SHA-256 `6154f28708cfe4d232a8615ee757b64cb994cfa3d2dcefb00fbcea878e5be927`。emulator-5592、5594 实读安装摘要和版本一致。5592 使用原 AVD 副本，5594 使用只读运行。实际服务复用固定 Laravel 和 MariaDB 的合成夹具副本，补测写入副本。性能单独使用原 Profile 包。 [原验收报告](V2_UI_S4_QUANTITATIVE_UX_ACCEPTANCE_REPORT.md)

## 文案证据修订

原 1,230 条编号、字段与处置全部保留。新矩阵用 133 组固定候选截图及配对 Android XML 复核已给出证据的 560 行。优先处理原 UNVERIFIED 后转可见的 152 行及替换 35 行。对同任务域语义框内像素执行 Windows OCR、检查实际 `text` 节点以及系统控件归属。OCR 按同框文字逐项精确匹配，统一全半角及空白，并记录截图标识和坐标。证据不足一律沿枚举记为 `NOT_RUN`。图片选择器的 `Photos` 由实际 Android 包及控件身份核实。App 自己的导航或选择语义仅作为操作线索。

| 处置 | 原 S4 | 补充复审 |
| --- | ---: | ---: |
| VISIBLE_VERIFIED | 501 | 352 |
| REPLACED | 35 | 30 |
| SYSTEM_CONTROL | 20 | 1 |
| COPY_REWRITE_CANDIDATE | 4 | 0 |
| NOT_RUN | 670 | 847 |
| 合计 | 1,230 | 1,230 |

原 501 条可见中，351 条经截图文字核实、1 条经 Android 实际文本核实，149 条待取证。152 条优先记录中，97 条有像素证据，55 条待取证。原 438 条 UNVERIFIED 中，98 条当前有证据，包括 97 条可见文案和 1 条系统控件。177 条由原已登记有证据降为待证，和原 670 条分列。 [文案复审矩阵](advisor-supplement-20261128/UI_S4_COPY_FINAL_AUDIT.csv)

## 功能与通知补证

| 项目 | 具名结果 | 待验范围 |
| --- | --- | --- |
| U03 基础资料 | HTTP 单独修改城市并由同账号读回，其他基础字段保持原值，另一账号基础资料独立。主账号头像写入 503；具备现成合成许可的账号完成同一头像接口，版本递增、认证读取 231 字节，另一账号头像保持原值。 | Android 头像上传以及其他基础资料编辑字段。 |
| U09 候选 | 已归档旧候选在当前 A 发布 v2 后仍从 HTTP 读到 v1。最初两名适格候选产出 0 对，前一对命中近期重复配对规则；另一个虚构组合被现行社交许可过滤。使用全新合法 TEST_ONLY 组合后，候选 `PENDING` 且无好友授权时资料为空，实际拒绝到 `DECLINED`。另一个新组合通过独立好友流程授予展示可见性，真实轮次产出 v2 候选，HTTP 新候选读到 v2，MariaDB 独立查得旧绑定 v1、新绑定 v2。两个新候选均明确执行拒绝，联系与 Messaging Consent 的状态及聊天写入资格按独立接口核对。 | Android 候选拒绝页面、正式身份和实际用户匹配。 |
| U10 Buddy | 真实 HTTP 创建、邀请、申请、创建人确认，双方读到 `CONFIRMED`。独立分支分别读到 `DECLINED`、`WITHDRAWN`、`CANCELLED`。匹配、好友和现行消息权限的具名对照一致。 | Android 新增状态逐页证据与其他场景。 |
| U11 隐私及安全 | 本人双会话。跨账号撤销目标会话 404，本人撤销后该会话从列表消失，旧凭证 401。Block 后呈现在已认证列表中，同一聊天从 200 到 404。 | Android 设备撤权及更多失权组合。D4-A 真实对象请求渠道关闭。 |
| F08 Web 管理 | 合成管理员经真实本地 Web 表单及会话登录、搜索用户，实际读取用户、举报、设备安全、支持、审计、匹配、展示审核、搭子社区、题库、发布共 10 个具名页面。退出后管理页恢复保护。 | 浏览器视觉、管理写操作和真管理员数据。 |
| 通知 | 新增具名类型 `status_like`，合法目标可读；收窄、Block、撤下、目标缺失时 API 历史记录可读，正文、载荷与旧路由为空。Android 已重进通知中心并读到历史态。 | 其余全类型及历史私有附件的交叉组合，新增类型的目标跳转与返回联动。 |
| U12 重登 | 旧设备凭证 401；重登 API 读回基础资料和独立合成账号的展示草稿，切号基础资料、头像分开。具名三盘账号的出生内容 `exists=true`，实际读取输入、输入版本和签名、结果版本和三盘结果、计算设置及状态。 | Android 沿用原具名 v2 三盘读回及切号实拍，所有字段的 Android 对照尚未跑。 |

U12 基础资料 HTTP 响应含 ID、昵称、手机号、生日、时刻、出生地和坐标、生肖、性别、城市、关系目标、审核、实名状态和准备度。展示草稿实际读取展示昵称、城市、城市派生状态、自介、兴趣与生活方式标签、关系目标、开场说明、照片 ID 和列表、受众、可见性意图、审核状态、版本及资格字段。字段出现在 API 响应中的事实与非空、当前可见和完整编辑分开记录。 [功能回归矩阵](advisor-supplement-20261128/UI_S4_FEATURE_REGRESSION_MATRIX.csv)

## 无障碍与性能

首页精选与好友频道展开后，各在中心竖线的最上、最下行实际点按切换成功，覆盖 126 px（420 dpi 下 48.0 dp）。原先同候选首屏裁剪 42.3 dp 仍保留。三盘默认截图各取一个正文像素样本，八字、紫微、西洋分别为 11.51:1、11.41:1、11.33:1。已在 Android 绑定 TalkBack 取得三盘焦点与返回快照，键盘具名覆盖聊天、退出确认、登录及注册门控状态，并记录 Tab、Shift+Tab、Enter、Space 的不同效果。三盘八字、紫微和西洋取得 360dp／2× 实拍，默认字号与窗口大小已恢复。另验证好友列表分页和会话入口的中心点按。触控矩阵仍有 32 条 NOT_RUN，4 条 CHECK_CLIP_OR_DISABLED。完整读屏播报、跨页恢复、隐私弹窗以及大字、禁用态和深色对比组合继续按行标记。 [无障碍补充矩阵](advisor-supplement-20261128/UI_S4_ACCESSIBILITY_FINAL_MATRIX.csv)

Profile 有六个独立分段，包含三盘进程内首进、紫微切换、西洋及可见标签、三盘重入、好友长列表打开和滚动。首次进三盘段出现 343.835 ms 栅格区间，首进前到重入后 PSS 增加 65,100 KiB，均按单样本保留。原 292.684 ms 和 56,116 KiB 也保留。Android 宿主返回为 `UNKNOWN`，首页和热启动首帧、首次素材、标签绘制和页面重建的独立归因仍未测，整体性能 `PARTIAL`。 [Profile 补充报告](advisor-supplement-20261128/UI_S4_PERFORMANCE_PROFILE_REPORT.md)

## 两个产品缺陷与停点

- **D01。** 第一页及下一页均在无互动往返为 0 px，改变点赞后同一可共同读回的视口锚点均偏移 +74 px。源码核实显式恢复用的 controller 没有接到列表。各布局与刷新因素的相对贡献仍为 `UNKNOWN`。独立修复验收使用同一作品 ID、稳定帧与 ≤10 px 容差。 [D01 诊断](advisor-supplement-20261128/UI_S4_D01_DIAGNOSIS.md)
- **D10。** 只读核对原记录。服务端单条提交、同编号幂等回放、对端可读与客户端重试和冷启仍待确认同时成立。发送端那次读回的载荷与确认和清理阶段证据缺失，根因 `UNKNOWN`。 [D10 诊断](advisor-supplement-20261128/UI_S4_D10_DIAGNOSIS.md)

五场景 7C/0S、必要问卷 20C/0S、三盘概览 3C/0S。U05 扩展与历史单列，用户净 W 留空。普通注册继续 `BLOCKED_BY_ACCEPTED_REGISTRATION_GATE`，U01-T TEST_ONLY 单列。D11 主夹具媒体 404 已有合法合成夹具的原具名通过。 [原成本矩阵](UI_S4_U01_U12_INTERACTION_COST_MATRIX.csv)

下一节点由 Owner 亲自体验和决定是否分别授权 D01、D10 修复，以及文案、无障碍和性能余项的优先级。补充测试的原图、日志、合成环境和试验脚本留在本机 `D:/EliteSync/development/v2-ui-s4-supplement-local-20261128`。原候选和原证仍位于 `D:/EliteSync/development/v2-ui-s4-local-20261128`。
