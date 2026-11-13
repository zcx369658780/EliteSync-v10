import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';
import 'package:flutter_elitesync_module/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/state/conversation_access_state.dart';
import 'package:flutter_elitesync_module/features/relationships_v1011/relationship_api.dart';
import 'package:flutter_elitesync_module/shared/enums/auth_status.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

const conversation = ConversationEntity(
  id: '17',
  name: 'Fictional peer',
  lastMessage: '',
  lastTime: '',
  unread: 0,
  entryKind: 'stored_conversation',
  conversationId: 3,
  peerUserId: 17,
);

class _Session extends SessionNotifier {
  @override
  SessionState build() => const SessionState(
    status: AuthStatus.authenticated,
    accessToken: 'fictional-session',
  );

  void switchAccount() => state = const AsyncData(
    SessionState(
      status: AuthStatus.authenticated,
      accessToken: 'other-fictional-session',
    ),
  );

  void signOut() =>
      state = const AsyncData(SessionState(status: AuthStatus.unauthenticated));
}

class _LockedAccess extends ConversationAccessController {
  @override
  ConversationAccessSnapshot build() =>
      const ConversationAccessSnapshot.notYetEstablished();
}

class _Repository extends Fake implements ChatRepository {
  int calls = 0;
  Future<ConversationEntity> Function()? response;

  @override
  Future<ConversationEntity> getConversation(int conversationId) async {
    calls++;
    expect(conversationId, 3);
    return response == null ? conversation : response!();
  }
}

Future<ProviderContainer> fixture(
  _Repository repository, {
  bool local = true,
  bool mock = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      appEnvProvider.overrideWithValue(
        AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Fixture',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: false,
          restorationLocalBuild: local,
          useMockChat: mock,
        ),
      ),
      sessionProvider.overrideWith(_Session.new),
      conversationAccessProvider.overrideWith(_LockedAccess.new),
      chatRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  await container.read(sessionProvider.future);
  return container;
}

void main() {
  test(
    'live detail resolves through the authoritative backend with demo gate locked',
    () async {
      final repository = _Repository();
      final container = await fixture(repository);
      expect(
        await container.read(conversationDetailProvider(3).future),
        conversation,
      );
      expect(repository.calls, 1);
    },
  );

  test('live backend denial remains a failure without fallback', () async {
    final repository = _Repository()
      ..response = () async => throw StateError('404');
    final container = await fixture(repository);
    await expectLater(
      container.read(conversationDetailProvider(3).future),
      throwsStateError,
    );
    expect(repository.calls, 1);
  });

  for (final mode in [(local: false, mock: false), (local: true, mock: true)]) {
    test(
      'locked access remains enforced for local=${mode.local} mock=${mode.mock}',
      () async {
        final repository = _Repository();
        final container = await fixture(
          repository,
          local: mode.local,
          mock: mode.mock,
        );
        await expectLater(
          container.read(conversationDetailProvider(3).future),
          throwsStateError,
        );
        expect(repository.calls, 0);
      },
    );
  }

  test('signed-out live detail cannot start a backend read', () async {
    final repository = _Repository();
    final container = await fixture(repository);
    (container.read(sessionProvider.notifier) as _Session).signOut();
    await expectLater(
      container.read(conversationDetailProvider(3).future),
      throwsStateError,
    );
    expect(repository.calls, 0);
  });

  for (final changeAccount in [true, false]) {
    test(
      'late live detail is discarded after ${changeAccount ? 'account' : 'authority'} change',
      () async {
        final pending = Completer<ConversationEntity>();
        final repository = _Repository();
        repository.response = () => repository.calls == 1
            ? pending.future
            : Future.error(StateError('current backend unavailable'));
        final container = await fixture(repository);
        final revealed = <ConversationEntity>[];
        final subscription = container.listen(conversationDetailProvider(3), (
          _,
          next,
        ) {
          if (next.asData?.value case final value?) revealed.add(value);
        });
        addTearDown(subscription.close);
        expect(repository.calls, 1);
        if (changeAccount) {
          (container.read(sessionProvider.notifier) as _Session)
              .switchAccount();
        } else {
          container
              .read(relationshipAuthorityEpochProvider.notifier)
              .invalidate();
        }
        await container.pump();
        await expectLater(
          container.read(conversationDetailProvider(3).future),
          throwsStateError,
        );
        pending.complete(conversation);
        await container.pump();
        expect(revealed, isEmpty);
        expect(repository.calls, 2);
      },
    );
  }
}
