import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

typedef AvatarPicker = Future<XFile?> Function();
final avatarPickerProvider = Provider<AvatarPicker>(
  (ref) =>
      () => ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      ),
);
final avatarApiProvider = Provider<AvatarApi>(
  (ref) => AvatarApi(ref.watch(dioProvider)),
);

class AvatarSnapshot {
  const AvatarSnapshot(this.revision, this.contentPath);
  final int revision;
  final String? contentPath;

  factory AvatarSnapshot.parse(Map data, int ownerId) {
    final revision = data['revision'];
    if (revision is! int || revision < 0) throw const FormatException('头像版本无效');
    final avatar = data['avatar'];
    if (avatar == null) return AvatarSnapshot(revision, null);
    if (avatar is! Map ||
        avatar['owner_user_id'] != ownerId ||
        avatar['revision'] != revision ||
        !validAvatarPath(avatar['content_path'], ownerId, revision)) {
      throw const FormatException('头像地址无效');
    }
    return AvatarSnapshot(revision, avatar['content_path'] as String);
  }
}

bool validAvatarPath(Object? path, int ownerId, int revision) =>
    ownerId > 0 && revision > 0 && path == '/api/v1/avatars/$ownerId/$revision';

class AvatarApi {
  AvatarApi(this.dio);
  final Dio dio;

  Options options(String token, bool Function() current) => Options(
    followRedirects: false,
    headers: {'Authorization': 'Bearer $token'},
    extra: {requestSessionGuardKey: current},
  );

  void check(bool Function() current) {
    if (!current()) throw StateError('登录会话已变化，请返回后重试。');
  }

  Future<AvatarSnapshot> read(
    int ownerId,
    String token,
    bool Function() current, {
    CancelToken? cancelToken,
  }) async {
    check(current);
    final response = await dio.get<Map<String, dynamic>>(
      '/api/v1/avatars/$ownerId',
      options: options(token, current),
      cancelToken: cancelToken,
    );
    check(current);
    if (response.statusCode != 200 || response.data == null) {
      throw StateError('头像读取失败');
    }
    return AvatarSnapshot.parse(response.data!, ownerId);
  }

  Future<AvatarSnapshot?> pickAndSave({
    required int ownerId,
    required int revision,
    required String token,
    required bool Function() current,
    required AvatarPicker picker,
  }) async {
    check(current);
    final file = await picker();
    check(current);
    if (file == null) return null;
    final length = await file.length();
    check(current);
    if (length > 5 * 1024 * 1024) {
      throw StateError('请选择不超过5 MiB的JPEG或PNG图片。');
    }
    final bytes = await file.readAsBytes();
    check(current);
    final png =
        bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71;
    final jpeg =
        bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255;
    if (bytes.length > 5 * 1024 * 1024 || (!png && !jpeg)) {
      throw StateError('请选择不超过5 MiB的JPEG或PNG图片。');
    }
    final response = await dio.post<Map<String, dynamic>>(
      '/api/v1/profile/avatar',
      data: FormData.fromMap({
        'expected_revision': revision,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: png ? 'avatar.png' : 'avatar.jpg',
        ),
      }),
      options: options(token, current),
    );
    check(current);
    return _confirm(
      response,
      ownerId,
      revision,
      token,
      current,
      removed: false,
    );
  }

  Future<AvatarSnapshot> remove(
    int ownerId,
    int revision,
    String token,
    bool Function() current,
  ) async {
    check(current);
    final response = await dio.delete<Map<String, dynamic>>(
      '/api/v1/profile/avatar',
      data: {'expected_revision': revision},
      options: options(token, current),
    );
    check(current);
    return _confirm(response, ownerId, revision, token, current, removed: true);
  }

  Future<AvatarSnapshot> _confirm(
    Response<Map<String, dynamic>> response,
    int ownerId,
    int previousRevision,
    String token,
    bool Function() current, {
    required bool removed,
  }) async {
    if (response.statusCode != 200 || response.data == null) {
      throw StateError('头像保存未确认，请刷新后检查。');
    }
    final saved = AvatarSnapshot.parse(response.data!, ownerId);
    final actual = await read(ownerId, token, current);
    if (saved.revision <= previousRevision ||
        actual.revision != saved.revision ||
        actual.contentPath != saved.contentPath ||
        (removed ? actual.contentPath != null : actual.contentPath == null)) {
      throw StateError('头像读回不一致，请刷新后检查。');
    }
    return actual;
  }
}

String avatarFailure(Object error) {
  if (error is DioException) {
    if (error.response?.statusCode == 409) return '头像已在其他位置更新，请刷新后再操作。';
    return '头像请求失败，请检查网络并刷新后重试。';
  }
  return error
      .toString()
      .replaceFirst('Bad state: ', '')
      .replaceFirst('FormatException: ', '');
}
