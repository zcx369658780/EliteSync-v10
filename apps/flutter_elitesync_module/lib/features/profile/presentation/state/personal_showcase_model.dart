import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';

enum ShowcaseItemStatus {
  completed('已确认'),
  available('可补充'),
  empty('可补充'),
  later('稍后处理');

  const ShowcaseItemStatus(this.label);
  final String label;
}

class ShowcaseChecklistItem {
  const ShowcaseChecklistItem({
    required this.title,
    required this.description,
    required this.status,
    required this.iconName,
  });

  final String title;
  final String description;
  final ShowcaseItemStatus status;
  final String iconName;

  bool get isReady => status == ShowcaseItemStatus.completed;
}

class PersonalShowcaseSnapshot {
  const PersonalShowcaseSnapshot({
    required this.nickname,
    required this.city,
    required this.profileCompletion,
    required this.showcaseCompletion,
    required this.checklist,
    required this.pendingSuggestions,
    required this.previewLines,
    required this.expressionAdvice,
    required this.readinessTitle,
    required this.readinessHelper,
    required this.primaryMissingClue,
    required this.relationshipGoalLabel,
    required this.detailAvailable,
    required this.localDraft,
  });

  final String nickname;
  final String city;
  final double profileCompletion;
  final double showcaseCompletion;
  final List<ShowcaseChecklistItem> checklist;
  final List<String> pendingSuggestions;
  final List<String> previewLines;
  final List<String> expressionAdvice;
  final String readinessTitle;
  final String readinessHelper;
  final String primaryMissingClue;
  final String relationshipGoalLabel;
  final bool detailAvailable;
  final ProfileLocalDraftPreview localDraft;

