import 'package:flutter_test/flutter_test.dart';
import '../tool/ci_gate.dart';

void main() {
  test('gate evidence continues after a failure and keeps every status', () async {
    const checks = [
      GateCheck('completeness', 'fake', []),
      GateCheck('purity', 'fake', []),
      GateCheck('performance', 'fake', []),
    ];
    final seen = <String>[];
    final results = await evaluateChecks(checks, (check) async {
      seen.add(check.id);
      return check.id == 'completeness' ? 1 : 0;
    });

    expect(seen, ['completeness', 'purity', 'performance']);
    expect(
      results.map((result) => result['status']).toList(),
      ['fail', 'pass', 'pass'],
    );
    expect(
      results.map((result) => result['exitCode']).toList(),
      [1, 0, 0],
    );
  });
}
