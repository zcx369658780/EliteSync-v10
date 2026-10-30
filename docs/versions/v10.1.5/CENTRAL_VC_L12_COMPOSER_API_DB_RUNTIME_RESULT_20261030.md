# Central VC / Laravel12 Composer / API—DB 综合任务结果｜2026-10-30

**`CENTRAL_VC_NOT_QUALIFIED / OBSERVATION_BUDGET_EXHAUSTED / PHP_COMPOSER_DB_NOT_RUN / AWAITING_ASTRA_REVIEW`。**

具名中央文件**存在**：x64、单链接、资源版本**14.51.36247.0**，离线缓存签名信任返回成功。第二次检查器因签名显示名与精确预设不符而停止，且本轮取证代码没有固化完整发布者链字段。**这是本轮取证实现与证据的缺口，不是系统库缺失、签名无效、PHP加载失败或必须安装的证据。** 两次观察均已消费；未补读第三次，未执行VC安装器/repair或PHP，未生成Laravel12锁。

## 1. Authority与来源

- 唯一正式任务Blob `d048f7f8fee97a93f8bf8c52293f60762fff0bda`。开工fresh main `d499658e0104960ebf270dbffb57a02ae86c36ee` / Root `239193ba375666ba1a8c74aadea0e32dcffdcecb` / ACTIVE_STATE `a631c44ad40e4dcee8fec0a854ead556c526049e`。
- 唯一研发Parent `f16d4cda817282d935cb53ce399d26a7850381a1` / Root `eb4045b343749b7f3fceb46121100fa946b92329`，apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`，services `120177c9f35905190972be7bbcb3dfdda95ba776`。其唯一Parent为e93ef514。Astra正式独立验收Blob `34e2f0d6a80109188cc32fa85b34d0a2574c70c1`已直接读回，不用Astra分支做研发Parent。
- fresh工作流 `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、派发协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03`与上一固定内容一致。冻结AC01–11和原15场景保持；746份具名后端/E2E源码导入新工作面并逐件匹配Parent Git Blob。
- `DIRECT_GITHUB_OBJECT`仅指直接GitHub对象/源码身份；本机观察/纯测试为`CODEX_REPORTED_LOCAL_TEST`。Windows原路径、PID/创建时间、FileId/Volume、证书/映像原证、ledger等为`LOCAL_ONLY_RAW`。Astra尚未独立验收本候选，也没有亲自在Windows重演。

## 2. 两次具名中央观察，实际成功与不足

观察只针对Windows API `GetSystemDirectoryW`返回目录中的`vcruntime140.dll`和当前控制进程同名已加载模块；没有遍历System32、WinSxS、其它进程或私有项目。没有调用LoadLibrary主动加载待测VC，也没有改系统登记。

| 观察 | 真实范围与结果 | 进程exit / 资格状态 |
|---|---|---|
| 1/2 | API系统根/祖先拒绝reparse、直接句柄规范路径、单句柄SHA/FileId/Volume、链接数、x64 PE；当前Python控制进程定点模块路径 | exit0；文件存在，`CENTRAL_STATIC_FILE_PRESENT_ADDITIONAL_QUALIFICATION_REQUIRED` |
| 2/2 | 非写且不允许write/delete共享的只读句柄保护；身份/Hash复读、资源版本、普通/delay import、export名、cache-only WinVerifyTrust及签名者显示名、当前控制进程定点模块映射 | exit0诊断回执；资格拒绝`CENTRAL_SIGNATURE_PUBLISHER`，不是签名API失败 |

具名文件SHA256：`d1f4225df2cd877dbf130d5668a021dce3f94118455ff5ec952061c30afc9ce7`，178616 bytes、links=1、PE AMD64，资源版本14.51.36247.0。两次Hash一致，真实FileId/Volume和规范路径留LOCAL_ONLY。

第二次读取的签名显示名为 **Microsoft Windows Software Compatibility Publisher**，不是检查器精确预设的Microsoft Corporation。WinVerifyTrust使用cache-only URL retrieval/不作联网撤销取证，返回`0x00000000`。不能把显示名不同改写为“非Microsoft签名”，也不能仅凭这个名称和离线成功自动认定完整发布者资格。原检查器只有显示名，缺少固化的证书/发布者链验证字段；原窗口/失败与源均保留，不临时扩大白名单求PASS。

检查器分成两段，第一次未同步收齐签名字段，第二次在名称预设处拒绝，已耗尽2/2。这一执行安排和字段不足由本轮负责；不归咎Owner环境，也不靠重新开根退款。第二段保存了71个具名导出及PE导入元数据，但没有证明全部目标PHP导入符号/准确编译器最低版本或实际PHP ABI。

当前Python宿主已加载的同名私有runtime路径不等于中央候选路径。这只是当前控制进程事实，**不是未来PHP一定选择私有DLL的证明**，也不能作为PHP已加载中央库的证据。本轮无任何PHP子进程。

版本14.51较目标PHP历史PE linker14.44标记新，但链接器不等于精确compiler/toolset最低版本证明；此对比不能单独升级为ABI资格。正式任务已允许中央只读使用路线，因此没有继续要求app-local再分发许可；本轮核心阻断是中央发布者/加载资格证据未闭合和观察额度已用尽。

## 3. 源码范围与保护门

新增`central_runtime_preconditions.py`仅为**纯输入事实合同**：将`MICROSOFT_CENTRAL_V14_RUNTIME`与`WINDOWS_SYSTEM_IMAGE`、`TASK_PRIVATE_BINARY`区分；只接纳具名模块、API系统根、直接规范路径、只读/单链接、架构/卷/文件身份/Hash/版本、独立发布者链与最低兼容证据pin。字符串或合成true不是防伪来源证明。加载事实合同还绑定PID/创建代际/nonce。返回STATIC或INPUT_FACTS_MATCHED不授予执行、也不观察真实PHP。

`os_images.validate_os_fact`显式拒绝通用Windows OS路径将vcruntime140当作普通系统映像，必须走单独中央资格。原`php_runtime.os_import`未加入vcruntime；私有文件原hardlink/reparse门完全保留。**没有实现或声称中央VC真实加载分支、SUPPLY_ONLY_COMPOSER实际启动器/child/网络守卫已经通过**；S1未合格，S2/S3不能进入。

requirements绑定本轮实际中央摘要与f16 Parent，状态仍NOT_QUALIFIED/PENDING；示例Manifest同步政策Hash。Python/PHP关闭集合新增本次结束任务，旧集合原样保留，不能继承未用预算。历史供应合同的合成测试fixture固定为其原Parent，不把新policy Parent错用于旧合同正例；没有让旧任务获得真实运行资格或删除负断言。

F1消息幂等、CN/MC/Block、token撤销、F3 T0/密文、F4通知、原Feature/Widget、所有生产app/routes/config/migration和Flutter业务代码均未改。Composer声明仍Parent Blob `d30ee1bb2af2bafb0416fa07b6005d53d6ab4f56`；旧lock仍`66327f584d3961c2b53391bb012047dda9cc9d23`（Laravel11.48.0），未伪造新版本、content-hash或vendor。

## 4. 真实检查、预算与NOT_RUN

第一批纯检查148/148 exit0；新增通用OS必须拒绝中央runtime的负例后，最终批**149/149，failed0/errors0/skipped0，exit0**。最终输出SHA256 `8ae5504a370b712149dfc33ec722e8ee6b5fe9df5bd902e4b7b9a74d77c5f1e4`。本轮真实重跑Parent132用例并加入17个新用例，不把历史成绩移入本轮；两批累计297次执行不等于297个独立用例。完整原输出和两批收据LOCAL_ONLY保留。

覆盖中央/OS/private分类、hardlink/reparse/别名/写句柄拒绝、错误Hash/身份/版本、缺发布者链或最低兼容证据、旧进程代际、私有同名模块不得代替中央映像，以及默认inspect无运行副作用。Popen/socket/system/startfile/实际OS枚举使用拒绝替身；纯检查不提供系统隔离/中央签名或PHP加载的动态证明。

| 操作 | 本轮实际消耗 | 说明 |
|---|---:|---|
| 具名中央只读观察 | **2/2** | 两次控制Python进程，不是PHP；未做第三次 |
| PHP ZIP/VC包重复下载 | **0** | 未复制PHP ZIP/解包新PHP；未复制系统DLL或提取app-local |
| Composer PHAR/包下载 | **0** | 未进入供应阶段；GitHub authority/发布回读另属Git操作 |
| Composer求解/vendor安装 | **0/2、0/1** | 原lock保持PENDING，无Laravel12 vendor |
| PHP全部CLI/无DB Probe | **0/60、0/2** | PHP lint也未运行 |
| Laravel12 Feature | **0/3** | 新三项及业务Feature均未执行 |
| MariaDB/API启动 | **0/2、0/2** | 未连接历史或新库 |
| 业务HTTP/迁移/seed | **0/160、0/1、0/1** | 无实际业务状态码/DB计数/事务回执 |
| Flutter/G2/Gradle/JVM/APK/设备/RTC/Push | **0** | 未获本轮权限 |
| VC安装/repair/系统或私有DLL复制 | **0** | 无安装/系统改动授权 |

没有新Laravel12锁、PHP能力或API/DB运行证据，不签`SYNTHETIC_API_DB_PASS`、`SAME_SOURCE_APP_API_DB_E2E_PASS`或整版FUNCTION_ACCEPTED。原15场景全部保留为本轮NOT_RUN；没有视频206、物理15/30天、设备Keystore/删除、RTC/AEC/Push证据。AC01–11仍10 PARTIAL/1 OPEN，AC05 OPEN。

## 5. Owner系统安装选择：具体条件，当前不执行

**现有库已经与前轮官方包同为14.51.36247.0；本轮没有证据证明重装或repair能解决显示名/取证字段不足。** 优先由Astra独立审阅已封存的两次原证；若Owner另选系统安装/repair路线，需新合同集中明确下列项目，不能把本轮概括授权解释为已批准：

1. 指定仅现有官方x64 v14包14.51.36247.0，SHA256 `843068991daaa1f73ad9f6239bce4d0f6a07a51f18c37ea2a867e9beca71295c`。本轮只读核其前轮具名文件Hash仍一致；没有重新下载、执行或提取。来源为微软官方最新v14页面→`https://aka.ms/vc14/vc_redist.x64.exe`→前轮已冻结Microsoft发行URL；不静默换资产。
2. Owner须明确决定**安装还是repair**、是否允许UAC提权、全局运行库文件/安装登记改变、具体一次执行及超时/日志目录。不得因已装同版而自动改用repair。按项目既有规则，UAC还需Owner当时在场及具体授权；本轮不发起UAC。
3. 运行前保存目标全局VC版本/安装登记/具名文件和已有应用依赖的恢复资料，由Owner确定可用Windows恢复点/系统备份及维护窗口。系统共享库不可承诺简单可逆，不自动卸载、降级或删除其它应用依赖；需要恢复时再按明确Owner批准执行。
4. 明确不自动重启；成功需按真实退出码/源/版本重新核验；若提示3010或其它重启要求就停等Owner，任何失败不自动重试/repair/换包。安装后仍要新资格/观察预算、PHP/Composer/实例条件，不直接宣称兼容。

