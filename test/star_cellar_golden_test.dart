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

const cellarSnapshot = GameSnapshot(
  week: 1,
  coins: 12,
  fatigue: 0,
  selected: 0,
  persona: 0,
  page: 14,
  eventIndex: 0,
  stats: {'지혜': 4, '공감': 5, '용기': 3},
  history: [],
);

void main() {
  testWidgets('star cellar renders the authored room in ko and en',
      (tester) async {
    await tester.pumpWidget(Game(await loadStory(),
        locales: await loadLocales(), initialSnapshot: cellarSnapshot));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('14-1-0-0-0-3-3-false-false')),
        findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/star-cellar.png'));
    await tester.tapAt(const Offset(650, 40));
    await tester.pump();
    expect(find.byKey(const ValueKey('14-1-0-0-0-3-3-false-false-en')),
        findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/star-cellar-en.png'));
  });
}
