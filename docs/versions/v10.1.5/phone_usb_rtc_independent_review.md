# EliteSync v10.1.5｜单真机 USB RTC 专项 Astra 独立复审

日期：2026-10-22（Asia/Singapore）。
**INDEPENDENT_PHONE_RTC_REVIEW_COMPLETE / PARTIAL / NOT_ACCEPTED / AC05_OPEN / ICE_MEDIA_PATH_NOT_ESTABLISHED / SOURCE_UNCHANGED / OWNER_DECISION_REQUIRED / MAIN_PRODUCT_NOT_INTEGRATED / NO_AUTOMATIC_R2 / V10.1.6_NOT_STARTED**。

本独立裁决以固定GitHub提交、原冻结任务、Codex集中交付报告与清单为依据。Astra不声称曾直接操作Windows、真机、数据库、SFU或LOCAL_ONLY原始日志，不能把Codex执行回执直接升格成Astra现场运行证明。不得更改v10.1.5冻结AC-10.1.5-05，已接受v10.1.4仍为main产品。

## 1. 直接核验的身份事实

- 单真机任务：`docs/versions/v10.1.5/OWNER_APPROVED_SINGLE_PHONE_USB_RTC_TASK_20261022.md`，Git Blob `b4d048ac931d66500e8d312fb7d80eb790121216`。Owner仅授权一台经USB实际连接的安卓真机、测试APP麦克风采集外部合成音、必要USB TCP reverse及受控本地服务；没有授权额外物理设备、宿主麦克风/摄像头、LAN/UDP/防火墙/UAC修改、新SDK、付费服务或公开部署。
- 复审前live `main` 为 `d161388a53b06bd71b33f85a9fe1df7b110bfba1`，其产品仍是已接受v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 本次候选 `fe2e4397e4db894257276238c1a3118ba3c6a5f9`，Root Tree `b7a2dc5c3071e52c57cd14be82d05651975415fb`，唯一Parent `7a5dc0d85ef82fdfc5db4a098ae4150164e2b999`；父Root `129c35a9163f68991dcc7e862e027f571438b13a`。相对父Commit ahead1/behind0，**仅两个新增docs**：`PHONE_USB_RTC_GATE_REPORT.md`及`phone_usb_rtc_gate_manifest.json`；应用服务没有提交变更。
- **GitHub直接比较完整子Tree**：本次及父提交的apps都为`0784c8aa7b0915a04b83693a45401197e31d93a2`，services都为`1e1e20bb3500bedb1a521e5f2ddeece915d09424`。本轮源码`SOURCE_UNCHANGED`已证实；原R1源码commit仍是`1c5cd2bb7919c435e8486a76959db75e9ccc367f`。
- 报告Blob `bf936c300d6b12b0f4ecae0b083dca277035f784`，manifest Blob `d2e0f15623e7f1a05513f4ae2286f396db523a0c`。两份GitHub文本均已独立读取；manifest中的本地APK哈希、设备与媒体日志只归`CODEX_REPORTED/LOCAL_ONLY`。

## 2. P0–P5分项判断

| 门 | Astra独立判断 | 支持与边界 |
|---|---|---|
| P0 设备、包名、签名及权限 | `SUPPORTED_CODEX_REPORTED` | 唯一Owner手机Android16/API36、arm64-v8a，固定R1开发APP登录运行，回取APK与原开发包hash匹配；原首次安装由用户取消、Owner许可重试一次后成功。真实手机的具体物理操作、哈希属于Codex回执。 |
| P1 USB链路和受保护信令 | `SUPPORTED_BOUNDED_SIGNALLING / MEDIA_PATH_PARTIAL` | USB reverse受限8031/8032/7894/7891、HTTP登录、合成peer受权accept、SFU有一名JOINED参与者；host仅loopback、raw SFU不对外发布，空输入TCP探测成功不等于ICE。第二端是HTTP控制端，**并未运行APP/LiveKit SDK或接收媒体**。 |
| P2 麦克风和媒体 | **`ENV_BLOCKED / NOT_PROVEN`** | APP开始Room.connect后约30.224秒出现`MediaConnectException`；SFU状态`connectionType=unknown`，**60份具有显式tracks字段的样本都为空**，其余655份没有tracks字段（不能直接当零音轨采样）；汇总网络packet/bytes不是经归属的音频RTP。没有证据证明设备捕获到合成音、手机publish或远端收到音轨。 |
| P3 安全和媒体重连 | `NOT_RUN` | 无正在流动的媒体，所以同call重连、撤权后旧RTC JWT首入/重入、撤权COMMIT→≤5秒停止均无合格试验；正常end的HTTP200不能代替媒体安全结果。 |
| P4 源码变动 | `SOURCE_UNCHANGED` | 仅有本轮运行脚本/启动配置的有限修正，产品Git apps/services完全一致，没理由要求整版重新回归或构建。非作者有界文档复核纠正观测715与中途653样本统计差异。 |
| P5 停机与保护 | `CODEX_REPORTED_SCOPED_PASS` | 任务服务、SFU/R1合成DB停止，四个新ADB reverse精确移除；手机APP被force-stop但包与数据保留。5保护根、730既有文件hash、306 refs与私密env不变为Codex具名回执，未由Astra直接核验。 |

