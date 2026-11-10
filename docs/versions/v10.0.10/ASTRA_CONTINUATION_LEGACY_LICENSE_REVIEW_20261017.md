# EliteSync-v10｜v10.0.10 第二次实施检查点与旧仓许可证材料 Astra 独立审查

**2026-10-17 — `CHECKPOINT_EVIDENCE_REVIEWED_WITH_OBSERVATIONS / CONTINUE_SAME_VERSION / NOT_FINAL_CANDIDATE / V10.0.10 NOT_ACCEPTED`**

**NIMA询问决定：`RECOMMEND_ONE_SCOPED_ENQUIRY / EXPLICIT_OWNER_APPROVAL_PENDING / NOT_SENT`**。Astra仅建议Owner批准，不以顾问意见或已往JPL单次授权替代新的收件人许可。

## 一、实际资料、身份和审阅限制

v10.0.10开发分支`codex/v10.0.10-natal-restoration`固定报告Commit `4222645703821ab20896765a31df1cfa375034ca`，Tree `b97a4d2f4b3135ed2970bdd324213845d9245069`，父为本版新源码Commit `0384a8ee65294931d35602b2a486f70ae3baedb6`（Tree `b14d2bc2130e4fe881744f18fc2301970066c00d`），其唯一父为上一阶段`54aaeca7bf8863554f07c6412fa912107e17b4b9`。GitHub真实`main`在复核时为`1bdc76c1e51b29af0e54ceb17b9bdb82eaf04c67`，未合入本版产品。

