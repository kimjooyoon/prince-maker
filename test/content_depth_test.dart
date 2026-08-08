import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/jsonl.dart';

Future<Map<String, dynamic>> loadStory() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SSOT exposes depth targets and all non-binary scene mechanics',
      () async {
    final story = await loadStory();
    final sideScenes =
        (story['sideScenes'] as List).cast<Map<String, dynamic>>();
    final types = sideScenes.map((scene) => scene['sceneType']).toSet();
    expect((story['events'] as List), hasLength(47));
    expect(sideScenes, hasLength(24));
    expect((story['events'] as List).length + sideScenes.length, 71);
    expect(
        types,
        containsAll(
            {'exploration', 'resource-crisis', 'mini-game', 'companion-pair'}));
    expect((story['locations'] as List), hasLength(6));
    expect((story['companionScenes'] as List), hasLength(18));
    expect((story['activityScenes'] as List), hasLength(10));
    expect((story['endingVariants'] as List), hasLength(18));
    expect((story['dialogueMetrics'] as Map)['authoredDialogueLines'], 612);
  });

  test('side scene and activity mini-event leave deterministic core traces',
      () async {
    final story = await loadStory();
    final session = GameSession(JsonStoryAdapter(story), MemorySaveAdapter(),
        autoPersist: false);
    session.chooseSideScene('sideArchiveLantern', 0);
    final snapshot = session.snapshot();
    expect(snapshot.flags['side-scene:sideArchiveLantern'], isTrue);
    expect(snapshot.history.any((entry) => entry.startsWith('side-scene:')),
        isTrue);
    expect(snapshot.history.any((entry) => entry.startsWith('event:')), isTrue);

    final activitySession = GameSession(
        JsonStoryAdapter(story), MemorySaveAdapter(),
        autoPersist: false);
    activitySession.choose(const ActivityChosen('지혜', 3, 0, 1,
        label: '별 관측', activityId: 'observatory'));
    expect(activitySession.snapshot().history,
        contains('activity-scene:observatory-late'));
    expect(activitySession.snapshot().lastLine, isNotEmpty);
  });

  test('ending variants resolve by failure, neutral and relationship state',
      () async {
    final story = await loadStory();
    final model = JsonStoryAdapter(story);
    final baseStats = {'지혜': 12, '공감': 0, '용기': 0};
    final failure = resolveEnding(model, baseStats,
        bonds: {'lumi': 0, 'bora': 0, 'taro': 0});
    expect(failure['endingVariant'], 'failure');
    final neutral = resolveEnding(model, baseStats,
        bonds: {'lumi': 0, 'bora': 0, 'taro': 0}, milestones: {'spring': true});
    expect(neutral['endingVariant'], 'neutral');
    final relationship = resolveEnding(model, baseStats,
        bonds: {'lumi': 8, 'bora': 0, 'taro': 0});
    expect(relationship['endingVariant'], 'relationship');
    expect(relationship['variantTitle'], isNotEmpty);
  });
}
