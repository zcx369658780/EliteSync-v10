# EliteSync v10.1.5｜be7ebd1f 三项PHP原生阻断 Astra 独立验收｜2026-10-30

**正式裁决：`BE7EBD1F_BOUNDED_OS_READONLY_AND_DB_FREE_PROBE_SOURCE_ACCEPTED_WITH_OBSERVATIONS / REDISTRIBUTABLE_AND_ABI_NOT_QUALIFIED / PHP_PROBE_NOT_RUN / V10.1.5_PARTIAL_NOT_ACCEPTED`。**

本审查独立读取GitHub Commit、Root/产品Tree、15项变更、正式任务、实施报告/Manifest及相关源实现，另核对Microsoft关于Visual C++再分发许可和运行库版本的官方说明。没有亲自执行Windows本机观察、PHP、数据库、Flutter或任何设备操作。源码接受与动态功能接受分层，不能冒称3个问题均已解决。

## 1. 权威及GitHub证据

- 正式Owner任务：`docs/versions/v10.1.5/V10_1_5_PHP_NATIVE_HARDLINK_REDISTRIBUTABLE_AND_DB_FREE_PROBE_CONSOLIDATED_TASK_20261029.md` Blob `8b6bd9233a08a7f4d0986d6f592eb114dec63e04`，发布时main `1e00aa6229ef13f26eaec7594b24f8303afac8d2`，ACTIVE_STATE Blob `525e63fc3ef16998ed3349071080cd636e7f7043`。
- 当前候选 `be7ebd1faa0fd3cb45bd88bd24af15ea9e805631`；sole Parent `3bed366233a39472f8a9e905021788b8d29e12b3`；Root `db2725ee513816f430002265e19c0f96ec21325f`。compare报告仅ahead 1/behind 0，共15变更。
- apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d` 与Parent完全相同；services Tree `dd552af956733514977cdd4bc82207c062792a96`，变化仅非生产`tests/E2E`。15个manifest路径与GitHub变更列表完全一致；14个非自引用 final Blob已由GitHub固定路径独立读取，14/14匹配。自引用Manifest Blob `186a68e766106b0d2285ec801e6b24fb361029cd`。
- Codex正式报告 `docs/versions/v10.1.5/PHP_NATIVE_THREE_ISSUE_UNBLOCK_RESULT_20261029.md` Blob `02c2d6e82715915735e33f2b2316a684eaad9a4d`。main在独立审阅时仍`1e00aa6229ef13f26eaec7594b24f8303afac8d2`，产品只接受v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`；本审查分支不作为研发Parent。

## 2. 问题一：Hardlink拒绝真实定位与限定OS只读规则

Codex提供的本轮Windows LOCAL_ONLY观察报告：原`contracts.local`拒绝发生在实际加载的`ntdll.dll`，报告的link count=2、SHA256=`651ac9041af8e6b5ebd331d53163244c0a27d36d1433f0f15cac1f28c5f2e82c`；OS模块观察2/2，其中第二次观察31个已加载映像并对22个System32模块应用新只读资格规则通过。实际原路径、FileId、签名链、堆栈、完整观察原始数据是LOCAL_ONLY，Astra没有直接目视其Windows原字节，故此事实等级为`CODEX_REPORTED_LOCAL_TEST`，不是Astra自己重演OS观察。

源码中`tools/v1015/mainline_e2e/os_images.py`分出按`GetSystemDirectoryW`根、直接父目录、read-only handle、reparse/别名拒绝、canonical Path、source API、已固定Hash/文件身份/links/签名断言的受信OS加载映像资格；`php_native.py`只对指定系统父目录使用该规则，其它路径仍走`contracts.local`的原始strict hardlink/reparse保护。PID与持有的进程句柄/创建时间、待观察模块set和nonce/profile在源中有相应守卫。最终对句柄/PID和API路径set的后续修正只有纯源码测试支持，没有第三次原生观察。**有界源码接受**，并保留以下观察：pin中Windows签名验证状态是来源事实输入，Python验证器本身并不完成独立WinVerifyTrust；OS瞬时映像快照不证明进程整个生命周期隔离或后续加载均安全，不能扩大为通用系统文件放行。

## 3. 问题二：微软运行库仍不得验收或复制

Codex报告唯一已有候选是`vcruntime140.dll`、FileVersion/ProductVersion `14.38.33126.1`、x64、119192 bytes、SHA256 `4d292623516f65c80482081e62d5dadb759dc16e851de5db24c3cbb57b87db83`，证书签名Valid；可见17个由PHP参考PE所需具名导出，未见missing export。现有8个PHP参考文件链接器标记14.44。这些只是静态观察，不能证明完整MSVC最低构建工具版本、二进制ABI或真实扩展装载；不能仅凭linker字段直接断定该DLL一定不兼容，但`14.38`也不能自动提升为满足需求。

