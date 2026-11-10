import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/logging/app_logger.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/logging_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

class _LogEntry {
  _LogEntry(this.message, this.tag, this.error, this.stackTrace);

  final String message;
  final String tag;
  final Object? error;
  final StackTrace? stackTrace;
}

class _Logger extends AppLogger {
  _Logger() : super(enableDebugLogs: true);

  final entries = <_LogEntry>[];

  @override
  void debug(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) => entries.add(_LogEntry(message, tag, error, stackTrace));

  @override
  void warning(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) => entries.add(_LogEntry(message, tag, error, stackTrace));
}

class _Adapter implements HttpClientAdapter {
  RequestOptions? sent;
  int status = 200;
  DioExceptionType? failure;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    sent = options;
    if (failure != null) {
      throw DioException(
        requestOptions: options,
        type: failure!,
        message: 'fixture-sensitive-exception-message',
        error: StateError('fixture-sensitive-inner-error'),
        stackTrace: StackTrace.fromString('fixture-sensitive-stack'),
      );
    }
    return ResponseBody.fromString('fixture-sensitive-response-body', status);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const target =
      'https://fixture-user:fixture-password@api.example.invalid/private-path-secret'
      '?token=fixture-query-secret#fixture-fragment';
  late Dio dio;
  late _Adapter adapter;
  late _Logger logger;

  setUp(() {
    adapter = _Adapter();
    logger = _Logger();
    dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(LoggingInterceptor(logger: logger));
  });
  tearDown(() => dio.close());

  void expectSafeLogs(List<String> messages) {
    expect(logger.entries.map((entry) => entry.message), messages);
    for (final entry in logger.entries) {
      expect(entry.tag, 'NETWORK');
      expect(entry.error, isNull);
      expect(entry.stackTrace, isNull);
    }
  }

  test('success logs metadata without URL, headers, or payloads', () async {
    final response = await dio.post<String>(
      target,
      data: 'fixture-sensitive-request-body',
      options: Options(
        headers: {'Authorization': 'Bearer fixture-header-secret'},
      ),
    );

    expect(response.data, 'fixture-sensitive-response-body');
    expect(adapter.sent!.uri.toString(), target);
    expect(adapter.sent!.data, 'fixture-sensitive-request-body');
    expect(
      adapter.sent!.headers['Authorization'],
      'Bearer fixture-header-secret',
    );
    expectSafeLogs(['[REQ] POST', '[RES] 200 POST']);
  });

  test('HTTP rejection keeps response and omits raw exception', () async {
    adapter.status = 403;
    await expectLater(
      dio.get<String>(target),
      throwsA(
        isA<DioException>()
            .having((error) => error.response?.statusCode, 'status', 403)
            .having(
              (error) => error.response?.data,
              'response body',
              'fixture-sensitive-response-body',
            )
            .having(
              (error) => identical(error.requestOptions, adapter.sent),
              'original request',
              isTrue,
            ),
      ),
    );
    expectSafeLogs(['[REQ] GET', '[ERR] 403 GET badResponse']);
  });

  for (final type in DioExceptionType.values) {
    test(
      '${type.name} logs safe category and preserves error details',
      () async {
        adapter.failure = type;
        await expectLater(
          dio.get<String>(target),
          throwsA(
            isA<DioException>()
                .having((error) => error.type, 'category', type)
                .having(
                  (error) => error.message,
                  'original message',
                  'fixture-sensitive-exception-message',
                )
                .having(
                  (error) => error.error,
                  'original inner error',
                  isA<StateError>(),
                )
                .having(
                  (error) => error.stackTrace.toString(),
                  'original stack',
                  'fixture-sensitive-stack',
                ),
          ),
        );
        expectSafeLogs(['[REQ] GET', '[ERR] - GET ${type.name}']);
      },
    );
  }

  test('custom method is omitted from logs and still forwarded', () async {
    await dio.request<String>(
      target,
      options: Options(method: 'CUSTOM-FIXTURE-METHOD-SECRET'),
    );
    expect(adapter.sent!.method, 'CUSTOM-FIXTURE-METHOD-SECRET');
    expectSafeLogs(['[REQ] OTHER', '[RES] 200 OTHER']);
  });
}
