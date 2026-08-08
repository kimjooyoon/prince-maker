import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, Map<String, String>>> loadSideSceneLocales() async {
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
  testWidgets('side scene archive renders ko and en illustration',
      (tester) async {
    final story = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    await tester.pumpWidget(Game(
      story,
      locales: await loadSideSceneLocales(),
      initialSnapshot: const GameSnapshot(
        week: 48,
        coins: 12,
        fatigue: 0,
        selected: 0,
        persona: 0,
        page: 9,
        eventIndex: 0,
        stats: {'지혜': 4, '공감': 5, '용기': 3},
        history: [],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1000)));
    await tester.pumpAndSettle();
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/side-scene.png'));
    await tester.tapAt(const Offset(650, 50));
    await tester.pump();
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/side-scene-en.png'));
  });
}
