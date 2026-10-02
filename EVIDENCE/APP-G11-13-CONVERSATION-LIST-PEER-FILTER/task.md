# APP-G11-13｜Conversation 列表空 peer 返回失败关闭

状态：`ISSUED`；风险 `LEVEL 2`（私密列表响应过滤）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 精确范围

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，保留全部既有 dirty/untracked。先读根规则、当前状态、APP-G11-10/12 的 Work 审查和 `ConversationController::index` 当前代码。唯一允许修改的既有文件 `services/backend-laravel/app/Http/Controllers/Api/V1/ConversationController.php`，输入 SHA-256 `E302A5DDFF313C8B56BE4D5A444AF26446B4B9DAE4EF9FC7210E4EB780D99678`。另允许新增 `services/backend-laravel/tests/Unit/ConversationListPeerFilterTest.php` 与本目录 `summary.md`；测试路径当前不存在。

只收紧 `index` 列表返回：`peer_user_id` 必须是正整数且通过现有 `canRead(actor, peer)`，才进入返回 `items`；缺失、null、0、负数、无效类型不得因 `empty(...)` 旁路过滤，也不得由 `id` 或 room key 补造 peer。保留有效 stored/eligible 项及原有 capability 附加、`total` 计算；`store`、`show`、`showPeer` 不改。用**直接控制器调用的人工 Unit**验证无效 peer 被排除、正 peer 根据 `canRead` 保留或排除、返回项/total 一致；不使用真实 DB，不绕过或改动 live middleware。Unit 只能证明控制器内部合同，不能宣布 live GET 可达或真实权限。

## 新一次性预算与停点

编辑前只读核对 controller 哈希、测试路径不存在、PHP 和本地依赖。必要编辑后执行一次 `php artisan test tests/Unit/ConversationListPeerFilterTest.php`；仅本任务两允许文件的夹具/实现缺陷可修后额外复跑同一命令一次。对 controller 和新测试各一次 `php -l`，对这两文件运行 `git diff --check`；新未跟踪测试文件需另作行尾空白检查。若任何命令尝试真实数据库、网络或任务外环境失败，记录并停，不扩大路径或启动服务。不要用 APP-G11-11/12 的测试预算。

`summary.md` 记录输入/最终哈希、新文件哈希、差异、测试/退出码/断言、预算、静态检查、局限及回退范围。回退仅本任务 controller 的新增过滤差异、新测试与摘要，保留全部已接受差异和其它工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自接受或启动后继。当前 live middleware 仍 404；真实 Conversation read/send、actor/audience、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填门不变。
