import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/shared/explainability/explainability_contract.dart';

void main() {
  test('explainability contract carries every required explanation field', () {
    const content = ExplainabilityContent(
      whatHappened: 'Synthetic event',
      why: 'Synthetic reason',
      informationClasses: ['Synthetic class'],
      doesNotMean: 'Not verified truth',
      uncertaintyAndLimits: 'Synthetic limit',
      userControls: ['Synthetic correction'],
    );

    expect(content.whatHappened, isNotEmpty);
    expect(content.why, isNotEmpty);
    expect(content.informationClasses, isNotEmpty);
    expect(content.doesNotMean, contains('Not verified truth'));
    expect(content.uncertaintyAndLimits, isNotEmpty);
    expect(content.userControls, isNotEmpty);
  });
}
