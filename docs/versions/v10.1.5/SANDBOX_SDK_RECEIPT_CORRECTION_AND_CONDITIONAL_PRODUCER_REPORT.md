# v10.1.5 Sandbox SDK回执纠正与条件式Producer交付

2026-10-24，Asia/Shanghai。**SDK_RECEIPT_WRITER_NOT_PROVEN / SDK_NOT_RUN / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN**。

本轮仅到D0：LOCAL_ONLY writer纠正尝试未获可靠性证明，唯一合成fixture退出1，随后停止。新Sandbox、Flutter CLI、Debug producer与正式30配置解析均未运行。三份合成正例不能签整套fixture PASS，更不能签SDK READY。本报告记录失败候选及未过门禁，不声称序列化修复完成。

## Authority与产品身份

完整读取正式任务Blob `8ec8ad6c1d76de7bd295101ffebe5e3ea69e15aa`、最新Astra复审 `706ae77e7292ce104fcafc8ef0af18c72d0fb1f6`、ACTIVE_STATE `c8d1fcabef63fd417a4b2f5c5d83b80954af26af`、前报告/Manifest与具名原脚本、异常及时间原证。重复粘贴的派发视为同一任务和同一预算。

live main `e2d8b1fa18fb9524a9c92bcf87b59547a36c3a02`，Root `778ad830858a5dd1d2363cc09e5f68321228ccfa`。仍是v10.1.4已接受产品：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，完整map1116/776条与原GitHub原证逐path/mode/type/Blob匹配。

本次从唯一候选 `a219fbb45edd0c746dce92af2f6abf661091bab4` 建安全后继，Parent候选Root `e1e0c3a8f7996e3d07ac4ec8960e1287f39f10c5`、该候选sole Parent `dd9b4eb9df9101adf4c0d980135081fd902c656a`。研发完整apps `785822ca072943c5bfefa3ccc37ede01c2af5164`、services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`，完整map1133/791条匹配。固定产品source `1522466faf798b719ccff281de7584f043946437`及app Gradle Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`不变；没有用main覆盖候选。

## D0：一次纠正尝试与首阻断

只读核原driver SHA256 `88dc071afd721c9c7a4728b8f4102af4d6f839c015e633aa81416a0173742e76`、完整Write-Receipt/调用链和异常。原writer是值进入ConvertTo-Json Depth14后直接Set-Content；身份字段来自Get-Content三行。历史现场对象/扩展成员类型没有保存，不能把本轮重建对象冒充历史快照。**SPECIFIC_PS_CAST_MECHANISM_UNKNOWN**保持；不重新调查已通过的dubious ownership、GPU、HOST或Gradle DAG。

在本任务独立副本中提出受控primitive/ordered schema边界，字符串重新构造，白名单键、深度6、数组/字节上限；正常回执采用临时文件、UTF8 JSON/schema/Hash读回、同目录Move原子发布且拒绝覆盖。并准备boundary、seed复制、cache复制/身份、tools、Git身份、Flutter CLI开始/完成、SDK READY增量阶段。旧安全断言未删除，原完整ErrorRecord dump改为有限异常摘要。**这些只是本轮失败的候选实现，不是已验收writer。**

唯一PowerShell合成suite **1/1次，exit1**：

- 17:22:59.733本任务fixture父进程建立；6秒只约束旧writer重建的Wait-Job，不能约束Stop-Job/Receive-Job/Remove-Job及整套时长。17:24:39现场仍见父子进程和空stdout/stderr；无法从这一快照确定具体停顿调用点。
- 17:25:06留下identity、phase、Unicode三份**runId=fixture**正例JSON；host随后只读解析内容与身份/阶段值。均为合成回执，不是guest进度或真实HEAD读取。
- 至17:25:06.779退出回执为1，stderr首异常 **RECEIPT_TYPE_REJECTED，receipt_writer.ps1:27**。已建立空的saved dart-version.result回放目录，具体被拒类型/完整异常调用链未捕获，保持UNKNOWN；不能猜测DateTime、PSObject或旧异常机制。
- 无fixture-result.json、无负例完成证、无failure JSON。回放参数在进入Write-Receipt前调用Copy-ReceiptValue，所以无failure JSON本身不证明fallback已执行失败。原writer重建结果仅计划在末尾持久化，但suite未到末尾；本轮没有可据以认定旧PSInvalidCast已重现的保存回执。
- 非作者指出fallback临时写入后Move缺少所有回执应有的JSON/schema/Hash读回；完整SDK schema正例与嵌套actualFlutter字段覆盖也不足。原始候选保留，不再修正/重跑。

17:26:17对精确具名合成serializer子进程作收口身份核对时，该进程已不存在；**terminationRequests=0**，未发正常关闭或强制终止。fixture父进程随后只读查询亦未见。此事项与旧Sandbox guest安全退出完全不同；通用VM后台进程未归属、未操作，也未查HCS。

