# EliteSync v10.1.5｜9b74ca6f Linux Laravel13 / 合成API数据库独立验收｜2026-10-30

**Astra正式裁决：`9B74CA6F_LARAVEL13_LINUX_BACKEND_SYNTHETIC_API_DB_ACCEPTED_WITH_OBSERVATIONS / LARAVEL13_PRODUCT_BASELINE_OWNER_DECISION_PENDING / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_READY_FOR_POPEN_FALSE / PRODUCT_MAIN_NOT_INTEGRATED`。**

本次**有界接受**的是在已核GitHub源码候选上，Codex报告的隔离Linux PHP/Composer/Laravel13新锁/vendor、合成 HTTP→Laravel→MariaDB 权限/持久性回归，以及保留失败、预算和STOP的分级交付。**这不是整版 FUNCTION_ACCEPTED、APP设备E2E、真实Push、RTC/AEC、生产可用性或新框架长期基线的Owner最终决定。** 本审查使用GitHub原生Commit/Tree/Blob、源码及脱敏运行回执；Astra没有接触本机Docker、vendor/DB卷、ledger终态、私有cookie、原始日志或Windows服务，更没有重跑258项PHP测试。不得把`CODEX_REPORTED_LOCAL_TEST`写成Astra本机动态验证。

## 1. GitHub精确身份及来源

