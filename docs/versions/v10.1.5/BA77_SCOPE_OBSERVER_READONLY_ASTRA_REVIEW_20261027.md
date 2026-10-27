# EliteSync v10.1.5｜ba77a3c8 scope/observer 只读根因交付｜Astra独立验收

日期：2026-10-27（Asia/Singapore）
裁决：**`BA77_BOUNDED_READONLY_ROOTCAUSE_REVIEW_ACCEPTED_WITH_OBSERVATIONS`**

本裁决仅接受**按任务交付的定点只读调查、静态机制论证、限制/假设保留与无运行预算消耗的报告**。不接受「当次G唯一根因已证」「发布图通过」「observer故障已解决」「AAR/POM/APP APK运行通过」或v10.1.5整版。

持续状态：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / GRAPH_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED / AAR_POM_RUNTIME_NOT_PROVEN / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / GATE2_NOT_AUTHORIZED / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。

## 一、Astra直接GitHub核验

- 本轮fresh main `82c19cf6a52618dff935263d296696afffec466e` / Root `693326ace9f9334024c331a560ac6eea30eec2c0`；main v10.1.4已接受 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 候选分支 `codex/v10.1.5-scope-observer-rootcause-readonly-20261027` HEAD固定 `ba77a3c840c36550a7ec3aa5a6475b69d874004f`。Git commit唯一Parent `fd0da9cce87c5eb84aec96dd11ea37aecd7aefff`；Root `8817729f4804d364e11c1ecb477e1e46a1cf9152`。Root递归Tree 6635项、`truncated=false`；apps `e6bff4bc8e359e6afe80c02f25212ee8b6195eab`、services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`，与候选Parent精确一致。
- GitHub compare `fd0...ba77` ahead=1/behind=0，仅追加 `SCOPE_OBSERVER_ROOT_CAUSE_READONLY_REPORT_20261027.md` 与 `SCOPE_OBSERVER_ROOT_CAUSE_EVIDENCE_INDEX_20261027.json`，没有候选产品源码变更或main产品集成。报告Blob `8c4947c5b4155ce495eae25b799b8c053a96ea94`，索引Blob `5817f409b6d5a3cb5fa5540306135a201d9e396c`，均已直接读取。
- 当前正式任务 `V10_1_5_SCOPE_OBSERVER_ROOT_CAUSE_READONLY_TASK_20261027.md` Blob `71d11e24c4d5b16d6d662f2684fc665750a7c154` 与索引 `taskBlob` 一致；其第0/6节授权本次**零Gradle/零产品修复**、只读判断并在交付后停止。
- Astra直接读GitHub tracked源码：`apps/android/scripts/owned_flutter_aar_init/aar_runtime.init.gradle` Blob `7654d90a8b2cc3fd31fafcb18fe589624486a3a2` 的首部guard确实检查 `gradle.startParameter.projectProperties['elitesyncOwnedAarInit']`；`apps/android/app/build.gradle.kts` Blob `92a2147843756f3ff2c9217250e04cdb2856b9cd` 确实在ordinary R1命令构造中加 `-PelitesyncOwnedAarInit=...`。
- Astra直接读 `apps/android/scripts/windows_build_observer.py` Blob `a6c4eebe690402a8e240c692d8670143c788af4d`：`image_path` 对 `OpenProcess` 或 `QueryFullProcessImageNameW` 失败返回`None`，未携带底层错误码；`sample`按已知PID父链构造选定进程并取映像路径。实际LOCAL_ONLY runner的抛错行号及原始输出仍由Codex报告支持，而非Astra直接重跑或读取本地私有runner。
- 公开索引为结构化脱敏记录，记载相关源码Hash/行、历史样本摘要、预算与43条LOCAL_ONLY证据。Hash存在不等于本轮Astra取得全部本地文件并亲自验证。相关Gradle 8.14 bundled source、actual argv、历史G原始进程日志仍需保持来源分层。

## 二、范围内实质判断

### Scope：静态机制论证可接受，G唯一根因未证

- G命令带且仅带一次scope `-P`，官方Gradle的StartParameter文档亦区分`newBuild()`与`newInstance()`；本轮Codex在本地8.14 bundled源码中细化出`newBuild()`复制环境/system args但不复制projectProperties，以及included plugin build继承initScripts的路径。这是**有来源的静态机制解释**，可以作为当前最强修复设计输入。
- 关键限制：Astra本轮未在本地打开8.14源Jar并核对其签名/运行class，历史G stderr未存被拒的Gradle对象、scope map实值或完整stacktrace。故只能接受 `STATIC_MECHANISM_SUPPORTED`，保留实际`H1 included build`为强假设；`H2 根argv/map异常`、`H3 其它附属上下文`均未被排除/证明。不能将`-P`参数在task之后作为已证错误，也不能直接把guard全局删掉。
- G配置阶段结束、0选中任务，不能把`DOKKA_TASK_SELECTED=NOT_PROVEN`改写为FALSE。

### Observer：源码异常链确认，出错实例不可还原

- 观察器对应路径合并`OpenProcess`、`QueryFullProcessImageNameW`失败与空字符串；无即时`GetLastError`、失败PID/实例创建时间，真实失败帧又在记录前中断。因此`PROCESS_INSTANCE_PATH_UNREADABLE`的底层API/实例/退出竞态/权限拒绝/PID复用保持`NOT_PROVEN`。
- 报告明确区分历史36个有效运行样本、1个根基线、累计PID别名组和未落盘失败帧；未推断具体conhost/java失败或实际发包。继续`observer fail-closed`，不得弱化非loopback TCP与未知/不可读进程强停。
- runner`Job kill-on-close`、A gate关闭、最终Job=0和未重试均为既有LOCAL_ONLY回执/Codex报告，不是本轮Astra亲自运行结果。

### 缓存与工具链

- 已见首要错误位于受控init guard；报告未给出具名缓存CRC/校验异常、依赖损坏或具体工具二进制API冲突证据。故`CACHE_CORRUPTION_NOT_PROVEN / TOOLCHAIN_VERSION_CONFLICT_NOT_PROVEN`合理。
- 不据此要求清理Gradle缓存、下载新Gradle、升级Flutter/JDK或卸载旧版本。Owner的条件性环境维护授权保留，但不转化成此候选可自动实施的动作。无具名跨项目依赖清单时亦不得清理旧版。

## 三、预算/保护与局限

- `OLD_APP_APK=EXHAUSTED_1_OF_1 / G=EXHAUSTED_1_OF_1 / A=NOT_RUN_GATE_CLOSED / GATE2=NOT_AUTHORIZED`。本调查报告声称新Gradle/JVM/Flutter/设备/观察器/网络实验、源码修复、下载、软件更新与卸载全部0；其LOCAL_ONLY过程不能由Astra直接证实，GitHub候选的**两文档差异直接核实**。
- Codex报告43项关键原件+14份G原证、五根与525 refs不变，旧partial SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`、旧claim `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、G claim `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`仍存。属于具名LOCAL_ONLY验收，不是本轮独立对全盘26784份和100453项的复算。
- 历史失败、AEC与最后可闻波形、native handle完整盘点、真实离线15/30天及物理30天清理、真实Push等全部继续开放。

## 四、裁决与建议

**`BA77_BOUNDED_READONLY_ROOTCAUSE_REVIEW_ACCEPTED_WITH_OBSERVATIONS`**：同意将报告作为下一步设计输入，严格保留`SCOPE_ACTUAL_ROOT_CAUSE_NOT_PROVEN`、`OBSERVER_FAILING_INSTANCE_NOT_PROVEN`。这是一份诚实、有用的有限根因调查，而非实际故障修复。

**建议的唯一最小后继（需Owner新的明确修复授权）：** 同一份有界`ZERO_GRADLE`综合源码/执行器加固任务：在项目自有owned init中精确限定允许的root与已固定Flutter tooling included build上下文，保持未知上下文fail-closed及来源/Hash/许可合同；仅在任务私有runner/observer副本加立即记录API阶段、错误码和失败实例的最小诊断字段，不允许失败后继续执行。允许静态与完全mock回归；运行G/A/APK、缓存重建、系统升级、Gate2及合main继续不授权。源码修复通过独立审阅后，再由Owner另批准**全新有账本**、受控图验证预算，不能复用已耗G或A剩余额度。

本Astra验收保存在独立文档审查分支；没有修改产品main、不合并候选、不启动构建、不自动下达修复任务。完成后STOP，等待Owner。
