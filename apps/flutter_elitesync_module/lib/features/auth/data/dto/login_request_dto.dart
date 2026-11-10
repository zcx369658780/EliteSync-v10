class LoginRequestDto {
  const LoginRequestDto({
    required this.phone,
    required this.password,
    this.deviceId,
  });

  final String phone;
  final String password;
  final String? deviceId;

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
      if (deviceId != null) 'device_id': deviceId,
    };
  }
}
