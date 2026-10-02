# APP-M5-60 frozen document-data checker receipt

Status: CANDIDATE — pending Work independent LEVEL2.
Observed checker data validation: PASS; transport fields explicitly unavailable below.
Main: cf8bfaa4a03b8c9a682105617b185141904413be.
Only this summary was created; no code or prior evidence changed.

## Exact invocation and budgets
Preflight1/1 closed; CheckerInvocation1/1 consumed closed.
Called exactly once, without arguments:
& 'D:\EliteSync-v10\EVIDENCE\APP-M5-59-EXACT-SCHEMA-CRLF-CHECKER-REPAIR\Check-CrlfContract.ps1'
workdir D:\EliteSync-v10; login=false; tty=false; plain pipes;
yield_time_ms=10000; max_output_tokens=3000. No polling, second call, parser,
version/environment checks, launcher or repair.
At save B0/1; final B original receipt only supplied in reply.

JSON Execution0 is reported verbatim and describes transform/test execution;
it does NOT mean checker execution0. Actual checker invocation is1.
Tool wall was 0.3681057s, returned finished exit0, no running session.
This is an observation window, NOT a proved hard timeout.

## Original complete preflight tool receipt
The output string retains the original JSON and final CRLF.
```json
{
  "chunk_id": "fa690e",
  "wall_time_seconds": 0.2300182,
  "exit_code": 0,
  "original_token_count": 197,
  "output": "{\"Phase\":\"PREFLIGHT\",\"Result\":\"PASS\",\"Files\":[{\"Path\":\"EVIDENCE/APP-M5-59-EXACT-SCHEMA-CRLF-CHECKER-REPAIR/Check-CrlfContract.ps1\",\"Bytes\":18068,\"SHA256\":\"432FBC9201E6AD08AB4CB137FEDAB1F4414D9286C3C8B1BB8C8BBDD949C72B2B\"},{\"Path\":\"EVIDENCE/APP-M5-55-LOCAL-CRLF-MATERIALS-CONTRACT/crlf-contract.md\",\"Bytes\":14300,\"SHA256\":\"214F7D4232DE8A8A71CF71353968466ECFD2E55B74D85792A7026BD8B3E2A051\"},{\"Path\":\"EVIDENCE/APP-M5-54-RAW-ANCHOR-SCOPE-MAP/anchor-map.md\",\"Bytes\":5879,\"SHA256\":\"CC1DA4B0484DC29E5BA2DE0DC4765337629394D327D8775869883533E9CE4774\"},{\"Path\":\"EVIDENCE/APP-M5-49-SCOPED-KOTLIN-PATCH-MATERIALS/patch-materials.md\",\"Bytes\":13818,\"SHA256\":\"B783379A7FC307B8750F73758261BEBCF739CDFA72A234B80148D96F4AD9DA49\"}],\"IdentityReads\":4,\"CheckerInvocation\":0,\"PreflightBudget\":\"1/1 closed\"}\r\n"
}
```

