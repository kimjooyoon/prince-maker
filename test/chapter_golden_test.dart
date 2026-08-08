import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, dynamic>> loadStory() async => jsonDecode(utf8.decode(
        (await rootBundle.load('story/story.json')).buffer.asUint8List()))
    as Map<String, dynamic>;

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

GameSnapshot chapterSnapshot(Map<String, dynamic> source, int targetWeek) {
  final story = JsonStoryAdapter(source),
      session = GameSession(story, MemorySaveAdapter());
  while (session.world.progress[0]!.week < targetWeek) {
    session.choose(const ActivityChosen('지혜', 3, 0, 1, label: '별 관측'));
    final week = session.world.progress[0]!.week;
    if (week >= targetWeek) continue;
    final event = story.events.firstWhere((event) => event['week'] == week);
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
  session.world.progress[0]!.eventIndex =
      story.events.indexWhere((event) => event['week'] == targetWeek);
  return session.snapshot(page: 3);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('all sixteen SSOT chapters have deterministic event Goldens',
      (tester) async {
    final source = await loadStory();
    final chapters =
        (source['progression'] as List).cast<Map<String, dynamic>>();
    for (final chapter in chapters) {
      final week = (chapter['eventWeeks'] as List).first as int,
          id = '${chapter['id']}';
      final snapshot = chapterSnapshot(source, week);
      await tester.pumpWidget(
          Game(source, initialSnapshot: snapshot, key: ValueKey(id)));
      await tester.pumpAndSettle();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      expect(find.byKey(ValueKey('3-$week-0-${snapshot.eventIndex}')),
          findsOneWidget);
      await expectLater(
          find.byType(Game), matchesGoldenFile('goldens/chapter-$id.png'));
    }
  });
}
