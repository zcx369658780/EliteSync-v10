import 'package:flutter_elitesync_module/features/match/domain/entities/match_detail_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';

enum DateDropChainState { preparing, noCandidate, revealed, feedbackGiven }

class DateDropMainChainModel {
  const DateDropMainChainModel({
    required this.state,
    required this.preparationReferences,
    required this.lightActions,
    required this.openerSuggestions,
    required this.feedbackOptions,
    required this.boundaryNotes,
    required this.showcasePrompt,
  });

  factory DateDropMainChainModel.fromMatch({
    MatchResultEntity? result,
    MatchDetailEntity? detail,
    bool feedbackGiven = false,
    bool showcaseComplete = false,
    bool candidateUnavailable = false,
  }) {
    final tags =
        result?.tags.where((tag) => tag.trim().isNotEmpty).toList() ?? const [];
    final reasons =
        detail?.reasons.where((reason) => reason.trim().isNotEmpty).toList() ??
        const [];
    final primaryTag = tags.isNotEmpty ? tags.first : '最近的生活节奏';
    final secondaryTag = tags.length > 1 ? tags[1] : '周末安排';
    final reasonHint = reasons.isNotEmpty ? reasons.first : '沟通节奏';

    return DateDropMainChainModel(
      state: feedbackGiven
          ? DateDropChainState.feedbackGiven
          : candidateUnavailable
          ? DateDropChainState.noCandidate
          : result == null
          ? DateDropChainState.preparing
          : DateDropChainState.revealed,
      preparationReferences: const [
        '基础资料',
        '展示自己',
        '关系目标',
        '兴趣 / 生活方式',
        '星盘 / 八字 / 紫微参考',
        '互动反馈',
      ],
      lightActions: const ['完善展示自己', '准备自我介绍', '查看可改写草稿', '记录体验反馈'],
      openerSuggestions: [
        '可以先从$primaryTag聊起，问一个轻松的问题。',
        '如果提到$secondaryTag，可以先分享自己的一个小习惯。',
        '围绕$reasonHint展开时，先问感受，不急着下结论。',
      ],
      feedbackOptions: const ['我想多看到类似的人', '这个方向不太适合我', '聊天开始有点困难', '资料不够了解'],
      boundaryNotes: const [
        '这些解释是帮助你开始了解，不是替你做决定。',
        '反馈会帮助后续方向更贴近你，但本版本不声称已经改变真实推荐权重。',
        '星盘 / 八字 / 紫微只作为关系参考维度，不决定你们是否合适。',
      ],
      showcasePrompt: showcaseComplete
          ? '你的展示资料已经比较完整，可以先从轻松问题开始。'
          : '完善展示自己，会让别人更快理解你。',
    );
  }

  final DateDropChainState state;
  final List<String> preparationReferences;
  final List<String> lightActions;
  final List<String> openerSuggestions;
  final List<String> feedbackOptions;
  final List<String> boundaryNotes;
  final String showcasePrompt;

  String get stageLabel {
    switch (state) {
      case DateDropChainState.preparing:
        return '当前：准备表达线索';
      case DateDropChainState.noCandidate:
        return '当前：等待本轮揭晓';
      case DateDropChainState.revealed:
        return '当前：先理解再开场';
      case DateDropChainState.feedbackGiven:
        return '当前：回看反馈';
    }
  }

  String get nextStepLabel {
    switch (state) {
      case DateDropChainState.preparing:
        return '下一步：整理展示自己';
      case DateDropChainState.noCandidate:
        return '下一步：等待揭晓后阅读解释';
      case DateDropChainState.revealed:
        return '下一步：查看解释，或手动带着草稿去消息';
      case DateDropChainState.feedbackGiven:
        return '下一步：带着记录的感受进入下一轮';
    }
  }

  String get boundaryLabel {
    switch (state) {
      case DateDropChainState.preparing:
        return '准备是为了被理解，不是提高匹配分。';
      case DateDropChainState.noCandidate:
        return '等待态不会提前打开解释或聊天；反馈只作为后续方向参考。';
      case DateDropChainState.revealed:
        return '开场建议只是草稿来源，发送始终由你确认。';
      case DateDropChainState.feedbackGiven:
        return '反馈只作为后续方向参考，不声称实时改权重。';
    }
  }

  bool containsForbiddenCopy() {
    final text = [
      ...preparationReferences,
      ...lightActions,
      ...openerSuggestions,
      ...feedbackOptions,
      ...boundaryNotes,
      showcasePrompt,
      stageLabel,
      nextStepLabel,
      boundaryLabel,
    ].join('\n');

    const forbidden = [
      'mock',
      'debug',
      'payload',
      'ranking score',
      'scoring_status',
      'external_oracle_status',
      '付费提高曝光',
      '无限推荐',
      '刷更多',
      'feed',
      '算法权重已调整',
      '保证匹配成功',
      '系统已完全理解你',
      '星盘决定你们是否合适',
    ];

    return forbidden.any(text.contains);
  }
}