## Original complete checker tool receipt
The output string retains every original check, field, value and final CRLF.
No bytes/fields are reconstructed or filled in.
```json
{
  "chunk_id": "e668a1",
  "wall_time_seconds": 0.3681057,
  "exit_code": 0,
  "original_token_count": 760,
  "output": "{\"Phase\":\"A\",\"Result\":\"PASS\",\"Sources\":[{\"Path\":\"EVIDENCE/APP-M5-55-LOCAL-CRLF-MATERIALS-CONTRACT/crlf-contract.md\",\"Bytes\":14300,\"SHA256\":\"214F7D4232DE8A8A71CF71353968466ECFD2E55B74D85792A7026BD8B3E2A051\"},{\"Path\":\"EVIDENCE/APP-M5-54-RAW-ANCHOR-SCOPE-MAP/anchor-map.md\",\"Bytes\":5879,\"SHA256\":\"CC1DA4B0484DC29E5BA2DE0DC4765337629394D327D8775869883533E9CE4774\"},{\"Path\":\"EVIDENCE/APP-M5-49-SCOPED-KOTLIN-PATCH-MATERIALS/patch-materials.md\",\"Bytes\":13818,\"SHA256\":\"B783379A7FC307B8750F73758261BEBCF739CDFA72A234B80148D96F4AD9DA49\"}],\"Checks\":[{\"Name\":\"NO_ARGUMENTS\",\"Result\":\"PASS\"},{\"Name\":\"SOURCE1_IDENTITY\",\"Result\":\"PASS\"},{\"Name\":\"SOURCE2_IDENTITY\",\"Result\":\"PASS\"},{\"Name\":\"SOURCE3_IDENTITY\",\"Result\":\"PASS\"},{\"Name\":\"ROOT_PHASE_RESULT\",\"Result\":\"PASS\"},{\"Name\":\"SAVED_BUDGETS\",\"Result\":\"PASS\"},{\"Name\":\"FIXTURE_PATH\",\"Result\":\"PASS\"},{\"Name\":\"ACCEPTED_FIXTURE_IDENTITY\",\"Result\":\"PASS\"},{\"Name\":\"ACCEPTED_FIXTURE_NEWLINES\",\"Result\":\"PASS\"},{\"Name\":\"CONTRACT_FIXTURE_IDENTITY\",\"Result\":\"PASS\"},{\"Name\":\"CONTRACT_FIXTURE_NEWLINES\",\"Result\":\"PASS\"},{\"Name\":\"REFERENCE_anchor-map\",\"Result\":\"PASS\"},{\"Name\":\"REFERENCE_patch-materials\",\"Result\":\"PASS\"},{\"Name\":\"EXPLICIT_ID_COUNTS\",\"Result\":\"PASS\"},{\"Name\":\"class_FULL_DECLARATION_FACTS\",\"Result\":\"PASS\"},{\"Name\":\"apply_FULL_DECLARATION_FACTS\",\"Result\":\"PASS\"},{\"Name\":\"addFlutterTasks_FULL_DECLARATION_FACTS\",\"Result\":\"PASS\"},{\"Name\":\"helper-member-before_RAW_LENGTH_COUNTS\",\"Result\":\"PASS\"},{\"Name\":\"helper-member-after_RAW_LENGTH_COUNTS\",\"Result\":\"PASS\"},{\"Name\":\"apply-preflight-before_RAW_LENGTH_COUNTS\",\"Result\":\"PASS\"},{\"Name\":\"apply-preflight-after_RAW_LENGTH_COUNTS\",\"Result\":\"PASS\"},{\"Name\":\"repository-consumer-before_RAW_LENGTH_COUNTS\",\"Result\":\"PASS\"},{\"Name\":\"repository-consumer-after_RAW_LENGTH_COUNTS\",\"Result\":\"PASS\"},{\"Name\":\"tasks-consumer-before_RAW_LENGTH_COUNTS\",\"Result\":\"PASS\"},{\"Name\":\"tasks-consumer-after_RAW_LENGTH_COUNTS\",\"Result\":\"PASS\"},{\"Name\":\"helper-member_RAW_RANGE_LINES\",\"Result\":\"PASS\"},{\"Name\":\"helper-member_SCOPE_DECLARATION_RELATION\",\"Result\":\"PASS\"},{\"Name\":\"helper-member_REPLACEMENT_DELTA\",\"Result\":\"PASS\"},{\"Name\":\"apply-preflight_RAW_RANGE_LINES\",\"Result\":\"PASS\"},{\"Name\":\"apply-preflight_SCOPE_DECLARATION_RELATION\",\"Result\":\"PASS\"},{\"Name\":\"apply-preflight_REPLACEMENT_DELTA\",\"Result\":\"PASS\"},{\"Name\":\"repository-consumer_RAW_RANGE_LINES\",\"Result\":\"PASS\"},{\"Name\":\"repository-consumer_SCOPE_DECLARATION_RELATION\",\"Result\":\"PASS\"},{\"Name\":\"repository-consumer_REPLACEMENT_DELTA\",\"Result\":\"PASS\"},{\"Name\":\"tasks-consumer_RAW_RANGE_LINES\",\"Result\":\"PASS\"},{\"Name\":\"tasks-consumer_SCOPE_DECLARATION_RELATION\",\"Result\":\"PASS\"},{\"Name\":\"tasks-consumer_REPLACEMENT_DELTA\",\"Result\":\"PASS\"},{\"Name\":\"STORED_TOTAL_AND_SIZE\",\"Result\":\"PASS\"}],\"LiteralCount\":8,\"AnchorCount\":4,\"DeclarationCount\":3,\"ReplacementDeltas\":[2237,37,56,1172],\"TotalReplacementDelta\":3502.0,\"ProspectiveFullOutputBytes\":45907.0,\"ScopeProof\":\"exact line context only\",\"Reads\":3,\"Execution\":0,\"FixtureSDKM550Reads\":0,\"Budget\":\"This invocation only; M5-55 A/B remain closed\"}\r\n"
}
```

