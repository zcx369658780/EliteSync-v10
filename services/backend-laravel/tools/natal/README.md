# v10.0.10 本命计算开发链

本目录为冻结方案 A 的实施代码，**不是已接受版本**。具名规则、独立参考的覆盖范围及来源限定见本版综合报告；不能把局部对照或代码存在当作整版验收。计算结果保留 `UNVERIFIED`，不能用于匹配评分、硬筛选或关系事实判断。

## 依赖与数据

PHP 使用现有 `composer.lock` 中 `6tail/lunar-php 1.4.0`；Node 使用 `tools/ziwei/iztro-runner/package-lock.json` 中 iztro 2.5.8 及五项传递依赖。保持原锁，分别安装为 `composer install --no-scripts --no-plugins` 与 `npm ci --ignore-scripts --no-audit --no-fund`，不要更新依赖或启用旧研究许可开关。

Python 已实测环境为 CPython 3.11、Windows x86_64。六项 wheel 的固定 hash 在 `requirements.windows-cp311.lock`，安装到独立 venv，使用 `pip install --require-hashes --only-binary=:all: -r requirements.windows-cp311.lock`。其它平台的二进制身份和运行验证 **NOT_RUN**，不能把此锁误称跨平台已验证。运行时会核实际版本、包元数据、关键实现、ERFA 闰秒及 Skyfield 时间表、解释器和 kernel 身份；改变身份后旧持久结果失效。身份探测会额外启动一次本地进程，实测约 0.43～0.62 秒，不访问网络。

完整依赖/数据清单在 `resources/natal/dependency-manifest.json`，包内许可证原文在同目录 `notices/`。NumPy Windows wheel 包含 OpenBLAS、LAPACK 和附有 GCC Runtime Library Exception 的运行库，不能只标 MIT；Certifi 未修改，保留 MPL-2.0 通知、全文及源码获得说明。当前 Git/APK 不分发 CPython 或整个运行环境，未来若打包这些二进制须一并保留其条款。

从 NAIF 官方地址获取**未修改**的 `de440s.bsp`：

`https://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/de440s.bsp`

