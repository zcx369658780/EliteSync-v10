# Chiron 独立参考与复算

产品轨道仅由有署名许可的固定 Lowell 元素记录生成；本参考使用 ESA/Gaia 的另一拟合初值、非作者独立力函数、SciPy DOP853 和 ERFA 投影。两者共享主要行星数据和有限物理方程，因此是独立软件及外部初值对照，不能称独立物理模型或不相交观测集。

`chiron_gaia_reference.py` 不导入产品 reader、Lowell 初值或产品 actual，不联网、不自动获取数据。`chiron_force_reference.py` 保留非作者源字节；参考输入、力函数、GM 和 kernel 在使用前核固定 SHA256。构造器的 TCB→TDB、Gaia FPR AU→IAU2012 AU 转换、两部 JD、光行时、有限源引力偏折、像差、ERFA 真黄道/真春分点 of-date 和中心 60 秒速度分别在源码中列明。

在**独立参考环境**安装 `requirements.oracle.windows-cp311.lock`，使用固定 CPython3.11 Windows x86_64 wheel。SciPy1.16.3 wheel SHA256 为 `53c3844d527213631e886621df5695d35e4f6a75f620dca412bcd292f6b87d78`；其 BSD 及随包 OpenBLAS/LAPACK/GCC Runtime Exception 条款需保留。运行锁中的六项原依赖保持不变。该环境不是产品依赖，不把 SciPy 或其二进制复制进 APK/服务部署包。

先按适用的 ESA/Gaia 数据条款在内部保存固定单对象响应；本仓库不分发原始状态或协方差。该响应 SHA256 为 `be29b90a286b049717dd72a482c626bb15ad24aeed6214db63b108ad60448b69`，对象号必须为2060。来源是 ESA TAP 的 `gaiafpr.sso_source`，选取 `number_mp=2060` 的状态、历元与协方差字段；具体查询、原响应及回执保留在本版 LOCAL_ONLY 原证。不得以论文 CC-BY 或镜像标签替代原数据权利。参考使用需署名 ESA、Gaia、DPAC 及原数据说明。

调用 `chiron_gaia_reference.py --kernel <固定DE440s> --gm <固定GM> --gaia <固定单对象响应> --inputs <虚构TT输入JSON> --output <不存在的输出JSON>`。输入可为 `cases:[{id,tt:[年,月,日,时,分,秒]}]`，或 `inputs:[{id,tt_calendar:"YYYY-MM-DD"}]`；TT 日期固定在1900-01-01至2101-01-01，ID须唯一。先生成并冻结 expected，再用独立比较器读取产品 actual；原 expected 不因比较差异而重写。

本轮96个既定日期与24个新选时间均有视经纬、距离、速度与逆行结果；另10个独立参考停滞点的两侧20时间单列。经纬阈值0.001°及逆行一致实际检查；距离/速度只报告诊断最大差。24例只有输入选择对 actual/轨道盲，主参考作者 NOT_BLIND；另20例是 reference-selected，不能扩充盲测数。参考方法已可携带，原科学计算与端点 raw hash 仍按原回执绑定，不因代码移动冒称新一次科学验证。

必须保留的限制：省略原拟合中的10颗扰动小行星、完整EIH/J2、非引力项和协方差传播；Gaia/Lowell 观测可能重叠；视偏折采用接收时刻扰动体位置；ERFA2006A与Skyfield2000A/Capitaine框架接近但不声明逐位等价。样本和数值收敛不能代替世纪全连续日期的不确定度界。实际源许可、数值对照、APP/持久库链、版本独立验收是不同事实。
