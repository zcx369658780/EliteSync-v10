import 'dart:math';
import 'package:flutter/material.dart';

Map<String, dynamic> objectMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

String requestKey() {
  final random = Random.secure();
  return List.generate(
    24,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

class IdentityGateCard extends StatelessWidget {
  const IdentityGateCard({super.key, required this.identity});
  final Map<String, dynamic> identity;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            identity['status'] == 'DEV_SYNTHETIC_VERIFIED'
                ? 'TEST_ONLY · 合成开发身份凭据'
                : '实人核验供应商未配置 / 当前未核验',
          ),
          const Text('运营审核不等于实人核验。合成凭据不证明真实身份；正式关系激活由服务器核对双方有效凭据与逐次确认。'),
          if (identity['expires_at'] != null)
            Text('凭据有效期至：${identity['expires_at']}'),
        ],
      ),
    ),
  );
}

String journeyStateLabel(Object? state) => switch ('$state'.toUpperCase()) {
  'NOT_ENROLLED' => '尚未报名',
  'ACTIVE' => '已参与 / 生效',
  'PAUSED' => '已暂停',
  'EXITED' => '已退出',
  'NO_ROUND' => '当前没有活动轮次',
  'SCHEDULED' => '等待轮次开始',
  'PREPARING' => '轮次准备中',
  'RUNNING' => '本轮处理中',
  'REVEALED' => '本轮已揭晓',
  'NO_CANDIDATE' => '本轮暂无候选，不代表被拒绝',
  'FAILED' => '轮次处理失败，可刷新查看恢复状态',
  'CLOSED' => '本轮已关闭',
  'PENDING' || 'PENDING_MUTUAL' => '等待双方独立回应',
  'ACCEPTED_BY_ONE' => '已有一方接受，等待另一方独立回应',
  'ACCEPTED_BY_ME' => '你已接受，等待对方回应',
  'MUTUALLY_ACCEPTED' => '双方已选择，连接与消息同意仍需独立确认',
  'DECLINED' => '已拒绝',
  'WITHDRAWN' => '已撤回',
  'EXPIRED' => '已到期',
  'ENDED' => '已结束，旧关系不可恢复',
  'SUSPENDED_REVERIFY' => '核验失效，分享已暂停，需双方重新确认',
  _ => '状态暂未确认',
};

String decisionLabel(Object? decision) =>
    decision == 'ACCEPTED' ? '已接受' : '尚未回应';
String preparationReasonLabel(Object? reason) => switch ('$reason') {
  'eligible' => '已完成当前必要准备，可自行决定是否参与',
  'questionnaire_incomplete' => '请先完成必要问卷',
  'questionnaire_unavailable' => '问卷暂不可用，请稍后再试',
  'account_disabled' ||
  'account_restricted' ||
  'account_state_unavailable' => '当前账号不可参与，请查看账号状态',
  'operational_review_pending' => '运营参与资格正在审核，非实人认证',
  'operational_review_rejected' => '运营参与资格尚未通过，请查看审核结果',
  _ => '当前暂不符合参与条件，请检查准备状态或稍后刷新',
};