Microsoft官方 https://learn.microsoft.com/cpp/windows/redistributing-visual-cpp-files 规定Visual C++ Runtime individual binaries/Redist再分发受相关Visual Studio使用许可及许可条款约束，且官方 https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist 要求Redistributable至少与目标使用的MSVC构建工具版本同等新、架构一致。独立外部核对支持“不应从Microsoft签名或第三方安装副本自动推导再分发权/兼容性”的结论。合法发行资产→对应文件来源链、适用REDIST文件表/许可及Owner实际权利、PHP确切最低MSVC工具集版本目前仍欠证。**`REDISTRIBUTABLE_NOT_QUALIFIED / PHP_RUNTIME_COMPATIBILITY_NOT_PROVEN / COPY_NOT_RUN`**，此分项不接受成功结论。不得补做下载、安装、私有副本或替代全局DLL来制造合格。

## 4. 问题三：无DB Probe源码解耦有界接受，动态尚未执行

审阅`contracts.py`新增`validate_probe_authority`与`NO_DB_TASK`，固定本次Owner任务Blob及Parent/apps/services，限定grant action=`php_native_no_db_probe`、一次30秒、new_instance_qualified=false、DB/network操作0、无DB配置/业务数据。原`validate_authority`显式拒绝同一个无DB任务进入API/DB；`MainlineEnvironment::assertProbeContext`先核非DB来源、hash、task等，不提前需要datadir/schema/DB口令，`php_runtime_probe.php`仅通过该新路径及原能力/Native握手，没有Laravel/DB入口。原`MainlineEnvironment::assertContext`、connect、boot继续保留DB及实例授权/端口/DB actor/GRANT等守卫。新`php_probe_entry.py`inspect默认不执行，execute前要求任务ledger及一次性额度、合法可再分发来源证明、私有文件副本收据与OS policy映像证据。

本轮未实际复制候选运行库，因此`php_probe_entry.execute`没有执行，PHP真实探针0/1；不能把PHP3项-lint或纯合成测试称为模块加载成功。**`DB_FREE_PROBE_SOURCE_DECOUPLING_ACCEPTED_WITH_RUNTIME_GATES`**。额外边界：legal_source_receipt、grant及OS pin是可信操作员冻结的一致性证据，不是不可伪造的Owner数字签名或恶意输入安全沙箱；后续必须实测现场API/Native闭包。

## 5. 预算、证据等级和终态

- 本次Codex报告Python纯契约`96/96`、exit0，3份PHP`-n -l` syntax exit0，`CODEX_REPORTED_LOCAL_TEST`；独立GitHub核验这些源/记录存在，Astra未在Owner Windows重跑。准备阶段的编码错误/patch锚点/扫描失败据报告保留，无重试退款。
- Windows只读OS观察`2/2`耗尽；合法运行库复制`0/1`；真实无DB能力Probe`0/1`；其它MariaDB/API/Flutter/G2/APK/设备等`0`（且本轮没有授权）；45分钟窗口中报告观察已过1941.047秒，任务结束后未消费次数**不自动延续到新任务**。
- `DIRECT_GITHUB_OBJECT`仅承诺Commit/sole Parent/Root/双产品Tree/变更Blob和代码差异；`CODEX_REPORTED_LOCAL_TEST`记录本机观察、纯检查与退出；`LOCAL_ONLY_RAW`保护证书、原始绝对路径/PID/FileId、签名链、ledger及历史证据；`NOT_RUN_GATE_CLOSED`为动态PHP扩展加载、Laravel、MariaDB、API、E2E、Flutter新批次、APP/RTC/Push等。
- 历史旧Flutter6/6、3bed Flutter3/3、MariaDB2/2、G/APK1/1和所有历史ACL超额事故原证、旧18、两ACL树、122件、五根、527 refs、3183 Seed、claims/ledger/dirty根均继续封存，不以本次定点结果反向抹除`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`。

最终仍`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`。AC01–11仍10 PARTIAL/1 OPEN。

**下一门只需Owner统一决定可信PHP运行库合法来源与目标ABI，并冻结一次真正动态Probe及随后API/DB测试的条件式综合预算；不要重发Flutter、Hardlink或旧ACL微任务。当前STOP，不自动发新正式任务、不合产品main、不签整版FUNCTION_ACCEPTED。**
