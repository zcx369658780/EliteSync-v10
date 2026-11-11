import 'package:flutter_elitesync_module/features/profile/avatar/authenticated_avatar.dart';
import 'package:flutter/material.dart';

class ProfileProjectionCard extends StatelessWidget {
  const ProfileProjectionCard({super.key, required this.projection});
  final Map projection;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('应用公开 ID：${projection['public_id'] ?? '暂不可见'}'),
          if (projection['avatar'] is Map)
            AuthenticatedAvatar(
              ownerId:
                  int.tryParse('${projection['avatar']['owner_user_id']}') ?? 0,
              revision: int.tryParse('${projection['avatar']['revision']}'),
            )
          else
            const Icon(Icons.person_outline),
          for (final entry in const {
            'birthday': '生日',
            'interests': '喜好',
            'resume': '履历',
            'zodiac': '星座',
          }.entries)
            Text(
              '${entry.value}：${projection.containsKey(entry.key) ? projection[entry.key] ?? '未填写' : '不可见'}',
            ),
        ],
      ),
    ),
  );
}

String relationshipStateLabel(Object? value) => switch ('$value') {
  'CN_NONE' || 'MC_NONE' => '尚未建立',
  'CN_PENDING' || 'MC_PENDING' => '等待对方确认',
  'CN_ACTIVE' || 'MC_ACTIVE' => '双方已确认',
  'CN_PAUSED' => '已暂停',
  'CN_CLOSED' => '已关闭',
  'CN_DECLINED' || 'MC_DECLINED' => '已拒绝',
  'CN_WITHDRAWN' || 'MC_WITHDRAWN' => '已撤回',
  'CN_EXPIRED' || 'MC_EXPIRED' => '已到期',
  'MC_REVOKED' => '已撤销',
  _ => '状态尚未确认',
};