## Read-back facts against this exact receipt
```json
{
  "CheckerInvocation": 1,
  "ExitCode": 0,
  "WallSeconds": 0.3681057,
  "OutputUTF8BytesIncludingCRLF": 3037,
  "CompleteJSONParsed": true,
  "CheckCount": 38,
  "CheckNamesExact": true,
  "DuplicateNames": 0,
  "AllChecksPASS": true,
  "SourcesExact": true,
  "Result": "PASS",
  "FailureTagPresent": false,
  "Reads": 3,
  "LiteralCount": 8,
  "AnchorCount": 4,
  "DeclarationCount": 3,
  "ReplacementDeltas": [
    2237,
    37,
    56,
    1172
  ],
  "TotalReplacementDelta": 3502,
  "ProspectiveFullOutputBytes": 45907,
  "ScopeProof": "exact line context only",
  "ReportedExecution": 0,
  "FixtureSDKM550Reads": 0,
  "ToolTruncatedField": "UNKNOWN_NOT_EXPOSED",
  "SeparateStderrField": "UNKNOWN_NOT_EXPOSED",
  "ObservedOutputOnlyJSON": true,
  "PollCalls": 0,
  "ObservationWindowExceeded": false,
  "HardTimeoutMechanism": "NOT_PROVEN"
}
```

原 output 为一个完整可解析 JSON，38 个准确具名检查无重复/缺失且全PASS，
三身份、Reads3、Literal8/Anchor4/Declaration3、四delta、总3502/拟45907
以及ScopeProof均与任务一致。拟尺寸仅局部材料算术，不是完整变换产物。
输出3037 UTF8 bytes（包含末CRLF）≤4KiB，
工具返回没有可见截断标记或额外异常文字。
本接口没有单独 truncated 或 stderr 字段，故两项按 UNKNOWN_NOT_EXPOSED
记录；不自填 truncated=false 或 independently captured stderr empty。
Work仍须核同次native原回执的这些传输字段，不能只据exit0自接受。

## Scope and protected gates
本轮固定checker文档数据验证一次；候选变换函数/完整变换/expected、
Python/AST/import/compile/tests/SDK/fixture/M5-50内容/
launcher-monitor/Gradle/Flutter/JVM/ADB/依赖下载/构建安装启动均0。
前置四身份读取一次与checker内部三文档内容读取一次分开记录，
未另行补读文档或调用检查器。六冻结/rawfixture仅沿用已存治理身份。
旧候选/证据/全部关闭预算/三原文档/dirty-untracked保持；
旧M5-55 B不追认，不commit/pull/push/reset/clean/stash。
无UAC、真实数据备份密钥/生产DB-API-SSH或环境cache-config-home读取。
M5-50历史SOURCE-ONLY/输入适用性阻塞、早期preflight PROPOSED、
属性与LibraryExtension时序NOT_PROVEN、M5及隔离构建NOT_READY、
settings-v1拒绝/loader-runtime false/真实性恢复生产门及transport历史限制保持。
停Work独立核定；最窄CRLF源修订/独立expected/Static-Test均另授。
