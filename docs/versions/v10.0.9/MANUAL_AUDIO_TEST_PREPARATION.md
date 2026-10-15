# v10.0.9 Owner人工双端试听准备

2026-10-16（Asia/Shanghai）。**AUDIO_DEVICE_VALIDATION_BLOCKED / NOT_CANDIDATE_DELIVERED / NOT_ACCEPTED**。

本次只读核对和离线准备，不修改冻结计划/产品源码，不启动服务，不读取或操作真机，不执行ADB设备枚举，不重复模拟器gRPC injectAudio/streamAudio。原视频、附件、撤权、失败证据及 [EXECUTION_REPORT](EXECUTION_REPORT.md)、[RUNBOOK](RUNBOOK.md)、[Manifest](manifest.json)原件保留。本文件不是新计划或新的设备/网络权限。

固定计划Commit `68d57f755d0091bc15cb867b96d3a21caee83690` / Blob `042cf7298b75169a89b1dcd7c9fb113f6ddd72e3`。本轮读取实际main仍为 `03c7de98d79c3075d4b3adb93a9b383dd342377f`；进度分支HEAD `844402af3b1aa465e502359d3f396da9b9167b44` / Tree `f16e8376b4e6b5923433f755b69ef45da3ccaceb`，身份与Owner给定一致。专用树没有对应代码图谱，本轮只读具名文件和固定上游源码，没有重建图谱。

## 一、实际发现

| 项目 | 本轮可核事实 | 不能据此宣称 |
|---|---|---|
| 当前运行环境 | Docker `desktop-linux` API管道不可用，inspect exit1；宿主指定TCP端口无监听、7882/UDP无endpoint。原容器/volume的最后停止状态见旧manifest，本轮未启动或改变 | 当前SFU健康、当前Docker端口映射已实际复核 |
| 受控信令 | `prepare-sfu.py`发布127.0.0.1:7884/TCP；`rtc-gateway.py`每次validate/WS经Laravel当前权限门；原SFU7880仅容器loopback | 直接开放原7880或在信令故障时回退原SFU |
| UDP媒体 | 保存的私配为node_ip=10.0.2.2、udp_port=7882、use_external_ip=false；原脚本仅发布127.0.0.1:7882/UDP | adb reverse已经转发UDP；真机能够使用AVD的10.0.2.2宿主别名 |
| TCP媒体 | 保存配置有tcp_port=7881，但原Docker脚本**没有发布7881/TCP**；不能称已有可用TCP回退 | 配置字段存在即等于真机已能传输媒体 |
| 实际ICE路径 | 当前产品RTP日志明确排除candidate/address/credential；无运行通话，当前selected candidate pair为NOT_OBSERVED | 用静态node_ip或RTP包增长猜测实际选中了TCP/UDP |
| 物理包ABI | 离线读取第四轮APK：仅lib/x86_64，含libflutter.so/libapp.so；SHA256仍为3358c629a9884e433cb501d02b364e2aea4c2354f33cd3b5003817d4cd8674cc | 该包可直接安装/运行于常见arm64真机 |
| 构建原因 | `apps/android/app/build.gradle.kts`本地开发门强制x64 AAR与x86_64 abiFilters；普通ARM构建另有正式默认地址 | 为了得到ARM包而取消本地开发门、使用普通生产配置 |
| APP音源 | 当前RTC调用系统麦克风；没有文件音轨/合成PCM的RTC发布入口。上一轮AVD未带allow-host-audio | 附件播放器音轨或本机播放WAV自动成为RTC发送源 |

原始安全检查与离线包核对位于Q/manual-20261016，Q仍为旧报告证据根。本轮安全摘要见 [manual/readonly-preparation.json](manual/readonly-preparation.json)。没有对私人设备读取、安装、控制、录音或修改。

安全原始流保存在manual目录：`host-tcp-confirmed.{stdout,stderr,exit}`、`host-udp-confirmed.{stdout,stderr,exit}`均exit0；`docker-rtc-readonly.{stdout,stderr,exit}`、`docker-db-readonly.{stdout,stderr,exit}`均exit1，保留引擎不可用原错误。文档JSON解析、相对链接和NOT_RUN默认值检查exit0；原dirty根HEAD/index/status摘要前后相同。产品源码、冻结plan、原执行报告/runbook/manifest对进度提交无差异。业务测试、构建、设备安装及双向试听本轮NOT_RUN。

## 二、推荐的最小网络方案：先验证USB-only ICE/TCP

**建议，尚未批准、尚未应用、尚未实测。** 它是具名7881/TCP媒体回退，不把TCP冒充UDP。

