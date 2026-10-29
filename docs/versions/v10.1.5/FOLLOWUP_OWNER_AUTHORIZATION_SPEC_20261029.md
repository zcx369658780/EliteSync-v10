# FOLLOWUP_OWNER_AUTHORIZATION_SPEC（提议，未获授权）

本文件只提供一次集中决策所需的精确范围，不派发任务，不增加当前预算。当前所有真实运行仍0。

## A：软件运行与实例资格（建议下一最小包）

- 固定本候选Commit、apps/services Tree及完整工具Hash；新的发布任务Blob和新task_id/attempt，唯一新运行根名称 v1015-mainline-live-<OwnerID>-20261029。同一ledger跨会话，禁止重建计数。
- 新MariaDB10.11.19私有实例：database elitesync_v1015_mainline_e2e_20261029，127.0.0.1:43349；actor v1015_e2e@127.0.0.1，固定server_id及task-owned datadir。MariaDB启动上限2（初始化bootstrap和失败均计），PHP API 127.0.0.1:43359启动上限2，禁止自动重启。任何端口被占、实例/身份/授权不符即STOP。
- 新空库迁移1次，fixture种子事务1次（10个普通虚构账号、5组独立关系；不能reset旧库）；最多160个HTTP操作、48个PHP fixture/观察CLI，失败也消耗。仅新合成schema赋权，不允许全局/GRANT OPTION/PUBLIC test privileges。无SQLite替代。
- 私有PHP/vendor/source配置闭包1套、Flutter3.41.7/Dart3.11.5私有SDK/Pub只读源镜像各1套；下载0、升级0、共享写入0。工具Hash、旧私有patch原件/LF差异重新资格化、真实Windows路径/子进程/写入闭包必须先独立成立；不能继承旧6/6额度。
- 仅对3个新增Widget回归和受影响原测试：Flutter test/analyze合计最多3批（含失败），不重跑整77集合充当E2E；类型/编译错误在同版有界修复并在该总数内验证。PHP及场景运行绑定同一源码Manifest。
- 新增logical/allocated分别上限8GiB（仅新根，不能删除旧证据腾空间）；软件运行窗口最多90分钟，操作前flushledger、保留失败，达到次数/空间/时间上限即STOP。旧SDK/源码/Hash/账本只读具名核验，旧ACL/Seed/数据库不作fixture。
- API驱动允许一像素合成PNG；短视频需另给获准制作/已核来源且<=128KiB的合成H.264 MP4和Hash。未有合法FFprobe/媒体处理资格时视频场景STOP为NOT_RUN，不禁用验证、不伪造READY。无RTC或Push网络。
- 测试专用PHP server.php与eligibility callback必须由Astra先审；其仅testing资格接线，实际业务授权、路由和持久模型保持真实。API服务context/Hash/root和运行源码来自同一候选，禁止生产入口挂载测试接线。

该包能取得“当前源定向Widget＋真实新MariaDB/API协议与唯一性”证据，**不能**独立买到实际APP UI/Keystore/物理时间/真实Push或整版接受。

## B：同源APP实物（须Owner另行明确激活）

- 必须先具备独立获准且闭合的Gradle/G2/构建安全前置；本提议不放行G2，G2 Popen/claim仍0。此前G/APK1/1不能重置。若前置不闭合，B保持NOT_RUN，A结果不冒称APP通过。
- 在新授权中单列新APK构建1次、指定Owner批准设备安装/回取1次；设备具体身份/Owner在场授权、签名/包名/Hash和来源必须具名，不能擅换设备。只有该同源APK才可执行6组APP观察步骤。
- APP观察覆盖unknown编辑/附件锁、pause-resume同key、切号晚HTTP/WS、picker/player、重启在线核验锁、同进程离线只读/清理失败、旧通知异步点击。当前没有自动设备点击驱动；由获准操作员执行并收集实际截图/trace。单窗口最多45分钟。
- 物理15/30日需另行保留新样本/时间锚与长期检查点，合成时间不能代替；实际Keystore/删除单列。真实WS路由当前占位，需要下一软件范围决定，不能以HTTP stub当WebSocket成功。
- RTC/AEC/5秒媒体停止、真实Push、现网/第三方费用、ACL、restricted child均0；AC05仍OPEN。

先A后B只是建议次序，不是自动创建后继或执行许可。完成授权包后仍交一个集中候选/实物回执，STOP等Astra；不合main或进入v10.1.6。
