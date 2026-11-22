import 'package:flutter_elitesync_module/main_prod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'remote Staging requires the compiled HTTPS host and matching bootstrap',
    () {
      const host = 'stage.edge.test';
      const origin = 'https://stage.edge.test/';
      expect(
        resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': origin},
          functionBuild: true,
          remoteStagingBuild: true,
          remoteStagingHost: host,
          compiledOrigin: origin,
        ),
        origin,
      );
      for (final value in [
        '',
        'http://stage.edge.test/',
        'https://other.edge.test/',
        'https://127.0.0.1:18446/',
      ]) {
        expect(
          () => resolveApiBaseUrl(
            hostBootstrap: {'apiBaseUrl': value},
            functionBuild: true,
            remoteStagingBuild: true,
            remoteStagingHost: host,
            compiledOrigin: origin,
          ),
          throwsStateError,
        );
      }
    },
  );

  test('remote Staging rejects unsafe hosts even when both origins agree', () {
    for (final host in [
      '',
      'slowdate.top',
      '127.0.0.1',
      'stage.edge.test:443',
      'stage.edge.test/path',
    ]) {
      final origin = 'https://$host/';
      expect(
        () => resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': origin},
          functionBuild: true,
          remoteStagingBuild: true,
          remoteStagingHost: host,
          compiledOrigin: origin,
        ),
        throwsStateError,
      );
    }
  });

  test('public IP Staging requires identical compiled and native origins', () {
    const ip = '8.8.4.4';
    const origin = 'https://8.8.4.4/';
    String resolve(String native, String compiled, {String host = ''}) =>
        resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': native},
          functionBuild: true,
          remoteStagingBuild: true,
          remoteStagingIp: ip,
          remoteStagingHost: host,
          compiledOrigin: compiled,
        );

    expect(resolve(origin, origin), origin);
    for (final invalid in [
      '',
      'http://8.8.4.4/',
      'https://8.8.4.4:443/',
      'https://8.8.4.4/path',
      'https://8.8.4.5/',
      'https://127.0.0.1:18446/',
      'https://slowdate.top/',
    ]) {
      expect(() => resolve(invalid, origin), throwsStateError);
      expect(() => resolve(origin, invalid), throwsStateError);
    }
    expect(
      () => resolve(origin, origin, host: 'stage.edge.test'),
      throwsStateError,
    );
  });

  test('IP Staging rejects private, special-use and ambiguous addresses', () {
    for (final ip in [
      '0.0.0.0',
      '10.1.2.3',
      '100.64.0.1',
      '127.0.0.1',
      '169.254.1.1',
      '172.16.0.1',
      '192.0.0.9',
      '192.0.2.1',
      '192.88.99.1',
      '192.168.1.1',
      '198.18.0.1',
      '198.51.100.1',
      '203.0.113.1',
      '224.0.0.1',
      '255.255.255.255',
      '008.8.4.4',
      '8.8.4.256',
      '8.8.4',
      '[2001:4860:4860::8844]',
    ]) {
      final origin = 'https://$ip/';
      expect(
        () => resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': origin},
          functionBuild: true,
          remoteStagingBuild: true,
          remoteStagingIp: ip,
          compiledOrigin: origin,
        ),
        throwsStateError,
        reason: ip,
      );
    }
  });

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
