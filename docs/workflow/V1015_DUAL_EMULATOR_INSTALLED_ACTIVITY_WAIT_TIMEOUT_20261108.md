# 新隔离模拟器启动/安装成功，APP Activity等待超时停止｜2026-11-08

**EMULATOR_BOOT_INSTALL_VERIFIED / ACTIVITY_WAIT_TIMEOUT_STOP / APP_FIRST_FRAME_UNKNOWN / PHONE_NOT_RUN / BACKEND_SPENT_0_REMAINING_1 / G2_FALSE**

Owner当前提出“先启动一个android模拟器，来检查APP是否正常（让模拟器和手机分别登录两个测试账号，尝试让这两个账号互相对话）”。另报告当前手机亮屏解锁，但没有留意此前返回是否切页；不倒推旧测试屏幕状态。按新双端目标建立完全隔离AVD/home/state/userdata/nonce/Job/私有ADB，新phone阶段不复活任何旧STOP，不重编或重装手机；原未耗后端1经Q→S→case01原子独占转交，新增后端次数0。

实际模拟器启动、同b621 APK交付文件一次安装Success，ARM64 native bridge资格fresh通过：abilist含x86_64/arm64-v8a、libndk_translation.so、exec1。启动可用13628MiB/磁盘332159066112B；guest2GiB/2核、Job6GiB/64进程、900秒SDK/950host/45清理/2GiB输出。实际入口66.687秒；controller root0/64.208秒，峰Job3775107072B。SDK继承428项具名清单仅ID/size及5关键二进制hash，不目录重扫或全镜像hash；新AVD数据保留，旧AVD未启动/修改。只编译了资源控制器，没有Android应用构建。

唯一Activity命令exit0，但Android输出`Status: timeout / LaunchState: UNKNOWN (-1) / WaitTime:11297`，脚本要求Status ok的断言失败，立即STOP收尾。元数据确认正确启动组件com.elitesync.MainActivity，不是错入口；没有取得APP首屏、字段焦点或package退出原因，**不能把系统Activity等待超时直接判APP崩溃/聊天或缓存修正失败**，也不能把安装Success当APP可用。模拟器36条boot/control ADB、安装1/Activity1，独立UI0；自有Job退出和私有ADB5076关闭核验通过，cleanup_errors空，无重启/重装重试。原始stdout/stderr、Vulkan/端口警告保留，不据此确诊原因。

手机本轮ADB0，累计之前34/240，剩206保持；没有backend claim、Docker/DB/API启动或媒体/双端账号操作，后端仍0耗1余。case01全scope与backend入口追加STOP封口，旧phone/claim及转交原件保留。双方实际登录/文字互发/DB读回、本轮媒体/冷启/播放/撤权均NOT_RUN；已装新1f源码候选的真机媒体修正效果仍UNKNOWN。

新case02候选仅准备，**未批准/无transfer/claim/动态**：新AVD/root/nonce及本地controller，不复活已耗一次。仍同b621包、无构建/手机安装，手机206+旧34≤240、模拟器一次启动安装/15分钟硬限，后端仅继承同一个未耗1（不重复申请）。只改测试首屏判定：Activity仍一次，ok或timeout均先记NOT_YET_VERIFIED，在同实例最多180秒/24份原生观察，必须本APP真实“账号登录”+两个空enabled字段且点后mobile实际focus才ready；明确Activity错误立即停，绝不把超时当PASS。失败在原45秒内采集该package exit-info再停止实例。9项host纯检查通过，非作者候选静态及原停止原证复核无P1/P2，最终48项payload零差异；非外部验收、非实际Android通过，不因本候选自动续额。

LOCAL_ONLY当前根v1015-emulator-redmi-dual-chat-20261108-case01，读IMPLEMENTATION_REPORT.md、emulator Activity stdout/failure/stop/controller result及最终回执；新候选根同名前缀case02，读PREPARATION.md、proposal与非作者复核。准备复制二进制fixture的UTF8错误在任何新SDK/claim前保留并纠正；新候选AVD暂存文件名纠正时仅移其两个未运行的小配置到自身retained-preparation目录，未触旧运行AVD。ledger承接24970项，只追加当前/候选/上次最终回执及新转交；新运行AVD大文件仅保存生成元数据清单并保留，不反复hash或扫描旧SDK/AVD/Sources。原main255/index与产品%SystemDrive%保护，apps/services树不变，仍10 PARTIAL/AC05 OPEN/G2 false/真实Push PENDING，功能优先/UI最后，不合main/发布、不启v10.1.6。
