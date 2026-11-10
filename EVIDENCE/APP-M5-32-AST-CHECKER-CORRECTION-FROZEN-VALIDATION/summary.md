# APP-M5-32｜AST检查器修正验证终止回执

2026-09-30；FROZEN SOURCE VALIDATION / STATIC FAIL / WORK LEVEL2 REVIEW PENDING。新静态进程一次启动、exit1，首个具名失败CHECK_FAILED:HOST_CALLS_TEST。两source字节/hash及AST解析、imports、生产宿主调用门已通过；测试宿主调用规则过宽，本轮不修复/补跑。测试NOT_CHECKED，M5/隔离构建NOT_READY。

唯一仓库D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；会话01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad。CURRENT/TASK_CURRENT/task与明确派发一致，182条入口dirty/untracked保留；唯一写本summary，两源/旧证据/authority完全未改。M5-31、M5-30及全部旧预算保持关闭。本轮不是旧预算恢复。

## 精确启动与当前源码身份

固定Python C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe，普通非reparse gate通过；两源准确路径普通非reparse/size门通过。ProcessStartInfo.ArgumentList逐项传-I、-B、-c及内存脚本文本，WorkingDirectory=D:\EliteSync-v10，CreateNoWindow=True；没有btoa、临时脚本、安装或未知全局。每source一次读入内存/hash，utf-8-sig解码及AST parse，不import/运行生产或测试。

| 冻结source | bytes | 同次最终SHA256 |
| --- | ---: | --- |
| apps/android_synthetic_demo/tools/aar_entry_materials.py | 20338 | B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7 |
| apps/android_synthetic_demo/tools/test_aar_entry_materials.py | 74376 | F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2 |

本轮新checker移除了全文discover/sys.path禁词，拟以AST Call/Attribute核执行节点，允许fixture Constant/注释；具名check在每个阶段打印PASS/FAIL。实际尚未到达NO_DISCOVERY_CALL_AST及后续准确路径、独立oracle、方法数等门，不能称这些门已PASS。

## 同次完整原回执与首个失败

工具chunk1487d2，命令工具exit1、墙钟0.3208154秒。硬60秒、异步双流逐块UTF8各≤32KiB主动累计；实际stdout642 bytes、stderr158 bytes，TIMEOUT=False、OUTPUT_LIMIT_EXCEEDED=False，子进程elapsed0.1292533秒、START_COUNT=1。回显完整无截断。

```text
STDOUT_BEGIN
CHECK FILE_GATE_aar_entry_materials.py PASS
FROZEN_SOURCE aar_entry_materials.py BYTES 20338 SHA256 B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7
CHECK HASH_aar_entry_materials.py PASS
CHECK AST_PARSE_aar_entry_materials.py PASS
CHECK FILE_GATE_test_aar_entry_materials.py PASS
FROZEN_SOURCE test_aar_entry_materials.py BYTES 74376 SHA256 F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2
CHECK HASH_test_aar_entry_materials.py PASS
CHECK AST_PARSE_test_aar_entry_materials.py PASS
CHECK IMPORTS_PRODUCTION PASS
CHECK IMPORTS_TEST PASS
CHECK HOST_CALLS_PRODUCTION PASS
CHECK HOST_CALLS_TEST FAIL
STDERR_BEGIN
Traceback (most recent call last):
  File "<string>", line 38, in <module>
  File "<string>", line 7, in check
RuntimeError: CHECK_FAILED:HOST_CALLS_TEST
MONITOR EXIT=1 ELAPSED_SECONDS=0.1292533 STDOUT_UTF8_BYTES=642 STDERR_UTF8_BYTES=158 TIMEOUT=False OUTPUT_LIMIT_EXCEEDED=False START_COUNT=1
```

checker对测试AST Call也采用包括run的通用Attribute禁用集合，未限定接收者或明确豁免已经授权的unittest.TextTestRunner(...).run(suite)。候选中该unittest runner调用是原任务指定测试机制，不能据通用run名称称真实宿主/进程副作用。此处记录检查器规则范围错误，不把它裁定为生产算法失败，也不自认候选已通过。没有失败后再读源码排查或修改checker/源补跑；精确节点与其余检查由Work结合同次脚本独立复核。

本轮没有继续执行旧全文禁词判断；但由于HOST_CALLS_TEST先失败，后续AST discovery/sys.path、keyword-only/frozen tuple、四fixture与完整expected hash、准确加载/register/loader/非零testsRun、12方法/P1/P2/三个scratch比较与负例静态覆盖均NOT_CHECKED。不以源码已有这些结构或旧局部结果补本轮PASS。

## 新预算关闭与未跑项

静态1/1耗尽，固定子进程1次、exit1；原条件“静态全部成功才测试”不满足。测试0/1未启动，因本任务首失败终止门关闭；实际testsRun/测试exit/stdout/stderr/elapsed/timeout/超量均UNKNOWN / NOT_CHECKED，不报0 tests PASS或12 tests PASS。不给旧预算或剩余测试自动转用授权，不修复/重跑/换检查实现。

无来源重准备/SDK或M5-27三旧来源回执读取，无生产算法、fixture/scratch测试、Kotlin/Groovy/Gradle/Flutter/JVM/ADB/编译/构建/安装/启动/UAC；无源码/旧summary/authority/旧证据写、目录搜索索引/下载复制、真实SDK/config/cache/env/home/properties/metadata/engine/plugin材料或旧D:\EliteSync/真实数据/备份密钥/生产DB/API/SSH访问，Git无commit/pull/push/reset/clean/stash。

候选及首失败回执停Work独立LEVEL2，不自接受/后继。真实AGP/Gradle/TaskAction/registrant/Api/POM/metadata输入/manifest/OS隔离仍UNKNOWN；M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false与账号/Conversation/恢复/UAC等全部保护门保持。
