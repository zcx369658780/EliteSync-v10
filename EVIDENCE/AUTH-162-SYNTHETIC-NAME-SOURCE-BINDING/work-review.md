# AUTH-162 Work 独立审查｜2026-09-27

**LEVEL 2 ACCEPT，仅接受纯内存 synthetic 候选的四来源同账号绑定修复。** 作者摘要 SHA-256 `8CABDBED6A200EF3E6A4BD8E9F7DD57760F7C554BCB2A495402845389F9AFC08`；两份修复后 PHP 哈希与摘要一致：`PrivateAccountTargetCandidate.php` `E6225EF406AB206C7DA06FF73CC39DB03E30FA2C9F04FB0BB7F71896C7847493`，`PrivateAccountTargetCandidateTest.php` `564AAE896D96C54B922DB6148163F5F779B400EED0C3AB1B68C0086208BF2CBC`。

独立源码/测试审查确认：旧姓名与显式昵称不再接受裸值，均要求精确 `source`、`account_id` 和 `value`；即使值空白或 null，来源错配仍抛出异常。测试新增两类跨账号、两类标签错误、空值错配及裸昵称拒绝，保留出生地点同账号/顺序/冲突负例。作者两份语法检查退出 0；新预算 Unit 首跑 **18 tests/22 assertions**，无 deprecations、失败或复跑。Work 未复跑；两份文件仍未跟踪，`git diff --check` 不能覆盖其内容，作者另做只读尾随空白核对，Work 读取文件确认无异常。

`synthetic_only=true` 只受调用方声明控制，不是可信真实来源证明；本接受不使该接口可接真实账号、备份、密码哈希、生产 DB 或登录权限。最终 nickname/schema、跨库账号范围和来源优先级仍待后继证据与 Owner/Work 决定。AUTH-161 旧 REJECT 与旧预算保持，AUTH-162 新预算不重置。未触及 SSH、真实数据、备份/恢复、提交或 GitHub 同步。
