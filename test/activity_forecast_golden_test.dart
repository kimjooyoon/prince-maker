import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, dynamic>> loadForecastStory() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

Future<Map<String, Map<String, String>>> loadForecastLocales() async => {
      for (final locale in ['ko', 'en'])
        locale: decodeJsonlCatalog(utf8.decode(
            (await rootBundle.load('story/locales/$locale.jsonl'))
                .buffer
                .asUint8List()))
    };

void main() {
  testWidgets('home shows deterministic activity forecasts', (tester) async {
    await tester.pumpWidget(Game(await loadForecastStory(),
        locales: await loadForecastLocales(),
        initialSnapshot: const GameSnapshot(
          week: 8,
          coins: 12,
          fatigue: 8,
          selected: 0,
          persona: 0,
          page: 0,
          eventIndex: 0,
          stats: {'지혜': 12, '공감': 10, '용기': 9},
          history: [],
        )));
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-8-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/activity-forecast.png'));
  });
}
