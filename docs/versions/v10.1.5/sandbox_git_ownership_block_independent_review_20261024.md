# EliteSync v10.1.5｜SDK Sandbox Git dubious ownership阻断｜Astra独立复审

日期：2026-10-24（Asia/Singapore）
裁决：**SDK_SANDBOX_NETWORK_AND_TOOLCHAIN_PREFLIGHT_SUPPORTED_WITH_OBSERVATIONS / GIT_OWNERSHIP_TRUST_BLOCKED / SDK_NOT_READY / PRODUCER_NOT_RUN / FORMAL_RESOLVE_NOT_RUN / NO_HOST_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**

## 1. GitHub不可变证据与权限范围

- Codex候选Commit `dd9b4eb9df9101adf4c0d980135081fd902c656a`，Root Tree `57ec12b1cc0aca1aebf4eb92da6c5f3a80f65243`，唯一Parent `7292a8c39cec2e0bbb611436686828263129614b`。GitHub Compare ahead1/behind0且仅两份新增docs：
  - `docs/versions/v10.1.5/OWNER_SANDBOX_SCOPED_SESSION_CLEANUP_AND_SDK_PRODUCER_REPORT.md` Blob `5394eecac87e07fa6a19c1f26ce65f567a5960c7`；
  - `docs/versions/v10.1.5/owner_sandbox_scoped_session_cleanup_and_sdk_producer_manifest.json` Blob `6f6c690be9bf99ebce2116dc083fa68e7ea09779`。
- 已读取两份GitHub固定文档。候选与Parent的 apps Tree均`785822ca072943c5bfefa3ccc37ede01c2af5164`，services Tree均`1e1e20bb3500bedb1a521e5f2ddeece915d09424`（须与GitHub完整Tree直接核对）；固定诊断源码`1522466faf798b719ccff281de7584f043946437`与build.gradle.kts Blob`bdb8e241d3e0defd1793c90b5f730c2facd7433d`本轮不变。
- 复审前live main `9e69b78aff49f1712a0184e65d82f2eab31e391f`，Root `e738c45e3b1eae8f9aedd0c3216b5b3924500714`；产品仍为独立接受的v10.1.4 apps`3468a3dd97da7accfda2539a0f8d8f68931a6110`、services`0cb1f9d19659291a462488b3686fd0a07a6698ac`。本轮更新main仅为review/docs，不等于v10.1.5已集成。
- 本任务前置Astra task Blob `ce270b0ffe1e95eb5f63a628eb9429fefd66c081`，前轮审查Blob `c9bcb7f019acfcba9a5f7c468323da2100d47dcd`。Git对象/公开回执为Astra GitHub直接核验；Windows实际Sandbox、真实工具、保护Hash为`CODEX_REPORTED_LOCAL_ONLY`，不能说Astra直接运行过Windows。

## 2. D0与D1已支持的有限正向结果

- Codex本轮生成可保存的独立原始进程快照，没有可确定属于旧探针的活动RemoteSession/guest；两条通用虚拟化后台记录缺CommandLine/路径，不归属旧任务、不终止。唯一辅助`hcsdiag list`仍返回`0x8037011B`，没有guest清单，**`OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS`继续保持**；关闭/强制终止均0次。Owner新授权只允许在资源不冲突的新独立实例上尝试一次，并不构成OLD_GUEST_CLOSED_PASS。
- Codex报告新Sandbox SDK映射实例 **1/1**，新实例内部 `Networking Disable`自身验证PASS：父及子进程对固定字面IPv4/v6目标TCP均`NetworkUnreachable(10051)`，无可用非loopback网络适配器或默认路由。这比前轮仅独立无凭据探针有进展；仍只适用于本次实际实例，而不是宿主全网/下次实例自动PASS。
- 在该实例内实际执行JDK17.0.18、Dart3.11.5、Gradle8.14版本命令exit0，不能将`gradle --version`自带Kotlin2.0.21冒认为应用Kotlin Gradle Plugin2.2.20变更。隔离guest私有复制约17898个输入并Hash匹配、历史来源只读，源保护回执来自Codex；这不是Flutter CLI通过或已正式30项解析。
- 真实首次阻断是guest中的`framework-head`调用Git返回exit128：`fatal: detected dubious ownership in repository`；guest仓库owner显示`SYSTEM`，运行者`WDAGUtilityAccount`。没有取得Git HEAD、没有执行Flutter CLI，不能推定HEAD错误、源码损坏或用户原本SDK的owner被修改；未运行stderr建议的`git config --global --add safe.directory`，也没有改ACL。
- 失败后producer0/1、真实libs.jar没有生成、`resolvePinnedDebugInputs`0/1及30项全部NOT_RUN；没有AAR/APK/设备/RTC/SFU/DB/API。旧guest最终身份仍UNKNOWN；当前Sandbox的正常shutdown为driver流程回执但缺独立guest退出确认，不能冒充历史收口已证明。
- 当前真实历史保护包括1189具名原件、20268复制/只读来源及509 old refs、五历史根，Codex报告未发现漂移；此处属于受限对象和Codex本地回执，不是全盘/活DB逐byte验收。

## 3. 下一门技术判断与安全合同

**当前是Git信任范围阻断，不是缺SDK/Gradle依赖。** Git官方`safe.directory`使明确指名的、故意共享而owner不同的Git仓库被当前执行用户信任；它会放宽对该指定仓库Git config/hooks的防护，所以**使用前必须核固定同源SDK仓库/.git字节与映射read-only来源可信、任务独占以及目录规范真实路径无重解析**。官方文档对`safe.directory`限定受保护配置；`GIT_CONFIG_COUNT/KEY_n/VALUE_n`提供仅当前Git子进程的runtime config，`git -c safe.directory=<确切仓库根>`则仅当前命令生效。引用：https://git-scm.com/docs/git-config ；具体当前本地Git版本、环境覆盖实际是否有效须下一任务验证，不能凭网页直接宣告PASS。

允许**下一份单一有界长任务**在Owner手动派发后：先只读证实可信的同版Flutter checkout、guest repo canonical路径及固定commit `cc0734ac716fbb8b90f3f9db8020958b1553afa7`；仅在任务私有Sandbox进程/后代Git子进程范围，为**这一个精确Flutter framework仓库路径**设置临时`safe.directory`受限例外。拒绝`*`或`<root>/*`通配、`--global`/`--system`、修改`.git/config`、ACL/chown、假owner、关掉Git安全检查或向其他仓库扩散。对照负例证实非允许仓库仍拒绝，精确路径不匹配不得放行；HEAD需实际与冻结SHA相符。若Git版本不支持该进程级方式，STOP上报，不允许退化为全局例外。

只有SDK git身份真正PASS，才有条件在新`Networking Disable` Sandbox内实际Flutter CLI版本/cache检查，然后既有真实Flutter Debug producer最多一次→真`libs.jar` Hash/ZIP/JNI/ABI确认→真实30配置依赖解析最多一次。任一级新阻断STOP；ICE的`targetPath=lib/main.dart`／`dartDefines=null`尚未证成诊断flags，继续`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`，所有产品RTC AC05硬门仍OPEN。

**正式裁决：`SDK_SANDBOX_NETWORK_AND_TOOLCHAIN_PREFLIGHT_SUPPORTED_WITH_OBSERVATIONS / GIT_OWNERSHIP_TRUST_BLOCKED`**；v10.1.5仍`PARTIAL_NOT_ACCEPTED`，不集成main、不R2、不启动v10.1.6。后继同样不得自动安装/更改Windows安全设施、联网下载、改变宿主或共享SDK、构建宿主APK或操作真实设备。
