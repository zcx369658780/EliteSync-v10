# AUTH-127｜轻量应用服务器单次只读目标绑定候选（Phase A）

**作者静态候选，待 Work LEVEL 2 独立审查；不放行账号登录或现场查看。** 2026-09-26，本地 `D:\EliteSync-v10`、`main`、HEAD `d35bcc8161a3d553c2eb4446e788ec1b32223f78`；`TASK_CURRENT.md` 为 `ISSUED — STATIC CANDIDATE ONLY; NO ACCOUNT LOGIN`。仅新增本 `plan.md`；既有 `CURRENT.md`、`TASK_CURRENT.md` 修改和两个无关未跟踪目录原样保留。

## 精确依据与事实层级

`EVIDENCE/AUTH-24-ALIYUN-BACKUP-RESOURCE-CHOICE-PACKET/packet.md` 第 9 行记录：2026-09-24 15:50～15:55（Asia/Shanghai），Owner 在当时已登录控制台确认上海**轻量应用服务器**为后端目标，公网 IP 与当次授权目标一致；同次 ECS 上海/全部地域列表未见实例。第 13 行明确轻量应用服务器不等于 ECS/RDS；第 47 行强调只是该页面/时点 UI 观察，不是云 API、全局资产或权限证明。该记录决定本候选的**产品类别**，但不能证明今天实例仍存在、地址未变或 Owner 账号权限未变。`EVIDENCE/AUTH-126-ECS-INSTANCE-BINDING-VIEW-STATIC-CANDIDATE/plan.md` 已由 Work REJECT 原 ECS 前提，仅保留错误类别停点。

`EVIDENCE/AUTH-02-ALIYUN-CORRECTED-KEY-SOURCE-IDENTITY/summary.md` 的 `101.133.161.203` 仅是历史 SSH 地址线索，AUTH-17 仅接受历史主机工具/空间回执，均未建立现时轻量实例 ID。AUTH-107 Phase B 未放行。AUTH-123 只接受本机 `INPUT_CR / FORMAT_INVALID` 类别，AUTH-121/122/123 的真实本机读取各 1/1 耗尽。AUTH-124 的服务器身份/端口分门是通用静态路径；AUTH-125 的 ECS 文档不能替代轻量应用服务器页面。**现时目标实例、当前公网地址、独立服务器 host-key 来源与有效 SSH 端口均 `UNKNOWN`。**

## 匿名官方资料与页面边界

