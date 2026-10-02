# BE-07 Work 独立审查｜2026-09-27

**LEVEL 2 REJECT 作为已完成的 application 关联切片；保留候选差异供有界修复。** 审查对象 SHA-256：新增 adapter `A001371D7BC9BA0C9E9E23EC517016E17B38E8137DAB8CCE1C5F512DA0680A43`，Unit test `B4D9015D4C29B87AB1C836A5C76565170F19F86A6513DBA0EC2AED0663B34F6E`。作者两份语法检查、三个定向 Unit 文件 21 tests/904 assertions PASS；BE-07 的运行预算已按回执使用，不由本审查重置。

提交一次、精确读回、恒 false 权限字段和失效目标核对符合本轮方向。但 `validEvidence` 仅校验每份证据的内部 bindings/revision 一致及 context/participants/purpose，未核对 **CN 与 MC 的 `required_bindings.audience` 共同绑定**。当前输入还没有显式 protected audience，因此把一份证据的 audience 改成另一个仍可形成 `EXACT_SOURCE_CORRELATION` / `correlation_usable=true`。BE-06 已接受映射与 BE-07 任务均要求跨 audience fail closed，新 test 未覆盖该负例。仅因记录仍标非权限，不能放宽其“来源关联可用”的结构断言。

后继应固定 synthetic protected audience，分别核对 CN/MC 与该值绑定，补双向错配负例，再用新有界预算验证；不把调用方声明的 audience 或任意自洽 owner 当作真实来源认证。真实 MC writer/权限使用点、账号、生产 DB 和备份恢复仍 `NOT_READY`。本审查不改源码或运行额外测试，既有无关工作区内容保留。
