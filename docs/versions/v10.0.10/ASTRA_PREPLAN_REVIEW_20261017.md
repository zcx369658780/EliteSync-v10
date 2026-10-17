# EliteSync-v10｜v10.0.10 三盘算法恢复：Astra 独立版前规划审查

2026-10-17。

**`PREPLAN_DIRECTION_ACCEPTED_WITH_FREEZE_RESERVATIONS / OWNER_SCOPE_DECISION_REQUIRED / PLAN_NOT_FROZEN / IMPLEMENTATION_NOT_STARTED`**

## 一、实际审阅身份及证据边界

Astra通过GitHub连接实读固定候选Commit `70ca8a945dc933f33ff815058b29813c744e6009`（Tree `294f43f46fbd45be4e3771c2cb2415cb45db3aa2`）中的：
- `docs/versions/v10.0.10/PREPLAN_REPORT.md`，Git Blob `88b16d64b48078349ba07f229a58600f4e54221c`
- `docs/versions/v10.0.10/PLAN_CANDIDATE.md`，Git Blob `afade84f4b23be011384949e4130895c84dbecc4`

该候选唯一父提交为已完成v10.0.9 K08的正式产品main `a1ce6473e85ee02786fc2fb4bb33ca1eac46ea8f`，GitHub compare确认**仅新增上述两份文档、无产品源码变化**。Astra另从已接受main直接读取了代表性`AstroProfileController.php`、`LegacyInputWesternNatalEngine.php`、`ZiweiCanonicalService.php`、`AstrologyDependencyGateService.php`及相关`config/*.php`，核对A07恢复台账、Owner D6及v10.0.7接受边界。Codex声称的Windows/本地旧库实际调查属于`CODEX_REPORTED`；本轮没有运行算法、安装依赖或测试，不能以计划证据充当软件验收。

## 二、通过的方向和不能夸大的事实

认可把八字完善、通用紫微排盘、西方本命星盘、统一输入/时区、算法独立验真、Flutter/API/真实隔离数据库纵向链、持久及缓存失效、隐私与可选解释组织为**同一v10.0.10大功能版本**；不另拆宫位/字段/接口的小版本。D6允许在剩余主要功能恢复后再做完整APP/Web联合验收，无需重新修订整个路线图。

源码证明当前：
- lunar-php真实计算基础已经在v10.0.7按其冻结限定范围通过，不代表全部扩展字段、顺逆起运和准确性均验真。
- 紫微通用路径含seed/approximate与未完成或`pending_oracle`字段；iztro 2.5.8为候选，不能以shadow runner、旧温墨样例或空四化/飞星字段冒完整。
- 西占默认`legacy_input`可用CRC seed产生月亮/上升估计，`western_lite`与正式canonical门仍有限制；旧Kerykeion源码线索、Flutter宫制/黄道设置和缓存来源签名不能直接证明所有模式真实计算。
- 真实时刻IANA时区/DST fold与经纬度来源、真太阳时的不同用途、旧noon占位、cache请求代际/结果版本和非时间安星参数均须在同一源合同正确区分。未知值绝不偷偷补成确定出生事实。
- 本版不修改当前匹配评分与独立CN/MC、资料访问控制、canonical真实字段；天文历法/规则一致性不能当成占卜预测效力科学证据。

## 三、引擎／许可的有条件同意

**同意A作为优先技术可行性路径、不是技术已交付或法律放行**：现锁`lunar-php 1.4.0`＋`iztro 2.5.8`＋待准入`Skyfield 1.55`/具名JPL SPK＋自行实现可核的宫制、四化和时间规则。独立已复核Skyfield1.55公开MIT元数据及NAIF官方SPICE使用/原始kernels再分发原则（https://pypi.org/project/skyfield/1.55/；https://naif.jpl.nasa.gov/naif/rules.html）；但实际分发包/直接与传递依赖/数据文件的完整LICENSE、NOTICE、kernel来源、hash、再分发条件仍须在首次受控获取/采用时实读并归档。核查其适用范围和精度，不得称NASA源等于所有天文数据自动MIT。

**保留B的许可门**：Kerykeion/所依赖的libephemeris和Swiss/pyswisseph实际采用版本有AGPL/双许可及版权主体差异；不能靠sidecar、`ASTRO_RESEARCH_MODE`、切后端或某外壳包MIT绕过。参见https://kerykeion.net/python-library/docs/v6/ephemeris_backend 及https://www.gnu.org/licenses/agpl-3.0.en.html。对闭源商用授权或开源合规义务需要确切第三方许可审查和Owner最终决定；本版默认**不购买、不启用受阻引擎，不调用其未准入实现作在线fallback或生产oracle**。

**关键技术限制**：Skyfield/JPL给日月行星天文位置，不自带完整占星宫制、扩展小天体、紫微四化与命宫飞星；DE440s也不自动覆盖Chiron等所有旧扩展点。不能仅以三款依赖名字满足“full”。在同一版本执行中先取到独立参考/许可与字段覆盖证据，证明可行后再扩大实现；若不具备完整必达能力，保持该字段`BLOCKED/UNVERIFIED`，向Astra集中报告，不得悄悄删除必达功能或扩大误差阈值。第一阶段可行性与后续实现属于**同一个综合版本任务**，不是另发几十份只读/审查任务。

