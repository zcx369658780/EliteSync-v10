<?php

return [
    'enabled' => env('STAGING_SYNTHETIC_SCOPE_ENABLED', false),
    'instance' => env('STAGING_INSTANCE_ID'),
    'marker_sha256' => env('STAGING_SCOPE_MARKER_SHA256'),
];
