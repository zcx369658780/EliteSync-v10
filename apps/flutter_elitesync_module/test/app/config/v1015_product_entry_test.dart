import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/main_prod.dart' as prod;

void main() {
  // Host contracts are compiled per product profile. The v1015 API assertions
  // run in that profile; the WS safety assertion also runs in the default suite.
  if (const bool.fromEnvironment('ELITESYNC_V1015_LOCAL_BUILD')) {
    test('v1015 profile is compiled with its accepted product parent', () {
      expect(const bool.fromEnvironment('ELITESYNC_V1015_LOCAL_BUILD'), isTrue);
      expect(const bool.fromEnvironment('ELITESYNC_V1014_LOCAL_BUILD'), isTrue);
    });

    test('v1015 accepts its own isolated Android API host', () {
      expect(
        prod.resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': 'http://127.0.0.1:8021/'},
        ),
        'http://127.0.0.1:8021/',
      );
    });

    for (final host in [
      '',
      'http://127.0.0.1:8019/',
      'http://127.0.0.1:8017/',
      'http://example.invalid:8021/',
      'http://127.0.0.1:8021/?token=x',
      'http://user@127.0.0.1:8021/',
    ]) {
      test('v1015 rejects a missing, older or untrusted API host: $host', () {
        expect(
          () => prod.resolveApiBaseUrl(hostBootstrap: {'apiBaseUrl': host}),
          throwsStateError,
        );
      });
    }
  }

  test(
    'v1015 local product bootstrap preserves its separate scoped WS port',
    () {
      expect(
        prod.resolveWsBaseUrl(
          apiBaseUrl: 'http://127.0.0.1:8021/',
          hostBootstrap: {'wsBaseUrl': 'ws://127.0.0.1:8022/'},
          flavor: AppFlavor.dev,
          environmentOverride: '',
        ),
        'ws://127.0.0.1:8022',
      );
    },
  );
}
