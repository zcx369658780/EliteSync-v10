# v10.1.8 语音留言节点交接

2026-11-14，北京时间。节点 `VOICE_MAIN_CHAIN_OBSERVED_SCOPED`，整版工程自验 `IN_PROGRESS`，顾问及 Owner 本版接受 `PENDING`。本文件所在提交为本次文档保存点，最终固定 SHA 由同步回读结果给出。

## Owner 本次安排

Owner 于11月14日要求继续，并建议长会话完成一个目标后先交接。到节点先保存本地及 GitHub 的任务进度、Owner 决定和工作流变化，再提供接续 prompt。本会话选择语音留言真实录制、明确发送与另一端播放作为单一目标，现已达到节点并保存交接。

普通工程长期授权延续，后续仍按 [AGENTS](../../../AGENTS.md)、[CURRENT_WORKFLOW](../../workflow/CURRENT_WORKFLOW.md) 与 [本版计划](plan.md) 执行。本次工作流仅记录该会话的交接安排。Owner 保留权限、原主库 dirty/index、受保护 `%SystemDrive%/`、数据和历史证据继续按现行约定处理。

## 工程与候选身份

| 项目 | 实际身份 |
| --- | --- |
| 稳定根 | `D:\EliteSync-v10-product-v1015-20261101` |
| 仓库 | `zcx369658780/EliteSync-v10` |
| origin | `git@github.com:zcx369658780/EliteSync-v10.git` |
| 分支 | `codex/v10.1.8-communication-notifications-20261113` |
| 任务发布 | `fda6d3db4e5fe25167bece23e2773ad46f68e5ab` |
| 承接源码基线 | `86c7a1badb785fa0eb3c1d8097111a58ac39de33` |
| APP 实际构建源码 | `ab86489aa576f95618fae48abc79b8c7f6a70258` |
| 后端最近产品修改 | `e22b0c95c2358672a8f81a9b6d6d0dd07f36830d` |
| 当前 APK | `10.1.8-dev / 1010804 / com.elitesync.v1015dev`，source Debug，arm64-v8a |
| APK 字节与 SHA256 | 123801854，`d2f777465c06f5797abce3c87f586373b62f643a41474e28efa3da2df3da46b8` |
| 签名 SHA256 | `7c023c0fbdab8cd4f53daedbc95badb47d5f968b2c267d94fa695655f391bd42` |

本节点沿用11月13日候选及双端安装字节回读，11月14日产品源码与部署逻辑沿原身份。保存昨日已通过的权限组件回归测试，补本节点文档。APK、录音和完整私有回执留 Owner 本机。

本次按四个相关后端文件读取 Git Blob、工作树和实际 API 容器字节，MessageController、PrivateAudioValidator、NotificationService、ConversationAtomicSendService 均相等，逐文件 SHA256 见 [语音证据摘要](VOICE_EVIDENCE_20261114.json)。其余改动文件的最终部署核对仍随整版交付完成。

## 本节点实际结果

1. 原测试账号与数据保留。录制端为 index1 / emulator5582 / Android user12 / 虚构用户17，接收端为 index0 / emulator5580 / Android user11 / 虚构用户16，当前 CN/MC 真实读取权限有效。
2. 用户17从普通聊天打开语音留言，经 Android MediaRecorder 真录制，停止至8.3秒预览。具名受控输入为鉴权模拟器 RPC 的440Hz、静音、880Hz序列。原生 AppOps 观测录制期间 RECORD_AUDIO running，停止后无运行标记。
3. APP 本机试听播放结束至8.3/8.3秒。纯输出采集检出440Hz与880Hz，采集工具此阶段只读取输出。
4. 用户明确点击确认发送。真实 API/MariaDB 保存消息 **131**、附件 **25**。服务器显示 `ready`、AAC-LC/M4A、audio/mp4、8267ms、103842字节。成品 SHA256 为 `fc0b1637f34a873451264aa4cece6deaf5a6b6a0ef52d2aaac406c9f60c58c2d`，实际 ffprobe 与完整 ffmpeg 解码 exit0。
5. 录制端发送后停止本包与模拟器，保留数据，再启动接收端。用户16沿普通聊天读取131并显式 ACK，`is_read` 从 false 变 true，首次 read_at 为 `2026-11-13T22:28:09Z`。本人有权 content HTTP200、Range HTTP206，1024字节片段与成品一致。
6. 接收端 APP 实际播放到8.3/8.3秒并出现重播。纯输出采集1107包、1144030字节，检出同样的440Hz、880Hz。真实数据库确认该消息对应通知 **277** 仅一条，消息已读后通知仍保持自身未读状态。

软件录制、编码、持久化、跨端读取和播放证据已具名。人工听感 `NOT_RUN`，实机硬件 `UNVERIFIED`。本次采用保留数据的两模拟器串行执行。

### 保留的失败与调整

