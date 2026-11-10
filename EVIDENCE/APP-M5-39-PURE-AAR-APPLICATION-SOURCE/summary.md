# APP-M5-39-PURE-AAR-APPLICATION-SOURCE

SOURCE-ONLY CANDIDATE — PENDING INDEPENDENT WORK LEVEL 2 REVIEW。

日期：2026-09-30。执行会话：01a0f1ec-ff46-7311-a52f-780a64e3d4fb；Work：01a0f173-9add-7070-b57a-7660f75f5c40。
唯一仓库 D:\EliteSync-v10；main；HEAD cf8bfaa4a03b8c9a682105617b185141904413be。
本轮仅新增 task.md 精确允许的两份源码和本 summary；没有改写 authority、原 adapter/test、旧 harness 或旧证据，没有 Git mutation。

## 主要结果与限制

- apps/android_synthetic_demo/tools/aar_applied_materials.py：6510 bytes，SHA256 123A1164B1B0805AE28867CC0A80BB0C8085D091794A8EE78CDFE1E680CF0224。
- apps/android_synthetic_demo/tools/test_aar_applied_materials.py：72513 bytes，SHA256 29B2E8C28EEA9E11EB41591D8395FD3B96CB2CF75C7F456EC33BE6E763FB6F9F。
- 上述身份来自唯一 B 同次读取。B 成功后两源冻结，未修改、补读、重跑。
- A 1/1、B 1/1，均成功且关闭。路径不存在门在 A 前通过，写入采用 CreateNew；既有路径不会覆盖。
- Python 语法、AST、import/exec_module、compile、算法、fixture/scratch、smoke、checker、launcher、monitor、测试：全部 NOT_CHECKED，执行次数 0。不存在本轮 tests PASS 或运行正确性结论。
- 新源码文字有 13 个测试方法，B 只核方法头文本数量；13 是作者编写数量，并非测试运行发现或成功数量。M5-37 的 12 个旧测试不替代新应用层测试。

## 实现选择（待独立审查的源码设计）

准确 keyword-only apply_module_debug_materials(*, materials, config)。两新 frozen=True / slots=True dataclass：ModelProjectInstallation 与 AppliedModuleMaterials；整体返回四完整 fragment、两原非执行 Attachment、原 Invocation、四项目模型安装与 model_only=True。

先执行准确类型预检，再调用已接受 adapter 的 schema/内容验证。预检覆盖已提供的已知嵌套槽，使用 type(value) is expected_type；错误 tuple 长度、缺槽及域/顺序由 adapter 保持 CONTRACT 拒绝。源码记录此选择，不修改 adapter、不扩展其输入域。签名额外参数/位置参数的 TypeError 不强制消息 TYPE。

内部只调用已接受 adapt_module_debug_entry；不接受外部 operations、EntryMaterials、安装 root。源码按六步 order 0..5 在局部 scratch 中要求 before 非空且当前 count=1，hash 始终绑定原始 immutable input bytes，共享 init 锚按先插入后替换顺序处理；所有步骤成功才整体返回。plugin-deps 保持原 bytes。Attachment 和 Invocation 直接保持 adapter 返回对象。

四项目安装模型使用固定 root token B/module/.android 和字符串 child_components，output-dir 固定字面投影 B/module/.android/../../publication，保留两个 '..'；不调用 path API/I/O。Invocation logical output-dir token、recipe、runtime_ready=False 保留，与模型 OWN 表分开。以上描述源码意图，不是算法执行证明。

## Oracle 与未来准确加载

新测试中的 ORIGINALS、EXPECTED_CODE、EXPECTED_SCRATCH 是同次 A 内存文字转录。每个完整声明的选取文字在已接受 M5-38 plan 中核字面包含；未求值任何 Python 声明，未调用被测函数生成 expected，没有使用生产私有 _CODE。完整 config、P1/P2 预期返回对象由测试文字独立构造。没有额外读取 receipt、SDK 或来源。

仅在将来获得新 task 明确 import/运行授权后，测试拟按下列顺序：
1. spec_from_file_location('aar_entry_materials', r'D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_entry_materials.py')。
2. module_from_spec；先登记 sys.modules['aar_entry_materials']，再 spec.loader.exec_module。
3. spec_from_file_location('aar_applied_materials', r'D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_applied_materials.py')。
4. module_from_spec；先登记 sys.modules['aar_applied_materials']，再 loader.exec_module。新 module 正常 import 已准确登记的 adapter。
5. 显式 loadTestsFromModule(sys.modules[__name__])；testsRun > 0 且 wasSuccessful 才 exit 0。不 discovery、不改 sys.path、不依赖 -I 下脚本目录搜索。

