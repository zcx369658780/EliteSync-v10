# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-118-HOST-LOCATOR-READONLY-CALL-STATIC-CANDIDATE

Risk Level: LEVEL 2（生产主机定位调用边界；本轮仅本地静态候选）

Status: ACCEPTED — LOCAL STATIC CONTRACT ONLY; NO SSH

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-117 仅接受历史身份和定位缺口的静态清单。现时 host-key 可信来源、远端解释器、受控程序部署/启动及 dump 工具绝对路径均 `UNKNOWN`。为后续可能的一次现场只读定位准备可独立审查的最小调用合同和固定脱敏回执；本任务不寻找、猜测或执行现场路径，也不放行 AUTH-107 Phase B。

唯一主要结果为 `EVIDENCE/AUTH-118-HOST-LOCATOR-READONLY-CALL-STATIC-CANDIDATE/plan.md`；仅允许新建并写该文件。其余项目文件与证据只读，保留两个无关未跟踪目录。

## 允许工作与预算

1. 核对本地 Git/工作区、五份入口、项目技能和 AUTH-02、AUTH-17、AUTH-107、AUTH-112～117 的已接受脱敏证据。不得读取 `.env`、凭据、私钥、`known_hosts` 正文、真实业务行、备份或旧 `D:\EliteSync`。
2. 写一份**不可直接执行**的单次只读定位调用合同：列明未来任务必须先固定的主机/SSH 身份、独立可信 host-key 指纹及来源、远端 shell/启动解释器、允许的只读定位动作与参数、环境净化、输出上限、超时、退出分类和失败即停条件。对当前未有可信来源的字段明确写 `UNKNOWN`；不得提供含真实主机/用户/密钥路径的完整 SSH 命令、远端脚本或自动探测逻辑。
3. 设计固定脱敏回执字段与负向分类，确保原始路径、帮助文本、环境值、业务数据、凭据和 host-key 内容不进入普通证据；说明何种最少结果才足以让 Work 判断下一独立任务，而不把“找到了路径”误作二进制身份或数据库权限证明。明确本地 `argv` 不保证远端 shell 安全；不能把 AUTH-115 本机程序当作已部署。
4. 静态自检最多 2 轮；无测试运行、SSH、远端程序、真实工具或 DB 预算。禁止生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML、删除、提交或推送。候选完成后停在 Work LEVEL 2 审查，不自接受或派发后继。

## 停点

Owner 暂时离开；任何可能触发 UAC 或需要输入密码的动作必须停下，待 Owner 在当前 Work 会话重新输入“我在”后再按具体任务风险门裁决。本任务不包含此类动作。AUTH-17/101/107 等一次预算不重置，AUTH-99 禁止运行。AUTH-107 Phase B、真实 SSH/DB/备份与恢复仍未放行；真实数据库备份须另经 Owner LEVEL 3 单次授权。

Work 已在 `EVIDENCE/AUTH-118-HOST-LOCATOR-READONLY-CALL-STATIC-CANDIDATE/plan.md` 作 LEVEL 2 受限 ACCEPT，仅限静态合同与脱敏回执边界；本任务不再 ISSUED。可信 host-key 来源、远端启动和精确工具路径仍 `UNKNOWN`，无现场调用授权。
