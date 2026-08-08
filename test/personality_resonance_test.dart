import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('personality focus talent closes the route loop', () async {
    final source = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final story = JsonStoryAdapter(source), people = story.personalities;
    final signatures = <String>[];
    for (var index = 0; index < people.length; index++) {
      final person = people[index], focus = person['focusStat'] as String;
      final other = story.activities
          .map((activity) => activity['stat'] as String)
          .firstWhere((stat) => stat != focus);
      GameSession play(String stat) {
        final session = GameSession(story, MemorySaveAdapter());
        session.world.progress[0]!.persona = index;
        session.choose(ActivityChosen(stat, 1, 0, 0, label: 'resonance'));
        return session;
      }

      final focused = play(focus),
          unfocused = play(other),
          initial =
              GameSession(story, MemorySaveAdapter()).world.stats[0]!.values,
          expected = initial[focus]! + 1 + (person['focusBonus'] as int);
      expect(focused.world.stats[0]!.values[focus], expected);
      expect(unfocused.world.stats[0]!.values[other], initial[other]! + 1);
      expect(unfocused.world.stats[0]!.values[focus], initial[focus]);
      final replay = play(focus);
      signatures.add(
          '${focused.world.stats[0]!.values}|${focused.world.progress[0]!.trace}');
      expect(signatures.last,
          '${replay.world.stats[0]!.values}|${replay.world.progress[0]!.trace}');
    }
    expect(people.map((person) => person['focusStat']).toSet(),
        hasLength(people.length));
    expect(signatures, hasLength(people.length));
  });
}
