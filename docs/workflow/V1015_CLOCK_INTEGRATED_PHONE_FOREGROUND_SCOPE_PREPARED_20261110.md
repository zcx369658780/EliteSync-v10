# v10.1.5 同域时钟整合与手机前台先行范围准备｜2026-11-10

Owner接续普通工程后，已核实际产品根、origin、分支、HEAD与index；起点为ca07fdf6efe05adcc85c165667266d95249d9b05，远端同分支相同。index为空，仅无关`%SystemDrive%/`未跟踪，保持原样。最新case05终态与26912项ledger身份匹配；原根255项目录级状态与index匹配保存基线。没有设备、SDK、构建、安装或后端运行。

## 同域时钟整合

在新的私有HOST_ONLY工程包中整合已复核的修正及直接调用依赖，未修改冻结case05。实际`emulator-session.py`的Python起点、截止与elapsed统一使用`time.monotonic()`；原始QPC字段独立供原C#900秒监督器，三份native源文件与case05一致，未生成或运行native控制器。旧306.263保留且仍为`INVALID_FOR_SCOPE_DURATION_MIXED_CLOCK_ORIGINS`，398.098711仍仅事件时间戳区间。

新副本先以旧实现运行一项实际main测试，两种不同原点subtest均RED；整合后时钟、预查截止、transport及fresh UI定向套件29项通过。首次扩展检查因测试搬迁后的相对fixture路径失效而未运行套件，已保留失败输出；仅修正新副本fixture定位并补齐直接phone依赖后通过，未改旧fixture或放宽断言。原86Python/6native历史结果不冒充本轮重跑。工程包明确拒绝动态执行，不能当新模拟器启动候选。

## 已准备、尚未批准的手机前台资格范围

先独立解决case05手机前台资格阻塞，成功也停止，不接着启动模拟器或后端。候选仅HOST_ONLY，无owner grant、scope claim或任何动态执行。

| 项目 | 精确拟定范围 |
| --- | --- |
| 设备与软件 | 原固定Redmi、user0、已装同b621包；核身份/安装hash，不构建或安装 |
| 时限 | 工作120秒，独立清理最多15秒；Python起点、截止、elapsed同域 |
| 命令 | 最多24条ADB，普通命令最多22条、预留2条清理；从48/240接续，最多累计72，至少余168，不新设240 |
| APP打开 | 手机须已亮屏且解锁；目标APP不在前台时，明确组件Activity最多一次；不点击桌面或其他APP，不安全解锁、force-stop或更改权限 |
| 前台资格 | 每次UI前核本APP焦点，fresh XML只在内存解析；确认真实两空字段表单，必要时只点一次观察到的空手机号框，再以fresh可见手机号焦点验证；每阶段最多两次只读观察 |
| 数据与截图 | 不输入账号或密码、不提交登录、不截图、不导入或操作媒体、不保存原始UI/window输出；非空字段或mixed/foreign UI立即停 |
| 停止与清理 | 失败或成功都STOP；只清理由本scope先证不存在的唯一XML路径；STOP后禁止普通命令，保留外部STOP并保存实际耗额 |
| 不包含的动作 | 模拟器启动/安装、手机安装、APK构建、后端claim/启动/额度转交均为0 |

Owner已具备一般APP/UI控制权，本次不重复申请一般权限。执行这份新设备具体范围仍需Owner明确批准；批准绑定唯一绝对执行根、nonce、完整三项payload hash与单次claim，不能复制批准到新目录重跑。当前无批准且HOST_ONLY保持。

最终激活采用另行冻结的唯一`execution-01`目录，其三项源码/目标payload hash与准备稿相同，只更新执行根和nonce。该目录无grant/claim，实际main因缺授权而拒绝；批准后仅新增其proposal绑定的单次grant，不删除准备根HOST_ONLY、不修改入ledger原证。原准备根proposal作为早期草案保留；最终批准对象为`execution-01/proposal-private.json`。原私有报告/交接里的解除HOST_ONLY描述由`ACTIVATION_ADDENDUM.md`纠正，第一版保存回执另存原文。

手机候选15项主机测试通过，含桌面→明确APP组件一次、已前台不启动、锁屏/截止拒绝、foreign UI/非空字段保护、超时计数、清理预留、完整manifest、目标替换拒绝、复制批准拒绝、运行中STOP与耗额保存。对STOP门与执行根门分别做隔离变异，两项对应测试均按预期失败。非作者Codex只读复核已修复发现的问题，最终无剩余P1/P2；这不属于外部验收或真机效果验证。

本范围只是前台资格诊断，不是双端或媒体验收，也不自动授予后续模拟器预算。后续若准备双端接续，须在其本次执行内fresh核手机前台，不能把此次未来可能得到的旧资格当作永久前置证明。原唯一未耗后端仍封于case05/backend STOP；本候选不转交、不消费，也不重复申请这一次未耗后端。

## 状态与保存

产品源码仍1f936d253dbccceb2c719ea16de4f25be2789b4d，已装APK身份不变。10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING；登录、双端、媒体NOT_RUN，缓存真机效果UNKNOWN。功能优先，UI最后依我的和设置→消息列表和聊天→首页及主要导航。

旧case05及全部STOP/claim/额度、旧ledger、SDK/AVD/Sources、原main根/index/255项状态和产品无关目录均保留。新原证只在私有工程包保存，新ledger仅追加该新包文件，不遍历旧资产、不重哈希运行镜像。GitHub仅同步本节点和当前入口/进度摘要；私有脚本、配置、APK、截图、凭据、许可证、SQL不上GitHub。不合main、发布或启动v10.1.6。
