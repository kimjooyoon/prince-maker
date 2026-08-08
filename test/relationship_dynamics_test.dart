import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('deterministic relationship states', () async {
    final source = jsonDecode(utf8.decode(
            (await rootBundle.load('story/story.json')).buffer.asUint8List()))
        as Map<String, dynamic>;
    final story = JsonStoryAdapter(source);
    final cases = [
      ({'lumi': 0, 'bora': 0, 'taro': 0}, <String, bool>{}, 'unformed'),
      ({'lumi': 3, 'bora': 3, 'taro': 2}, <String, bool>{}, 'balanced'),
      ({'lumi': 5, 'bora': 3, 'taro': 1}, <String, bool>{}, 'tension'),
      ({'lumi': 8, 'bora': 2, 'taro': 0}, <String, bool>{}, 'estranged'),
      ({'lumi': 8, 'bora': 2, 'taro': 0}, {'windmill-truce': true}, 'truce'),
    ];
    for (final item in cases) {
      final first = resolveRelationshipDynamics(story, item.$1, item.$2);
      final replay = resolveRelationshipDynamics(story, item.$1, item.$2);
      expect(first['id'], item.$3);
      expect(jsonEncode(first), jsonEncode(replay));
    }
  });

  test('accepted choice records relationship state in ECS replay trace',
      () async {
    final source = jsonDecode(utf8.decode(
            (await rootBundle.load('story/story.json')).buffer.asUint8List()))
        as Map<String, dynamic>;
    final session = GameSession(JsonStoryAdapter(source), MemorySaveAdapter());
    session.chooseEvent(const StoryChoiceMade('용기', 2, 0, '관계 상태 기록',
        bondId: 'lumi', bondDelta: 6, rivalId: 'bora', rivalDelta: -1));
    expect(session.world.progress[0]!.trace,
        contains('relationship:estranged|gap:6'));
  });
}
