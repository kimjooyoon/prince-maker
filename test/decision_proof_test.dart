import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/decision_proof.dart';

void main() {
  test('same preconditions reproduce the same chain', () {
    SystemDecisionReceipt run(String state, [String parent = 'genesis']) =>
        SystemDecisionPolicy.evaluate(
            kind: 'activity',
            subject: '별 관측',
            week: 3,
            endingWeek: 49,
            conditions: true,
            owner: 'system',
            contract: 'ledger',
            preconditions: state,
            parentDecisionHash: parent);
    final first = run('week=3|stat=4'), replay = run('week=3|stat=4');
    expect(replay.trace, first.trace);
    expect(run('week=3|stat=5').decisionHash, isNot(first.decisionHash));
    expect(
        run('week=3|stat=4', 'other').decisionHash, isNot(first.decisionHash));
  });
}
