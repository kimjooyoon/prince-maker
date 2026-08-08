import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/decision_receipt.dart';

void main() {
  test('parses an immutable approval trace and preserves its hash', () {
    final receipt = DecisionReceipt.parse(
        'approval:approved|owner:Lumen Ledger System|kind:story-choice|'
        'subject:첫 질문:기록|week:17|rule:input-contract|'
        'contract:lumen-ledger|preconditionHash:abc12345|'
        'parentDecisionHash:genesis|decisionHash:1a2b3c4d5e');

    expect(receipt, isNotNull);
    expect(receipt!.approved, isTrue);
    expect(receipt.subject, '첫 질문:기록');
    expect(receipt.week, 17);
    expect(receipt.shortHash, '1a2b3c4d');
    expect(receipt.shortPreconditionHash, 'abc12345');
  });

  test('projects only the latest three valid decisions', () {
    final traces = [
      for (var i = 1; i <= 4; i++)
        'approval:rejected|kind:activity|subject:a$i|week:$i|'
            'decisionHash:hash$i',
      'activity:지혜+3',
    ];

    final receipts = recentDecisionReceipts(traces);
    expect(receipts, hasLength(3));
    expect(receipts.first.subject, 'a4');
    expect(receipts.last.subject, 'a2');
  });

  test('fails closed for malformed approval status', () {
    expect(
        DecisionReceipt.parse(
            'approval:maybe|kind:activity|week:1|decisionHash:bad'),
        isNull);
  });
}
