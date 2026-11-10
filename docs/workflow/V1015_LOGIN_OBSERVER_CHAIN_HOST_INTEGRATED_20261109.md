# 登录观察器调用链主机整合，45项检查通过｜2026-11-09

**LOGIN_OBSERVER_CHAIN_HOST_INTEGRATED / HOST45_VERIFIED / DEVICE_NOT_RUN / OLD_STOP_PRESERVED / BACKEND_SPENT_0_REMAINING_1 / G2_FALSE**

Owner“可以请继续”后，仅继续普通工程整合；实际产品根/remote/分支/HEAD d6e5fe91、仅%SystemDrive%/及干净index与上一回执一致。新私有主机包名v1015-login-observer-integration-host-20261109-case01，旧case03运行与上一局部helper均不覆盖。产品源码、APK、SDK/AVD、设备、数据库及全部STOP不改；本轮没有设备或服务运行、新授权或额度消耗。

现在完整表单和聚焦态分开验证：完整基线必须fresh同时显示本APP唯一手机号/密码框，启用且为空（或手机号为刚输入的固定测试值、密码仍空）；基线绑定当前request SHA256、端serial、APK，最多180秒且拒未来时间。聚焦后可以仅见目标框，但必须fresh/own/唯一/正确类型/启用/预期空值；隐藏框只保留此前已观察事实，不作为当前空值证明，不复制旧节点/坐标来输入。foreign、非空错值、disabled、重复角色、冲突焦点仍拒绝。已确认登录surface暂时0字段仅供原fresh/deadline内只读等待，不生成基线或输入。

调用方已一起整合：startup采用上一局部focus helper并把同次完整基线写入ready；prepare-login消费同端有效基线，已有正确焦点不重复tap，没有基线则先获得完整表单；两端focus helper支持受约束的单框聚焦态。实际登录初始只读确认→手机号输入一次→完整新树读回测试手机号/密码空→从新节点单tap密码→fresh焦点后输入一次→完整手机号读回/同意/提交；不因字段隐藏跳过手机号核验。pre-backend焦点确认改为只读，backend authority同步核同scope/端/时效基线。Phone.text原有fresh唯一正确空enabled输入门保留。

非作者初审发现P2：键盘关闭后focus可保留，单凭focus发Back可能退出APP。现只有独立当前IME状态唯一mInputShown=true，且其后单一mCurrentFocus确为本APP，才在同一个30秒期限内发一次Back；false/unknown/冲突只读等或停，foreign foreground直接拒绝。IME原始输出不落盘，只保存bool/null；未来设备是否提供该字段仍UNKNOWN，不支持时不能猜测或Back，须只读停止。不得把这段主机协议当作已获设备资格。

两端真实导航函数的主机回放先RED：初始5项中同一个单框流程在phone/emulator两子例均因旧len!=2阻断，原文保留；修改后完整45项通过，含原15项fresh/transport检查、上一12项真实XML startup回放、新准备/双端导航/输入拒绝/跨端跨request与过期证明/只读pre-backend/create-once/IME关闭或未知/foreign foreground等。测试调用实际导航及Phone.text，但设备接口以有边界的主机替身替换，不证明Android输入、登录、DB或发送通过。非作者最终P2关闭，无剩余P1/P2，非外部或Owner产品验收。

本包明确HOST_ONLY：没有run-contract/actual grant/request/claim/transfer，driver authority直接拒绝，实际Phone.run包括cleanup在任何设备进程前也拒绝；未形成新动态候选。新设备复测前仍需把已审源码装配到新的独立范围并具备新的一次模拟器启动/安装授权，不能重跑case03；其启动/安装已耗，各余0。原后端仍0耗1余、指定到已STOP的case03/backend，不重复申请同一未耗次数；手机累计34/240、剩206。后续资源安排仍以Owner5GiB可用门和先E准备后B为准，900秒总时限不叠加，guest2GiB/Job6GiB/B原3GiB门不擅改。

本地读IMPLEMENTATION_REPORT.md、GREEN-final-45.txt、non-author-final-review-private.json、source-bindings及最终回执；ledger从26187项仅追加主机文件/上一最终回执，不重扫旧SDK/AVD/Sources或大镜像。原D main255/index、产品%SystemDrive%、旧库/备份/所有STOP和私有原证保持。源码1f及此前已装b621身份沿用，双端实际登录/互发/DB、媒体/冷启/播放/撤权仍NOT_RUN、真机缓存效果UNKNOWN；仍10 PARTIAL/AC05 OPEN/G2 false/真实Push PENDING，功能优先UI最后，不合main/发布、不启v10.1.6。私有原证/APK/凭据/SQL/许可证不上GitHub。
