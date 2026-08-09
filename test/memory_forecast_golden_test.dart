import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, dynamic>> loadMemoryStory() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

Future<Map<String, Map<String, String>>> loadMemoryLocales() async => {
      for (final locale in ['ko', 'en'])
        locale: decodeJsonlCatalog(utf8.decode(
            (await rootBundle.load('story/locales/$locale.jsonl'))
                .buffer
                .asUint8List()))
    };

void main() {
  testWidgets('event shows the authored memory impact before commit',
      (tester) async {
    final story = await loadMemoryStory();
    final eventIndex =
        (story['events'] as List).indexWhere((event) => event['week'] == 12);
    await tester.pumpWidget(Game(story,
        locales: await loadMemoryLocales(),
        initialSnapshot: GameSnapshot(
          week: 12,
          coins: 12,
          fatigue: 0,
          selected: 0,
          persona: 0,
          page: 3,
          eventIndex: eventIndex,
          stats: const {'지혜': 12, '공감': 10, '용기': 9},
          history: const [],
        )));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('3-12-0-$eventIndex')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/memory-forecast.png'));
  });
}
