# AUTH-162｜纯内存候选的姓名来源账号绑定修复

状态：`ISSUED`；风险 LEVEL 2；派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`。本任务只修 AUTH-161 保留候选的旧姓名/显式昵称来源绑定，交付后停 Work LEVEL 2 独立审查。

## 固定入口与允许范围

先核对 `D:\EliteSync-v10`、本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、dirty 工作区与当前任务。只读根治理文件、本地 workflow/runtime 技能、AUTH-160 `plan.md`/review、AUTH-161 task/summary/review、下列两份精确候选。它们修改前 SHA-256 必须分别为 `00C2811313836861166627D58E2492129EBA116F8F73776BED5C003BE87A04C2` 与 `CB9A6C863E4BC28FFC7C43B63E7C473A0228159F93A6EA06FBE9CBEAE120DA3F`；不符即停，不覆盖他人变化。

只允许修改 `services/backend-laravel/app/Domain/PrivateAccount/PrivateAccountTargetCandidate.php`、`services/backend-laravel/tests/Unit/PrivateAccountTargetCandidateTest.php`，新增本目录 `summary.md`。其他工作区内容不改。

## 修复行为

将 `legacy_name` 和 `explicit_nickname` 也改为带精确 `source`、`account_id`、`value` 的虚构来源候选，分别使用明确的旧姓名和显式昵称来源标签；两者都必须与主 `account_id` 一致，即使值为 null/空白也要验证身份。缺失、标签错配或跨账号立即 `InvalidArgumentException`，不返回部分候选；不允许裸值兼容分支。保留 AUTH-161 的昵称只取显式候选、旧名仅可生成冲突标记，及出生地点固定当前两处来源优先、未知/两备份库顺序拒绝、`'0'` 保留等语义。synthetic 标签不是来源证明，接口仍不连 User/DB、环境或网络。

调整原有虚构测试夹具并补至少四类负例：旧姓名跨账号、显式昵称跨账号、两种姓名来源标签错误、空值或空白仍须拒绝来源错配。保持原有出生地点负例。不得读真实数据、迁移/导入、改 Auth/Profile 模型/controller 或放行登录。

## 新预算与停点

两份修改 PHP 各一次 `php -l`；新预算对指定 Unit 文件首跑 **1 次**，若仅本任务代码/测试缺陷失败可修正后最多复跑 **1 次**。其他失败停审；完整套件 `NOT_RUN`。因两文件仍未跟踪，`git diff --check` 不足以检查内容，须对两文件做只读尾随空白核对。`summary.md` 记前后哈希、测试退出码/tests/assertions/deprecations/复跑、负例和边界；回退仅撤销两文件 AUTH-162 差异和本摘要，保留 AUTH-161 候选。

不得访问旧 `D:\EliteSync`、备份/密钥、SSH/云/生产 API、真实账号行、DB、Docker/WSL、UAC；不提交、拉取或推送。旧 AUTH-161 预算不重置；作者停 Work LEVEL 2 ACCEPT/REJECT，不自接受或启动后继。
