<?php

return [
    'android' => [
        'latest_version_name' => env('ANDROID_LATEST_VERSION_NAME', '0.07.04'),
        'latest_version_code' => (int) env('ANDROID_LATEST_VERSION_CODE', 70400),
        'min_supported_version_name' => env('ANDROID_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('ANDROID_DOWNLOAD_URL', 'http://101.133.161.203/downloads/elitesync-0.07.04.apk'),
        'changelog' => env('ANDROID_CHANGELOG', '7.0 视觉层级与慢约会体验刷新：首页更聚焦今天的主行动，发现页更明确为轻探索和关系灵感，我的页与展示自己入口更低压力，匹配 / Date Drop 主链更清楚呈现当前阶段、下一步与等待边界，设置、版本、反馈、通知与星盘相关页面减少工程感和过度声明。边界：不改变匹配算法、后端资料保存/公开展示能力、聊天/媒体/反馈持久化、通知推送、星盘/八字/紫微计算逻辑或生产服务端能力。'),
        'sha256' => env('ANDROID_APK_SHA256', '34EBFC8C841B4F38C7CAE08D5CED025FDA6783D6972D359F51A29EE0CB8BFEAC'),
        'force_update' => (bool) env('ANDROID_FORCE_UPDATE', false),
    ],
    'ios' => [
        'latest_version_name' => env('IOS_LATEST_VERSION_NAME', '0.01.01'),
        'latest_version_code' => (int) env('IOS_LATEST_VERSION_CODE', 101),
        'min_supported_version_name' => env('IOS_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('IOS_DOWNLOAD_URL', ''),
        'changelog' => env('IOS_CHANGELOG', ''),
        'sha256' => env('IOS_APP_SHA256', ''),
        'force_update' => (bool) env('IOS_FORCE_UPDATE', false),
    ],
];
