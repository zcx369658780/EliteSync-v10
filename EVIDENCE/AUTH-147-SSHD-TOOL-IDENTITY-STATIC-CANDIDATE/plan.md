# AUTH-147｜sshd 与观察工具路径身份候选（Phase A）

**作者结论：`STATIC_CANDIDATE_FOR_REVIEW`；现场仍 `NO-GO`，待 Work LEVEL 3 与 Owner 对新输出范围作具体裁决。** 本地 `D:\EliteSync-v10`、`main`，起点 HEAD `a4edf970daba90de4519d3c8135fad3692f34f68`；唯一新增结果是本文件。现场预算 `0`，本轮未运行 Shell、`sshd`、`systemctl`、SSH 或 DB。

AUTH-139 Work LEVEL 3 仅接受完整 host-key 发现 `NOT_FIXED`。AUTH-140 的短探针经后续 Owner 单次手动提交，AUTH-144 只接受命令记录“执行完成”；AUTH-146 的唯一详情回执才确认当次命令助手 Shell 退出 0，白名单为 `UID=ROOT`、`SSHD/SYSTEMCTL/SERVICE=YES`。这三个 `YES` **只表示当时名称可定位**，不是可执行文件的字节身份、服务运行状态、配置、公钥或端口。AUTH-140/142/144/145/146 各自已耗预算不重置；此前针对 AUTH-140 的 root 例外不自动授权本候选。

## 一份完整的只读候选文本

拟议解释器为阿里云命令助手的 **Linux Shell**，执行用户拟显式设为 `root`，与 AUTH-146 当次环境保持同一类别；此项需 Owner 对**新的一次调用**单独确认。脚本只使用 POSIX Shell 的 `command -v`、`case`、参数展开和 `printf`；**不执行** `sshd`、`systemctl`、`service`，也不调用 `stat`、`readlink` 或外部 `test`。不读取 sshd 配置、公钥/私钥、监听/端口、`.env`、DB、业务文件或客户端 PEM，不创建/修改普通文件，不提权、不改环境或 PATH。`/dev/null` 仅为丢弃错误输出的特殊设备，不留普通文件。

```sh
exec 2>/dev/null || exit 3
probe() {
  p=$(command -v "$1" 2>/dev/null) || return 1
  case "$p" in /*) ;; *) return 2 ;; esac
  case "$p" in /) return 2 ;; esac
  case "$p" in *[!ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_./-]*|*..*) return 2 ;; esac
  n=${#p}
  case "$n" in [1-9]|[1-9][0-9]|1[01][0-9]|120) ;; *) return 2 ;; esac
  printf '%s' "$p"
}
s=$(probe sshd) || { printf 'AUTH147=ERR_SSHD\n'; exit 2; }
t=$(probe systemctl) || { printf 'AUTH147=ERR_SYSTEMCTL\n'; exit 2; }
v=$(probe service) || { printf 'AUTH147=ERR_SERVICE\n'; exit 2; }
printf 'AUTH147=OK SSHD=%s SYSTEMCTL=%s SERVICE=%s\n' "$s" "$t" "$v"
```

`command -v` 只询问当前 Shell 的名称解析；返回值必须呈**绝对路径**、仅含受限 ASCII 字符、总长 2～120 字符，才产生结果。Shell 函数、内建、单独的 `/` 或相对命令被拒；三个候选须全部通过才有一行 `AUTH147=OK`，不会先输出部分路径。成功 stdout 的唯一模式是 `AUTH147=OK SSHD=/[A-Za-z0-9_./-]{1,119} SYSTEMCTL=/[A-Za-z0-9_./-]{1,119} SERVICE=/[A-Za-z0-9_./-]{1,119}`，且每个路径不得含 `..`；整行最多 420 字节，退出 0。任一查询/形态不符，只允许一行固定 `AUTH147=ERR_SSHD|ERR_SYSTEMCTL|ERR_SERVICE`，退出 2。最初 stderr 重定向失败拟退出 3，但平台或 Shell 可能先写非白名单错误；按异常停止。正常 stderr 应为空；任何非零、超时、额外/畸形输出或平台错误都不用于推断某工具绝对不存在。

这给出**受限字符/长度的绝对路径形态候选**，比 AUTH-146 的 `YES` 有实际增量；但没有 `test`、`readlink`、`stat` 或哈希工具的受审身份，**不能证明路径确为普通可执行文件、链接最终目标、文件字节哈希、进程正在运行、配置/公钥来源、监听端口或工具可信**。输出只是当前名称解析候选，不能称已验证的二进制身份。运行环境或 PATH 与 AUTH-146 不同也可能使结果变化，届时只接受当次事实，不追认旧回执。

