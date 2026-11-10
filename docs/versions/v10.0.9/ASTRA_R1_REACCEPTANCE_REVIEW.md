# EliteSync-v10｜v10.0.9 Astra R1 独立复核：一项冻结音频门仍未证明

2026-10-16。**ASTRA R1 INDEPENDENT RE-REVIEW / R1-1 CLOSED_WITH_OBSERVATIONS / R1-2 CLOSED_CODEX_REPORTED / R1-3 OPEN_NOT_PROVEN / V10.0.9 NOT_ACCEPTED / NO_MAIN_PRODUCT_INTEGRATION / NO_K08 / NO_NEXT_VERSION**。

本文件是一次非作者、基于 GitHub 固定源码和可公开安全证据的独立复核结论，**不是** `acceptance.md`、不是对物理 Windows 测试的冒称，也不增删/降低原 AC。Owner 仍是额外设备和系统权限最终 Authority。

## 固定身份和独立读取

- 唯一正式冻结计划：Commit `68d57f755d0091bc15cb867b96d3a21caee83690`，Blob `042cf7298b75169a89b1dcd7c9fb113f6ddd72e3`；AC-09-01～08 保持不变。Owner D1～D6 的产品决定 Blob `85dd5f9b88840104b0d5c26ba57d96fad4a17f11`。
- [原Astra R1初审](https://github.com/zcx369658780/EliteSync-v10/blob/27df047ea348de226b2f6a24e754cb9ae4633617/docs/versions/v10.0.9/ASTRA_R1_REVIEW_FINDINGS.md) Blob `9d6455ab184571041d29e1fce1a94d781c2c3d55`。
- 原候选：Commit `66a8638581d1017823ac3caa2536568e0de3b939` / Tree `5d12910949af8bf8f29f87106f45594887a962b7`。
- [本次R1正式交付](https://github.com/zcx369658780/EliteSync-v10/blob/70612d36652660e8bdd9d12017c1254ada686298/docs/versions/v10.0.9/R1_REPORT.md)：Commit `70612d36652660e8bdd9d12017c1254ada686298` / Tree `6dccb9f4339e7656883bc7594fbb8a8cc11f5636` / 报告 Blob `c54f56801305cbb60a5f262163bfcdb2356a1890`。GitHub 分支 `codex/v10.0.9-rtc-media` 读取 HEAD 与其相同，R1 较初始候选 ahead 1 / behind 0。
- R1 仅新增/调整报告、说明和安全证据；GitHub compare 确认 **APP/Flutter/Android/Laravel/RTC 产品与测试源码未变**。原最终产品源码锚 `e0eb86ada8f8dff95a7b384969ace058385e2c37` / Tree `a6be76c7963fcd2cff42e207660503c3b0856424`，物理 APK/AAR 的本地归属继续为 CODEX_REPORTED。
- 本次复核前 GitHub main：`27df047ea348de226b2f6a24e754cb9ae4633617` / Tree `d0ea85005c59323bcc56ecb99a6fe5e666fdc35e`。未将 R1 产品源码合并 main。

## 三项独立裁决

| 项 | 本次复核 | 验证依据与精确保留 |
|---|---|---|
| **R1-1 16项PHP失败** | **CLOSED_WITH_OBSERVATIONS** | 实读 [16项逐项归因](https://github.com/zcx369658780/EliteSync-v10/blob/70612d36652660e8bdd9d12017c1254ada686298/docs/versions/v10.0.9/R1_PHP_FAILURE_ATTRIBUTION.md) 及 paired JSON。固定0.8 `3a8f7989...` 与0.9 `66a863...` 的隔离、同配置及各自题库定点测试，双方均16项／62断言／4 errors／12 failures／exit2（CODEX_REPORTED）。#1–7为既有紫微/iztro问题，#8/10/11/13/14涉及历史matching，#12为旧Conversation合同，#15/16为旧西占，#9为过时字面routes摘要而在0.8已失败；v2切片及边界另经只读检查。此前全量1063项／14037断言、4 errors／12 failures／exit2保持；**不宣称全套通过，也不证明不存在全部顺序依赖**。当前PDO相关选集37项／325断言／exit0，由R1脱敏回执支持。无本版引入的具名回归已获证明，不要求整版重验。 |
| **R1-2 防火墙四规则** | **CLOSED_CODEX_REPORTED** | 实读 [防火墙脱敏证据](https://github.com/zcx369658780/EliteSync-v10/blob/70612d36652660e8bdd9d12017c1254ada686298/docs/versions/v10.0.9/evidence/r1/firewall-safe-evidence.json)。四条精确具名临时WLAN 7882/UDP与7881/TCP Allow/Block规则：四个cmdlet成功、内部脚本exit0、再次按名称回读剩余0；其它828条规则的已比较基本属性不变。**UAC父进程OS退出码未捕获、其它无关filter字段未比、Astra没有实际读Windows防火墙**，保留此边界；不得据此说全部主机资源已经关闭或任何规则都不存在。 |
| **R1-3 同call人工双向音频** | **OPEN_NOT_PROVEN — BLOCKING AC-09-03** | 实读 [音频证据关联](https://github.com/zcx369658780/EliteSync-v10/blob/70612d36652660e8bdd9d12017c1254ada686298/docs/versions/v10.0.9/R1_AUDIO_EVIDENCE_LINKAGE.md) 和公开 `audio-linkage-safe.json`。Owner 2026-10-16 14:18:47、14:20:43 的实际反馈，仅明确“手机旁说话→电脑端听见清楚”及静音恢复；第三版试听包和最终包不同 SHA，虽音频相关源/依赖哈希延续，但不能等同最终包被人耳双向确认。最终包 call59 在同call双端 inbound/outbound RTP 同时增长，**但媒体统计不是人耳可辨**。原人工听辨的 call/room 未能无歧义定位，反向电脑→手机人工听辨、同call同时双向人耳确认及与最终安装包的直接关联均 `NOT_PROVEN`。R1诚信保留这些缺口，不拼凑不同call，不虚构Owner反馈。 |

## 冻结AC与最终裁决

原初审对AC-09-02、04、05、06及受影响旧功能的限定证据继续有效；没有产品源码变化，不因本轮仅整理证据重跑全部双端视频或历史版本。R1-1消除了AC-09-07的16项失败归因障碍；R1-2消除了AC-09-01的临时规则清理障碍。**AC-09-03“双方同时可辨真实双端语音”仍缺必要人耳确认及同call/包身份，不能判PASS；AC-09-08完整最终交付因此仍不能全部关闭。**

**裁决：V10.0.9 NOT_ACCEPTED — ONLY FROZEN AC-09-03 AUDIO LISTENING PROOF REMAINS.** 这不是判定已有双端RTC产品实现失败，而是强制验收标准未得到完整可信实证。不能以`ACCEPT WITH OBSERVATIONS`覆盖这一冻结必要门，也不要求为此重复R1-1/R1-2。

## 下一步仅此一门

优先不增加源码修改。如Owner希望继续达到原冻结标准，需另行**针对一次voice-only、具名设备、网络和时间范围的明确许可**，届时由Codex在批准范围内恢复专用0.9环境，先核设备/服务/volume、双端**最终APK实际安装hash**，于**同一个合法call**记录call/room身份及两方向实际APP采集→SFU→对端订阅播放，并由Owner分别确认手机→电脑、电脑→手机和双方同call同时说话时均能辨认；对应回执标真实确认的时间口径，保存必要脱敏统计。不能只取RTP/SDK状态或把“手机+电脑麦克风正常”替代声学确认。测试前不得默认重新建立已删除的防火墙规则；任何需提权/开放端口的动作另行具名授权。无Owner新许可时保持停止，原卷/媒体/原证与dirty根受保护。

若原证日后查到同等强度的真实确认链，可先只读补证；若事实无法补证且Owner不选择做一次新测试，版本维持`NOT_ACCEPTED/RETAINED_GAP`，不得追认历史PASS或改变固定plan。必要证据达标后Astra才按原8AC集中作最终裁决、正式书写 `acceptance.md` / 复盘；之后K08仍须由Owner手动转交Codex，分别记Acceptance、GitHub集成、本地接续与实际运行。**当前不合main、不K08、不启动后继版本**。

未解除的既有观察仍包括原生AEC/NS/AGC实际模式UNVERIFIED、本地HTTP front的队头等待与短体边界、有限死锁重试预算、LOCAL_ONLY框架原日志可能含SQL、debug包显示旧0.08.04及历史Flutter失败，不因此开启范围外优化。
