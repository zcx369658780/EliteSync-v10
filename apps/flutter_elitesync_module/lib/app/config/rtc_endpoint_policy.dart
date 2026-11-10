import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/core/network/api_transport_policy.dart';

/// Preserve the gateway path for the SDK, after validating its transport.
String validateRtcGatewayUrl(String raw, {required AppEnv env}) {
  final value = raw.trim();
  final prefix = RegExp(
    r'^(wss|ws)://',
    caseSensitive: false,
  ).firstMatch(value);
  if (prefix == null) {
    throw const FormatException('Invalid RTC gateway URL');
  }
  final secure = prefix.group(1)!.toLowerCase() == 'wss';
  final httpUrl =
      '${secure ? 'https' : 'http'}://${value.substring(prefix.end)}';
  try {
    // Reuse authority/port/credential checks without returning the API
    // normalizer's trailing slash or path changes to the RTC SDK.
    validateApiBaseUrl(httpUrl, allowLocalInsecure: !secure && env.isDev);
    if (!secure) {
      final api = Uri.parse(
        validateApiBaseUrl(env.apiBaseUrl, allowLocalInsecure: env.isDev),
      );
      final gateway = Uri.parse(httpUrl);
      if (!env.isDev || api.scheme != 'http' || api.host != gateway.host) {
        throw const FormatException('RTC requires a secure gateway');
      }
    }
  } on FormatException {
    // Do not expose credential-bearing input in errors or downstream logs.
    throw const FormatException('Invalid or insecure RTC gateway URL');
  }
  return value;
}
