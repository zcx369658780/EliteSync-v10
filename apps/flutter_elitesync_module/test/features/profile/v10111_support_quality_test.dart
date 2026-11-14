import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/feedback/presentation/pages/inner_test_feedback_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/account_recovery_help_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/change_password_page.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/features/slow_dating_v1012/relationship_privacy_page.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    user: UserSummary(id: 101, phone: ''),
    accessToken: 'fictional-first',
  );

  void change({bool sameOwner = false}) => state = AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      user: UserSummary(id: sameOwner ? 101 : 202, phone: ''),
      accessToken: 'fictional-next',
    ),
  );
}

class _Relationship extends RelationshipApi {
  _Relationship(this.handle) : super(ApiClient(dio: Dio()));
  final Future<Map<String, dynamic>> Function(
    String,
    String,
    Map<String, dynamic>?,
  )
  handle;
  final List<Map<String, dynamic>> commands = [];

  @override
  Future<Map<String, dynamic>> call(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) {
    commands.add({
      'method': method,
      'path': path,
      'body': body == null ? null : jsonDecode(jsonEncode(body)),
    });
    return handle(method, path, body);
  }
}

class _Api extends ApiClient {
  _Api(this.handle) : super(dio: Dio());
  final Future<NetworkResult<Map<String, dynamic>>> Function(String, Object?)
  handle;
  final List<Object?> bodies = [];

  @override
  Future<NetworkResult<Map<String, dynamic>>> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    bodies.add(body);
    return handle(path, body);
  }

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    CancelToken? cancelToken,
    Map<String, dynamic>? query,
    Options? options,
  }) => handle(path, null);
}

Map<String, dynamic> _list(int id, {int? cursor}) => {
  'items': [
    {'id': id, 'status': 'OPEN', 'updated_at': 'fictional-time'},
  ],
  'next_before_id': cursor,
};
Map<String, dynamic> _detail(int id, String content) => {
  'feedback': {
    'id': id,
    'status': 'OPEN',
    'revision': 1,
    'content': content,
    'updates': <dynamic>[],
  },
};
Map<String, dynamic> _privacy(String resume) => {
  'revision': 0,
  'self_profile': {'resume': resume},
  'fields': {
    'birthday': 'SELF',
    'interests': 'SELF',
    'resume': 'SELF',
    'zodiac': 'SELF',
  },
};

Future<ProviderContainer> _show(
  WidgetTester tester,
  Widget page, {
  _Relationship? relationship,
  _Api? api,
}) async {
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      sessionProvider.overrideWith(_Session.new),
      if (relationship != null)
        relationshipApiProvider.overrideWithValue(relationship),
      if (api != null) apiClientProvider.overrideWithValue(api),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light, home: page),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
  return container;
}

