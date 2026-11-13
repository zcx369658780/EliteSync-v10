import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class AuthenticatedShowcasePhoto extends ConsumerStatefulWidget {
  const AuthenticatedShowcasePhoto({
    super.key,
    required this.contentPath,
    this.fit = BoxFit.cover,
    this.refreshKey,
  });

  final String contentPath;
  final BoxFit fit;
  final Object? refreshKey;

  @override
  ConsumerState<AuthenticatedShowcasePhoto> createState() =>
      _AuthenticatedShowcasePhotoState();
}

class _AuthenticatedShowcasePhotoState
    extends ConsumerState<AuthenticatedShowcasePhoto>
    with WidgetsBindingObserver {
  MemoryImage? _image;
  CancelToken? _cancel;
  bool _loading = false;
  bool _active = true;
  int _generation = 0;
  late final ProviderSubscription<AsyncValue<SessionState>> _session;
  late final ProviderSubscription<int> _authority;

  void _clear() {
    _generation++;
    _cancel?.cancel('Showcase photo authority changed');
    _cancel = null;
    final previous = _image;
    _image = null;
    _loading = false;
    if (previous != null) unawaited(previous.evict());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _session = ref.listenManual(sessionProvider, (_, _) => _reload());
    _authority = ref.listenManual(
      relationshipAuthorityEpochProvider,
      (_, _) => _reload(),
    );
    Future.microtask(_reload);
  }

  @override
  void didUpdateWidget(AuthenticatedShowcasePhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.contentPath != oldWidget.contentPath ||
        widget.refreshKey != oldWidget.refreshKey) {
      _reload();
    }
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
    final path = Uri.tryParse(widget.contentPath);
    if (!_active ||
        session?.isLoggedIn != true ||
        path == null ||
        path.hasScheme ||
        path.hasAuthority ||
        path.hasFragment ||
        !RegExp(
          r'^/api/v1/profile/showcase/[1-9]\d*/photos/[1-9]\d*$',
        ).hasMatch(path.path) ||
        path.queryParameters.keys.any((key) => key != 'publication_revision') ||
        (path.queryParameters.containsKey('publication_revision') &&
            (int.tryParse(path.queryParameters['publication_revision']!) ??
                    0) <=
                0)) {
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
    setState(() => _loading = true);
    try {
      final response = await ref
          .read(dioProvider)
          .get<List<int>>(
            widget.contentPath,
            cancelToken: cancel,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              extra: {requestSessionGuardKey: current},
            ),
          );
      if (!current()) return;
      final bytes = response.data;
      if (response.statusCode != 200 || bytes == null || bytes.isEmpty) {
        throw StateError('照片内容未确认');
      }
      setState(() {
        _loading = false;
        _image = MemoryImage(Uint8List.fromList(bytes));
      });
    } catch (_) {
      if (current()) setState(_clear);
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
  Widget build(BuildContext context) {
    if (_image != null) {
      return Image(
        image: _image!,
        fit: widget.fit,
        errorBuilder: (_, _, _) => const Center(child: Text('照片无法显示')),
      );
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Center(
      child: IconButton(
        tooltip: '照片暂不可用，重新读取',
        onPressed: _active ? _reload : null,
        icon: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
