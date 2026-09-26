# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-128-LIGHTWEIGHT-SERVER-INSTANCE-BINDING-READONLY

Risk Level: LEVEL 2（Owner 在场的阿里云轻量应用服务器控制台只读查看）

Status: COMPLETED — WORK LEVEL 2 LIMITED ACCEPT OF UI OBSERVATION; TARGET_BINDING UNKNOWN; VIEW 1/1 EXHAUSTED

Assignee: Work 本会话，Owner 本人只处理登录密码/真人识别；Codex 会话 `01a0dc31-b629-76a3-85fd-f71566b03056` 不派发本任务现场动作。

## 授权与依据

AUTH-127 的静态候选获 Work LEVEL 2 ACCEPT，仅限阿里云轻量应用服务器“服务器列表→唯一服务器概览”。Owner 在当前 Work 会话确认与 AUTH-24 同一阿里云账号、华东2（上海）轻量应用服务器，且本人在场，明确授权本人亲自处理登录后**只读查看一次**该两级页面。Owner 先前要求遇密码、真人识别或可能 UAC 停下；本任务将登录动作完全交给 Owner，Work 不输入、观察、转述或保存凭据。

本任务唯一主要结果为 `EVIDENCE/AUTH-128-LIGHTWEIGHT-SERVER-INSTANCE-BINDING-READONLY/summary.md`；仅写脱敏状态、观察时点、预算和 Work LEVEL 2 结论。原始页面、截图、账号/实例 ID、公网 IP、密码、验证码和任何密钥不得写入普通证据或聊天。保留两个无关未跟踪目录。

本次执行后的有限结论：官方轻量应用服务器上海列表和唯一概览中的地域、地址一致，现时地址与历史线索相符；因未预先独立固定实例 ID，`TARGET_BINDING=UNKNOWN`，仅接受 UI 观察事实。`VIEW_BUDGET=1/1`，不得重看或重试。见本任务 `summary.md`；后继须另立独立来源与风险门。

## 本次单次流程与停点

1. 启动前核对本地 Git/工作区、AUTH-24/127、固定官方资料 URL 和本任务；入口仅 `https://swasnext.console.aliyun.com/servers/`。只使用一个浏览器页/会话，打开后控制台查看预算计 1/1；不刷新、重试、新开账号页或改走 ECS/RDS。
2. 若需登录，**停在登录/密码/真人识别前**，仅由 Owner 在本机自行完成；Work 不自动操作认证控件、不读取凭据或验证码。登录失败、非预期域/权限提示、需要 UAC、账号或地域与 Owner 确认不符即停。Owner 完成后只凭其明确“已登录”继续同一页，先重新观察。
3. 仅在阿里云轻量应用服务器“服务器”列表观察产品类别、账号/地域可核验性、唯一候选和现时地址与 AUTH-02 历史地址线索是否匹配；若页面提供精确筛选，只用该预定线索，不广泛枚举服务器。最多进入唯一候选“服务器概览”的基本信息，然后退出。缺字段、多个候选、地址漂移、地域不能独立确认、页面变化或 Owner 不确认目标，记录 `UNKNOWN/NO` 并停，不点击其他页面或操作。
4. 普通回执只含 `TARGET_BINDING=YES|NO|UNKNOWN`、`PRODUCT_CLASS=LIGHTWEIGHT_APPLICATION_SERVER|UNKNOWN`、`SOURCE=OFFICIAL_SAS_SERVER_LIST_AND_OVERVIEW|UNKNOWN`、固定失败类别、观察时点和 `VIEW_BUDGET=1/1`。即使匹配，也只证明这次 UI 的目标绑定，不证明独立 host-key、实际 SSH 端口、SSH/DB 或备份可用。

## 禁止

不得点击远程连接、命令助手、VNC/Workbench、重置密码、编辑配置/防火墙、安装 Agent、创建/导出、购买或任何写入；不得 SSH、远端命令、DB、备份、重读 known_hosts、触发/处理 UAC。AUTH-121/122/123 旧预算不重置；AUTH-107 Phase B 和真实数据库备份均未放行。任何异常失败即停，不复用本次 1/1。
