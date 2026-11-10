# APP-HM-07 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定接受 Home 页面消费虚构安全回退投影的 widget 测试证据。** Work 独立核对唯一测试文件差异、作者摘要 SHA-256 `4B7E7907CB53FB243B75FF982CC83E7FB3CD2AC9B877308F5597F4F0C40E527E` 与最终文件 SHA-256 `3709AC2EE75CBC6A4D1273E7540985695739AAE86BEA08A15F87A6244FC9AF47`。改动只给测试夹具加 `ProviderScope` 与默认 `CalmHomeProjection.current` 覆盖，并加入一条 Match unknown 虚构投影的页面用例；产品代码未动。

新增用例核对可见 `UNKNOWN` 和“查看进展”，不显示“当前没有可用的匹配提案”，点击唯一主按钮进入测试 Progress 路由；原有页面布局、隐私次级按钮、对比度和普通手机宽度用例保留。首跑退出 1，原因是新夹具漏掉默认投影覆盖；允许范围内修正后的唯一复跑退出 0、7/7 tests passed。`git diff --check` 退出 0。`dart format` 写入和只读复核在最后一次夹具修正前退出 0；最终文件未再次运行格式工具，故**最终格式工具复核未建立**。Work 从最终差异检查新增修正仅为默认投影表达式和排版，不将此前格式回执冒充最终版本证明，也不重用一次性预算。

本接受仅证明 HomePage 对给定虚构投影的可见文案与测试路由，不证明真实 Home/Match 权威、provider 至页面的完整真实接线、设备构建或 APP-T12 G-08 已关闭。AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B、真实 CMS 认证/隔离恢复及账号回填仍 `NOT_READY`。本地 `main` HEAD 未移动，既有工作区保留；无提交、pull、push、真实数据或恢复动作。
