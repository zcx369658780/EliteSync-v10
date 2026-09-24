# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-04-DEPLOYED-ROUTE-DIFF-CORRECTED`

Risk Level: `LEVEL 2`（真实服务器源码只读差异；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付一次新授权下的精确只读差异事实候选，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-03 的一次远端读取预算已耗尽，Work LEVEL 2 REJECT 其“具体差异已完成”结论；其远端 SHA-256 事实仍为 `2cdffe4b9cbb48a8059f09afa1eb74f521d1dcf96203c527814d528a65b6fb70`。Work 已在纯本地验证 Python `difflib.unified_diff`：当前本地路由与自身比较 0 差异行，与一份本地历史 blob 比较 15 差异行。Owner 现**明确授权新任务再做一次**同一精确路由文件的只读 SSH 读取；不重置 AUTH-03 的预算。

目标是列出部署 `/opt/elitesync/services/backend-laravel/routes/api.php` 与本地 `services/backend-laravel/routes/api.php` 的具体差异，并精确判断 `v1/auth/login`、`v1/auth/refresh` 的方法、控制器和中间件声明是否相同。比较只涉及该源码文件的静态文本，不推断路由缓存、实际 HTTP 行为、可信登录事件 `T0`、15/30 天规则、权限来源或生产就绪。

先核对本地 `main`、HEAD、工作区及 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能、AUTH-02/03 回执和本地精确路由文件。只有本任务仍为 `ISSUED` 且派发匹配才执行。

## Required local preflight, then one remote read

在**不连服务器**时，用 Python 标准库 `difflib.unified_diff` 对本地路由字节做两项预检：与自身比较得到 0 差异行；与 `git show e34d6530270d:services/backend-laravel/routes/api.php` 的本地历史字节比较得到非零有限差异。预检失败即停，不允许 SSH。

预检通过后，最多 **1 次 SSH 进程调用**：`root@101.133.161.203`、`C:\Users\zcxve\.ssh\CodexKey.pem`，`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，关闭密码与键盘交互，外部等待上限 20 秒。远端命令仅 `cat /opt/elitesync/services/backend-laravel/routes/api.php`。建议在 Python 中用 `subprocess.run(..., stdin=DEVNULL, capture_output=True, timeout=20)` 读取 stdout 到**内存**，不打印/保存整份源码。若 SSH 非零、主机密钥问题、认证失败、stdout 大于 64 KiB、UTF-8 严格解码失败或 SHA-256 不等于 AUTH-02/03 接受的远端值，记录分类并停，不重试或改读其他路径。

用内存中的两份字节经严格 UTF-8 解码后调用 `difflib.unified_diff`；统计完整差异，但证据仅记录必要的非私密差异 hunk、行号和路由声明，最多 120 行。若 diff 太大或疑似出现凭据字面量，不输出原文，记录数量/分类并停在 Work 门。明确区分字节差异、路由声明差异与未核验的运行事实。不得在本地落盘远端全文，不修改本地/远端路由。

## Scope and verification

唯一允许新增 `EVIDENCE/AUTH-04-DEPLOYED-ROUTE-DIFF-CORRECTED/summary.md`。不读私钥内容、`.env`、配置/环境变量值、Token、日志、DB、用户/媒体数据；不运行 `php artisan`、HTTP/API、服务管理、部署或远端写入，不访问旧 `D:\EliteSync`，不 pull/push GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

回执记录本地 HEAD、两项本地预检、一次 SSH 是否执行/结果、远端与本地 SHA-256、准确差异及 auth 两入口的结论或精确未完成分类。只运行一次 `git diff --check`；新文档另作尾随空白检查。不运行产品测试、设备或全量搜索。Codex 不自接受、不提交、不备份、不推送、不派发后继。Work LEVEL 2 独立 ACCEPT/REJECT。
