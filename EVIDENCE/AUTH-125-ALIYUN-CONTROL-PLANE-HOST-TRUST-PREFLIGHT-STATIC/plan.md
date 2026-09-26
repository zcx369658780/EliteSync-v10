# AUTH-125｜阿里云控制面主机信任核验预检（Phase A 静态候选）

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-26；`D:\EliteSync-v10`、本地 `main` HEAD `cc3f72ab54870cdc3996f5496ca6692eb62ce8b0`。任务为 `ISSUED — STATIC CANDIDATE ONLY; NO OWNER LOGIN`，只允许新增本 `plan.md`。既有 `CURRENT.md`、`TASK_CURRENT.md` 修改和两个无关未跟踪目录保留。本文件是将来核验所需问题与停止条件，不是控制台操作许可或可执行现场命令。

## 本地已知与缺口

`EVIDENCE/AUTH-02-ALIYUN-CORRECTED-KEY-SOURCE-IDENTITY/summary.md` 只接受历史一次严格 host-key 检查和客户端私钥 SSH 登录成功；`EVIDENCE/AUTH-17-ALIYUN-DB-BACKUP-HOST-READINESS/summary.md` 只接受历史一次远端工具/空间受限回执，旧 SSH 预算已耗尽。`EVIDENCE/AUTH-107-DUMP-TOOL-READONLY-PROBE-CANDIDATE/plan.md` 仅为静态设计，Phase B 未放行。`EVIDENCE/AUTH-123-LOCAL-FORMAT-RECEIVER-SYNTHETIC-REPAIR/work-review.md` 仅接受单次本机 `INPUT_CR / FORMAT_INVALID` 类别、已检查 0 条、候选 `NO`、端口和信任 `UNKNOWN`；AUTH-121/122/123 各自真实本机读取 1/1 耗尽。`EVIDENCE/AUTH-124-SERVER-HOST-IDENTITY-AND-PORT-TRUST-PATH-STATIC/plan.md` 获 Work LEVEL 2 接受的只是静态信任路径。本机客户端 `sshkey`、阿里云账号登录、历史 SSH 成功和本机 `known_hosts` 均不是现时服务器 host-key 的独立可信来源。

当前缺口分别是：**云账号/地域/实例 ID/现时公网地址的目标绑定**、**服务器 host-key 公有指纹的独立来源及算法/时点**、**guest 内实际 SSH 服务端口**和**对应安全组/主机防火墙准入**。四者均无本目标的当前现场回执；不能默认端口 22、算法、host-key 公钥路径或首次握手指纹可信。控制台是否直接提供精确实例的服务器 host-key 指纹：`UNKNOWN`，不能把未见文档解释成“没有此功能”。

## 公开官方资料的有限支持

下列网页于 **2026-09-26** 匿名只读访问正文，均为阿里云 ECS 当前在线帮助文档；其页面可随时更新，既不是固定版本快照，也不描述本目标实例：

