import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/main_prod.dart';

void main() {
  test('pilot API requires an exact host and explicit safe endpoint', () {
    for (final endpoint in [
      'https://pilot.example.invalid/',
      'https://pilot.example.invalid:8443/api/',
      'http://127.0.0.1:8030/',
    ]) {
      expect(
        resolvePilotApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': endpoint},
          configuredApi: endpoint,
        ),
        endpoint,
      );
      expect(
        () => resolvePilotApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': '$endpoint/other'},
          configuredApi: endpoint,
        ),
        throwsStateError,
      );
    }
    for (final endpoint in [
      '',
      '/api/',
      'https:///api/',
      'http://pilot.example.invalid/',
      'http://101.133.161.203/',
      'http://127.0.0.1:8000/',
      'http://127.0.0.1:08030/',
      'http://localhost:8030/',
      'http://127.0.0.1:8030/api/',
      'https://user:pass@pilot.example.invalid/',
      'https://@pilot.example.invalid/',
      'https://pilot.example.invalid/?',
      'https://pilot.example.invalid/#',
      ' https://pilot.example.invalid/',
    ]) {
      expect(
        () => resolvePilotApiBaseUrl(
          hostBootstrap: {'apiBaseUrl': endpoint},
          configuredApi: endpoint,
        ),
        throwsStateError,
      );
    }
    expect(
      () => resolvePilotApiBaseUrl(
        hostBootstrap: {},
        configuredApi: 'https://pilot.example.invalid/',
      ),
      throwsStateError,
    );
  });

  test('pilot WS is optional and cannot fall back or change host values', () {
    expect(resolvePilotWsBaseUrl(hostBootstrap: {}, configuredWs: ''), '');
    for (final endpoint in [
      'wss://pilot.example.invalid/socket/',
      'ws://127.0.0.1:8030/',
    ]) {
      expect(
        resolvePilotWsBaseUrl(
          hostBootstrap: {'wsBaseUrl': endpoint},
          configuredWs: endpoint,
        ),
        endpoint,
      );
    }
    for (final endpoint in [
      'ws://101.133.161.203:8081/',
      'ws://127.0.0.1:8081/',
      'wss://user@pilot.example.invalid/',
      'wss://pilot.example.invalid/?token=x',
      'https://pilot.example.invalid/',
    ]) {
      expect(
        () => resolvePilotWsBaseUrl(
          hostBootstrap: {'wsBaseUrl': endpoint},
          configuredWs: endpoint,
        ),
        throwsStateError,
      );
    }
    expect(
      () => resolvePilotWsBaseUrl(
        hostBootstrap: {'wsBaseUrl': 'wss://unexpected.example.invalid/'},
        configuredWs: '',
      ),
      throwsStateError,
    );
  });

  test('actual pilot gate fails closed without matching native bootstrap', () {
    if (const bool.fromEnvironment('ELITESYNC_V10_1_0_PILOT_BUILD')) {
      expect(() => resolveApiBaseUrl(hostBootstrap: {}), throwsStateError);
    }
  });
}
