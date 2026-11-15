import '../dto/login_response_dto.dart';
import 'package:flutter_elitesync_module/core/error/app_exception.dart';
import 'package:flutter_elitesync_module/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:flutter_elitesync_module/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/auth/data/dto/login_request_dto.dart';
import 'package:flutter_elitesync_module/features/auth/data/dto/register_request_dto.dart';
import 'package:flutter_elitesync_module/features/auth/data/mapper/auth_mapper.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_elitesync_module/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required AuthMapper mapper,
  }) : _remote = remote,
       _local = local,
       _mapper = mapper;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final AuthMapper _mapper;

  @override
  Future<AuthSession> login({
    required String phone,
    required String password,
  }) async {
    return _authenticate(
      (deviceId) => _remote.login(
        LoginRequestDto(phone: phone, password: password, deviceId: deviceId),
      ),
    );
  }

  Future<AuthSession> _authenticate(
    Future<LoginResponseDto> Function(String) request,
  ) async {
    final loginEpoch = _local.beginLoginAttempt();
    await _local.prepareLoginAttempt(loginEpoch);
    final deviceId = await _local.getOrCreateDeviceId();
    if (!_local.isCurrentAttempt(loginEpoch)) {
      throw const ValidationException(
        '登录已变化，请重新操作。',
        code: 'AUTH_STALE_RESPONSE',
      );
    }
    final response = await request(deviceId);
    if (!_local.isCurrentAttempt(loginEpoch)) {
      throw const ValidationException(
        '登录已变化，请重新操作。',
        code: 'AUTH_STALE_RESPONSE',
      );
    }

    if (!response.ok) {
      throw ValidationException(
        response.message ?? '登录失败',
        code: response.code,
      );
    }

    final session = _mapper.toSession(response);
    if (session.accessToken.isEmpty) {
      throw const ValidationException('登录失败，令牌为空', code: 'AUTH_EMPTY_TOKEN');
    }

    await _local.persistSession(
      session,
      retention: response.sessionRetention,
      expectedEpoch: loginEpoch,
      expectedDeviceId: deviceId,
    );
    if (!_local.isCurrentAttempt(loginEpoch)) {
      throw const ValidationException(
        '登录已变化，请重新操作。',
        code: 'AUTH_STALE_RESPONSE',
      );
    }
    return session;
  }

  @override
  Future<AuthSession> register({
    required String phone,
    required String password,
    String? nickname,
  }) {
    return _authenticate(
      (deviceId) => _remote.register(
        RegisterRequestDto(
          phone: phone,
          password: password,
          passwordConfirmation: password,
          realnameVerified: false,
          deviceId: deviceId,
          nickname: nickname,
        ),
      ),
    );
  }

  @override
  Future<void> logout() async {
    _local.cancelPendingLogin();
    try {
      await _remote.logout();
    } finally {
      await _local.clearSession();
    }
  }
}