Astra通过GitHub连接实读固定版本：
- [合并实施报告](https://github.com/zcx369658780/EliteSync-v10/blob/4222645703821ab20896765a31df1cfa375034ca/docs/versions/v10.0.10/IMPLEMENTATION_REPORT.md)（Blob`b18a570d98797a500426160b174f0febfb68f111`）
- [唯一Owner集中决策请求](https://github.com/zcx369658780/EliteSync-v10/blob/4222645703821ab20896765a31df1cfa375034ca/docs/versions/v10.0.10/OWNER_DECISION_REQUEST.md)（Blob`61bb765a0775011151c4398c1bbaad201016f0d7`）
- [公开验证摘要](https://github.com/zcx369658780/EliteSync-v10/blob/4222645703821ab20896765a31df1cfa375034ca/docs/versions/v10.0.10/validation-summary.json)（Blob`a20e3bbcc1dfed1ebe14417548b020809f0cf4d8`）、`CALCULATION_CONVENTIONS.md`、`continuation_reference_sources.json`、新增Flutter显示与PHP起运口径及本版独立参考文件。Astra未在Windows直接运行测试；现场原始stdout/stderr/APP/DB及设备数据仍`CODEX_REPORTED / LOCAL_ONLY`。
- Owner在本次会话上传**旧仓库本地许可合规ZIP**，包SHA256 `06315ab9ce9ddc2776bfad125ffaa6537c0989aa01bc34e30d3ff5191adf567f`，169个ZIP条目/155个历史证据文件；Astra直接读取内附《旧EliteSync软件算法授权合规总结》、根LICENSE、`LICENSE_DEPENDENCY_STATUS.md`、旧Western canonical ADR、具名第三方LICENSE快照、锁文件和小结。原件仍仅在会话上传中，**未向GitHub上传ZIP或逐字公开其私有路径/原件**。该包注明其审计基线为旧`D:/EliteSync`固定Commit `0f06e895a89629a7f4f0cf0c62b784446ecf515a`，**不代表v10当前运行时SBOM或商业合同**。

## 二、阶段性技术验收结论

- Gregorian交运新增30个非作者日历输入×3转换口径=90项一致；沿用88个已冻结生产输出的83项参考够精度样本×3=249项起运对照一致，另5例保留不确定。此仅证明明确的lunar-php兼容Gregorian加法、月底/闰日和固定+08到IANA TZ换算，不自动证明古籍唯一现代计算方式或秒级交节事实。
- 恒星黄道自定义`CRC1956-23.25-true-frame-anchor-IAU2000A-v1`及`mean_lilith`计算补28例×3=84项非作者独立定义参考；源码与APP具名标注为**自定义而非官方Lahiri/旧引擎逐位相等**。对齐的IERS/ERFA模型族不冒充完全独立观测。
- 紫微新增680项合法样本部分辅星落宫和1512项选定大限/年运限规则对照；相对于冻结AC仍不足以证明全亮度、闰月/月初和全年/流曜完整能力。完整亮度已发现`太阴酉`、`七杀酉`具名流派异文，不能按少数值随意拼表。
- PHP15项130断言、Flutter默认与v1010 define各20项及定点静态分析由Codex报告exit0；本轮APP、API、DB启动/持久化、APK/AAR重建安装均**NOT_RUN**，旧build4实测仍归属旧源码，不能被当成本轮新标签软件联动已经现场验收。
- 独立源码抽查显示修改主要为Gregorian规则来源/回执口径、standards显式标签及参考/测试；未经审查的全部变更不冒充已逐行审核。**保持`CONTINUE_SAME_VERSION`，不可把检查点提升`FINAL_CANDIDATE`，AC-10-01/03/04/05/08等关键门未关。**

## 三、历史许可包与本版权利缺口的实际关系

- 旧项目根MIT声明只涉及其自有代码，不替代第三方许可、星历数据、题库或素材授权。
- 旧`lunar-php 1.4.0`MIT vendor许可证、`iztro 2.5.8`本地MIT包许可证、Astronomy Engine等MIT/BSD快照提供**复用历史来源证据**；旧`iztro`登记为OPEN_VERIFY但包内许可证更直接，正式准入仍应绑定v10实用包/锁及传递链。
- 旧`Kerykeion/Swiss/pyswisseph`被登记AGPL或商业/双许可受限，Western ADR为`Accepted(architecture)/Pending(commercial authorization)`；历史代码使用或源码MIT并未授予闭源商用许可，也不能解除v10显式依赖门。
- 该ZIP无具名Chiron/NIMA授权合同、权限授予或权利主体签名；旧报告自述**整个旧项目尚未完成闭源商用合规审查，不适用于v10**。因此旧包有助缩小重复审计，但**不能关闭Chiron数据权利，也不是禁止其最终获得许可的证据**。
- 旧包还登记了Baidu/Google等专有SDK与匹配/解释文案等长期全APP合规缺口，**不是此玄学本命版已经采用或须立即重新审计全部541条的证明**。其开放/验证/限制状态继续按实际新版本发行目标区别。

## 四、NIMA官方联系与建议范围

独立外部核验：Lucky Star官方[Chiron NIMAv16记录](https://lesia.obspm.fr/lucky-star/obj.php?p=1075)有具名SPK、1895～2023观测弧和0.090 arcsec观测残差；这些**不是1900～2101全域误差、商业使用或数据再分发授权**。项目[联系说明](https://lesia.obspm.fr/lucky-star/predictions.php)公开列出`josselin.desmars@obspm.fr`用于该页面的咨询；并不保证该研究者本人有权以个人名义授予单位/第三方数据商业许可。应当明确询问权利主体或正确转介。

**Astra建议Owner单独批准：**恰好一封致该官方公开邮箱、主题`Rights and coverage clarification for offline Chiron NIMA ephemerides`的纯权利/技术澄清邮件；使用已审`OWNER_DECISION_REQUEST.md`所附英文正文，可加一句请对方指明授权主体/许可负责人。只询问离线闭源应用/服务本地保存与运算、展示派生坐标、是否允许原样kernel再分发、覆盖和历史/远期不确定度、署名及费用/签约流程。**不得附真实生辰、源码、二进制、用户数据/秘钥，不承诺费用、购买、部署/重新分发或重复群发。发送前必须由Owner本人明确授权新的收件人与单次动作；原JPL邮件授权不能复用**。当前是推荐，不宣称已经批准/已发送/收到许可。

如日后得到答复，须核发送者是否有相应权利主体权限、授权对象/适用版本与使用范围、是否允许独立商业运行和再分发；NIMA文件受何第三方数据权利影响、时间域与实际精度，均另由Codex核证。没有明确适用的允许条件仍不能运行/分发Chiron；同时可以继续本版其余合法独立oracle、规则和边界工作。不自动因等待答复停工、购买Swiss、删冻结Chiron、放宽8AC或合main/K08。

## 五、工作流结论

`V10.0.10 NOT_ACCEPTED / CONTINUE_SAME_VERSION`。保持唯一正式冻结计划与Owner方案A。普通同版源码、合法参考和测试由Codex自行继续，**不发新微型任务单**。仅在下一次确实需要新第三方发信、付费/许可证承诺、隐私合同或重大互斥流派选择时向Owner集中提问。提交完整版`FINAL_CANDIDATE`前必须具合法Chiron来源及完整紫微/八字/西占独立参考和实际新源码APP/DB联动证据；所有现场结论如实标`CODEX_REPORTED`与`NOT_RUN`。

## 2026-10-17 后继事实：Owner一次性NIMA询问批准与Gmail发送确认

**`NIMA_ONCE_ENQUIRY_SENT / REPLY_PENDING / RIGHTS_NOT_GRANTED`**。

Owner在本会话明确回复“我批准仅向 NIMA 上述收件人发送一次限定权利询问，不授权购买或使用数据”，批准唯一收件人`josselin.desmars@obspm.fr`和原定主题`Rights and coverage clarification for offline Chiron NIMA ephemerides`。据此Astra通过已连接Gmail**实际发送一次**英文权利/覆盖咨询；Gmail发信回执为`SENT`，随后查询发件箱取得恰好一封同收件人/主题的已发送邮件。发送时间按Gmail回执为2026-10-17 23:52:44北京时间。**未附用户资料、源码、文件，不承诺付费，不下载/安装/使用Chiron数据，也没有改变JPL此前已发邮件状态**。正文明确项目尚未成立公司/未公开测试、仅独立开发者前期询问；同时询问授权主体、闭源本地运算、派生坐标、可选原样再分发、覆盖/不确定性、署名及费用过程；如收件人无权许可，请转介适格主体。

本记录仅持久化脱敏**事件状态**，不公开发件人身份、完整私人邮件ID/线程ID或Gmail私有URL；原Gmail回执可从授权账户核查。之前文档`EXPLICIT_OWNER_APPROVAL_PENDING / NOT_SENT`属于**原审查时点**，已由本节后继事实覆盖。当前`REPLY_PENDING`不能当作权利许可，也不代表对方已经接收/阅读/拒绝。v10.0.10开发分支未因发信获得新增引擎/数据准入或改变冻结AC，保持`CONTINUE_SAME_VERSION / NOT_FINAL_CANDIDATE / NOT_ACCEPTED`，其余独立oracle合法开发可自主继续。
