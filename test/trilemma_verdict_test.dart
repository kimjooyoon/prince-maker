import 'package:flutter_test/flutter_test.dart';
import '../tool/trilemma_verdict.dart';

void main() {
  test('every trilemma axis rejects missing evidence', () {
    final verdict = buildTrilemmaVerdict('ci', [
      {'id': 'ci-policy', 'status': 'pass'},
      {'id': 'story-contract', 'status': 'pass'},
    ]);
    final axes = (verdict['axes'] as Map).cast<String, dynamic>();
    expect(verdict['decision'], 'reject');
    expect(axes.values.every((axis) => axis['status'] == 'fail'), isTrue);
    expect(axes['performance']['missingChecks'], isNotEmpty);
  });

  test('all CI evidence produces a three-axis approval', () {
    final ids = requiredAxes('ci').values.expand((ids) => ids).toSet();
    final verdict = buildTrilemmaVerdict(
        'ci', ids.map((id) => {'id': id, 'status': 'pass'}).toList());
    final axes = (verdict['axes'] as Map).cast<String, dynamic>();
    expect(verdict['decision'], 'approve');
    expect(axes.values.every((axis) => axis['status'] == 'pass'), isTrue);
  });
}
