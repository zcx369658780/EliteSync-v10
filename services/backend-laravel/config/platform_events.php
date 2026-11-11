<?php

return [
    // Explicit local wiring only; PlatformAccess also validates the exact pair.
    'database' => env('PLATFORM_EVENTS_DATABASE', 'elitesync_v10_1_4_dev'),
    'port' => (int) env('PLATFORM_EVENTS_DB_PORT', 43325),
];
