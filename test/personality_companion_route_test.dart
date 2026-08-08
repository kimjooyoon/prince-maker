import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('personality-companion matrix changes accepted bonds and endings',
      () async {
    final source = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final story = JsonStoryAdapter(source),
        routes = story.companions
            .expand((companion) => story.personalities.map((person) =>
                resolvePersonalityCompanionRoute(story,
                    story.personalities.indexOf(person), '${companion['id']}')))
            .toList();
    expect(routes, hasLength(9));
    expect(routes.where((route) => route['matched'] == true), hasLength(3));
    for (final route in routes) {
      final persona = story.personalities
          .indexWhere((person) => person['id'] == route['personaId']);
      final companionId = '${route['companionId']}',
          session = GameSession(story, MemorySaveAdapter());
      session.world.progress[0]!.persona = persona;
      session.world.progress[0]!.bonds[companionId] = 7;
      session.chooseEvent(
          StoryChoiceMade('지혜', 0, 0, 'resonance', bondId: companionId));
      final bonds = session.world.progress[0]!.bonds,
          ending =
              resolveEnding(story, {'지혜': 60, '공감': 1, '용기': 1}, bonds: bonds);
      if (route['matched'] == true) {
        expect(bonds[companionId], 8);
        expect(ending['companionRouteIds'], contains(companionId));
        expect(session.world.progress[0]!.trace,
            contains(startsWith('resonance:${route['id']}')));
      } else {
        expect(bonds[companionId], 7);
        expect(ending['companionRouteIds'], isNot(contains(companionId)));
      }
    }
  });
}