- 首次麦克风授权返回时，当前私密上下文 epoch 变化，APP提示重新进入录制。按页面提示重新进入后完成主链。
- v3 在受控输入接入附近录制端模拟器退出，最后图形日志为 `bad color buffer handle 275`，协议返回 SocketException。失败回执保留，精确原因 `UNKNOWN`。
- v4 将录制端改为 swangle、串行使用模拟器，并先确认 APP 原生采集再注入受控输入，随后录制和双方播放通过。各调整的独立因果效应 `UNKNOWN`，swangle 日志也保留了较早的图形错误。
- 冷启动 source Debug APP 曾超过辅助工具30秒页面等待，待真实页面完成后继续普通导航。开发服务本轮启动后 API `/up` HTTP200，真实库与原业务数据保留。

## 证据与继承范围

[VOICE_EVIDENCE_20261114.json](VOICE_EVIDENCE_20261114.json) SHA256 为 `ee2c67a35fdda309197b74b0a66cc474d1ab7f9e9e186c2b1008e4e30f962f5b`，包含必要去敏结果、四个部署文件字节核对及私有固定回执摘要哈希。原始 PCM/M4A、截图、APK、日志、凭据和数据库保留本机。

私有原证根为 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev\v1018-current`。关键文件为 `voice-record-input-v4-20261114-actions-private.json`、`voice-preview-v1-20261114-actions-private.json`、`voice-receiver-v1-20261114-actions-private.json`、`normal-voice-send-20261114-private.json`、`normal-voice-persistence-20261114-private.json` 和 `checkpoint-resources-20261114-private.json`。失败 v3 独立保留。

11月13日具名成果继续按原候选继承。文字127、搜索与引用128为1010803；图片129、短视频130及本节点语音131为1010804。真实 Web 审核 submission6 产生通知274，publication仍为空。后端55项/632断言、Flutter定向182项、权限组件2项通过，权限组件属于最终 Flutter 选择集，数量有重叠。本节点继承该次测试，今日仅补真实语音链及相关身份核对。

## 整版剩余工作

| 项目 | 接续位置 |
| --- | --- |
| AC18-01 | 一次具名真实 APP 发送响应丢失后的同编号重试，确认单消息、单附件归属和单通知 |
| AC18-02 | 已读、搜索、引用既有具名成果继续继承，最终代码身份与集中报告待收口 |
| AC18-03 | 主链本节点已观测，完整AC暂保留 PARTIAL；60秒自动预览、取消/后台及当前失权等剩余受影响实测路径待收口 |
| AC18-04 | 当前 SFU exited，普通媒体、有限恢复、新撤权双方原生停媒及完整5秒尾窗待验，PARTIAL；历史精确原因UNKNOWN |
| AC18-05 | APP通知当前目标回流、偏好、失效旧目标及他人ID路径待收口；消息131实际产生单条277已补证，RTC结果随通话链验证 |
| AC18-06 | 同一组数据重登/必要开发服务重启持久化，最终 IMPLEMENTATION_REPORT.md、artifact_manifest.json、全部受影响部署身份和最终同步回读 |

下一会话可先以“发送结果未知后的同编号重试”为单一目标。私有 `v1018_response_loss.py` 已写入，仍未启动或注入。该工具设计为仅本机、单次真实后端提交成功后丢弃响应，须与普通成功主链分别记账，并在结束时恢复原路由。

## 带时间资源快照

实际观测结束为 **2026-11-14 06:29:56.971676 +08:00**。

- 当前自有 MariaDB/API/WS 为 running。SFU `bd15c12a…` 为 exited / exit1，Room状态 `UNAVAILABLE_SFU_EXITED`，本语音节点未另做通话恢复。
- 两个自有模拟器均已停止，本包进程已停止，AVD和Android测试用户11/12数据保留。接收端停止前 CAMERA、RECORD_AUDIO 均无运行标记，录制端停止录制后的原生观测亦已保存。
- ADB5038保留运行，实际进程命令含 `--one-device elitesync-current-emulators-only-no-usb`。手机 `NOT_RUN`，5037/5039沿原环境管理。
- 真实Push `REAL_PUSH_PROVIDER_PENDING`。自然长期限、硬件、历史SFU精确根因维持各自原身份。

## 恢复方式

先核实际根、remote、分支、HEAD、工作区/index和资源，读 ACTIVE_STATE 首块、本文件与本版计划的当前目标。沿实际最新分支接续，保护原主库和 `%SystemDrive%/`。本地薄工具位于 `C:\Users\zcxve\EliteSyncDev`，RPC discovery按实际进程重新发现，回执使用新的独立后缀保存。稳定构建目录仍为 `C:\Users\zcxve\EliteSyncDev\v1015-source-debug-workspace`。

在下一次明确继续指令后推进下一个目标，到节点保存交接。整版最终交付后停下供顾问验收，main集成、发布与后续版本按Owner保留权限处理。
