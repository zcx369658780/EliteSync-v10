# EliteSync v10.1.5｜5aa3fc63 Windows Flutter Widget/unit私有补丁运行器候选｜Astra独立验收

日期：2026-10-29（Asia/Singapore）。

**正式裁决：`5AA3FC63_BOUNDED_WIDGET_TEST_DELIVERY_ACCEPTED_UNDER_TASK_PRIVATE_PATCHED_RUNNER_WITH_OBSERVATIONS`。**

接受的内容是：**固定Git代码和测试装配修复**、经独立交叉核验的`11文件/77用例全部执行并PASS`这一**有源Codex本地回执**、Flutter单文件analyze的有源回执、原有权限负例/断言保留，以及不放宽原系统shell守卫的任务私有测试运行器方式。**此裁决不等于未经补丁的标准Flutter工具链、实际设备、端到端APP、整版v10.1.5或G2通过。** 维持`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED`。

## 1. GitHub权威与交付范围

- 正式Owner任务：`docs/versions/v10.1.5/V10_1_5_WINDOWS_HOOKS_RUNNER_PRIVATE_WIDGET_TEST_RECOVERY_AND_BOUNDED_CLIENT_REPAIR_TASK_20261029.md`，Blob **`02018a930428bb6417c9fcdd811a6c1350b03988`**。前一轮`TASK_NOT_PUBLISHED`已通过GitHub实际创建与`ACTIVE_STATE`读回消除。该任务只允许本轮私有Hook runner适配、6批Flutter测试/analyze、必要有界客户端源码/测试修复，禁止数据库/G2/Gradle/设备/旧ACL。
- Fresh `main`：Commit **`519672942e3697d8b3c7918d95619600feed658a`**、Root **`3b06491b8c1d95ba1be9dd5e2151a16d51fb816f`**、`ACTIVE_STATE` Blob **`b9d0c40b34e1895789e445d91fa7ea2bad6ace9f`**。正式接受产品仍v10.1.4，apps **`3468a3dd97da7accfda2539a0f8d8f68931a6110`**，services **`0cb1f9d19659291a462488b3686fd0a07a6698ac`**。
- Codex候选 Commit **`5aa3fc631dd7b450888c794182a1a8b35d57ec0a`**，唯一Parent **`15b23d8cacfa1429f6f77b8d57a86fff6b827673`**，Root **`2db8c8c509ffebb3b02169c23b99b34261f0424a`**。GitHub compare `15b→5aa`为ahead1/behind0，**仅3条变更**：一个Flutter通知测试文件，另两份报告/索引；无生产Flutter/Laravel鉴权源码、Gradle/SDK/vendor文件改动，无main产品集成。
- 候选完整apps Tree **`798049a15eb33fec16acdd37d83a07af0ed181b5`**（729 Blob），services Tree **`9bba2938aa41ad3eaee501ef88bfeecdee797591`**（716 Blob），递归Root Tree **`2db8c8c509ffebb3b02169c23b99b34261f0424a`**共6274项、`truncated=false`。services与前轮相同，apps只涉及具名测试文件。
- 交付报告：`docs/versions/v10.1.5/FLUTTER_WINDOWS_HOOK_SAFE_WIDGET_RECOVERY_REPORT_20261029.md` Git Blob **`f85cddc77ec32c60ffd4726e59bb1e4dc6de1530`**；证据索引：`docs/versions/v10.1.5/flutter_windows_hook_safe_widget_evidence_index_20261029.json` Git Blob **`657deb5e748a7d0d216b5b1c589ed3b86254734f`**。Astra直接从固定候选读回并成功解析索引；这些Git对象/内容是`DIRECT_GITHUB_OBJECT`，本地测试和OS身份属于`CODEX_REPORTED_LOCAL_TEST`，原本机完成回执、全量私有补丁与工具日志为`LOCAL_ONLY_RAW`。
- 具名测试文件 `apps/flutter_elitesync_module/test/features/notification/presentation/pages/notification_center_page_test.dart` Parent Blob `293d84df69b1e699991a67eeb2dc18d4b76c8787` → candidate Blob **`6ec6e0fd50982c4123141bffc888ff3141c8b953`**；已直接读取两版正文，对比`expect(...)`共**97处**，顺序与规范化文本逐项**97/97一致**；`testWidgets(...)`声明两版均**16处**，`skip:`均0。这是Astra直接源码核验，不只是复述Codex内部Sol/high审查。
  
