import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/auth/data/dto/login_response_dto.dart';
import 'package:flutter_elitesync_module/features/auth/data/mapper/auth_mapper.dart';

void main() {
  const mapper = AuthMapper();

  test('toSession normalizes admin role with whitespace and case', () {
    final session = mapper.toSession(
      const LoginResponseDto(
        ok: true,
        accessToken: 'token',
        user: {'id': 8, 'phone': '13772423130', 'role': ' Admin '},
      ),
    );

    expect(session.user.role, 'admin');
  });

  test('toSession recognizes admin group fallback', () {
    final session = mapper.toSession(
      const LoginResponseDto(
        ok: true,
        accessToken: 'token',
        user: {'id': 8, 'phone': '13772423130', 'group': 'admin'},
      ),
    );

    expect(session.user.role, 'admin');
  });

  test('toSession keeps ordinary role ordinary', () {
    final session = mapper.toSession(
      const LoginResponseDto(
        ok: true,
        accessToken: 'token',
        user: {
          'id': 7,
          'phone': '17094346566',
          'role': 'user',
          'group': 'normal',
        },
      ),
    );

    expect(session.user.role, 'user');
  });
}