该方案仅为待审文字，本轮以上每一步均未执行。Groovy/Kotlin literal 未作为宿主执行文件或 eval/exec 输入。

13 个方法的作者覆盖意图：P1/P2 完整对象；完整 bytes/plugin-deps；共享锚/helpers/完整外部字节；完整模型及 logical 分离；immutable/detached/deterministic；适配输出和材料变化拒绝；签名及外部包/root 拒绝；exact 类型和子类；类型先于 schema；config/mode/identity/path；project/task；ID/跨项目属性冲突；属性 schema/order/path token。未开放任意 op 注入。

## A 同次原回执

```text
A path=D:\EliteSync-v10\EVIDENCE\APP-M5-38-INMEMORY-AAR-APPLICATION-CONTRACT\plan.md bytes=137079 SHA256=7DB003A4620EEE403A310192DAE2C7BEEAAE5F88AE8D7A5B8CE6D962F8FC34BD ordinary_non_reparse=PASS strict_UTF8=PASS
A path=D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_entry_materials.py bytes=20338 SHA256=B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7 ordinary_non_reparse=PASS strict_UTF8=PASS
A path=D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_entry_materials.py bytes=74376 SHA256=F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2 ordinary_non_reparse=PASS strict_UTF8=PASS
A total_bytes=231793 limit=262144 identity=PASS
```

A 每份各一次 ReadAllBytes，普通非 reparse，每份 <=192 KiB，总 <=256 KiB。严格 UTF-8 与准确身份通过，输出仅身份/总量；无全文回显。随后仅普通标准库文字转录/组织与保存源码，没有 Python、AST、import、literal 求值或被测算法执行。A exit_code=0。

## B 同次原回执

```text
B path=D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_applied_materials.py bytes=6510 SHA256=123A1164B1B0805AE28867CC0A80BB0C8085D091794A8EE78CDFE1E680CF0224 ordinary_non_reparse=PASS strict_UTF8=PASS
B path=D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_applied_materials.py bytes=72513 SHA256=29B2E8C28EEA9E11EB41591D8395FD3B96CB2CF75C7F456EC33BE6E763FB6F9F ordinary_non_reparse=PASS strict_UTF8=PASS
B total_bytes=79023 limit=196608 fixed_production_slots=PASS fixed_test_slots=PASS literal_declaration_headers=PASS exact_load_text=PASS forbidden_selected_text=ABSENT authored_method_headers=13 checks=PASS Python_AST_import_compile_tests=NOT_CHECKED
```

B 两源各一次 ReadAllBytes，普通非 reparse，每份 <=160 KiB，总 <=192 KiB。仅 PowerShell/.NET 字符串槽与方法头检查，无 Python parser/AST 或任何源码执行。检查是列明的固定文本槽，不宣称全静态语义正确。B exit_code=0；B 成功后两源冻结。

## Git 成员保留

以接管 status-before.txt 加接管目录恢复的 183 条基线，加 M5-33～38 六个明确目录作为 189 条既有成员，与当前 porcelain normal 成员逐条比较。当前 190 条，仅新增本 task 的折叠目录成员；两源码在既有 android_synthetic_demo 折叠目录内。完整同次回执：

```text
STATUS baseline=183 preserved_expected=189 actual=190 missing_preserved=0 unexpected_difference=0
STATUS MEMBER_PRESERVATION=PASS; new_collapsed_member=M5-39; byte_integrity=NOT_CHECKED; Git_mutations=0
```

成员比对 exit_code=0，分支/HEAD 保持上述值。这仅证明 Git 状态成员保留，不宣称既有全文件字节完整性。没有 stage/commit/pull/push/reset/clean/stash。

## 停点

本轮候选交 Work 独立 LEVEL 2 ACCEPT/REJECT；不自接受，不发布后继，不执行任何新检查链。M5/隔离构建 NOT_READY，settings/v1 全拒绝、loader/runtime false、全部旧预算关闭，以及真实账号、Conversation、恢复、生产、UAC 具体授权门保持。无旧 D:\EliteSync、真实数据/备份/密钥/DB/API/SSH、SDK/cache/config/env/home/真实 metadata/properties、下载索引、Gradle/Flutter/JVM/ADB、构建安装启动或 UAC 动作。
