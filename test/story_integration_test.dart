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
        final choice = (events.first['choices'] as List).first as Map<String, dynamic>;
        session.chooseEvent(StoryChoiceMade(choice['stat'], choice['delta'], choice['coins'], choice['label'], bondId: choice['bondId'], bondDelta: choice['bondDelta']));
      }
    }
    final progress = session.world.progress[0]!, ending = resolveEnding(story, session.world.stats[0]!.values, progress.bonds);
    expect(progress.week, 12);
    expect(progress.milestones.length, 4);
    expect(progress.bonds['bora'], 8);
    expect(ending['epilogue'], isNotNull);
    expect(progress.trace.where((e) => e.startsWith('milestone:')).length, 4);
  });
}
