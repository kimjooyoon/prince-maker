import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, dynamic>> loadJournalStory() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

Future<Map<String, Map<String, String>>> loadJournalLocales() async => {
      for (final locale in ['ko', 'en'])
        locale: decodeJsonlCatalog(utf8.decode(
            (await rootBundle.load('story/locales/$locale.jsonl'))
                .buffer
                .asUint8List()))
    };

void main() {
  testWidgets('activity journal renders deterministic reflection pages',
      (tester) async {
    await tester.pumpWidget(Game(await loadJournalStory(),
        locales: await loadJournalLocales(),
        initialSnapshot: const GameSnapshot(
          week: 1,
          coins: 12,
          fatigue: 0,
          selected: 0,
          persona: 0,
          page: 0,
          eventIndex: 0,
          stats: {'지혜': 4, '공감': 5, '용기': 3},
          history: [
            'activity-scene:observatory-mist',
            'activity-scene:garden-thin-leaf'
          ],
        )));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(500, 50));
    await tester.pump();
    expect(find.byKey(const ValueKey('12-1-0-0')), findsOneWidget);
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/activity-journal-ko.png'));
    await tester.tapAt(const Offset(650, 50));
    await tester.pump();
    expect(find.byKey(const ValueKey('12-1-0-0-en')), findsOneWidget);
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/activity-journal-en.png'));
  });
}
