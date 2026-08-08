import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, dynamic>> loadStory() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

Map<String, dynamic> available(
    GameSession session, Map<String, dynamic> event) {
  final choices = (event['choices'] as List).cast<Map<String, dynamic>>();
  return choices.firstWhere((choice) =>
      (choice['requiresStat'] == null ||
          (session.world.stats[0]!.values[choice['requiresStat']] ?? 0) >=
              (choice['requiresMin'] as int? ?? 0)) &&
      (choice['requiresBondId'] == null ||
          (session.world.progress[0]!.bonds[choice['requiresBondId']] ?? 0) >=
              (choice['requiresBondMin'] as int? ?? 0)) &&
      (choice['requiresFlag'] == null ||
          session.world.progress[0]!.flags[choice['requiresFlag']] == true));
}

GameSnapshot closureSnapshot(Map<String, dynamic> source, int targetWeek) {
  final story = JsonStoryAdapter(source),
      session = GameSession(story, MemorySaveAdapter());
  while (session.world.progress[0]!.week < targetWeek) {
    session.choose(const ActivityChosen('지혜', 3, 0, 1, label: '별 관측'));
    final week = session.world.progress[0]!.week,
        event = story.events.where((e) => e['week'] == week).firstOrNull;
    if (event == null) continue;
    final choice = available(session, event);
    session.chooseEvent(StoryChoiceMade(
        choice['stat'], choice['delta'], choice['coins'], choice['label'],
        bondId: choice['bondId'],
        bondDelta: choice['bondDelta'] ?? 0,
        rivalId: choice['rivalId'],
        rivalDelta: choice['rivalDelta'] ?? 0,
        requiresStat: choice['requiresStat'],
        requiresMin: choice['requiresMin'] ?? 0,
        requiresBondId: choice['requiresBondId'],
        requiresBondMin: choice['requiresBondMin'] ?? 0,
        requiresFlag: choice['requiresFlag'],
        setsFlag: choice['setsFlag'],
        line: choice['line'] ?? ''));
  }
  return session.snapshot(page: 6);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
      'all sixteen SSOT chapter closures have deterministic goal Goldens',
      (tester) async {
    final source = await loadStory();
    final chapters =
        (source['progression'] as List).cast<Map<String, dynamic>>();
    for (final chapter in chapters) {
      final id = '${chapter['id']}',
          week = chapter['weekEnd'] as int,
          snapshot = closureSnapshot(source, week);
      expect(snapshot.milestones.containsKey(chapter['milestoneId']), true,
          reason: '$id week=$week milestone=${chapter['milestoneId']}');
      final scene = (chapter['relationshipScene'] as Map?) ?? const {};
      expect(scene['speakerId'], isNotNull,
          reason: '$id relationship scene must bind a speaker');
      expect(scene['lineKey'], isA<String>(),
          reason: '$id relationship scene must bind locale text');
      await tester.pumpWidget(
          Game(source, initialSnapshot: snapshot, key: ValueKey(id)));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      expect(find.byKey(ValueKey('6-${snapshot.week}-0-0')), findsOneWidget);
      await expectLater(find.byType(Game),
          matchesGoldenFile('goldens/chapter-closure-$id.png'));
    }
  });
}
