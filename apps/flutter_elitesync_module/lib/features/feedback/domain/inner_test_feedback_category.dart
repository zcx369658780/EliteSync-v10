import 'package:flutter/material.dart';

class InnerTestFeedbackCategory {
  const InnerTestFeedbackCategory({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;
}

const innerTestFeedbackCategories = <InnerTestFeedbackCategory>[
  InnerTestFeedbackCategory(
    id: 'match_recommendation',
    label: '匹配推荐',
    description: '推荐结果、解释、节奏或破冰建议。',
    icon: Icons.favorite_border_rounded,
  ),
  InnerTestFeedbackCategory(
    id: 'buddy_experience',
    label: '搭子体验',
    description: '搭子类型、活动建议或边界提示。',
    icon: Icons.groups_2_outlined,
  ),
  InnerTestFeedbackCategory(
    id: 'chat_experience',
    label: '聊天体验',
    description: '聊天入口、开场建议或消息体验。',
    icon: Icons.chat_bubble_outline_rounded,
  ),
  InnerTestFeedbackCategory(
    id: 'profile_data',
    label: '资料与展示',
    description: '应用设置、功能体验、资料展示或页面问题。',
    icon: Icons.badge_outlined,
  ),
  InnerTestFeedbackCategory(
    id: 'astro_display',
    label: '星盘 / 八字 / 紫微显示',
    description: '星盘、八字、紫微主星、四化或页面展示。',
    icon: Icons.auto_awesome_outlined,
  ),
  InnerTestFeedbackCategory(
    id: 'ziwei_flying_star_oracle',
    label: '紫微显示校准',
    description: '请写明宫位、方向、对照结果和截图来源。',
    icon: Icons.device_hub_outlined,
  ),
  InnerTestFeedbackCategory(
    id: 'bug_report',
    label: '页面异常',
    description: '卡住、错位、打不开、闪退或异常提示。',
    icon: Icons.bug_report_outlined,
  ),
  InnerTestFeedbackCategory(
    id: 'other_suggestion',
    label: '其他建议',
    description: '其他体验建议或不确定问题。',
    icon: Icons.lightbulb_outline_rounded,
  ),
];

InnerTestFeedbackCategory innerTestFeedbackCategoryById(String? id) {
  return innerTestFeedbackCategories.firstWhere(
    (category) => category.id == id,
    orElse: () => innerTestFeedbackCategories.first,
  );
}

String innerTestFeedbackSourceLabel(String? source) {
  switch ((source ?? '').trim()) {
    case 'settings':
      return '从设置进入';
    case 'version_center':
      return '从版本中心进入';
    case 'profile':
      return '从资料页进入';
    case 'match':
      return '从匹配进入';
    case 'buddy':
      return '从搭子进入';
    case 'astro':
      return '从星盘进入';
    case 'ziwei':
      return '从紫微进入';
    default:
      return '从反馈入口进入';
  }
}