## 受控接收、留存与 UI 硬门

**新增风险点：结果会包含三个程序路径原值。** 路径不是凭据，但不属于此前 AUTH-140 的纯类别输出。拟议唯一接收通道为 Owner/Work 当前已认证的阿里云轻量实例**命令助手详情页**，只在该受保护会话中临时阅读，并与该实例/本次命令记录绑定；普通聊天、Git、`EVIDENCE/` 和截图**不得复制路径原值**。控制面可能长期留存脚本、路径结果和审计副本，实际可见者/期限未知；此前 Owner 对“无秘密脚本及严格类别结果”留存的接受**不自动覆盖路径原值**。Work 必须先将这个增量风险和接收/留存边界交 Owner 作具体决定；不同意或不能限定可见者/读取方式即 `NO-GO`。若后继需要把原值带出控制面，应另立受保护材料与权限/期限门，本文件不授权导出。

未来临运行候选参数：只对 Owner 指定的上海唯一轻量应用服务器，Work 在新授权范围内核对当前命令助手所选对象与 AUTH-138/144/146 的受保护目标一致；命令类型 Linux Shell，显式用户 `root`，超时 **10 秒**，命令参数/模板功能关闭，完整替换编辑器内容为上述代码块原始字节，不附加命令、不改变执行路径或环境变量。控制面出现默认额外脚本、路径/用户/目标不一致、登录/权限/密码/真人识别/UAC 提示或无法核对脚本字节时，触发前停。stdout 预期单行 ASCII、最多 **420 字节**，stderr 预期空；端到端等待上限 **30 秒**。这些是未来临运行门，**不是本轮已验证的平台限额或现场预算**。若平台不能确认/维持该边界，`NO-GO`。

公开来源：POSIX [`command`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/command.html) 的 `-v` 名称解析与 Shell 参数展开的一般语义；阿里云[《执行命令助手命令》](https://help.aliyun.com/zh/simple-application-server/user-guide/use-command-assistant)说明执行用户、超时和可查看的脚本/结果。它们不证明本实例的程序身份、输出一定不会被平台包装或长留存访问范围。

下一次现场动作**须新任务**固定这份脚本的 SHA-256、目标与 UI 参数，由 Work 独立 LEVEL 3 临运行审查，并经 Owner 对本次显式 root、可能长期留存的**路径原值**及**最多一次**执行单独授权；点击即新预算 1/1，失败即停，不重试、不换路径/脚本/实例，不转 SSH。当前 AUTH-147 现场预算 **0**。AUTH-128/136/138 页面、AUTH-121/122/123 本机读取以及 AUTH-144/145/146 现场预算均不重置。此结果不放行 sshd 测试模式、服务管理工具执行、SSH、真实 DB、dump 或备份；独立 host-key 信任锚与有效端口仍 `UNKNOWN`。作者最多两轮本地静态/虚构检查，报告文件 SHA-256 和实际范围后停 Work LEVEL 3，不自接受、不派发后继、不提交或推送。

## Work LEVEL 3 独立静态审查

Work 核对作者交付前 SHA-256 `FACEBEE2CC7A53B5E17398DBF669905627AD6F80011758F013BFB2933D3AC32D`、当前任务、AUTH-139/140/146 受限结论和唯一新增路径。静态逐行检查：`probe` 仅用 Shell 名称解析、形态/长度过滤和输出；不会调用三个被查询工具，不读 sshd 配置、密钥、监听或 DB。脚本能给出**当前 Shell 的受限绝对路径字符串候选**，不能证明普通可执行文件、链接目标、字节身份、服务运行或服务器信任。作者报告两轮静态检查；Work 未运行候选或现场测试。

**ACCEPT 仅 Phase A 路径形态候选；现场 `NO-GO`。** 原始工具路径可能进入命令助手长期留存的结果，超出 Owner 此前对纯类别输出的风险接受；Owner 对此新增范围、显式 root 及一次现场调用须另作具体决定。即使 Owner 同意，还须新任务复核控制面目标、脚本字节、输出和失败边界，再作 Work LEVEL 3 临运行裁决。`TARGET_BINDING`、host-key 信任锚、有效 SSH 端口及 DB 结构均未因此改变；本任务现场预算 0。
