# AUTH-155 Phase A｜隔离目标与能力预检命令静态设计

Status: ISSUED — DOCS-ONLY; no runtime preflight. Risk: LEVEL 3. Assignee: latest eligible Codex execution session `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`; Work independently reviews the candidate.

## 唯一交付与允许来源

仅新增或修改本目录 `plan.md`，交付一份**不可在本轮执行**的本机只读预检命令白名单与失败停点。允许只读 `D:\EliteSync-v10` 中的 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、双库交接 `handoff.md`、AUTH-153 的 `task-draft.md`/`plan.md`/`work-review.md`、AUTH-154 的 `plan.md`/`work-review.md`、本目录 `task-draft.md`/`task.md`，及本地 workflow 技能。先核对 cwd/branch/HEAD/dirty；本地 `main` 预期 HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。保留所有既有修改和无关未跟踪目录。当前没有可复用的 AUTH-152/153/154 预算。

Work 提议的仓库外一次性目标候选为 `D:\EliteSync-v10-Restore-Isolation-20260927`。Work 在发单前仅观察到该精确路径不存在、`D:\` 存在，Docker/WSL 命令名可解析、Podman 不可解析。不得把候选当成已审定目标或明文落盘许可，不得创建、枚举或进入该路径。

## 方案必须固定

1. 将后继 Phase B **仅只读本机预检**所需的每条命令/原生命令参数、输入精确路径、最多调用次数、单项 10 秒/总计 2 分钟上限、最大 stdout/stderr 字节、允许字段和错误分类列成表；没有安全只读命令就写 `NOT_FIXED`。不得提出会启动 Docker Desktop/WSL/服务、联网拉取、容器/VM、UAC、扫描目录或读取密文/密钥的命令。不要把命令存在性当成守护进程或隔离能力 PASS。
2. 分别规划精确路径存在/重解析点、父卷文件系统和 ACL 预期清单的核法；对镜像只允许从**已运行**本地 daemon 的至多四个 MariaDB 候选读取有限名称、版本与摘要，摘要缺失或来源无法证明时保持 `NOT_FIXED`。定义 daemon 不可达、自动启动风险、超过四个候选时的失败停点；不得输出其他镜像清单。
3. 区分静态能力、可强制配置与启动后实际证明：无网络/端口/挂载，2 GiB 内存、2 核、128 进程、2 GiB 可写层，镜像默认卷及应用不可连接。本轮全部不得运行；静态命令无法证明的项目写 `UNKNOWN/NOT_TESTED`。若路径 ACL、镜像身份或限额能力无法固定，说明必须先补的最小事实，不得临场扩展观察。
4. 针对 256 MiB 认证前明文暂存，列出 pagefile/转储/锁页/清零的证据需求和只读预检上限；本轮不运行解密或明文程序，不改系统设置。认证失败、超时、超限、截断时消费者必须 0 次/0 字节；本轮只能审查静态设计，不能声称已运行证明。真实私钥密码只能 Owner 非回显输入，任何可能 UAC 的后继步骤须先在当前 Work 会话获 Owner“我在”及具体授权。
5. 明确先后关系：AUTH-155 Phase A 静态计划 → Work LEVEL 3 独立审查 → 另发有界 Phase B 本机只读预检 → 再审真实隔离/认证/恢复方案。即使 Phase B 将来通过，也不授权 AUTH-153 真实解密/恢复、AUTH-154 逐对象审计、账号行读取或生产迁移。导出时独立源清单与无冲突 DDL 仍 `UNKNOWN`。

## 预算、禁止项与停点

最多两轮固定来源静态核对；只写 `plan.md`，记录轮数、差异与 `NOT_RUN`，交付后停 Work 独立 LEVEL 3 审查。不运行计划中的任何本机预检命令，不访问备份/密钥目录或真实 CMS，不运行 Docker/WSL/VM/OpenSSL/DB，不碰 `.env`、旧 `D:\EliteSync`、SSH/云/生产系统，不提交、pull、push 或改任务状态。不得读取真实账号行、哈希值、生日/出生地点值，亦不得将这些写入普通证据。

## Work 发单范围裁决

Work 对 `task-draft.md` 的风险检查指出：其原拟只读现场观察仍缺精确命令、ACL 预期与 Docker 自动启动证明，不能作为运行任务派发。本任务据此缩为静态命令设计；只有候选 `plan.md` 通过独立 LEVEL 3 审查，才可另审是否派发任何现场观察。本裁决不接受未来命令、不授权 Phase B 或真实数据操作。