| 官方文档 | 可支持的一般事实 | 不能证明 |
| --- | --- | --- |
| [查看实例ID、实例名称和实例状态等信息](https://help.aliyun.com/zh/ecs/user-guide/view-instance-information) | ECS 控制台有实例概览/详情，可查看实例 ID、状态、可用区及 IP 地址等；未来可用来核对实例绑定。 | Owner 所在账号/地域、本实例 ID、现时公网地址或账号访问权限。 |
| [通过 VNC 连接实例](https://help.aliyun.com/zh/ecs/user-guide/connect-to-a-linux-instance-by-using-a-password) | 官方 VNC 路径可查看实例操作系统界面，文档称其不受安全组设置或实例中运行软件限制；进入 guest 仍涉及相应权限与登录。 | 本实例可用 VNC、已登录 guest、host-key 指纹或实际 SSH 端口；VNC 不等于 SSH host-key 认证。 |
| [执行已有的云助手命令](https://help.aliyun.com/zh/ecs/user-guide/run-a-command) | 云助手可对指定实例执行命令，文档说明执行用户/超时设置；Linux 默认执行用户为 root，普通用户最小权限是推荐方向。 | 本实例 Agent、权限、命令路径与结果，或任何当前执行授权；默认 root 反而要求更严的未来风险门。 |
| [使用安全组](https://help.aliyun.com/zh/ecs/user-guide/manage-security-group-rules) | 安全组规则作用于实例弹性网卡，文档以 22/TCP 为 SSH 常见规则示例，可查看相应网络准入配置。 | 本实例实际安全组、SSH 端口为 22、guest 内 `sshd` 配置/运行监听或主机防火墙状态。 |
| [OpenSSH `ssh(1)`](https://man.openbsd.org/ssh.1)、[`sshd_config(5)`](https://man.openbsd.org/sshd_config.5)、[`ssh-keygen(1)`](https://man.openbsd.org/ssh-keygen.1) | 服务器认证、服务端 HostKey/Port 配置和公钥指纹计算的一般语义；AUTH-124 曾只读核对。 | 阿里云控制台产品界面或本目标主机当前值。 |

公开页面的访问不等于进入 Owner 账号。尝试读取英文 Workbench 文档候选 URL `https://www.alibabacloud.com/help/en/ecs/user-guide/connect-to-a-linux-instance-by-using-workbench` 时只取得页面外壳，浏览器访问报告 `ERR_BLOCKED_BY_CLIENT`；未取得可核对的 Workbench 正文，因此 **Workbench 的具体认证方式、可见字段与本实例可用性均 `UNVERIFIED`**。同样，以上可访问官方资料均未给出“控制台直接展示该实例 host-key 指纹”的可核对依据；对此仍记 `UNKNOWN`，不声称不存在。

## 将来 Owner 控制面核验清单（本轮不执行）

1. **登录前停点。** Work 另立精确现场任务，明确官方入口、允许的页面/对象、Owner 到场、账号与权限、单次预算、审计与退出。Owner 在当前 Work 会话说“我在”只满足到场；登录、密码/真人识别、任何 UAC 或新权限提示之前必须停，取得该任务的具体放行后才由 Owner 处理。不得让 Owner 在聊天里提供密码、验证码、截图、实例 ID、公钥/指纹或原始页面输出。登录失败、页面跳转到非固定入口、权限意外扩大即止。
2. **绑定实例。** 在官方 ECS 实例列表/详情按已锁定账号、地域、实例 ID 与公网地址逐项核对，记录观察时点、实例状态及一致/不一致/UNKNOWN。地址漂移、重建、多个候选或页面未能显示必要字段就停，不靠旧 SSH 地址或首次网络握手选择实例。未来若使用 VNC、云助手或其他控制面功能，必须再次确认操作目标是该同一实例。
3. **独立端口门。** 安全组对应弹性网卡的入方向规则只记 `NETWORK_RULE_CANDIDATE`；即使显示 22/TCP，也不当实际监听端口。将来若需确认有效端口，另立实例内只读观察任务，先固定有效 sshd 配置、运行监听与主机防火墙三个对象及最小输出；同一时点与控制面网络准入交叉核对。任一层未观察或不一致，`PORT_VERIFIED=UNKNOWN/NO`，不试探其他端口。
4. **独立 host-key 门。** 首先只查官方控制面是否对**同一实例**直接提供带算法、指纹、来源/时点的可信服务器 host-key 信息；若页面无此功能、来源不清或只是首次 SSH/Workbench 握手提示，`HOST_KEY_SOURCE_VERIFIED=UNKNOWN`。若需通过 VNC/云助手进入 guest 读取服务器公有 host key，必须先另发高风险现场任务，固定唯一公钥对象、只读命令、执行用户/权限、输出投影、超时/一次预算、审计与失败即停；绝不临场搜索公钥路径、默认算法，或读取私钥、客户端 sshkey、密码和配置全文。云助手默认 root 的文档事实不能被当作使用 root 的许可。任何无法在普通证据外安全处理公有指纹的情况也停。
5. **比对与留存。** 将实例身份、有效端口、算法和独立来源指纹绑定；真正 SSH 握手的指纹只能在后续单独授权流程中与之精确比较。首次握手、`ssh-keyscan`、历史 `known_hosts` 或旧认证成功均不充当独立来源。轮换、算法变化、时点过旧或失配时重新立门，不接受/改写本机 host-key 后继续。

未来 Work 普通证据仅接收：`TARGET_BINDING=YES|NO|UNKNOWN`、`CONTROL_PLANE_SOURCE=OFFICIAL_ECS|UNKNOWN`、观察时点、`VNC/CLOUD_ASSISTANT_AVAILABILITY=YES|NO|UNKNOWN`、`CONSOLE_FINGERPRINT_DISPLAY=YES|NO|UNKNOWN`、`HOST_KEY_SOURCE_VERIFIED=YES|NO|UNKNOWN`、`PORT_VERIFIED=YES|NO|UNKNOWN`、固定失败/退出类别和已用预算。实例 ID、账号、密码、验证码、原始公钥/指纹及命令原文不进普通证据；若确需传递公有指纹供比较，须另定受限接收者、位置和生命周期。登录页可见性、实例绑定、网络规则、guest 服务、host-key 来源分别判定，不因一个 `YES` 代替其他门。

在目标绑定、独立 host-key 来源与有效端口均未闭合之前，**AUTH-107 Phase B、SSH、生产工具、DB 和真实备份继续停止**。本轮未登录阿里云控制台、VNC、Workbench 或云助手，未请求密码/真人识别、触发 UAC、连接服务器、重读 `known_hosts`、运行测试或作备份。AUTH-121/122/123 的 1/1 不重置，AUTH-99 禁止运行。本候选停 Work LEVEL 2 独立审查；不提交、推送、自接受或派发后继。

## Work LEVEL 2 独立结论（2026-09-26）

**ACCEPT，仅公开资料支持的静态控制面预检清单。** Work 核对作者候选 SHA-256 `48923C185017D58E88EF4A186A969970C4E7CBE71DCC9F84016EC75724341D77`（写入本结论前的候选字节）、资料链接/适用边界及 AUTH-124 的实例、端口、host-key 分门。文档对控制台查看实例信息、VNC 和云助手的一般能力作有限表述，对 Workbench 正文不可核验与控制台是否直接显示目标指纹均保留 `UNVERIFIED/UNKNOWN`；安全组示例没有被当作实际端口。作者静态检查 1/2，未运行测试或现场调用。

本接受**不放行阿里云账号登录、密码/真人识别、VNC、云助手、Workbench、SSH、AUTH-107 Phase B、DB 或备份**。后续若要进入控制台，先固定精确页面/实例绑定范围和脱敏回执，由 Owner 在密码/真人识别之前按其暂停要求给出当前现场指令；此前可继续无凭据的静态准备。目标实例、host-key 独立来源和实际端口仍 `UNKNOWN`，AUTH-121/122/123 预算不重置。
