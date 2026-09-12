import 'package:flutter_elitesync_module/features/connection/domain/product_connection_contract.dart';

enum ConnectionEvidenceAuthority { authoritative, notYetEstablished }

class ConnectionPresentationState {
  const ConnectionPresentationState.authoritative(this.state)
    : authority = ConnectionEvidenceAuthority.authoritative;

  const ConnectionPresentationState.notYetEstablished()
    : state = null,
      authority = ConnectionEvidenceAuthority.notYetEstablished;

  final ProductConnectionState? state;
  final ConnectionEvidenceAuthority authority;

  bool get hasAuthoritativeState =>
      authority == ConnectionEvidenceAuthority.authoritative && state != null;
}
