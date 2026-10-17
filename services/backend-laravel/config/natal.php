<?php

return [
    // Local executables only. No HTTP engine or research-license fallback.
    'python' => env('NATAL_PYTHON', ''),
    'node' => env('NATAL_NODE', 'node'),
    'kernel' => env('NATAL_JPL_KERNEL', ''),
    'kernel_sha256' => 'c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2',
    'timeout_seconds' => 45,
    'identity_timeout_seconds' => 10,
];
