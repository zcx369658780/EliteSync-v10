<?php

return [
    'enabled' => env('DYNAMIC_CHARTS_ENABLED', false),
    // Selection only: DynamicChartService keeps the development allowlist fixed in source.
    'database' => env('DYNAMIC_CHARTS_DATABASE', 'elitesync_v1011_dev'),
    'timeout_seconds' => 300,
];
