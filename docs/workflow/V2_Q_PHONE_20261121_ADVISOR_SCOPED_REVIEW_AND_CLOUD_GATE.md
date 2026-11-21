# EliteSync V2-Q｜Android实机续测独立顾问审查与阿里云门禁

日期：2026-11-21。顾问状态：**PHONE_ADVISOR_PARTIAL / SAFE_LOCAL_CONTINUATION_RECOMMENDED / CLOUD_PRODUCTION_NO_GO / CLOUD_STAGING_PREFLIGHT_ALLOWED_ONLY / ADMIN_RESTORE_NO_GO**。

## 固定来源/证据等级

- Owner本次直接上传`V2_Q_PHONE_TEST_REPORT_20261120.md`，SHA256 `790c5b16c0f64ac0701640062d841007277ed0f3c37bc1219e65da1b4eb0eb42`；同时上传完整Q工程报告SHA256 `ddf80452c197ca4ee927cb6f25bdd04914f30b4e6bf2e99a3dedc749027da2ba`。上传材料在本次网页会话直接阅读，本地私有日志/XML/SQLite、USB手机及 APK 并未被顾问独立打开/运行。
- Q源码`5e457fb0fd21c5978864f146d78120cc9a7d025b`、交付`b35f6d0aa43a80e648143a30fbb17a91c2bf922a`沿用原已审GitHub身份。实机独立测试包`com.elitesync.v2qdev`、version`10.1.18-dev /1011804`，安装包与手机`base.apk`由Codex报告同SHA256`db142f7b884589c62622dab8b3cc0e9672a67e33a094b62ffe0aa615ae1326d7`。ARM64 Flutter release AAR + debug宿主、独立包名和activity-ktx匹配；产品仓库源码未改，不能称正式发行APK。
- 实机服务由报告表明为**Windows PHP8.5.3/Laravel/独立SQLite/回环API+USB转发**；未证明当前某个Docker镜像/Compose容器与Q源码字节相同。云部署前必须核Docker实际有效镜像及依赖身份，不能将实机Laravel/SQLite通过视为Docker/MariaDB通过。
- 证据等级：`CODEX_REPORTED_DEVICE_RUN`（用户直接提供具名报告+证据hash）；`ADVISOR_SOURCE_SPOTCHECK`（GitHub固定`edit_profile_page.dart`、`ProfileController.php`、`NatalProfileController.php`与`NatalCalculationService.php`已直接查看）；`ADVISOR_DEVICE/PRIVATE_LOG_NOT_VERIFIED`（无手机/API原始日志文件与SQLite原件）。

## 两天全部已披露结果（旧失败保留，后继以新续测状态为准）

- 实机具名PASS：登录注册与欢迎、五题保存/改选/在线重启、首页频道/搜索/SELF阻断/Block、FRIENDS+FRIENDS_ONLY文字发布、评论与撤回、数据权利渠道不存在的正确拒绝、Buddy草稿/发现/Block、第一种“创建请求未到达服务端”同键查后重发、通知最小投影与失权、账号切换。
- 11月20日普通退出`PARTIAL/UNKNOWN`：11月21日按本机SQLite令牌与会话核对补证`PASS`。保留“先显示未确认、后确切读回”的实际时序，不将最初停点删除。
- 11月21日新增具名PASS：测试环境里C/D双方好友→连接→消息同意，手机读/回消息与服务端持久读回；Block后消息接口404与手机去除旧会话；合成私有封面手机渲染和Block后媒体字节404；测试MBTI三题/历史；动态星盘历史版本1读取`COMPUTED_UNVERIFIED`；本人昵称保存读回。仅两个虚构账号/指定隔离环境，没有WebSocket/双手机实时对话/真Push/真音视频。
- 必须保留FAIL①：**三盘本命HTTP仍失败**。未知时刻手机重复提交后`FAILED`；第二隔离环境已知时刻HTTP 2次503`natal_calculation_unavailable`，结果版本空。同一持久输入在CLI计算服务可返回三个模块，因此不是算法准确性PASS。GitHub `NatalProfileController::save`第73–79行将任意计算`Throwable`压成统一503；`NatalCalculationService`会调用Python/Node本地进程，包含身份/数据/超时/执行上下文门禁。精确HTTP失败原因仍UNKNOWN，不能凭现象宣布是哪一个环境变量或路径错误。
- 必须保留FAIL②：**编辑基本资料的保存说明失真**。`edit_profile_page.dart`本版两种构建文案称保存资料自动刷新星盘/八字或缺出生时刻默认午时；`ProfileController::saveBasic`当前明确只保存账号事实，`recomputed_at=null`且`astro_profile=null`，不自动跨用途联算。应同步修复全部相关文案/加载态，并正反Widget检查；未知时刻保持UNKNOWN。
- 保留P1：注册`trusted_login_at`/离线可信T0旧合同冲突尚需Owner具体选择；旧星盘兼容25条仍FAIL且策略A/B/C未选。真实匹配/身份、正式关系完整链、RTC/WebSocket/双手机、真实受理、相册上传、短视频、跨设备、辅助技术及MariaDB/PHP8.4均未运行或受控片段未覆盖。
- 工程Q原全量PHP**46 errors+122 failures**与真实运行不足仍保留；Android实机成功不倒改旧全量FAIL。

## 云端当前风险/历史线索

- 2026-09-24固定历史治理证据`EVIDENCE/AUTH-24-ALIYUN-BACKUP-RESOURCE-CHOICE-PACKET/packet.md`将Owner确认的上海云目标标为**轻量应用服务器**，而非被验证的ECS/RDS。当前实例的属主、规格、存储、有效URL、Docker引擎、DB、服务健康、host key与访问权必须重新证实；不能依历史IP盲SSH或通过ECS模板部署。
- 已有旧数据库备份的Owner事实必须先核查原件路径、密文hash、真实身份/版本、可恢复性及最新程度；不能以“曾备份几个管理员”为只包含几条账号，也不能拿旧库全量覆盖新V2库。历史管理员/身份与权限属于真实敏感数据，**LOCAL_ONLY**，仅可按Owner批准范围在隔离库做字段和归属映射，禁止源明文、token、密码/hash、邮件/手机号、SQL数据进入GitHub。
- 阿里云官方《[轻量服务器Docker部署](https://help.aliyun.com/zh/simple-application-server/use-cases/deploy-and-use-docker)》明确重置镜像会清除系统盘；《[轻量服务器防火墙](https://help.aliyun.com/zh/simple-application-server/user-guide/manage-the-firewall-of-a-server)》要求最小开端口。**绝不在存有旧业务与数据的实例上重置Docker应用镜像、覆盖/清理原服务/数据库/volume，或用`compose down -v`和`migrate:fresh`。** 新环境只可独立且受限的staging stack，网络与持久卷/库完全分离，不对公网暴露3306/Redis/管理面。
- 真正上云的两个高风险动作——①创建/替换云实例或部署真实服务 ②解密/恢复旧管理员数据——目前**均未获得具名完成证据或单独执行授权**。先做静态/有限本地预检，具名Owner选择目标/成本/账号与数据边界之后才进入受控写入。

## 顾问结论

**PHONE_ADVISOR_PARTIAL**，可以继续下一轮本地缺陷修复与阿里云staging readiness规划；本轮并未宣布APP总体PASS、生产就绪或重新打开真实身份与匹配。建议优先本命HTTP503诊断/修复与资料页文案，再做Docker镜像与PHP8.4/MariaDB的独立环境补证；旧管理员只做后续严格受控的独立数据恢复方案。
