import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, dynamic>> loadStory() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

Future<Map<String, Map<String, String>>> loadLocales() async => {
      for (final locale in ['ko', 'en'])
        locale: decodeJsonlCatalog(utf8.decode(
            (await rootBundle.load('story/locales/$locale.jsonl'))
                .buffer
                .asUint8List()))
    };

const emptyStats = {'지혜': 4, '공감': 5, '용기': 3};

void main() {
  testWidgets('English home is a player-facing core-loop Golden',
      (tester) async {
    await tester.pumpWidget(Game(await loadStory(),
        locales: await loadLocales(),
        initialSnapshot: const GameSnapshot(
          week: 1,
          coins: 12,
          fatigue: 0,
          selected: 0,
          persona: 0,
          page: 1,
          eventIndex: 0,
          stats: emptyStats,
          history: [],
        )));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(650, 50));
    await tester.pump();
    await tester.tapAt(const Offset(600, 560));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-1-0-0-en')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/player-home-en.png'));
  });

  testWidgets('save archive hides raw trace and renders localized summaries',
      (tester) async {
    final story = await loadStory(), locales = await loadLocales();
    const snapshot = GameSnapshot(
      week: 8,
      coins: 17,
      fatigue: 4,
      selected: 0,
      persona: 0,
      page: 4,
      eventIndex: 0,
      stats: emptyStats,
      history: [
        'activity:지혜+3',
        'event:루미에게 별의 이름을 묻는다|line:이름을 부르면 낯선 것도 조금 가까워져.',
        'approval:internal-hash',
      ],
    );
    await tester
        .pumpWidget(Game(story, locales: locales, initialSnapshot: snapshot));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('4-8-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/player-save.png'));
    await tester.tapAt(const Offset(650, 50));
    await tester.pump();
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/player-save-en.png'));
  });
}
