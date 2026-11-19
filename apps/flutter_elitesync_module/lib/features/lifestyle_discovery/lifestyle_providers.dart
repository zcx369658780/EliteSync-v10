import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/interceptors/auth_interceptor.dart';
import '../../core/network/network_result.dart';
import '../../core/storage/private_cache_service.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/session_provider.dart';
import '../relationships_v1011/relationship_api.dart';
import 'lifestyle_controller.dart';

const lifestyleDraftKey = 'lifestyle-discovery-draft:v1';

final lifestyleControllerProvider = Provider.autoDispose<LifestyleController>((
  ref,
) {
  final session = ref.watch(sessionProvider).asData?.value;
  final id = session?.user?.id;
  final token = session?.accessToken;
  final client = ref.watch(apiClientProvider);
  final cache = PrivateCacheService.forStorage(
    ref.watch(secureStorageProvider),
  );
  var alive = true;
  bool current() =>
      alive &&
      id != null &&
      session?.isLoggedIn == true &&
      ref.read(sessionProvider).asData?.value.user?.id == id &&
      ref.read(sessionProvider).asData?.value.accessToken == token;
  Future<Map<String, dynamic>> call(
    Map<String, dynamic>? body, {
    bool resultQuery = false,
  }) async {
    if (!current()) throw const RelationshipFailure('session changed');
    final options = Options(extra: {requestSessionGuardKey: current});
    const path = '/api/v1/profile/lifestyle-discovery';
    final result = resultQuery
        ? await client.get(
            '$path/command-result',
            query: body,
            options: options,
          )
        : body == null
        ? await client.get(path, options: options)
        : await client.put(path, body: body, options: options);
    if (!current()) throw const RelationshipFailure('session changed');
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw RelationshipFailure(result.message, statusCode: result.statusCode);
    }
    return (result as NetworkSuccess<Map<String, dynamic>>).data;
  }

  final controller = LifestyleController(
    read: () => call(null),
    readCommandResult: (body) => call(body, resultQuery: true),
    send: call,
    readDraft: () => cache.readAfterCurrentAuthorization(
      lifestyleDraftKey,
      expectedAccountId: id ?? -1,
      isCurrent: current,
    ),
    writeDraft: (value) => cache.saveAuthorized(
      lifestyleDraftKey,
      value,
      expectedAccountId: id,
      isCurrent: current,
    ),
    isCurrent: current,
  );
  ref.onDispose(() {
    alive = false;
    controller.dispose();
  });
  return controller;
});
