# APP-G11-10｜Conversation 返回字段与 Flutter 消费来源映射

状态：`ISSUED`；风险 `LEVEL 2`（Conversation 身份/隐私，docs-only）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 唯一交付与问题

唯一实时仓库 `D:\EliteSync-v10`；本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，全部既有 dirty/untracked 保留。先读根规则、当前状态、APP-G11-08/09 的 Work 审查和 APP-T12 重审结果 G-11。只允许新增本目录 `plan.md`；不修改任何源码、测试或 authority 文档。

在当前本地 v10 代码内，静态追踪 Laravel `GET /api/v1/conversations` 及 `GET /api/v1/conversations/{id}` 的实际入口、中间件、服务输出字段与客户端 `ChatRemoteDataSource`→`ConversationDto`→`ChatMapper`→列表/详情消费。用精确来源说明 `id`、`conversation_id`、`peer_user_id`、`entry_kind` 在 stored/eligible/legacy 路径各是什么，缺失或冲突如何处理；区分当前代码合同、人工测试、真实权限证明。特别检查列表 `peer_user_id` 缺失时服务器过滤条件与返回内容的行为，只记录代码可证的事实和潜在缺口，不推断真实数据或扩大权限。给 Work 推荐**一张**无需真实数据的下一有界软件切片及负例/回退边界；若不足以确定，明确 `NOT_FIXED`。

## 新一次性预算与停点

最多两轮本地只读静态核对：第一轮固定路线和直接服务/DTO 定义，第二轮仅追踪第一轮发现的直接调用者及定向测试。可用已索引的本仓 codebase-memory 图谱定位，再以当前文件正文核验；图谱不足时限于本仓 `rg` 回退并记录。仅写 `plan.md`，记录两轮实际来源、未核实项、文件 SHA-256；不运行测试、构建、网络、设备、数据库、备份、SSH、云/生产 API，也不访问旧 `D:\EliteSync`。不得提交、pull、push、自验收或派发后继。旧任务测试与静态预算不重置。真实 Conversation read/send、actor/audience、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填门不变。
