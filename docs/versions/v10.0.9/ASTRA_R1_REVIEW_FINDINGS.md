# EliteSync-v10｜Astra独立终验初审｜v10.0.9 候选R1定点缺口

2026-10-16。**ASTRA INDEPENDENT INITIAL REVIEW / TARGETED R1 REQUIRED / NOT_ACCEPTED / NO_MAIN_PRODUCT_INTEGRATION / NO_K08 / NO_NEXT_VERSION**。

## 固定权威与已核对象

- 候选：`66a8638581d1017823ac3caa2536568e0de3b939` / Tree `5d12910949af8bf8f29f87106f45594887a962b7`，开发分支 `codex/v10.0.9-rtc-media` 的实际HEAD一致；产品最后实现锚 `e0eb86ada8f8dff95a7b384969ace058385e2c37` / Tree `a6be76c7963fcd2cff42e207660503c3b0856424`，其后两提交为交付文档/证据。
- GitHub main 本次初审核验为 `cab5e7c07d214572385521a33fdacc0eb1c8fc2f`；仍为0.8产品技术基线后的纯文档链，尚未集成0.9源码。
- 唯一冻结plan Commit `68d57f755d0091bc15cb867b96d3a21caee83690` / Blob `042cf7298b75169a89b1dcd7c9fb113f6ddd72e3`；Owner D1～D6沿用 `PRODUCT_DECISIONS.md` Blob `85dd5f9b88840104b0d5c26ba57d96fad4a17f11`。原AC-09-01～08未修改。
- 实读GitHub候选的 `EXECUTION_REPORT.md`、`manifest.json`、`RUNBOOK.md`、安全统计JSON、公开AVD截图及相关Flutter/PHP/RTC网关/媒体安全源码与测试。GitHub文件证明公开字节；Windows物理APK/AAR、Owner音频原始回执、实际手机/摄像头、Docker/防火墙/PID等属于 `CODEX_REPORTED / LOCAL_ONLY`，Astra没有在Windows重跑。
- 最终Codex报告的相关PHP 37项325断言 exit0、Flutter RTC32项 exit0；全量PHP 1063项14037断言、4 errors / 12 failures、exit2（最后PDO边界修复前），**绝不声称全绿或已知全部历史问题**。

## AC逐项独立初审

| 冻结AC | 本次初审 |
|---|---|
| 09-01 | 镜像/隔离DB、双ABI独立包与两个指定设备证据有力，源码/包关系有具体hash；**测试结束后四条受控临时防火墙规则仍存在，环境最终清理未闭环（R1）**。 |
| 09-02 | 真实当前Match→CN/MC→独立accept、拒绝/处罚/错误call及可信入房/重连代码、测试与报告相互支持；保留物理状态为CODEX_REPORTED，不重做旧版。 |
| 09-03 | ICE设备阻塞已解除，Owner声学确认由Codex报告，音频RTP/静音恢复具名；**公开证据未将同一有效call的两方向及同时双向人耳辨认、Owner确认和最终安装包身份逐一关联（R1仅补既有脱敏回执，不默认要求重新采音）**。 |
| 09-04 | 已实际查看旧双AVD不同视频画面截图、新横屏及前后台设备关闭截图；最终call60/61安全统计包含双向帧、真实旋转、权限/前后台和终止。手机私人图片LOCAL_ONLY，不作为GitHub已读证据。 |
| 09-05 | 已读安全统计：CN关闭call49、block call54、MC撤销call59、挂断call61等双方离房及5秒后无RTP，call61保存的未过期JWT仍余51.69s时join404/validate403/WS403；原SFU宿主入口不可达。旧Web restrict/ban、SFU故障证据归属原报告。最终分项整体支持，仍按物理原证可访问性限制陈述。 |
| 09-06 | 已实际查看私有短视频最终4.933秒片尾截图及旧起播证据，真实APP picker/验证/持久化/Range、撤权播放器停止和HTTP负例有具名结果；不声称转码或封面。 |
| 09-07 | 原文本/图片、D1/D2、Web处罚/申诉及隐私的定点回归有支持；**全量PHP的16项错误/失败没有具名逐项判别是否落入本版修改或既有业务回归范围（R1）**，不可在未知归因下直接当作历史绿测。 |
| 09-08 | 最终包SHA256（APK `77d4b0215d710a3a749814d386059d4763eaefa73101d9b31bc14b8ba7bca5ca`、AAR `dd1e869f34eea40693793871e03de895cc4a50d3f131255b9edd9e2d05642d9e`）及两端安装、同库重启、证据报告有明确身份，物理包仍LOCAL_ONLY；**受09-01/03/07待收口事项连带，不作最终PASS**。 |

## R1唯一集中返修/补证范围（不改冻结计划）

1. **PHP失败归因**：从既有LOCAL_ONLY全量PHP原流抽取4 errors与12 failures的准确测试类/用例、错误类别、实际exit和是否触及0.9变更。对每项给出“本版回归/旧基线已复现/不相关环境或fixture/UNKNOWN”及可核依据；只对不确定或受影响的测试做必要定点重测，必要时用固定0.8代码基线同条件对照。不得仅凭“和最后一次修复前同名”认定早于0.9；真属本版缺陷则定点修复、回归，不重启0.6～0.8全历史。
2. **临时防火墙规则收口**：先现场只读核属于本v10.0.9的四条规则名称、协议、精确限制、创建凭据/归属及当前状态。规则为本版临时测试创建且测试已结束时，按原最小授权边界仅删除这些确证归属规则并给出删除前后脱敏读回；如删除需要新的Owner UAC具体许可，停止该动作先报告，不默认提权，不触碰无关网络策略、服务/卷/原dirty根。服务保持停止。
3. **双向音频证据关联**：基于既有Owner实际确认及其脱敏receipt，提供至少一个可定位的真实call/room：手机→AVD、AVD→手机及同call同时双向辨认、对端实际听见的确认、采集/播放状态、时间口径，并与最终APK的源字节/安装身份关联。缺的仅是证据链时不重新用真人音频或开手机摄像头，不补写不存在的Owner确认；确实没有证据时明确`NOT_PROVEN`并报告最小Owner决定。

R1不得降级AC、改变Owner D1～D6、自动并main/运行K08/启动下一版。无新增视频/录音/网络窗口授权；此前LiveKit/双ABI/RTC/附件通过的具名原证继续有效，无受影响源码差异时不重做全部双端测试。全量失败中已证明与本版不相关的旧观察项可保留但必须提供依据。

## 保留的非阻断观察（不自动扩成R1优化）

- Android原生AEC/NS/AGC最终生效实现仍UNVERIFIED，报告仅证明初始化请求和Owner实际声学反馈，不能夸成纯软件AEC实现证明。
- 本地单PHP worker前置串行化仍有队头等待/短body边界风险；不得将本地有效性外推生产或公网。
- 有限数据库死锁重试不保证1.5秒总预算；原框架日志可能含SQL（LOCAL_ONLY），不可向GitHub传出。
- 调试Android包显示版本仍0.08.04，v10.0.9为冻结开发版标识，K08/未来正式分发须分别核物理包版本、URL与SHA；不冒充发布完成。
- 原0.7 Flutter三个旧失败和PHP vendor弃用保持原值；本轮没有全量Flutter PASS声明。

**终裁：TARGETED R1 REQUIRED — v10.0.9候选当前NOT_ACCEPTED。等待Owner手动转交同版R1结果，再针对三点及必要关联回归复核；此文档不是acceptance.md或新计划。**
