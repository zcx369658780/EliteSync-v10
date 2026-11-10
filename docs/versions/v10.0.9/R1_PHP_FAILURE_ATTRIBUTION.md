# v10.0.9 R1：PHP 16项具名失败归因

CODEX_REPORTED；不是全量PHP通过声明。原始全量：1063项/14037断言/4 errors/12 failures/exit2，发生于最终PDO边界修复前。退出码来源为原会话第3577行 `TEST_EXIT=2`，外层记录exit0只是随后输出命令成功，不能替代PHP退出码。

固定0.8基线 `3a8f7989aa208285b885f1c80f4365f38488ac54`（backend与K08产品提交4f1b3c52一致）；候选 `66a8638581d1017823ac3caa2536568e0de3b939`。两份隔离Git archive副本，使用相同现有vendor、独立Composer应用映射、同PHP8.5.3/PHPUnit11.5.55、512M、phpunit.xml、相同本地.env字节、sqlite :memory:和各自固定题库。反射实读应用类来自各自副本。产品/测试源码逐blob核对；题库四JSON由archive转CRLF，与原工作树字节相同，LF规范化及JSON语义均同固定blob。未启动持久DB、seed持久数据或改变依赖。

对16个精确class::method使用锚定filter（不是全量重跑）：两侧各16项/62断言/4 errors/12 failures/exit2。以下“基线复现”表示同运行时/配置/fixture的定点复现，不等于重现原全量执行顺序或诊断全部更深根因。未删测试、改断言或改冻结AC。

| # | 完整测试名 | 原失败及原因 | 0.9关联/分类依据 | 基线/候选定点exit |
|---|---|---|---|---|
| 1 | `Tests\Unit\ZiweiIztroAppVisibleReplacementTest::test_app_visible_replacement_outputs_b_iztro_14_main_star_subset` | error: Undefined array key algorithm_route（原流L29） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 2 | `Tests\Unit\ZiweiIztroAppVisibleReplacementTest::test_app_visible_replacement_outputs_c_iztro_14_main_star_subset` | error: Undefined array key algorithm_route（原流L36） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 3 | `Tests\Unit\ZiweiIztroLocalReplacementTest::test_local_replacement_mode_outputs_b_iztro_14_main_star_subset` | error: Undefined array key algorithm_route（原流L43） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 4 | `Tests\Unit\ZiweiIztroLocalReplacementTest::test_local_replacement_mode_outputs_c_iztro_14_main_star_subset` | error: Undefined array key algorithm_route（原流L50） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 5 | `Tests\Unit\ZiweiIztroRunnerClientTest::test_runner_client_executes_iztro_runner_for_sample_a` | failure: runner success=false; expected true（原流L61） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 6 | `Tests\Unit\ZiweiIztroShadowAdapterTest::test_shadow_adapter_generates_a_b_c_candidates_that_match_accepted_strict_subset` | failure: candidate_unavailable; expected candidate_generated（原流L66） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 7 | `Tests\Unit\ZiweiIztroShadowAdapterTest::test_shadow_adapter_preserves_b_empty_strict_main_star_palaces` | failure: empty palace subset; expected two entries（原流L76） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 8 | `Tests\Feature\AdminMatchingOperationalTruthLoopIntegratedSmokeTest::test_disposable_admin_operation_truth_recovery_and_audit_loop` | failure: HTTP 500; expected 202; synchronous matching job raises matching execution failed（原流L95） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 9 | `Tests\Feature\Api\V2\TransportEnvelopeTest::test_v1_source_slice_and_non_authority_boundaries_remain_unchanged` | failure: obsolete literal v1 source hash; baseline and candidate both differ from expected, with distinct actual hashes（原流L194） | Shared route file changed; literal hash already fails on 0.8; permitted RTC additions also change candidate hash；BASELINE_REPRODUCED | 2 / 2 |
| 10 | `Tests\Feature\C2LocalRuntimeIntegrationTest::test_admin_request_replay_stale_retry_reveal_and_close_contract` | failure: HTTP 500; expected 202; synchronous matching job raises matching execution failed（原流L204） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 11 | `Tests\Feature\C2LocalRuntimeIntegrationTest::test_non_admin_is_denied_and_compensation_stays_unavailable` | failure: HTTP 409; expected 403（原流L303） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 12 | `Tests\Feature\DomainSkeletonApiTest::test_conversation_and_media_skeleton_routes_are_available` | failure: stored_conversation; expected conversation（原流L312） | Indirect conversation route; same contract failure on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 13 | `Tests\Feature\MatchPayloadContractTest::test_current_match_payload_contains_all_module_contracts_from_matching_engine` | failure: HTTP 403; expected 200（原流L324） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 14 | `Tests\Feature\MatchRoundApiFoundationTest::test_admin_and_cli_execution_are_default_off` | failure: HTTP 200; expected 503（原流L333） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 15 | `Tests\Feature\ProfileBasicRecomputeTest::test_save_basic_invalidates_stale_western_natal_chart_cache_before_detail_recompute` | failure: chart subject marker empty; expected fixture input signature（原流L341） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |
| 16 | `Tests\Feature\ProfileBasicRecomputeTest::test_save_basic_marks_western_natal_render_failure_without_fake_chart_cache` | failure: HTTP fake recorded 0 requests; expected 1（原流L351） | No direct changed implementation identified; same failure signature on baseline；BASELINE_REPRODUCED | 2 / 2 |