| 用途 | 手机/AVD一侧 | 宿主/容器一侧 | 权限边界 |
|---|---|---|---|
| Laravel APP API | 各自127.0.0.1:8000，经该设备专属ADB reverse | 宿主loopback8000→8001 | 仍按原真实账号认证，不转发内部授权8002 |
| RTC信令 | 各自127.0.0.1:7884，经该设备专属ADB reverse | 受控网关7884→容器原生7880 | 每次首入/重连/旧JWT均重查当前call、CN/MC/revision与处罚 |
| ICE/TCP媒体 | 各自127.0.0.1:7881，经该设备专属ADB reverse | **拟新增**127.0.0.1:7881/TCP发布至SFU媒体端口 | 仅加一个loopback TCP映射；不新增外部转发服务/网卡绑定/防火墙规则 |
| UDP | 本USB方案不使用 | 原UDP配置和证据保留；临时USB配置不发布UDP | 不使用ADB reverse解决UDP，不开放50000～60000 |

临时本地SFU配置的拟改字段：node_ip=127.0.0.1、use_external_ip=false、tcp_port=7881、force_tcp=true、enable_loopback_candidate=true。原受控网关、私配密钥、独立watchdog、撤权DeleteRoom/故障停服和7880隔离不变。只替换经核归属的本0.9临时SFU容器，不动数据库/volume；先保存原配置和安全inspect以便恢复。**当前没有执行这些改变。**

