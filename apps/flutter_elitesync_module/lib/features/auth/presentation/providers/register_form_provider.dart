import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/models/user_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/providers/auth_guard_provider.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/state/register_form_state.dart';

class RegisterFormNotifier extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() => const RegisterFormState();

  void onPhoneChanged(String value) {
    state = state.copyWith(
      phone: value.trim(),
      clearError: true,
      clearSuccess: true,
    );
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(
      password: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void onNicknameChanged(String value) {
    state = state.copyWith(
      nickname: value.trim(),
      clearError: true,
      clearSuccess: true,
    );
  }

  void onAgreementChanged(bool value) {
    state = state.copyWith(
      isAgreementAccepted: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<bool> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(submitError: '请先填写正确手机号、密码并勾选协议');
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    final sessionNotifier = ref.read(sessionProvider.notifier);
    final intent = sessionNotifier.beginAuthentication();
    try {
      final session = await ref
          .read(registerUseCaseProvider)
          .call(
            phone: state.phone,
            password: state.password,
            nickname: state.nickname.isEmpty ? null : state.nickname,
          );

      if (!sessionNotifier.isCurrentAuthentication(intent)) return false;
      ref.read(registrationWelcomeProvider.notifier).set(true);
      await sessionNotifier.setAuthenticated(
        expectedIntent: intent,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        user: UserSummary(
          id: session.user.id,
          phone: session.user.phone,
          nickname: session.user.nickname,
          role: session.user.role,
        ),
      );
      if (!sessionNotifier.isCurrentAuthentication(intent)) return false;
      state = state.copyWith(isSubmitting: false, successMessage: '注册成功');
      return true;
    } catch (e) {
      final msg = ref.read(authErrorMapperProvider).mapToUserMessage(e);
      state = state.copyWith(isSubmitting: false, submitError: msg);
      return false;
    }
  }
}

final registerFormProvider =
    NotifierProvider<RegisterFormNotifier, RegisterFormState>(
      RegisterFormNotifier.new,
    );

class RegistrationWelcome extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final registrationWelcomeProvider = NotifierProvider<RegistrationWelcome, bool>(
  RegistrationWelcome.new,
);
