# APP-G11-11｜Laravel stored Conversation 类别合同对齐

状态：`ISSUED`；风险 `LEVEL 2`（Conversation 响应身份合同）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 唯一变更目标

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 全部保留。先读根规则、当前状态及 APP-G11-10 `work-review.md`、`plan.md`，核对目标文件、当前 live 404 中间件与旧测试 `withoutMiddleware` 夹具。

仅允许修改：

| 文件 | 输入 SHA-256 |
| --- | --- |
| `services/backend-laravel/app/Services/ConversationDomainService.php` | `70B071A91C130C70194982F873E21C478E1BA6EBE17069C69BC03FBE8F635588` |
| `services/backend-laravel/tests/Feature/ConversationCapabilityFoundationTest.php` | `97CD987BDA73C0FE42038D08F5FF40DEA6AF14ECEB1457F2F21EFD35868AB56E` |

另允许新增本目录 `summary.md`。只将 `summarizeConversation` 的 stored `entry_kind` 从 `conversation` 对齐为 `stored_conversation`，并更新该文件内依赖旧字面量的人工测试期望；保持 `conversation_id`、`peer_user_id`、eligible 类别/ID、控制器、middleware 与其它行为。定向测试应确认列表/详情 stored 字段和 eligible 正例；旧夹具旁路 live middleware 的事实必须在摘要明确。不得改变空 peer 过滤、对端成员选择、权限、auth、schema、Flutter 或其它代码。

## 新一次性预算与停点

编辑前只读核对两文件哈希、`vendor/autoload.php` 和本地 PHP。必要编辑后，运行一次 `php artisan test tests/Feature/ConversationCapabilityFoundationTest.php`；仅本任务两文件中的夹具/实现缺陷可修后额外复跑同一命令一次。两文件各一次 `php -l`，两文件 `git diff --check`。不运行完整套件、网络、设备、真实数据或生产验证。若现有测试因本任务外原因失败，记录原始退出码和失败，停止，不篡改权限夹具或扩路径。

`summary.md` 记录前后哈希、目标差异、测试数/断言/退出码、预算、静态检查、兼容局限与回退范围。回退只撤销本任务两文件新增差异和摘要，保留全部既有工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自接受或启动后继。当前 live 门仍返回 404；真实 Conversation read/send、actor/audience、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填不变。
