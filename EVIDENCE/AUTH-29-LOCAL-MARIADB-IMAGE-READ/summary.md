# AUTH-29｜本机 MariaDB 镜像只读回执

状态：Codex 候选，待 Work LEVEL 2 独立 ACCEPT/REJECT。查询日期：2026-09-24（Asia/Shanghai）。

## 前置与来源

- 本地 `D:\EliteSync-v10`、`main`；查询前 HEAD `73c804fbe27008deeb5721294766092ff23ce7ce`，父提交 `f1e392d847443daf51508ca7eff9164d8c029e77`，符合任务单派发拓扑。
- 查询前工作区只有原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`，保持原状；本任务仅新增本文件。
- `TASK_CURRENT.md` 为 `AUTH-29-LOCAL-MARIADB-IMAGE-READ`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地工作流技能及 AUTH-27/28 的 Work LEVEL 2 ACCEPT 记录。AUTH-28 只证明其查询时 daemon 可达，本任务重新按依赖顺序核对。

## 固定查询结果

| 顺序 | 项目 | 白名单结果 | 实际调用 |
|---:|---|---|---:|
| 1 | 当前 Docker context 端点类别 | `local_named_pipe` | `docker context inspect` 1/1 次 |
| 2 | 本机 daemon | `reachable` | `docker info` 1/1 次 |
| 3 | 本地精确标签 `mariadb:10.11` | `present` | `docker image inspect mariadb:10.11` 1/1 次 |

三项均按顺序完成，未发生查询异常或依赖失败。原始 stdout/stderr 只在进程内用于归类，未显示或落盘；未记录端点、路径、主机名、证书或 Docker/镜像元数据。没有列出其他镜像、容器、卷或网络，也未访问 registry、拉取或运行镜像。

`present` 仅证明查询时该精确标签有本地镜像，不证明镜像来源可信、实际 MariaDB 版本或与目标备份兼容，也不证明网络隔离、数据保护或恢复能力。下一步若做验证，只能另立虚构数据隔离测试任务，明确负向用例和清理责任；真实备份、解密和恢复均无本任务授权。

验证：`git diff --check` 按预算执行 1/1 次，退出码 0、无输出；该检查不覆盖未跟踪新文档，本文件另作只读尾随空白检查，0 行。未运行产品测试或构建。

未创建、启动或删除容器/VM/卷/镜像，未备份、传输、恢复或改库，也未访问旧仓库、浏览器、SSH、云、数据库、备份目录、凭据或真实数据。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本机固定镜像标签当次存在性的只读事实回执。** Work 核对派发 HEAD `73c804fbe27008deeb5721294766092ff23ce7ce`、唯一候选路径、原候选 25 行、0 行尾随空白及 SHA-256 `F15E6738E0BA31E2B131808AB0BFA8B10A087CCE7DED4C79BC91F58C8287CA28`。独立运行 `git diff --check` 退出 0；该检查不覆盖未跟踪文档，已另查尾随空白。作者报告 context、daemon 和固定标签各查询 1/1 次且顺序通过；Work 未重跑三项查询，原始输出未保留，执行细节依赖作者回执。

接受只证明当次本机 daemon 可达且 `mariadb:10.11` 标签可找到。镜像实际内容、来源、容器隔离、合成恢复及真实数据兼容均未核验；未授权真实备份或恢复。