技术上，本轮明确阻断于**合法信令以后、有效WebRTC ICE媒体连接以前**。现有证据无法区分ICE candidate的可达性与配对、ADB反向TCP实际媒体语义、SFU配置或其他WebRTC内部故障；不可以将它确定归咎于“Android麦克风损坏”、“产品代码P1”、“一定必须开放UDP/防火墙”，或认为USB 7891/7894 TCP connect已经证明ICE可用。

真实麦克风授权成功并不等于真实采音成功；报告注明麦克风启动位于Room.connect成功之后，本轮未到该阶段。合成WAV已生成但未证明扬声器实际播放，更未证明手机采集声音。不能借此声称已验证AEC/人耳音质。

本版合成测试账号经普通auth路径建立、隔离库测试issuer disabled且is_synthetic字段为false：只能按**独立开发库中的虚构测试用户**解释，不能当作已实名认证或生产真人流程，后续若做数据共享或迁移需仍严格保护身份标记与归属。

## 3. 冻结AC-10.1.5-05独立复审结果

| 硬门 | 裁决 |
|---|---|
| 双端APP双向流动音频 | `NOT_VERIFIED`；一台PHONE_A与HTTP控制端不构成双APP |
| 同call真实媒体重连 | `NOT_RUN` |
| 撤权后旧RTC JWT首入/重入拒绝 | `NOT_RUN` |
| 撤权COMMIT后已流动媒体停止≤5秒 | `NOT_RUN` |

所有未执行的硬门继续OPEN。没有产品源码变更，不推翻此前v10.1.5 R1 Android可信时间注入34项、加密测试密文清理、真实消息同键重试、私有图片/视频Range及有限Safety通知已证成果。实际设备RTC双端音视频/AEC与真实Push仍保留其原独立门禁。此前综合WS命令exit1不会被本次控制信令成功覆盖。

## 4. 风险、保护与下一门

- Codex报告一项**本地证据工具输出边界问题**：原ICE candidate网络地址曾流入LOCAL_ONLY工具会话，最终公开报告和manifest使用字段白名单，未包含原地址、手机序列号、SQL/APK、token或真实私密音频。此事实保留，不宣称发生外部泄露，也不删除本地原证。
- 原首次安装授权拒绝、初次activity/cwd/Windows监听枚举错误以及最初旧资料对照脚本误读均如实在执行报告中保留，最终保护判断只使用修正后的确切回执。
- Codex声称既有SQL旧178行精确保留、原六位既有用户没改、本任务创建虚构测试账号7/8、5历史根/730旧文件、手机数据未清、已停自有服务与USB reverse。这些均为`CODEX_REPORTED`，不应被Astra形容为Windows和Android现场实核。

**正式终审结论**：`V10.1.5_PHONE_USB_RTC_INDEPENDENT_REVIEW_COMPLETE / PARTIAL / NOT_ACCEPTED / AC05_ICE_MEDIA_PATH_BLOCKED / OWNER_DECISION_REQUIRED / NO_AUTO_R2 / PRODUCT_MAIN_UNCHANGED`。本候选的价值是证明设备安装、业务权限与受保护信令路线，而不是RTC媒体安全通过。现在尚无可验证音频流，继续追踪四硬门缺乏前提。

Owner此前选择**方案A**——原AC保持不变，RTC独立阻断。建议不要重复相同USB reverse＋HTTP peer的通话尝试，而应将下一动作严格限制为**先厘清一条合规、当前设备可使用的ICE候选/媒体传输路径**。可以先做只读ICE candidate/端点/协议及已有SFU配置证据审计，明确是否有在现有已授权条件下的受控TCP ICE方案；若确需真实LAN、UDP、端口、防火墙或第二个APP端，则由Owner对具体接口、最小权限和回滚单独批准。不能以本轮`PARTIAL`自行派发R2、开放raw SFU/网络、安装SDK、改变冻结AC、集成`main`或启动v10.1.6。

本轮只完成独立GitHub核验与结论归档，**未操作Owner手机或云/本地服务**。
