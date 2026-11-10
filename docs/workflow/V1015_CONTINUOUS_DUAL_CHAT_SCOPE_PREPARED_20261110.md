# v10.1.5 完整双端文字验证连续候选已准备｜2026-11-10

按[Owner连续推进决定](../decisions/OWNER_CONTINUOUS_ENGINEERING_SCOPE_20261110.md)，本次不再把手机前台资格当作独立运行的终点。已在新的私有工程包整合一个连续入口；中间成功直接进入下一阶段，没有逐动作的Owner确认或成功STOP。旧两份手机scope与case05的STOP不改。

## 连续目标与准确范围

一次执行自动衔接：手机同机/user0/同已装b621、亮屏解锁及fresh实际APP/可见空登录页→新隔离模拟器启动、OS、同包安装、APP空表单/焦点→两端fresh完整空表单与IME协议→独占接续原未耗后端一次→两个白名单虚构账号真实登录、双向文字→APP-family HTTP及唯一MariaDB密文/解密行证据→两端退出和统一清理。预检看到部分空字段仅证明当前前台，不能授权输入；任何输入前仍须本次完整表单基线。模拟器等待后会重新核实手机，不沿用上次资格或陈旧表单。

| 项目 | 冻结候选 |
| --- | --- |
| 时间 | 整段900秒，含手机预检；所有阶段共用一次45秒清理，不重开时窗 |
| 手机 | 原固定Redmi/user0/已装b621，累计76/240，现余164；同一命令ledger续计，普通最多148、清理预留16 |
| 普通UI | 必要亮屏最多2次，不安全解锁；仅明确NON_TARGET时最多打开固定APP组件1次；字段缺失/null/歧义不冒充非目标 |
| 模拟器 | 需要新的启动、同包安装各1；旧已耗不继承或恢复；控制120＋UI160合计最多280条ADB |
| 原资源约束 | Guest 2GiB/2核，Job 6GiB/64进程；启动fresh可用5GiB，后端原3GiB门，工作卷8GiB、输出2GiB边界保留 |
| 后端 | 新增0，只独占转交case05/backend原未耗1；准备时未转交，原STOP保持，不重复申请该次数 |
| 数据/服务 | 两个已有白名单虚构账号、现有本地API/WS/MariaDB与固定镜像；原容器State保护、只管本scope资源 |
| 排除 | 不构建APP、不重装手机、不改权限或安全解锁、不做设备媒体/RTC、不下载/外部服务/真实账号/生产/发布 |

APP/UI一般权限保留。本候选需要的是整段新范围及新增模拟器启动/安装各一次的准确批准；批准后普通检查、观察等待、导航、必要输入及互发在此范围内连续完成，不再分阶段询问。明确身份/安全/transport/资源/真实额度/总时限或可信证据失败才结束本次范围；不把有限观察等待当新运行次数。

## 主机整合与检查

前台修正进入预检、两端适配器、完整表单/IME和后台资格的所有直接消费点，统一使用displays与严格脱敏分类。手机在模拟器claim前真正核APP，不再仅get-serialno；预检和后续同一ledger计数不清零。总控自动接续两端准备、登录互发与退出，不复制或复活旧入口。

Python起点、截止与后台/API timeout均直接用原monotonic，epoch仅显示；C#监督器保留独立原QPC900秒门，不换原点、不重计900。后台截止单次取时，递增时钟也不能超过原截止。第一个结束/失败点原子冻结清理截止，root/dual/E/B都取同一45秒；启动失败一经观察即并发清理，不等E先清完。

自有UI路径先证明不存在，再在真正派发dump前原子记录“可能创建”；reverse每条派发独立落盘，父进程截断后仍可恢复已发出资源。不会因首次dump超时而漏清理，也不会用后一阶段的新时窗延长资源寿命。原有节点的错误和遗漏不回写。

99项Python主机检查通过，覆盖整段无中间STOP、真实Phone适配器预检→第11条继续同ledger、原预算/单次批准/独占转交、被杀主机子进程的ownership恢复、实际dump超时、唯一清理时窗、墙钟正反跳、递增monotonic、普通亮屏/安全锁及完整观察器/登录/后台回归；另执行6项原生监督时钟纯方法检查，未启动SDK。首轮旧夹具缺新clock或u0格式的失败及主机CRLF断言失败均保留，修正新副本夹具后通过，无跳过断言或放宽运行判断。非作者只读审查发现的6项P2均已修正并回归，最终无剩余P1/P2；这是工程准备，不是动态或外部验收。

## 准备身份与保存

私有根名`v1015-continuous-dual-chat-20261110-case01`，批准对象为其proposal-private.json，冻结71项payload。无actual reply/request/grant/claim或父backend transfer；两个真实入口均在未批准时拒绝，设备/SDK/Docker/数据库/API执行为0。HOST_ONLY标记保留准备时的原始事实；将来仅新增绑定准确Owner回复及proposal hash的实际请求/授权与独占transfer，不删除准备原证。新AVD只生成配置，未复制或哈希运行镜像，旧SDK/AVD/Sources不扫描；具名原manifest及必要模板按引用复用。

本次起点6dabba3c9ff0767d936adf7e86abbb6366d14162，产品根/remote/分支、空index及仅无关`%SystemDrive%/`核对一致。ledger从27077仅追加新包文件；原main根255项状态/index与历史原证保持。最新私有三件为新包HANDOFF_PROMPT.txt、IMPLEMENTATION_REPORT.md与final-local-github-receipt-private.json，精确最终HEAD/ledger/hash以回执为准。GitHub仅脱敏节点、决定及当前摘要，不上传私有源码、模板、配置、日志、设备身份、APK、截图、凭据、许可证或SQL。

产品源码仍1f936d253dbccceb2c719ea16de4f25be2789b4d，已装b621未动；phone仍76/240余164。10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING，真实双端互发/媒体NOT_RUN、缓存真机UNKNOWN。功能优先/UI最后，不合main、发布或启动v10.1.6。
