import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/state/edit_profile_ui_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const detail = ProfileDetailEntity(
  nickname: '虚构用户',
  gender: 'male',
  birthday: '2000-01-01',
  birthTime: '12:00',
  city: '旧城市',
  target: 'dating',
);

class _Edit extends EditProfileNotifier {
  int citySaves = 0;
  int fullSaves = 0;
  String? submitted;
  bool fail = false;
  @override
  Future<EditProfileUiState> build() async =>
      const EditProfileUiState(detail: detail);
  @override
  Future<ProfileDetailEntity> saveCity(String city) async {
    citySaves++;
    submitted = city;
    if (fail) throw Exception('账号已禁用');
    return detail;
  }

  @override
  Future<ProfileDetailEntity> save(ProfileDetailEntity value) async {
    fullSaves++;
    return value;
  }
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  for (final fail in [false, true]) {
    testWidgets(
      'independent city button preserves full action, failure=$fail',
      (tester) async {
        final notifier = _Edit()..fail = fail;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [editProfileProvider.overrideWith(() => notifier)],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const EditProfilePage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final field = find.descendant(
          of: find.byKey(const ValueKey('profile-city-field')),
          matching: find.byType(TextField),
        );
        await reveal(tester, field);
        await tester.enterText(field, '新城市');
        final button = find.byKey(const ValueKey('profile-save-city'));
        await reveal(tester, button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(notifier.citySaves, 1);
        expect(notifier.submitted, '新城市');
        expect(notifier.fullSaves, 0);
        expect(
          find.text('城市已保存，并已从服务端读回确认'),
          fail ? findsNothing : findsOneWidget,
        );
        if (fail) expect(find.textContaining('账号已禁用'), findsOneWidget);
        final full = find.widgetWithText(AppPrimaryButton, '保存并重算');
        await reveal(tester, full);
        await tester.tap(full);
        await tester.pumpAndSettle();
        expect(notifier.fullSaves, 1);
        expect(notifier.citySaves, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
