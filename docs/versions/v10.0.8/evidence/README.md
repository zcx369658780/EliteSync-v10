# 安全证据阅读入口

本目录来自唯一0.8隔离开发环境；完整原件保留在Manifest的Q。本目录不是新的验收结论。INDEX逐文件列出原始SHA256、公开SHA256、字节数和是否脱敏；公开core-first.stdout只去掉SQL异常中的密码hash，本地原件保留。密码、token、cookie、私配、物理AAR/APK、数据库和媒体二进制不发布。

优先读取：

- `final-business-snapshot.stdout`：最终同库users、audit、sanctions、reports、questions、runs、Match/CN/MC、notifications及release的有限投影。
- `web-real-csrf-version-concurrency.json`、`session-rotation-real.json`及三张旧session拒绝截图：可信Web身份、CSRF、并发和当前权限。
- `final-disabled-*`、`final-normal-bob-correct.json`、`app-final-disabled-session.png`：Alice禁用、APP清会话、正常Bob对照及R1隐私。
- `question-history-preservation.json`、`d1-history-consent-preserved.json`：停用与运营审核的历史保留，不把追加后的整体hash当作旧记录hash。
- `web-run-succeeded.png`、`web-worker-stopped-pending.png`、`web-zero-candidate-published.png`、`web-final-round-closed-ok.png`、`final-notice-{api,read}.json`：真实consumer、失败恢复、发布/关闭和站内事件。
- `joint-before.stdout`、`joint-after.stdout`、`joint-snapshot-comparison.json`、`web-joint-restart-users.png`、`app-joint-bob-readback.png`、`app-joint-release-database.png`：同一volume不重seed的联合重启。
- `php-regression-sixth.*`、`flutter-related-final02.*`、`flutter-related-final03.*`、`analyze-final03.*`、`build-fifth.*`、`install-fifth.*`：实际stdout/stderr/退出码。原始失败均按原标签保留，不用成功覆盖失败。

`final-disabled-old-token.json`、`final-normal-bob.json`中的404来自误用不存在的 `/api/v1/me`，**不作为权限证据**；正确路由证据为带correct后缀文件。`joint-round-current.json`关闭后no_round、`joint-match-current.json`对方禁用后no match均按实际状态解释。APP的泛化通知标题不是原私信摘要；正常匹配通知可以导航到重新读取权限的结果页，撤销后的消息通知不保留会话导航。

真实browser截图与真实APP截图不被单测替代；SQLite/Widget测试、真实HTTP协议补证、MariaDB快照和交互截图分别说明其证据层级。后端suite保留vendor deprecations；全量Flutter本版NOT_RUN，旧exit1记录仍在原0.7报告。全部结论等待Astra独立终验。
