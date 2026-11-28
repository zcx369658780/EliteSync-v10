import 'package:flutter_elitesync_module/features/auth/presentation/state/register_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'registration checks Laravel letter, number and eight-character rules',
    () {
      bool valid(String password) =>
          RegisterFormState(password: password).isPasswordValid;
      expect(valid('Abc1234'), isFalse);
      expect(valid('Abc12345'), isTrue);
      expect(valid('abcdefghi'), isFalse);
      expect(valid('123456789'), isFalse);
      expect(valid('甲乙丙丁戊己庚１'), isTrue);
      expect(valid('a１😀😀😀'), isFalse);
    },
  );

  test('registration still requires a separate agreement choice', () {
    const state = RegisterFormState(phone: '10000061201', password: 'Abc12345');
    expect(state.canSubmit, isFalse);
    expect(state.copyWith(isAgreementAccepted: true).canSubmit, isTrue);
  });
}
