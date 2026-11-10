# AUTH-47｜本机虚构 CMS 加密预检回执

状态：**一次性虚构证书生成失败，CMS/GCM 目标未执行；待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行日期：2026-09-24（Asia/Shanghai）。本任务一次运行预算已耗尽。

## 前置与候选

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `eb68c487a93fa013d7ea51a7ccfaeb73d0a6f1a2`，父提交 `4621f2a4afb15b3adc1473841d915e6b20fb5343`，符合任务单。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。仅新增本目录的 `run.ps1` 与本文件。
- `TASK_CURRENT.md` 为 `AUTH-47-LOCAL-SYNTHETIC-CMS-ENCRYPTION-PREFLIGHT`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对项目入口、产品决定、风险门、本地工作流技能及 AUTH-25、AUTH-45～46 回执；旧任务预算未重置。
- 新脚本 PowerShell 静态解析 0 错误。静态核对固定 Windows 绝对临时路径、当前用户 Temp 父目录、递归清理前的规范化绝对路径及非重解析点门；全部候选资产路径只在该临时目录内，备份专用目录仅做只读空目录核对。静态检查后执行 **1/1 次**。

## 一次执行回执

| 阶段 | 作者脚本结果 | 调用次数 |
|---|---|---:|
| 本机 OpenSSL 可解析、版本 3.x；Temp 父目录与目标不存在；备份专用目录为空 | `PASS`；OpenSSL **3.5.6** | 各 1 |
| 创建固定虚构临时目录 | `PASS` | 1 |
| 生成一次性无密码虚构 RSA 3072 私钥及自签证书 | **`FAIL`**；进程退出码 **1** | 1 |
| 固定输入、CMS AES-256-GCM 加密、正常解密、单字节篡改、篡改解密 | 均 `NOT_CHECKED` | 各 0 |
| 结束时备份专用目录再次核对 | `NOT_CHECKED` | 0 |
| 固定临时目录精确递归清理、核对不存在 | `PASS` | 删除 1、核对 1 |

最早失败 `CERTIFICATE_FAILED`；总耗时 **1 秒**，低于 120 秒上限。原始 OpenSSL stdout/stderr 未保存，证书失败的具体原因 `UNKNOWN`。密文长度、原文匹配和篡改拒绝均 `NOT_CHECKED`；不能据此判断 CMS AES-256-GCM 是否受支持。固定备份目录在预检时报告为空，失败后未再次查询，因此不把末次状态写成已验证。

验证：`git diff --check` 按预算执行 **1/1 次**，退出码 0；它不覆盖未跟踪新文件，两个新文件另作只读尾随空白检查，均为 0 行。无需产品测试、Docker 或真实数据库动作。

本次未生成真实备份密钥、未要求 Owner 密码、未运行加密/解密或接触备份文件、真实凭据、数据库及业务数据。未修改备份专用目录、ACL、旧证据或控制文件。脚本不修改、不换算法/参数、不重跑；不提交、制作 bundle、推送、自接受或派发后继。候选停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Work 独立审查（2026-09-24）

**LEVEL 2 REJECT — CMS AES-256-GCM 加密/解密及篡改拒绝目标均未执行；仅接受虚构证书生成失败和清理的受限事实回执。** Work 核对派发 HEAD `eb68c487a93fa013d7ea51a7ccfaeb73d0a6f1a2`、父提交 `4621f2a4afb15b3adc1473841d915e6b20fb5343`，候选仅本目录 `run.ps1`、`summary.md`。审查时脚本 SHA-256 `A64C13D1DEA0CE5FEC51B9F68E444DAD9288ADB703E2344295596DBF18A070F6`，摘要审查前 SHA-256 `41B73440FF07EFE61D162587BE99046633B6364E8AF2BB8991E07940FDA99500`；脚本 PowerShell 静态解析 0 错误，两文件尾随空白 0 行。Work 未重跑脚本。

脚本静态限定固定 Temp 路径、非重解析点、只创建虚构测试材料、失败即停和删除前的绝对路径核对。作者一次运行报告前置 PASS，证书生成退出 1，后续加密/解密调用均 0，固定临时目录清理 PASS；原始 OpenSSL 错误未保存，失败原因 UNKNOWN。Work 另只读确认固定临时目录不存在、备份专用目录仍为空。此回执不能判定 CMS GCM 支持情况，也不授权换参数后复用旧预算；后继须新任务。
