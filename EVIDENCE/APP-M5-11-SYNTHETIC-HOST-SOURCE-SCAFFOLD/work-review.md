# APP-M5-11｜Work独立审查｜2026-09-30

**LEVEL 2 REJECT / CLOSED SOURCE CANDIDATE — ROUTE GUARD GAP。** Work与独立Sol/high审查最终源字节，P2：flutter_deeplinking_enabled=false位于application，而MainActivity.onNewIntent仍交给super；未建立Activity元数据开关对新Intent的有效阻断。固定getInitialRoute只覆盖初始route，不能据此接受完整外部route拒绝门。须另立有新静态预算的小修复，不改本摘要或复用旧检查。

其余审查无阻断：准确九文件、新包、settings无条件拒绝插件解析、固定bootstrap与严格validator的SOURCE-ONLY实现。39/39纯Python测试同次原始exec-9394a902-0612-4af6-9f7e-fa8b0906da15已实核，退出0、0.063秒、stdout1084/stderr0，无超时/截断；编排TypeError在进程调用前，不构成重跑。测试仅覆盖合同，不覆盖Android路由。静态/空白预算已耗尽且发生在路由补充前，最终源码由Work只读审查。

summary SHA256 5612BCC9D4CDB4F74139583ACE5BCABD93617A851488FC044754A3F4B09954AE。最终manifest CAE490260B4CD9AE8740F810BD6EA0C553F9F5D2DEF5E7567C233035FEA9F69A；MainActivity 7C84B23C554FAD528126151E00AB1B63B9E179A2DFCDDD5A13AA4AC9A203176F；validator A4F93BD498DC835D556A4F52FC0A457FECEDB7203304B8A1E59EF6FD03244924，均与候选一致。原测试PASS和耗尽预算保留，候选不自接受；没有真实构建/设备执行。M5仍NOT_READY，全部既有工作区/真实数据门保留。
