import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<Map<String, dynamic>> play(String stat, int persona) async {
    final source = jsonDecode(await rootBundle.loadString('story/story.json'))
        as Map<String, dynamic>;
    final story = JsonStoryAdapter(source),
        session = GameSession(story, MemorySaveAdapter());
    session.world.progress[0]!.persona = persona;
    final delta = stat == '용기' ? 2 : 3;
    while (session.world.progress[0]!.week < story.endingWeek) {
      session.choose(ActivityChosen(stat, delta, 0, 1, label: '$stat 루트'));
      final events = story.events
          .where((e) => e['week'] == session.world.progress[0]!.week)
          .toList();
      if (events.isNotEmpty) {
        final choices =
            (events.first['choices'] as List).cast<Map<String, dynamic>>();
        final available = choices
            .where((c) =>
                (c['requiresStat'] == null ||
                    (session.world.stats[0]!.values[c['requiresStat']] ?? 0) >=
                        (c['requiresMin'] as int? ?? 0)) &&
                (c['requiresBondId'] == null ||
                    (session.world.progress[0]!.bonds[c['requiresBondId']] ??
                            0) >=
                        (c['requiresBondMin'] as int? ?? 0)) &&
                (c['requiresFlag'] == null ||
                    session.world.progress[0]!.flags[c['requiresFlag']] ==
                        true))
            .toList();
        final choice = available.firstWhere((c) => c['stat'] == stat,
            orElse: () => available.first);
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
            setsFlag: choice['setsFlag']));
      }
    }
    final p = session.world.progress[0]!;
    return resolveEnding(story, session.world.stats[0]!.values,
        bonds: p.bonds, milestones: p.milestones);
  }

  test('canonical SSOT completes a deterministic 12-week route', () async {
    final source = jsonDecode(await rootBundle.loadString('story/story.json'))
        as Map<String, dynamic>;
    final story = JsonStoryAdapter(source),
        session = GameSession(story, MemorySaveAdapter());
    while (session.world.progress[0]!.week < story.endingWeek) {
      session.choose(const ActivityChosen('지혜', 3, 0, 1, label: '별 관측'));
      final events = story.events
          .where((e) => e['week'] == session.world.progress[0]!.week)
          .toList();
      if (events.isNotEmpty) {
        final choices =
            (events.first['choices'] as List).cast<Map<String, dynamic>>();
        final choice = choices.firstWhere((c) =>
            (c['requiresStat'] == null ||
                (session.world.stats[0]!.values[c['requiresStat']] ?? 0) >=
                    (c['requiresMin'] as int? ?? 0)) &&
            (c['requiresBondId'] == null ||
                (session.world.progress[0]!.bonds[c['requiresBondId']] ?? 0) >=
                    (c['requiresBondMin'] as int? ?? 0)) &&
            (c['requiresFlag'] == null ||
                session.world.progress[0]!.flags[c['requiresFlag']] == true));
        session.chooseEvent(StoryChoiceMade(
            choice['stat'], choice['delta'], choice['coins'], choice['label'],
            bondId: choice['bondId'],
            bondDelta: choice['bondDelta'],
            rivalId: choice['rivalId'],
            rivalDelta: choice['rivalDelta'] ?? 0,
            requiresBondId: choice['requiresBondId'],
            requiresBondMin: choice['requiresBondMin'] ?? 0,
            requiresFlag: choice['requiresFlag'],
            setsFlag: choice['setsFlag'],
            line: choice['line']));
      }
    }
    final progress = session.world.progress[0]!,
        ending = resolveEnding(story, session.world.stats[0]!.values,
            bonds: progress.bonds, milestones: progress.milestones);
    expect(progress.week, 12);
    expect(progress.milestones.length, 4);
    expect(progress.bonds['bora'], 11);
    expect(
        progress.flags.keys.where((key) => key.startsWith('place:')).toSet(), {
      'place:archive',
      'place:greenhouse',
      'place:market',
      'place:river-road'
    });
    expect(
        progress.trace.where((entry) => entry.startsWith('location:')).length,
        4);
    expect(ending['id'], 'stargazer-master');
    expect(ending['epilogue'], isNotNull);
    expect(progress.trace.where((e) => e.startsWith('milestone:')).length, 4);
  });
  test('all three personality routes reach their authored master ending',
      () async {
    expect((await play('지혜', 0))['id'], 'stargazer-master');
    expect((await play('공감', 1))['id'], 'gardener-master');
    expect((await play('용기', 2))['id'], 'pathfinder-master');
  });
  test('every authored ending and event choice is reachable under its contract',
      () async {
    final source = jsonDecode(await rootBundle.loadString('story/story.json'))
        as Map<String, dynamic>;
    final story = JsonStoryAdapter(source);
    for (final ending in story.endings) {
      final stats = {'지혜': 1, '공감': 1, '용기': 1};
      stats[ending['stat'] as String] = (ending['min'] as int) + 10;
      final milestones = {
        for (final id in (ending['requiresMilestones'] as List? ?? const []))
          '$id': true
      };
      expect(resolveEnding(story, stats, milestones: milestones)['id'],
          ending['id']);
    }
    for (final event in story.events) {
      for (final raw
          in (event['choices'] as List).cast<Map<String, dynamic>>()) {
        final session = GameSession(story, MemorySaveAdapter());
        final required = raw['requiresStat'] as String?;
        final requiredBond = raw['requiresBondId'] as String?;
        if (required != null)
          session.world.stats[0]!.values[required] = raw['requiresMin'] as int;
        if (requiredBond != null)
          session.world.progress[0]!.bonds[requiredBond] =
              raw['requiresBondMin'] as int;
        final requiredFlag = raw['requiresFlag'] as String?;
        if (requiredFlag != null)
          session.world.progress[0]!.flags[requiredFlag] = true;
        final before = session.world.stats[0]!.values[raw['stat'] as String]!;
        session.chooseEvent(StoryChoiceMade(
            raw['stat'], raw['delta'], raw['coins'], raw['label'],
            bondId: raw['bondId'],
            bondDelta: raw['bondDelta'],
            rivalId: raw['rivalId'],
            rivalDelta: raw['rivalDelta'] ?? 0,
            requiresStat: required,
            requiresMin: raw['requiresMin'] ?? 0,
            requiresBondId: requiredBond,
            requiresBondMin: raw['requiresBondMin'] ?? 0,
            requiresFlag: requiredFlag,
            setsFlag: raw['setsFlag'],
            line: raw['line']));
        expect(session.world.stats[0]!.values[raw['stat'] as String],
            before + (raw['delta'] as int));
        expect(session.world.progress[0]!.trace.last,
            startsWith('event:${raw['label']}'));
      }
    }
  });
}
