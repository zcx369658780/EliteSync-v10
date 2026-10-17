# v10.0.10 计算约定与验证边界

此文件明确现有兼容行为，不改变冻结 AC，不把工程约定当作传统唯一正确答案。输入、规则及实际依赖的身份仍进入缓存签名。日期参考与数值参考分别证明各自字段；任一局部通过不提升整盘为 VERIFIED。

<a id="qiyun"></a>
## 起运比例与 Gregorian 交运

传统来源支持三日一年、一日四个月、一时辰十日及顺逆数节。它们不唯一规定现代 Gregorian 加法或 DST。沿用已接受 lunar-php 1.4.0 的口径，具名为 `lunar-php-1.4.0-sequential-gregorian-clamp-utc8-v1`，不改库以匹配另一流派。

1. 有 UTC 时，先把出生瞬间换为**固定 UTC+08:00**；同一瞬间的年/月柱、邻节和起运不随用户 TZ 或真太阳时开关变化。没有 UTC 的旧内部输入保留 `compatibility_wall_time`，不给它虚构 UTC。
2. sect 1 默认：把固定参考墙钟映为 `12 × Gregorian 日序 + min(11, floor((小时+1)/2))`。后端点减前端点的非负整数每 36 单位一年，余数每 3 单位一月，其余每单位十日；小时为零。**23 时在此兼容算法的末桶 11，而非用于时柱的子时桶 0**。分钟和秒不参与此折算；不能声称任意秒差会线性影响起运。
3. sect 2 可选内部规则：端点分别截去秒，再减整分钟。每 4,320 分钟一年、360 分钟一月、12 分钟一日、余一分钟两小时。是端点标签截秒，不是精确秒差再四舍五入。
4. 得到非负 `(年,月,日,小时)` 后，严格顺序执行：出生年加年，若目标年没有该日则截到月末；再加月，再截到月末；再加 Gregorian 整日；最后加小时。保留出生时分秒。年/月不得先合并：例如闰日先加一年会先变为二月二十八日，后续加月不会恢复二十九日。
5. Gregorian 闰年用 4/100/400 规则。主要域 1901–2100；交运结果可能延伸以后。lunar-php 的 1582 改历特殊行为不在此次现代日历证明范围内。
6. 以上算术完成后，固定 +08 墙钟得到唯一 UTC，再转换为用户 IANA TZ；不在 DST 用户墙钟上直接加年/月，因此结果不会产生待猜测的 gap/fold。两个同样的墙钟时间可带不同 offset，显示必须保留 offset。
7. 返回的秒只是保留原出生秒，**不是邻节天文误差或真实交运时刻的秒级认证**。HKO 分钟表只能在分辨率足够的非边界样本证明折算桶；节令附近仍保留参考精度限制。

兼容实现来源：[lunar-php 1.4.0 Yun](https://github.com/6tail/lunar-php/blob/1.4.0/src/Yun.php)、[Solar](https://github.com/6tail/lunar-php/blob/1.4.0/src/Solar.php)。独立日期算术使用 [Python datetime](https://docs.python.org/3/library/datetime.html)、[calendar](https://docs.python.org/3/library/calendar.html) 和 [zoneinfo](https://docs.python.org/3/library/zoneinfo.html)，并保留非作者盲选样本；这独立于被测库，但不认证传统比例是自然事实。

<a id="western"></a>
## 恒星黄道与 Lilith 的具体定义

恒星黄道始终使用 `CRC1956-23.25-true-frame-anchor-IAU2000A-v1`。在 1956-03-21 00:00 **TT**，取真黄道/真春分点框架经度 23°15′、纬度零的单位方向；旋回固定 ICRS 方向，再在目标时刻真黄道/真春分点框架投影，该经度为减去的 ayanamsha。对行星和四轴/非整宫宫尖减同一偏移；整宫制在移动后的恒星 ASC 所在星座重新划分。速度使用各端点各自偏移，不把岁差贡献遗漏。

[IMD Positional Astronomy Centre 的 Panchang 说明](https://packolkata.imd.gov.in/panchang/en/explanation)提供 1956 锚值的背景，但不唯一规定本实现选择的现代框架、TT 和旋转。**这是具名自定义现代重建，未证明等于官方 Lahiri、Swiss Lahiri 或旧版逐位输出**；不把这些名字用作精度背书。产品页面须显示自定义标识。只有独立相同数学定义对照通过，才能说该定义的计算符合；不能由此认证其它标准等价。

`mean_lilith` 是 **mean lunar apogee**：IERS2010 Delaunay 基本角 `F + Ω − l + 180°`，以 TT 儒略世纪求值，再以 IAU2000A 黄经章动转到盘面真春分点。其零纬为盘面约定，距离为空；不是瞬时真实远地点、插值/振荡黑月、假想第二卫星，也不以同名证明旧版定义等价。基本角来源：[IERS2010 第5章式5.43](https://iers-conventions.obspm.fr/content/chapter5/icc5.pdf)。现有 ERFA 基本角分解对照独立于合并多项式，但共享 IERS 规范。

真北交点另定义为 DE440s 地月瞬时几何轨道平面与同一真黄道面的北向交线；南交点取其对点。它们不是平均交点，亦非对观测事件作时间插值。Chiron 权利未准入前不计算；`full` 继续明确为 `PARTIAL_FULL`，不得用其它点补位。
