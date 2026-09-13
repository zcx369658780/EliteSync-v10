import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/chat/domain/product_conversation_contract.dart';

final conversationAccessProvider = Provider<ConversationAccessSnapshot>(
  (ref) => const ConversationAccessSnapshot.notYetEstablished(),
);
