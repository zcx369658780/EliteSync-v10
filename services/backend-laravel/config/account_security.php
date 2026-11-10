<?php

return [
    // Never infer erasure authority from APP_ENV, a phone prefix or a client flag.
    'erasure_enabled' => env('V1011_ERASURE_ENABLED', false),
    'dataset' => 'v10.1.1-controlled-synthetic',
    'database' => 'elitesync_v10_1_1_dev',
    'host' => '127.0.0.1',
    'port' => 43322,
];
