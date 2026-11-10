import 'package:flutter_elitesync_module/main_prod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
