# AUTH-130｜轻量服务器 host trust 探针静态停点

**`NOT_FIXED`：未形成可运行的精确无秘密命令候选；停 Work LEVEL 3 独立静态审查。** 2026-09-26，本地 `D:\EliteSync-v10`、`main` HEAD `0a50b1bbd0adc99749245f748790b216864f36f5`。`TASK_CURRENT.md` 状态为 `ISSUED — PHASE A STATIC COMMAND CANDIDATE ONLY; NO CONSOLE EXECUTION`，本轮仅新增本 `plan.md`；既有 `CURRENT.md`、`TASK_CURRENT.md` 修改及两个无关未跟踪目录原状保留。

## 已接受边界与为什么本轮不能给命令

Owner 已指定 AUTH-128 控制台内上海唯一轻量应用服务器为本次备份目标，这是**目标选择**。`EVIDENCE/AUTH-128-LIGHTWEIGHT-SERVER-INSTANCE-BINDING-READONLY/summary.md` 仅接受一次列表/概览受限 UI 观察，`TARGET_BINDING=UNKNOWN`，查看 1/1 耗尽。`EVIDENCE/AUTH-124-SERVER-HOST-IDENTITY-AND-PORT-TRUST-PATH-STATIC/plan.md`、`EVIDENCE/AUTH-127-LIGHTWEIGHT-SERVER-BINDING-VIEW-STATIC-CANDIDATE/plan.md` 与 `EVIDENCE/AUTH-129-FIRST-BACKUP-CONNECTION-TRUST-STATIC-CANDIDATE/plan.md` 的接受只确立分门和静态路径；未固定执行程序、host-key 公钥对象、端口或留存处理。AUTH-02 旧严格 SSH 成功与 AUTH-123 本机 `INPUT_CR` 均不能变成当前独立服务器指纹。AUTH-121/122/123 本机读取各 1/1、AUTH-128 页面查看 1/1 均已耗尽；AUTH-107 Phase B 与真实备份未放行。

2026-09-26 匿名只读核对以下**公开官方资料**，均只能支持一般产品/软件语义：

