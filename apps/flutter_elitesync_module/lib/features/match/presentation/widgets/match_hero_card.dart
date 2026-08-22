import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';

class MatchHeroCard extends StatelessWidget {
  const MatchHeroCard({super.key, required this.headline, required this.score});

  final String headline;
  final int score;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headline, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(score >= 70 ? '这轮有可继续了解的线索' : '建议先慢慢观察线索'),
        ],
      ),
    );
  }
}
