import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/providers/connection_presentation_provider.dart';
import 'package:flutter_elitesync_module/features/connection/presentation/state/connection_presentation_state.dart';
import 'package:flutter_elitesync_module/main_demo.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const defaultDevEnv = AppEnv(
  flavor: AppFlavor.dev,
  appName: 'Default dev',
  apiBaseUrl: 'http://127.0.0.1:9/',
  useMockData: true,
);

ProviderContainer demoContainer() => ProviderContainer(
  overrides: [appEnvProvider.overrideWithValue(createDemoAppEnv())],
);

void main() {
  test('synthetic lifecycle requires the explicit demo flag', () {
    expect(defaultDevEnv.useSyntheticConnectionLifecycle, isFalse);
    expect(createDemoAppEnv().useSyntheticConnectionLifecycle, isTrue);

    final defaultContainer = ProviderContainer(
      overrides: [appEnvProvider.overrideWithValue(defaultDevEnv)],
    );
    addTearDown(defaultContainer.dispose);
    final initial = defaultContainer.read(connectionPresentationProvider);
    expect(initial.authority, ConnectionEvidenceAuthority.notYetEstablished);
    expect(initial.state, isNull);

    defaultContainer
        .read(connectionPresentationProvider.notifier)
        .apply(ConnectionLifecycleAction.request);
    expect(
      defaultContainer.read(connectionPresentationProvider).state,
      isNull,
    );
  });

  test('contract transitions drive the synthetic lifecycle', () {
    final container = demoContainer();
    addTearDown(container.dispose);
    final controller = container.read(connectionPresentationProvider.notifier);

    expect(
      container.read(connectionPresentationProvider),
      isA<ConnectionPresentationState>()
          .having(
            (value) => value.authority,
            'authority',
            ConnectionEvidenceAuthority.syntheticDevelopment,
          )
          .having(
            (value) => value.hasAuthoritativeState,
            'hasAuthoritativeState',
            isFalse,
          )
          .having(
            (value) => value.state,
            'state',
            ProductConnectionState.none,
          ),
    );

    controller.apply(ConnectionLifecycleAction.accept);
    expect(
      container.read(connectionPresentationProvider).state,
      ProductConnectionState.none,
    );

    controller.apply(ConnectionLifecycleAction.request);
    expect(
      container.read(connectionPresentationProvider).state,
      ProductConnectionState.pending,
    );
    controller.apply(ConnectionLifecycleAction.accept);
    expect(
      container.read(connectionPresentationProvider).state,
      ProductConnectionState.active,
    );
    controller.apply(ConnectionLifecycleAction.pause);
    expect(
      container.read(connectionPresentationProvider).state,
      ProductConnectionState.paused,
    );
    controller.apply(ConnectionLifecycleAction.resume);
    expect(
      container.read(connectionPresentationProvider).state,
      ProductConnectionState.active,
    );
    controller.apply(ConnectionLifecycleAction.close);
    expect(
      container.read(connectionPresentationProvider).state,
      ProductConnectionState.closed,
    );
  });

  test('pending terminal branches use the existing contract', () {
    for (final branch in <ConnectionLifecycleAction, ProductConnectionState>{
      ConnectionLifecycleAction.decline: ProductConnectionState.declined,
      ConnectionLifecycleAction.withdraw: ProductConnectionState.withdrawn,
      ConnectionLifecycleAction.expire: ProductConnectionState.expired,
    }.entries) {
      final container = demoContainer();
      addTearDown(container.dispose);
      final controller = container.read(
        connectionPresentationProvider.notifier,
      );
      controller.apply(ConnectionLifecycleAction.request);
      controller.apply(branch.key);
      expect(container.read(connectionPresentationProvider).state, branch.value);
    }
  });

  test('synthetic active remains non-authoritative and conversation stays locked', () {
    expect(
      ProductConnectionContract.transitions.where(
        (transition) =>
            transition.from == ProductConnectionState.none &&
            transition.to == ProductConnectionState.active,
      ),
      isEmpty,
    );
    expect(ProductConnectionAuthority.authoritativeActions, isEmpty);

    final container = demoContainer();
    addTearDown(container.dispose);
    final controller = container.read(connectionPresentationProvider.notifier);
    controller.apply(ConnectionLifecycleAction.request);
    controller.apply(ConnectionLifecycleAction.accept);

    final connection = container.read(connectionPresentationProvider);
    expect(connection.state, ProductConnectionState.active);
    expect(connection.hasAuthoritativeState, isFalse);

    final conversation = container.read(conversationAccessProvider);
    expect(conversation.canRevealPrivateContent, isFalse);
    expect(conversation.canSend, isFalse);
  });
}
