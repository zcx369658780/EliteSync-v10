import 'package:dio/dio.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocalStorage extends LocalStorageService {
  @override
  Future<String?> getString(String key) async => null;

  @override
  Future<Map<String, dynamic>?> getJson(String key) async => null;
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(dio: Dio());

  final List<Object> responses = <Object>[];
  final List<String> requestedPaths = <String>[];

  @override
  Future<NetworkResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    requestedPaths.add(path);
    final response = responses.removeAt(0);
    if (response is Exception) throw response;
    return response as NetworkResult<Map<String, dynamic>>;
  }
}

Map<String, dynamic> _feedItem({String id = 'remote-1'}) => {
  'id': id,
  'title': '合成关系话题',
  'summary': '仅用于确定性测试的内容摘要',
  'author': '测试作者',
  'likes': 3,
  'body': '确定性测试正文',
  'tags': ['测试标签'],
};

void main() {
  late _FakeApiClient api;
  late HomeRemoteDataSource remote;

  setUp(() {
    api = _FakeApiClient();
    remote = HomeRemoteDataSource(
      apiClient: api,
      useMock: false,
      localStorage: _FakeLocalStorage(),
    );
  });

  test('non-mock Discover maps a valid non-empty response', () async {
    api.responses.add(
      NetworkSuccess<Map<String, dynamic>>({
        'data': [_feedItem()],
        'meta': {'has_more': false},
      }),
    );

    final page = await remote.fetchDiscoverFeedPage(tab: 'hot');

    expect(page.items, hasLength(1));
    expect(page.items.single.id, 'remote-1');
    expect(page.items.single.title, '合成关系话题');
    expect(api.requestedPaths, ['/api/v1/discover/feed']);
  });

  test('non-mock Discover preserves a successful empty response', () async {
    api.responses.add(
      const NetworkSuccess<Map<String, dynamic>>({
        'data': <Map<String, dynamic>>[],
        'meta': {'has_more': false},
      }),
    );

    final page = await remote.fetchDiscoverFeedPage();

    expect(page.items, isEmpty);
    expect(page.hasMore, isFalse);
    expect(api.requestedPaths, ['/api/v1/discover/feed']);
  });

  test(
    'non-mock Discover explicit failure is error without fallback',
    () async {
      api.responses.add(
        const NetworkFailure<Map<String, dynamic>>(
          message: 'raw endpoint text',
        ),
      );

      await expectLater(
        remote.fetchDiscoverFeedPage(),
        throwsA(isA<DiscoverContentUnavailableException>()),
      );
      expect(api.requestedPaths, ['/api/v1/discover/feed']);
    },
  );

  test(
    'non-mock Discover thrown exception is sanitized and no fallback',
    () async {
      api.responses.add(StateError('raw transport details'));

      await expectLater(
        remote.fetchDiscoverFeedPage(),
        throwsA(isA<DiscoverContentUnavailableException>()),
      );
      expect(api.requestedPaths, ['/api/v1/discover/feed']);
    },
  );

  test('non-mock Discover malformed response fails closed', () async {
    api.responses.add(
      const NetworkSuccess<Map<String, dynamic>>({'data': 'not-a-list'}),
    );

    await expectLater(
      remote.fetchDiscoverFeedPage(),
      throwsA(isA<DiscoverContentUnavailableException>()),
    );
  });

  test('non-mock Discover rejects malformed non-empty item maps', () async {
    api.responses.add(
      const NetworkSuccess<Map<String, dynamic>>({
        'data': [
          <String, dynamic>{'foo': 'bar'},
        ],
      }),
    );

    await expectLater(
      remote.fetchDiscoverFeedPage(),
      throwsA(isA<DiscoverContentUnavailableException>()),
    );
  });

  test('explicit mock seam remains isolated from the API client', () async {
    final mockRemote = HomeRemoteDataSource(
      apiClient: api,
      useMock: true,
      localStorage: _FakeLocalStorage(),
    );

    final page = await mockRemote.fetchDiscoverFeedPage();

    expect(page.items, isNotEmpty);
    expect(api.requestedPaths, isEmpty);
  });

  test('non-mock detail maps valid current DTO without generation', () async {
    api.responses.add(
      NetworkSuccess<Map<String, dynamic>>({'data': _feedItem(id: 'detail-1')}),
    );

    final detail = await remote.fetchContentDetail('detail-1');

    expect(detail.id, 'detail-1');
    expect(detail.body, '确定性测试正文');
    expect(api.requestedPaths, ['/api/v1/content/detail-1']);
  });

  test(
    'non-mock detail missing data is unavailable without generated DTO',
    () async {
      api.responses.add(
        const NetworkSuccess<Map<String, dynamic>>({'data': null}),
      );

      await expectLater(
        remote.fetchContentDetail('missing'),
        throwsA(isA<DiscoverContentUnavailableException>()),
      );
    },
  );

  test(
    'non-mock detail failure is unavailable without generated DTO',
    () async {
      api.responses.add(
        const NetworkFailure<Map<String, dynamic>>(
          message: 'raw detail failure',
        ),
      );

      await expectLater(
        remote.fetchContentDetail('failed'),
        throwsA(isA<DiscoverContentUnavailableException>()),
      );
    },
  );

  test('non-mock detail thrown exception is sanitized', () async {
    api.responses.add(StateError('raw detail exception'));

    await expectLater(
      remote.fetchContentDetail('thrown'),
      throwsA(isA<DiscoverContentUnavailableException>()),
    );
  });

  test('non-mock detail rejects malformed non-empty maps', () async {
    api.responses.add(
      const NetworkSuccess<Map<String, dynamic>>({
        'data': <String, dynamic>{'foo': 'bar'},
      }),
    );

    await expectLater(
      remote.fetchContentDetail('malformed'),
      throwsA(isA<DiscoverContentUnavailableException>()),
    );
  });

  test('non-mock detail rejects a mismatched content identity', () async {
    api.responses.add(
      NetworkSuccess<Map<String, dynamic>>({
        'data': _feedItem(id: 'different-id'),
      }),
    );

    await expectLater(
      remote.fetchContentDetail('requested-id'),
      throwsA(isA<DiscoverContentUnavailableException>()),
    );
  });
}