  factory PersonalShowcaseSnapshot.fromProfile({
    required ProfileSummaryEntity summary,
    ProfileDetailEntity? detail,
  }) {
    final hasTags = summary.tags.isNotEmpty;
    final hasAstroTag = summary.tags.any(
      (tag) =>
          tag.contains('座') ||
          tag.contains('生肖') ||
          tag.toUpperCase().contains('MBTI'),
    );
    final rawTarget = (detail?.target.trim().isNotEmpty ?? false)
        ? detail!.target
        : summary.target;
    final hasTarget = rawTarget.trim().isNotEmpty;
    final targetDisplayLabel = hasTarget
        ? _relationshipGoalDisplayLabel(rawTarget)
        : '';
    final hasCity =
        summary.city.trim().isNotEmpty ||
        (detail?.city.trim().isNotEmpty ?? false);

    final checklist = [
      const ShowcaseChecklistItem(
        title: '自我介绍',
        description: '用一两句话说明你最近的状态和想被理解的方式。',
        status: ShowcaseItemStatus.empty,
        iconName: 'intro',
      ),
      ShowcaseChecklistItem(
        title: '关系目标',
        description: hasTarget
            ? '当前目标：$targetDisplayLabel'
            : '说明你期待恋爱、搭子或先聊天了解。',
        status: hasTarget
            ? ShowcaseItemStatus.completed
            : ShowcaseItemStatus.available,
        iconName: 'target',
      ),
      ShowcaseChecklistItem(
        title: '兴趣标签',
        description: hasTags
            ? summary.tags.take(3).join(' / ')
            : '补充兴趣标签，让聊天开场更自然。',
        status: hasTags
            ? ShowcaseItemStatus.completed
            : ShowcaseItemStatus.empty,
        iconName: 'tags',
      ),
      ShowcaseChecklistItem(
        title: '生活方式',
        description: hasCity ? '已展示常驻城市，可继续补充作息和相处偏好。' : '补充城市、作息和周末偏好。',
        status: hasCity
            ? ShowcaseItemStatus.available
            : ShowcaseItemStatus.empty,
        iconName: 'lifestyle',
      ),
      const ShowcaseChecklistItem(
        title: '照片/头像',
        description: '当前版本先提醒完善，不新增上传或存储链路。',
        status: ShowcaseItemStatus.later,
        iconName: 'photo',
      ),
      ShowcaseChecklistItem(
        title: '星盘 / 八字 / 紫微关系参考',
        description: hasAstroTag ? '可作为关系解释入口，不代表命运结论。' : '补充出生信息后可查看关系参考。',
        status: hasAstroTag
            ? ShowcaseItemStatus.completed
            : ShowcaseItemStatus.available,
        iconName: 'astro',
      ),
      const ShowcaseChecklistItem(
        title: '聊天开场表达建议',
        description: '先给你低压表达方向，不会自动发送消息。',
        status: ShowcaseItemStatus.available,
        iconName: 'chat',
      ),
    ];
    final readyCount = checklist.where((item) => item.isReady).length;
    final showcaseCompletion = readyCount / checklist.length;
    final pendingSuggestions = checklist
        .where((item) => item.status != ShowcaseItemStatus.completed)
        .take(4)
        .map((item) => item.title)
        .toList(growable: false);

    final displayName = summary.nickname.trim().isEmpty
        ? '我'
        : summary.nickname;
    final cityLine = hasCity
        ? '常驻 ${summary.city.isNotEmpty ? summary.city : detail!.city}'
        : '常驻城市待补充';
    final tagLine = hasTags
        ? '关键词：${summary.tags.take(3).join('、')}'
        : '兴趣关键词待补充';
    final targetLine = hasTarget ? '关系目标：$targetDisplayLabel' : '关系目标待补充';
    final percent = (showcaseCompletion.clamp(0.0, 1.0) * 100).round();
    final primaryMissingClue = pendingSuggestions.isEmpty
        ? '预览别人如何理解我'
        : pendingSuggestions.first;
    final readinessTitle = percent >= 70
        ? '资料完善提示：主要线索已补充'
        : hasTarget || hasTags
        ? '资料完善提示：可以继续补充'
        : '资料完善提示：还差一条表达线索';
    final readinessHelper = percent >= 70
        ? '这里的比例只帮助你整理资料，不代表审核、发布、对外可见或匹配资格。'
        : '可以再补充一条表达线索；这里的比例只是本地整理提示，不会开启审核、发布或匹配资格。';
    final localDraft = ProfileLocalDraftPreview(
      title: '先整理一版资料草稿',
      helper: pendingSuggestions.isEmpty
          ? '当前展示线索可以先作为本地草稿预览，待你确认后再进入后续保存流程。'
          : '先把${pendingSuggestions.first}整理成本地草稿，待你确认后再决定是否继续完善。',
      lines: [
        hasTarget ? '关系目标：$targetDisplayLabel' : '关系目标：待你确认',
        hasTags
            ? '关键词建议：${summary.tags.take(2).join('、')}'
            : '关键词建议：后续可基于你的确认生成展示标签',
        hasCity ? '生活线索：$cityLine' : '生活线索：常驻城市待你确认',
      ],
      boundary: '本地草稿，尚未保存；不会自动发送，不会直接写入正式资料，也不会自动改推荐权重。正式提交前还需要安全检查。',
    );

    return PersonalShowcaseSnapshot(
      nickname: displayName,
      city: summary.city,
      profileCompletion: summary.completion.clamp(0.0, 1.0),
      showcaseCompletion: showcaseCompletion.clamp(0.0, 1.0),
      checklist: checklist,
      pendingSuggestions: pendingSuggestions,
      previewLines: ['$displayName，$cityLine', tagLine, targetLine],
      expressionAdvice: const [
        '先写一句最近的生活状态，比长篇自我包装更自然。',
        '把关系目标说清楚：想认真了解、先聊天，或寻找稳定搭子。',
        '选择 2-3 个具体兴趣，方便对方发起第一句聊天。',
      ],
      readinessTitle: readinessTitle,
      readinessHelper: readinessHelper,
      primaryMissingClue: primaryMissingClue,
      relationshipGoalLabel: hasTarget ? targetDisplayLabel : '慢慢了解',
      detailAvailable: detail != null,
      localDraft: localDraft,
    );
  }

  int get showcasePercent => (showcaseCompletion * 100).round();
  int get profilePercent => (profileCompletion * 100).round();
}

class ProfileLocalDraftPreview {
  const ProfileLocalDraftPreview({
    required this.title,
    required this.helper,
    required this.lines,
    required this.boundary,
  });

  final String title;
  final String helper;
  final List<String> lines;
  final String boundary;
}

String _relationshipGoalDisplayLabel(String rawValue) {
  switch (rawValue.trim().toLowerCase()) {
    case 'dating':
      return '慢约会';
    case 'friendship':
      return '交朋友';
    default:
      return rawValue.trim();
  }
}
