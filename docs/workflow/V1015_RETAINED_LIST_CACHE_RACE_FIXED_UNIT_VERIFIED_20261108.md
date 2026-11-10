# 保留列表刷新共享缓存竞争修正，47项定向检查通过｜2026-11-08

**CONTROLLED_CACHE_RACE_RED_TO_GREEN47 / SOURCE_FIX_1F936D25 / APK_NOT_REBUILT / DEVICE_EFFECT_UNKNOWN / G2_FALSE**

Owner授权继续代码层复现/修正，另明确先解决功能，UI最后按“我的和设置→消息列表和聊天→首页及主要导航”。源码1f936d253dbccceb2c719ea16de4f25be2789b4d：正常在线列表刷新不再全局作废共享缓存代际；真正离线恢复仍执行全局重验。账户/关系撤权、15/30天、时间异常、加密写失败等保护不放松。仅新增真实路由保留双页回归、修列表单一条件及既有测试fake同步签名；PrivateCacheService/聊天源码和后端服务不改。

新回归在picker pause/resume、聊天对象写/上传响应挂起期间先完成底层列表GET。旧源码RED实际出现锁页并失败（root1/controller32，61秒），修正后GREEN47项通过（root/controller0，23.453秒，峰Job2376912896B）。其中新正常发送和真实fake-store写失败仍锁页两例、可靠性21/socket4/cache15/list-cache5通过；GREEN82输入与当前产品逐hash一致，RED差异仅列表源码。每阶段一次已耗、无重跑；4GiB Job/5120MiB启动/64进程/300sSDK-360sHost/45s收尾/8GiB卷/2GiB输出/离线保持。清理无错、五个SDK关键hash不变、legacy version仍无、SDK复制0。

两阶段stderr的隔离assets/config目录缺失诊断保留，不称完整素材环境验收。非作者代码/原证复核无P1/P2，非外部验收。该受控机制已修，真机唯一根因及新候选设备效果仍UNKNOWN。当前已装包66524ef6…仍旧65b，**本修正未产新APK、未装机/媒体复测**；本轮ADB/后端/构建/安装均0，旧STOP和已耗额度保持。

LOCAL_ONLY根名v1015-retained-list-cache-regression-20261108-case01，读IMPLEMENTATION_REPORT.md、verified-red-green-bindings-private.json、两phase原始日志/outcome与最终回执。ledger承接23892项仅追加，不重扫旧SDK/AVD/Sources。原dirty main255/index及%SystemDrive%保持。UI问题及Owner排序见[UI收口计划](../versions/v10.1.5/UI_COMPLETION_PLAN_20261108.md)，尚未进行UI改造/截图验收。仍10 PARTIAL/AC05 OPEN/G2 false/真实Push PENDING，不合main/发布、不启v10.1.6。