## 2. Flutter运行结果与一致性检查

索引`tests.files`固定**11项**，`finalUniqueTests=77`，`caseResults`中**77个唯一的具名非hidden测试均为success且无skipped**；各文件`executed`合计77，0 failed、0 skipped。其F1（未知发送结果/旧WebSocket/切号）、F2（本地安全存储/离线只读/合成15/30日/登录退出竞态）、F3（通知当前鉴权/晚响应/隐私/导航）具名测试与任务要求相符。隐藏基础设施事件不计入通过数。

跨同一执行账本的六批`FLUTTER_BATCH`历史：
1. Widget：0用例，exit1（真实caller别名/启动错配，不是业务测试失败）；
2. Widget：77执行／57通过／20失败，exit1；
3. 定向通知：20执行／14通过／6失败，exit1；
4. 全集：77执行／77通过，exit0；
5. 修改文件analyze：exit0；
6. 最终全集：**77执行／77通过／0失败／0跳过，exit0**。最终运行operation **`2e75fac543dd4da397c18773873a0ef4`**，stdout SHA256 **`e847bb301a53674b65a4e386bfa7561822d4fee05dbf8c5383b3b02aa9fe0d49`**，stderr报告为空SHA256 **`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`**。索引60条执行Timeline中6条具名`FLUTTER_BATCH`均`ACTION_ENDED`且退出码与前述矩阵一致；失败全部保留、不退款。

**证据等级限制：** Astra通过GitHub复核的是原测试结果索引、Git代码及回执Hash字段的一致性，**未调用用户Windows原始Flutter runner、未重放完整测试输出的独立Hash、未直接读取本地completion-receipt**。可接受`CODEX_REPORTED_LOCAL_TEST / BOUNDED_ACCEPTANCE`，不可宣称`ASTRA_INDEPENDENT_WINDOWS_REEXECUTION_PASS`。

## 3. 私有Hook修复：限定接受，不称通用SDK修复

`hooks_runner-1.0.1`的最小差异只存在本轮task私有Pub副本。索引记录原源码SHA256 **`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d4d08c393dad9`**、最终 **`7d04fa44ccd94549ea2011997d3b1053ae6e72716e9b9fc0cc4d7c7e202244bc`**、私有diff SHA256 **`9d7f7883e34bbe451d364b89b03d4acab6c30d00d1f4d9081f562708b6e7f119`**，私有Flutter tools走源码入口而非旧预编译snapshot。任务报告称调用只准具名canonical私有`dart.exe`／绝对目录、固定compile/hook参数、`runInShell:false`，拒绝bat/cmd及越界程序/工作目录；19行为资格检查PASS，其中5次实际直接启动、10次负向Popen前拒绝。所需objective_c Hook仍编译和运行，未静默关闭必要Hook。
- 这个方法有源回执支持**目前固定代码、固定任务runner配置下的受控Widget测试**；源补丁未上传产品Git，Astra无法逐字节审阅补丁的真实OS启动逻辑，也不可以视为原版未修改`hooks_runner`已经支持无shell。
- 索引记录系统shell进程采样0次、私有Dart/engine进程出现，另有允许的OS conhost；**10ms采样不能排除所有瞬时进程**。预启动白名单与进程守卫是补充，但不是恶意Dart/config的通用安全沙箱。
- 若以后正常开发流程仍使用原先未补丁的全局Flutter SDK/Pub或旧snapshot，这个Windows Hook障碍可能再次出现。必须把可重复的任务私有runner方法规范化/经新Owner批准的上游/独立工具化后，才能声明常规Flutter开发环境已修复。

