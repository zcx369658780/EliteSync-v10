# v10.1.16 模拟器代表截图

全部来自候选 `10.1.16-dev / 1011601`，源码 `00cec7843911bb3341304c004059de0a91e12f16`。使用虚构 QA 账号和保留数据的模拟器，Owner 手机为 NOT_RUN。授权状态与服务端 revision 对照，详细范围见[实施报告](../IMPLEMENTATION_REPORT.md)。

- [旧虚构账号保持默认关闭，资格不足时授权按钮禁用](legacy-default-off.png)
- [已完成准备的 QA A，授权前状态](ready-before-grant.png)
- [持续参与的独立授权确认](explicit-consent.png)
- [APP 明确授权后 ACTIVE](app-active.png)
- [已有轮次报名已结束，任务按原因跳过](app-round-closed.png)
- [APP 暂停后 PAUSED](app-paused.png)
- [APP 进程重启后读取仍为 ACTIVE](app-cold-active.png)
- [APP 撤销后 REVOKED](app-revoked.png)
- [切换 QA B 后探索未开始、自动化 OFF](app-account-b-off.png)
- [返回 QA A 后保留 REVOKED](app-account-a-returned.png)
