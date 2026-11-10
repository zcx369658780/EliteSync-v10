import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/providers/connection_presentation_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class ConversationAccessController extends Notifier<ConversationAccessSnapshot> {
  ProductConversationState _localState = ProductConversationState.locked;
  bool _hasLocalMutualConsent = false;

  @override
  ConversationAccessSnapshot build() {
    final env = ref.watch(appEnvProvider);
    final connection = ref.watch(connectionPresentationProvider);
    if (!env.isDev || !env.useSyntheticConversationLifecycle) {
      _clearLocalLifecycle();
      return const ConversationAccessSnapshot.notYetEstablished();
    }
    if (!connection.hasSyntheticDevelopmentState ||
        connection.state != ProductConnectionState.active) {
      _clearLocalLifecycle();
    }
    return ConversationAccessSnapshot.syntheticDevelopment(_localState);
  }

  bool get hasLocalMutualConsent => _hasLocalMutualConsent;

  List<ConversationTransition> get availableTransitions {
    if (!state.hasSyntheticDevelopmentState) {
      return const <ConversationTransition>[];
    }
    final hasActiveConnection = _hasSyntheticActiveConnection;
    return ProductConversationContract.transitions.where((transition) {
      if (transition.from != state.state) return false;
      if (transition.requiresAuthoritativeActiveConnection &&
          !hasActiveConnection) {
        return false;
      }
      if (transition.requiresAuthoritativeMutualMessagingConsent &&
          transition.action !=
              ConversationLifecycleAction.acceptMessagingConsent &&
          !_hasLocalMutualConsent) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  void apply(ConversationLifecycleAction action) {
    final env = ref.read(appEnvProvider);
    if (!env.isDev ||
        !env.useSyntheticConversationLifecycle ||
        !state.hasSyntheticDevelopmentState) {
      return;
    }

    for (final transition in ProductConversationContract.transitions) {
      if (transition.from != state.state || transition.action != action) {
        continue;
      }
      if (transition.requiresAuthoritativeActiveConnection &&
          !_hasSyntheticActiveConnection) {
        return;
      }

      var nextMutualConsent = _hasLocalMutualConsent;
      if (action == ConversationLifecycleAction.acceptMessagingConsent) {
        nextMutualConsent = true;
      }
      if (transition.requiresAuthoritativeMutualMessagingConsent &&
          !nextMutualConsent) {
        return;
      }

      if (action == ConversationLifecycleAction.declineMessagingConsent ||
          action == ConversationLifecycleAction.withdrawMessagingConsent) {
        nextMutualConsent = false;
      }
      _hasLocalMutualConsent = nextMutualConsent;
      _localState = transition.to;
      state = ConversationAccessSnapshot.syntheticDevelopment(_localState);
      return;
    }
  }

  void resetLocalDemo() {
    final env = ref.read(appEnvProvider);
    if (!env.isDev || !env.useSyntheticConversationLifecycle) return;
    _clearLocalLifecycle();
    state = const ConversationAccessSnapshot.syntheticDevelopment(
      ProductConversationState.locked,
    );
  }

  bool get _hasSyntheticActiveConnection {
    final connection = ref.read(connectionPresentationProvider);
    return connection.hasSyntheticDevelopmentState &&
        connection.state == ProductConnectionState.active;
  }

  void _clearLocalLifecycle() {
    _localState = ProductConversationState.locked;
    _hasLocalMutualConsent = false;
  }
}

final conversationAccessProvider =
    NotifierProvider<ConversationAccessController, ConversationAccessSnapshot>(
      ConversationAccessController.new,
    );
