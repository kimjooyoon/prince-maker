import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, Map<String, String>>> loadEventArtLocales() async {
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
  testWidgets('ko and en event surfaces render the authored illustration',
      (tester) async {
    final story = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    await tester.pumpWidget(Game(
      story,
      locales: await loadEventArtLocales(),
      initialSnapshot: const GameSnapshot(
        week: 2,
        coins: 12,
        fatigue: 0,
        selected: 0,
        persona: 0,
        page: 3,
        eventIndex: 0,
        stats: {'지혜': 4, '공감': 5, '용기': 3},
        history: [],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1000)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('3-2-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/event-art.png'));
    await tester.tapAt(const Offset(650, 50));
    await tester.pump();
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/event-art-en.png'));
  });
}
