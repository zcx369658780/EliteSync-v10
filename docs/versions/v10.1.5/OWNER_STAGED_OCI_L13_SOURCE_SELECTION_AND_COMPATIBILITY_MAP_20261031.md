# Laravel13 target-main source selection and compatibility map

Parent: `f9f9b97870c6ca482ced83ba09af82dab326f370`; input: `f407e543e1d6bcd3f9f7f341d876d97dc7228ac1`.

All 257 current-main application/route blobs and the complete apps Tree remain exact. No wider 9b F1/F3/F4 business code was imported. The original SQLite :memory: TestCase remains unchanged.

| Path | Class | Mode | Blob |
|---|---|---|---|
| services/backend-laravel/composer.json | EXACT_F407_FRAMEWORK_INPUT | 100644 | 130793decf84ff8ab93faa0300117b7fab9d1826 |
| services/backend-laravel/composer.lock | EXACT_F407_FRAMEWORK_INPUT | 100644 | e236fbc960c1dd08c1fecb9aeed4926b4cab3933 |
| services/backend-laravel/config/session.php | EXACT_F407_FRAMEWORK_INPUT | 100644 | dbcb582d0afbab3a0dc95576797730555ce3cd8d |
| services/backend-laravel/tests/Feature/Api/V2/TransportEnvelopeTest.php | DERIVED_F407_TEST_MAIN_HASH_PIN_ONLY | 100644 | 44ee2de7b682148ce326563976215351d35c54b7 |
| services/backend-laravel/tests/Feature/V1006AdminWebTest.php | EXACT_F407_FRAMEWORK_INPUT | 100644 | d67921e90c4bde8a6b2644929140978016325ecf |
| services/backend-laravel/tests/Feature/V1007LiveConsentTest.php | ACCEPTED_MAIN_TEST_FIXTURE_ALIGNMENT | 100644 | 273fca333c2f97f0f96def9d4949e8d68c444365 |
| services/backend-laravel/tests/Feature/V1007PrivateMediaTest.php | ACCEPTED_MAIN_TEST_FIXTURE_ALIGNMENT | 100644 | ddd02ced9b382cf004c41f2509079599e89d4497 |
| services/backend-laravel/tests/Feature/V1008MatchingOperationsWebTest.php | EXACT_F407_FRAMEWORK_INPUT | 100644 | edf9ad8811898bfa2d39cedf63f5cc93e274f254 |
| services/backend-laravel/tests/Feature/V1008SessionWebTest.php | EXACT_F407_FRAMEWORK_INPUT | 100644 | 80754a18a09d679a0d14309ea8b171c67ca13e65 |
| services/backend-laravel/tests/Feature/V1009PrivateVideoTest.php | ACCEPTED_MAIN_TEST_FIXTURE_ALIGNMENT | 100644 | ab21487cf54ebb0136cf05aa5b8cfe806f7d5500 |
| services/backend-laravel/tests/Feature/V1014SafetyContinuityR1Test.php | EXACT_F407_FRAMEWORK_INPUT | 100644 | acbc201e312c40b9c9970867df771a64591a9e91 |
| services/backend-laravel/tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php | EXACT_F407_FRAMEWORK_INPUT | 100644 | b024d4d043e57ac71d1c8562f991ea3dd6be339e |
| services/backend-laravel/tests/Feature/FrameworkDependencyCompatibilityTest.php | NEW_TASK_VERIFICATION_TEST_OR_CLI_TOOL | 100644 | 7abec5fbf155f95941657b22004a63d4d4498560 |
| services/backend-laravel/tests/Feature/FrameworkSessionCompatibilityTest.php | EXACT_F407_FRAMEWORK_INPUT | 100644 | b43bdc530389f509c1290a77e940767ed3aba2a8 |
| services/backend-laravel/tests/Support/CreatesAcceptedMainMatch.php | NEW_TASK_VERIFICATION_TEST_OR_CLI_TOOL | 100644 | 7a41ebb9e85705cc94ced7783b3b843c4c429fa5 |
| services/backend-laravel/tools/verification/l13_main_runtime/http_request.php | NEW_TASK_VERIFICATION_TEST_OR_CLI_TOOL | 100644 | 77d86c31f9984748001cb382bde6a39f6deb92de |
| services/backend-laravel/tools/verification/l13_main_runtime/task_fixture.php | NEW_TASK_VERIFICATION_TEST_OR_CLI_TOOL | 100644 | 3aa3fdc90bde4bda2db1dc818bcfc1d74ecc770d |

Repairs: TransportEnvelope retains the unchanged-source assertion but pins the accepted main V1 slice SHA256 ee56dcab57ded641f23039c30207a56d983b6d172670515af765d4cd7ab44d9d. The three old media/consent fixtures now use the already accepted main proposal-parent pattern and two real accept endpoints; no CN/MC authority is directly granted. Guest media denies 401 at auth:sanctum, while authenticated outsiders and revocations still deny 404; no-bytes/no-private-key assertions were added. Guzzle8 uses client-level setHandler, not an unsupported per-request handler option.

Four previous failed batches, the fixture User/int typo, missing read-only question-bank mount and the task facts-table typo remain in LOCAL_ONLY original receipts. The final 166/2817 batch passed. All assertions were retained or strengthened; no business guard was disabled.

The four question-bank JSON inputs were taken from the frozen main native blobs and mounted read-only for tests. They are unchanged main assets and are not added as product differences.

Non-author bounded Sol review found and rechecked helper typing and HTTP CRLF/method guards. Both are fixed; native guard negatives and current PHP lint passed. This helper review is not Astra acceptance.
