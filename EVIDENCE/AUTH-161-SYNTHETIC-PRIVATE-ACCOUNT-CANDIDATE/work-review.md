# AUTH-161 Work 独立审查｜2026-09-27

**LEVEL 2 REJECT 作为完整的同账号来源绑定候选；代码与测试候选保留供 AUTH-162 有界修复。** 作者摘要 SHA-256 `A7563E3CDF1121FE72AEBD5073F80846068B1DCA6787FD4A938CC779D4DC191E`；两份新 PHP 哈希与摘要一致：`PrivateAccountTargetCandidate.php` `00C2811313836861166627D58E2492129EBA116F8F73776BED5C003BE87A04C2`，`PrivateAccountTargetCandidateTest.php` `CB9A6C863E4BC28FFC7C43B63E7C473A0228159F93A6EA06FBE9CBEAE120DA3F`。作者两份语法检查退出 0，Unit 首跑 **11 tests/15 assertions**、无 deprecations/复跑；Work 未重复运行。

负向边界缺口：`normalize()` 对两处出生地点验证 `source` 和 `account_id`，但 `legacy_name` 与 `explicit_nickname` 是没有来源/账号绑定的裸值。调用方可把另一个账号的显式昵称放进当前账号输入而得到候选，违反任务单“任一来源账号身份与主账号不一致时 fail closed”及五项资料不可跨账号拼接的目标。现有测试没有昵称/旧姓名来源身份错配用例；synthetic 标签本来只表明调用方声明，也不能补足来源绑定。此问题不需要触及真实数据即可修复。

不能以测试通过验收完整任务，也不把旧预算复用为补测。生产 User/DB、真实备份/账号行、迁移与权限未触及；两份新文件保留为未接受候选，待 AUTH-162 新固定范围及预算。未提交、拉取或推送。
