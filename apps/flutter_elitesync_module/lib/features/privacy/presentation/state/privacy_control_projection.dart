import 'package:flutter_elitesync_module/app/router/app_route_names.dart';

class PrivacyControlArea {
  const PrivacyControlArea({
    required this.key,
    required this.title,
    required this.purpose,
    required this.audience,
    required this.unresolved,
    this.availableActionLabel,
    this.availableActionRoute,
  });

  final String key;
  final String title;
  final String purpose;
  final String audience;
  final List<String> unresolved;
  final String? availableActionLabel;
  final String? availableActionRoute;

  bool get hasAvailableNavigation =>
      availableActionLabel != null && availableActionRoute != null;
}

abstract final class PrivacyControlProjection {
  static const notYetEstablished = 'NOT YET ESTABLISHED';

  static const areas = <PrivacyControlArea>[
    PrivacyControlArea(
      key: 'private-identity',
      title: 'Private Identity · 私密身份',
      purpose: '用于账户身份与资料维护，不代表公开个人主页。',
      audience: 'ACCOUNT_PRIVATE / PRIVATE_IDENTITY',
      unresolved: ['服务端可见性控制', '导出与删除规则', '地区权利实现'],
      availableActionLabel: '查看私密身份页面',
      availableActionRoute: AppRouteNames.mePrivateIdentity,
    ),
    PrivacyControlArea(
      key: 'matching-inputs-readiness',
      title: 'Matching Inputs / Readiness · 匹配输入与准备状态',
      purpose: '用于准备状态与匹配输入；填写或完成不会自动加入匹配。',
      audience: 'READINESS_RESTRICTED',
      unresolved: ['字段级撤回', '保留期限', '身份保证机制'],
      availableActionLabel: '查看匹配输入页面',
      availableActionRoute: AppRouteNames.meMatchingInputs,
    ),
    PrivacyControlArea(
      key: 'candidate-showcase',
      title: 'Candidate-scoped Showcase · 候选人范围展示',
      purpose: '仅用于候选人范围内的展示准备，不是全局公开 Profile。',
      audience: 'SHOWCASE_CANDIDATE_SCOPED',
      unresolved: ['候选人范围撤回', '服务端可见性', '导出与删除规则'],
      availableActionLabel: '查看展示页面',
      availableActionRoute: AppRouteNames.meShowcase,
    ),
    PrivacyControlArea(
      key: 'product-connection',
      title: 'Product Connection · 产品连接',
      purpose: '独立的双方同意生命周期；Match 不会自动建立 Connection。',
      audience: 'CONNECTION_SCOPED',
      unresolved: ['运行时权威来源', '请求与同意写入', '关闭后的保留规则'],
      availableActionLabel: '查看连接页面',
      availableActionRoute: AppRouteNames.progressConnection,
    ),
    PrivacyControlArea(
      key: 'private-conversation',
      title: 'Private Conversation · 私密对话',
      purpose: '需要 CN_ACTIVE 与独立双方消息同意；Connection 本身不开放消息。',
      audience: 'CONVERSATION_SHARED_PRIVATE',
      unresolved: ['保留期限', '导出', '删除', '关闭后的读取规则'],
      availableActionLabel: '查看消息权限页面',
      availableActionRoute: AppRouteNames.messages,
    ),
    PrivacyControlArea(
      key: 'ai-private-support',
      title: 'AI-derived / Private Support · AI 派生与私密支持',
      purpose: '仅可作为有边界的辅助说明，不是已验证事实或人格结论。',
      audience: 'PRIVATE_SUPPORT_ONLY',
      unresolved: ['信号允许清单', '撤回与更正机制', '保留与训练用途'],
    ),
    PrivacyControlArea(
      key: 'safety-restricted',
      title: 'Safety-restricted Information · Safety 受限信息',
      purpose: '仅供受限 Safety 处理；不得成为排名、声誉、兼容性或有罪判断。',
      audience: 'SAFETY_RESTRICTED',
      unresolved: ['地区法律流程', '保留与申诉机制', '完整访问控制'],
    ),
    PrivacyControlArea(
      key: 'operational-minimum',
      title: 'Operational Minimum · 运行所需最小数据',
      purpose: '仅用于账号、设备和服务运行；操作偏好不等于领域同意。',
      audience: 'OPERATIONAL_MINIMUM',
      unresolved: ['完整数据清单', '地区权利实现', '服务端删除与导出'],
      availableActionLabel: '查看设备与账号设置',
      availableActionRoute: AppRouteNames.settings,
    ),
  ];
}
