import 'package:flutter_elitesync_module/app/router/app_route_names.dart';

enum HomeProjectionAuthority { authoritative, notYetEstablished, unknown }

enum HomeProjectedDomain { readiness, match, connection, conversation }

extension HomeProjectedDomainCopy on HomeProjectedDomain {
  String get label => switch (this) {
    HomeProjectedDomain.readiness => '准备状态',
    HomeProjectedDomain.match => '匹配',
    HomeProjectedDomain.connection => '连接',
    HomeProjectedDomain.conversation => '对话',
  };

  String get stateKey => switch (this) {
    HomeProjectedDomain.readiness => 'home-state-readiness',
    HomeProjectedDomain.match => 'home-state-match',
    HomeProjectedDomain.connection => 'home-state-connection',
    HomeProjectedDomain.conversation => 'home-state-conversation',
  };
}

class HomeStateSummary {
  const HomeStateSummary({required this.domain, required this.authority});

  final HomeProjectedDomain domain;
  final HomeProjectionAuthority authority;

  String get statusLabel => switch (authority) {
    HomeProjectionAuthority.authoritative => '已由所属功能确认',
    HomeProjectionAuthority.notYetEstablished =>
      domain == HomeProjectedDomain.match ||
              domain == HomeProjectedDomain.conversation
          ? '权限尚未建立'
          : '状态尚未建立',
    HomeProjectionAuthority.unknown => 'UNKNOWN',
  };
}

class HomeNextDecision {
  const HomeNextDecision({required this.label, required this.route});

  final String label;
  final String route;
}

class CalmHomeProjection {
  const CalmHomeProjection({
    required this.summaries,
    required this.readinessAuthority,
    this.authoritativeNextDecision,
  });

  static const current = CalmHomeProjection(
    summaries: [
      HomeStateSummary(
        domain: HomeProjectedDomain.readiness,
        authority: HomeProjectionAuthority.notYetEstablished,
      ),
      HomeStateSummary(
        domain: HomeProjectedDomain.match,
        authority: HomeProjectionAuthority.notYetEstablished,
      ),
      HomeStateSummary(
        domain: HomeProjectedDomain.connection,
        authority: HomeProjectionAuthority.notYetEstablished,
      ),
      HomeStateSummary(
        domain: HomeProjectedDomain.conversation,
        authority: HomeProjectionAuthority.notYetEstablished,
      ),
    ],
    readinessAuthority: HomeProjectionAuthority.notYetEstablished,
  );

  final List<HomeStateSummary> summaries;
  final HomeProjectionAuthority readinessAuthority;
  final HomeNextDecision? authoritativeNextDecision;

  HomeNextDecision get nextDecision {
    if (readinessAuthority != HomeProjectionAuthority.authoritative) {
      return const HomeNextDecision(
        label: '前往准备状态',
        route: AppRouteNames.meReadiness,
      );
    }
    return authoritativeNextDecision ??
        const HomeNextDecision(label: '查看进展', route: AppRouteNames.progress);
  }
}
