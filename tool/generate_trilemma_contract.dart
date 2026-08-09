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
  final companionSceneGoldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => [
            'companion-scenes.png',
            'companion-scene-choice.png',
            'companion-scene-recorded.png',
            'companion-scene-recorded-en.png',
            'companion-scene-lumi-mixed.png',
            'companion-scene-bora-mixed.png',
            'companion-scene-taro-mixed.png',
            'companion-scene-locked.png',
            'companion-scene-choice-recall.png',
          ].contains(file.uri.pathSegments.last))
      .length;
  final activityForecastGoldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.uri.pathSegments.last == 'activity-forecast.png')
      .length;
  final activityRiskForecastGoldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.uri.pathSegments.last == 'activity-risk.png')
      .length;
  final memoryImpactGoldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.uri.pathSegments.last == 'memory-forecast.png')
      .length;
  final activityReflectionGoldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where(
          (file) => file.uri.pathSegments.last == 'activity-reflection-en.png')
      .length;
  final activityJournalGoldens =
      Directory('test/goldens').listSync().whereType<File>().where((file) {
    final name = file.uri.pathSegments.last;
    return name.startsWith('activity-journal-') && name.endsWith('.png');
  }).length;
  final systemDecisionReceiptGoldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.uri.pathSegments.last == 'system-receipt.png')
      .length;
  final systemReceiptGoldenTest = File('test/system_receipt_golden_test.dart')
          .existsSync()
      ? File('test/system_receipt_golden_test.dart').readAsStringSync()
      : '';
  final systemDecisionReceiptEvidence =
      systemReceiptGoldenTest.contains("matchesGoldenFile('goldens/system-receipt.png')") &&
          systemReceiptGoldenTest.contains('approval:approved') &&
          systemReceiptGoldenTest.contains('approval:rejected');
  final dialogue = (story['dialogueMetrics'] as Map).cast<String, dynamic>();
  final scenarioCases =
      (story['scenarioVariantBudget'] as Map).cast<String, dynamic>();
  final narrative =
      (story['narrativeLoop'] as Map? ?? {}).cast<String, dynamic>();
  final gameplay =
      (story['gameplayKpis'] as Map? ?? {}).cast<String, dynamic>();
  final gameplayTargets =
      (gameplay['targets'] as Map? ?? {}).cast<String, dynamic>();
  final lineageDistribution =
      (story['lineageDistribution'] as Map? ?? {}).cast<String, dynamic>();
  final contentBudget =
      (story['contentBudget'] as Map? ?? {}).cast<String, dynamic>();
  final quests = (story['companionQuests'] as List? ?? const []).cast<Map>();
  final companionScenes =
      (story['companionScenes'] as List? ?? const []).cast<Map>();
  final companionSceneChoices = companionScenes.fold<int>(0,
      (sum, scene) => sum + ((scene['choices'] as List? ?? const []).length));
  final saveUiStateEvidence = File('test/save_state_test.dart')
          .readAsStringSync()
          .contains(
              'save round trip preserves player-facing archive positions') &&
      File('test/companion_scene_golden_test.dart')
          .readAsStringSync()
          .contains('saved companion position resumes the same Golden surface');
  final companionRenderBudgetEvidence = File('test/companion_scene_test.dart')
      .readAsStringSync()
      .contains(
          'companion archive canvas projection stays within the frame budget');
  final canvasRenderBudgetEvidence = File('test/canvas_render_perf_test.dart')
      .readAsStringSync()
      .contains('full Canvas pages stay within the deterministic frame budget');
  final questStages = quests.fold<int>(
      0, (sum, quest) => sum + ((quest['stages'] as List? ?? const []).length));
  final eventStormNodes = events.length +
      (story['sideScenes'] as List? ?? const []).length +
      (story['companionScenes'] as List? ?? const []).length +
      (story['activityScenes'] as List? ?? const []).length +
      (story['endingVariants'] as List? ?? const []).length +
      (story['progression'] as List? ?? const []).length;
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
          'eventStormNodes': eventStormNodes,
          'sideSceneChoices': (story['sideScenes'] as List? ?? const [])
              .cast<Map>()
              .fold<int>(
                  0, (sum, scene) => sum + (scene['choices'] as List).length),
          'narrativeFateThreads': narrative['fateThreadCount'],
          'companionQuestStages': questStages,
          'personalityCompanionRoutes':
              (story['personalityCompanionRoutes'] as List? ?? const []).length,
          'personalityIllustrationGoldens':
              (story['personalities'] as List? ?? const []).length,
          'activityForecastGoldens': activityForecastGoldens,
          'activityRiskForecastGoldens': activityRiskForecastGoldens,
          'memoryImpactGoldens': memoryImpactGoldens,
          'activityReflectionGoldens': activityReflectionGoldens,
          'activityJournalGoldens': activityJournalGoldens,
          'systemDecisionReceiptGoldens': systemDecisionReceiptGoldens,
          'systemDecisionReceiptEvidence': systemDecisionReceiptEvidence,
          'companionScenes': companionScenes.length,
          'companionSceneChoices': companionSceneChoices,
          'companionSceneChoiceBranching': companionScenes.isNotEmpty &&
              companionScenes.every((scene) =>
                  ((scene['choices'] as List? ?? const []).length) == 2),
          'companionSceneChoiceImpactRate':
              gameplayTargets['companionSceneChoiceImpactRate'],
          'companionSceneGoldens': companionSceneGoldens,
          'companionSceneBondReward': companionScenes.isNotEmpty &&
              companionScenes
                  .every((scene) => (scene['bondDelta'] as int?) == 1),
          'saveUiStateContinuity': saveUiStateEvidence,
          'goldens': goldens,
          'localeKeys': dialogue['minimumLocaleKeys'],
          'qualityScoreTarget': qualityScoreTarget,
        },
        'evidence': [
          'tool/verify_game.dart#scenario-contract',
          'tool/verify_content_depth.dart#content-depth-gate',
          'tool/verify_event_storm.dart#event-storm-gate',
          'test/event_storm_test.dart#event storm covers every authored unit',
          'test/scenario_completeness_test.dart#scenario-closure',
          'test/golden_test.dart#all',
          'test/player_facing_golden_test.dart#all personality illustration pages render deterministic portraits',
          'test/activity_forecast_golden_test.dart#home shows deterministic activity forecasts',
          'test/activity_risk_golden_test.dart#home explains deterministic fatigue risk before spending the day',
          'test/memory_forecast_test.dart#choice maps to an authored fate thread',
          'test/memory_forecast_golden_test.dart#event shows the authored memory impact before commit',
          'test/activity_forecast_test.dart#recovery window follows the injected SSOT rest delta',
          'test/activity_reflection_golden_test.dart#event shows localized activity reflection after day spend',
          'test/activity_journal_golden_test.dart#activity journal renders deterministic reflection pages',
          'test/system_receipt_golden_test.dart#ledger renders system-owned decision receipts',
          'test/companion_scene_test.dart#companion scene resolver and record loop',
          'test/companion_scene_test.dart#companion choice is recalled by the next authored scene',
          'test/companion_scene_test.dart#companion archive canvas projection stays within the frame budget',
          'test/companion_scene_golden_test.dart#companion scene archive records a scene',
          'test/save_state_test.dart#save round trip preserves player-facing archive positions',
          'test/companion_scene_golden_test.dart#saved companion position resumes the same Golden surface',
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
          'lineageDistributionPolicies': lineageDistribution['policyCount'],
          'lineageDistributionMinEndings':
              lineageDistribution['minimumDistinctEndingsPerProfile'],
          'lineageDistributionMinSignatures':
              lineageDistribution['minimumDistinctSignaturesPerProfile'],
          'lineageDistributionObservedEndings':
              lineageDistribution['observedDistinctEndingsPerProfile'],
          'lineageDistributionObservedSignatures':
              lineageDistribution['observedDistinctSignaturesPerProfile'],
          'lineageDistributionFingerprints':
              lineageDistribution['distinctProfileFingerprints'],
          'lineageDistributionReplay': true,
          'deterministicReplay': true,
          'choiceImpactRate': gameplayTargets['choiceImpactRate'],
          'eventDivergenceRate': gameplayTargets['eventDivergenceRate'],
          'multiAxisImpactRate': gameplayTargets['multiAxisImpactRate'],
          'minimumTradeoffRate': gameplayTargets['minimumTradeoffRate'],
          'minimumGatedChoices': gameplayTargets['minimumGatedChoices'],
          'personalityCompanionRoutes':
              (story['personalityCompanionRoutes'] as List? ?? const []).length,
          'personalityIllustrationGoldens':
              (story['personalities'] as List? ?? const []).length,
          'activityForecastGoldens': activityForecastGoldens,
          'activityForecastDeterminism': true,
          'activityForecastHorizonGolden':
              gameplayTargets['activityForecastHorizonGolden'],
          'activityRiskForecastGoldens': activityRiskForecastGoldens,
          'activityRiskForecastDeterminism': true,
          'activityRiskForecastGolden':
              gameplayTargets['activityRiskForecastGolden'],
          'memoryImpactGoldens': memoryImpactGoldens,
          'memoryImpactGolden': gameplayTargets['memoryImpactGolden'],
          'activityReflectionGoldens': activityReflectionGoldens,
          'activityReflectionDeterminism': true,
          'activityJournalGoldens': activityJournalGoldens,
          'activityJournalDeterminism': true,
          'systemDecisionReceiptGoldens': systemDecisionReceiptGoldens,
          'systemDecisionReceiptGolden':
              gameplayTargets['systemDecisionReceiptGolden'],
          'systemDecisionReceiptEvidence': systemDecisionReceiptEvidence,
          'companionScenes': companionScenes.length,
          'companionSceneChoices': companionSceneChoices,
          'companionSceneChoiceBranching': companionScenes.isNotEmpty &&
              companionScenes.every((scene) =>
                  ((scene['choices'] as List? ?? const []).length) == 2),
          'companionSceneChoiceImpactRate':
              gameplayTargets['companionSceneChoiceImpactRate'],
          'companionSceneGoldens': companionSceneGoldens,
          'companionSceneBondReward': companionScenes.isNotEmpty &&
              companionScenes
                  .every((scene) => (scene['bondDelta'] as int?) == 1),
          'companionSceneDeterminism': true,
          'saveUiStateContinuity': saveUiStateEvidence,
          'matchedPersonalityCompanionRoutes':
              ((story['personalityCompanionRoutes'] as List? ?? const [])
                  .where((route) => (route as Map)['matched'] == true)
                  .length),
          'qualityScoreTarget': qualityScoreTarget,
        },
        'evidence': [
          'test/gameplay_metrics_test.dart#route-variety',
          'test/gameplay_metrics_test.dart#each legacy profile keeps a deterministic distribution across policies',
          'test/legacy_profile_catalog_test.dart#legacy policy forecast projects only the verified SSOT contract',
          'test/purity_integration_test.dart#same-schedule-budget-outcomes',
          'tool/verify_gameplay_fun.dart#gameplay-purity-kpi-gate',
          'tool/verify_quality_score.dart#quality-score-99',
          'test/golden_test.dart#event choice shows a separated result banner',
          'test/player_facing_golden_test.dart#all personality illustration pages render deterministic portraits',
          'test/activity_forecast_test.dart#fatigue and talent forecast is deterministic',
          'test/activity_forecast_golden_test.dart#home shows deterministic activity forecasts',
          'test/activity_risk_golden_test.dart#home explains deterministic fatigue risk before spending the day',
          'test/activity_forecast_test.dart#recovery window follows the injected SSOT rest delta',
          'test/activity_localization_test.dart#activity result localizes deterministic reflection',
          'test/memory_forecast_test.dart#choice maps to an authored fate thread',
          'test/memory_forecast_golden_test.dart#event shows the authored memory impact before commit',
          'test/activity_journal_test.dart#activity journal opens only recorded reflection pages',
          'test/companion_scene_test.dart#companion scene resolver and record loop',
          'test/companion_scene_test.dart#companion choice is recalled by the next authored scene',
          'test/companion_scene_test.dart#companion archive canvas projection stays within the frame budget',
          'test/companion_scene_golden_test.dart#companion scene archive records a scene',
          'test/save_state_test.dart#save round trip preserves player-facing archive positions',
          'test/companion_scene_golden_test.dart#saved companion position resumes the same Golden surface',
          'test/system_receipt_golden_test.dart#ledger renders system-owned decision receipts',
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
          'transitionBudget': 5000 *
              ((story['endingWeek'] as int) -
                  1 +
                  events.length +
                  companionScenes.length),
          'companionSceneTransitions': 5000 * companionScenes.length,
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
          'lineageDistributionPolicies': lineageDistribution['policyCount'],
          'lineageDistributionMinEndings':
              lineageDistribution['minimumDistinctEndingsPerProfile'],
          'lineageDistributionMinSignatures':
              lineageDistribution['minimumDistinctSignaturesPerProfile'],
          'lineageDistributionObservedEndings':
              lineageDistribution['observedDistinctEndingsPerProfile'],
          'lineageDistributionObservedSignatures':
              lineageDistribution['observedDistinctSignaturesPerProfile'],
          'lineageDistributionFingerprints':
              lineageDistribution['distinctProfileFingerprints'],
          'lineageDistributionReplay': true,
          'checksumReplayMustMatch': true,
          'activityForecastDeterminism': true,
          'activityRiskForecastDeterminism': true,
          'memoryForecastDeterminism': true,
          'companionSceneReplay': true,
          'companionSceneChoiceModes': 2,
          'companionSceneRouteTrace': true,
          'companionSceneRenderBudgetMicros': 8000,
          'companionSceneRenderBudgetEvidence': companionRenderBudgetEvidence,
          'canvasRenderBudgetMicros': contentBudget['canvasPaintBudgetMicros'],
          'canvasRenderPages':
              (contentBudget['canvasRenderPages'] as List? ?? const []).length,
          'canvasRenderBudgetEvidence': canvasRenderBudgetEvidence,
          'minCompanionScenes': 3,
          'qualityScoreTarget': qualityScoreTarget,
        },
        'evidence': [
          'tool/benchmark_game.dart#ssot-campaign-throughput-signatures',
          'tool/benchmark_game.dart#profile-policy-distribution',
          'test/golden_test.dart#ending exposes deterministic next-run legacy picker',
          'tool/benchmark_game.dart#companion-scene-replay-checksum',
          'test/companion_scene_test.dart#companion archive canvas projection stays within the frame budget',
          'test/canvas_render_perf_test.dart#full Canvas pages stay within the deterministic frame budget',
          'lib/activity_forecast.dart#forecastActivity',
          'lib/activity_forecast.dart#recoveryDaysToClearFatigue',
          'lib/i18n.dart#localizedActivityRisk',
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
