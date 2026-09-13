import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/privacy/presentation/state/privacy_control_projection.dart';

void main() {
  test('privacy projection distinguishes all eight required purposes', () {
    expect(
      PrivacyControlProjection.areas.map((area) => area.key),
      orderedEquals(const [
        'private-identity',
        'matching-inputs-readiness',
        'candidate-showcase',
        'product-connection',
        'private-conversation',
        'ai-private-support',
        'safety-restricted',
        'operational-minimum',
      ]),
    );

    for (final area in PrivacyControlProjection.areas) {
      expect(area.unresolved, isNotEmpty);
    }
    expect(PrivacyControlProjection.notYetEstablished, 'NOT YET ESTABLISHED');
  });
}
