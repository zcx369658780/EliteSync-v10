# 新模拟器二次启动后原生UI无根节点，观察工具缺陷停止｜2026-11-08

**EMULATOR_BOOT_INSTALL_VERIFIED / NATIVE_UI_NULL_ROOT_OBSERVER_PARSE_STOP / APP_FIRST_FRAME_UNKNOWN / PHONE_NOT_RUN / BACKEND_SPENT_0_REMAINING_1 / G2_FALSE**

Owner明确批准“新模拟器一次及双端接续”后才绑定case02 current reply/proposal、新actual grant和case01→case02唯一未耗后端转交。case01的STOP/已耗保持。case02新AVD启动/ARM64 bridge资格/同b621交付一次安装成功，唯一Activity exit0但Status timeout/UNKNOWN/13089ms。随后uiautomator exit0却stderr明确`ERROR: null root node returned by UiTestAutomationBridge.`，没有生成XML；exec-out cat也exit0但stdout是文件不存在的错误文本，旧观察器ET.ParseError而提前STOP。

这证明测试工具没有完整核验stdout/stderr与有效界面文件，是工程观察器缺陷，**不是APP失败/崩溃证据，也没有等完180秒首屏窗口**。package限定exit-info仅有1970/无退出记录，不能据此证明APP正常或无崩溃。模拟器当时power/keyguard/OS画面未测，原因UNKNOWN；不把新null root倒推解释旧手机或选图结果。只读补查旧phone两阶段9份dump及scope05九份picker dump全部完成且stderr空，原旧观测/UNKNOWN保持。

case02共63模拟器boot/control ADB，独立UI适配器0，boot/install/Activity各一次；124.859秒，controller0/122.293秒，峰Job3621453824B，启动可用12934MiB/磁盘328305250304B。自有Job及私有ADB5076退出/端口关闭检查通过、cleanup_errors空。手机本轮ADB0、累计34/240，剩206；后端无claim、0耗1余，无Docker/DB/API或双账号操作。case02及backend入口已追加STOP封口，已耗不退款，不重跑。两个模拟器scope各耗一次，不能把本次工具错误记成额度未用。APP首屏、双端登录/互发/DB、本轮媒体/冷启/播放/撤权均NOT_RUN/UNKNOWN，产品源码和已装phone b621未改。

新case03仅准备（**未批准/无actual grant/transfer/claim/动态**）：先核全新guest Awake/Keyguard/系统PNG与可读原生root，再安装启动APP；只新guest唤醒一次，仅secure=false才dismiss非安全锁，不解锁真实手机。新可见窗口、AVD/root/nonce/控制器，仍Job6GiB/guest2GiB2核/900秒/host950/45清理/2GiB输出，原SDK428清单继承、不重扫旧SDK/AVD/Sources。新控制120（留6清理）+UI160合计280，不增加上一100+180的合计；这是待新批准的独立scope，不复用旧余额。手机仍206+34≤240，后端仅拟继承同一个未耗1，新增0，不重编/重装手机，不做媒体/RTC。

观察器修正只在新候选：dump须完整成功标记/目标路径/无ERROR才读文件，缺失/非XML仅NOT_READY；最多180秒/12份8秒间隔，不重复Activity，不以timeout作PASS。实际空登录2正确enabled字段、单次点后fresh focus才ready；post-focus与两端Phone.dump也拒读旧XML。13项host纯检查通过，包括旧真实错误的RED ParseError→新NOT_READY、nullroot不读文件、旧focused XML不能冒充新focus和OS缺失不准入；非作者原证/候选复核无剩余P1/P2，51项payload及合同零差异；非外部验收、不是Android通过。完整新批准后才可原子新建actual grant/request及parent转交，不重写已保护pending或contract。

LOCAL_ONLY最新根v1015-emulator-redmi-dual-chat-20261108-case02，读IMPLEMENTATION_REPORT.md、emulator boot058-061原证/failure/stop/controller result与最终回执；新候选同前缀case03（PREPARATION、proposal、最终非作者复核）。ledger承接25239项仅追加两根/上次最终回执及新转交；新运行AVD仅保存生成元数据并保留，不重哈希大运行镜像。原main255/index、产品%SystemDrive%、旧SDK/DB/备份/全部STOP保护，apps/services树不变。仍10 PARTIAL/AC05 OPEN/G2 false/真实Push PENDING，功能优先/UI最后，不合main/发布、不启v10.1.6。