2026-09-26 匿名只读访问阿里云轻量应用服务器（SAS）官方[《查看轻量应用服务器信息》](https://help.aliyun.com/zh/simple-application-server/user-guide/view-lightweight-application-server-information)，正文可核对。该页指向官方[“轻量应用服务器控制台－服务器”入口](https://swasnext.console.aliyun.com/servers/)；**本轮未打开此账号页面**。文档说明“服务器”列表可见账号下服务器基本信息，支持以实例 ID 或公网 IP **精确查询**，列表主要信息含实例 ID、IP 地址和状态；点击实例 ID 后的“服务器概览”基本信息含实例 ID、IP 地址等。这只支持未来的页面类别与字段设计，不证明 Owner 账号、上海地域、具体实例或今天 UI 布局。文档还显示远程连接、密码重置和命令助手等操作能力；它们全部在本候选范围外。该正文未足以固定地域字段的可见位置，故未来无法独立核对地域时必须记 `REGION_UNKNOWN` 并停，不能从旧 AUTH-24 观察推定当前地域。

未来另立具体 Phase B 并完成 Owner 风险门后，**一次查看**最多走：上述固定官方轻量应用服务器“服务器”入口 → 仅在预定账号与上海地域下查看服务器列表 → 用事先固定的历史地址线索作**精确**筛选（若当前 UI 支持） → 唯一候选的“服务器概览”基本信息 → 退出。不得点击远程连接、命令助手、安装 Agent、VNC、Workbench、重置密码、编辑名称/防火墙、导出、创建或任何其他服务器操作；不得换账号、地域、产品、搜索条件或逐个浏览多台服务器。若官方入口重定向到非预期域、页面/字段变化或地域无法确认，`PAGE_OR_REGION_UNVERIFIED` 并停，不临场摸索。文档是在线产品说明，未来现场前仍须由 Work 复核精确入口和页面边界。

## 未来单次门、有限回执与停止条件

1. **放行前固定。** Work 先以受限方式固定预期 Owner 账号主体、轻量应用服务器产品、上海地域、AUTH-02 历史地址 `101.133.161.203`（仅待核对线索）、允许的唯一候选识别规则、观察时点窗口和页面路径；若实例 ID 有独立既有来源也要单独固定，不能由本次猜出。账号主体/地域/唯一规则缺一项即 `PRECHECK_MISSING`，不给现场预算。AUTH-24 的“当时匹配”不当今日事实。
2. **登录/密码前停。** 本 Phase A 不打开账号页面。未来 Phase B 即使仅只读，也须新任务、Work 独立裁决和 Owner 在**当前 Work 会话**的具体授权；“我在”只表示到场。到达登录页、密码、验证码/真人识别、权限提示或 Windows UAC 之前立即停下，由 Owner 自行现场处理获准凭据步骤；绝不请 Owner 在聊天发密码、截图、实例 ID、IP 或页面原文。登录失败、意外权限扩大或跳转异常，失败即停。
3. **只作唯一绑定。** 在已获准页面内，核对产品类别、预固定账号主体与地域；列表精确查询历史地址只用于**寻找待核对候选**。必须恰有一个服务器，进入其基本信息并核对实例 ID（若预先固定）、当前公网地址、状态、产品类别与观察时点。无结果、多候选、缺少实例 ID/地域/IP、地址漂移、实例重建或与预固定线索不符，均停止并保留 `UNKNOWN/NO`；不得因旧地址吻合就忽略实例身份，也不得在现场改走 ECS/RDS。若仅靠历史 IP 无法形成独立的唯一实例判断，`TARGET_BINDING=UNKNOWN`，交 Work 决定新的来源任务。
4. **普通脱敏回执。** 只允许 `TARGET_BINDING=YES|NO|UNKNOWN`、`PRODUCT_CLASS=LIGHTWEIGHT_APPLICATION_SERVER|UNKNOWN`、`SOURCE=OFFICIAL_SAS_SERVER_LIST_AND_OVERVIEW|UNKNOWN`、观察时点、固定失败类别、现场查看预算 `0/1` 或 `1/1`。固定失败类别可为 `NONE|PRECHECK_MISSING|LOGIN_STOP|AUTH_FAILED|PAGE_OR_REGION_UNVERIFIED|PERMISSION_MISMATCH|ZERO_OR_MULTIPLE|FIELD_MISSING|ADDRESS_DRIFT|INSTANCE_MISMATCH|PRODUCT_MISMATCH|OTHER_FIXED`。普通证据不存账号、实例 ID、IP、截图、页面全文、凭据、验证码或异常；若受限比对需要这些标识，须在另定接收者与保存边界下进行。已开始授权页面查看后，无论成功失败预算记 1/1，立即退出，不刷新重试或扩大页面范围。

页面是观察时点快照；实例更换、地址漂移、账号权限和缓存/加载状态均可能改变结果，后继不能把一次 `YES` 当永久权威。即使本次将来证明目标绑定，也**不证明服务器 host-key 指纹的独立来源、实际 SSH 端口、guest 服务、SSH/AUTH-107 Phase B、DB 或真实备份权限**。这些门继续关闭；AUTH-99 禁止运行，AUTH-121/122/123 已耗预算不重置。

本轮仅写 `docs-only` 静态候选，未访问 Owner 账号控制台、输入/请求密码或真人识别、触发 UAC、进入远端终端、SSH/DB/备份或重读 `known_hosts`。无运行测试；作者静态检查最多 2 轮，最终 SHA-256 与已用检查预算在交接时单列。不自接受、提交、推送或派发后继。

## Work LEVEL 2 独立结论（2026-09-26）

**ACCEPT，仅轻量应用服务器控制面只读目标绑定的静态候选。** Work 对照 AUTH-24 第 9/13/47 行及阿里云轻量应用服务器官方资料，核对作者候选 SHA-256 `DBBB180BE919D5961ECE64901B6865F367769E6F36AF4ED89B6B47DB463EACFA`（写入本结论前的字节）。候选将未来页面限为官方“服务器列表→唯一服务器概览”，把旧公网地址只当筛选线索，并在账号/地域/唯一实例/现时地址任一无法确认时停止；普通回执不含实例 ID、IP 或页面原文。地域字段在公开文档中的位置未证明，账号主体尚无可用于本次预固定的受限权威；所以现时 `PRECHECK_MISSING`，不能给现场预算。作者静态检查 1/2，通过；本轮无运行测试或账号页面访问。

此接受**不放行登录、密码/真人识别、UAC、控制台列表查看、远端终端、host-key 读取、SSH、AUTH-107 Phase B、DB 或备份**。下一步由 Work 与 Owner 在受限通道明确目标账号主体/地域及现场参与方式，再作单独临运行裁决。Owner 要求遇到密码或可能 UAC 先停；本任务停在该门，旧预算不重置。
