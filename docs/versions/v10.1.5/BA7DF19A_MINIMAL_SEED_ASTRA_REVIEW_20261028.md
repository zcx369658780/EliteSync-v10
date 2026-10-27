# EliteSync v10.1.5｜ba7df19a 最小依赖 Seed / SDK 写入决策｜Astra独立验收

日期：2026-10-28（Asia/Singapore）

**正式裁决：`BA7DF19A_BOUNDED_STATIC_DECISION_ACCEPTED_WITH_OBSERVATIONS`**  
**技术结果：`MINIMAL_SEED_CLOSURE_NOT_PROVEN / BLOCKED_DISK_OR_ISOLATION / G2_READY_FOR_POPEN=FALSE / RUNTIME_NOT_PROVEN`。**

本裁决接受**任务范围内的定向静态决策证据、保守模型及明确未证明的边界、容量备选方案、测试定义与正确保留的运行门禁**；不接受Gradle真正的最小Seed/variant/runtime闭包、OS真实只读隔离、G2运行许可、AAR/POM/APP构建或v10.1.5整版。

## 一、直接GitHub权威与对象核验

- 任务：`docs/versions/v10.1.5/V10_1_5_G2_MINIMAL_DEPENDENCY_SEED_AND_SDK_WRITE_BOUNDARY_TASK_20261027.md`，Blob `465eb13f8cb290bfab4061b03edf51629e90ca87`；前次Astra写隔离受阻交付裁决 `68FEEE04_BOUNDED_BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`，审查Blob `40a772e4a86f248b04b49bfb245d8f671e3ec751`。均已按路径读取。
- 本次 fresh main `599a44d99c928c8052a0a7edfb783e79fe63513c`、Root `3494eb3956c9529d1714c9b2c15bf982a9857b69`；已接受产品v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，直接Git Tree查验。
- Codex候选 `ba7df19accd3df22b8e06cdfd65a6466cf4ecc53`、唯一Parent `68feee0443991696385337c318348ead5306e1ef`、Root `8aa1345fcc5f2297169296339065abe604379539`；recursive tree 6662项、`truncated=false`；apps `5af7a9d0042be19437616e969e260658b67e9353` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`，与68fe未接受候选两产品Tree相同。
- GitHub compare `68fe→ba7` ahead=1, behind=0，**恰好新增四个安全文档/静态源码路径**，无产品源码变更：
  - `G2_MINIMAL_DEPENDENCY_SEED_DECISION_REPORT_20261027.md` Git Blob `b0912b629c0d0f9021788e6a5177c63720605d1f`，27083 bytes；
  - `G2_MINIMAL_DEPENDENCY_SEED_EVIDENCE_INDEX_20261027.json` Git Blob `b5f1825520e502995e431a571277f04cf4a824c0`，77246 bytes；
  - `g2_minimal_seed_static/seed_static.py` Git Blob `f0374f502f2f45e9f4d945fbbce8e6b1a1afd94d`，9952 bytes；
  - `g2_minimal_seed_static/test_seed_static.py` Git Blob `023bdd0ddf609f7ffe2f70516cebe66dc56e3871`，5823 bytes。
- Astra通过GitHub直接读取四个路径的内容/结构，并核对Root Tree的path/mode/Blob/size。未直接登录Codex本地Windows工作面、未读取完整LOCAL_ONLY分析输入/输出。

## 二、静态技术结论：为何仍不具备G2资格

1. **模型是声明可达拓扑，非Gradle resolver。** `seed_static.py` 可解析有限POM/XML、parent/BOM、部分模块元数据多variant声明和依赖路径，并将缺失/不确定条件显式出具issues。其`envelope`并没有实现Gradle最终版本冲突、attribute/capability matching、Maven effective model、profile激活、exclusion应用、缓存二进制metadata迁移或plugin classloader复用。代码与报告均明示这一局限；因此不能将5908条模型边、933个请求节点/715个有内容节点宣称为真实任务图或完整依赖闭包。
2. **多版本和UNKNOWN不等于真缺依赖。** 主要模型diagnostics包括variant 135、`COMPONENT_CONTENT_NOT_CACHED` 218、多版本winner 160、排除规则未应用207、parent/effective model未解145、BOM unresolved2等；不同类别可重叠，数字不能用作真实缺失依赖数。报告举出的4份外部plugin marker POM的字面关系是真实静态声明证据，但无法推出最终Gradle选中实现；Flutter loader通过includeBuild是可能的本地提供者，真实resolution仍未证。
3. **缓存内容与仓库索引严格分离。** Codex报告已定向fresh重Hash 3183份sealed `modules-2`，共1362106905 bytes；发现1013份POM、301份Gradle Module Metadata及metadata-2.107二进制索引。Astra直接读到相关报告/索引和解析器源码，但**未亲自Hash本地3183份文件或运行真实Gradle的repository identity/index迁移**。即使POM/JAR在目录中存在，也不能证明在新private home+readonly seed中离线命中。
4. **容量数字有用但不是最小闭包证明。** core-only约315205052 bytes，配置静态模型约880792638，添加可能action约951221175，整套sealed约1362106905。这些是**不同声明/现有内容集合**，并非全G2必须字节或严格运行上界。Codex诚实说明无条件必需字节下界暂为0（证明能力下界，不是实际需求为0），完整运行闭包上界UNKNOWN；因此无法批准≤512MiB闭合成功。
5. **2GiB选项是量化方案，尚未批准、也不保证够用。** 报告规划：1362106905旧sealed内容 + 8277854已知小骨架 + 536870912私有write reserve + 67108864计划余量 = 1974364535 bytes；对2GiB（2147483648）留173119113 bytes。数学关系正确，但私有写Reserve、文件分配/metadata余量及实际依赖/SDK额外写入**未证明为上界**。若另要两份新seed备份共存，报告规划峰值3336471440 bytes，超过2GiB。Owner并未授权扩容或复制。
6. **SDK/OS写面未关。** Flutter `forceNdkDownload`及CMake staging条件位置有静态定位；NDK/CMake/API/build-tools的本地source.properties只能证明声明存在，不能确保整套Android SDK无写入、不会调用manager或下载。Flutter/Dart bin/cache读取集、tooling included-build实际输出、14插件的额外build操作、profile/user-home/temp fallback及有权限的OS write barrier均有剩余UNKNOWN。只读ACL descriptor不等于有效token写权限已测试，更不等于解决TOCTOU、owner/WRITE_DAC、父目录rename/delete风险。
7. **准确的运行状态：** G2一直未运行，无真实selected tasks和文档任务结论；`DOKKA_TASK_SELECTED_NOT_PROVEN / GRAPH_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN`不能降级为FALSE或PASS。无证据支持缓存损坏、盲目删除缓存、Gradle/Flutter/JDK版本升级。

## 三、测试、空间、原证与证据层级

- GitHub可直接阅读的`test_seed_static.py`含marker缺失、parent/BOM/cycle、classifier、variant/constraints、rich versions、静态effective model不确定、重复module metadata、dynamic/profile、cache index、RO fallback、hash drift、路径重定向、大小上限/peak拒绝和永不运行G2等用例。Codex报告**25项定向fixture/mock exit0、0 failures/errors/skips，审计禁止事件0**；Astra**没有运行**本地测试。此前22项v1绿灯存在逻辑漏项，Codex报告保留原RED/审阅纠正和新25项回归，不把旧绿灯冒充最终同一结果。
- 新任务仅执行静态XML/JSON/POM/ZIP元数据解析与Python；报告还明确有一次`fsutil file layout`只读查询返回Access Denied(exit1)，未提权；继而通过任务拥有文件的`FILE_STANDARD_INFO`只读属性测量AllocatedSize。该调用属于本机文件元数据API读取，不应误称“完全没调用native API”；不等于真实Windows observer/Job或Gradle启动。
- 公开索引分别披露任务拥有的逻辑/allocated字节：intake后首次 snapshot 4671302/4706304，analysis 23004418/23141224，提交报告/索引前27290418/27443448；初始pre-outbox与final post-readback allocated值不在公开索引，报告称最终receipt留LOCAL_ONLY。Owner转述最终约35.9MB属于Codex本地回执范围，不是Astra独立远端验证的“完整物理磁盘增长”；卷free包含其他并发活动。
- Codex报告定向首尾84份受保护原证、五保护根、527 refs，314 Gradle输入+3183 cache输入及44来源/14锚点，旧下载partial 7941328 bytes SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`；旧APK claim SHA256 `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、旧G claim SHA256 `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`不变。此为`CODEX_REPORTED_LOCAL_EXECUTION/LOCAL_ONLY_RAW`；Astra未重算旧26784件历史保护项或完整100453库存。
- 旧APK/旧G各1/1耗尽，旧A被旧G失败门禁封闭。Codex最新报告`G2ReservedStarts=0 / G2Popen=0 / G2ClaimAbsent=true`，故**条件性G2预算按其本地回执仍0/1**；Astra没有直接读取本地claim账本。新任务没权限创建claim。Gate2、AAR/POM、APP/APK、设备、RTC、Push、DB/生产、真实G2和软件清理/下载均未获得新的执行放行。

## 四、决策建议与停止

**`BA7DF19A_BOUNDED_STATIC_DECISION_ACCEPTED_WITH_OBSERVATIONS`**：接受可核验的决策包与准确的阻断结论；不接受`MINIMAL_SEED_STATIC_CLOSURE_CANDIDATE`、`INVENTORY_RUNTIME_CLOSURE_VERIFIED`、`G2_READY_FOR_POPEN`或整版v10.1.5。

鉴于多轮受限静态调查已明确碰到Gradle实际resolver与Windows OS约束的可证明边界，**不建议继续发布同形态的细分静态调查**。若Owner决定推进，建议作一次**明确容量+独立OS读写隔离授权的决策**（例如待Owner批准的≤2GiB单一只读Seed snapshot及有限OS ACL/访问资格检验，仍零Gradle；必须带可回退路径、峰值空间及严格保护、可拒绝的未知写入）。但2GiB不是证明足够的值，未给实际缓存复制或Gradle启动许可；或者保留现状BLOCKED。任何涉及改变共享ACL/全局安全策略、提升权限或不可逆影响其它项目的动作，仍须Owner对具体对象单独授权。

**持续状态：`MINIMAL_SEED_CLOSURE_NOT_PROVEN / BLOCKED_DISK_OR_ISOLATION / G2_READY_FOR_POPEN=FALSE / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / GRAPH_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`**。AEC、最后可闻波形、native handle、真实15/30天elapsed与清理、真实Push等以前的未决事项也不关闭。

本Astra独立验收仅在审查文档分支归档并同步该分支状态；没有更改产品main或68fe/ba7候选、未执行Gradle、未用G2、未建立新claim、未发布后继任务、未扩大512MiB cap。**STOP等待Owner决定。**