若Owner只补充独立认可的发布者链证据/资格规则，应明确这是**证据审查路线**而非已证明必须安装；同样不能沿用本轮已经耗尽的2/2观察或STOP后的运行余额。不自动派发此选择为下一任务。

## 6. 保护与交付STOP

唯一新task-owned根，task_id `V1015_CENTRAL_VC_L12_COMPOSER_API_DB_20261030`，attempt-0001，持久ledger；成本动作前PREPARE/flush，观察失败不退款。8GiB logical/native AllocationSize与120分钟单调窗口均受控，最终实测及ledger SHA在LOCAL_ONLY完成回执封存；Manifest记录交付快照并预留末尾元数据，不冒称连续峰值监测。

dirty状态、527 refs及前轮f16/e93/be7三个具名旧任务根身份、ledger/完成回执/预算Hash前后相同。没有清理旧根、SQL/SDK/Seed、历史原始失败/claims或ACL实验树；没有重新扫描旧18/122/五根/3183 Seed，不声称逐件重新核验。旧Flutter6/6、3bed3/3、MariaDB2/2、G/APK1/1及ACL超限事故永久保留。

维持`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / OS_ENFORCEMENT_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / V10.1.6_NOT_STARTED`。仅发布一个sole Parent=f16普通non-force候选；最终GitHub直接回读Commit/sole Parent/Root、每条变更原字节与完整双产品Tree、fresh main。最终固定身份封存在LOCAL_ONLY回执，避免报告自引用。main仍仅已接受v10.1.4。**交付后STOP，等待Astra独立验收。**