主代理停止放行与一次非作者有界审查一致：**D0_NOT_PROVEN / SANDBOX_NOT_AUTHORIZED_TO_START**。同一位GPT-6.1 Sol/high只读审阅最终diff、fixture失败原证与交付；审阅者没有运行fixture、SDK或构建，也不代替Astra最终验收。

## D1–D3：均未放行

| 门禁或运行 | 本轮真实结果 |
|---|---|
| 新Sandbox隔离、父子外联拒绝 | NOT_RUN，实例0/1 |
| 新guest精确信任与冻结framework HEAD | NOT_RUN；历史PASS保留 |
| Flutter CLI / SDK READY | 0次 / 未READY |
| Debug packJniLibs及compile依赖 | 0/1，未授权请求 |
| 本轮真实libs.jar / Hash、ZIP、CRC、JNI、ABI | 未生成 / NOT_RUN |
| resolvePinnedDebugInputs / Configuration.resolve() | 0/1 / 0调用 |
| 15模块×2配置 | BEGIN0 / OK0 / FAIL0 / NOT_RUN30 |
| 宿主APK、设备、RTC/SFU、DB/API、main集成 | NOT_RUN |

仅准备22条独立映射，历史输入只读、宿主可写限本任务；没有启动或在宿主重复制SDK。准备的环境字节沿用原50键原值，额外仅GIT_CONFIG_COUNT/KEY_0/VALUE_0三项；base50 canonical `78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`、runtime53 `6468110fb2cd275115774ae4813aa769415d2f3d14bcb297ab9d0867457a9723`分别核对。任意大小写ANDROID_PREFS_ROOT键不存在，ANDROID_USER_HOME批准归属不变。**本轮仅静态准备审计，不是实际新子进程环境PASS。**没有改global/system Git、共享.git、ACL/owner或全局环境。

严格resolver SHA256 `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`、artifact policy `bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`与producer init原字节保留。Flutter3.41.7、Dart3.11.5、Gradle8.14、JDK17.0.18.8、AGP8.11.1、KGP2.2.20未升级，本轮没有以历史版本命令代替新运行。

## 历史600秒截止与迟到异常

历史截止 **15:13:39.026 +08，600.111897秒**，当时无SDK READY/身份JSON/Flutter启动或guest终止回执。历史晚到异常另记 **15:18:08.1167661 +08，晚约269.09055秒**，PSInvalidCastException发生于framework-identity的Write-Receipt/ConvertTo-Json；历史Git唯一command信任与冻结HEAD `cc0734ac716fbb8b90f3f9db8020958b1553afa7`实际成功不被改写。

本轮没有新SDK600秒窗口，不能将历史迟到异常或本轮合成正例倒填旧截止PASS。历史转换机制、整段时延原因及Owner关闭提示窗口的因果仍未证。旧guest **OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS**保留；未见窗口/进程不等于独立证明所有guest安全关闭。

## D4：保护与交付

保护终检PASS：**21,704份去重具名原件全部字节/Hash不变**，覆盖继承具名保护清单、已准备只读来源及本轮读取的上轮目录；不是全盘/活DB审计。5历史root的HEAD、branch、index、dirty状态与旧warning保持。开工511条refs完整保持；相较上轮510引用的变化只有新增上轮交付branch及正常fetch的origin/main、符号origin/HEAD跟随docs main前进，历史对象未丢失。三份init一致，SQL/APK/备份/原失败/私密日志/SDK与未授权part保留。

24组相关环境与21组Git环境摘要在本轮17:25首次快照至终检保持；首次快照发生在fixture执行期间，不能称全D0开始前快照。静态审查与执行范围未见全局环境写入。宿主网络解析结构与回执内状态Hash相同，完整raw回执文件Hash不同；宿主相关Java/Dart进程0。没有下载、网络/服务修改、工具升级、未知进程结束或历史清理。

Git仅新增本报告和`sandbox_sdk_receipt_correction_and_conditional_producer_manifest.json`。分支 `codex/v10.1.5-sandbox-sdk-receipt-correction`，唯一Parent `a219fbb45edd0c746dce92af2f6abf661091bab4`；author/committer固定为`zcx369658780 <zcxvegeta@126.com>`。普通nonforce发布后核Commit/Parent/Root、两文档Blob与原UTF8字节、完整apps/services maps；提交后的精确身份和真实远端回读存在LOCAL_ONLY delivery-git-identity/final-readback回执及Owner交付，避免正文自引用或预先声称远端PASS。

证据分层：GitHub任务/复审/状态/产品对象为GITHUB_DIRECT；本次单一失败fixture和保护为CODEX_REPORTED_LOCAL_ONLY；非作者仅有界只读复核；历史迟到异常单列LATE_GUEST_EVIDENCE；本次未运行的Sandbox/SDK/Producer/30配置明确NOT_RUN。完整脚本、WSB、环境、进程标识、绝对SDK路径及原始异常仍LOCAL_ONLY，公开只含脱敏结果、计数和内容Hash。

**OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

普通发布与完整回读后立即停止，等待Astra独立验收；本轮失败fixture不重跑、不自动修复或启动后继任务。
