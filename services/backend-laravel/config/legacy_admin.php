<?php

return [
    'target' => env('LEGACY_ADMIN_TARGET'),
    'url' => env('LEGACY_ADMIN_HTTPS_ORIGIN'),
    'database' => env('LEGACY_ADMIN_DATABASE'),
    'host' => env('LEGACY_ADMIN_DATABASE_HOST'),
    'connection' => env('LEGACY_ADMIN_DATABASE_CONNECTION'),
    'username' => env('LEGACY_ADMIN_DATABASE_USERNAME'),
    'port' => (int) env('LEGACY_ADMIN_DATABASE_PORT', 0),
    'current_user' => env('LEGACY_ADMIN_DATABASE_CURRENT_USER'),
    'version' => env('LEGACY_ADMIN_DATABASE_VERSION'),
    'server_id' => (int) env('LEGACY_ADMIN_SERVER_ID', 0),
    'approval' => env('LEGACY_ADMIN_APPROVAL'),
    'operator' => env('LEGACY_ADMIN_OPERATOR'),
    'owner_public_key' => env('LEGACY_ADMIN_OWNER_PUBLIC_KEY'),
];
