import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/config/rtc_endpoint_policy.dart';
import 'package:flutter_test/flutter_test.dart';

AppEnv _env({bool dev = false, String api = 'https://api.example.com'}) =>
    AppEnv(
      flavor: dev ? AppFlavor.dev : AppFlavor.prod,
      appName: 'RTC endpoint test',
      apiBaseUrl: api,
      useMockData: false,
    );

void main() {
  test('secure SFU may use a separate host and preserves gateway path', () {
    for (final gateway in [
      'wss://sfu.example.com',
      'wss://sfu.example.com:7443/rtc/gateway',
      'wss://sfu.example.com/rtc/gateway/',
      'wss://sfu.example.com/rtc/a%2Fb',
    ]) {
      expect(validateRtcGatewayUrl(gateway, env: _env()), gateway);
      expect(validateRtcGatewayUrl(gateway, env: _env(dev: true)), gateway);
    }
  });

  for (final host in ['127.0.0.1', 'localhost', '[::1]', '10.0.2.2']) {
    test('dev $host permits different local API and SFU ports', () {
      final gateway = 'ws://$host:7880/rtc/gateway';
      expect(
        validateRtcGatewayUrl(
          gateway,
          env: _env(dev: true, api: 'http://$host:8021'),
        ),
        gateway,
      );
      expect(
        () =>
            validateRtcGatewayUrl(gateway, env: _env(api: 'http://$host:8021')),
        throwsFormatException,
      );
    });
  }

  for (final api in [
    'https://127.0.0.1:8021',
    'http://localhost:8021',
    'http://10.0.2.2:8021',
    'http://api.example.com:8021',
    'http://127.0.0.1:8021?credential=synthetic',
  ]) {
    test('plaintext gateway rejected for mismatching/insecure API $api', () {
      expect(
        () => validateRtcGatewayUrl(
          'ws://127.0.0.1:7880',
          env: _env(dev: true, api: api),
        ),
        throwsFormatException,
      );
    });
  }

  for (final gateway in [
    '',
    '/rtc',
    'https://sfu.example.com',
    'http://127.0.0.1:7880',
    'ftp://sfu.example.com',
    'ws://sfu.example.com',
    'ws://127.0.0.2:7880',
    'ws://localhost.evil.invalid:7880',
    'wss:///rtc',
    'wss://user:synthetic-secret@sfu.example.com',
    'wss://@sfu.example.com',
    'wss://sfu.example.com:',
    'wss://sfu.example.com:0',
    'wss://sfu.example.com:65536',
    'wss://sfu.example.com:wrong',
    'wss://sfu.example.com?token=synthetic',
    'wss://sfu.example.com#fragment',
    r'wss://sfu.example.com\other',
  ]) {
    test('reject malformed or insecure gateway $gateway', () {
      expect(
        () => validateRtcGatewayUrl(
          gateway,
          env: _env(dev: true, api: 'http://127.0.0.1:8021'),
        ),
        throwsFormatException,
      );
    });
  }

  test('validation errors do not retain credential-bearing input', () {
    const gateway = 'wss://user:synthetic-secret@sfu.example.com:wrong';
    try {
      validateRtcGatewayUrl(gateway, env: _env());
      fail('Expected invalid gateway rejection');
    } on FormatException catch (error) {
      expect(error.source, isNull);
      expect(error.toString(), isNot(contains('synthetic-secret')));
      expect(error.toString(), isNot(contains('sfu.example.com')));
    }
  });
}
