import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/quality_score.dart';

String sha(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

Map<String, dynamic> buildContract(Map<String, dynamic> story, String hash) {
  final events = (story['events'] as List).cast<Map<String, dynamic>>();
  final choices = events.fold<int>(
      0, (sum, event) => sum + (event['choices'] as List).length);
  final goldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.png'))
      .length;
  final dialogue = (story['dialogueMetrics'] as Map).cast<String, dynamic>();
  final scenarioCases =
      (story['scenarioVariantBudget'] as Map).cast<String, dynamic>();
  final narrative =
      (story['narrativeLoop'] as Map? ?? {}).cast<String, dynamic>();
  final gameplay =
      (story['gameplayKpis'] as Map? ?? {}).cast<String, dynamic>();
  final gameplayTargets =
      (gameplay['targets'] as Map? ?? {}).cast<String, dynamic>();
  final quests = (story['companionQuests'] as List? ?? const []).cast<Map>();
  final questStages = quests.fold<int>(
      0, (sum, quest) => sum + ((quest['stages'] as List? ?? const []).length));
  return {
    'schema': 'prince-maker-trilemma-v1',
    'source': {'ref': 'story/story.jsonl#root', 'sha256': hash},
    'axes': [
      {
        'id': 'completeness',
        'targetScore': qualityScoreTarget,
        'unit': 'gate-score',
        'guardrails': {
          'scenarioDimensions': 8,
          'authoredBranches': choices + (story['endings'] as List).length,
          'scenarioCases': scenarioCases['minimumCases'],
          'scenarioRouteInputs': scenarioCases['routeInputCases'],
          'authoredScenes':
              events.length + (story['sideScenes'] as List? ?? const []).length,
          'sideSceneChoices': (story['sideScenes'] as List? ?? const [])
              .cast<Map>()
              .fold<int>(
                  0, (sum, scene) => sum + (scene['choices'] as List).length),
          'narrativeFateThreads': narrative['fateThreadCount'],
          'companionQuestStages': questStages,
          'goldens': goldens,
          'localeKeys': dialogue['minimumLocaleKeys'],
          'qualityScoreTarget': qualityScoreTarget,
        },
        'evidence': [
          'tool/verify_game.dart#scenario-contract',
          'tool/verify_content_depth.dart#content-depth-gate',
          'test/scenario_completeness_test.dart#scenario-closure',
          'test/golden_test.dart#all',
          'test/locale_contract_test.dart#ssot-dialogue-contract',
          'tool/verify_decision_proof.dart#decision-proof-preconditions',
          'tool/verify_quality_score.dart#quality-score-99',
          'tool/trilemma_verdict.dart#axis-verdict',
          'tool/trilemma_verdict.dart#closed-loop-receipt',
          'test/trilemma_verdict_test.dart#closed-loop-receipt',
        ],
      },
      {
        'id': 'purity',
        'targetScore': 0.75,
        'unit': 'route-variety',
        'guardrails': {
          'schedulePolicies': (story['activities'] as List).length,
          'minDistinctEndings': 3,
          'minDistinctSignatures': 3,
          'scenarioCases': scenarioCases['minimumCases'],
          'minScenarioSignatures': scenarioCases['minimumCases'],
          'narrativeFateThreads': narrative['fateThreadCount'],
          'companionQuestStages': questStages,
          'narrativeDeterministic': true,
          'minLegacyProfiles': (story['legacyProfiles'] as List? ?? []).length,
          'minLegacyTargetEndings':
              (story['legacyProfiles'] as List? ?? []).length,
          'minLegacyTargetCompanions':
              (story['legacyProfiles'] as List? ?? []).length,
          'deterministicReplay': true,
          'choiceImpactRate': gameplayTargets['choiceImpactRate'],
          'eventDivergenceRate': gameplayTargets['eventDivergenceRate'],
          'multiAxisImpactRate': gameplayTargets['multiAxisImpactRate'],
          'minimumGatedChoices': gameplayTargets['minimumGatedChoices'],
          'qualityScoreTarget': qualityScoreTarget,
        },
        'evidence': [
          'test/gameplay_metrics_test.dart#route-variety',
          'test/purity_integration_test.dart#same-schedule-budget-outcomes',
          'tool/verify_gameplay_fun.dart#gameplay-purity-kpi-gate',
          'tool/verify_quality_score.dart#quality-score-99',
          'test/golden_test.dart#event choice shows a separated result banner',
          'tool/verify_decision_proof.dart#decision-proof-preconditions',
          'tool/trilemma_verdict.dart#axis-verdict',
          'tool/trilemma_verdict.dart#closed-loop-receipt',
          'test/trilemma_verdict_test.dart#closed-loop-receipt',
        ],
      },
      {
        'id': 'performance',
        'targetScore': qualityScoreTarget,
        'unit': 'campaign-throughput',
        'guardrails': {
          'campaigns': 5000,
          'transitionBudget':
              5000 * ((story['endingWeek'] as int) - 1 + events.length),
          'systemApproval': (story['decisionSystem'] as Map?)?['mode'] ==
              'system-adjudicated',
          'failClosed': (story['decisionSystem'] as Map?)?['failureMode'] ==
              'fail-closed',
          'maxMillis': 24000,
          'minSignatures': 3,
          'lineageProfiles': (story['legacyProfiles'] as List? ?? []).length,
          'lineageTargetEndings':
              (story['legacyProfiles'] as List? ?? []).length,
          'lineageTargetCompanions':
              (story['legacyProfiles'] as List? ?? []).length,
          'checksumReplayMustMatch': true,
          'qualityScoreTarget': qualityScoreTarget,
        },
        'evidence': [
          'tool/benchmark_game.dart#ssot-campaign-throughput-signatures',
          'tool/verify_quality_score.dart#quality-score-99',
          'tool/verify_decision_proof.dart#decision-proof-preconditions',
          'tool/trilemma_verdict.dart#axis-verdict',
          'tool/trilemma_verdict.dart#closed-loop-receipt',
          'test/trilemma_verdict_test.dart#closed-loop-receipt'
        ],
      },
    ],
  };
}

void main(List<String> args) {
  const input = 'story/story.jsonl';
  final source = decodeJsonl(File(input).readAsStringSync());
  final output = encodeJsonl(buildContract(source, sha(input)),
      schema: 'lumen-document-jsonl-v1',
      document: 'docs/trilemma-contract.jsonl');
  const path = 'docs/trilemma-contract.jsonl';
  if (args.contains('--check')) {
    if (!File(path).existsSync() || File(path).readAsStringSync() != output) {
      stderr.writeln('TRILEMMA_CONTRACT_FAIL: regenerate $path');
      exit(1);
    }
    stdout.writeln('TRILEMMA_CONTRACT_OK: $path');
    return;
  }
  File(path).writeAsStringSync(output);
  stdout.writeln('TRILEMMA_CONTRACT_WRITTEN: $path');
}
