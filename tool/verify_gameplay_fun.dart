import 'dart:convert';
import 'dart:io';
import 'package:prince_maker/choice_impact.dart';
import 'package:prince_maker/jsonl.dart';

Never fail(String message) {
  stderr.writeln('GAMEPLAY_FUN_GATE_FAIL: $message');
  exit(1);
}

void main() {
  final story = decodeJsonl(File('story/story.jsonl').readAsStringSync());
  final events = (story['events'] as List).cast<Map<String, dynamic>>(),
      sideScenes = (story['sideScenes'] as List? ?? const [])
          .cast<Map<String, dynamic>>(),
      authoredScenes = [...events, ...sideScenes],
      choices = authoredScenes
          .expand((event) =>
              (event['choices'] as List).cast<Map<String, dynamic>>())
          .toList();
  bool effectful(Map<String, dynamic> choice) =>
      ChoiceImpact.from(choice).effectful ||
      choice['setsFlag'] != null ||
      choice['legacyBonuses'] != null;
  String effect(Map<String, dynamic> choice) => jsonEncode([
        choice['stat'],
        choice['delta'],
        choice['coins'],
        choice['bondId'],
        choice['bondDelta'],
        choice['rivalId'],
        choice['rivalDelta'],
        choice['setsFlag'],
        choice['legacyBonuses']
      ]);
  final impactful = choices.where(effectful).length,
      multiAxis = choices
          .where((choice) => ChoiceImpact.from(choice).axisCount >= 2)
          .length,
      tradeoffChoices = choices
          .where((choice) => ChoiceImpact.from(choice).hasTradeoff)
          .length,
      divergentEvents = authoredScenes.where((event) {
        final variants = (event['choices'] as List)
            .cast<Map<String, dynamic>>()
            .map(effect)
            .toSet();
        return variants.length >= 2;
      }).length,
      gatedChoices = choices
          .where((choice) =>
              choice['requiresStat'] != null ||
              choice['requiresBondId'] != null ||
              choice['requiresFlag'] != null)
          .length;
  final metrics = {
    'authoredChoices': choices.length,
    'effectfulChoices': impactful,
    'choiceImpactRate': impactful / choices.length,
    'multiAxisChoices': multiAxis,
    'multiAxisImpactRate': multiAxis / choices.length,
    'tradeoffChoices': tradeoffChoices,
    'tradeoffRate': tradeoffChoices / choices.length,
    'divergentEvents': divergentEvents,
    'eventDivergenceRate': divergentEvents / authoredScenes.length,
    'gatedChoices': gatedChoices,
    'feedbackGolden': File('test/goldens/feedback.png').existsSync() &&
        File('test/golden_test.dart')
            .readAsStringSync()
            .contains('event choice shows a separated result banner'),
  };
  final contract = (story['gameplayKpis'] as Map).cast<String, dynamic>(),
      current = (contract['current'] as Map).cast<String, dynamic>();
  if (contract['schema'] != 'lumen-gameplay-kpi-v1' ||
      current['choiceImpactRate'] != metrics['choiceImpactRate'] ||
      current['eventDivergenceRate'] != metrics['eventDivergenceRate'] ||
      current['multiAxisImpactRate'] != metrics['multiAxisImpactRate'] ||
      current['tradeoffRate'] != metrics['tradeoffRate']) {
    fail('SSOT gameplay KPI drift');
  }
  final approved = choices.length >= 166 &&
      metrics['choiceImpactRate'] == 1.0 &&
      metrics['eventDivergenceRate'] == 1.0 &&
      (metrics['multiAxisImpactRate'] as double) >= 0.9 &&
      (metrics['tradeoffRate'] as double) >=
          ((contract['targets'] as Map)['minimumTradeoffRate'] as num) &&
      gatedChoices >= 20 &&
      metrics['feedbackGolden'] == true;
  final report = {
    'schema': 'lumen-gameplay-fun-verdict-v1',
    'decision': approved ? 'approve' : 'reject',
    'source': 'story/story.jsonl#gameplayKpis',
    'metrics': metrics,
    'targets': contract['targets'],
    'system': {
      'owner': 'Lumen Gameplay Purity Gate',
      'mode': 'system-adjudicated',
      'humanApprovalRequired': false,
      'failureMode': 'fail-closed'
    }
  };
  final file = File('build/gameplay-fun-verdict.json')
    ..parent.createSync(recursive: true);
  file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(report) + '\n');
  stdout.writeln('GAMEPLAY_FUN_OK: ' + jsonEncode(metrics));
  if (!approved) exit(1);
}