Future<void> _click(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets(
    'feedback unknown result retries immutable command and preserves subsequent editing',
    (tester) async {
      var posts = 0;
      final api = _Relationship((method, path, body) async {
        if (method == 'POST') {
          posts++;
          if (posts == 1) {
            throw const RelationshipFailure('unavailable', statusCode: 503);
          }
          return _detail(9, body!['content'] as String);
        }
        if (path.endsWith('/9')) return _detail(9, 'original fictional input');
        return {'items': <dynamic>[], 'next_before_id': null};
      });
      await _show(
        tester,
        const InnerTestFeedbackPage(sourceSurface: 'settings'),
        relationship: api,
      );
      await tester.enterText(
        find.byType(TextField).first,
        'original fictional input',
      );
      await _click(tester, find.byKey(const Key('support-submit')));
      expect(find.textContaining('提交结果尚未确认'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField).first,
        'subsequent legal draft',
      );
      await _click(tester, find.byKey(const Key('support-submit')));
      final commands = api.commands
          .where((row) => row['method'] == 'POST')
          .toList();
      expect(commands, hasLength(2));
      expect(commands[0]['body'], commands[1]['body']);
      expect(find.text('提交回执 #9 已确认。'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'subsequent legal draft',
      );
    },
  );

  testWidgets('POST alone is insufficient when persisted receipt read fails', (
    tester,
  ) async {
    final api = _Relationship((method, path, body) async {
      if (method == 'POST') return _detail(9, body!['content'] as String);
      if (path.endsWith('/9')) {
        throw const RelationshipFailure('unavailable', statusCode: 503);
      }
      return {'items': <dynamic>[], 'next_before_id': null};
    });
    await _show(tester, const InnerTestFeedbackPage(), relationship: api);
    await tester.enterText(
      find.byType(TextField).first,
      'legal fictional input',
    );
    await _click(tester, find.byKey(const Key('support-submit')));
    expect(find.textContaining('提交结果尚未确认'), findsOneWidget);
    expect(find.text('提交回执 #9 已确认。'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'legal fictional input',
    );
  });

  for (final status in [403, 503]) {
    testWidgets(
      'displayed feedback pagination$status handles current permission and network separately',
      (tester) async {
        final api = _Relationship((method, path, body) async {
          if (path.contains('before_id=')) {
            throw RelationshipFailure('failure', statusCode: status);
          }
          return _list(12, cursor: 12);
        });
        await _show(tester, const InnerTestFeedbackPage(), relationship: api);
        await tester.enterText(find.byType(TextField).first, 'legal draft');
        expect(find.textContaining('反馈 #12'), findsOneWidget);
        await _click(tester, find.text('加载更早反馈'));
        expect(
          find.textContaining('反馈 #12'),
          status == 403 ? findsNothing : findsOneWidget,
        );
        expect(
          find.text('加载更早反馈'),
          status == 403 ? findsNothing : findsOneWidget,
        );
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          'legal draft',
        );
        if (status == 503) {
          await _click(tester, find.text('加载更早反馈'));
          final reads = api.commands
              .where((row) => '${row['path']}'.contains('before_id='))
              .toList();
          expect(reads[0]['path'], reads[1]['path']);
        }
      },
    );
  }

  testWidgets(
    'old account delayed rejection cannot clear new feedback or retain old draft',
    (tester) async {
      final old = Completer<Map<String, dynamic>>();
      var reads = 0;
      final api = _Relationship((method, path, body) {
        reads++;
        return reads == 1 ? old.future : Future.value(_list(22));
      });
      final container = await _show(
        tester,
        const InnerTestFeedbackPage(),
        relationship: api,
      );
      await tester.enterText(
        find.byType(TextField).first,
        'old account private draft',
      );
      (container.read(sessionProvider.notifier) as _Session).change();
      await tester.pump();
      await tester.pump();
      old.completeError(
        const RelationshipFailure('old rejection', statusCode: 403),
      );
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('反馈 #22'), findsOneWidget);
      expect(find.textContaining('暂不能使用'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '',
      );
    },
  );

  testWidgets(
    'late rejection from an old authority cannot clear a fresh projection',
    (tester) async {
      final old = Completer<Map<String, dynamic>>();
      var reads = 0;
      final api = _Relationship((method, path, body) {
        reads++;
        return reads == 1 ? old.future : Future.value(_list(33));
      });
      final container = await _show(
        tester,
        const InnerTestFeedbackPage(),
        relationship: api,
      );
      await tester.enterText(
        find.byType(TextField).first,
        'legal current input',
      );
      container.read(relationshipAuthorityEpochProvider.notifier).state++;
      await tester.pump();
      await _click(tester, find.byKey(const Key('support-history')));
      old.completeError(
        const RelationshipFailure('old authority rejection', statusCode: 403),
      );
      await tester.pump();
      expect(find.textContaining('反馈 #33'), findsOneWidget);
      expect(find.textContaining('暂不能使用'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'legal current input',
      );
    },
  );

  testWidgets('same-owner credential refresh preserves legal feedback input', (
    tester,
  ) async {
    final api = _Relationship((method, path, body) async => _list(12));
    final container = await _show(
      tester,
      const InnerTestFeedbackPage(),
      relationship: api,
    );
    await tester.enterText(
      find.byType(TextField).first,
      'same account legal draft',
    );
    (container.read(sessionProvider.notifier) as _Session).change(
      sameOwner: true,
    );
    await tester.pump();
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'same account legal draft',
    );
  });

  testWidgets(
    'privacy refresh503 retains edited input and displayed settings',
    (tester) async {
      var reads = 0;
      final api = _Relationship((method, path, body) async {
        if (++reads == 1) return _privacy('original owner input');
        throw const RelationshipFailure('unavailable', statusCode: 503);
      });
      await _show(tester, const RelationshipPrivacyPage(), relationship: api);
      await tester.enterText(
        find.byKey(const Key('privacy-resume')),
        'edited legal input',
      );
      await tester.tap(find.byTooltip('刷新'));
      await tester.pump();
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('privacy-resume')))
            .controller!
            .text,
        'edited legal input',
      );
      expect(find.text('保存受众 / 撤回分享'), findsOneWidget);
    },
  );

  testWidgets(
    'password503 retains exact characters and never reports success',
    (tester) async {
      final api = _Api(
        (path, body) async =>
            const NetworkFailure(message: 'unavailable', statusCode: 503),
      );
      await _show(tester, const ChangePasswordPage(), api: api);
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), ' Original123 ');
      await tester.enterText(fields.at(1), ' Changed123 ');
      await tester.enterText(fields.at(2), ' Changed123 ');
      await _click(tester, find.text('保存新密码'));
      expect((api.bodies.single as Map)['new_password'], ' Changed123 ');
      expect(
        tester.widget<TextField>(fields.at(1)).controller!.text,
        ' Changed123 ',
      );
      expect(find.textContaining('修改结果尚未确认'), findsOneWidget);
    },
  );

  testWidgets(
    'password late success cannot sign out another account or show an old result',
    (tester) async {
      final pending = Completer<NetworkResult<Map<String, dynamic>>>();
      final api = _Api((path, body) => pending.future);
      final container = await _show(
        tester,
        const ChangePasswordPage(),
        api: api,
      );
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Original123');
      await tester.enterText(fields.at(1), 'Changed123');
      await tester.enterText(fields.at(2), 'Changed123');
      await _click(tester, find.text('保存新密码'));
      (container.read(sessionProvider.notifier) as _Session).change();
      await tester.pump();
      pending.complete(
        const NetworkSuccess({
          'ok': true,
          'status': 'PASSWORD_CHANGED_LOGIN_REQUIRED',
        }),
      );
      await tester.pump();
      await tester.pump();
      expect(container.read(sessionProvider).asData!.value.user!.id, 202);
      expect(tester.widget<TextField>(fields.at(1)).controller!.text, '');
      expect(find.textContaining('密码已更新'), findsNothing);
    },
  );

  testWidgets(
    'account help reflects unconfigured verification and offers existing receipt path',
    (tester) async {
      final api = _Api(
        (path, body) async => const NetworkSuccess({
          'password_recovery': {
            'available': false,
            'status': 'VERIFICATION_PROVIDER_NOT_CONFIGURED',
          },
        }),
      );
      await _show(tester, const AccountRecoveryHelpPage(), api: api);
      expect(find.textContaining('密码找回验证渠道尚未接入'), findsOneWidget);
      expect(find.text('查看本机注销处理回执'), findsOneWidget);
    },
  );
}
