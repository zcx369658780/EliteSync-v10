# 新guest启动前只读状态观察修正，32项主机检查通过｜2026-11-09

**PREBOOT_READONLY_WAIT_HOST32_VERIFIED / NEW_START_APPROVAL_PENDING / ANDROID_NOT_RUN / BACKEND_SPENT_0_REMAINING_1 / G2_FALSE**

Owner确认同一Redmi手机已连接并亮屏解锁；这是Owner报告，未新增设备回核。实际产品根/remote/分支/HEAD63800ecd、仅%SystemDrive%/及干净index与上轮实际保存回执一致。手机连接不解除已STOP的case01模拟器/双端范围或恢复启动额度。

上次原证为启动查询not-found、not-found、offline后按旧transport条件STOP，未进入安装/APP。此次仅修私有启动观察器：新guest首次boot=1之前、精确只读sys.boot_completed查询，且为当前私有serial时，known not-found/offline与空/0记PENDING；只有rc0/空stderr/1才算启动完成。仍受原240秒boot/900秒总时限、控制120+UI160≤280约束，没有新boot/reconnect/重启ADB/重装/重复Activity。security/unauthorized、未知或混合输出立刻STOP；boot完成后offline及手机/后端/UI原安全条件不变。真实离线原因仍UNKNOWN，此修改不是APP修复或运行通过。

提取旧guard的RED源及首次8项失败记录保留；修正后全部32项host纯检查通过，含新增8项真实启动stderr回放与开机前后/错误边界。复制新候选时的一次JSON路径检查失败另存，路径递归修正后通过；最终合同/控制器冻结后32项再次通过。只编译本机资源控制器，无Android构建/SDK/ADB/模拟器/手机/服务/后端执行。非作者Codex只读复核无P1/P2；50项proposal、合同payload5/private6哈希零差异，新root/AVD/userdata/控制器boundary/nonce正确，非外部或Owner验收。

新case02仅准备：拟新一次可见模拟器boot/同b621安装，guest2GiB2核/Job6GiB64进程，启动可用10GiB/磁盘8GiB，900秒SDK/950秒host/统一45秒清理/2GiB输出；手机最多206（加前34≤240）、最多1次Activity，不重编APP或重装手机。先OS Awake/未锁/可读及真实空登录focus，后两虚构账号APP互发文字、APP-family路由与MariaDB密文/解密唯一行、两端退出；所有工作在同一次15分钟内，后端30分钟原上界不叠加。失败即停，不媒体/RTC/真实账号/外部服务/权限改动。

原后端0耗1余仍指定到已STOP的case01/backend，本候选无新批准/actual grant/request/transfer/claim，不重复申请原未耗1、不新增后端次数。新具体范围获批后才原子独占转交；全部旧STOP和已耗保持，不重跑旧入口。LOCAL_ONLY根名v1015-emulator-redmi-dual-chat-20261109-case02，先读PREPARATION.md、proposal-private.json、non-author-final-review-private.json、pure-checks-final-32-after-freeze.txt及最终回执；旧实际失败终态仍在case01/runtime-closeout-20261109。

ledger从25842项只追加，旧SDK428清单继承并仅metadata/5关键二进制检查，不重扫旧SDK/AVD/Sources或重哈希大镜像。原D main255/index、产品%SystemDrive%、旧库/备份/STOP与全部私有原证保护；源码1f、已装phone b621和apps/services树未改，真实双端/媒体NOT_RUN、缓存真机效果UNKNOWN。仍10 PARTIAL/AC05 OPEN/G2 false/真实Push PENDING，功能优先、UI最后，不合main/发布、不启v10.1.6。
