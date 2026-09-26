# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-112-SSH-REMOTE-EXIT-PROVENANCE-STATIC-CONTRACT

Risk Level: LEVEL 2（未来只读主机回执的传输与远端退出来源；本轮仅公开文档和本地静态合同）

Status: ACCEPTED — STATIC CONTRACT ONLY; NO SSH OR REAL TOOL

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-109～111 仅接受本地虚构采集/解析。AUTH-110 解析器接收调用方分别提供的 SSH 与远端退出候选；AUTH-111 正确保留后者 `UNVERIFIED_CALLER_CANDIDATE`。在真实 SSH 运行中，不能凭同一个本地进程退出码虚构两个独立实测退出码。先核对公开、权威的 OpenSSH `ssh(1)` 退出语义，再给未来单次只读主机观察提出可审查的最小协议和失败停点。本轮不生成可运行 SSH 调用器，不访问目标主机。

主要结果仅为新目录 `EVIDENCE/AUTH-112-SSH-REMOTE-EXIT-PROVENANCE-STATIC-CONTRACT/contract.md`；只允许写该文件。AUTH-107～111、控制文件和源码只读；保留两处原有无关未跟踪目录。

## 允许工作与预算

1. 核对本地 Git/工作区、五份入口、AUTH-107～111、项目技能与风险门。可只读查阅公开 OpenSSH 官方手册及必要的已保存本地证据，并给出可复核 URL/节名；不得读取 `.env`、凭据、私钥、真实业务行、备份或旧 `D:\EliteSync`。
2. 区分 SSH 本地进程退出、远端程序退出、远端工具的两次退出与 JSON 自报状态；说明哪些可由当前本地接口直接观测、哪些是协议声明、哪些必须经目标主机/程序身份和固定字节另证。处理 SSH 255、远端命令也可能返回 255、连接中断、半行/多行、stderr、JSON 成功但进程非零以及进程零但 JSON 失败的歧义；禁止把它们归成成功。
3. 给出**一种**最小、失败即停的未来候选协议：最多一行 2 KiB 固定 JSON、工具原文只在远端受控内存、远端程序如何把两次工具退出安全投影到 JSON、本地 SSH 退出与完整性如何联合判定。明确 AUTH-110/111 哪些字段或前置门需要另立实现任务调整；不在本任务改代码、重置旧预算或自称可现场运行。列出目标身份、host-key、远端程序固定字节、工具路径/别名/哈希、环境净化和本地采集启动阻塞等未解决门。
4. 静态核对最多 2 轮；无虚构子进程测试预算。若官方来源不可用，标 `SOURCE_UNAVAILABLE` 并基于已保存事实保留 `UNKNOWN`，不得猜测 SSH 语义。禁止 SSH、真实工具/DB、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。交候选后停在 Work LEVEL 2 独立审查，不提交、推送、自接受或派发后继。

## 停点

AUTH-107 Phase B 未放行；AUTH-101、AUTH-17、AUTH-107 已耗预算不重置，AUTH-99 禁止运行。Owner 已决定本次只备份数据库，排除数据库外上传文件；数据库内部对象全集仍 UNKNOWN。真实备份仍须目标、权限、内部对象范围、一致性、加密传输和隔离恢复前置门及 Owner LEVEL 3 单次授权。可能触发 UAC 的后继步骤须先等 Owner 在**当前 Work 会话**输入“我在”；旧到场确认不沿用。

Work 已在 `EVIDENCE/AUTH-112-SSH-REMOTE-EXIT-PROVENANCE-STATIC-CONTRACT/contract.md` 作 LEVEL 2 受限 ACCEPT：仅静态协议和公开 `ssh(1)` 退出语义，不能用于现场调用。本任务不再处于 ISSUED；AUTH-110/111 若按合同修订，须新任务和独立虚构验证。