## 4. 测试装配修复与安全边界

唯一产品树变更是**测试代码**，不是生产通知鉴权逻辑：
- 新增`_SessionHarness`显式watch sessionProvider并在合成会话Provider完成之前隐藏子树，修复被mock notification list provider替换后session尚未初始化的实际测试装配缺口；
- 移除`_wrap`里的重复默认session override，保留调用方明确的合成登录fixture；对3个Router入口统一使用合成会话初始化装配；
- 97条`expect()`正文序列完全一致，16项testWidgets声明、原负向权限/撤权与错误断言保留，未加入skip。**上述确认仅证明测试断言未被显式删除，不自动保证所有测试fixture覆盖强度与真实服务权限一致**。依赖mock测试不能替代真实服务端授权或真实APP E2E。
- 生产客户端/后端权限策略没有被本次变更削弱；独立完整静态语义结论仅限唯一改动测试文件及已直接查阅的GitHub源码，不升级为对全部既有生产源再审。

## 5. 执行预算与历史事故

本任务`V1015_WINDOWS_HOOKS_WIDGET_RECOVERY_20261029`一棵私有工作根，历史6批Flutter启动**6/6已用尽**， SDK镜像1/1、Pub1/1、源码导入1/1；无额外下载、DB连接/API/服务Popen、ACL、restricted child、G2/Gradle/JVM/Android/APK/ADB/设备RTC/真实Push。前轮MariaDB **2/2耗尽**及API 1/2历史账本不变；API 1次剩余不构成此任务授权。新task最大已观测logical **3,912,048,419**、allocated **3,998,870,168** bytes，低于各8GiB，但非连续峰值证明。账本Hash **`161573a997ff297ab7a10e26f924151bd4bd29c2394b782063fdcb5f7f6191b7`**只是发布前checkpoint，最终completion receipt另存原Windows本地，Astra未直接核。
- 受保护旧SDK18,000文件与Pub23,816文件元数据尾检、4关键Hash以及上轮ledger/receipt固定Hash据Codex报告保持，**不是**原SDK/历史122原证/旧18/五根/527refs/3183 Seed的本轮全量重新hash/OS安全检查。
- Owner已封存的真实事故`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`继续不可退款、改写或删除；旧18件严格SD恢复、OS restricted身份、G2/Gradle依赖图、RTC AEC/native handle、真实Push、设备Keystore/物理15/30天与清理，全部独立`NOT_PROVEN/NOT_RUN`。

## 6. 最终裁决与下一门

**`5AA3FC63_BOUNDED_WIDGET_TEST_DELIVERY_ACCEPTED_UNDER_TASK_PRIVATE_PATCHED_RUNNER_WITH_OBSERVATIONS`**：接受唯一候选的Git身份、限定测试装配修复、完整且一致的11文件77用例通过回执、任务私有Hook适配受控测试结果，以及不重复启动数据库/Gradle/G2的安全停止。前轮已接受的MariaDB 23 Feature/152 assertions及Flutter analyze得以**继承为既有已接受证据**，而非本轮又执行一次。至此v10.1.5软件层三个方向获得有界真实服务端合成测试和有界客户端Widget Mock验证，但版本全功能仍**不是**`FUNCTION_ACCEPTED`。

**建议Owner下一步先决定**：是否将已验证的私有Hook方案沉淀为可复现且受安全门禁管理的开发测试入口，然后安排一次同版完整功能验收差距审查，明确何者可以用现有证据接近正式接受、何者需要真实APK/设备、物理存储与时长、G2/Gradle、RTC和Push；避免陷入无限临时runner或再次重复已通过的MariaDB/Widget测试。常规开发环境并未因此宣告全修复。该建议**不是**新权限，也不是自动派发后继任务。

**STOP等待Owner明确后继方向；不自动合main、不关闭AC05、不启动G2/Gradle/设备、不开v10.1.6、不清理历史原证。**
