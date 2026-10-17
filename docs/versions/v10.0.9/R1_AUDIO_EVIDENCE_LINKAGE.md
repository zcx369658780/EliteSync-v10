# v10.0.9 R1：真实双向语音证据关联与未证明项

**NOT_PROVEN：同一有效call内双方同时双向人耳可辨，以及该人工试听与最终安装APK的完整关联。** 这是证据关联结果，不是重新音频测试或AC接受。原生最终AEC/NS/AGC模式仍UNVERIFIED。

## 人工确认：原话、方向与时间

来源会话01a14250-b40a-7410-ac1d-61dde1ec0644的JSONL为LOCAL_ONLY；本R1会话不同，未借用来源身份。问句明确“在手机旁正常说话、轻声说话，电脑端听感怎样”，因此只能直接认定手机→电脑方向。

| 实际确认 | 北京时间（metadata create_time） | 源JSONL行 | 证据界限 |
|---|---|---|---|
| “仍很少或没有回声”；“正常和轻声都清楚” | 2026-10-16 14:18:47.229+08 | 1851 | 人工听辨手机→电脑；不是反向同时说话确认 |
| “是，回声很少或没有，正常和轻声都清楚” | 2026-10-16 14:20:43.656+08 | 1902 | 静音再开麦后的同向听感保持 |

精确envelope UTC timestamp与metadata epoch分别保留在audio-linkage-safe.json，不混淆记录时间和操作时间。owner-agc-profile-result.json中utc=06:19:10早于第二条实际答复，且文件汇总含后续mute_reopen；它是可变汇总回执，不能当两次确认发生时间。更早“电脑端+手机端播放、话筒功能正常”是设备功能整体确认，不能补成某一call的双向同时听辨。

## 第三版试听包与最终包的身份桥接

第三版AGC包：APK `904efe1429740b2a435c511343586b4d9e5b4a1f7f5d84e37bdaa3b642cb20bd`；AAR `8b0db8392114f18d395219a9e274b766281bdc24cb2a6e30b494040b7173b555`。audio-echo-software/agc-manifest及两端安装/运行时回执证明两端安装hash匹配，安装exit0。此前stable版本call29不属于此包，不能借用；第三版试听时call/room没有被不可歧义的回执关联，均NOT_PROVEN，不能按序号猜call30。

最终包：APK `77d4b0215d710a3a749814d386059d4763eaefa73101d9b31bc14b8ba7bca5ca`；AAR `dd1e869f34eea40693793871e03de895cc4a50d3f131255b9edd9e2d05642d9e`。provider-final-installed-package-hashes.json在北京时间17:27:20.306实读两个安装APK hash一致。独立包com.elitesync.v1009test，Android显示0.08.04。本次未安装或读取设备。

第三版与最终manifest中的音频引擎rtc_android_audio_engine.dart、rtc_livekit_service.dart、pubspec.yaml及pubspec.lock SHA逐项相同，并与最终候选Git blob规范化换行后内容核对；除engine文件外其余工作树CRLF哈希不同于canonical Git哈希，两种hash分别记录。此事实证明这些源码/依赖锁字节连续，不等于两个APK/AAR字节相同，也不等于最终包重新获得相同人工确认。具体SHA见audio-linkage-safe.json。

## 最终包同call媒体统计：call59

call59-before-revoke持久状态回执为in_call/voice，provider59安全摘要指定最终APK hash；最终双端安装hash回执先于此call撤权。选取既有两端事件：PHONE_XIAOMI_TEST为8组inbound/outbound音频样本，AVD_MANUAL为4组；各方向bytes/packets在同call都增长，逐方向首尾时刻与增量见audio-linkage-safe.json。SDK inbound RTP仅证明远端receiver统计；outbound仅证明发送统计，不能单独证明声学播放、人耳听懂或同时双向说话。采集/播放状态不能从统计进一步升级。

call59准确room未在所选安全回执列出，标NOT_PROVEN；call_id59是本地原证查找锚。call49也有两端各30条RTP和撤CN停止证据，但它属于另一call，**没有与第三版Owner人工试听拼接**。本R1没有开麦、放声、采音、录音、呼叫或新网络窗口。

## 最小待补条件

现有证据不足的具体字段：第三版人工试听call/room；同call电脑→手机可辨确认；同call双方同时双向可辨确认；人工确认与最终安装APK直接绑定。保持NOT_PROVEN并提交Astra/Owner决定，不自称此缺口已闭合。

如Owner今后选择补证，需要另行具体授权一次voice-only有限窗口，并在同一call记录call/room、双端安装hash、两方向及同时双向人工确认、APP采集/订阅/播放状态和时间；当前没有该许可，不预先启动设施。也可由Owner/Astra判断现有证据限制的验收后果。完整声音、真实serial/IP、JWT与原日志继续LOCAL_ONLY。
