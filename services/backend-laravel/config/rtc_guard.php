<?php
return [
    'enabled' => filter_var(env('V1009_RTC_ENABLED', 'false'), FILTER_VALIDATE_BOOL),
    'gateway_secret' => env('V1009_GATEWAY_SECRET', ''),
];
