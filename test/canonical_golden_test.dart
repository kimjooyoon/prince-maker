import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Map<String, dynamic> availableChoice(
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

void chooseAuthoredEvent(GameSession session, Map<String, dynamic> event) {
  final choice = availableChoice(session, event);
  session.chooseEvent(StoryChoiceMade(
      choice['stat'], choice['delta'], choice['coins'], choice['label'],
      bondId: choice['bondId'],
      bondDelta: choice['bondDelta'],
      rivalId: choice['rivalId'],
      rivalDelta: choice['rivalDelta'] ?? 0,
      requiresStat: choice['requiresStat'],
      requiresMin: choice['requiresMin'] ?? 0,
      requiresBondId: choice['requiresBondId'],
      requiresBondMin: choice['requiresBondMin'] ?? 0,
      requiresFlag: choice['requiresFlag'],
      setsFlag: choice['setsFlag'],
      line: choice['line']));
}

GameSnapshot routeSnapshot(Map<String, dynamic> source,
    {required int targetWeek, required int page}) {
  final story = JsonStoryAdapter(source),
      session = GameSession(story, MemorySaveAdapter());
  while (session.world.progress[0]!.week < targetWeek) {
    session.choose(const ActivityChosen('지혜', 3, 0, 1, label: '별 관측'));
    final week = session.world.progress[0]!.week;
    final event = story.events.where((e) => e['week'] == week).firstOrNull;
    if (event != null && week < targetWeek) chooseAuthoredEvent(session, event);
  }
  if (page == 3) {
    final eventIndex = story.events.indexWhere(
        (event) => event['week'] == session.world.progress[0]!.week);
    session.world.progress[0]!.eventIndex = eventIndex;
  } else if (page == 2) {
    session.world.progress[0]!.eventIndex = story.events.length - 1;
  }
  return session.snapshot(page: page);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
      'canonical SSOT renders a stable Canvas ending after the authored event',
      (tester) async {
    final source = decodeJsonl(utf8.decode(
            (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()))
        as Map;
    final eventSnapshot = routeSnapshot(Map<String, dynamic>.from(source),
        targetWeek: 4, page: 3);
    await tester.pumpWidget(Game(Map<String, dynamic>.from(source),
        initialSnapshot: eventSnapshot));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1000)));
    await tester.pump();
    expect(find.byKey(const ValueKey('3-4-0-2')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/canonical-event.png'));

    final handoffSnapshot = routeSnapshot(Map<String, dynamic>.from(source),
        targetWeek: (source['campaignWeeks'] as int), page: 3);
    await tester.pumpWidget(Game(Map<String, dynamic>.from(source),
        initialSnapshot: handoffSnapshot, key: const ValueKey('handoff')));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1000)));
    await tester.pump();
    final handoffIndex = handoffSnapshot.eventIndex;
    expect(find.byKey(ValueKey('3-${source['campaignWeeks']}-0-$handoffIndex')),
        findsOneWidget);
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/canonical-handoff-event.png'));

    final endingSnapshot = routeSnapshot(Map<String, dynamic>.from(source),
        targetWeek: (source['endingWeek'] as int), page: 2);
    await tester.pumpWidget(Game(Map<String, dynamic>.from(source),
        initialSnapshot: endingSnapshot, key: const ValueKey('ending')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
        find.byKey(ValueKey(
            '2-${source['endingWeek']}-0-${endingSnapshot.eventIndex}')),
        findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/canonical-ending.png'));
  });
}