## 四、必须在正式冻结计划内收敛的口径

**F1：计算Profile/流派规则**：冻结一份有出处、可复现的默认表及必要用户可选profile；八字维持v10.0.7已接受行为，23:00/00:00与子时边界的修改须以证明及具体新策略说明；紫微必须一套贯通闰月、安星/主辅小星、四化、宫干飞化/命宫飞星的同流派规则与可获取独立参考；西占旧默认tropical+Placidus可作为候选主profile，Flutter现有sidereal/whole/Alcabitius设置如正式保留必须真正改变计算，sidereal ayanamsha要具名固定。严禁混流派表或者“引擎默认”不披露。实现团队可以自主选定**不改变已接受产品语义**的规则；若涉及新的重要用户结果/默许旧版错误，请Owner一次决定。

**F2：恢复范围与旧动态盘扩展**：必须逐项列出实际旧APP的本命排盘、Chiron/Lilith/交点、bazi大运流年、紫微运限、合盘、transit、return、法达等哪些是原版已实现而非仅演示/预留。**Owner需明确本版是否同时承担旧合盘／行运／回归／法达等时间与关系扩展**，还是本版专注三盘本命与本命扩展/八字大运流年/紫微运限，动态和关系盘明确保持具名后续必恢复项、内测前完成。不能无声删去恢复基线。只有此项需要此时向Owner发起合并式产品范围确认。

**F3：独立oracle与定量口径**：接受多来源方法，不将HKO公农历表误称每日干支或秒级节气oracle；HKO范围1901–2100和旧可存出生年份分开，不缩小既有保存域，超参考覆盖但无法验证处明确`unverified/not_applicable`。紫微飞星、四化、亮度的现代完整独立源目前`REFERENCE_PENDING`；在真正能够取到并覆盖所冻结字段之前，不允许`AC-10-04 PASS`。Skyfield与JPL Horizons共享历表应诚实表述为独立实现比较；宫制与紫微规则要非作者独立推导，不用生产输出生成expected。≤60秒节气/真太阳时、≤0.001°十主体黄经、≤0.01°宫尖是有条件的工程建议，不可在来源未匹配模型/时标和独立可测能力前宣传已达到。测试样本64/48/96与各盘24例非作者盲测可保留为覆盖计划，但**验收以必达字段、规则分支、边界、独立来源可核为主，不以单纯凑数量替代质量**。源不足不得降低标准或伪造expected；真实不能达成时阻断有问题字段并集中返Owner/Astra。

**F4：隐私和新资料语义**：默认继续现有canonical事实与私有访问合同，出生时区、坐标、算法用的非时间参数须用户明确确认，避免用公开gender或无效缺省作排盘事实；无外部真实生辰上传、额外付费、AI模型外发、商用受限依赖、自动系统改动。确需扩大资料合同/共享范围/对外调用时，先请求Owner新许可，不能预先将此类内容写进通用实施权限。

**F5：合同强度与实现可行性**：建议保留`AC-10-01..08`八个综合目标，以真实安装APP→Laravel→合法算法→独立开发DB持久重读/缓存重算/重启→非作者oracle作为交付；原AC-09及旧失败不重开。正式冻结文件必须是**一份唯一plan**，具名流派/可用算法版本/必达字段/验证参考及受控本地服务和设备范围一次明确，不要将当前含大量`待选`的候选改名为Frozen Plan。Owner批准后由Codex同版自主开发/回归/内部审核/Astra独立验收，不为每个模块反复来回派发小任务。

## 五、当前裁决与下一步

**`PREPLAN_DIRECTION_ACCEPTED_WITH_FREEZE_RESERVATIONS`**，这不是`PLAN_FROZEN`、不是`IMPLEMENTATION_AUTHORIZED`、不是算法运行验收。目前只需一次Owner对于F2恢复范围的集中决定；F1/F3/F4的常规技术取证和口径收敛由Astra/Codex在下一份唯一冻结计划与同一实施任务内负责，许可或增加敏感资料如发生再报Owner，不额外制造版前小任务链。

推荐Owner选择：v10.0.10必达**三盘本命完整计算+原版有证据的本命扩展（含八字大运流年和紫微运限）**；对旧合盘／行运／回归／法达等如确为原版可用则具名保留在紧接的剩余功能恢复包、**内测前完成**。备选为同一v10.0.10包含全部经证实的动态/合盘能力，工期/独立参考/许可要求随之提升。不应无证地称其原版已恢复，也不能将其降为无限期`Later`。

正式main依然保持v10.0.9 K08已完成状态；本次评审仅是docs-only顾问意见，不合入预规划分支、改算法源码、改接受路线、冻结新AC或授权购买/运行/生产。
