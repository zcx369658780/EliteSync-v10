import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/main_prod.dart';

void main() {
  test('endpoint resolution respects the actual build mode', () {
    const v1010 = bool.fromEnvironment('ELITESYNC_V1010_LOCAL_BUILD');
    const previousLocal =
        bool.fromEnvironment('ELITESYNC_V1006_LOCAL_BUILD') ||
        bool.fromEnvironment('ELITESYNC_V1007_LOCAL_BUILD') ||
        bool.fromEnvironment('ELITESYNC_V1008_LOCAL_BUILD') ||
        bool.fromEnvironment('ELITESYNC_V1009_LOCAL_BUILD');
    if (v1010) {
      expect(
        resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': 'http://127.0.0.1:8010/'},
        ),
        'http://127.0.0.1:8010/',
      );
      for (final invalid in [
        '',
        'http://127.0.0.1:8000/',
        'https://example.com/',
      ]) {
        expect(
          () => resolveApiBaseUrl(hostBootstrap: {'apiBaseUrl': invalid}),
          throwsStateError,
        );
      }
    } else if (previousLocal) {
      expect(
        resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': 'http://127.0.0.1:8000/'},
        ),
        'http://127.0.0.1:8000/',
      );
      expect(
        () => resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': 'http://127.0.0.1:8010/'},
        ),
        throwsStateError,
      );
    } else {
      expect(
        resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': 'http://127.0.0.1:8010'},
        ),
        'http://127.0.0.1:8010/',
      );
      expect(
        resolveApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': 'https://example.invalid/'},
        ),
        'https://example.invalid/',
      );
      const configured = String.fromEnvironment('ELITESYNC_API_BASE_URL');
      final expected = configured.trim().isEmpty
          ? 'http://101.133.161.203/'
          : configured.trim().endsWith('/')
          ? configured.trim()
          : '${configured.trim()}/';
      expect(resolveApiBaseUrl(hostBootstrap: {}), expected);
    }
  });
}
