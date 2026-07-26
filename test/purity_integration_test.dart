import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<Map<String, dynamic>> play(String stat, int delta) async {
    final source = jsonDecode(await rootBundle.loadString('story/story.json')) as Map<String, dynamic>;
    final story = JsonStoryAdapter(source), session = GameSession(story, MemorySaveAdapter());
    while (session.world.progress[0]!.week < story.endingWeek) {
      session.choose(ActivityChosen(stat, delta, 0, 1, label: '$stat 집중'));
      final event = story.events.where((e) => e['week'] == session.world.progress[0]!.week).firstOrNull;
      if (event != null) {
        final choices = (event['choices'] as List).cast<Map<String, dynamic>>();
        final available = choices.where((c) => c['requiresStat'] == null || (session.world.stats[0]!.values[c['requiresStat']] ?? 0) >= (c['requiresMin'] as int? ?? 0)).toList();
        final choice = available.firstWhere((c) => c['stat'] == stat, orElse: () => available.first);
        session.chooseEvent(StoryChoiceMade(choice['stat'], choice['delta'], choice['coins'], choice['label'], bondId: choice['bondId'], bondDelta: choice['bondDelta'], requiresStat: choice['requiresStat'], requiresMin: choice['requiresMin'] ?? 0, line: choice['line']));
      }
    }
    final p = session.world.progress[0]!;
    final ending = resolveEnding(story, session.world.stats[0]!.values, bonds: p.bonds, milestones: p.milestones);
    return {'ending': ending['id'], 'stats': Map.of(session.world.stats[0]!.values), 'bonds': Map.of(p.bonds), 'trace': List.of(p.trace)};
  }

  test('same schedule budget yields distinct authored outcomes', () async {
    final wisdom = await play('지혜', 3), empathy = await play('공감', 3);
    expect(wisdom['ending'], 'stargazer-master');
    expect(empathy['ending'], 'gardener-master');
    expect(wisdom['stats'], isNot(equals(empathy['stats'])));
    expect(wisdom['bonds'], isNot(equals(empathy['bonds'])));
    expect((wisdom['trace'] as List).length, (empathy['trace'] as List).length);
  });

  test('same schedule and event policy replay identically', () async {
    final first = await play('지혜', 3), replay = await play('지혜', 3);
    expect(replay, equals(first));
  });
}
