# 当前入口｜2026-11-10 功能优先与资产清理

Owner 已要求暂停动态测试；本轮只清理冗余资产和简化工程流程。此前 case08 只有准备文件，从未激活，没有本轮设备/后端操作。旧 STOP、已耗记录和未耗次数不改写，也不自动接续。

- 产品目录：`D:\EliteSync-v10-product-v1015-20261101`；分支 `codex/v10.1.5-software-continuation-20261101`。原主库 `D:\EliteSync-v10` 的 main/dirty/index 及无关 `%SystemDrive%/` 保留。
- 产品源码仍为 `1f936d253dbccceb2c719ea16de4f25be2789b4d`；本轮未修改 APP/API 源码、未构建或安装 APK。现包 SHA256 `b621fb883a16ad0956b0b2d049d8d023d5cb7a25e7451d6b08584d402580e57f`。
- v10.1.5 仍 10 PARTIAL、AC05 OPEN、G2 false、真实 Push PENDING。最近双端连续链的登录/文字互发/持久化未完成；历史局部登录、媒体后端证据不等于当前整链完成，缓存真机效果 UNKNOWN。
- 当前状态与缺口见 [PROGRESS](../versions/v10.1.5/PROGRESS.md)；旧逐 case 流程已退役，历史完整记录从 Git 历史及固定私有整理目录查询，不继续层层冻结。

后续主线：完善 APP 功能和真实开发链，再集中做协议加密等安全封装。普通修复自主连续完成；只做受影响检查与必要的一次最短功能验证。现有鉴权和数据保护保留。当前未自动启动新功能实现或动态测试。

[Owner 决定](../decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md) · [工作流](CURRENT_WORKFLOW.md) · [资产与版本摘要](../versions/ASSET_VERSION_SUMMARY_20261110.md)
