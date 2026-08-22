import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/personal_showcase_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses compact display-only status labels', () {
    expect(ShowcaseItemStatus.completed.label, '已确认');
    expect(ShowcaseItemStatus.available.label, '可补充');
    expect(ShowcaseItemStatus.empty.label, '可补充');
    expect(ShowcaseItemStatus.later.label, '稍后处理');
  });

  test('maps internal dating target to user-safe Personal Showcase copy', () {
    const detail = ProfileDetailEntity(
      nickname: '星语者',
      gender: 'female',
      birthday: '1998-11-25',
      birthTime: '20:30',
      city: '南阳市',
      target: 'dating',
    );

    final snapshot = PersonalShowcaseSnapshot.fromProfile(
      summary: const ProfileSummaryEntity(
        nickname: '星语者',
        birthday: '1998-11-25',
        birthTime: '20:30',
        birthPlace: '南阳',
        city: '南阳市',
        target: 'dating',
        verified: true,
        moderationStatus: 'normal',
        moderationNote: null,
        completion: 0.78,
        tags: ['ENFJ'],
      ),
      detail: detail,
    );

    expect(snapshot.previewLines.join('\n'), isNot(contains('dating')));
    expect(snapshot.relationshipGoalLabel, '慢约会');
    expect(snapshot.readinessTitle, isNot(contains('dating')));
    expect(snapshot.readinessTitle, startsWith('资料完善提示'));
    expect(snapshot.readinessHelper, contains('只是本地整理提示'));
    for (final forbidden in ['审核通过', '已经发布', '对外可见', '匹配资格已开启']) {
      expect(
        '${snapshot.readinessTitle}\n${snapshot.readinessHelper}',
        isNot(contains(forbidden)),
      );
    }
    expect(snapshot.localDraft.title, '先整理一版资料草稿');
    expect(snapshot.localDraft.helper, contains('本地草稿'));
    expect(snapshot.localDraft.helper, contains('待你确认'));
    expect(snapshot.localDraft.lines.join('\n'), contains('关系目标：慢约会'));
    expect(snapshot.localDraft.boundary, contains('本地草稿'));
    expect(snapshot.localDraft.boundary, contains('尚未保存'));
    expect(snapshot.localDraft.boundary, contains('不会自动发送'));
    expect(snapshot.localDraft.boundary, contains('不会直接写入正式资料'));
    expect(snapshot.localDraft.boundary, contains('不会自动改推荐权重'));
    expect(snapshot.localDraft.boundary, contains('正式提交前还需要安全检查'));
    expect(snapshot.checklist.map((item) => item.title).toList(), [
      '自我介绍',
      '关系目标',
      '兴趣标签',
      '生活方式',
      '照片/头像',
      '星盘 / 八字 / 紫微关系参考',
      '聊天开场表达建议',
    ]);
    expect(
      snapshot.checklist.firstWhere((item) => item.title == '关系目标').description,
      '当前目标：慢约会',
    );
    expect(
      snapshot.checklist
          .firstWhere((item) => item.title == '兴趣标签')
          .status
          .label,
      '已确认',
    );
    expect(
      snapshot.checklist
          .firstWhere((item) => item.title == '照片/头像')
          .status
          .label,
      '稍后处理',
    );
    expect(snapshot.previewLines.first, isNot(contains('dating')));
  });

  test('uses summary target when detail is not available', () {
    final snapshot = PersonalShowcaseSnapshot.fromProfile(
      summary: const ProfileSummaryEntity(
        nickname: '星语者',
        birthday: '1998-11-25',
        birthTime: '20:30',
        birthPlace: '南阳',
        city: '南阳市',
        target: 'dating',
        verified: true,
        moderationStatus: 'normal',
        moderationNote: null,
        completion: 0.78,
        tags: ['ENFJ', '慢热'],
      ),
    );

    expect(snapshot.relationshipGoalLabel, '慢约会');
    expect(snapshot.previewLines.join('\n'), isNot(contains('dating')));
    expect(snapshot.primaryMissingClue, isNotEmpty);
  });

  test(
    'local draft preview avoids misleading persistence and safety claims',
    () {
      final snapshot = PersonalShowcaseSnapshot.fromProfile(
        summary: const ProfileSummaryEntity(
          nickname: '星语者',
          birthday: '1998-11-25',
          birthTime: '20:30',
          birthPlace: '南阳',
          city: '',
          target: '',
          verified: true,
          moderationStatus: 'normal',
          moderationNote: null,
          completion: 0.34,
          tags: [],
        ),
      );

      final draftText = [
        snapshot.localDraft.title,
        snapshot.localDraft.helper,
        ...snapshot.localDraft.lines,
        snapshot.localDraft.boundary,
      ].join('\n');

      expect(draftText, contains('先整理一版资料草稿'));
      expect(draftText, contains('本地草稿'));
      expect(draftText, contains('待你确认'));
      expect(draftText, contains('后续可基于你的确认生成展示标签'));

      for (final forbidden in [
        '已保存到服务端',
        '已保存',
        '已同步',
        '已提交审核',
        '已通过内容安全',
        '已生成真实标签',
        '已更新推荐权重',
        '算法已学习',
        '资料已生效',
        '永久保存',
      ]) {
        expect(draftText, isNot(contains(forbidden)));
      }
    },
  );
}
