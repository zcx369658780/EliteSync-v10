import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return BrowseScaffold(
      header: const _HomeHeader(),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.xs, 0, t.spacing.huge),
        children: [
          _SlowDateProgressCard(
            onOpenMatch: () => context.go(AppRouteNames.match),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.xl),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '首页',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '从这里查看慢约进展。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlowDateProgressCard extends StatelessWidget {
  const _SlowDateProgressCard({required this.onOpenMatch});

  final VoidCallback onOpenMatch;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.xl),
        border: Border.all(color: t.browseBorder),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          key: const ValueKey('e1-home-primary-match-cta'),
          onPressed: onOpenMatch,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: t.textPrimary,
            foregroundColor: t.browseSurface,
          ),
          icon: const Icon(Icons.favorite_rounded),
          label: const Text('查看慢约进展'),
        ),
      ),
    );
  }
}
