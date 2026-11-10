import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

/// A server snapshot, independent of self-reported identity or local progress.
class OperationalStatus {
  const OperationalStatus({
    required this.status,
    required this.reason,
    required this.revision,
    required this.moderationStatus,
    required this.eligible,
    required this.reasonCode,
    required this.requiredAnswers,
    required this.answeredAnswers,
    required this.missingAnswers,
    required this.nextActionCode,
  });

  final String status;
  final String reason;
  final int revision;
  final String moderationStatus;
  final bool eligible;
  final String reasonCode;
  final int requiredAnswers;
  final int answeredAnswers;
  final int missingAnswers;
  final String nextActionCode;

  factory OperationalStatus.fromJson(Map<String, dynamic> json) {
    final matching = json['matching_eligibility'];
    final status = json['status'];
    if (!const ['pending', 'approved', 'rejected'].contains(status) ||
        json['reason'] is! String ||
        json['revision'] is! int ||
        (json['revision'] as int) < 0 ||
        json['moderation_status'] is! String ||
        matching is! Map<String, dynamic> ||
        matching['eligible'] is! bool ||
        matching['reason_code'] is! String ||
        matching['next_action_code'] is! String) {
      throw const FormatException('Invalid operating status');
    }
    for (final field in const [
      'required_answer_count',
      'answered_answer_count',
      'missing_answer_count',
    ]) {
      if (matching[field] is! int || (matching[field] as int) < 0) {
        throw const FormatException('Invalid answer coverage');
      }
    }
    return OperationalStatus(
      status: status as String,
      reason: json['reason'] as String,
      revision: json['revision'] as int,
      moderationStatus: json['moderation_status'] as String,
      eligible: matching['eligible'] as bool,
      reasonCode: matching['reason_code'] as String,
      requiredAnswers: matching['required_answer_count'] as int,
      answeredAnswers: matching['answered_answer_count'] as int,
      missingAnswers: matching['missing_answer_count'] as int,
      nextActionCode: matching['next_action_code'] as String,
    );
  }
}

final operationalStatusProvider = FutureProvider.autoDispose<OperationalStatus>(
  (ref) async {
    final result = await ref
        .watch(apiClientProvider)
        .get('/api/v1/profile/operating-status');
    if (result is! NetworkSuccess<Map<String, dynamic>>) {
      throw const FormatException('Operating status unavailable');
    }
    return OperationalStatus.fromJson(result.data);
  },
  // Show an explicit failure immediately; recovery is a user-requested refresh.
  retry: (_, _) => null,
);

class OperationalStatusCard extends ConsumerWidget {
  const OperationalStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(operationalStatusProvider);
    return AppInfoSectionCard(
      title: '运营参与资格（非实名认证）',
      subtitle: '审核用于新一轮匹配准入；不代表外部身份认证。',
      leadingIcon: Icons.fact_check_outlined,
      child: state.when(
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: false,
        loading: () => const Text('正在读取服务器运营资格…'),
        error: (_, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('运营资格暂不可用，无法确认当前审核或匹配状态。'),
            TextButton(
              onPressed: () => ref.invalidate(operationalStatusProvider),
              child: const Text('重试读取运营资格'),
            ),
          ],
        ),
        data: (status) {
          final label = switch (status.status) {
            'approved' => '运营审核已通过',
            'rejected' => '运营审核未通过',
            _ => '运营审核待处理',
          };
          final restricted = const [
            'restrict',
            'restricted',
          ].contains(status.moderationStatus);
          final banned = status.moderationStatus == 'banned';
          final eligible =
              status.status == 'approved' &&
              status.eligible &&
              !restricted &&
              !banned;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              if (status.reason.trim().isNotEmpty)
                Text('审核原因：${status.reason}'),
              if (restricted)
                const Text('账号受限：保留当前合法权限下的历史只读及申诉；新匹配、公开发布和新的私信收发暂停。'),
              if (banned) const Text('账号已禁用，请通过合法支持途径处理。'),
              Text(eligible ? '服务器确认可参与新一轮匹配' : '当前不能参与新一轮匹配'),
              if (status.status == 'approved' && !eligible)
                const Text('审核通过仍须满足问卷覆盖、账号状态及其它准入条件。'),
              Text(
                '当前有效回答 ${status.answeredAnswers} / 所需 ${status.requiredAnswers} 项',
              ),
              if (status.missingAnswers > 0) ...[
                Text('需补答 ${status.missingAnswers} 项当前启用的匹配问卷；历史答卷保留。'),
                TextButton(
                  onPressed: () => context.go(AppRouteNames.questionnaire),
                  child: const Text('补答匹配问卷'),
                ),
              ],
              TextButton(
                onPressed: () => ref.invalidate(operationalStatusProvider),
                child: const Text('刷新运营资格'),
              ),
            ],
          );
        },
      ),
    );
  }
}