依据是官方v1.13.10源Commit `e5655ac20267fa5005dccaf3f0e3bfc3ea688c07`，与既有官方镜像source revision一致：[config-sample.yaml](https://github.com/livekit/livekit/blob/e5655ac20267fa5005dccaf3f0e3bfc3ea688c07/config-sample.yaml)、[go.mod](https://github.com/livekit/livekit/blob/e5655ac20267fa5005dccaf3f0e3bfc3ea688c07/go.mod)。其锁定mediatransportutil `f234b534b095` 的 [config.go](https://github.com/livekit/mediatransportutil/blob/f234b534b095/pkg/rtcconfig/config.go)定义ForceTCP/EnableLoopbackCandidate；[webrtc_config.go](https://github.com/livekit/mediatransportutil/blob/f234b534b095/pkg/rtcconfig/webrtc_config.go)在ForceTCP时不启用UDP network types，并支持显式node IP重写与loopback candidates。这是**源码可行依据，尚非客户端兼容/真机连通实证**。

批准后先证明：两个端点确实选用ICE/TCP，发往127.0.0.1:7881；信令只经过7884；原7880不可达；server下发ICE列表没有未批准的外部STUN/TURN。不能只填空stun_servers便声称无外联。现有RTP日志不足以确定selected pair，若需要最小脱敏ICE观测变更，应明确记录源码差异并按实改重新关联包，不输出私网地址/JWT。

7881是ICE/DTLS/SRTP媒体端口，不是第二个JWT/HTTP信令入口；其存在仍需证明不能复用旧会话继续媒体。当前SFU强制关闭房间和独立watchdog必须在这条TCP路径上回归，不能照搬前一UDP路径的≤5秒结论。

若USB/TCP实测不兼容，才提交局域网备选：仅一张Owner指定网卡的具体宿主地址:7882/UDP、仅指定真机源地址、必要的最小防火墙规则与同网段检查。7884/API可继续走USB，7880不开放。不自动尝试LAN绑定、提权、防火墙或TURN。

## 三、Owner需要确认的具体事项

1. **真机归属与ADB许可**：Owner具名给出机型/测试设备别名，并明确允许该设备的ADB授权、必要安装和本版APP操作后，才核serial/Android版本/ABI与本版包名是否已存在。原始serial仅LOCAL_ONLY；只查测试所需元数据，不枚举个人文件/账号。若已装com.elitesync且含个人数据，不默认覆盖或清数据。
2. **限定网络选择**：是否批准上述USB-only 7881/TCP、loopback ICE及指定两端reverse的最小验证。当前尚无宿主网卡/防火墙/新转发服务授权。
3. **模拟器稳定输入**：Owner指定已有PC麦克风或已有隔离line-in/音频接口，并明确允许它仅在本次测试期间作为AVD系统麦克风采集合成声。启用AVD host audio会实际打开相应宿主输入，当前不自动启用、不安装驱动。若没有这种路径，保持模拟器→真机方向BLOCKED，另请Owner决定替代测试端；不恢复gRPC注入。
4. **仅实际ABI缺口时的构建**：先核Owner指定机型；若为arm64，现有x64包不兼容，需明确允许必要的本地开发ARM兼容调整/构建并保留现有AVD包。不得为了满足ABI而关闭restoration安全门或换普通生产构建。若包ABI已兼容，不因换设备重复构建。现在未改构建脚本、未重建。

以上只有实质边界需Owner决定；之后的常规恢复服务、真实表单/同意、构建诊断及定点回归仍在原冻结版本内自主完成，不新增逐步骤审批。

## 四、已离线准备的虚构音及听辨方法

文件仅在Q/manual-20261016/synthetic，参数/完整hash见 [manual/synthetic-sources.json](manual/synthetic-sources.json)。本轮只生成文件，**未播放、未采集、未RTC发送**。

- A音：440Hz、三次较长脉冲，5秒；供模拟器→手机方向辨认。
- B音：880Hz、两次短脉冲，5秒；供手机→模拟器方向辨认。
- 连续音：660Hz、45秒；仅供授权撤销停止验证，避免5秒短片自然结束被误判为撤权有效。

文件播放不是RTC发送。必须让已经指定的发送端麦克风/line-in**实际采集**该音，再经APP发布→SFU→对端订阅/解码→实际扬声器或耳机播放。设备播放、声学耦合、音量与回声消除是否可用仍NOT_RUN；不要用系统录音、录屏音轨或gRPC speaker stream保存Owner声音。优先耳机/隔离输入避免反馈啸叫，Owner自行控制实际音量。

先分别试听两方向，要求Owner在**接收端**确认听到了哪一种脉冲模式，而非仅看到发送端播放或包计数。然后在同一有效call/room进行双向并行发声/接收确认，补充静音/恢复。只单向可辨、仅解码计数增长、只听到本机回授或来源无法分辨，均不得将AC-09-03登记为通过。没有稳定合成采集路径时，不能把附件播放、应用提示音或系统播放共享冒认为已完成的RTC麦克风链。

## 五、人工测试记录与后续顺序

使用 [manual/listening-receipt.template.json](manual/listening-receipt.template.json)，所有结果默认NOT_RUN、人耳确认默认null。仅Owner实际回应后记录其原意、对应方向和宿主收到确认的时间；Codex不能自动填写“已听见”。

1. 设备/ADB、ABI、输入、USB/TCP边界都明确后，按现有runbook恢复**仅0.9**资源。Docker API不可用是当前前置问题，先正常恢复既有开发引擎，不升级系统或切换到其它生产环境。不得init/seed。
2. 当前数据以原持久库为准：Bob3最后保留restrict处罚3和申诉1。正例前用授权Blade按该条处罚restore，并重新完成双方当前MC；不直接改字段、不复活旧token、不替换旧证据。每个APP各自正常登录虚构账号。
3. 先证实真实呼叫/响铃/独立接听、同call/room、双方麦克风/扬声器状态、当前权限、实际ICE传输；再做两方向与双向并行听辨。RTP inbound/outbound、非零decoded frame/能量是佐证，必须与人工确认同时成立。
4. 成功后接续原8AC中未完成的拒接/忙线/未接/连接心跳超时、麦克风与摄像头拒绝、静音/切换/前后台/旋转、真实断线及当前授权重连。USB-only下关闭Wi-Fi不会证明媒体断线；Owner可控的USB拔插或经验证真正断开传输的限域故障才算断线，不把移除reverse映射本身当作已切断现有连接。
5. 分别完成CN/MC撤销、block、restrict/banned、end、旧未过期JWT、SDK刷新/自动重连、跨call/epoch、原始SFU绕过、DB/网关/SFU未知故障矩阵。≤5秒测试在T0前后保持连续合成源和真实双端有效媒体；源不能自然结束或先静音。关联服务端失效/ACK、主机接收两端媒体/释放事件的时点及Owner实际听辨，记录测量精度。Owner反应时间不是精密停止时钟，不能单凭听辨确认计算≤5秒。
6. 私有视频须实际观察播放进度从0推进并播放到结尾，再在正播放时撤权，证明播放器停止/缓存失效，完整/Range继续拒绝；补齐失败/重复/非参与者等原矩阵。旧起播截图继续保留，不升级成完整播放证明。
7. 只按实改运行必要回归，最终包与源码/hash/两端身份关联；保留安全stdout/stderr、真实exit和原失败。全部8AC齐全才发布候选并等待Astra终验；只有单向或仍有设备/网络阻塞继续报告BLOCKED。

## 六、证据与敏感信息

主机收流记录使用同一宿主wall clock＋monotonic时间；每条设备日志另标其设备epoch，禁止混用AVD/手机漂移时钟求停止耗时。人工确认记录“宿主收到确认”的时点，不伪造耳朵听到的精确瞬间。

安全输出仅包含虚构账号ID、设备别名/脱敏身份、call_id/room、当前CN/MC revision、音量/静音状态、RTP/decoded统计、传输类型及脱敏candidate类别、人工确认和原始退出码。原始JWT、密钥、私网网卡地址、真实serial及完整未经筛选日志仍LOCAL_ONLY，不公开Owner音视频。不会开启SFU录制/egress或音频采集落盘。

本轮产品源码/包、旧报告、旧manifest、数据库、容器、AVD和系统网络均未更改。准备不等于设备或网络已获授权；上述三项状态保持。
