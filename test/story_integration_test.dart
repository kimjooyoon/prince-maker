import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('canonical SSOT completes a deterministic 12-week route', () async {
    final source = jsonDecode(await rootBundle.loadString('story/story.json')) as Map<String, dynamic>;
    final story = JsonStoryAdapter(source), session = GameSession(story, MemorySaveAdapter());
    while (session.world.progress[0]!.week < story.endingWeek) {
      session.choose(const ActivityChosen('지혜', 3, 0, 1, label: '별 관측'));
      final events = story.events.where((e) => e['week'] == session.world.progress[0]!.week).toList();
      if (events.isNotEmpty) {
        final choices = (events.first['choices'] as List).cast<Map<String, dynamic>>();
        final choice = choices.firstWhere((c) => c['requiresStat'] == null || (session.world.stats[0]!.values[c['requiresStat']] ?? 0) >= (c['requiresMin'] as int? ?? 0));
        session.chooseEvent(StoryChoiceMade(choice['stat'], choice['delta'], choice['coins'], choice['label'], bondId: choice['bondId'], bondDelta: choice['bondDelta']));
      }
    }
    final progress = session.world.progress[0]!, ending = resolveEnding(story, session.world.stats[0]!.values, bonds: progress.bonds, milestones: progress.milestones);
    expect(progress.week, 12);
    expect(progress.milestones.length, 4);
    expect(progress.bonds['bora'], 12);
    expect(ending['id'], 'stargazer-master');
    expect(ending['epilogue'], isNotNull);
    expect(progress.trace.where((e) => e.startsWith('milestone:')).length, 4);
  });
}
