# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-139-BOUNDED-HOST-KEY-DISCOVERY-STATIC-CANDIDATE

Risk Level: LEVEL 3（生产实例连接信任；本阶段仅本地静态候选）

Status: COMPLETED — LEVEL 3 ACCEPT NOT_FIXED ONLY; FIELD EXECUTION 0

Assignee: 最新合资格 Codex 执行会话 `01a0dc31-b629-76a3-85fd-f71566b03056`；交付后停 Work 独立 LEVEL 3 审查。

## 本次目标与授权边界

Owner 指出详情页的 `CodexKey` 并提供客户端 PEM、地址及端口，明确授权尝试 SSH，随后同意尽快按独立主机公钥来源推进。AUTH-138 已接受控制台页面的产品、地域、公私网地址与 Owner 候选一致，详情查看 `1/1` 耗尽；页面 `CodexKey` 是客户端云密钥对名称，不是服务器 host-key。Owner 的 SSH 方向授权不消除首次握手的独立信任门，也不授权作者现在连接。PRODUCT_DECISIONS 已接受仅为准备候选而承担命令助手可能长期留存无秘密脚本/白名单结果的风险，不是现场执行许可。

本任务只在本地准备**一条**绑定该上海唯一轻量实例的命令助手只读发现候选，回答在公钥路径、算法及有效 sshd 端口尚未知时，能否以有限、明确、失败即停的读取取得独立主机密钥来源。若无法收敛为安全精确候选，结果写 `NOT_FIXED`，不得用 Ubuntu 默认路径、旧 `known_hosts`、`ssh-keyscan` 或首次 SSH 指纹补洞。允许在静态设计中提出受限动态解析策略，但须明确输入对象、候选数量上限、拒绝多义性、执行身份、程序身份、完整命令文本、超时/输出限额、白名单投影、脚本与结果在控制台的留存/可见风险及失败停点；不得设计全盘搜索或读取任何私钥、`.env`、DB、业务行、备份。

唯一主要结果：`EVIDENCE/AUTH-139-BOUNDED-HOST-KEY-DISCOVERY-STATIC-CANDIDATE/plan.md`。仅允许新增该文件；本地静态检查最多 2 轮，不运行候选。保留两个无关未跟踪目录，不改产品代码和既有任务证据，不提交、不推送。

## 严格停点

本阶段控制台查看/命令助手、云 API、SSH、真实 DB、dump、传输、恢复、备份、客户端 PEM 读取、UAC/密码/真人识别预算均为 **0**。AUTH-128/136/138 各自页面预算及 AUTH-121/122/123 本机读取预算不重置。作者只交静态候选和 `GO|NOT_FIXED` 判定，不自审、不放行现场；Work 复核后才决定是否向 Owner 提交**精确一次**命令助手现场动作的授权请求。

## 交付与审查

作者已交唯一静态结果 `EVIDENCE/AUTH-139-BOUNDED-HOST-KEY-DISCOVERY-STATIC-CANDIDATE/plan.md`，Work LEVEL 3 仅接受 `NOT_FIXED` 停止结论，未放行现场执行或 SSH。预审仍缺实例技术绑定、执行身份/工具身份、公钥映射与异常输出边界。下一个决策是是否允许另立**更小的受限只读能力发现**任务，明确接受该一步的执行身份/工具路径尚未知和命令助手留存风险；即使 Owner 同意，也须先给精确脚本、单次预算及新 LEVEL 3 临运行门，不能直接运行本候选。
