# APP-M5-37｜冻结 AAR 材料单次人工 Test 原回执

2026-09-30；AUTHOR TEST PASS CANDIDATE / WORK LEVEL 2 REVIEW PENDING。唯一新 Test 链 1/1 已耗尽并关闭；实际 Ran 12 tests / OK，12项全部 ok；工具与子进程 exit 0，固定 Python 启动一次，无超时或输出超量。未重跑 Static，不自接受或派后继。

## 入口与执行范围

唯一 D:\EliteSync-v10；main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。执行会话 01a0f1ec-ff46-7311-a52f-780a64e3d4fb；实时 TASK_CURRENT 顶部 M5-37 ISSUED/assignee 与明确派发一致。先读完整 task 与 M5-36 work-review，沿用 elitesync-local-workflow。M5-35 ACCEPT/CLOSED SOURCE-ONLY 与 M5-36 ACCEPT/CLOSED STATIC VALIDATION ONLY 保持，所有旧预算关闭。

仅新增本 summary；原两 source、M5-35 harness、全部旧候选/summary/authority未修改。host 精确 C:\Program Files\PowerShell\7\pwsh.exe，login=false（无profile），cwd D:\EliteSync-v10。首个预检前同次打印 TEST_CHAIN_BUDGET=1/1。

同一链先核 launcher 普通非 reparse/8089 bytes，ReadAllBytes 一次确认 SHA256 7903EED058B00A5B4E8907DD83AE48100B54F95DB9F878BDA96E1DFB5538583E。门通过后仅调用固定 M5-35 launcher -Mode Test -CheckerSha256 D5D2E6FF3A7E053909E918B59DAB7EF38FED03F408A65E009C2A5A3FC549D32A。launcher固定 checker/production/test 文件与hash门通过才启动固定 Python，-I -B 仅准确 test_aar_entry_materials.py。checker 本轮仅身份核验，未执行 Static/额外 AST。

固定 test 在授权范围内精确加载唯一生产源、登记 sys.modules、exec_module，并由明确 loadTestsFromModule/唯一 TextTestRunner 运行 12 方法。人工 fixture、独立 expected 与内存 scratch 是此唯一运行对象；未生成真实材料包或执行 Kotlin/Groovy/Gradle 片段。

## 实际结果

工具 chunk 8ef9ee；exit 0；wall_time_seconds 0.3927272；无 session yield、重试或额外包装 runner。launcher Mode=Test、Failure=null、Exit=0、ChildExit=0、ElapsedSeconds=0.1657188、Timeout=false、OutputLimitExceeded=false、StartCount=1、StartAttemptCount=1、CleanupObservedExit=true。

stdout 0 raw bytes（空），stderr 1290 raw bytes，严格 UTF8 解码完整；unittest结果正常写stderr，不是错误。原回执 Ran 12 tests in 0.003s / OK，12项逐一 ok，没有 skips、失败或 error。此为实际测试数，区别于 M5-36 静态方法计数。

测试涉及 P1/P2 完整返回、完整 scratch、固定配置/路径、冻结/输入脱离/确定性、ID绑定、逻辑安装recipe、keyword-only、材料完整性/顺序/锚、项目/tasks、property schema与类型边界。mode_matrix_is_source_only 保持源码材料检查，不证明真实 Gradle mode 分支已执行。通过只支持已审纯内存域，不证明全面负例有效性、真实SDK/AGP/配置/安装/账号/Conversation/恢复或生产就绪。

## 同次完整原工具 stdout / JSON

下面原工具 stdout 完整保留，不重新运行或重生成。JSON完整包含所有要求字段、双流文本及 raw base64。工具元数据：chunk_id=8ef9ee、exit_code=0、wall_time_seconds=0.3927272；工具未返回 session_id；output 未截断。

