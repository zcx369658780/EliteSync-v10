String normalizePublicContentCopy(String value) {
  final normalized = value
      .replaceAll('热点话题', '关系话题')
      .replaceAll('热门征集', '活动话题')
      .replaceAll('同城选择趋势', '轻松活动想法')
      .replaceAll('同城活动后', '活动之后')
      .replaceAll('不同城市用户', '不同经历的人')
      .replaceAll('参与讨论并查看', '看看')
      .replaceAll('最能提升二次见面率', '可以记下值得回想的细节')
      .replaceAll('真实经验', '分享')
      .replaceAll('热门：', '小提示：')
      .replaceAll('同城', '共同兴趣')
      .replaceAll('低压力', '轻松')
      .replaceAll('更容易', '可以')
      .replaceAll('热点', '关系话题')
      .replaceAll('热门', '活动话题');
  final lower = normalized.toLowerCase();
  const prohibitedFragments = [
    'reason_code',
    'next_action_code',
    'contract_version',
    'round_key',
    'state_version',
    'http://',
    'https://',
    'dioexception',
    'dioerror',
    'socketexception',
    'exception',
    'stacktrace',
    'stack trace',
    'provider',
    '服务端',
    '接口返回',
    '缓存键',
    '内部状态',
    '原始得分',
    '权重',
    '阈值',
    '焦虑型依恋',
    '回避型依恋',
    '心理标签',
  ];
  final prohibitedPatterns = [
    RegExp(
      r'\b(no_round|preparing|waiting|revealed|no_candidate|failed|closed)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(raw_?score|score|weight|threshold|rank(?:er|ing)?|quality_?grade|grade)\b\s*[:=]?',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(http\s*\d{3}|dio(?:error|exception)|socketexception|stack\s*trace|status_?code|error_?code)\b',
      caseSensitive: false,
    ),
    RegExp(r'(保证|确保|一定|必然|百分百|100%)\s*(匹配|成功|结果)'),
    RegExp(r'匹配率\s*[:=]?\s*\d+%?'),
    RegExp(r'(焦虑型|回避型|安全型)?依恋(类型|标签)?|心理标签|人格等级'),
  ];
  if (prohibitedFragments.any(lower.contains) ||
      prohibitedPatterns.any((pattern) => pattern.hasMatch(normalized))) {
    return '内容正在整理中，可以稍后再看。';
  }
  return normalized;
}
