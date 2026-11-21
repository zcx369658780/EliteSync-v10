<?php

return [
    'target' => env('LEGACY_ADMIN_TARGET'),
    'url' => env('LEGACY_ADMIN_HTTPS_ORIGIN'),
    'database' => env('LEGACY_ADMIN_DATABASE'),
    'host' => env('LEGACY_ADMIN_DATABASE_HOST'),
    'server_id' => (int) env('LEGACY_ADMIN_SERVER_ID', 0),
    'approval' => env('LEGACY_ADMIN_APPROVAL'),
];