```text
TEST_CHAIN_BUDGET=1/1
LAUNCHER_IDENTITY_PASS BYTES=8089 SHA256=7903EED058B00A5B4E8907DD83AE48100B54F95DB9F878BDA96E1DFB5538583E
{"Mode":"Test","Failure":null,"Exit":0,"ChildExit":0,"ElapsedSeconds":0.1657188,"Timeout":false,"OutputLimitExceeded":false,"StartCount":1,"StartAttemptCount":1,"CleanupObservedExit":true,"StdoutRawBytes":0,"StderrRawBytes":1290,"Stdout":"","Stderr":"test_complete_p1_p2 (__main__.EntryMaterialsTests.test_complete_p1_p2) ... ok\r\ntest_complete_scratch (__main__.EntryMaterialsTests.test_complete_scratch) ... ok\r\ntest_config_keys_fixed_values_and_paths (__main__.EntryMaterialsTests.test_config_keys_fixed_values_and_paths) ... ok\r\ntest_frozen_detached_deterministic (__main__.EntryMaterialsTests.test_frozen_detached_deterministic) ... ok\r\ntest_ids_and_bindings (__main__.EntryMaterialsTests.test_ids_and_bindings) ... ok\r\ntest_installation_logical_and_dynamic_id (__main__.EntryMaterialsTests.test_installation_logical_and_dynamic_id) ... ok\r\ntest_keyword_only (__main__.EntryMaterialsTests.test_keyword_only) ... ok\r\ntest_material_integrity_order_and_anchors (__main__.EntryMaterialsTests.test_material_integrity_order_and_anchors) ... ok\r\ntest_mode_matrix_is_source_only (__main__.EntryMaterialsTests.test_mode_matrix_is_source_only) ... ok\r\ntest_projects_and_tasks (__main__.EntryMaterialsTests.test_projects_and_tasks) ... ok\r\ntest_property_schema_scope_and_types (__main__.EntryMaterialsTests.test_property_schema_scope_and_types) ... ok\r\ntest_top_and_nested_types (__main__.EntryMaterialsTests.test_top_and_nested_types) ... ok\r\n\r\n----------------------------------------------------------------------\r\nRan 12 tests in 0.003s\r\n\r\nOK\r\n","StdoutCapturedBase64":"","StderrCapturedBase64":"dGVzdF9jb21wbGV0ZV9wMV9wMiAoX19tYWluX18uRW50cnlNYXRlcmlhbHNUZXN0cy50ZXN0X2NvbXBsZXRlX3AxX3AyKSAuLi4gb2sNCnRlc3RfY29tcGxldGVfc2NyYXRjaCAoX19tYWluX18uRW50cnlNYXRlcmlhbHNUZXN0cy50ZXN0X2NvbXBsZXRlX3NjcmF0Y2gpIC4uLiBvaw0KdGVzdF9jb25maWdfa2V5c19maXhlZF92YWx1ZXNfYW5kX3BhdGhzIChfX21haW5fXy5FbnRyeU1hdGVyaWFsc1Rlc3RzLnRlc3RfY29uZmlnX2tleXNfZml4ZWRfdmFsdWVzX2FuZF9wYXRocykgLi4uIG9rDQp0ZXN0X2Zyb3plbl9kZXRhY2hlZF9kZXRlcm1pbmlzdGljIChfX21haW5fXy5FbnRyeU1hdGVyaWFsc1Rlc3RzLnRlc3RfZnJvemVuX2RldGFjaGVkX2RldGVybWluaXN0aWMpIC4uLiBvaw0KdGVzdF9pZHNfYW5kX2JpbmRpbmdzIChfX21haW5fXy5FbnRyeU1hdGVyaWFsc1Rlc3RzLnRlc3RfaWRzX2FuZF9iaW5kaW5ncykgLi4uIG9rDQp0ZXN0X2luc3RhbGxhdGlvbl9sb2dpY2FsX2FuZF9keW5hbWljX2lkIChfX21haW5fXy5FbnRyeU1hdGVyaWFsc1Rlc3RzLnRlc3RfaW5zdGFsbGF0aW9uX2xvZ2ljYWxfYW5kX2R5bmFtaWNfaWQpIC4uLiBvaw0KdGVzdF9rZXl3b3JkX29ubHkgKF9fbWFpbl9fLkVudHJ5TWF0ZXJpYWxzVGVzdHMudGVzdF9rZXl3b3JkX29ubHkpIC4uLiBvaw0KdGVzdF9tYXRlcmlhbF9pbnRlZ3JpdHlfb3JkZXJfYW5kX2FuY2hvcnMgKF9fbWFpbl9fLkVudHJ5TWF0ZXJpYWxzVGVzdHMudGVzdF9tYXRlcmlhbF9pbnRlZ3JpdHlfb3JkZXJfYW5kX2FuY2hvcnMpIC4uLiBvaw0KdGVzdF9tb2RlX21hdHJpeF9pc19zb3VyY2Vfb25seSAoX19tYWluX18uRW50cnlNYXRlcmlhbHNUZXN0cy50ZXN0X21vZGVfbWF0cml4X2lzX3NvdXJjZV9vbmx5KSAuLi4gb2sNCnRlc3RfcHJvamVjdHNfYW5kX3Rhc2tzIChfX21haW5fXy5FbnRyeU1hdGVyaWFsc1Rlc3RzLnRlc3RfcHJvamVjdHNfYW5kX3Rhc2tzKSAuLi4gb2sNCnRlc3RfcHJvcGVydHlfc2NoZW1hX3Njb3BlX2FuZF90eXBlcyAoX19tYWluX18uRW50cnlNYXRlcmlhbHNUZXN0cy50ZXN0X3Byb3BlcnR5X3NjaGVtYV9zY29wZV9hbmRfdHlwZXMpIC4uLiBvaw0KdGVzdF90b3BfYW5kX25lc3RlZF90eXBlcyAoX19tYWluX18uRW50cnlNYXRlcmlhbHNUZXN0cy50ZXN0X3RvcF9hbmRfbmVzdGVkX3R5cGVzKSAuLi4gb2sNCg0KLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KUmFuIDEyIHRlc3RzIGluIDAuMDAzcw0KDQpPSw0K"}
```