| 来源 | 可确认 | 不可据此固定的本实例事实 |
| --- | --- | --- |
| 阿里云轻量应用服务器[《执行命令助手命令》](https://help.aliyun.com/zh/simple-application-server/user-guide/use-command-assistant) | 控制台可选择实例、配置执行用户/超时并执行命令；执行记录可查看脚本内容和结果。 | 本实例命令助手/权限可用性、执行用户实际权限、输出留存/访问边界、目标公钥路径与安全投影。脚本和结果可能留存，不能当临时无痕通道。 |
| 阿里云轻量应用服务器[《查看轻量应用服务器信息》](https://help.aliyun.com/zh/simple-application-server/user-guide/view-lightweight-application-server-information) | “服务器”列表/概览可展示实例标识和 IP 等基本字段。 | 本轮不得重开 AUTH-128 页面；文档不能预固定 Owner 指定实例的受保护 ID 或实例内文件。 |
| Ubuntu Server 官方[《OpenSSH server》](https://documentation.ubuntu.com/server/how-to/security/openssh-server/) | 介绍 Ubuntu 的主配置、片段包含与 OpenSSH 服务的一般配置方式。 | 目标实例是否运行 Ubuntu 24.04、实际配置/包含片段、host-key 算法和公钥路径、当前有效端口、正在监听的进程。即使目标版本随后被证实，默认配置也不能代替该实例现时事实。 |
| OpenSSH [`sshd_config(5)`](https://man.openbsd.org/sshd_config.5)、[`ssh-keygen(1)`](https://man.openbsd.org/ssh-keygen.1) | `HostKey`/`Port` 及公钥 SHA-256 指纹计算的一般定义。 | 哪个 host key 当前生效、其唯一绝对公钥路径、实际算法或监听端口。Ubuntu Noble manpages 本轮请求不可达，不据其未核正文作目标判断。 |

**关键输入均 `NOT_FIXED`：**目标实例 ID 的受保护预固定来源；目标 OS/sshd 版本及运行方式；唯一 host-key **公钥**绝对路径和算法；指纹比较所需受控通道；解释器/二进制绝对路径、版本与 SHA-256；执行用户及最小权限；完整只读命令文本/参数及当前服务配置/监听观察对象；命令助手脚本、结果与审计的留存/访问时限；轻量控制面网络准入的独立页面/规则身份。这些不能由默认值、历史 SSH、首次握手或本机 `known_hosts` 补齐。**本文件不含任何拟执行命令，也不提供现场搜索、枚举或换路径办法。**

## 仅供后继固定的一个路径与 GO/NO-GO

保留 AUTH-129 的**同一优先路径**：未来经另立任务，在阿里云轻量应用服务器官方控制面中对 Owner 指定的**唯一实例**使用至多一次命令助手只读核验；不改走 VNC、SSH、云 API 或其他实例。但本次因上述输入不全，`COMMAND_CANDIDATE=NOT_FIXED`、`FIELD_EXECUTION_BUDGET=0`，不能进入临运行审查或页面。Work 若要继续，须在不重耗旧页面/读取预算的独立可信来源下先固定下表，每一行不满足即 `NO-GO`：

| 独立门 | 后继必须预先固定的内容 | 本轮结论 |
| --- | --- | --- |
| 目标与权限 | Owner 指定对象的受保护实例 ID/账号/地域匹配规则、控制面最小权限、当前命令助手可用性及执行用户。 | `NOT_FIXED`；Owner 选择不是技术绑定或执行许可。 |
| host-key | 当前有效 `HostKey` 对应的**一个**公钥绝对路径、算法、文件身份、只读 SHA-256 指纹比较方法；私钥永不读取。 | `NOT_FIXED`；不得猜默认文件或算法。 |
| sshd/端口 | 有效配置解析来源、运行中监听对象及相同端口的轻量网络准入独立回执。 | `NOT_FIXED`；单次命令即使证明配置和监听，也**不能**独自把 `PORT_VERIFIED` 写为 YES，云侧/主机防火墙准入仍需独立只读门。 |
| 程序与输出 | 唯一解释器/可执行文件及依赖身份/哈希、完整无秘密只读脚本、严格白名单输出、退出码/异常分类、双流限额、总超时与回收、控制面脚本/结果留存及访问控制。 | `NOT_FIXED`；若指纹原值或配置全文会被命令助手持久留存而不能获准受限处理，即停。 |

未来普通证据最多包含 `INSTANCE_MATCH`、`PUBLIC_HOST_KEY_SOURCE`、`HOST_KEY_ALGORITHM_CLASS`、`FINGERPRINT_COMPARISON`、`CONFIG_LISTENER_MATCH`、`NETWORK_RULE_MATCH` 各自的 `YES|NO|UNKNOWN`、固定错误类别、时点与预算；不含账号、实例 ID、IP、公钥/指纹原值、端口数字、配置全文、脚本或原始输出。将来若要比较真实公有指纹，必须先明确受控接收者/内存比较方式和命令助手自身留存边界；不能在普通证据或聊天中搬运原值。失配、缺失、非零退出、额外输出、权限/UAC/密码提示、超时或身份变化均失败即停，不重试、不现场更改命令。即使 host-key 与端口门将来通过，也只允许另审 SSH；DB 目标、对象/权限、一致性、服务器侧认证加密、密文传输和隔离恢复仍各有独立门。

未来任何控制面登录、命令助手执行或可能 UAC 的动作都须新的明确任务、独立 LEVEL 3 临运行审查、精确单次预算，并在密码/真人识别/UAC 前按 Owner **当前 Work 会话**到场与具体授权规则停下；“我在”本身不放行。当前没有可运行候选，故不申请现场预算。本轮未打开已登录控制台、真实服务器、SSH/`known_hosts`、DB、密钥或备份正文，也未触发 UAC/密码、运行测试、提交或推送。作者最多两轮文档静态检查，最终哈希和实际检查数在交接时单列。

## Work LEVEL 3 独立静态审查（2026-09-26）

**ACCEPT 仅 `NOT_FIXED` 停止结论；REJECT 任何现场执行或首次备份放行。** Work 核对作者候选 SHA-256 `7F14BE6C89683D93BDDC1D25062CC1E4ACB7C9875F92D1EF7E8A1CDCF5FC3FFA`（本结论写入前）、AUTH-128/129 边界、当前任务及工作区。候选明确没有可运行命令，也没有从一般 Ubuntu/OpenSSH 默认值猜本机实际 host-key 或端口；作者静态检查 1/2 PASS，无现场测试。AUTH-128 概览曾显示 Ubuntu 24.04，故上表“目标实例是否运行 Ubuntu 24.04”应精确理解为**概览的镜像标签已观察、实例内实际 OS/sshd 运行状态未证明**；这项措辞不影响 `NOT_FIXED` 结论。

若要继续，先由新任务审查一条固定、失败即停、只读的运行中配置/公钥来源发现方式及命令助手留存/访问边界；该方式是否允许须经具体高风险门。没有这项独立来源时，服务器指纹和有效端口仍 `UNKNOWN`，不得 SSH、查询真实 DB 或启动 dump。Owner 的目标指定及一般“继续”授权不重置旧预算，也不构成现场命令或生产备份批准。
