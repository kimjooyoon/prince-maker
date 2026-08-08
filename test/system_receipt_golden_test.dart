import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, dynamic>> story() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

Future<Map<String, Map<String, String>>> locales() async {
  final result = <String, Map<String, String>>{};
  for (final locale in ['ko', 'en']) {
    final raw = decodeJsonl(utf8.decode((await rootBundle
            .load('story/locales/$locale.jsonl'))
        .buffer
        .asUint8List())) as Map;
    result[locale] = raw.map((key, value) => MapEntry('$key', '$value'));
  }
  return result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('ledger renders system-owned decision receipts', (tester) async {
    final source = await story();
    final snapshot = GameSnapshot(
      week: 17,
      coins: 18,
      fatigue: 2,
      selected: 0,
      persona: 0,
      page: 5,
      eventIndex: 15,
      stats: {'지혜': 18, '공감': 20, '용기': 16},
      bonds: {'lumi': 8, 'bora': 5, 'taro': 3},
      milestones: {'spring': true},
      flags: {'first-ledger': true},
      history: const [
        'approval:approved|owner:Lumen Ledger System|kind:activity|'
            'subject:별 관측|week:16|rule:input-contract|'
            'contract:lumen-ledger|preconditionHash:aaaabbbb|'
            'parentDecisionHash:genesis|decisionHash:1a2b3c4d',
        'activity:지혜+3',
        'approval:rejected|owner:Lumen Ledger System|kind:story-choice|'
            'subject:잠긴 질문|week:17|rule:input-contract-rejected|'
            'contract:lumen-ledger|preconditionHash:ccccdddd|'
            'parentDecisionHash:1a2b3c4d|decisionHash:5e6f7a8b',
      ],
    );
    await tester.pumpWidget(
        Game(source, locales: await locales(), initialSnapshot: snapshot));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('5-17-0-15')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/system-receipt.png'));
  });
}
