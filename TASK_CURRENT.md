# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-148-ONE-SHOT-TOOL-PATH-PROBE

Risk Level: LEVEL 3（生产实例命令助手一次路径候选探针）

Status: ISSUED — WAITING FOR OWNER TO OPEN COMMAND FORM; EXECUTION 0/1 NO-GO

Assignee: Work 准备同一实例表单、独立临运行核对和证据；最终点击由 Owner 在本任务 GO 后亲自操作，除非 Owner 对本任务另作明确决定。Codex 不执行现场动作。

## Owner 本次决定与固定候选

Owner 在已知 AUTH-146 的类别结果与 AUTH-147 静态候选后，明确接受**三个程序绝对路径原值及脚本可能由阿里云命令助手长期留存，可见者/期限未知**的新增风险，并授权准备同一上海轻量实例、显式 `root` 的一次只读路径候选调用。此决定不证明实例独立绑定、程序身份或 SSH/DB 就绪；本轮仍须先固定表单、脚本和预算，Work LEVEL 3 给 GO 前不得点击执行。AUTH-140/142/144/145/146 的预算均不重置。

脚本唯一来源为 `EVIDENCE/AUTH-147-SSHD-TOOL-IDENTITY-STATIC-CANDIDATE/plan.md` 中的完整 `sh` 代码块；Work 审查记录写入后的当前 SHA-256 为 `E9D184064CD24C8D496EDFCE0EB07ADDC79F5514D89A37D8B83B4242929DED39`，本轮临运行须重新计算。脚本只用 Shell 内建名称解析和字符/长度过滤，**不调用** `sshd`、`systemctl`、`service` 本体，不读配置、公钥、私钥、端口、数据库或业务文件。成功也只给路径字符串候选，不证明工具字节身份或服务运行。

## 本任务 UI 准备与执行硬门

只在当前已登录的阿里云官方上海唯一轻量实例命令助手页面操作。Work 可关闭 AUTH-146 已读详情、打开该实例“执行命令”表单并**只为准备**精确填写：Linux Shell、输入命令内容、命令名 `AUTH-148-readonly-tool-path-probe`、参数关闭、显式用户 `root`、执行路径保留原默认 `/root`、超时 10 秒、编辑器**仅含 AUTH-147 固定代码块原文**（允许尾随换行）。不得提交、试点“确定”或预先运行。若表单目标/地域/实例不一致、需要另登录、密码、真人识别、权限/UAC、模板残留、代码无法逐行核对或字段不能固定，立即 `NO-GO`，不换目标、用户或脚本。

Work 仅在目标、脚本、参数、按钮状态与无遮罩均经重新核对后，记录 LEVEL 3 临运行裁决；若条件通过，向 Owner 给出**仅当前表单手动单击“确定”一次**的明确 GO。Owner 点击动作开始即本任务执行预算 `1/1`，无论页面是否变化，不重试、不让 Work 补点、不改走 SSH。事前预算 `0/1`。点击后仅在当前页面观察新记录一次；详情读取不包含在本任务预算，需另审。若无回执，记 `SUBMIT_UNCONFIRMED`、`FIELD_RESULT=UNKNOWN`；不推断未执行。

普通证据只保留目标/表单 `MATCH|NO|UNKNOWN`、脚本哈希、提交预算、控制面状态和有限时间，不保存实际工具路径、实例 ID/IP、页面/异常原文、截图或命令输出。唯一主要结果 `EVIDENCE/AUTH-148-ONE-SHOT-TOOL-PATH-PROBE/summary.md`。AUTH-128/136/138/141 页面及 AUTH-121/122/123 本机已耗预算不重置；保留两个无关未跟踪目录，不访问旧仓库，不自动 pull/push。SSH、PEM、DB、dump、传输、恢复均未放行。

## 当前 UI 停点

Work 尝试关闭已读详情，但浏览器自动化点击/键盘动作无可见作用，怀疑仍有交互定位问题，未继续试点。已请 Owner 手动关闭详情并打开“执行命令”新表单，明确不要点击“确定”。后续只读观察见详情已关闭、表单尚未打开；Work 未填写脚本或参数，未提交，执行预算 `0/1`。此处等待 Owner 回报“表单已打开”；不能借已关闭详情自行推定用户同意后续点击。
