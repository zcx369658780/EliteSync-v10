# EliteSync v10.1.5｜离线隔离探针PASS／SDK实例启动前阻断｜Astra独立复审

日期：2026-10-24（Asia/Singapore）  
裁决：**ISOLATION_PROBE_DELIVERY_SUPPORTED_WITH_OBSERVATIONS / SDK_RUNTIME_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / FORMAL_RESOLVE_NOT_RUN / NO_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 1. GitHub固定对象与来源层次

- Codex候选Commit `29eced7453d876ca3d229341241b518e80b82635`，Root Tree `925fa111a5b81f25780b59137a9889b9d4097a82`，唯一Parent `c1a6cba30f7c18ad8d0f5252436a40ea760437d6`。GitHub单提交只新增两份docs，候选apps/services完整Tree和Parent分别均为 `785822ca072943c5bfefa3ccc37ede01c2af5164` / `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。本轮没有产品源码变化。
- 报告：`docs/versions/v10.1.5/FLUTTER_OFFLINE_EXECUTION_BOUNDARY_AND_PRODUCER_REPORT.md`，Blob `7ffae2f037509b827b734f4d0d6e213358f2048d`；Manifest：`flutter_offline_execution_boundary_and_producer_manifest.json`，Blob `6ec1483a4f4fdeb813ee90969547cba0bf3160d9`。Astra直接读取固定GitHub版本并比照Commit/Parent/Root与变更文件身份。本轮task Blob`f02853ee72d65ac36674f9fb8d6071a3d0bfbb0b`，前置Astra复审Blob`b34db972b2db6ea65bd196d0c93195acdde5b133`。
- 验收读取时main Commit `bda789155505fcdb071e6a359d930fe5abc6429e`，Root `8b3b78142340a87119eee6467ce1efda435713d7`；仍只有v10.1.4正式接受产品 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。纯文档归档可使main前进，不意味着v10.1.5产品已集成。
- `ASTRA_GITHUB_DIRECT`只适用于Git对象/公开原文；实际Windows Sandbox网络探针、SDK文件复制、关闭窗口/进程观察、保护Hash是**CODEX_REPORTED_LOCAL_ONLY**，Astra未独立运行、远程访问Desktop或Windows Guest。非作者本地审阅亦不是Astra亲自执行。

## 2. 验收范围与特别限制

- Codex报告已安装、微软签名的Windows Sandbox在用户上下文可用，无新安装/启用或管理员提权。任务独立`Networking Disable`无凭据探针：**1次，约87.15秒，exit0**；父进程和一个子进程向固定字面IPv4和IPv6目标的TCP端口443连接均报`NetworkUnreachable(10051)`，无active网卡、nonloopback连接或默认路由。属于该固定配置与该实例的**有界正向证据**，不是形式化的系统全协议证明、并不自动覆盖尚未启动的SDK映射实例。
- D1受控准备：报告复制约17907份输入、约1.63GB；SDK目标有3297个不同文件以及离线元数据，前轮同版真实`flutter_gpu`34文件和5份metadata继承。使用22条预定映射且既有SDK/tool/.git/Gradle/Android源设只读。**没有启动SDK实例**、没有完成来宾运行中的版本/SDK/cache/Flutter CLI验证。不能将静态身份/阶段复制记为`ISOLATED_SDK_RUNTIME_READY`。
- 探针Sandbox中的guest脚本请求关闭且launcher exit0；但归属RemoteSession UI/进程在一个由Codex发起的`CloseMainWindow`正常请求返回true后，`WaitForExit(10000)`仍为false，只读查询仍见同一实例。**未知它此后是否退出、也未知guest当时是否仍在运行**。不能把“UI仍存在”写作“guest必然运行”，更不能将返回true写作“退出成功”。未执行force kill/多次重试/系统改动，安全STOP合理。
- SDK映射实例启动0次；producer0/1；真实`resolvePinnedDebugInputs`0/1，30配置全部NOT_RUN；无本轮`libs.jar`、Flutter AAR、宿主APK/设备RTC。前轮真实DAG成功、隔离GPU包来源在本轮未重跑。实际DAG `targetPath=lib/main.dart`、`dartDefines=null`，`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`保持。
- Codex保护回执：990份重要具名原件无漂移；20,226个去重只读/复制来源核身份，47固定pins，507 old refs、5历史根未报告变化；属于具名范围，不等于全磁盘或运行中DB重验。用户交付说明的正常non-force发布/远端raw回读已与GitHub固定对象交叉核对。

## 3. 独立裁决及下一任务约束

**正式裁决：`ISOLATION_PROBE_DELIVERY_SUPPORTED_WITH_OBSERVATIONS / SDK_RUNTIME_PRECONDITION_BLOCKED`。** 认可在一个独立Sandbox实例内的离线探针证据及对未确认关闭状态的停止；不签`SDK_RUNTIME_READY`、`PRODUCER_ACCEPTED`、`30_CONFIG_PASS`、`APK`、`ICE_FLAGS`或`AC05`。

**建议只发布一份有界后继综合任务**：首先只读检查先前唯一探针实例与RemoteSession是否仍存在，区分UI残留、guest状态、进程实例归属；若自然退出且不存在旧guest/资源冲突，允许在新的任务隔离Stage里按既有映射启动一次SDK Sandbox实例，**该实例重新验证禁网边界**，然后按已接受DAG条件式一次Debug producer与条件式一次真正30配置解析。若仍留有上一实例，只在Owner手动派发的新任务中允许一次严格PID与任务归属匹配的**非强制、原生正常关闭请求**；关闭不能确认或guest状态不能确认就停，向Owner呈一项明确人工关闭/特别权限决策，**不自行kill、重启、安装、升级、切平台或改系统网络**。不要重跑已经通过的无凭据独立探针、重复复制无变动SDK、做全仓考古或自动提交产品main。

所有后继仍须Owner手动派发，无宿主APK、RTC/DB/SFU、外联/系统级变更许可。保留`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / V10.1.6_NOT_STARTED`。
