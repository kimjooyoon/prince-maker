import 'dart:convert';
import 'dart:io';

import 'package:prince_maker/jsonl.dart';

// content-depth-gate: the SSOT evidence check for authored scene density.

Never fail(String message) {
  stderr.writeln('CONTENT_DEPTH_GATE_FAIL: $message');
  exit(1);
}

int textUnits(Map<String, dynamic> item, List<String> fields) => fields
    .where(
        (field) => item[field] is String && '${item[field]}'.trim().isNotEmpty)
    .length;

void main() {
  final story = decodeJsonl(File('story/story.jsonl').readAsStringSync());
  final events = (story['events'] as List).cast<Map<String, dynamic>>();
  final sideScenes =
      (story['sideScenes'] as List? ?? const []).cast<Map<String, dynamic>>();
  final companionScenes = (story['companionScenes'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final activityScenes = (story['activityScenes'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final endingVariants = (story['endingVariants'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final locations =
      (story['locations'] as List? ?? const []).cast<Map<String, dynamic>>();
  final companions =
      (story['companions'] as List? ?? const []).cast<Map<String, dynamic>>();
  final activities =
      (story['activities'] as List? ?? const []).cast<Map<String, dynamic>>();
  final endings =
      (story['endings'] as List? ?? const []).cast<Map<String, dynamic>>();

  final sceneCount = events.length + sideScenes.length;
  final sideChoices = sideScenes.fold<int>(
      0, (sum, scene) => sum + (scene['choices'] as List).length);
  final sideTypes = sideScenes.map((scene) => '${scene['sceneType']}').toSet();
  const requiredTypes = {
    'exploration',
    'resource-crisis',
    'mini-game',
    'companion-pair'
  };
  final locationCounts = <String, int>{};
  final locationEvidence = <String, Map<String, bool>>{};
  for (final scene in sideScenes) {
    final location = '${scene['locationId']}';
    locationCounts[location] = (locationCounts[location] ?? 0) + 1;
    final evidence = locationEvidence.putIfAbsent(
        location,
        () => {
              'exploration': false,
              'reward': false,
              'relationship': false,
            });
    evidence['exploration'] =
        evidence['exploration'] == true || scene['sceneType'] == 'exploration';
    final choices = (scene['choices'] as List).cast<Map<String, dynamic>>();
    evidence['reward'] = evidence['reward'] == true ||
        choices.any((choice) => ((choice['coins'] as num?) ?? 0) > 0);
    evidence['relationship'] = evidence['relationship'] == true ||
        choices.any((choice) =>
            choice['bondId'] is String &&
            ((choice['bondDelta'] as num?) ?? 0) > 0);
  }
  final companionCounts = <String, int>{};
  for (final scene in companionScenes) {
    final companion = '${scene['companionId']}';
    companionCounts[companion] = (companionCounts[companion] ?? 0) + 1;
  }
  final activityCounts = <String, int>{};
  for (final scene in activityScenes) {
    final activity = '${scene['activityId']}';
    activityCounts[activity] = (activityCounts[activity] ?? 0) + 1;
  }
  final variantCounts = <String, int>{};
  for (final variant in endingVariants) {
    final core = '${variant['coreEndingId']}';
    variantCounts[core] = (variantCounts[core] ?? 0) + 1;
  }
  final sideDialogue = sideScenes.fold<int>(0, (sum, scene) {
    final choices = (scene['choices'] as List).cast<Map<String, dynamic>>();
    return sum +
        textUnits(scene, ['title', 'body', 'prompt', 'consequence']) +
        choices.fold<int>(
            0,
            (choiceSum, choice) =>
                choiceSum + textUnits(choice, ['label', 'line']));
  });
  final companionDialogue = companionScenes.fold<int>(
      0,
      (sum, scene) =>
          sum +
          textUnits(scene, ['title', 'body', 'prompt', 'line', 'closing']));
  final activityDialogue = activityScenes.fold<int>(
      0, (sum, scene) => sum + textUnits(scene, ['title', 'moment', 'line']));
  final endingDialogue = endingVariants.fold<int>(
      0, (sum, variant) => sum + textUnits(variant, ['title', 'body']));
  final dialogue = (story['dialogueMetrics'] as Map).cast<String, dynamic>();
  final baseDialogue = dialogue['baseAuthoredDialogueLines'] as int? ?? 0;
  final authoredDialogue = baseDialogue +
      sideDialogue +
      companionDialogue +
      activityDialogue +
      endingDialogue;
  final failures = <String>[];
  void require(bool condition, String message) {
    if (!condition) failures.add(message);
  }

  require(events.length == 47, 'main event count must remain 47');
  require(sideScenes.length >= 24, 'side scene count must be at least 24');
  require(sceneCount >= 70 && sceneCount <= 90,
      'authored scene total must be between 70 and 90');
  require(sideChoices >= 72, 'side scenes must expose at least 72 choices');
  require(requiredTypes.difference(sideTypes).isEmpty,
      'all four non-binary scene mechanics must be authored');
  require(locations.length >= 6 && locations.length <= 8,
      'location count must be between 6 and 8');
  require(
      locations.every((location) => (locationCounts[location['id']] ?? 0) >= 4),
      'every location must have at least four side scenes');
  require(locations.every((location) {
    final evidence = locationEvidence[location['id']] ?? const {};
    return evidence['exploration'] == true &&
        evidence['reward'] == true &&
        evidence['relationship'] == true;
  }), 'every location must expose exploration, reward and relationship evidence');
  require(
      companions.length == 3 &&
          companions.every(
              (companion) => (companionCounts[companion['id']] ?? 0) >= 5),
      'each of the three companions must have at least five independent scenes');
  require(
      activities.length == 5 &&
          activities
              .every((activity) => (activityCounts[activity['id']] ?? 0) >= 2),
      'each activity must have at least two mini events');
  require(
      endings.length == 6 &&
          endings.every((ending) => (variantCounts[ending['id']] ?? 0) == 3),
      'each core ending must have failure, neutral and relationship variants');
  require(
      authoredDialogue >= 600 &&
          dialogue['authoredDialogueLines'] == authoredDialogue,
      'authored dialogue evidence must be a true six-hundred-line closed sum');
  require(
      dialogue['minimumLocaleKeys'] is int &&
          (dialogue['minimumLocaleKeys'] as int) >= 800,
      'locale evidence must include the expanded authored catalog');
  require(
      sideScenes.every((scene) =>
          (scene['choices'] as List).length == 3 &&
          scene['titleKey'] is String &&
          scene['bodyKey'] is String &&
          scene['promptKey'] is String &&
          scene['consequenceKey'] is String),
      'side scenes must have three choices and four narrative locale keys');

  final measurements = {
    'mainEvents': events.length,
    'sideScenes': sideScenes.length,
    'authoredScenes': sceneCount,
    'mainChoices': events.fold<int>(
        0, (sum, event) => sum + (event['choices'] as List).length),
    'sideSceneChoices': sideChoices,
    'locations': locations.length,
    'companionScenes': companionScenes.length,
    'activityMiniEvents': activityScenes.length,
    'endingVariants': endingVariants.length,
    'sceneTypes': sideTypes.toList()..sort(),
    'dialogue': {
      'base': baseDialogue,
      'sideScenes': sideDialogue,
      'companionScenes': companionDialogue,
      'activityMiniEvents': activityDialogue,
      'endingVariants': endingDialogue,
      'authoredDialogueLines': authoredDialogue,
      'ssotClaim': dialogue['authoredDialogueLines'],
    },
    'locationSideSceneCounts': locationCounts,
    'locationEvidence': locationEvidence,
    'companionSceneCounts': companionCounts,
    'activitySceneCounts': activityCounts,
    'endingVariantCounts': variantCounts,
  };
  final report = {
    'schema': 'lumen-content-depth-verdict-v1',
    'decision': failures.isEmpty ? 'approve' : 'reject',
    'source': 'story/story.jsonl#content-depth',
    'measurements': measurements,
    'requirements': {
      'mainEvents': 47,
      'totalAuthoredScenes': '70..90',
      'sideSceneChoices': 72,
      'locations': '6..8',
      'locationSignals': 'exploration + reward + relationship per location',
      'companionScenesPerCompanion': 5,
      'activityMiniEventsPerActivity': 2,
      'endingVariantsPerCoreEnding': 3,
      'authoredDialogueLines': 600,
    },
    'failures': failures,
    'system': {
      'owner': 'Lumen Content Depth Gate',
      'mode': 'system-adjudicated',
      'humanApprovalRequired': false,
      'failureMode': 'fail-closed',
    },
  };
  final file = File('build/content-depth-verdict.json')
    ..parent.createSync(recursive: true);
  file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(report)}\n');
  if (failures.isNotEmpty) fail(failures.join('; '));
  stdout.writeln(
      'CONTENT_DEPTH_OK: scenes=$sceneCount sideChoices=$sideChoices dialogue=$authoredDialogue locations=${locations.length} companionScenes=${companionScenes.length} activityMiniEvents=${activityScenes.length} endingVariants=${endingVariants.length}');
}
