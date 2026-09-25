# AUTH-51｜服务器 OpenSSL CMS 工具能力只读回执

状态：**作者受限观察；目标未完整达成，待 Work LEVEL 2 独立 ACCEPT/REJECT**。日期：2026-09-24（Asia/Shanghai）。

## 入口与预算

- 本地 `D:\EliteSync-v10`、`main`，执行前 HEAD `6e37681a8eb95d016c43248327f8cf0578c2ab97`。任务 `AUTH-51-SERVER-OPENSSL-CMS-CAPABILITY-READONLY` 为 `ISSUED — NOT STARTED`、指派 Codex、LEVEL 2；本会话从 SSH 预算 **0/1** 起步。
- 工作区起初仅有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`，保留原状。已读项目入口、产品决定、任务、风险门、本地工作流技能及 AUTH-49、AUTH-50 回执。本任务只新增本文件。
- 对任务指定的服务器、用户、私钥与既有 `known_hosts` 发起 SSH **1/1 次**；使用 `BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`。SSH 退出码 **0**。未重试、换入口或补查。

## 一次连接的受限结果

| 阶段 | 状态 | 脱敏事实 |
|---|---|---|
| SSH 连接 | PASS | 退出码 0。 |
| `openssl` 解析 | PASS | `command -v` 退出码 0；未保留解析路径。 |
| `openssl version` | FAIL（版本值未取得） | 命令退出码 0；本地版本格式过滤未接受返回字符串，版本记为 `UNKNOWN`。原始字符串未保存，不能补判。 |
| `openssl cms -help` | PASS（静态线索） | 命令退出码 0；帮助文本已丢弃，未保存。 |
| `openssl list -cipher-algorithms` | FAIL（能力判定未解决） | 命令退出码 0；本次只做区分大小写的 `AES-256-GCM` 字面匹配，结果布尔值为 `false`。这不足以判断算法是否列出，实际支持状态 `UNKNOWN`。完整列表未保存。 |

首个未达目标阶段为 **版本值提取**。远端四项查询各执行至多一次，命令本身均未报告异常；后两项已在同一次固定 shell 查询中执行。本地整理发现版本过滤和大小写匹配不足后，没有再次连接或增加探测命令。

## 限制与停点

本次仅确认指定连接当时可解析 OpenSSL，且 `version`、`cms -help`、`list -cipher-algorithms` 调用退出 0。服务器 OpenSSL 版本、AES-256-GCM 是否列出、CMS AES-256-GCM 端到端可用性、与本机密文互通、真实备份及恢复能力均未建立。`false` 不是算法不存在的证明。

未读取数据库、备份、密钥内容、环境变量或服务器文件；未运行加解密、密钥生成、文件写入、服务重启、Laravel、云 API、真实数据传输或恢复。未触碰本机备份/密钥目录内容及无关未跟踪目录。本任务不提交、制作 bundle、推送、自接受或派发后继。SSH 预算已耗尽，停在 **Work LEVEL 2 独立 ACCEPT/REJECT** 门；任何补测须新任务授权。

## 本地验证

`git diff --check` 按预算执行 **1/1 次**，退出码 0；该命令不覆盖未跟踪的新文件。本文件另作只读尾随空白检查，**0 行**。

## Work 独立审查（2026-09-25）

**LEVEL 2 REJECT — 服务器 OpenSSL 版本及 AES-256-GCM 算法列出情况未核定，完整工具能力目标未达成。** 仅接受一次受限连接的作者事实回执：SSH 退出 0、`openssl` 可解析，`openssl version`、`openssl cms -help`、`openssl list -cipher-algorithms` 各退出 0。`cms -help` 退出 0 只是帮助命令可调用的静态线索，不证明 CMS GCM 加解密可用。

Work 独立核对本地 `main` HEAD `6e37681a8eb95d016c43248327f8cf0578c2ab97`、任务单、候选路径与工作区；候选仅本文件，另有必须保留的无关未跟踪目录。审查前本文件 SHA-256 为 `309E2631E92371C7F4D1C2A751615BEAE4004D7FBF5A27B25A69A729C572DCEC`，独立只读尾随空白检查为 0 行。作者报告 `git diff --check` 已按预算执行 1/1 次且退出 0；Work 未重复该命令。跨盘既有 Git bundle 的 SHA-256 与交接值 `780CC799DDE26EF8DA48B8B9BFC43BED187653AC098B9FA82D5E25C592652EF9` 一致，`git bundle verify` 报告完整历史；它只覆盖原 HEAD，不含本候选。

版本本地过滤未取得值，算法检查仅做区分大小写字面匹配，且原始输出未保存，因此版本和 AES-256-GCM 是否列出均为 `UNKNOWN`，无法事后补判。SSH 调用与未执行禁止项依赖作者回执，Work 未连接服务器或独立复现远端命令。服务器与本机 CMS 密文互通、真实备份和恢复能力仍未建立。本任务 SSH 预算 **1/1 已耗尽**；如需补测，必须另立有界任务，不重用本任务连接。
