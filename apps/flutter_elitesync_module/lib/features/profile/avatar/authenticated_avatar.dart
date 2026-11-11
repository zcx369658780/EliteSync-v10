import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'avatar_api.dart';

class AuthenticatedAvatar extends ConsumerStatefulWidget {
  const AuthenticatedAvatar({
    super.key,
    required this.ownerId,
    this.revision,
    this.refreshKey,
    this.size = 44,
  });
  final int ownerId;
  final int? revision;
  final Object? refreshKey;
  final double size;
  @override
  ConsumerState<AuthenticatedAvatar> createState() =>
      _AuthenticatedAvatarState();
}

class _AuthenticatedAvatarState extends ConsumerState<AuthenticatedAvatar>
    with WidgetsBindingObserver {
  MemoryImage? _image;
  CancelToken? _cancel;
  int _generation = 0;
  bool _active = true;
  late final ProviderSubscription<AsyncValue<SessionState>> _session;
  late final ProviderSubscription<int> _authority;

  void _clear() {
    _generation++;
    _cancel?.cancel('Avatar authority changed');
    _cancel = null;
    final image = _image;
    _image = null;
    if (image != null) unawaited(image.evict());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _session = ref.listenManual(sessionProvider, (_, next) => _reload());
    _authority = ref.listenManual(
      relationshipAuthorityEpochProvider,
      (_, next) => _reload(),
    );
    Future.microtask(_reload);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _reload();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(_clear);
    final generation = _generation;
    final session = ref.read(sessionProvider).asData?.value;
    final epoch = ref.read(relationshipAuthorityEpochProvider);
    final token = session?.accessToken;
    if (!_active ||
        session?.isLoggedIn != true ||
        token == null ||
        token.isEmpty ||
        widget.ownerId <= 0) {
      return;
    }
    bool current() =>
        mounted &&
        _active &&
        generation == _generation &&
        identical(session, ref.read(sessionProvider).asData?.value) &&
        epoch == ref.read(relationshipAuthorityEpochProvider);
    final cancel = CancelToken();
    _cancel = cancel;
    try {
      final api = ref.read(avatarApiProvider);
      // Always re-authorize metadata, including after a refresh or removal.
      final snapshot = await api.read(
        widget.ownerId,
        token,
        current,
        cancelToken: cancel,
      );
      final path = snapshot.contentPath;
      if (!current() ||
          path == null ||
          !validAvatarPath(path, widget.ownerId, snapshot.revision)) {
        return;
      }
      final response = await api.dio.get<List<int>>(
        path,
        cancelToken: cancel,
        options: api.options(token, current)..responseType = ResponseType.bytes,
      );
      if (!current()) return;
      final bytes = response.data;
      if (response.statusCode != 200 || bytes == null || bytes.isEmpty) return;
      setState(() => _image = MemoryImage(Uint8List.fromList(bytes)));
    } catch (_) {
      if (current()) setState(_clear);
    }
  }

  @override
  void didUpdateWidget(AuthenticatedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId ||
        oldWidget.revision != widget.revision ||
        oldWidget.refreshKey != widget.refreshKey) {
      _reload();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _session.close();
    _authority.close();
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipOval(
    child: SizedBox(
      width: widget.size,
      height: widget.size,
      child: _image == null
          ? const ColoredBox(
              color: Color(0xffeeeeee),
              child: Icon(Icons.person_outline),
            )
          : Image(
              image: _image!,
              fit: BoxFit.cover,
              gaplessPlayback: false,
              errorBuilder: (_, error, stack) =>
                  const Icon(Icons.person_outline),
            ),
    ),
  );
}
