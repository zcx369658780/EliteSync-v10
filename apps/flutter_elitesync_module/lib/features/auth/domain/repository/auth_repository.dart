import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login({required String phone, required String password});

  Future<AuthSession> register({
    required String phone,
    required String password,
    String? nickname,
  });

  Future<void> logout();
}
