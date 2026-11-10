# 5GiB门通过，真实手机号焦点已证；双框可见性观察误判停止｜2026-11-09

**OWNER_5GIB_STAGED_SCOPE / REAL_LOGIN_MOBILE_FOCUS_VERIFIED / VISIBLE_FIELD_COUNT_OBSERVER_STOP / PHONE_NOT_RUN / BACKEND_SPENT_0_REMAINING_1 / G2_FALSE**

Owner明确“只要5GB就可以，你可以将两个阶段逐步进行”。此次将启动可用内存门改为5120MiB（不是总占用上限），guest2GiB/2核、Job6GiB/64进程和后端≥3072MiB门及容器上限不变。先E准备再B，双端期间必要同时存活，总时限仍900秒。非作者无P1/P2、38项host通过后，按当前指示独占继承case02的原未耗boot1/backend1，不再申请同一未耗次数；父级E/B各新增transfer，旧STOP/请求原文不改，两个new grants均0。

fresh可用8798MiB/磁盘331196145664B通过新门。启动前已知not-found/offline在原界内继续只读观察，guest实际boot完成、OS Awake/未锁/原生root及pre-APP系统PNG通过；同b621安装一次成功，唯一Activity仍Status timeout/WaitTime12333，仅作待证。前三份APP dump nullroot后，033完成/034原生XML实际显示本APP账号登录、两个空enabled框。035只点手机号一次，036 nullroot正确拒读，037/039/041完成，038/040/042三份新XML均显示本APP唯一可见手机号EditText，password=false/text空/enabled=true/focused=true。因此**真实手机号焦点已经观察到**，不再标UNKNOWN或点击无效。

实际停止原因是startup仍调用要求两个可见输入框的login_frame；点后新树只见手机号，三份合格focused记录都被len!=2判None，最终ObservationUnavailable。缺失密码框的具体原因UNKNOWN；符合键盘/viewport可见性变化，但无APP PNG，不能将遮挡原因定论，也不能把不可见密码框当作当前空值证明。没有APP PNG/ready proof或完整视觉/功能验收。exit-info无退出记录，不据此证明或排除崩溃。

45条E控制ADB/153.844秒，启动/安装/Activity各耗1；Job峰4358266880B，controller/root0、148250ms，cleanup_errors空；自有controller退出及5076/5596/5597关闭另核通过。无重启/重装/Activity/tap/input重试。手机本轮0，仍累计34/240、剩206；后端无claim、0耗1余，不新增次数。当前scope/backend已STOP封口，未耗B指定到case03/backend，不凭余额复活入口。没有Docker/DB/API或双账号操作，也没有新测旧容器State。

普通工程另存LOCAL_ONLY主机修正v1015-login-focus-visibility-host-fix-20261109-case01：只新增startup聚焦态helper，要求同次点击前的完整空表单基线，再用fresh唯一空enabled手机号焦点证明；完整表单门保持，不把隐藏框视为空，不用旧节点输入。新增接口RED实际为11个缺函数错误及1项原fullform检查通过，随后GREEN12项通过，含本次三份真实XML、foreign/disabled/nonempty/重复角色/冲突焦点等拒绝；不称12个独立行为RED；它未集成到本次冻结运行，也未形成新动态候选。只读定位还发现prepare-login、两端focus_target、login初始表单及pre-backend二次tap存在同类假设；下一步需完整整合这些调用方及基线时效，再考虑新设备范围，不带着同类阻断盲跑。Phone.text已仅接受fresh正确唯一空focused目标，应保留。

LOCAL_ONLY实际根v1015-emulator-redmi-dual-chat-20261109-case03，读runtime-closeout-20261109/IMPLEMENTATION_REPORT.md、HANDOFF_PROMPT.txt、verified-actual-mobile-focus-observer-stop-private.json及最终回执；PREPARATION及38host为执行前准备。ledger承接25933项，只追加本次原证/父级两transfer/主机修正及上一最终回执；新运行AVD只记录生成元数据，不重哈希大镜像、不重扫旧SDK/AVD/Sources。原D main255/index、产品%SystemDrive%、旧库/备份/全部STOP保护。

源码1f/已装Redmi b621及apps/services树未改；双端实际登录/文字互发/DB、媒体/冷启/播放/撤权NOT_RUN，缓存修正真机效果UNKNOWN。仍10 PARTIAL/AC05 OPEN/G2 false/真实Push PENDING，功能优先UI最后，不合main/发布、不启v10.1.6；所有私有原证/APK/凭据/SQL/许可证不上GitHub，不作为Owner或外部产品验收。