## 原 unittest 文本（同次 JSON 的 stderr）

```text
test_complete_p1_p2 (__main__.EntryMaterialsTests.test_complete_p1_p2) ... ok
test_complete_scratch (__main__.EntryMaterialsTests.test_complete_scratch) ... ok
test_config_keys_fixed_values_and_paths (__main__.EntryMaterialsTests.test_config_keys_fixed_values_and_paths) ... ok
test_frozen_detached_deterministic (__main__.EntryMaterialsTests.test_frozen_detached_deterministic) ... ok
test_ids_and_bindings (__main__.EntryMaterialsTests.test_ids_and_bindings) ... ok
test_installation_logical_and_dynamic_id (__main__.EntryMaterialsTests.test_installation_logical_and_dynamic_id) ... ok
test_keyword_only (__main__.EntryMaterialsTests.test_keyword_only) ... ok
test_material_integrity_order_and_anchors (__main__.EntryMaterialsTests.test_material_integrity_order_and_anchors) ... ok
test_mode_matrix_is_source_only (__main__.EntryMaterialsTests.test_mode_matrix_is_source_only) ... ok
test_projects_and_tasks (__main__.EntryMaterialsTests.test_projects_and_tasks) ... ok
test_property_schema_scope_and_types (__main__.EntryMaterialsTests.test_property_schema_scope_and_types) ... ok
test_top_and_nested_types (__main__.EntryMaterialsTests.test_top_and_nested_types) ... ok

----------------------------------------------------------------------
Ran 12 tests in 0.003s

OK
```

## 预算、保留与停点

Test 新链 1/1 关闭，实际 Python 启动1；没有最早失败阻塞。Static/其它算法测试/monitor试跑/SDK/Gradle/Flutter/JVM/ADB/构建/安装启动预算与实际均0，不扩大或复用旧预算。

只读 Git status 对照保存的183条接管清单加 M5-33/34/35/36 四目录：187条既有成员缺项0；当前188条，唯一新增为 M5-37 证据目录（入口已因Work任务存在）。成员保持不证明全部既有内容的逐字节完整性。无 commit/pull/push/reset/clean/stash。

未访问旧 D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH、SDK/cache/config/env/home/真实metadata/properties；固定Python位置仅作为授权解释器。无目录索引/搜索/下载复制或UAC。

候选停 Work 独立 LEVEL 2 ACCEPT/REJECT，作者不自接受或自动启动后继。M5/隔离构建 NOT_READY、settings/v1 全拒绝、loader/runtime false；真实账号/Conversation/恢复/生产/UAC及全部保护门保持。人工测试通过不等于真实工程构建或部署。

