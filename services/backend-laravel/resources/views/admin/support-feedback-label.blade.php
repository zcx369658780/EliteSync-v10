@php
    $labels = ($kind ?? 'status') === 'category'
        ? ['match_recommendation' => '匹配推荐', 'buddy_experience' => '搭子体验',
            'chat_experience' => '聊天体验', 'profile_data' => '资料与展示',
            'astro_display' => '星盘 / 八字 / 紫微显示', 'ziwei_flying_star_oracle' => '紫微显示校准',
            'bug_report' => '页面异常', 'other_suggestion' => '其他建议']
        : ['OPEN' => '已接收', 'IN_REVIEW' => '处理中', 'RESOLVED' => '已解决', 'CLOSED' => '已关闭'];
@endphp
{{ $labels[$value] ?? $value }}
