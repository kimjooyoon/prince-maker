import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:prince_maker/jsonl.dart';

import 'generate_event_storm.dart' as generator;

// event-storm-gate: fail-closed coverage and source-integrity check.

Never fail(String message) {
  stderr.writeln('EVENT_STORM_GATE_FAIL: $message');
  exit(1);
}

void main() {
  const storyPath = 'story/story.jsonl';
  const artifactPath = 'docs/event-storm.jsonl';
  if (!File(artifactPath).existsSync()) fail('missing $artifactPath');
  final story = decodeJsonl(File(storyPath).readAsStringSync());
  final actual = decodeJsonl(File(artifactPath).readAsStringSync());
  final expected = generator.buildEventStorm(
      story, sha256.convert(File(storyPath).readAsBytesSync()).toString());
  final source = actual['source'];
  if (actual['schema'] != 'lumen-event-storm-v1') fail('schema mismatch');
  if (source is! Map || source['ref'] != 'story/story.jsonl#root') {
    fail('source reference mismatch');
  }
  if (actual['source'].toString() != expected['source'].toString()) {
    fail('source hash mismatch');
  }
  final summary = (actual['summary'] as Map).cast<String, dynamic>();
  final nodes = (actual['nodes'] as List).cast<Map<String, dynamic>>();
  if (nodes.length != 133 || summary['nodeCount'] != 133) {
    fail('expected 133 authored event-storm nodes');
  }
  if (summary['choiceCount'] != 202 ||
      summary['companionChoiceCount'] != 36 ||
      summary['companionChoiceEffectCoverage'] != 1.0 ||
      summary['companionChoiceFeedbackCoverage'] != 1.0 ||
      summary['mainEvents'] != 47 ||
      summary['sideScenes'] != 24 ||
      summary['companionScenes'] != 18 ||
      summary['activityScenes'] != 10 ||
      summary['endingVariants'] != 18 ||
      summary['chapterClosures'] != 16) {
    fail('summary does not close over the authored unit counts');
  }
  if (summary['effectCoverage'] != 1.0 || summary['feedbackCoverage'] != 1.0) {
    fail('choice effect and feedback coverage must both be 1.0');
  }
  if ((summary['mechanics'] as List).toSet().difference({
    'exploration',
    'resource-crisis',
    'mini-game',
    'companion-pair',
  }).isNotEmpty) {
    fail('unexpected side scene mechanic');
  }
  if (!(summary['mechanics'] as List).toSet().containsAll({
    'exploration',
    'resource-crisis',
    'mini-game',
    'companion-pair',
  })) {
    fail('missing non-binary side scene mechanic');
  }
  final ids = nodes.map((node) => node['id']).toSet();
  if (ids.length != nodes.length) fail('event-storm node ids must be unique');
  final kinds = {
    'main-event': 47,
    'side-scene': 24,
    'companion-scene': 18,
    'activity-mini-event': 10,
    'ending-variant': 18,
    'chapter-closure': 16,
  };
  for (final entry in kinds.entries) {
    final count = nodes.where((node) => node['kind'] == entry.key).length;
    if (count != entry.value)
      fail('${entry.key} count $count != ${entry.value}');
  }
  final choiceNodes = nodes.where((node) =>
      node['kind'] == 'main-event' ||
      node['kind'] == 'side-scene' ||
      node['kind'] == 'companion-scene');
  var choiceCount = 0;
  for (final node in choiceNodes) {
    final commands = (node['commands'] as List);
    final domainEvents =
        (node['domainEvents'] as List).cast<Map<String, dynamic>>();
    if (commands.length != 2 && commands.length != 3) {
      fail('${node['id']} must expose two or three commands');
    }
    if (commands.length != domainEvents.length) {
      fail('${node['id']} command/domain event count mismatch');
    }
    choiceCount += commands.length;
    for (final event in domainEvents) {
      if ((event['axes'] as List).isEmpty || event['hasFeedback'] != true) {
        fail('${node['id']} has a choice without effect or feedback');
      }
    }
  }
  if (choiceCount != 202) fail('choice node total $choiceCount != 202');
  if (actual['responsibility'] is! Map ||
      (actual['responsibility'] as Map)['mode'] != 'system-adjudicated' ||
      (actual['responsibility'] as Map)['failureMode'] != 'fail-closed') {
    fail('responsibility boundary is not system-adjudicated fail-closed');
  }
  final actualJson = encodeJsonl(actual,
      schema: 'lumen-document-jsonl-v1', document: artifactPath);
  final expectedJson = encodeJsonl(expected,
      schema: 'lumen-document-jsonl-v1', document: artifactPath);
  if (actualJson != expectedJson)
    fail('artifact is not deterministic from SSOT');
  stdout.writeln(
      'EVENT_STORM_OK: nodes=${nodes.length} choices=$choiceCount effectCoverage=${summary['effectCoverage']} feedbackCoverage=${summary['feedbackCoverage']}');
}
