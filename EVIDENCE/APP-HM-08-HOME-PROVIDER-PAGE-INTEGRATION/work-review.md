# APP-HM-08 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定接受本地 synthetic Match → Home provider → HomePage 的 widget 回归。** Work 独立核对唯一测试文件差异、作者摘要 SHA-256 `A094AE0706138198E16867598C5E101F15071964447131E9C27283B002FDE9E8` 与最终文件 SHA-256 `A68DF195F0212A95D748891532911E0B5F358B2FE7114CBF3BC17406D365F3B7`。产品代码未修改。

新夹具只覆盖 dev 环境、ready navigation 和人工 Match `failed`/`closed` 输入，没有覆盖 `calmHomeProjectionProvider`；两条 widget 用例实际经该 provider 到 HomePage，核对页面 `UNKNOWN`、“查看进展”、无“当前没有可用的匹配提案”，点击唯一主按钮进入测试 Progress 路由。APP-HM-07 的手工投影用例及原有六条页面用例保留。

作者定向 Flutter 测试首跑退出 0、9/9 tests passed；最终格式写入与只读复核均退出 0，`git diff --check` 退出 0。Work 未复跑测试或重用一次性预算。这只证明本地虚构输入下的 widget 接线，不建立 APP-T12 G-08 真实 Home/Match 来源、真实 CN/MC、设备构建或生产权限。AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B、真实 CMS 认证/隔离恢复和账号回填仍 `NOT_READY`。

本地 `main` HEAD 未移动，既有工作区保留；无提交、pull、push、真实数据或恢复动作。后继须另立有界任务。