## 7. 变更身份

| 文件 | Parent Blob | 候选源Blob |
|---|---|---|
| `services/backend-laravel/tests/E2E/PhpRuntimeQualification.php` | `96df0787ad75fd53a6de91b5451ab9a44ea29c5f` | `5ad2dbe3677a5a75491f8f63685bec6c56030f05` |
| `tools/v1015/mainline_e2e/README.md` | `4db1ba6ecf956a6d77be856a4dad855e37e10dc9` | `b241f67f862fbf3d3b1e40d22e7b8400ee7478d6` |
| `tools/v1015/mainline_e2e/central_runtime_preconditions.py` | `NEW` | `f07d17c7f855eb971761c0e6b0dfc491c5760825` |
| `tools/v1015/mainline_e2e/os_images.py` | `119cd7365fd5218a2249d8aacdae639bb3dd144b` | `6d31c90d5911741bdb199533a60d3ff4fbde1210` |
| `tools/v1015/mainline_e2e/php_requirements.json` | `4816503c471963cb46e89ff0ed23afe252c9d62e` | `945de044f389ca18a56b1e273ba26f7950c6b5f7` |
| `tools/v1015/mainline_e2e/php_runtime.py` | `847c0d6e41a9e0120498e4c9ce2850d346d15622` | `29a038a4f2d5d116789075a78c0c0231cf8c27a9` |
| `tools/v1015/mainline_e2e/php_runtime_manifest.example.json` | `b33c9e76405e53e27253a29f1d740fab5b79e7fd` | `37c4240136a281ade4b7a3af97243f5cbb8c7810` |
| `tools/v1015/mainline_e2e/test_central_runtime_preconditions.py` | `NEW` | `e576df715655d6254d77e6959352a8734fe50d83` |
| `tools/v1015/mainline_e2e/test_supply_preconditions.py` | `db6af71ee54958d67e0e14f5eb6e43b6ace2a5f9` | `1ba91e48b4520af8a122c3a5a493e94291e4a659` |

## 官方依据与证据边界

本轮来源边界采用正式任务固定的官方依据及已回读Astra裁决；没有用新外网下载补充系统资格。微软公开部署/版本说明不是本机精确签名链或实际PHP ABI证明：

- https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist/
- https://learn.microsoft.com/en-us/cpp/windows/choosing-a-deployment-method
- https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files
- https://www.php.net/downloads.php?os=windows&version=8.5
- https://laravel.com/docs/12.x/upgrade
- https://laravel.com/docs/12.x/deployment
