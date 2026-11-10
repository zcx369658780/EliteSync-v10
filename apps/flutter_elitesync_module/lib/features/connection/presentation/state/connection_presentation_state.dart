import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';

enum ConnectionEvidenceAuthority {
  authoritative,
  syntheticDevelopment,
  notYetEstablished,
}

class ConnectionPresentationState {
  const ConnectionPresentationState.authoritative(this.state)
    : authority = ConnectionEvidenceAuthority.authoritative;

  const ConnectionPresentationState.notYetEstablished()
    : state = null,
      authority = ConnectionEvidenceAuthority.notYetEstablished;

  const ConnectionPresentationState.syntheticDevelopment(this.state)
    : authority = ConnectionEvidenceAuthority.syntheticDevelopment;

  final ProductConnectionState? state;
  final ConnectionEvidenceAuthority authority;

  bool get hasAuthoritativeState =>
      authority == ConnectionEvidenceAuthority.authoritative && state != null;

  bool get hasSyntheticDevelopmentState =>
      authority == ConnectionEvidenceAuthority.syntheticDevelopment &&
      state != null;
}
