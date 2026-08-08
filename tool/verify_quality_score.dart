import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/quality_score.dart';

Never fail(String message) {
  stderr.writeln('QUALITY_SCORE_GATE_FAIL: $message');
  exit(1);
}

Map<String, dynamic> readJson(String path) {
  final file = File(path);
  if (!file.existsSync()) fail('missing $path');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

String sha256File(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

double metric(Map<String, dynamic> report, String key) {
  final value = (report['metrics'] as Map)[key];
  if (value is! num) fail('gameplay metric $key is not numeric');
  return value.toDouble();
}

int goldenCount(String prefix) => Directory('test/goldens')
    .listSync()
    .whereType<File>()
    .where((file) => file.path.endsWith('.png'))
    .where((file) => file.uri.pathSegments.last.startsWith(prefix))
    .length;

int validScenarioDimensions(Map<String, dynamic> story) {
  final dimensions =
      ((story['scenarioCompleteness'] as Map)['dimensions'] as List)
          .cast<Map<String, dynamic>>();
  const expected = {
    'arc',
    'agency',
    'relationship',
    'feedback',
    'gating',
    'replay',
    'presentation',
    'closure'
  };
  return dimensions
      .where((dimension) =>
          expected.contains(dimension['id']) &&
          '${dimension['name']}'.trim().isNotEmpty &&
          '${dimension['target']}'.trim().isNotEmpty &&
          '${dimension['current']}'.trim().isNotEmpty &&
          '${dimension['evidence']}'.trim().isNotEmpty)
      .length;
}

int minimumLocaleKeys(Map<String, dynamic> story) {
  final refs = (story['localeRefs'] as List).cast<Map<String, dynamic>>();
  if (refs.isEmpty) fail('localeRefs is empty');
  final counts = <int>[];
  for (final ref in refs) {
    final path = '${ref['ref']}'.split('#').first;
    final file = File(path);
    if (!file.existsSync()) fail('missing locale catalog $path');
    counts.add(decodeJsonlCatalog(file.readAsStringSync()).length);
  }
  return counts.reduce((a, b) => a < b ? a : b);
}

void main() {
  final story = decodeJsonl(File('story/story.jsonl').readAsStringSync()),
      model = qualityScoreModel(),
      gameplay = readJson('build/gameplay-fun-verdict.json'),
      benchmark = readJson('build/benchmark-verdict.json'),
      decisionProof = readJson('build/decision-proof-verdict.json');
  if (model['schema'] != qualityScoreSchema ||
      (model['targetScore'] as num) != qualityScoreTarget ||
      qualityScoreComponents.length != 10) {
    fail('quality score model schema, target or component count drift');
  }
  if (gameplay['schema'] != 'lumen-gameplay-fun-verdict-v1' ||
      gameplay['decision'] != 'approve') {
    fail('gameplay-fun evidence did not approve');
  }
  if (benchmark['schema'] != 'lumen-campaign-benchmark-v1' ||
      benchmark['decision'] != 'approve') {
    fail('campaign benchmark evidence did not approve');
  }
  if (decisionProof['schema'] != 'lumen-decision-proof-verdict-v1' ||
      decisionProof['decision'] != 'approve') {
    fail('decision proof evidence did not approve');
  }

  final scenarioCount = validScenarioDimensions(story),
      localeCount = minimumLocaleKeys(story),
      eventGoldens = goldenCount('chapter-') - goldenCount('chapter-closure-'),
      closureGoldens = goldenCount('chapter-closure-'),
      gameplayTargets = ((story['gameplayKpis'] as Map)['targets'] as Map)
          .cast<String, dynamic>();
  final scores = <String, double>{
    'scenario-contract': cappedRatio(scenarioCount, 8),
    'choice-impact': cappedRatio(metric(gameplay, 'choiceImpactRate'),
        gameplayTargets['choiceImpactRate'] as num),
    'event-divergence': cappedRatio(metric(gameplay, 'eventDivergenceRate'),
        gameplayTargets['eventDivergenceRate'] as num),
    'multi-axis-choice': cappedRatio(metric(gameplay, 'multiAxisImpactRate'),
        gameplayTargets['multiAxisImpactRate'] as num),
    'gated-choice': cappedRatio(metric(gameplay, 'gatedChoices'),
        gameplayTargets['minimumGatedChoices'] as num),
    'chapter-event-golden': cappedRatio(eventGoldens, 16),
    'chapter-closure-golden': cappedRatio(closureGoldens, 16),
    'locale-coverage': cappedRatio(localeCount, 505),
    'replay-determinism':
        benchmark['checksum'] == benchmark['replayChecksum'] &&
                benchmark['decision'] == 'approve'
            ? 1.0
            : 0.0,
    'runtime-proof': gameplay['decision'] == 'approve' &&
            benchmark['decision'] == 'approve' &&
            decisionProof['decision'] == 'approve'
        ? 1.0
        : 0.0,
  };
  final score = weightedQualityScore(scores),
      components = [
        for (final component in qualityScoreComponents)
          {
            ...component.toJson(),
            'score': scores[component.id],
            'weightedContribution': double.parse(
                (scores[component.id]! * component.weight).toStringAsFixed(6)),
          }
      ],
      approved = score >= qualityScoreTarget,
      report = {
        'schema': 'lumen-quality-score-verdict-v1',
        'decision': approved ? 'approve' : 'reject',
        'targetScore': qualityScoreTarget,
        'qualityScore': score,
        'source': {
          'ref': 'story/story.jsonl#quality-score-inputs',
          'sha256': sha256File('story/story.jsonl'),
        },
        'model': model,
        'measurements': {
          'scenarioDimensions': scenarioCount,
          'localeKeysMinimum': localeCount,
          'chapterEventGoldens': eventGoldens,
          'chapterClosureGoldens': closureGoldens,
          'gameplayMetrics': gameplay['metrics'],
          'benchmark': benchmark,
          'decisionProof': decisionProof,
        },
        'components': components,
        'system': {
          'owner': 'Lumen Quality Score Gate',
          'mode': 'system-adjudicated',
          'humanApprovalRequired': false,
          'failureMode': 'fail-closed',
          'formula': 'sum(component.score × component.weight)',
        },
      };
  final file = File('build/quality-score-verdict.json')
    ..parent.createSync(recursive: true);
  file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(report)}\n');
  stdout.writeln(
      'QUALITY_SCORE_OK: score=$score target=$qualityScoreTarget components=${scores.length} eventGoldens=$eventGoldens closureGoldens=$closureGoldens localeKeys=$localeCount');
  if (!approved) exit(1);
}
