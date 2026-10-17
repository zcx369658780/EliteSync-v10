# v10.0.10 集中决策请求：数据权利与剩余独立参考

2026-10-17。**CONTINUE_SAME_VERSION / RIGHTS_AND_ORACLE_BLOCKED_FOR_FINAL / NOT_FINAL_CANDIDATE / NOT_ACCEPTED**。

本轮已继续完成合法技术工作，不重新立项、不修改八项 AC。最新源码检查点 `0384a8ee65294931d35602b2a486f70ae3baedb6`；新增结果和限制统一登记在[综合实施报告](IMPLEMENTATION_REPORT.md)及[机器验证汇总](validation-summary.json)。当前请求仅涉及新的第三方联系或付费路线；普通同版源码、参考和测试工作不再申请权限。

## 一、Chiron：可以选择的具体路线

原 JPL 澄清邮件已成功发送一次，本轮仅查看原线程一次，仍只有原 SENT 消息，无答复。不重发，不把未答复当成拒绝或授权。DE440s 无 Chiron；NAIF 自身分发 kernel 的规则不能扩张到 Horizons 用户生成 SPK 或其它机构目录。

本轮另查 IMCCE/Miriade、MPC/ASSIST、AstDyS/OrbFit、LESIA/NIMA、ESA/ESDC。未找到同时满足本项目闭源服务使用、必要分发权和冻结年代精度证明的已准入组合。不是断言这些来源永远不可能授权。

| 路线 | 具体证据、产品影响 | 费用及新权限 |
|---|---|---|
| A：保持当前免费路线，等待已发 JPL 答复 | [Horizons 技术手册](https://ssd.jpl.nasa.gov/horizons/manual.html)支持小天体 SPK；权利仍待具体答复。拿到适用许可后才能取固定数据并做独立数值验证。其余三盘成果保留，Chiron 不删除，整版继续阻塞。 | 本轮费用 0；等待本身无需新增许可，不自动建立轮询或重复发信。 |
| B：同时向 LESIA/NIMA 作一次限定权利询问（建议的新增动作） | [NIMA Chiron v16 对象页](https://lesia.obspm.fr/lucky-star/obj.php?p=1075)有固定 kernel 与观测弧/残差资料；1895–2023 观测弧、0.090 arcsec 拟合 RMS 不能证明 1901–2100 全域误差。应先询问闭源本地运算、衍生坐标展示、内部保存、可选原文件分发和覆盖误差证明。[官方项目联系页](https://lesia.obspm.fr/lucky-star/preda0.php)列 J. Desmars 联系方式。技术上可维持 Skyfield 本地计算路线，不必外发生辰。 | 报价/授权期限 UNKNOWN；只申请发出下方一封无生辰、无附件、无费用承诺的询问，不购买、不下载集成数据。现有一次性发信授权只覆盖 JPL，需 Owner 明确扩展到此收件人。 |
| C：评估商业 Swiss Ephemeris 专业许可作为备用 | [官方 2026-09 合同](https://www.astro.com/swisseph/secont_e_2609.pdf)覆盖自有 APP 和服务器用途，第三方 API 用户另受限制；[官方技术文档 §2.3.4](https://www.astro.com/swisseph/swisseph.htm)说明 Chiron 可计算年代 700–4650 CE，但这仍不是本版独立 oracle 已通过。采用将改变已批准 A 路线和现有禁用引擎门，必须明确批准、完成有效许可和独立验证后才能接入。Swiss 专业许可不自动解除 Kerykeion/pyswisseph 包装层的其它义务。 | [当前官方价](https://www.astro.com/swisseph/swephprice_e.htm) CHF 700，合同期限 **6 年**，到期续约或停止相关使用；不是旧文档中的 CHF 750 永久许可。汇率、税费、续约价未核。需 Owner 对路线、预算、签约主体作明确决定；本请求不自动授权购买或使用。 |

**建议选择 B 并继续等待 A；C 作为单独明确批准的收费备用。** 不提出删除 Chiron、减字段、把 PARTIAL_FULL 改成完整盘或开放真实出生资料外发的选项。

### B 的可审阅询问信息（尚未发送）

收件人：`josselin.desmars@obspm.fr`；主题：`Rights and coverage clarification for offline Chiron NIMA ephemerides`。

> Hello Dr Desmars,
>
> We are evaluating a local natal-chart calculator in a closed-source application and are considering the NIMA Chiron ephemeris identified on the Lucky Star project site. No end-user birth information would be sent to your service.
>
> Could you identify the applicable terms or permission process for retaining a fixed Chiron kernel locally, computing and displaying derived coordinates through our own application/server, and optionally redistributing the unmodified kernel? We would also appreciate the supported interval and uncertainty information relevant to 1900–2101, plus any attribution, fee or other obligations.
>
> This is an inquiry only: we are not requesting a paid purchase or agreeing to fees, and will not integrate the data before the applicable rights are clear. Thank you.

## 二、独立参考：已收口部分与仍需的证据

交运的 Gregorian 顺序截日、固定 UTC+08、DST 最终转换及分秒保留已经明确，并补非作者盲选日期对照；无需 Owner 逐个裁决日历加法。自定义 CRC1956 与 mean lunar apogee 的具体数学定义也已补非作者参考和 APP 标签；没有冒称官方 Lahiri 或旧版逐位等价。

紫微保持冻结 `iztro-2.5.8-modern-default-v1`。新增 680 项余星位置和 1,512 项选定大限/流年规则比较均相符，但不能补成全亮度、闰月/初日特例、单支旬空选择及完整运限流曜的独立证据。具名异文仍为：太阴酉 iztro“不”/紫微家“旺”；七杀酉 iztro“庙”/紫微家“旺”。另一表还有 63 格字面异文；不能只按这两格挑值或把不同流派拼在一起。

当前没有一套已获许可、已独立核全的替代现代 profile 可直接推荐，因此**本次不要求 Owner 逐值选星曜，也不申请放宽 AC**。继续保持原 profile，取得同口径独立规则/案例后再核；若后续具名完整替代 profile 的证据、费用及产品差异均确立，才能集中申请切换。外部程序上游 UNKNOWN、现代文章/整表转载权限不足不能由一句 Owner“通过”变为独立数值证明。

八字更广历表/精确边界和完整本命扩展、西占原版点位定义等未覆盖项继续如实保留。上述参考不足仍阻塞最终候选；购买 Swiss 也不会自动修复紫微或八字 oracle 缺口。

本版服务/DB/APP 验收基线按影响复用；本轮不重启服务或设备、不重做既有 APP/DB 链、不发布新版 APK。不合 main、不执行 K08、不启动下一版。只在权利与完整独立参考闭合后交一次最终候选。
