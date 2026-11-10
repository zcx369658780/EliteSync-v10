# AUTH-46｜本机加密备份目标只读准备回执

状态：**固定目录与 ACL 检查通过，部分工具/设备状态未决；待 Work LEVEL 2 独立 ACCEPT/REJECT**。观察日期：2026-09-24（Asia/Shanghai）。这不是备份或目标安全性的完整验收。

## 前置与固定范围

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `1032946627076e69e8e16ed3f2d1d450ca289f9d`，父提交 `803706d3ebe2ae6129bee2cebb8d82e977dcafba`，符合任务单。工作区只有原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`，保持原状；仅新增本文件。
- `TASK_CURRENT.md` 为 `AUTH-46-LOCAL-BACKUP-DESTINATION-READINESS`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对项目入口、产品决定、风险门、本地工作流技能及 AUTH-25、AUTH-26、AUTH-45 回执。固定目标仅为 `C:\Users\zcxve\EliteSync-v10-DB-Backups`；未读取其中任何文件内容或名称。

## 一次只读查询结果

| 项目 | 受限结果 | 查询次数 |
|---|---|---:|
| 目标路径规范化及对象类型 | 与精确绝对路径一致；普通目录存在 | 目标 1 |
| 目标及其父目录重解析点 | 均为否 | 父目录 1；目标属性随目标查询 |
| 目录是否为空 | **是** | 1 |
| ACL 继承 | 关闭 | 1 |
| ACL Allow 主体及权限 | 仅当前 Windows 用户、SYSTEM、Administrators；三类均为 FullControl | 随 ACL 1 |
| ACL Deny 或其他主体 | 均无 | 随 ACL 1 |
| C 盘当次可用空间 | **649684254720 bytes** | 1 |
| `openssl` | 可解析；版本 **3.5.6** | 命令查询 1、版本 1 |
| `gpg` | 可解析；版本 **UNKNOWN** | 命令查询 1、版本 1 |
| `ssh` | 可解析；版本 **9.5p2** | 命令查询 1、版本 1 |
| C 盘 BitLocker 保护状态 | **UNKNOWN** | 1 |
| 固定目标是否位于系统报告的 OneDrive 根路径下 | **UNKNOWN** | 根路径读取/前缀判断 1 |

目录和权限的布尔结果只覆盖该路径在本次查询时的对象与 ACL。`gpg` 版本在唯一一次版本输出的受限解析中未得到可用值；BitLocker 查询未形成 `ON/OFF` 结果；OneDrive 根路径未形成可判断的前缀布尔。三项保持 `UNKNOWN`，没有替代方法或重试。按表内顺序，**首个实际未决项是 `GPG_VERSION_UNKNOWN`**。本次内存汇总器的自动 `first_failure` 字段误报 `path_exact`，与同一输出中的 `path_exact=true` 矛盾；该字段不作为事实，以上述逐项结果为准。

验证：`git diff --check` 按预算执行 **1/1 次**，退出码 0；它不覆盖未跟踪新文件，本文件另作只读尾随空白检查，0 行。无产品测试、容器或数据库动作。

没有读取备份内容、真实凭据、密码、密钥或数据库；没有改目录、ACL、工具配置或设备保护状态。目录为空及 OneDrive 前缀状态不能证明不存在其他自动同步；工具可解析不证明安全加密方案可实施。没有生成、传输、恢复或删除任何备份。本回执不证明完整加密备份、磁盘故障恢复或真实数据库身份。作者不提交、制作 bundle、推送、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受固定本地路径、ACL、空目录、可用空间及工具解析的受限事实；完整目标安全性仍未验收。** Work 核对派发 HEAD `1032946627076e69e8e16ed3f2d1d450ca289f9d`、父提交 `803706d3ebe2ae6129bee2cebb8d82e977dcafba`，候选仅本文件；审查前 SHA-256 `72590F41233112F4D554B52FAF4EF0A06ECE65D83442F9B761617F0D09A8F8E2`，尾随空白 0 行，`git diff --check` 退出 0。Work 另只读核对目录仍为空、ACL 继承关闭且只有当前用户、SYSTEM、Administrators 显式 FullControl；未重跑作者的固定工具/设备查询。

作者回执报告 C 盘可用 649684254720 bytes、OpenSSL 3.5.6、SSH 9.5p2；GPG 版本、BitLocker 和 OneDrive 前缀均为 `UNKNOWN`。自动 `first_failure=path_exact` 与 `path_exact=true` 矛盾，Work 不接受该字段，采用作者已明确更正的逐项结果。未核验其他自动同步软件或完整加密/传输方案，不得据此开始真实备份、解密或恢复。