- 正式已发布且Owner手动派发的综合任务：`docs/versions/v10.1.5/V10_1_5_RUNNING_DOCKER_ENGINE_LARAVEL_BATCH_API_DB_CONTINUATION_TASK_20261030.md`，Blob `a1cbc75afe406e3e05712c6c51fb63c86bad928d`。原v10.1.5功能冻结计划`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；旧Windows和Docker STOP任务不重新开放。
- 研发候选Commit **`9b74ca6fef89e2507f966870c1f0d04f4fe09ba6`**，Git对象唯一Parent **`debe4a11d19f25179efef1d90d04e346980c2867`**，Root **`3b9690c1cdd6313d8f192c0ca4105352b8b40188`**；compare ahead 1、behind 0，38条变更。Parent Root `5cc585d5344e9a8e00b7512863e3169f662ad52b`。
- GitHub完整递归Tree：候选6411 entries、Parent6384 entries，`truncated=false`；Manifest的37项非自身payload路径、Git Blob、mode **37/37精确匹配**；加Manifest自身Blob `500e4c78f6876f048b138e0c223b6288b376e70e`为38/38；没有第39项变更，包含一项`100755`执行脚本和其余`100644`。源码与报告的固定Git对象可直接核实，报告不制造自身循环签名。
- Candidate apps Tree **`8cd9b6df8e744c8fc9d4217412edce31795a318d`**，和Parent一致；candidate services Tree **`9427d6deba3be2d44fce94122661a21668976e20`**。本审查不将两Tree合到main。审查前GitHub main仍 `e1916cd3f3513c5809b695c6e930a433e186e50a`、Root `6d7aac9e1922c5d906476923b91eb256aeb9a73d`，正式已集成产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 直接读取Result Blob `f7e83f4062f49def6e86cc4fc88a1026dbd1eb63`、Manifest `500e4c78f6876f048b138e0c223b6288b376e70e`、预算 `78547838b3d616b67751301585a398c360bfcf2e`、脱敏测试回执 `4df52a1294a3522f79e203f396b2984658c77864`、供应/工具链锁 `79e082c8bbc782691f2d50dc68a5a7e20dc4e711` 和依赖矩阵 `9ec73da64d1d07ec918f4e7fb4e8315978e11d5b`，并审阅生产消息源码、Feature差异、E2E router/fixture 与受控供应/容器/HTTP驱动。

## 2. 真实依赖锁与Laravel13迁移的限定支持

- 新`services/backend-laravel/composer.json` Blob `130793decf84ff8ab93faa0300117b7fab9d1826`，声明PHP`~8.4.0`、Laravel`^13.0`、Tinker3、PHPUnit12及现有Sanctum/Workerman/lunar-php；scripts/plugins被禁。新`composer.lock` Blob **`e236fbc960c1dd08c1fecb9aeed4926b4cab3933`** 不是旧Laravel11锁：直接解析得114个锁定包（81生产、33开发），其中`laravel/framework v13.39.0`、`laravel/tinker v3.0.2`、`phpunit/phpunit 12.5.42`，content-hash具名。静态锁与Codex真实Composer solver exit0、offline vendor install exit0、validate严格与check-platform-reqs exit0的脱敏回执相互吻合；vendor 9,161个文件/安装闭包为LOCAL_ONLY，Astra未直接重算vendor。
- Codex环境报告：本地Docker Desktop4.97.0.244584、CLI/Engine29.9.2、linux/amd64、PHP8.4.27、Composer2.11.0、MariaDB10.11.19；官方镜像摘要、layer/config和离线build锁表均有GitHub脱敏身份。**不等于Astra亲自核对本机签名、镜像raw或动态运行。** PHP官方容器用户态是Debian12，MariaDB镜像是Ubuntu22.04；不是运行Ubuntu24.04发行版证明。Desktop安装日志称本任务开始前自动更新/重新拉起，Codex明确称非本任务执行；未独立证明是谁授权更新，也不倒改原Docker Secrets Engine失败事实。
- Laravel13独立长期技术基线仍须Owner最终选择；此审查只承认候选在具名合成后端切片内取得动态PASS，不意味着生产PHP版本、生产依赖、线上会话或发布基线已经改变。

## 3. 受影响业务源码与测试语义

- 生产变更集中在`ConversationAtomicSendService.php`的一处分支：未知/停用peer返回404`message=chat unavailable`，与已有`authorizeSend`拒绝结果的消息形态一致，仍在pair row lock、token再取、CN/MC/Block授权之前fail-closed。未见本轮删除业务授权条件或把拒绝状态改200。旧消息指纹冲突/幂等路径保留。**响应内部code字段变化仍应按后续Flutter/客户端兼容合同复核**；本版没有APP测试授权。
- Feature改动主要为Laravel13/PHPUnit12的类名/attributes/测试夹具适配；`ConversationCapabilityFoundationTest`明确保留block之前有效读取、block之后`can_read/can_send/can_ws=false`、HTTP 404与历史行未删除；私有媒体匿名拒绝改为401、撤权后仍404；refresh由任意个人token改为真实DeviceSessions发放的refresh token，更符合F3约束。审查未发现为了通过测试而直接删掉关键授权负例，但源码目读不是全APP实际权限证明。
- 新`RunningDockerEnvironment.php` test-only bootstrap显式检查任务/源码Hash/有效期、Linux PHP/DB变量、实例、MariaDB hostname/port/schema/授权、session格式和私有媒体根；单独router调用Laravel `handleRequest`，未见返回固定mock成功包。新的Python HTTP客户端将预算计费的请求通过任务文件队列交给受控API容器，容器内PHP curl真正访问`127.0.0.1:8081`，无主机端口转发。驱动检查正向消息、同key replay、异payload409、旧access/refresh拒绝、Block/CN/MC撤权后404、图片字节及私密缓存、通知偏好、管理员CSRF、logout以及容器重启后相同业务事实。**这支持一个受控测试专用真实后端HTTP/API/DB闭环，不是普通用户APP到公网服务E2E**。
- session序列化`php`已由前轮静态预包保留；本轮合成PHP序列化夹具、cookie管理及受控重启下login/拒绝正负例有Codex动态回执，但**没有用旧Laravel11真正产生的二进制Cookie/原旧存储会话验证跨框架升级**。不可把`SYNTHETIC_LEGACY`改称`REAL_LARAVEL11_SESSION_COMPATIBILITY_PROVEN`。

## 4. 实际回执及保留原始失败

- 脱敏测试回执中最终第四批`258 tests / 3071 assertions / exit0`；先前三批分别exit255、exit2、exit1，失败原因及修复记录没有删除；PHP源码解析581个文件及受影响13个PHP lint exit0。供应/账本纯检查14/14属于Codex本机执行。测试数与断言数不是功能接受率，也没有Astra当场执行。
- MariaDB实际合成空库执行75迁移、5组虚构pair与虚构管理员；HTTP总计100次尝试、99实际响应、1次连接失败记账，最终具名安全及持久正负例通过。4条消息、4附件、4通知及迁移记录在同一自有数据库卷的受控API/DB容器重启后保持一致，容器StartedAt确有变化；身份、媒体与同key结果复核通过。任务的DB重启不等于Docker Desktop/WSL宿主重启，更不意味着真实生产数据已恢复。
- 初始服务组compress配置错误、Feature discovery fatal/后续失败、初次migration授权条件拒绝、seed超时回滚、HTTP宿主转发错误、媒体disk输入不合格、admin表单参数缺失，以及Windows主机读取solver回执的GBK/UTF8问题均在脱敏报告保留。Owner另外明确**一项早期只读检查回执缺口**，其对象/原始字节未见Astra直接独立核实，应永久保留`EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED`，不得补造exit0；当前结果只有最终运行闭环的有界接受，不追溯让这项缺口PASS。
- 任务动态结束预算快照（非最终封存峰值）：供应336,590,677 bytes/317请求/4镜像Digest；build1、solver1、vendor1、服务组4/4、PHP CLI79/120、Feature4/5、HTTP100/240、migration2/2、seed2/2；用时7156.859秒约119.28分钟；logical10,361,638,395/allocated10,386,729,472 bytes，低于16GiB。Owner报告最终封存共约147分钟。**最终`budget-terminal.json`、`completion-receipt.json`、完整ledger及本地保护Hash仅LOCAL_ONLY，Astra未直接重算最终峰值/时限；“全预算内”在此为Codex/Owner报告且公开快照一致，不是Astra本机独立签收。** STOP后即使尚有单项剩余额度也不可恢复。
- Codex报告所有任务专属API/DB/worker/supply容器停止，原dirty252、index、527 refs及9具名保护根身份/回执保持一致；本轮没有旧18/两ACL/122原证/3183 Seed全量重新逐件核对。保护状态为LOCAL_ONLY报告，禁止由GitHub推断全机原件已逐字复验。

## 5. 明确未通过的门禁与安全界限

- **本裁决不等于`V10.1.5_FUNCTION_ACCEPTED`、`PRODUCT_MAIN_INTEGRATED`、`G2_READY_FOR_POPEN`或`AC05_CLOSED`。** v10.1.5原11项AC仍保持`10 PARTIAL / 1 OPEN`，AC05 RTC/AEC仍OPEN，真实Push Provider待接入；v10.1.6 NOT_STARTED。
- Android/Flutter、Gradle/G2、APK/ADB、真机音视频/AEC与人耳声质、H264 video206实际测试、真实Push/通知GUI、经过真实15/30天/物理清理都NOT_RUN。后端合成媒体图片不能填这些设备/运营门禁。
- 旧Laravel11生成的真实cookie、老会话实际迁移/保留未证明；Windows Native PHP/API-set E_NOTIMPL和OS_ENFORCEMENT_NOT_PROVEN原结论不被Linux运行替代。四个固定历史事故状态、旧数据保护、原失败和所有旧STOP预算继续永久保留。未授予生产部署/更新、外部费用、客户数据、真实供应商或自动合并main权限。

## 6. 接受出口及单一下一决策

**有界接受：`LARAVEL13_LINUX_BACKEND_SYNTHETIC_API_DB_CANDIDATE_ACCEPTED_WITH_OBSERVATIONS`**，理由是固定Git Commit与38变更已复核、真实新锁存在、关键授权代码与测试差异有源码依据，且Codex脱敏运行回执展示实际PHP/Laravel13/HTTP/MariaDB持久性闭环并保留失败/受限范围。该接受仅允许作为后续Owner产品技术基线讨论和未来有界代码集成输入；**没有宣布Laravel13为正式长期基线，亦没有签整版v10.1.5功能接受**。接受后的源码main集成与本地连续基线接续须遵循现有独立授权、安全集成/再次Astra验收过程。

**唯一Owner下一决定：** 是否选择已通过此有界后端合成验收的`Laravel13 + PHP8.4`作为后续开发主技术基线（或要求先有界补充真实旧Laravel11 session/设备相关证据）；如批准选定与集成，Astra再按现有任务发布闭环制定**一次**精确产品集成/相关安全验证综合任务，不退回逐DLL微任务，不自动开始v10.1.6。未经Owner决定保持该候选与接受记录在审阅分支，不修改main产品Tree。

审查性质：Astra `DIRECT_GITHUB_OBJECT / SOURCE_REVIEW` + Codex `CODEX_REPORTED_LOCAL_TEST`；不存在Astra本机Composer/PHP/DB再运行。本Astra审查分支以研发候选为Parent，永远不作为下次研发唯一Parent。
