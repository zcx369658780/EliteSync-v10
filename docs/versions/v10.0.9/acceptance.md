# EliteSync-v10｜v10.0.9 Astra 最终独立验收

**2026-10-17 — `V10.0.9 ACCEPTED WITH OBSERVATIONS`**

**`AC-09-01..AC-09-08: PASS (retained observations explicit)`**  
**`AC-09-03 FINAL SAME-CALL BIDIRECTIONAL HUMAN-INTELLIGIBLE AUDIO: PROVEN`**  
**`NO_PRODUCT_MERGE_TO_MAIN / NO_K08_UNTIL_OWNER_HANDOFF / NO_NEXT_VERSION_AUTOSTART`**

## 1. Authority、版本身份及审阅材料

- Owner为不可逆产品决策与额外权限authority；Astra为本版独立验收方。冻结Owner决定Blob `85dd5f9b88840104b0d5c26ba57d96fad4a17f11`，冻结计划Commit `68d57f755d0091bc15cb867b96d3a21caee83690`、plan Blob `042cf7298b75169a89b1dcd7c9fb113f6ddd72e3`；8项AC不改写。
- 产品候选分支`codex/v10.0.9-rtc-media`继续停在Commit `70612d36652660e8bdd9d12017c1254ada686298`、Tree `6dccb9f4339e7656883bc7594fbb8a8cc11f5636`；Flutter/Laravel产品源码最初锚 `e0eb86ada8f8dff95a7b384969ace058385e2c37`。两端最终安装包实读SHA256均为 `77d4b0215d710a3a749814d386059d4763eaefa73101d9b31bc14b8ba7bca5ca`（实际设备回执由Codex采集，公开材料为脱敏安全副本）。当前资料没有表明新的APP源码修改或重新构建安装。
- 最终语音候选固定Commit `2f510cf19324e91c3ab9aebb5724449d64ad7019`，Tree `0fa86584adc0dc5eb3334cec99d66662f464ef6b`，唯一parent为产品开发Commit `70612d36652660e8bdd9d12017c1254ada686298`。GitHub compare显示仅新增`docs/_temporary_review/v1009-final-audio-call65-20261017/`中的32项脱敏审阅文件，未把临时材料或产品改动混入main。
- Astra实读该固定候选中`FINAL_AUDIO_CANDIDATE.md`、`OWNER_CONFIRMATIONS.json`、`CALL_AND_SOURCE_WINDOWS.json`、`QUALIFICATIONS_SAFE.json`、`MEDIA_SAFE_SUMMARY.json`、`NETWORK_SAFE_SUMMARY.json`、`EXIT_CODES.json`、`FINAL_DUAL_STORE.json`、`FINAL_RESOURCE_READBACK.json`、`RUN_IDENTITY.json`、`PREWARM_AND_SERVICE_EVENTS.json`、`INTERNAL_REVIEW.md`、`RUNTIME_CHANGE.diff`及相关SHA/测试/安全审阅文件。GitHub固定Tree中32个临时blob已完整枚举；物理执行原证仍为`CODEX_REPORTED/LOCAL_ONLY`，不等于Astra登录Windows亲自录音/执行；Owner原话由用户提供并经Codex按host时间关联。所需真人录音或隐私媒介未上传，也不作为验收前提。
- [最终候选报告](https://github.com/zcx369658780/EliteSync-v10/blob/2f510cf19324e91c3ab9aebb5724449d64ad7019/docs/_temporary_review/v1009-final-audio-call65-20261017/FINAL_AUDIO_CANDIDATE.md)、[A/B/C人工确认](https://github.com/zcx369658780/EliteSync-v10/blob/2f510cf19324e91c3ab9aebb5724449d64ad7019/docs/_temporary_review/v1009-final-audio-call65-20261017/OWNER_CONFIRMATIONS.json)、[同通话与音源关联](https://github.com/zcx369658780/EliteSync-v10/blob/2f510cf19324e91c3ab9aebb5724449d64ad7019/docs/_temporary_review/v1009-final-audio-call65-20261017/CALL_AND_SOURCE_WINDOWS.json)、[媒体摘要](https://github.com/zcx369658780/EliteSync-v10/blob/2f510cf19324e91c3ab9aebb5724449d64ad7019/docs/_temporary_review/v1009-final-audio-call65-20261017/MEDIA_SAFE_SUMMARY.json)。这些为历史固定Commit引用，清理临时branch后可能仍可按SHA读取，但branch删除不能保证对象从历史永久消失。

## 2. 唯一剩余冻结门 AC-09-03：已通过

本次不是借用先前第三版APK的单向试听，也不是以call59 RTP冒充人耳确认。

- 新Run `6491c22e-6df6-4547-87ec-61ae206669ef`：Owner就一次最长1200秒、一次UAC与四条原精确规则另行授权；北京时间16:38:32.297开始，固定截至16:58:32.297，16:45:55后主动STOP，16:46:27控制器结束，16:46:45双Store独立回读完成；无续期、第二次UAC或另一通话拼接。
- 实际APP caller拨出→独立callee APP接听（host 16:43:56附近），新voice `call_id=65`处于`in_call`；room的SHA256 `e51c655675f1a8495a36e3ababc4140daa6b24d0b29da1d6cba85506bd527433`。两端当前资格读取为`CN_ACTIVE` revision2、双方`MC_ACTIVE` revision2、APP账户approved且moderation normal、LIVE_READ/LIVE_SEND允许；不是强制seed、恢复失效旧凭据或手工改业务权限。
- **A，模拟器APP → 手机APP**：AVD麦克风链采集经设备扬声器送入的660Hz三声脉冲，手机APP真正远端订阅与播放；Owner实际答复 **「你好，手机有反应，听到了三声。」** 并同时提出回声疑问；音源host 16:43:02.813–16:43:06.927。
- **B，手机APP → 模拟器APP**：手机真实APP麦克风发声，电脑侧远端APP输出；Owner答复 **「是的，电脑播放了我说的话」**。
- **C，同一call65同时双向**：AVD侧经APP麦克风输入三声脉冲，同时手机经APP麦克风说话，双方发布、订阅与播放；源host 16:45:11.581–16:45:15.696。Owner明确答复 **「是的，双方都能听到，三项成立」**，对应收录的三项是手机听到远端三声、电脑播放手机说话、双向同时远端声音可辨。确认记录是收到Owner回复的host时刻，不伪称精确真人出声时间。
- 两端同call65的`TrackSource.microphone` `muted=false`、本地PCM帧与峰值、`TRACK_SUBSCRIBED`、`AUDIO_PLAYBACK_READY`、远端decoded PCM统计、双方向inbound/outbound RTP包/字节均被记录；host采样区间涵盖C阶段前后，双方方向都有增量。**这些技术指标仅辅助声学证据，人工A/B/C是关键验收依据。**
- 本次执行真实`GET /up` HTTP200（响应头约266ms）、恰好一次真`POST /api/v1/rtc-guard/sweep` HTTP200且`allowed_rooms=[]`（响应头约47ms），才启动SFU/通话；先前/liveness超时的服务端根因未因此被证明。
- `call65`业务end请求HTTP200，双方APP force-stop，本轮SFU、DB及5个自有服务均停止，无目标APP进程残留，添加的4条ADB reverse逐条移除exit0；网络自动四条规则创建4、收编4、删除4、残留0，28个适配器操作均exit0；双Store`ActiveStore`/`PersistentStore`四名均0、独立查询各exit0；服务监督、网络、controller、外层的整体exit均0，持久volume与旧证据未动。**经主动终止的5个子进程各自exit1，不能把其原生exit伪改为0；上层清理结果为成功。**

**AC-09-03 = PASS。** 原R1-3音频唯一阻塞正式关闭；不需再补新的电话窗口来重复A/B/C。

## 3. 原冻结8项AC的总裁决

|冻结门|Astra最终状态|证据定位与范围|
|---|---|---|
|AC-09-01 环境/镜像/数据隔离|PASS|原R1审查、0.9隔离数据库卷、官方固定LiveKit镜像/实际image身份、最终双APP SHA；本次保护原volume及主机受控网络清理|
|AC-09-02 当前CN/MC及RTC授权|PASS|历史真实多种拒绝/接受/撤权和重连正反例；本次call65当前CN_ACTIVE/双MC_ACTIVE、新合法APP独立接听|
|AC-09-03 真双端语音|**PASS**|call65最终同源APK、同room、A/B/C Owner实听、双向真实APP媒体统计、结束/停服回执；原历史RTC终态/DB/拒绝/忙线/重连等测试仍按既有候选保持|
|AC-09-04 真双端视频|PASS|先前call60/61不同测试图/双方真实视频帧与RTP、旋转前后台、摄像头拒绝/切换及资源清理；本轮voice-only不重做|
|AC-09-05 实时撤权与旧JWT/SFU|PASS|原call49/54/55/59/61等真实CN/MC/block/ban/end，撤权≤5秒与未过期JWT/原SFU绕行fail-closed原证；本次不重测|
|AC-09-06 私有短视频消息|PASS|原APP选片/持久MP4短视频、另一APP完整播放、无权/撤权/Range拒绝与重启后再次观看，失败和限制保留|
|AC-09-07 已接受功能/Web联动|PASS WITH OBSERVATIONS|旧v10.0.7/0.8必要切片保留，16项旧PHP失败经R1在0.8同条件复现；原全量PHP仍exit2，不能写为全绿|
|AC-09-08 最终包/联合运行/证据|PASS WITH OBSERVATIONS|原候选构建/双端安装/联合重启及媒体回归、R1证据，再加call65真实最终缺口与完整收口；LOCAL_ONLY原证不冒充独立物理实测|

[R1独立复核](https://github.com/zcx369658780/EliteSync-v10/blob/631a62015c1645e17b492391dc4281efbf4f362d/docs/versions/v10.0.9/ASTRA_R1_REACCEPTANCE_REVIEW.md)最初结论为`R1-1 CLOSED_WITH_OBSERVATIONS`、`R1-2 CLOSED_CODEX_REPORTED`、`R1-3 OPEN_NOT_PROVEN`；最后这一项已被本文件新同call人工确认补证取代。除最终语音证据外，没有由此要求重开旧8项AC的其它测试。

## 4. 必须保留的观察、不应夸大的结论

1. **回声/AEC未验证**：Owner在A阶段追问“但是昨天已经调试好的去回声功能怎么没了？”；最终设备日志`RTC_AUDIO_ENGINE hardwareProcessingRequested=false ... effectiveMode=unverified`。真实回声程度、原生AEC/NS/AGC是否实际生效均未证，不能把AC通过写成“无回声/已恢复降噪”。由于Owner仍明确确认三项双向同时可辨，当前没有证据显示冻结AC要求的可辨双向语音失败。将AEC/回声音质留为明确产品质量观察，由Owner决定后续版本何时优化；不得自动改最终APK重新打开AC。
2. **call65单次end终态额外读回缺失**：业务end HTTP200，两APP终止、SFU停止、通话不再有媒体，DB停服与资源回读成立，但本次没有额外独立查询`call65`结束后的DB行或provider room最终状态。原版本候选含历史正常end/终态、失效与持久重启正反例，因此只将本次附加独立回读缺失列为证据观察，不能谎称call65数据库终态已独立取证。
3. **全量PHP并非PASS**：原全套1063项／14037断言，4 errors／12 failures／exit2；R1在固定v10.0.8基线同条件复现这16项、分类`CLOSED_WITH_OBSERVATIONS`，相关回归exit0。不能说16项都已修复，也不能不加限定地称整仓测试全部绿色。
4. **旧GET /up超时服务端根因未确定**：后续受控运行以11次GET200及call65真实GET/sweep成功恢复可用，仅能证明本次就绪门通过，不能编造旧超时的完整服务端根因或声称彻底消除所有冷启动不确定性。
5. **Windows/设备实操原件LOCAL_ONLY**：Astra独立读GitHub公开脱敏回执、源文件与真实退出码的对应关系，没有直接登录用户Windows读本机所有完整日志、声音/视频载荷。拒绝将`CODEX_REPORTED`换成Astra现场独立重演。未发现需要在本次冻版前继续开新真实窗口的未闭合必要门。

## 5. 交付与后续权限

**当前v10.0.9版本业务验收已完成：`ACCEPTED WITH OBSERVATIONS`。** 保留原v10.0.6/v10.0.7/v10.0.8既有accepted state和v10.0.9 frozen plan。此文档是**docs-only main上的独立验收记录**，绝非将产品开发分支合入main、发布生产版本、启动staging、执行K08或授权下一个版本。

若Owner决定执行产品集成、K08、生产发布或下一大版本，必须另行给出明确决策和授权，由Codex按新的版本级综合任务自主推进；不再为已完成call65重复分割微型R任务或重新申请网络试音窗口。历史安全脱敏短期审阅分支只按既定协议清理；其Git对象在历史或缓存中可能继续存在。
