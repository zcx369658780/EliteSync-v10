import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/retry_interceptor.dart';

class _InitialFailure implements HttpClientAdapter {
  _InitialFailure(this.refresh);
  final bool refresh;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? body, Future<void>? cancel) async {
    if (refresh) return ResponseBody.fromString('{}', 401);
    throw DioException(requestOptions: options, type: DioExceptionType.connectionError);
  }
  @override
  void close({bool force=false}) {}
}
void main() {
  for (final refresh in [false,true]) {
    for (final switched in [false,true]) {
      test('${refresh ? 'refresh' : 'GET network'} retry ${switched ? 'rejects switched account' : 'permits current account'}', () async {
        var epoch=1;
        final entered=Completer<void>();final release=Completer<void>();
        final server=await HttpServer.bind(InternetAddress.loopbackIPv4,0);
        final subscription=server.listen((r) async {
          entered.complete();await release.future;
          r.response.headers.contentType=ContentType.json;
          r.response.write('{"private":"account-A"}');await r.response.close();
        });
        final dio=Dio(BaseOptions(baseUrl:'http://127.0.0.1:${server.port}'))..httpClientAdapter=_InitialFailure(refresh);
        dio.interceptors.add(AuthInterceptor(accessTokenProvider:() async=>'synthetic-token',sessionIdentity:()=>'$epoch',refreshAccessToken:refresh ? () async=>'synthetic-new-token' : null));
        if (!refresh) dio.interceptors.add(RetryInterceptor());
        try {
          final future=dio.get<dynamic>('/retry-test');
          final assertion=switched ? expectLater(future,throwsA(isA<DioException>().having((e)=>e.type,'type',DioExceptionType.cancel))) : expectLater(future,completion(isA<Response<dynamic>>()));
          await entered.future.timeout(const Duration(seconds:10));
          if (switched) epoch=2;
          release.complete();await assertion;
        } finally { dio.close(force:true);await subscription.cancel();await server.close(force:true); }
      });
    }
  }
}
