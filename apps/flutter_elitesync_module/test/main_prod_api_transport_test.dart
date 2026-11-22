import 'package:flutter_elitesync_module/main_prod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const stagingLogin = bool.fromEnvironment('ELITESYNC_V2_STAGING_LOGIN_BUILD');
  const expectedOrigin = stagingLogin
      ? 'https://127.0.0.1:18446/'
      : 'https://127.0.0.1:18444/';
  const otherOrigin = stagingLogin
      ? 'https://127.0.0.1:18444/'
      : 'https://127.0.0.1:18446/';

  test('function bootstrap accepts only the selected loopback endpoint', () {
    expect(
      resolveApiBaseUrl(
        hostBootstrap: {'apiBaseUrl': expectedOrigin},
        functionBuild: true,
        compiledOrigin: expectedOrigin,
      ),
      expectedOrigin,
    );
    for (final origin in ['', otherOrigin, 'https://slowdate.top/']) {
      expect(
        () => resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': origin},
          functionBuild: true,
          compiledOrigin: expectedOrigin,
        ),
        throwsStateError,
      );
    }
    expect(
      () => resolveApiBaseUrl(
        hostBootstrap: {'apiBaseUrl': otherOrigin},
        functionBuild: true,
        compiledOrigin: otherOrigin,
      ),
      throwsStateError,
    );
  });

  test('default entry matches the host secure API configuration', () {
    expect(resolveApiBaseUrl(hostBootstrap: {}), 'https://slowdate.top/');
  });

  test('configured HTTPS keeps its path and normalizes the trailing slash', () {
    expect(
      resolveApiBaseUrl(
        hostBootstrap: {'apiBaseUrl': ' https://api.example.invalid/base '},
      ),
      'https://api.example.invalid/base/',
    );
  });

  test('ordinary entry rejects public HTTP and ambiguous URL components', () {
    for (final value in [
      'http://api.example.invalid/',
      'https://user:password@api.example.invalid/',
      'https://api.example.invalid/?endpoint=other',
      'https://api.example.invalid/#other',
    ]) {
      expect(
        () => resolveApiBaseUrl(hostBootstrap: {'apiBaseUrl': value}),
        throwsFormatException,
      );
    }
  });

  test('development HTTP exception is local and never enables public HTTP', () {
    expect(
      resolveApiBaseUrl(
        hostBootstrap: {'apiBaseUrl': 'http://127.0.0.1:8021/'},
        allowLocalInsecure: true,
      ),
      'http://127.0.0.1:8021/',
    );
    expect(
      () => resolveApiBaseUrl(
        hostBootstrap: {'apiBaseUrl': 'http://127.0.0.1:8021/'},
      ),
      throwsFormatException,
    );
    expect(
      () => resolveApiBaseUrl(
        hostBootstrap: {'apiBaseUrl': 'http://external.invalid/'},
        allowLocalInsecure: true,
      ),
      throwsFormatException,
    );
  });
}
