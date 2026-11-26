import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

bool isTransportUnavailable(Object? error) {
  if (error is SocketException || error is TimeoutException) return true;
  if (error is! DioException || error.response != null) return false;
  return switch (error.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => true,
    // A response interrupted at the socket can arrive through the generic
    // Dio wrapper. Keep HTTP status errors and other unknown causes closed.
    DioExceptionType.unknown => switch (error.error) {
      SocketException() => true,
      HttpException(message: 'Connection closed while receiving data') => true,
      _ => false,
    },
    _ => false,
  };
}
