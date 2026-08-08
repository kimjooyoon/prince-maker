import 'dart:convert';
import 'dart:io';

Never fail(String message) {
  stderr.writeln('GAMEPLAY_FUN_GATE_FAIL: $message');
  exit(1);
}

void main() {
  final story = jsonDecode(File('story/story.json').readAsStringSync())
      as Map<String, dynamic>;
  final events = (story['events'] as List).cast<Map<String, dynamic>>(),
      choices = events
          .expand((event) =>
              (event['choices'] as List).cast<Map<String, dynamic>>())
          .toList(),
      numericAxes = ['delta', 'coins', 'bondDelta', 'rivalDelta'];
  int axes(Map<String, dynamic> choice) =>
      numericAxes.where((key) => ((choice[key] as num?) ?? 0) != 0).length;
  bool effectful(Map<String, dynamic> choice) =>
      axes(choice) > 0 ||
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
      multiAxis = choices.where((choice) => axes(choice) >= 2).length,
      divergentEvents = events.where((event) {
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
    'divergentEvents': divergentEvents,
    'eventDivergenceRate': divergentEvents / events.length,
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
      current['multiAxisImpactRate'] != metrics['multiAxisImpactRate']) {
    fail('SSOT gameplay KPI drift');
  }
  final approved = choices.length >= 94 &&
      metrics['choiceImpactRate'] == 1.0 &&
      metrics['eventDivergenceRate'] == 1.0 &&
      (metrics['multiAxisImpactRate'] as double) >= 0.9 &&
      gatedChoices >= 20 &&
      metrics['feedbackGolden'] == true;
  final report = {
    'schema': 'lumen-gameplay-fun-verdict-v1',
    'decision': approved ? 'approve' : 'reject',
    'source': 'story/story.json#gameplayKpis',
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
