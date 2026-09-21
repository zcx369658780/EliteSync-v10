import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/state/connection_presentation_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionPresentationController
    extends Notifier<ConnectionPresentationState> {
  @override
  ConnectionPresentationState build() {
    final env = ref.watch(appEnvProvider);
    if (env.isDev && env.useSyntheticConnectionLifecycle) {
      return const ConnectionPresentationState.syntheticDevelopment(
        ProductConnectionState.none,
      );
    }
    return const ConnectionPresentationState.notYetEstablished();
  }

  List<ConnectionTransition> get availableTransitions {
    final snapshot = state;
    final current = snapshot.state;
    if (!snapshot.hasSyntheticDevelopmentState || current == null) {
      return const <ConnectionTransition>[];
    }
    return ProductConnectionContract.transitions
        .where((transition) => transition.from == current)
        .toList(growable: false);
  }

  void apply(ConnectionLifecycleAction action) {
    final snapshot = state;
    final current = snapshot.state;
    if (!snapshot.hasSyntheticDevelopmentState || current == null) return;

    for (final transition in ProductConnectionContract.transitions) {
      if (transition.from == current && transition.action == action) {
        state = ConnectionPresentationState.syntheticDevelopment(transition.to);
        return;
      }
    }
  }

  void resetLocalDemo() {
    final env = ref.read(appEnvProvider);
    if (!env.isDev || !env.useSyntheticConnectionLifecycle) return;
    state = const ConnectionPresentationState.syntheticDevelopment(
      ProductConnectionState.none,
    );
  }
}

final connectionPresentationProvider =
    NotifierProvider<
      ConnectionPresentationController,
      ConnectionPresentationState
    >(ConnectionPresentationController.new);
