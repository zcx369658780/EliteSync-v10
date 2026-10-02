# APP-M5-12｜Work独立审查｜2026-09-30

**LEVEL 2 ACCEPT / CLOSED SOURCE-ONLY；M5-11九文件经本修复后的最终源码获限定接受。** Work审查最终manifest/MainActivity与SDK来源链；独立Sol/high NO_FINDINGS。唯一false开关由application直属移至.MainActivity，固定getInitialRoute=/home与debug/synthetic门保留；ActivityInfo.metaData→shouldHandleDeeplinking→delegate新Intent导航helper读取链由本地官方两Java源定位支持。仅静态闭合此前位置问题，插件仍可收到新Intent，不能称已阻断所有插件Intent处理。

最终九文件hash逐一匹配M5-11八文件和M5-12新manifest，未重跑测试。manifest SHA256 A7433272D1CAD6D9ACE5445F7EF3D3C56FF3C79F4B0B618B15EC183D7A6EF432；M5-12 summary BD1E2ED91321DB0D51ED88761E0C4F8BB5A54B4CA4C928DBD29B0A2AB700625B。旧M5-11 REJECT原样保留，被本次正确源接线修复取代；39/39合同PASS回执及旧预算不变。

M5-12一次XML进程退出0、0.079秒、stdout219/stderr0，无超时/截断，唯一Activity false/application无开关/其它XML语义与准确字节移动PASS；空白PASS。编辑前CRLF匹配断言失败发生在写入与XML启动前，原hash未变；实际写入1次/验证进程1次，无XML复跑。官方源码读取/静态预算耗尽。

此接受仅源码准备。settings仍全拒绝构建；merged manifest、生命周期、host编译、产物/签名/未来AAR与SDK版本绑定、配置/依赖/数据及网络隔离仍未证，M5 NOT_READY。main HEAD不动，无构建/设备/真实数据或Git动作。最新执行会话实际11 turns、idle，继续沿用；后继仅SDK构建调用链的只读合同，不放行构建。
