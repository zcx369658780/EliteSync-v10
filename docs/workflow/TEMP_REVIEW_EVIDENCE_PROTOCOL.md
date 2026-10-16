# EliteSync-v10｜临时审阅材料交付与清理协议

生效：2026-10-16。Owner在v10.0.9 R3安全脚本验收时明确批准：未来必要的Codex审阅材料可以借GitHub短期交付，Astra独立验收后主动组织精确清理。此协议是**证据传递工作流**，不替代版本冻结计划、Owner网络/设备/费用授权或Astra独立验收，不恢复GitHub作为日常任务单/message bus。

## 一、不可混淆的技术事实

- 本地`gitignored`或Git未跟踪（untracked）目录**不能出现在GitHub仓库供Astra读取**。不得宣称「远端临时目录不被Git追踪」。
- 推荐双层目录：原始本地`LOCAL_ONLY`证据及`.local_review_outbox/`保持未跟踪/忽略；仅经检查的**脱敏审阅副本**，在独立短期`review/temporary-evidence-<task-id>`分支内暂时`git add/commit/push`至`docs/_temporary_review/<task-id>/`。
- 临时审阅分支**不得合并到main、产品分支或冻结验收分支**；这是为可审阅性产生的短期Git跟踪，不能保证在GitHub历史/缓存中无痕。
- 当前仓库GitHub可公开访问。**任何上传到远端的文件都必须按公开资料标准脱敏**，即使预期稍后删除。删除文件/分支**不等于保证从Git对象、历史、缓存或克隆中彻底消除**。若无法安全脱敏，改由Owner直接上传到会话或经明确批准的非公开受控文件通道；不得为了方便审阅而降低安全边界。

## 二、Codex产生一次性审阅包

1. 在当前Owner已派发版本/定点任务范围内，先保护原dirty root、旧工作树和所有LOCAL_ONLY。不得盲pull/reset/clean/stash/prune。
2. 只准备最小内容：任务状态与权威Commit/Tree、审阅目标、脚本源码/必要测试源码（如其本身不含秘密）、最小stdout/stderr/exit或脱敏统计、SHA256清单、独立审查和已知失败。避免长篇历史转存、整段logcat、二进制大包。
3. 上传前用实际内容核查并排除：账号、token/JWT/API key、私有配置、家庭/设备私网IP、真实设备序列、真人声音/摄像头原图、真实业务数据、个人路径和任何不能公开的信息。目录名或清单SHA不是安全脱敏的替代。
4. 创建只用于这次审阅的独立临时分支（精确基线、唯一任务ID），**普通non-force**上传审阅包；不给`main`和正在执行的产品开发分支新增临时证据提交。原本地未跟踪目录仍不强制跟踪。
5. 固定报告审阅分支、完整Commit/Tree、每个文件的Git blob或SHA256、准确路径及GitHub固定链接；标明哪些真实Windows物理结果仍为`CODEX_REPORTED / LOCAL_ONLY`、哪些源文件和测试由GitHub可直接读取。未上传的原证不得冒充Astra已读。
6. 若文件或安全范围不明、提交涉及私有原证，停止上传并请求Owner做一次范围决策。

## 三、Astra独立审阅与定点清理

1. Astra先核对分支HEAD/Commit/Tree、每个审阅文件、代码与测试身份，以及冻结AC；据实`PASS`、`PARTIAL`、`NOT_PROVEN`或`REJECT`，不可用Codex自报成绩代替真正代码审查。
2. 审阅中需要定点补证时，可在同一短期分支追加脱敏材料；不自动复制到`main`。先归档最终结论及必要**不敏感摘要/哈希/拒绝理由**至正式版本文档，不把暂存原件纳入长期归档。
3. 完成验收/拒收及需要的最终摘要后，Astra主动发起清理：在授权GitHub工具支持范围内精确删除临时审阅文件并回读；若连接器不支持**删除远端分支**，向Codex发出**仅删除该具名短期远端分支**的集中清理任务，由Codex执行`git push origin --delete <exact-review-branch>`（或等效GitHub UI操作），Astra再查分支/目录不可访问。**不得扩大为删除业务分支、Git历史重写或仓库prune。**
4. 记录`REVIEWED / CLEANUP_REQUESTED / REMOTE_BRANCH_REMOVED_VERIFIED`等真实阶段，不提前声称已清理。短期远端引用删除不能保证Git对象、搜索缓存和外部克隆已经清除。
5. 临时文件删除/分支清理与`acceptance.md`、产品合并main、K08、系统网络权限都是独立动作；任何一个动作不自动授予其它动作。

## 四、当前v10.0.9示范

R3仅提交去除秘密的7个实际运行脚本、相关模拟/启动器测试及必要原始exit、审查报告和哈希，在独立短期审阅分支接受Astra核对。原DB卷、设备、密钥、真实防火墙地址及声音继续LOCAL_ONLY。即使临时审阅包代码核验通过，**AC-09-03仍须另行Owner明确批准的实际同call双向人工听辨**；当前`v10.0.9 NOT_ACCEPTED`、无K08或后继版本。

此协议与[CURRENT_WORKFLOW](CURRENT_WORKFLOW.md)、[项目启动指导](../../AGENTS.md)共同生效；如工具无法提供所需远端删除能力，必须报告并改用上述具名Codex清理途径，不能假称Astra已删除。
