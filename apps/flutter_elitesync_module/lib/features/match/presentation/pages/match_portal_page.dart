import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_round_contract_view.dart';

class MatchPortalPage extends ConsumerWidget {
  const MatchPortalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MatchRoundContractView();
  }
}
