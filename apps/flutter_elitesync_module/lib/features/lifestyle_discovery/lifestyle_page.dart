import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_route_names.dart';
import '../relationships_v1011/relationship_api.dart';
import '../slow_dating_v1012/journey_components.dart';
import 'lifestyle_controller.dart';
import 'lifestyle_providers.dart';

class LifestyleDiscoveryPage extends ConsumerStatefulWidget {
  const LifestyleDiscoveryPage({super.key, this.onExit});
  final VoidCallback? onExit;
  @override
  ConsumerState<LifestyleDiscoveryPage> createState() => _LifestylePageState();
}

class _LifestylePageState extends ConsumerState<LifestyleDiscoveryPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transition = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    value: 1,
  );
  LifestyleController? _loaded;
  int _index = -1;
  int _direction = 1;
  bool _moving = false;
  bool _positioned = false;
  bool get _reduced =>
      MediaQuery.disableAnimationsOf(context) ||
      MediaQuery.accessibleNavigationOf(context);

  @override
  void dispose() {
    _transition.dispose();
    super.dispose();
  }

  void _exit() {
    if (widget.onExit != null) {
      widget.onExit!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(AppRouteNames.home);
    }
  }

  Future<void> _move(int next) async {
    if (_moving || next == _index) return;
    final controller = _loaded;
    setState(() {
      _moving = true;
      _direction = next < _index ? -1 : 1;
    });
    if (!_reduced) await _transition.reverse();
    if (!mounted || controller != _loaded) return;
    setState(() => _index = next);
    if (!_reduced) await _transition.forward();
    if (mounted && controller == _loaded) setState(() => _moving = false);
  }

  Future<void> _reset(LifestyleController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重新探索？'),
        content: const Text('将清除当前答案和偏好摘要，从第一个场景重新开始。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('重新开始'),
          ),
        ],
      ),
    );
    if (confirmed == true &&
        await controller.command('reset') &&
        mounted &&
        controller == _loaded) {
      await _move(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(lifestyleControllerProvider);
    if (_loaded != controller) {
      _loaded = controller;
      _index = -1;
      _moving = false;
      _positioned = false;
      _transition.value = 1;
      scheduleMicrotask(controller.load);
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final data = controller.data;
        final scenes = rows(objectMap(data?['bank'])['scenes']);
        final answers = objectMap(data?['answers']);
        if (!_positioned && data != null) {
          _positioned = true;
          if (data['status'] == 'completed') {
            _index = scenes.length;
          } else if (data['status'] == 'in_progress') {
            final missing = scenes.indexWhere(
              (scene) => !answers.containsKey(scene['id']),
            );
            _index = missing < 0 ? scenes.length : missing;
          }
        }
        final enabled =
            !controller.busy && controller.pending == null && !_moving;
        final isScene = _index >= 0 && _index < scenes.length;
        final scene = isScene ? scenes[_index] : <String, dynamic>{};
        final selected = objectMap(answers[scene['id']])['option_id'];
        return Scaffold(
          appBar: AppBar(
            title: const Text('生活方式探索'),
            actions: [
              TextButton(
                key: const Key('lifestyle-skip'),
                onPressed: controller.busy
                    ? null
                    : () async {
                        if (controller.pending != null ||
                            data == null ||
                            data['status'] == 'completed') {
                          _exit();
                          return;
                        }
                        await controller.command('skip');
                        if (mounted && controller == _loaded) _exit();
                      },
                child: const Text('跳过'),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (controller.busy)
                        const LinearProgressIndicator(
                          semanticsLabel: '正在保存或读取',
                        ),
                      if (controller.error != null) ...[
                        Semantics(
                          liveRegion: true,
                          child: Text(controller.error!),
                        ),
                        if (controller.conflict)
                          OutlinedButton(
                            onPressed: controller.busy
                                ? null
                                : () async {
                                    await controller.discardAndReload();
                                    if (mounted &&
                                        controller == _loaded &&
                                        controller.error == null) {
                                      setState(() {
                                        _positioned = false;
                                        _index = -1;
                                      });
                                    }
                                  },
                            child: const Text('放弃本机待同步选择，读取最新答案'),
                          )
                        else
                          OutlinedButton(
                            onPressed: controller.busy
                                ? null
                                : () async {
                                    if (controller.pending != null) {
                                      await controller.retry();
                                    } else {
                                      await controller.load();
                                    }
                                  },
                            child: const Text('重试'),
                          ),
                        TextButton(
                          onPressed: _exit,
                          child: const Text('稍后继续，进入社区'),
                        ),
                      ],
                      if (data != null)
                        SlideTransition(
                          key: const Key('lifestyle-transition'),
                          position: _reduced
                              ? const AlwaysStoppedAnimation(Offset.zero)
                              : _transition.drive(
                                  Tween(
                                    begin: Offset(.04 * _direction, 0),
                                    end: Offset.zero,
                                  ),
                                ),
                          child: FadeTransition(
                            opacity: _reduced
                                ? const AlwaysStoppedAnimation(1)
                                : _transition,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_index < 0) ...[
                                  Text(
                                    '从几个日常小选择开始',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 20),
                                  const Text('五个生活场景，按最近的倾向选择。答案仅自己可见，可以随时改。'),
                                  const SizedBox(height: 12),
                                  const Text('可以跳过并使用社区、好友和搭子。参加每周慢约会时再完成即可。'),
                                  const SizedBox(height: 24),
                                  FilledButton(
                                    key: const Key('lifestyle-start'),
                                    onPressed: enabled
                                        ? () async {
                                            if (await controller.command(
                                                  'start',
                                                ) &&
                                                mounted &&
                                                controller == _loaded) {
                                              final first = scenes.indexWhere(
                                                (item) => !answers.containsKey(
                                                  item['id'],
                                                ),
                                              );
                                              await _move(
                                                first < 0 ? 0 : first,
                                              );
                                            }
                                          }
                                        : null,
                                    child: Text(
                                      answers.isEmpty ? '开始探索' : '继续探索',
                                    ),
                                  ),
                                ] else if (isScene) ...[
                                  Text(
                                    '${_index + 1} / ${scenes.length}',
                                    textAlign: TextAlign.end,
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Stack(
                                      children: [
                                        Image.asset(
                                          '${scene['asset']}',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          excludeFromSemantics: true,
                                        ),
                                        if (selected != null)
                                          Positioned.fill(
                                            child: IgnorePointer(
                                              child: Align(
                                                alignment: Alignment(
                                                  (rows(
                                                            scene['options'],
                                                          ).indexWhere(
                                                            (o) =>
                                                                o['id'] ==
                                                                selected,
                                                          ) -
                                                          1) *
                                                      .65,
                                                  .55,
                                                ),
                                                child: Container(
                                                  width: 48,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: .12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      '${scene['title']}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  for (final option in rows(scene['options']))
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Semantics(
                                        key: Key('choice-${option['id']}'),
                                        selected: selected == option['id'],
                                        child: AnimatedContainer(
                                          duration: _reduced
                                              ? Duration.zero
                                              : const Duration(
                                                  milliseconds: 200,
                                                ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            color: selected == option['id']
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primaryContainer
                                                : Colors.transparent,
                                          ),
                                          child: OutlinedButton(
                                            key: Key('option-${option['id']}'),
                                            style: OutlinedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(52),
                                            ),
                                            onPressed: enabled
                                                ? () async {
                                                    final next =
                                                        const bool.fromEnvironment(
                                                              'ELITESYNC_V1017_LOCAL_BUILD',
                                                            ) &&
                                                            data['status'] ==
                                                                'completed'
                                                        ? scenes.length
                                                        : _index + 1;
                                                    if (await controller.answer(
                                                          '${scene['id']}',
                                                          '${option['id']}',
                                                        ) &&
                                                        mounted &&
                                                        controller == _loaded) {
                                                      await _move(next);
                                                    }
                                                  }
                                                : null,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${option['label']}',
                                                  ),
                                                ),
                                                if (selected == option['id'])
                                                  const Icon(
                                                    Icons.check,
                                                    size: 20,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        key: const Key('lifestyle-back'),
                                        onPressed: !enabled
                                            ? null
                                            : () => _move(_index - 1),
                                        child: const Text('返回'),
                                      ),
                                      if (selected != null)
                                        TextButton(
                                          onPressed: !enabled
                                              ? null
                                              : () => _move(_index + 1),
                                          child: const Text('下一步'),
                                        ),
                                    ],
                                  ),
                                ] else ...[
                                  Text(
                                    '你的生活方式偏好',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('这些偏好来自你刚才的选择，可随时纠正。'),
                                  for (var i = 0; i < scenes.length; i++)
                                    Card(
                                      child: ListTile(
                                        title: Text(
                                          '${scenes[i]['dimension_label']}',
                                        ),
                                        subtitle: Text(
                                          '${objectMap(objectMap(data['derived_preferences'])[scenes[i]['dimension']])['explanation'] ?? '尚未选择'}',
                                        ),
                                        trailing: const Icon(
                                          Icons.edit_outlined,
                                        ),
                                        onTap: enabled ? () => _move(i) : null,
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  FilledButton(
                                    onPressed: _exit,
                                    child: Text(
                                      const bool.fromEnvironment(
                                            'ELITESYNC_V1017_LOCAL_BUILD',
                                          )
                                          ? '完成并返回'
                                          : '完成，进入社区',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: enabled
                                        ? () => _reset(controller)
                                        : null,
                                    child: const Text('重新探索'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
