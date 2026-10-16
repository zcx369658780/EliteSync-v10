# v10.0.9 人工音频测试接续记录

2026-10-16。**AUDIO_DEVICE_VALIDATION_BLOCKED / NOT_CANDIDATE_DELIVERED / NOT_ACCEPTED**。不是候选交付，不修改原8AC或原报告/manifest。本记录补充[人工测试准备](MANUAL_AUDIO_TEST_PREPARATION.md)，原视频、附件和撤权证据保持原结论。

## 实际授权和设备

Owner本轮具名指定USB小米25060RK16C（Android16、arm64），指定现有Pixel_6_Pro_2（Android16、x86_64），批准ADB测试、必要ARM适配、USB loopback TCP方案，随后明确批准PC已有麦克风仅采集合成音。原始serial、私配和网络地址保持LOCAL_ONLY。

Owner后续明确“我在”，批准仅当前WLAN具体地址的7882/UDP及两条来源受限防火墙规则和具名UAC操作。实际建立精确Allow及其它IPv4来源Block规则；同一本机来源范围补充127.0.0.1，不增加外部设备。首轮管理员脚本因Windows默认Restricted策略exit1、无规则；第二轮仅进程级ExecutionPolicy Bypass执行同一具名脚本exit0，未修改系统执行策略。规则原件和读回LOCAL_ONLY，不公开家庭网卡地址。

**新增同一WLAN7881/TCP回退尚未批准、尚未应用**。它不同于已批准的USB loopback7881/TCP；精确规则脚本已准备供Owner审阅。

## 产品改动、构建与安装

- `c387994`：本地0.9门下可选arm64+x86_64 AAR/APK；debug独立包名`com.elitesync.v1009test`，保护两端已有`com.elitesync`及数据。新增USB-only TCP配置与脱敏ICE分类统计。
- `c7fee153f74e1df59632004061bfdc49ada1c39c`：本地RTC显式空ICE server列表，不采用SFU默认公共STUN；非本地行为不变。固定LiveKit 1.13.10实际存在公共STUN默认回退，不能把服务器空配置称为禁用STUN。锁定SDK源码确认显式非null空列表阻止采用服务器列表，原生层形成空ICE server列表。
- `5a58cdd2f4267c8cc214a51e7715e8699cca9657` / Tree `96c3f4329b9420d27b76dc9453ea732c4759b40a`：修复首次未登录通知重试占住RTC扫描锁；未认证整轮跳过、8秒外层超时、旧用户/dispose结果丢弃、同步登记timer。ICE日志区分transport_selected、selected_flag和nominated_inference，不能把推断当作实际选中路径。该发现层仅比较userId，不冒称会话epoch授权；最终入房仍由服务端当前权限验证。
- 本次`prepare-sfu.py`后续LAN启动工具改动不改变上述Flutter/Android源码锚。该工具不创建防火墙规则或自行提权；LAN模式要求本机私有的具体批准范围文件。原始7880仍不发布。

最终本轮构建/两端安装源码锚为5a58cdd，不是原第四轮x64包。AAR `Q/artifacts/manual-watcher-flutter_release-1.0.aar`，8,707,299 bytes，SHA256 `65f2e3610798d3a835ba464baeb639129ed5fb484c065fb1a7949eee386062bf`。APK `Q/artifacts/manual-watcher-app-debug.apk`，414,145,599 bytes，SHA256 `26787b5336a5b6e14f6838a7dd1b5a62f30e4b632fae440c5bb5f33d14fd7e9e`，双ABI。两端实际安装base.apk回读同hash。只覆盖本轮独立测试包，不清数据；没有改development release记录或正式分发。

手机首轮安装因系统`INSTALL_FAILED_USER_RESTRICTED`失败；Owner明确允许USB安装后重试成功，原失败原件保留。第一次构建因用户Gradle默认代理127.0.0.1:7890不可用exit1；后续仅本次构建进程覆盖代理属性，成功，未改全局代理或升级依赖。

## 实际呼叫与当前阻塞

| 呼叫 | 路径和观察 | 判定 |
|---|---|---|
| 12～14 | 真实APP创建，未形成及时独立接听，最终missed/timeout；其中首次登录轮询问题及人工操作超时保留 | 未进行有效音频测试 |
| 15～16 | 手机实际点击接听，双方系统麦克风前台权限；同call/room。USB reverse普通TCP7881双端exit0，但RTC MediaConnectException、无有效媒体 | USB纯TCP媒体失败 |
| 17～19 | 获批WLAN UDP；手机transport_selected=udp，真实音频outbound bytes/packets增长；模拟器出现远端track对象，但统计unavailable、ICE未完成，随后MediaConnectException/断开。全部当前call终态ended/peer_disconnected | 不能宣称单向试听通过，更不能双向通过 |

仅重启手机独立测试APP、保留凭据后，旧包来电轮询恢复，确认首次登录路径缺陷；新版已修复且针对性测试通过，但尚未另作真实登出再登录闭环。

有界容器内UDP头部计数与精确虚构探测表明AVD探测包能到SFU。STUN请求/回应存在不对称；这不证明AVD完整双向UDP/DTLS/SRTP已通，也不建立唯一根因。首个计数helper转义错误使结果无效，原件保留；修正后先验证字节常量再运行，发布的是标明validated的脱敏结果。仅保留协议头部计数，不保存媒体payload。没有重用gRPC音频注入，没有录制保存Owner声音。

Owner反馈“对手机和电脑麦克风说话，没看到音频反应”，与未形成可用远端媒体一致，**不是人耳播放成功确认**。本轮尚未播放合成音作实际双向试听；两方向和同时双向均NOT_PASS。不能从包数、track对象、in_call或普通端口可达推导AC-09-03完成。

## 验证和保留事项

- 最终相关Flutter测试36项exit0（真实bootstrap调度、RTC和私有播放器）；局部Dart分析No issues found、exit0。首轮watcher测试编译错误exit1及修复结果保留。
- 最终双ABI AAR/debug APK构建exit0、两端安装exit0并回读相同hash；物理包LOCAL_ONLY。窄非作者审查无当前debug路径阻断发现，保留其仅userId检查等限定。
- 全Flutter/全PHP、全范围分析、本轮真实双向试听、完整RTC权限/拒接/忙线/断线/旧JWT/5秒矩阵，以及视频完整播放和撤权播放器停止补证均NOT_RUN或尚未完成；旧成功不能外推当前最终设备组合。历史Flutter失败和PHP vendor弃用不改记PASS。
- 安全原始构建/测试stdout、stderr、exit及摘要见[本轮证据](manual/20261016/evidence-index.json)。其余本机原件在`Q/manual-device-20261016`；网络、权限弹窗、完整logcat、serial、凭据、包和配置继续LOCAL_ONLY。原始字节hash指本机原件，Git行尾规范化可能改变仓库字节。

## 等待下一门时的资源状态

新增TCP授权待Owner；当前仅0.9 SFU已暂停，宿主AVD音频输入已关闭。0.9 DB/持久volume/media保留，API、独立授权监听、bridge和worker仍仅loopback运行；两端测试APP/Owner启动的AVD保留，没有wipe或操作个人应用。UDP两条精确防火墙规则仍存在，SFU停止后该媒体端口无服务；测试结束只移除本轮具名规则。旧SFU容器已具名保留，不删除原件。原dirty根本轮HEAD/index/status摘要前后相同，未重验全历史文件；0.6～0.8库/卷未操作、0.9未重seed。

收到具体网络授权后继续同版测试；全部8AC完成前不输出候选交付、不合main/K08、不启动后继版本。
