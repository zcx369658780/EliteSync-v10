<?php

return [
    'test_issuer_enabled' => env('V1012_TEST_ISSUER_ENABLED', false),
    'test_issuer_key' => env('V1012_TEST_ISSUER_KEY', ''),
    'mariadb_fixture_enabled' => filter_var(env('V2_FUNCTION_MARIADB_IDENTITY_ENABLED', false), FILTER_VALIDATE_BOOL),
    'mariadb_fixture_runtime' => env('V2_FUNCTION_RUNTIME', ''),
    'dataset' => 'v1012-synthetic-only',
    'proposal_hours' => 168,
];
