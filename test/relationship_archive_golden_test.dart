import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, Map<String, String>>> loadRelationshipLocales() async {
  final locales = <String, Map<String, String>>{};
  for (final locale in ['ko', 'en']) {
    final raw = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/locales/$locale.jsonl'))
            .buffer
            .asUint8List())) as Map;
    locales[locale] = raw.map((key, value) => MapEntry('$key', '$value'));
  }
  return locales;
}

Future<void> pumpRelationshipArchive(WidgetTester tester, int persona) async {
  final story = decodeJsonl(utf8.decode(
      (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
  await tester.pumpWidget(Game(
    story,
    key: ValueKey('relationship-archive-$persona'),
    locales: await loadRelationshipLocales(),
    initialSnapshot: GameSnapshot(
      week: 1,
      coins: 12,
      fatigue: 0,
      selected: 0,
      persona: persona,
      page: 11,
      eventIndex: 0,
      stats: const {'지혜': 4, '공감': 5, '용기': 3},
      history: const [],
    ),
  ));
  await tester.pumpAndSettle();
  await tester
      .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
  await tester.pump();
}

void main() {
  testWidgets('relationship archive renders the resolved state and follow-up',
      (tester) async {
    await pumpRelationshipArchive(tester, 0);
    expect(find.byKey(const ValueKey('11-1-0-0')), findsOneWidget);
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/relationship-archive.png'));
    await tester.tapAt(const Offset(650, 40));
    await tester.pump();
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/relationship-archive-en.png'));
  });

  testWidgets('relationship archive renders all personality resonance states',
      (tester) async {
    await pumpRelationshipArchive(tester, 1);
    expect(find.byKey(const ValueKey('11-1-1-0')), findsOneWidget);
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/relationship-archive-kind.png'));

    await pumpRelationshipArchive(tester, 2);
    expect(find.byKey(const ValueKey('11-1-2-0')), findsOneWidget);
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/relationship-archive-bold.png'));
  });
}
