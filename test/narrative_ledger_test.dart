import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';

Future<Map<String, dynamic>> loadStory() async => jsonDecode(utf8
    .decode((await rootBundle.load('story/story.json')).buffer.asUint8List()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('deterministic-projection keeps fate and companion loops replayable',
      () async {
    final source = await loadStory(), story = JsonStoryAdapter(source);
    final flags = <String, bool>{};
    for (final thread in story.fateThreads) flags['${thread['flag']}'] = true;
    for (final quest in story.companionQuests) {
      for (final stage in (quest['stages'] as List).cast<Map>()) {
        flags['${stage['flag']}'] = true;
      }
    }
    final bonds = {for (final c in story.companions) '${c['id']}': 8};
    final firstFates = resolveFateThreads(story, flags),
        firstQuests = resolveCompanionQuests(story, bonds, flags);
    expect(firstFates, hasLength(6));
    expect(firstFates.every((thread) => thread['discovered'] == true), isTrue);
    expect(firstQuests, hasLength(story.companions.length));
    expect(firstQuests.every((quest) => quest['completedStages'] == 3), isTrue);
    expect(firstQuests.every((quest) => quest['complete'] == true), isTrue);
    expect(firstFates, equals(resolveFateThreads(story, flags)));
    expect(firstQuests, equals(resolveCompanionQuests(story, bonds, flags)));
    print('NARRATIVE_LEDGER_OK: fates=6 quests=3 stages=9 deterministic=true');
  });
}
