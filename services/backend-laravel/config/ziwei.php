<?php

return [
    'iztro' => [
        'mode' => env('ZIWEI_IZTRO_MODE', 'off'),
        'allowed_local_replacement_environments' => ['local', 'testing', 'dev'],
        'app_visible_replacement' => [
            'production_allowed' => filter_var(env('ZIWEI_IZTRO_APP_VISIBLE_PRODUCTION_ALLOWED', false), FILTER_VALIDATE_BOOLEAN),
        ],
        'fail_open_to_current_runtime' => true,
        'timeout_ms' => 5000,
        'log_birth_payload' => false,
        'runner_path' => env('ZIWEI_IZTRO_RUNNER_PATH', base_path('tools/ziwei/iztro-runner/runner.mjs')),
        'node_bin' => env('ZIWEI_IZTRO_NODE_BIN', 'node'),
    ],
];
