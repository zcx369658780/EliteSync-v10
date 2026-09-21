class MatchMock {
  static const roundProjection = {
    'data': {
      'state': 'revealed',
      'server_now': '2026-09-21T09:00:00Z',
      'updated_at': '2026-09-21T09:00:00Z',
      'round_id': 990000001,
      'result_id': 990000101,
      'retry_eligible': false,
      'user_action': 'none',
      'projection_version': 1,
      'round_key': 'SYNTHETIC_DEMO_ROUND_01',
      'state_version': 1,
      'reveal_at': '2026-09-21T09:00:00Z',
      'next_action_code': 'NONE_READ_ONLY',
      'result': {
        'match_id': 990000101,
        'partner_id': 990000201,
        'partner_nickname': 'Synthetic Demo Partner 990000201',
        'headline': 'Synthetic candidate proposal · 开发演示假数据',
      },
      'conversation_capability': {
        'can_create': false,
        'can_send': false,
        'can_ws': false,
      },
    },
    'meta': {'contract_version': 'synthetic-demo-v0.1'},
  };

  static const countdown = {
    'status': 'waiting_drop',
    'reveal_at': '2026-03-31T21:00:00+08:00',
    'hint': '资料完成度越高，匹配解释会更精准。',
  };

  static const resultHappy = {
    'status': 'matched',
    'match_id': '1703',
    'headline': '你们在沟通与情绪节奏上较契合',
    'score': 86,
    'confidence': 88,
    'tags': ['同城', '高匹配', '节奏接近'],
    'highlights': [
      {'title': '依恋安全感', 'value': 51, 'desc': '都倾向稳定关系'},
      {'title': '冲突修复倾向', 'value': 48, 'desc': '冲突后愿意重建沟通'},
    ],
  };

  static const resultNoMatch = {
    'status': 'no_match',
    'message': '暂无匹配或未到 Drop',
  };

  static const resultError = {
    'ok': false,
    'code': 'MATCH_RESULT_ERROR',
    'message': '匹配结果获取失败',
  };
}
