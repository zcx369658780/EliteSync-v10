class RegisterFormState {
  const RegisterFormState({
    this.phone = '',
    this.password = '',
    this.nickname = '',
    this.isAgreementAccepted = false,
    this.isSubmitting = false,
    this.submitError,
    this.successMessage,
  });

  final String phone;
  final String password;
  final String nickname;
  final bool isAgreementAccepted;
  final bool isSubmitting;
  final String? submitError;
  final String? successMessage;

  bool get isPhoneValid => RegExp(r'^1\d{10}$').hasMatch(phone);
  // Match Laravel Password::min(8)->letters()->numbers().
  static final _letter = RegExp(r'\p{L}', unicode: true);
  static final _number = RegExp(r'\p{N}', unicode: true);
  bool get isPasswordValid =>
      password.runes.length >= 8 &&
      _letter.hasMatch(password) &&
      _number.hasMatch(password);
  bool get canSubmit =>
      isPhoneValid && isPasswordValid && isAgreementAccepted && !isSubmitting;

  RegisterFormState copyWith({
    String? phone,
    String? password,
    String? nickname,
    bool? isAgreementAccepted,
    bool? isSubmitting,
    String? submitError,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return RegisterFormState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      isAgreementAccepted: isAgreementAccepted ?? this.isAgreementAccepted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearError ? null : (submitError ?? this.submitError),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}
