# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-125-ALIYUN-CONTROL-PLANE-HOST-TRUST-PREFLIGHT-STATIC

Risk Level: LEVEL 2（未来云控制面与主机身份/端口观察；本轮仅公开资料和本地静态设计）

Status: ACCEPTED — STATIC CONTROL-PLANE PREFLIGHT ONLY; NO OWNER LOGIN

Assignee: 最新合资格 Codex 执行会话 `01a0dc31-b629-76a3-85fd-f71566b03056`；Work 独立 LEVEL 2 审查。

## 目标与依据

AUTH-124 已由 Work 接受仅静态信任路径；阿里云控制台能否直接显示目标实例 SSH host-key 指纹、实际 SSH 端口及实例身份均 `UNKNOWN`。Owner 表示可使用阿里云登录密码和真人识别，但要求遇到输入密码或可能触发 UAC 前先停；“我在”只说明到场，不代表控制台/服务器权限。AUTH-121/122/123 的真实本机读取各 1/1 已耗尽，AUTH-107 Phase B 未放行。

主要结果为 `EVIDENCE/AUTH-125-ALIYUN-CONTROL-PLANE-HOST-TRUST-PREFLIGHT-STATIC/plan.md`；只允许写该新目录的 `plan.md`，其余项目文件只读，保留两个无关未跟踪目录。

## 允许工作与边界

1. 核对本地 Git/工作区、五份入口、项目技能和 AUTH-02/17/107/123/124 精确结论。只读查询**公开阿里云官方文档**及必要 OpenSSH 官方手册，记录可访问的精确 URL、文档适用产品/版本、访问日与支持的有限事实；不能把通用文档或截图等同目标实例实况。若公开来源不可达，就写 `UNVERIFIED`，不改走个人账号控制台。
2. 形成 Owner 将来登录官方控制面后可逐项核对的最小清单：账户/地域/实例 ID/现时公网地址的绑定；控制台连接方式和其认证性质；有效 SSH 端口从 guest 内 sshd 配置、运行监听和安全组/防火墙三层分别证明；服务器 host-key 公有指纹是否有控制台直接可信展示。仅在官方资料支持时写具体界面或只读机制；不能默认 22、默认算法、默认 host-key 路径或把首次 SSH 握手当独立来源。
3. 若必须由实例内部读取公有 host key 或有效端口，给出**未来独立任务**需先固定的对象/命令/权限/输出/风险/预算字段，并列出缺失的目标事实与停止条件。本轮不创作、运行或试探现场命令，不猜文件路径；不要请求 Owner 在聊天中发送密码、原始公钥/指纹、截图、实例 ID 或敏感输出。
4. 记录可接收的脱敏最小状态、权限和审计/退出门，以及控制台登录、密码/真人识别或 UAC 之前必须停止的位置。静态检查最多 2 轮，不做运行测试；写最终候选哈希、未证明项并停 Work LEVEL 2 审查。

## 禁止与停点

不得登录阿里云控制台、云助手、Workbench、远端终端或 SSH，不得网络探测目标服务器、重读 `known_hosts`、读取其他 SSH 文件、请求/输入密码或触发 UAC，不得运行真实工具/DB/备份、部署、导出、传输、停写、DDL/DML、提交或推送。Phase A 接受不放行现场控制面、AUTH-107 Phase B、DB 或真实备份；这些动作需分别具体任务与风险门。AUTH-99 继续禁止运行，AUTH-121/122/123 预算不重置。

Work 已在 `EVIDENCE/AUTH-125-ALIYUN-CONTROL-PLANE-HOST-TRUST-PREFLIGHT-STATIC/plan.md` 独立 LEVEL 2 **ACCEPT 仅静态预检清单**。阿里云账号与实例绑定、host-key 独立来源、有效 SSH 端口均 `UNKNOWN`；Workbench 正文未核验，控制台直接显示目标指纹未证明。无登录、密码/真人识别、UAC、SSH、DB 或备份。后继现场动作须另立精确候选和 Owner 密码前停点。
