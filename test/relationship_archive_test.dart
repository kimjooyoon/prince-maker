import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('relationship archive reuses the pure resolver projection', () async {
    final story = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final model = JsonStoryAdapter(story),
        bonds = {'lumi': 0, 'bora': 0, 'taro': 0},
        flags = <String, bool>{};
    final first = resolveRelationshipDynamics(model, bonds, flags);
    final followup = resolveRelationshipFollowup(model, first);
    final quests = resolveCompanionQuests(model, bonds, flags);
    expect(first['id'], 'unformed');
    expect(followup['stateId'], 'unformed');
    expect(quests, hasLength(3));
    expect(quests.every((quest) => quest['completedStages'] == 0), isTrue);
    expect(resolveRelationshipDynamics(model, bonds, flags), first);
  });
}