## 范围与判别

- #1–7：原有iztro shadow/display测试。既有runner依赖解析仅做resolve，返回MODULE_NOT_FOUND/exit1；没有安装依赖、运行新的排盘或修改被许可算法。缺失依赖导致runner不可用与fallback形态；0.8同样失败。保持范围外观察，不能称本版新回归，也不将其当新算法验证。
- #8/#10：原matching同步job异常，最外层HTTP500；匹配实现未被0.9直接修改，两侧定点同样500。更深历史失败根因不扩查，仍UNKNOWN。
- #9：预期固定摘要986308…已经不匹配0.8实际2cf944…；候选实际7ce3e8…也不匹配。0.9确有共享routes/api.php改动，增加受控rtc-guard入口和RtcTransaction，不能声称路由字节不变。两侧失败在同一字面摘要断言，0.9变化属于冻结RTC实现，不改断言追绿；另逐项核v2切片相同、v1无application-envelope、声明恰1、v2无auth:sanctum，均通过，见route-boundary-safe.json。没有因此宣称整个原测试PASS。
- #11/#13/#14：旧匹配权限/默认开关断言与当前fixture/config结果不符；基线与候选相同。#12为旧skeleton期望conversation、实际stored_conversation，关联共享会话路由但0.8同样失败。#15/#16原natal chart策略/重算与fake请求断言失败，0.8同样失败；不解除许可或Safety门。
- 最终PDO相关选集 `V1009|V1007LiveConsent|V1008EligibilityConsent` 在候选固定副本再次37项/325断言/exit0，保留vendor/PHPUnit弃用。未发现R1新增产品缺陷，源码/测试修复为空；不宣称全量绿或所有失败从未受0.9间接影响。

## 必须保留的调查失败

第一次两侧副本漏带根question_bank，各16/58，5 errors/11 failures/exit2；MatchPayload额外setup错误使其不能充当同fixture对照。恢复各自固定题库后得到上述v2结果，原流不删除。包装脚本重复定义PHPUnit常量警告已用官方入口的global路径参数修正。分析脚本默认GBK导致一次exit1；显式UTF-8读取后通过。逐blob初查发现四题库CRLF差异而exit1；已据archive/原工作树/LF与JSON检查解释，不掩盖该原始检查失败。详见harness-observations及LOCAL_ONLY原流。

原全量stderr已合并入txt，不能事后伪造独立stderr。R1各命令stdout/stderr/JUnit/exit单独封存并列于raw-evidence-index.json。全套PHP和全套Flutter本次NOT_RUN。
