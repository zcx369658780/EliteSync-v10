import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/edit_profile_ui_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

const _detail = ProfileDetailEntity(
  nickname: '虚构',
  gender: 'male',
  birthday: '2000-01-01',
  birthTime: '12:00',
  city: '开发城市',
  target: 'dating',
  birthPlace: '已保存地点',
  birthLat: 31.2,
  birthLng: 121.5,
);

class _Edit extends EditProfileNotifier {
  ProfileDetailEntity? submitted;
  @override
  Future<EditProfileUiState> build() async =>
      const EditProfileUiState(detail: _detail);
  @override
  Future<ProfileDetailEntity> save(ProfileDetailEntity detail) async {
    submitted = detail;
    return detail;
  }
}

class _UnknownTimeEdit extends _Edit {
  final response = Completer<ProfileDetailEntity>();

  @override
  Future<EditProfileUiState> build() async => const EditProfileUiState(
    detail: ProfileDetailEntity(
      nickname: '虚构',
      gender: 'male',
      birthday: '2000-01-01',
      birthTime: '',
      city: '开发城市',
      target: 'dating',
      birthPlace: '已保存地点',
      birthLat: 31.2,
      birthLng: 121.5,
    ),
  );

  @override
  Future<ProfileDetailEntity> save(ProfileDetailEntity detail) async {
    submitted = detail;
    state = AsyncData(EditProfileUiState(detail: detail, saving: true));
    return response.future;
  }
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  for (final localRestoration in [true, false]) {
    testWidgets('explains account-only saving, local=$localRestoration', (
      tester,
    ) async {
      final edit = _UnknownTimeEdit();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            editProfileProvider.overrideWith(() => edit),
            appEnvProvider.overrideWithValue(
              AppEnv(
                flavor: AppFlavor.dev,
                appName: '开发',
                apiBaseUrl: 'http://localhost',
                useMockData: false,
                restorationLocalBuild: localRestoration,
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const EditProfilePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('仅保存基础资料，不会重新排盘'), findsOneWidget);
      expect(find.textContaining('默认午时'), findsNothing);
      final save = find.byKey(const ValueKey('profile-save-full'));
      await _reveal(tester, save);
      expect(find.text('保存基础资料'), findsOneWidget);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('出生时间将保持未知。是否继续保存基础资料？'), findsOneWidget);
      expect(edit.submitted, isNull);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(edit.submitted, isNull);
      await tester.tap(save);
      await tester.pumpAndSettle();
      await tester.tap(find.text('继续保存'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(edit.submitted?.birthTime, '');
      final saving = find.text('正在保存基础资料', skipOffstage: false);
      // Scroll back while the save is in flight. A loading indicator animates.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 1800));
      await tester.pump(const Duration(milliseconds: 400));
      expect(saving, findsOneWidget);
      expect(find.textContaining('自动触发'), findsNothing);
      edit.response.complete(edit.submitted);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('基础资料已保存，出生时间保持未知。'), findsOneWidget);
    });
  }
  for (final valid in [true, false]) {
    testWidgets(
      'local manual birth input persists or rejects invalid coordinates valid=$valid',
      (tester) async {
        final edit = _Edit();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              editProfileProvider.overrideWith(() => edit),
              appEnvProvider.overrideWithValue(
                const AppEnv(
                  flavor: AppFlavor.dev,
                  appName: '开发',
                  apiBaseUrl: 'http://localhost',
                  useMockData: false,
                  restorationLocalBuild: true,
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const EditProfilePage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final place = find.descendant(
          of: find.byKey(const ValueKey('profile-local-birth-place')),
          matching: find.byType(TextField),
        );
        await _reveal(tester, place);
        expect(tester.widget<TextField>(place).controller?.text, '已保存地点');
        await tester.enterText(place, '手工地点');
        final lat = find.descendant(
          of: find.byKey(const ValueKey('profile-local-birth-lat')),
          matching: find.byType(TextField),
        );
        await _reveal(tester, lat);
        expect(tester.widget<TextField>(lat).controller?.text, '31.2');
        await tester.enterText(lat, valid ? '30.25' : 'NaN');
        final lng = find.descendant(
          of: find.byKey(const ValueKey('profile-local-birth-lng')),
          matching: find.byType(TextField),
        );
        await _reveal(tester, lng);
        await tester.enterText(lng, '120.5');
        final save = find.byKey(const ValueKey('profile-save-full'));
        await _reveal(tester, save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        if (valid) {
          expect(edit.submitted?.birthPlace, '手工地点');
          expect(edit.submitted?.birthLat, 30.25);
          expect(edit.submitted?.birthLng, 120.5);
          expect(find.text('基础资料已保存。'), findsOneWidget);
        } else {
          expect(edit.submitted, isNull);
          expect(find.textContaining('纬度'), findsWidgets);
        }
        expect(find.text('搜索出生地'), findsNothing);
      },
    );
  }
}
