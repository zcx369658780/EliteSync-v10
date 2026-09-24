# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-21-LOGIN-EVENT-LOCAL-PERSISTENCE-PREFLIGHT`

Risk Level: `LEVEL 2`（auth 与未来数据模型；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付本地候选和证据，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 已决定：可信 `T0` 仅来自服务端确认的成功交互登录；自动 Token 续期不重置；在线登录 15 天，离线只读最多至最后一次成功在线登录满 30 天，随后清理已保存加密私密内容。AUTH-08/09/10 分别是合同、纯 synthetic 判定和持久化设计，均未形成真实事件存储。AUTH-20 仅报告部署目录当前 CLI 连接的聚合元数据。本任务只在本地用**虚构账户和设备**预检登录事件持久化所需的不变量与 schema 可行性，不接入真实登录或部署数据库。

Owner 另决定未来完整 DB 备份仅在阿里云内加密保留 30 天；精确位置、密钥、隔离恢复目标及清理责任仍未定。本任务不得备份、恢复或修改阿里云。

## Allowed candidate

仅允许新增 `EVIDENCE/AUTH-21-LOGIN-EVENT-LOCAL-PERSISTENCE-PREFLIGHT/` 下的 `schema_candidate.php`、`test_schema_candidate.php`、`summary.md`。不得修改既有源码、migration、测试、配置或控制文件。先核对 `main`、HEAD、工作区和本任务 `ISSUED` 状态，读取根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地工作流技能、AUTH-08/09/10/20 接受结论及必要的本地 Laravel migrations、`AuthController.php` 和 `User.php`。保留无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

`schema_candidate.php` 应是仅供本地虚构数据预检的、可重复执行的 SQLite 内存 schema/操作样例，不作为 Laravel migration 或产品代码。使用抽象、不含真实标识的账户/设备引用与事件幂等键。由测试展示：同一事件重复提交不新增锚，账户/设备不串用，顺序冲突或较旧事件不覆盖较新锚，失败登录/注册/refresh 不新增成功交互登录事件，已有用户无可信事件时保持 `UNKNOWN`。若本地 SQLite 扩展不可用，停止运行预检并在 `summary.md` 标记 `NOT RUN`，不得装依赖或换远端数据库。不能用本样例模拟出真实服务端身份、设备证明、受信时间、撤权传播或合法保留/删除政策。

`summary.md` 记录精确候选路径、所核对的来源、测试结果和尚未决定的生产 schema 项（至少含设备绑定证明、可信时间与顺序、账号删除与事件保留、撤权、索引/并发和旧数据处理）。明确该预检不签发离线凭据，不提供在线读发权限，也不授权部署 migration。

## Verification budget and stop

仅运行 `test_schema_candidate.php` **最多 1 次**，只用虚构输入及本地内存 SQLite；`php -l` 对两个新 PHP 文件各 **最多 1 次**；`git diff --check` **最多 1 次**，并对三个新增文件另作只读尾随空白检查。若测试或语法失败，保留失败回执，不通过反复运行或扩大范围掩盖。不得读取 `.env`、真实配置值、私钥、账号/Token/日志/媒体或业务数据行；不得 SSH、HTTP/API、设备、远端 DB、备份、导出、恢复、migration、部署或 GitHub pull/push。Codex 不提交、自接受、备份或派发后继；Work 独立审查差异、负向用例和证据后决定 ACCEPT/REJECT。