字节数 `32726016`，SHA256 `c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2`，官方 MD5 `3917ee56769db332790c751e2168843d`，TDB 覆盖约 1849-12-25～2150-01-21。遵守 [NAIF 规则](https://naif.jpl.nasa.gov/naif/rules.html)；该条款覆盖 NAIF 分发的 kernel，不能推广为 SSD/Horizons Chiron 数据许可。本目录不内置 SPK，不自动下载，也不捆绑 SPICE Toolkit。

Kerykeion、Swiss、pyswisseph 保持原许可证门。Chiron 使用 [Lowell 数据清单](../../resources/natal/chiron-data-manifest.json)中固定的元素事实和自有离线轨道，不使用待回复的 JPL/NIMA 数据。所选 `astorb.dat` 采用原作者明确的署名使用/复制/传输许可；保留 [完整署名](../../resources/natal/notices/Lowell-astorb-Chiron-ATTRIBUTION.txt)，不把该许可扩张到其它目录或原始观测。`full` 现在真实计算十主体、真南北交点、平均 Lilith 和 Chiron；数据缺失、hash/准入不符或越界均拒绝，不在线回退。

轨道制品 SHA256 `b8172992366c783e8cc65789e4837f432d3cb496c5f503b1a776275518a059e3`，438113 字节，9182 个八日节点。它是有限力模型的自产轨道，独立样本对照不等于全连续日期的物理误差保证。只在显式离线构建时执行 `chiron_build.py --kernel <已核DE440s路径> --gm <已核gm_de440.tpc路径> --output <不存在的输出路径>`；无下载、覆盖或服务启动行为。GM 官方地址、hash、NAIF 条款及所有构建源码 pin 在清单内。请求时只做经 hash 校验的 Hermite 插值和视位置运算。制品、manifest、reader 和署名参与缓存签名；Laravel 核对计算实际使用的数据与 manifest 身份，防止数据变化后以旧签名落库。

Chiron 独立参考的可重放代码及仅参考环境的锁见 [oracle/CHIRON_REFERENCE.md](oracle/CHIRON_REFERENCE.md)。SciPy 不属于产品运行依赖，Gaia 原始状态/协方差未分发；JPL/NIMA 邮件仍为待回复，不重复联系。

## 本地接线

配置名称为 `NATAL_PYTHON`（独立解释器）、`NATAL_NODE`（本地 Node）、`NATAL_JPL_KERNEL`（已核 SPK 文件）。不得把真实配置、凭据或出生资料放进参数、仓库或对外请求。PHP 通过参数向量启动本地脚本，生辰只经 stdin；脚本没有云端算法 fallback。

仅在新建、明确归属且只含虚构资料的开发数据库执行迁移 `2026_10_17_100010_create_user_natal_profiles_table`。它增加本人私有派生表，不回填旧 canonical、旧私有镜像或匹配数据。不要针对生产/历史数据库运行本说明。测试 API 可绑定 `127.0.0.1:8010`；受控 Android 构建使用 `ELITESYNC_V1010_LOCAL_BUILD=true`、独立 `.v1010test` 包，实际显示版本仍为 `0.08.04`。不要把构建开关当生产配置。

本人鉴权接口 `GET/POST /api/v1/profile/natal`。POST 包含 `input`、`settings` 与 `expected_revision`；保存后 APP 再 GET 核对 revision/signature 才显示结果。重复同输入可复用结果，过期编辑/过期计算不能覆盖新版本。失败保留输入、清空结果；必须重读再编辑。代码、依赖、时表、规则或数据变化后 GET 显示 `STALE_RECALCULATION_REQUIRED`，不展示旧盘替代。

输入为公历当地日期、时间及精度、IANA TZ、可选成对 WGS84 坐标；DST gap 拒绝，fold 要明确。未知时间不补 12:00。算法性别是单独确认的传统规则参数，不推断公开性别。已有生日可保存范围保留；目前未获独立参考的历史域明确 `UNVERIFIED`。目标运限年不得早于出生年。

## 固定计算口径

完整的兼容 Gregorian 顺序/截日/时区/舍入、具名恒星黄道和 Lilith 定义见 [CALCULATION_CONVENTIONS](CALCULATION_CONVENTIONS.md)。现代工程换算约定与传统比例来源分别登记；既有数值口径保持，新增 profile 说明使旧缓存按原合同失效。

- 八字：lunar-php 1.4.0，日sect 2、起运sect 1，年月柱用恢复后的节令TT半开区间；起运端点按ERFA与历史模型UT1转换到固定＋8日历标签。日时柱继续用当地民用或所选真太阳时。原始库标签保留，不能误标UTC；完整时间政策见计算约定。独立PHP计算测试也需传入本版 `NATAL_PYTHON`，未配置则拒绝精确计算，不默退旧框架。
- 紫微：`iztro-2.5.8-modern-default-v1`，农历年界，闰月前十五日归本月、后半归次月，早晚子采用 current。封诰明确寅起子顺行，保留已发现逆行异文及首轮失败；宫干飞化是来源宫干→化星→目标宫的有向边。目标年以七月一日为明确参考日，出生当年晚于该日则用出生时刻；不是声称该年所有时刻运限恒定。
- 紫微亮度仅回移官方2.6.1确认的酉宫三格数据错误修复：太阳陷→平、太阴不→旺、七杀庙→旺，包与锁仍为2.5.8。具名修正profile、固定源码身份及MIT通知见 `resources/natal/ziwei-upstream-corrections.json`；输出保留 `engine_brightness` 与修正来源。它不是从不同流派表逐格挑值，也不证明完整亮度独立oracle已经成立；原失败与古今异文保留。
- 西占：十主体为地心视位置、真黄道/真春分点 of-date；DE440s 外行星 4～9 明确是重心目标。四轴与 whole/Placidus/Alcabitius 真实计算；极地无适用解不暗换宫制。恒星黄道是具名现代重建 `CRC1956-23.25-true-frame-anchor-IAU2000A-v1`，1956-03-21 TT 的 23°15′固定惯性方向锚；**不是已证明逐位复现官方 Lahiri**。
- 真交点为 DE440s 地月瞬时轨道平面北向交点及其对点；平均 Lilith 是 IERS2010 `F+Omega-l+180` 平均远地点黄经，零纬是盘面约定，不能冒称瞬时真实远地点或已证原版定义完全相同。
- 1960 年前民用归一标签按 UT1 解释；其后 ERFA 处理 UTC、漂移秒和闰秒到 TT。UT1 来自已记录 Skyfield DeltaT 模型，未来闰秒未知。Python 日期不支持输入字面 `23:59:60`。

## 验证与后续欠账

PHP `V1010Natal*` 测试、Node `tools/natal/tests/ziwei.test.mjs`、Python `tools/natal/tests/test_*.py` 与 Flutter 本命/设置/会话测试是局部回归，不能代替独立算法参考或实际 APP/持久数据库链。显式指定本版自有 kernel/解释器的环境测试不得指向旧用户数据或生产配置。参考脚本 `oracle/` 与独立来源清单只验证其声明字段；fixture/mock 合同测试不能提升为数值 oracle。

合盘/synastry/composite、行运/transit、太阳/月亮回归、法达及其它已证旧动态/关系盘仍是**内测前必须恢复的具名欠账**。本版没有实现或验收这些功能；新 natal 数据在旧动态预览入口拒绝派发，不删除原台账，也不以本版源码存在宣称完整旧 APP 已恢复。
