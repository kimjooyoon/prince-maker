import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, Map<String, String>>> loadLocales() async {
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

void main() {
  testWidgets('home footer opens the environment atlas', (tester) async {
    await tester.pumpWidget(
        const Game({'title': '프린스 메이커', 'setting': '루멘', 'hero': '노아'}));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(500, 590));
    await tester.pump();
    expect(find.byKey(const ValueKey('8-1-0-0')), findsOneWidget);
  });

  testWidgets('environment atlas renders the six gameplay surfaces',
      (tester) async {
    final story = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    await tester.pumpWidget(Game(
      story,
      locales: await loadLocales(),
      initialSnapshot: const GameSnapshot(
        week: 1,
        coins: 12,
        fatigue: 0,
        selected: 0,
        persona: 0,
        page: 8,
        eventIndex: 0,
        stats: {'지혜': 4, '공감': 5, '용기': 3},
        history: [],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('8-1-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/environment-atlas.png'));
    await tester.tapAt(const Offset(650, 40));
    await tester.pump();
    expect(find.byKey(const ValueKey('8-1-0-0-en')), findsOneWidget);
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/environment-atlas-en.png'));
  });
}
