<?php

return [
    'enabled' => filter_var(env('V1007_LOCAL_RESTORATION', false), FILTER_VALIDATE_BOOL),
    'port' => (int) env('V1007_DB_PORT', 43317),
    'synthetic_connection_enabled' => filter_var(env('V2_SYNTHETIC_CONNECTION_ENABLED', false), FILTER_VALIDATE_BOOL),
];
