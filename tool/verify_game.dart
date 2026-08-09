import 'dart:io';
import 'package:prince_maker/jsonl.dart';
import 'package:crypto/crypto.dart';
import 'package:prince_maker/quality_score.dart';

void verifyTrilemmaContract(String storyHash,
    {required int endingWeek,
    required int eventCount,
    required int companionSceneCount}) {
  final file = File('docs/trilemma-contract.jsonl');
  if (!file.existsSync()) fail('missing trilemma contract');
  final contract = decodeJsonl(file.readAsStringSync());
  final source = (contract['source'] as Map).cast<String, dynamic>();
  final axes =
      (contract['axes'] as List? ?? const []).cast<Map<String, dynamic>>();
  const ids = {'completeness', 'purity', 'performance'};
  if (contract['schema'] != 'prince-maker-trilemma-v1' ||
      source['ref'] != 'story/story.jsonl#root' ||
      source['sha256'] != storyHash ||
      axes.length != ids.length ||
      axes.map((axis) => axis['id']).toSet().length != axes.length ||
      !axes.map((axis) => axis['id']).toSet().containsAll(ids)) {
    fail('trilemma contract schema/source drift');
  }
  final byId = {for (final axis in axes) axis['id'] as String: axis};
  final complete =
      (byId['completeness']!['guardrails'] as Map).cast<String, dynamic>();
  final purity = (byId['purity']!['guardrails'] as Map).cast<String, dynamic>();
  final performance =
      (byId['performance']!['guardrails'] as Map).cast<String, dynamic>();
  if ((byId['completeness']!['targetScore'] as num) < qualityScoreTarget ||
      complete['scenarioDimensions'] != 8 ||
      (complete['scenarioCases'] as int? ?? 0) < 2000 ||
      (complete['scenarioRouteInputs'] as int? ?? 0) < 2000 ||
      (complete['narrativeFateThreads'] as int? ?? 0) < 6 ||
      (complete['companionQuestStages'] as int? ?? 0) < 9 ||
      (complete['activityForecastGoldens'] as int? ?? 0) < 1 ||
      (complete['activityRiskForecastGoldens'] as int? ?? 0) < 1 ||
      (complete['memoryImpactGoldens'] as int? ?? 0) < 1 ||
      (complete['activityReflectionGoldens'] as int? ?? 0) < 1 ||
      (complete['activityJournalGoldens'] as int? ?? 0) < 2 ||
      (complete['systemDecisionReceiptGoldens'] as int? ?? 0) < 1 ||
      complete['systemDecisionReceiptEvidence'] != true ||
      (complete['companionScenes'] as int? ?? 0) < 18 ||
      (complete['companionSceneChoices'] as int? ?? 0) < 36 ||
      complete['companionSceneChoiceBranching'] != true ||
      (complete['companionSceneChoiceImpactRate'] as num? ?? 0) < 1.0 ||
      (complete['companionSceneChoiceImpactRate'] as num? ?? 0) < 1.0 ||
      (complete['companionSceneGoldens'] as int? ?? 0) < 8 ||
      complete['companionSceneBondReward'] != true ||
      complete['saveUiStateContinuity'] != true ||
      complete['goldens'] < 20 ||
      complete['localeKeys'] < 118 ||
      complete['qualityScoreTarget'] != qualityScoreTarget ||
      purity['minDistinctEndings'] < 3 ||
      purity['minDistinctSignatures'] < 3 ||
      (purity['scenarioCases'] as int? ?? 0) < 2000 ||
      (purity['minScenarioSignatures'] as int? ?? 0) < 2000 ||
      (purity['narrativeFateThreads'] as int? ?? 0) < 6 ||
      (purity['companionQuestStages'] as int? ?? 0) < 9 ||
      purity['narrativeDeterministic'] != true ||
      purity['minLegacyProfiles'] < 3 ||
      purity['minLegacyTargetEndings'] < 3 ||
      purity['minLegacyTargetCompanions'] < 3 ||
      purity['lineageDistributionPolicies'] != 5 ||
      (purity['lineageDistributionMinEndings'] as int? ?? 0) < 3 ||
      (purity['lineageDistributionMinSignatures'] as int? ?? 0) < 3 ||
      (purity['lineageDistributionObservedEndings'] as int? ?? 0) < 4 ||
      (purity['lineageDistributionObservedSignatures'] as int? ?? 0) < 4 ||
      (purity['lineageDistributionFingerprints'] as int? ?? 0) < 3 ||
      purity['lineageDistributionReplay'] != true ||
      purity['deterministicReplay'] != true ||
      (purity['choiceImpactRate'] as num? ?? 0) < 1.0 ||
      (purity['eventDivergenceRate'] as num? ?? 0) < 1.0 ||
      (purity['multiAxisImpactRate'] as num? ?? 0) < 0.9 ||
      (purity['minimumGatedChoices'] as int? ?? 0) < 20 ||
      (purity['activityForecastGoldens'] as int? ?? 0) < 1 ||
      purity['activityForecastDeterminism'] != true ||
      (purity['activityRiskForecastGoldens'] as int? ?? 0) < 1 ||
      purity['activityRiskForecastDeterminism'] != true ||
      purity['activityRiskForecastGolden'] != true ||
      (purity['memoryImpactGoldens'] as int? ?? 0) < 1 ||
      purity['memoryImpactGolden'] != true ||
      (purity['activityReflectionGoldens'] as int? ?? 0) < 1 ||
      purity['activityReflectionDeterminism'] != true ||
      (purity['activityJournalGoldens'] as int? ?? 0) < 2 ||
      purity['activityJournalDeterminism'] != true ||
      (purity['systemDecisionReceiptGoldens'] as int? ?? 0) < 1 ||
      purity['systemDecisionReceiptGolden'] != true ||
      purity['systemDecisionReceiptEvidence'] != true ||
      (purity['companionScenes'] as int? ?? 0) < 18 ||
      (purity['companionSceneChoices'] as int? ?? 0) < 36 ||
      purity['companionSceneChoiceBranching'] != true ||
      (purity['companionSceneChoiceImpactRate'] as num? ?? 0) < 1.0 ||
      (purity['companionSceneChoiceImpactRate'] as num? ?? 0) < 1.0 ||
      (purity['companionSceneGoldens'] as int? ?? 0) < 8 ||
      purity['companionSceneBondReward'] != true ||
      purity['companionSceneDeterminism'] != true ||
      purity['saveUiStateContinuity'] != true ||
      purity['qualityScoreTarget'] != qualityScoreTarget ||
      performance['campaigns'] != 5000 ||
      performance['transitionBudget'] !=
          5000 * (endingWeek - 1 + eventCount + companionSceneCount) ||
      performance['companionSceneTransitions'] != 5000 * companionSceneCount ||
      performance['maxMillis'] != 24000 ||
      performance['minSignatures'] < 3 ||
      performance['lineageTargetEndings'] < 3 ||
      performance['lineageTargetCompanions'] < 3 ||
      performance['lineageDistributionPolicies'] != 5 ||
      (performance['lineageDistributionMinEndings'] as int? ?? 0) < 3 ||
      (performance['lineageDistributionMinSignatures'] as int? ?? 0) < 3 ||
      (performance['lineageDistributionObservedEndings'] as int? ?? 0) < 4 ||
      (performance['lineageDistributionObservedSignatures'] as int? ?? 0) < 4 ||
      (performance['lineageDistributionFingerprints'] as int? ?? 0) < 3 ||
      performance['lineageDistributionReplay'] != true ||
      performance['checksumReplayMustMatch'] != true ||
      performance['activityForecastDeterminism'] != true ||
      performance['activityRiskForecastDeterminism'] != true ||
      performance['memoryForecastDeterminism'] != true ||
      performance['companionSceneReplay'] != true ||
      (performance['companionSceneChoiceModes'] as int? ?? 0) < 2 ||
      performance['companionSceneRouteTrace'] != true ||
      (performance['companionSceneRenderBudgetMicros'] as int? ?? 0) > 8000 ||
      performance['companionSceneRenderBudgetEvidence'] != true ||
      (performance['canvasRenderBudgetMicros'] as int? ?? 0) > 8000 ||
      (performance['canvasRenderPages'] as int? ?? 0) < 6 ||
      performance['canvasRenderBudgetEvidence'] != true ||
      (performance['minCompanionScenes'] as int? ?? 0) < 3 ||
      performance['qualityScoreTarget'] != qualityScoreTarget ||
      performance['systemApproval'] != true ||
      performance['failClosed'] != true) {
    fail('trilemma targets or guardrails are below the project contract');
  }
}

Set<String> authoredLocaleKeys(dynamic node) {
  final keys = <String>{};
  if (node is Map) {
    for (final entry in node.entries) {
      if (entry.key is String &&
          entry.key.toString().endsWith('Key') &&
          entry.value is String) keys.add(entry.value as String);
      keys.addAll(authoredLocaleKeys(entry.value));
    }
  } else if (node is List) {
    for (final item in node) keys.addAll(authoredLocaleKeys(item));
  }
  return keys;
}

Never fail(String message) {
  stderr.writeln('GAME_GATE_FAIL: $message');
  exit(1);
}

void main() {
  final story = decodeJsonl(File('story/story.jsonl').readAsStringSync());
  verifyTrilemmaContract(
      sha256.convert(File('story/story.jsonl').readAsBytesSync()).toString(),
      endingWeek: story['endingWeek'] as int,
      eventCount: (story['events'] as List).length,
      companionSceneCount:
          (story['companionScenes'] as List? ?? const []).length);
  final activities = (story['activities'] as List).cast<Map<String, dynamic>>();
  final people = (story['personalities'] as List).cast<Map<String, dynamic>>();
  final companions = (story['companions'] as List).cast<Map<String, dynamic>>();
  final personalityCompanionRoutes =
      (story['personalityCompanionRoutes'] as List? ?? const [])
          .cast<Map<String, dynamic>>();
  final characterArchive = (story['characterArchive'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final locations = (story['locations'] as List).cast<Map<String, dynamic>>();
  final legacyProfiles =
      (story['legacyProfiles'] as List).cast<Map<String, dynamic>>();
  final events = (story['events'] as List).cast<Map<String, dynamic>>();
  final endings = (story['endings'] as List).cast<Map<String, dynamic>>();
  final endingIds = endings.map((ending) => '${ending['id']}').toSet();
  final refs = (story['codeRefs'] as List).cast<Map<String, dynamic>>();
  final assetRefs = (story['assetRefs'] as List).cast<Map<String, dynamic>>();
  final fontRefs =
      (story['fontRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  final localeRefs =
      (story['localeRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  final progression =
      (story['progression'] as List? ?? []).cast<Map<String, dynamic>>();
  final dialogueMetrics =
      (story['dialogueMetrics'] as Map? ?? {}).cast<String, dynamic>();
  final scenario =
      (story['scenarioCompleteness'] as Map? ?? {}).cast<String, dynamic>();
  final decisionSystem =
      (story['decisionSystem'] as Map? ?? {}).cast<String, dynamic>();
  final campaignWeeks = story['campaignWeeks'] as int? ??
      ((story['endingWeek'] as int) - 1).clamp(1, 999).toInt();
  final contentBudget =
      (story['contentBudget'] as Map? ?? {}).cast<String, dynamic>();
  final sideScenes =
      (story['sideScenes'] as List? ?? const []).cast<Map<String, dynamic>>();
  final activityScenes = (story['activityScenes'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final scenarioVariantBudget =
      (story['scenarioVariantBudget'] as Map? ?? {}).cast<String, dynamic>();
  final endingDesign =
      (story['endingDesign'] as Map? ?? {}).cast<String, dynamic>();
  final narrativeLoop =
      (story['narrativeLoop'] as Map? ?? {}).cast<String, dynamic>();
  final legacySelection =
      (story['legacySelection'] as Map? ?? {}).cast<String, dynamic>();
  final chapterSceneContract =
      (story['chapterSceneContract'] as Map? ?? {}).cast<String, dynamic>();
  final relationshipDesign =
      (story['relationshipDesign'] as Map? ?? {}).cast<String, dynamic>();
  final fateThreads =
      (story['fateThreads'] as List? ?? []).cast<Map<String, dynamic>>();
  final companionQuests =
      (story['companionQuests'] as List? ?? []).cast<Map<String, dynamic>>();
  final companionScenes =
      (story['companionScenes'] as List? ?? []).cast<Map<String, dynamic>>();
  final companionQuestStages = companionQuests.fold<int>(
      0, (sum, quest) => sum + ((quest['stages'] as List? ?? const []).length));
  if (campaignWeeks < 48 || story['endingWeek'] != campaignWeeks + 1)
    fail('campaign must expose a 48-week route and one terminal week');
  if (contentBudget['schema'] != 'lumen-playtime-v1' ||
      contentBudget['minimumMinutes'] is! int ||
      (contentBudget['minimumMinutes'] as int) < 120 ||
      contentBudget['campaignWeeks'] != campaignWeeks ||
      contentBudget['terminalWeek'] != story['endingWeek'] ||
      contentBudget['authoredEvents'] != events.length ||
      contentBudget['authoredChoices'] != events.length * 2 ||
      contentBudget['sideScenes'] != sideScenes.length ||
      contentBudget['companionScenes'] != companionScenes.length ||
      contentBudget['companionSceneChoices'] !=
          companionScenes.fold<int>(
              0, (sum, scene) => sum + ((scene['choices'] as List).length)) ||
      contentBudget['activityMiniEvents'] != activityScenes.length ||
      contentBudget['chapterClosures'] != progression.length ||
      contentBudget['chapterSceneBeats'] != progression.length ||
      contentBudget['canvasPaintBudgetMicros'] is! int ||
      (contentBudget['canvasPaintBudgetMicros'] as int) > 8000 ||
      (contentBudget['canvasRenderPages'] as List? ?? const []).length != 6 ||
      (contentBudget['pacingSeconds'] as Map? ?? {})['activityReflection']
          is! int ||
      (contentBudget['pacingSeconds'] as Map? ?? {})['storyChoice'] is! int ||
      (contentBudget['pacingSeconds'] as Map? ?? {})['sideScene'] is! int ||
      (contentBudget['pacingSeconds'] as Map? ?? {})['chapterClosure']
          is! int ||
      (contentBudget['pacingSeconds'] as Map? ?? {})['chapterSceneBeat']
          is! int ||
      (contentBudget['pacingSeconds'] as Map? ?? {})['activityMiniEvent']
          is! int) {
    fail('content budget must prove the minimum 120-minute campaign');
  }
  final pacing =
      (contentBudget['pacingSeconds'] as Map).cast<String, dynamic>();
  final estimatedSeconds =
      campaignWeeks * (pacing['activityReflection'] as int) +
          events.length * (pacing['storyChoice'] as int) +
          sideScenes.length * (pacing['sideScene'] as int) +
          progression.length * (pacing['chapterClosure'] as int) +
          progression.length * (pacing['chapterSceneBeat'] as int) +
          activityScenes.length * (pacing['activityMiniEvent'] as int);
  if (contentBudget['estimatedFirstPlaythroughMinutes'] !=
      estimatedSeconds ~/ 60)
    fail(
        'content budget estimated minutes do not match the authored pacing formula');
  if (estimatedSeconds < (contentBudget['minimumMinutes'] as int) * 60)
    fail('content budget pacing is below the minimum playtime');
  final branchWeeks =
      (scenarioVariantBudget['branchWeeks'] as List? ?? const []).cast<int>();
  final branchEvents =
      events.where((event) => branchWeeks.contains(event['week'])).toList();
  final branchVectors = branchWeeks.isEmpty ? 0 : 1 << branchWeeks.length;
  final routeInputCases = activities.length *
      people.length *
      (legacyProfiles.length + 1) *
      branchVectors;
  if (scenarioVariantBudget['schema'] != 'lumen-scenario-cases-v1' ||
      (scenarioVariantBudget['minimumCases'] as int? ?? 0) < 2000 ||
      branchWeeks.length < 11 ||
      branchWeeks.toSet().length != branchWeeks.length ||
      branchEvents.length != branchWeeks.length ||
      branchEvents.any((event) =>
          (event['choices'] as List).length != 2 ||
          (event['choices'] as List).cast<Map<String, dynamic>>().any(
              (choice) =>
                  choice['requiresStat'] != null ||
                  choice['requiresBondId'] != null ||
                  choice['requiresFlag'] != null)) ||
      scenarioVariantBudget['branchChoicesPerWeek'] != 2 ||
      scenarioVariantBudget['authoredBranchVectors'] != branchVectors ||
      scenarioVariantBudget['activityPolicies'] != activities.length ||
      scenarioVariantBudget['personalityRoutes'] != people.length ||
      scenarioVariantBudget['legacyContexts'] != legacyProfiles.length + 1 ||
      scenarioVariantBudget['routeInputCases'] != routeInputCases ||
      (scenarioVariantBudget['verifiedReachableCases'] as int? ?? 0) <
          (scenarioVariantBudget['minimumCases'] as int) ||
      scenarioVariantBudget['evidence'] !=
          'tool/verify_scenario_variants.dart#scenario-case-enumerator') {
    fail(
        'scenario variant budget must define and exceed 2,000 reachable cases');
  }
  final resolutionOrder =
      (endingDesign['resolutionOrder'] as List? ?? const []).cast<String>();
  final coreFamilies = (endingDesign['coreFamilies'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final companionRouteModifiers =
      (endingDesign['companionRouteModifiers'] as List? ?? const [])
          .cast<Map<String, dynamic>>();
  final growthAxes = activities.map((activity) => activity['stat']).toSet();
  if (endingDesign['schema'] != 'lumen-ending-matrix-v1' ||
      !resolutionOrder.contains('winner-growth-axis') ||
      !resolutionOrder.contains('highest-eligible-authored-tier') ||
      !resolutionOrder.contains('companion-route-set') ||
      coreFamilies.length != growthAxes.length ||
      coreFamilies.any((family) =>
          !growthAxes.contains(family['stat']) ||
          (family['tiers'] as List? ?? const []).length < 2 ||
          (family['masterRequires'] as List? ?? const []).isEmpty) ||
      companionRouteModifiers.length != companions.length ||
      (endingDesign['maximumCompanionRouteSets'] as int? ?? 0) < 8 ||
      (endingDesign['maximumTerminalRouteCards'] as int? ?? 0) < 48 ||
      (endingDesign['minimumCoreEndings'] as int? ?? 0) < 6 ||
      endingDesign['evidence'] != 'lib/game_core.dart#resolveEnding') {
    fail(
        'ending matrix must define authored tiers and companion route modifiers');
  }
  if (decisionSystem['schema'] != 'lumen-ledger-v1' ||
      decisionSystem['mode'] != 'system-adjudicated' ||
      decisionSystem['humanApprovalRequired'] != false ||
      decisionSystem['failureMode'] != 'fail-closed' ||
      decisionSystem['owner'] is! String ||
      (decisionSystem['receiptFields'] as List? ?? const []).length < 5 ||
      (decisionSystem['rules'] as List? ?? const []).length < 3) {
    fail('decision system must be deterministic, fail-closed and auditable');
  }
  if (locations.length != 6 ||
      locations.map((location) => location['id']).toSet().length != 6 ||
      locations.any((location) =>
          location['name'] is! String || location['nameKey'] is! String)) {
    fail('location registry must contain six localized unique places');
  }
  final locationIds = locations.map((location) => location['id']).toSet();
  if (events.any((event) => !locationIds.contains(event['locationId']))) {
    fail('every authored event must enter a registered location');
  }
  if (legacyProfiles.length != 3 ||
      legacyProfiles.map((profile) => profile['id']).toSet().length != 3 ||
      legacyProfiles.any((profile) =>
          profile['stat'] is! String ||
          !activities.any((activity) => activity['stat'] == profile['stat']) ||
          profile['bonus'] is! int ||
          profile['bonus'] < 1 ||
          !companions
              .any((companion) => companion['id'] == profile['companionId']) ||
          profile['targetEndingId'] is! String ||
          !(profile['endingIds'] as List).contains(profile['targetEndingId']) ||
          !endingIds.contains('${profile['targetEndingId']}') ||
          profile['titleKey'] is! String ||
          (profile['endingIds'] as List? ?? const []).isEmpty ||
          (profile['endingIds'] as List)
              .any((ending) => !endingIds.contains('$ending')))) {
    fail('legacy profile contract must map three authored growth lineages');
  }
  final legacySelectionEvidence =
      (legacySelection['evidence'] as List? ?? const []).cast<String>();
  if (legacySelection['schema'] != 'lumen-legacy-selection-v1' ||
      legacySelection['unlockRule'] is! String ||
      legacySelection['ordering'] != 'legacy profile id ascending' ||
      legacySelection['maximumVisibleProfiles'] != 3 ||
      legacySelection['defaultWhenUntouched'] is! String ||
      legacySelection['effect'] is! String ||
      legacySelection['homeFeedback'] is! String ||
      legacySelection['forecast'] is! String ||
      !legacySelectionEvidence
          .contains('lib/legacy_profile_catalog.dart#unlockedLegacyProfiles') ||
      !legacySelectionEvidence
          .contains('lib/legacy_profile_forecast.dart#legacyProfileForecast') ||
      !legacySelectionEvidence.contains('lib/main.dart#legacyProfile') ||
      !legacySelectionEvidence.contains('lib/main.dart#legacyPicker') ||
      !legacySelectionEvidence.contains(
          'test/legacy_profile_catalog_test.dart#collection unlocks profiles in stable order') ||
      !legacySelectionEvidence.contains(
          'test/golden_test.dart#ending exposes deterministic next-run legacy picker')) {
    fail('legacy selection must be an explicit deterministic SSOT contract');
  }
  final lineageDistribution =
      (story['lineageDistribution'] as Map? ?? {}).cast<String, dynamic>();
  final lineageEvidence =
      (lineageDistribution['evidence'] as List? ?? const []).cast<String>();
  if (lineageDistribution['schema'] != 'lumen-lineage-distribution-v1' ||
      lineageDistribution['policyCount'] != activities.length ||
      lineageDistribution['profileCount'] != legacyProfiles.length ||
      (lineageDistribution['minimumDistinctEndingsPerProfile'] as int? ?? 0) <
          3 ||
      (lineageDistribution['minimumDistinctSignaturesPerProfile'] as int? ??
              0) <
          3 ||
      (lineageDistribution['observedDistinctEndingsPerProfile'] as int? ?? 0) <
          4 ||
      (lineageDistribution['observedDistinctSignaturesPerProfile'] as int? ??
              0) <
          4 ||
      (lineageDistribution['distinctProfileFingerprints'] as int? ?? 0) < 3 ||
      !lineageEvidence
          .contains('tool/benchmark_game.dart#profile-policy-distribution') ||
      !lineageEvidence.contains(
          'test/gameplay_metrics_test.dart#each legacy profile keeps a deterministic distribution across policies') ||
      !lineageEvidence.contains(
          'test/golden_test.dart#ending exposes deterministic next-run legacy picker')) {
    fail(
        'legacy profile policy distribution must be an explicit SSOT contract');
  }
  final scenarioDimensions =
      (scenario['dimensions'] as List? ?? []).cast<Map<String, dynamic>>();
  const scenarioIds = {
    'arc',
    'agency',
    'relationship',
    'feedback',
    'gating',
    'replay',
    'presentation',
    'closure'
  };
  if (scenario['schema'] != 'life-sim-scenario-v1' ||
      scenarioDimensions.length != scenarioIds.length ||
      scenarioDimensions.map((d) => d['id']).toSet().length !=
          scenarioDimensions.length ||
      !scenarioDimensions
          .map((d) => d['id'])
          .toSet()
          .containsAll(scenarioIds) ||
      scenarioDimensions.any((d) =>
          d['name'] is! String ||
          d['target'] is! String ||
          d['current'] is! String ||
          d['evidence'] is! String)) {
    fail('scenario completeness contract invalid');
  }
  if (activities.length != 5 || people.length != 3 || companions.length != 3)
    fail('expected 5 activities, 3 personalities and 3 companions');
  if (endings.length != 6) fail('expected 6 authored endings');
  if ({...activities.map((e) => e['id'])}.length != activities.length)
    fail('activity ids are not unique');
  if ({...people.map((e) => e['id'])}.length != people.length)
    fail('personality ids are not unique');
  if ({...companions.map((e) => e['id'])}.length != companions.length)
    fail('companion ids are not unique');
  final expectedRouteIds = {
    for (final person in people)
      for (final companion in companions) '${person['id']}:${companion['id']}'
  };
  final routeIds =
      personalityCompanionRoutes.map((route) => '${route['id']}').toSet();
  if (personalityCompanionRoutes.length != expectedRouteIds.length ||
      routeIds.length != expectedRouteIds.length ||
      !routeIds.containsAll(expectedRouteIds) ||
      personalityCompanionRoutes
              .where((route) => route['matched'] == true)
              .length !=
          people.length ||
      personalityCompanionRoutes.any((route) =>
          route['bondBonus'] is! int ||
          (route['matched'] == true && route['bondBonus'] < 1) ||
          (route['matched'] != true && route['bondBonus'] != 0))) {
    fail(
        'personality-companion route matrix must cover matched and neutral pairs');
  }
  if (people.any((e) =>
      e['focusStat'] is! String ||
      e['focusBonus'] is! int ||
      e['focusBonus'] < 1)) fail('personality talent contract invalid');
  if (companions.any((e) =>
      e['bondThreshold'] is! int ||
      e['bondThreshold'] < 1 ||
      e['epilogue'] is! String ||
      (e['epilogue'] as String).isEmpty))
    fail('companion epilogue contract invalid');
  final expectedEventWeeks = [
    for (var week = 2; week <= campaignWeeks; week++) week
  ];
  if (events.length != campaignWeeks - 1 ||
      events.map((e) => e['week']).toList().join(',') !=
          expectedEventWeeks.join(','))
    fail(
        'events must cover every authored week from 2 through the terminal campaign week');
  final expectedChapterRanges = [
    for (var start = 1; start <= campaignWeeks; start += 3)
      '${start}-${start + 2}'
  ];
  if (progression.length != campaignWeeks ~/ 3 ||
      progression.map((c) => '${c['weekStart']}-${c['weekEnd']}').join(',') !=
          expectedChapterRanges.join(','))
    fail(
        'progression must cover contiguous three-week chapters through the campaign');
  final eventWeeks = events.map((e) => e['week']).toSet();
  if (progression.any((c) =>
      c['titleKey'] is! String ||
      c['premiseKey'] is! String ||
      c['payoffKey'] is! String ||
      ((c['relationshipScene'] as Map? ?? {})['speakerId'] is! String) ||
      ((c['relationshipScene'] as Map? ?? {})['titleKey'] is! String) ||
      ((c['relationshipScene'] as Map? ?? {})['lineKey'] is! String) ||
      (c['eventWeeks'] as List? ?? [])
          .any((week) => !eventWeeks.contains(week))))
    fail('chapter progression contract invalid');
  final milestones =
      (story['milestones'] as List? ?? []).cast<Map<String, dynamic>>();
  final expectedMilestoneWeeks = [
    for (var week = 3; week <= campaignWeeks; week += 3) week
  ];
  if (milestones.length != expectedMilestoneWeeks.length ||
      milestones.map((m) => m['week']).join(',') !=
          expectedMilestoneWeeks.join(','))
    fail('milestones must cover every chapter closure');
  if (milestones.any((m) =>
      m['id'] is! String ||
      m['title'] is! String ||
      m['stat'] is! String ||
      m['min'] is! int ||
      m['coins'] is! int ||
      m['pass'] is! String ||
      m['fail'] is! String)) fail('milestone contract invalid');
  const pressureAxes = {'stat', 'coins', 'fatigue', 'bond'};
  final chapterContractsValid = progression.every((chapter) {
    final contract =
        (chapter['contract'] as Map? ?? {}).cast<String, dynamic>();
    final eventWeeks = (chapter['eventWeeks'] as List? ?? []).cast<int>();
    final choiceWeeks = (contract['choiceWeeks'] as List? ?? []).cast<int>();
    final axes = (contract['pressureAxes'] as List? ?? []).cast<String>();
    final closure = contract['closureMilestone'];
    final closureGoal = milestones.where((m) => m['id'] == closure).firstOrNull;
    final chapterEvents = events.where((event) =>
        (event['week'] as int) >= (chapter['weekStart'] as int) &&
        (event['week'] as int) <= (chapter['weekEnd'] as int));
    return contract['reveal'] is String &&
        (contract['reveal'] as String).trim().isNotEmpty &&
        axes.length >= 2 &&
        axes.toSet().length == axes.length &&
        axes.every(pressureAxes.contains) &&
        choiceWeeks.toSet().length == eventWeeks.toSet().length &&
        choiceWeeks.toSet().containsAll(eventWeeks) &&
        choiceWeeks
            .every((week) => events.any((event) => event['week'] == week)) &&
        chapterEvents.isNotEmpty &&
        chapterEvents
            .every((event) => (event['choices'] as List).length == 2) &&
        closureGoal != null &&
        closureGoal['week'] == chapter['weekEnd'];
  });
  if (!chapterContractsValid)
    fail(
        'each chapter needs reveal, two pressure axes, authored choices and a closing milestone');
  if (chapterSceneContract['schema'] != 'lumen-chapter-scene-v1' ||
      chapterSceneContract['count'] != progression.length ||
      narrativeLoop['chapterSceneCount'] != progression.length) {
    fail('every chapter must expose one deterministic relationship scene beat');
  }
  final relationshipStates = (relationshipDesign['states'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final relationshipThresholds =
      (relationshipDesign['thresholds'] as Map? ?? {}).cast<String, dynamic>();
  const relationshipStateIds = {
    'unformed',
    'balanced',
    'tension',
    'estranged',
    'truce'
  };
  final actualRelationshipStateIds =
      relationshipStates.map((state) => '${state['id']}').toSet();
  final relationshipFollowups =
      (relationshipDesign['followups'] as List? ?? const [])
          .cast<Map<String, dynamic>>();
  final followupStateIds =
      relationshipFollowups.map((followup) => '${followup['stateId']}').toSet();
  final companionIds =
      companions.map((companion) => '${companion['id']}').toSet();
  if (relationshipDesign['schema'] != 'lumen-relationship-dynamics-v1' ||
      relationshipDesign['truceFlag'] is! String ||
      relationshipThresholds['tensionGap'] is! int ||
      relationshipThresholds['estrangedGap'] is! int ||
      relationshipThresholds['tensionGap'] >=
          relationshipThresholds['estrangedGap'] ||
      relationshipStates.length != relationshipStateIds.length ||
      actualRelationshipStateIds.length != relationshipStateIds.length ||
      !actualRelationshipStateIds.containsAll(relationshipStateIds) ||
      relationshipStates.any(
          (state) => state['key'] is! String || state['fallback'] is! String) ||
      relationshipDesign['followupExclusiveGroup'] != 'relationship-followup' ||
      relationshipFollowups.length != relationshipStateIds.length ||
      followupStateIds.length != relationshipStateIds.length ||
      !followupStateIds.containsAll(relationshipStateIds) ||
      relationshipFollowups.any((followup) =>
          followup['exclusiveGroup'] != 'relationship-followup' ||
          followup['speakerId'] is! String ||
          !companionIds.contains(followup['speakerId']) ||
          followup['titleKey'] is! String ||
          followup['lineKey'] is! String ||
          followup['title'] is! String ||
          followup['line'] is! String) ||
      narrativeLoop['relationshipStateContract'] !=
          'lumen-relationship-dynamics-v1' ||
      narrativeLoop['relationshipFollowupCount'] !=
          relationshipStateIds.length ||
      narrativeLoop['relationshipFollowupContract'] !=
          'one exclusive follow-up per resolved state') {
    fail('relationship dynamics must expose five deterministic states');
  }
  for (final ref in refs) {
    final path = (ref['ref'] as String).split('#').first;
    if (!File(path).existsSync()) fail('missing code ref $path');
    final actual = sha256.convert(File(path).readAsBytesSync()).toString();
    if (actual != ref['sha256']) fail('code ref hash drift: $path');
  }
  for (final ref in assetRefs) {
    final path = (ref['ref'] as String).split('#').first;
    if (!File(path).existsSync()) fail('missing asset ref $path');
    final actual = sha256.convert(File(path).readAsBytesSync()).toString();
    if (actual != ref['sha256']) fail('asset ref hash drift: $path');
  }
  final assetPaths =
      assetRefs.map((r) => (r['ref'] as String).split('#').first).toSet();
  if (!assetPaths.contains('assets/noa-sprite-sheet.png') ||
      !assetPaths.contains('assets/lumen-personality-sheet.png'))
    fail('hero/personality PNGs must be declared in assetRefs');
  if (people.any((p) =>
      !assetPaths.contains(p['portraitAsset']) ||
      (p['design'] as Map?)?['palette'] is! String ||
      (p['design'] as Map?)?['motif'] is! String ||
      (p['design'] as Map?)?['silhouette'] is! String))
    fail('personality design-to-PNG contract invalid');
  for (final character in characterArchive) {
    final emotionAsset = character['emotionAsset'];
    if (emotionAsset is String && !assetPaths.contains(emotionAsset)) {
      fail('character emotion asset is not declared: ${character['id']}');
    }
  }
  if (!characterArchive.any((character) =>
      character['id'] == 'doran' &&
      character['emotionAsset'] ==
          'assets/generated/character-emotions/doran.png')) {
    fail('doran emotion sheet contract is missing');
  }
  final emotionAssets = characterArchive
      .map((character) => character['emotionAsset'])
      .whereType<String>()
      .toSet();
  if (emotionAssets.length != characterArchive.length ||
      emotionAssets.length != 20) {
    fail('all twenty character archive residents require emotion sheets');
  }
  for (final event in events) {
    final illustrationAsset = event['illustrationAsset'];
    if (illustrationAsset is! String ||
        !assetPaths.contains(illustrationAsset)) {
      fail('event illustration asset is not declared: ${event['week']}');
    }
  }
  final sideIllustrationFrames = <String, Set<int>>{};
  for (final scene in sideScenes) {
    final asset = scene['illustrationAsset'];
    final frame = scene['illustrationFrame'];
    if (asset is! String ||
        !assetPaths.contains(asset) ||
        frame is! int ||
        frame < 0 ||
        frame >= 4) {
      fail('side scene illustration binding is invalid: ${scene['id']}');
    }
    (sideIllustrationFrames[asset] ??= <int>{}).add(frame);
  }
  if (sideIllustrationFrames.length != 6 ||
      sideIllustrationFrames.values.any((frames) => frames.length != 4)) {
    fail('side scene illustration matrix must be 6 sheets x 4 frames');
  }
  for (final ref in fontRefs) {
    final path = (ref['ref'] as String).split('#').first;
    if (!File(path).existsSync()) fail('missing font ref $path');
    final actual = sha256.convert(File(path).readAsBytesSync()).toString();
    if (actual != ref['sha256']) fail('font ref hash drift: $path');
  }
  if (localeRefs.length < 2) fail('at least ko and en localeRefs are required');
  final requiredLocaleKeys = authoredLocaleKeys(story);
  for (final ref in localeRefs) {
    final path = (ref['ref'] as String).split('#').first;
    if (!File(path).existsSync()) fail('missing locale ref $path');
    final actual = sha256.convert(File(path).readAsBytesSync()).toString();
    if (actual != ref['sha256']) fail('locale ref hash drift: $path');
    final catalog = decodeJsonlCatalog(File(path).readAsStringSync());
    final missing = requiredLocaleKeys
        .where(
            (key) => !catalog.containsKey(key) || catalog[key]!.trim().isEmpty)
        .toList();
    if (missing.isNotEmpty)
      fail('locale contract missing keys in $path: ${missing.join(',')}');
    if (catalog.length < (dialogueMetrics['minimumLocaleKeys'] as int? ?? 0) ||
        !catalog.keys.toSet().containsAll([
          'ui.locale.toggle',
          'ui.locale.current',
          'ui.ending.title',
          'ui.ending.subtitle',
          'ui.ending.record',
          'ui.ending.restart',
        ])) fail('locale catalog size/UI contract invalid: $path');
  }
  final stats = activities.map((e) => e['stat']).toSet();
  if (endings.any((e) =>
      !stats.contains(e['stat']) ||
      e['min'] is! int ||
      e['min'] < 1 ||
      ((e['requiresMilestones'] as List? ?? [])
          .any((id) => !milestones.any((m) => m['id'] == id)))))
    fail('ending stat/min/milestone contract invalid');
  if ({...endings.map((e) => e['id'])}.length != endings.length)
    fail('ending ids are not unique');
  if (endings.map((e) => e['stat']).toSet().length != stats.length)
    fail('every growth axis needs an ending');
  final masters =
      endings.where((e) => (e['id'] as String).endsWith('-master')).toList();
  if (masters.length != stats.length ||
      masters.any((e) => (e['requiresMilestones'] as List? ?? []).isEmpty))
    fail('every growth axis needs a milestone-gated master ending');
  if (activities.any((e) =>
      e['fatigue'] is! int ||
      e['fatigue'] < -2 ||
      e['fatigue'] > 2 ||
      e['coins'] is! int)) fail('activity risk/reward contract invalid');
  for (final event in events) {
    final choices = (event['choices'] as List).cast<Map<String, dynamic>>();
    if (choices.length != 2) fail('each event needs exactly 2 choices');
    for (final choice in choices) {
      if (!stats.contains(choice['stat']))
        fail('event choice targets an unknown stat');
      if (choice['delta'] is! int || choice['coins'] is! int)
        fail('event deltas must be ints');
      if (!companions.any((c) => c['id'] == choice['bondId']) ||
          choice['bondDelta'] is! int ||
          choice['bondDelta'] < 0) fail('event bond contract invalid');
      if (choice['rivalId'] != null &&
          (!companions.any((c) => c['id'] == choice['rivalId']) ||
              choice['rivalId'] == choice['bondId'] ||
              choice['rivalDelta'] is! int)) {
        fail('event rival bond contract invalid');
      }
      if (choice['requiresStat'] != null &&
          (!stats.contains(choice['requiresStat']) ||
              choice['requiresMin'] is! int ||
              choice['requiresMin'] < 1))
        fail('event requirement contract invalid');
      if (choice['requiresBondId'] != null &&
          (!companions.any((c) => c['id'] == choice['requiresBondId']) ||
              choice['requiresBondMin'] is! int ||
              choice['requiresBondMin'] < 1))
        fail('event relationship requirement contract invalid');
      if (choice['requiresFlag'] != null && choice['requiresFlag'] is! String)
        fail('event memory requirement contract invalid');
      if (choice['setsFlag'] != null &&
          (choice['setsFlag'] is! String ||
              (choice['setsFlag'] as String).isEmpty))
        fail('event memory output contract invalid');
      if (choice['legacyBonuses'] != null) {
        final bonuses =
            (choice['legacyBonuses'] as Map).cast<String, dynamic>();
        final profileIds =
            legacyProfiles.map((profile) => '${profile['id']}').toSet();
        if (!bonuses.keys.toSet().containsAll(profileIds) ||
            bonuses.length != profileIds.length ||
            bonuses.values.any((bonus) =>
                bonus is! Map ||
                !stats.contains(bonus['stat']) ||
                bonus['delta'] is! int ||
                bonus['delta'] < 1)) {
          fail('legacy choice must define one valid bonus for every lineage');
        }
      }
    }
  }
  final writtenFlags = events
      .expand((e) => (e['choices'] as List).cast<Map<String, dynamic>>())
      .map((c) => c['setsFlag'])
      .whereType<String>()
      .toSet();
  final requiredFlags = events
      .expand((e) => (e['choices'] as List).cast<Map<String, dynamic>>())
      .map((c) => c['requiresFlag'])
      .whereType<String>()
      .toSet();
  const seededFlags = {'legacy-star'};
  if (writtenFlags.isEmpty ||
      !requiredFlags.contains('legacy-star') ||
      !writtenFlags.containsAll(requiredFlags.difference(seededFlags)))
    fail('every event memory gate needs an authored prior flag');
  if (!events.any((event) => (event['choices'] as List)
      .cast<Map<String, dynamic>>()
      .any((choice) => choice['legacyBonuses'] is Map))) {
    fail('scenario needs an authored lineage-specific choice bonus');
  }
  if (!events.any((e) => (e['choices'] as List)
      .cast<Map<String, dynamic>>()
      .any((choice) => choice['rivalId'] != null))) {
    fail('scenario needs at least one rival-bond choice');
  }
  if (fateThreads.length < 6 ||
      fateThreads.map((thread) => thread['id']).toSet().length !=
          fateThreads.length ||
      fateThreads.any((thread) =>
          thread['id'] is! String ||
          thread['flag'] is! String ||
          thread['titleRef'] is! String ||
          thread['detailKey'] is! String ||
          thread['detail'] is! String ||
          thread['detailEn'] is! String ||
          !writtenFlags.contains(thread['flag']))) {
    fail('butterfly ledger must use unique authored memory flags');
  }
  final companionIdSet =
      companions.map((companion) => '${companion['id']}').toSet();
  if (companionQuests.length != companions.length ||
      companionQuests.map((quest) => quest['companionId']).toSet().length !=
          companionQuests.length ||
      companionQuests.any((quest) {
        final stages =
            (quest['stages'] as List? ?? const []).cast<Map<String, dynamic>>();
        return quest['id'] is! String ||
            !companionIdSet.contains('${quest['companionId']}') ||
            quest['titleRef'] is! String ||
            stages.length < 3 ||
            stages.map((stage) => stage['id']).toSet().length !=
                stages.length ||
            stages.any((stage) =>
                stage['id'] is! String ||
                stage['flag'] is! String ||
                !writtenFlags.contains(stage['flag']) ||
                stage['bondMin'] is! int ||
                stage['bondMin'] < 0 ||
                stage['eventRef'] is! String);
      })) {
    fail('companion quests must define three authored stages per companion');
  }
  final trackedLocaleKeys = <String>{
    ...fateThreads.map((thread) => '${thread['titleRef']}'),
    ...fateThreads.map((thread) => '${thread['detailKey']}'),
    ...companionQuests.map((quest) => '${quest['titleRef']}'),
    ...companionQuests.expand((quest) => (quest['stages'] as List)
        .cast<Map<String, dynamic>>()
        .map((stage) => '${stage['eventRef']}')),
  };
  for (final ref in localeRefs) {
    final catalog = decodeJsonlCatalog(
        File((ref['ref'] as String).split('#').first).readAsStringSync());
    if (trackedLocaleKeys.any((key) => !catalog.containsKey(key)))
      fail('butterfly/companion locale ref missing in ${ref['ref']}');
  }
  final narrativeContractEvidence =
      (narrativeLoop['evidence'] as List? ?? const [])
          .map((entry) => '$entry')
          .toSet();
  if (narrativeLoop['schema'] != 'lumen-memory-companion-loop-v1' ||
      narrativeLoop['fateThreadCount'] != fateThreads.length ||
      narrativeLoop['companionQuestCount'] != companionQuests.length ||
      narrativeLoop['companionSceneCount'] != companionScenes.length ||
      narrativeLoop['stagesPerQuest'] != 3 ||
      narrativeLoop['systemOwner'] != 'lumen-rule-engine' ||
      narrativeLoop['resolver'] is! String ||
      !(narrativeLoop['resolver'] as String)
          .contains('lib/game_core.dart#resolveFateThreads') ||
      !(narrativeLoop['resolver'] as String)
          .contains('lib/game_core.dart#resolveCompanionQuests') ||
      !(narrativeLoop['resolver'] as String)
          .contains('lib/game_core.dart#resolveCompanionScenes') ||
      narrativeLoop['evidence'] is! List ||
      !narrativeContractEvidence.contains(
          'test/narrative_ledger_test.dart#deterministic-projection') ||
      !narrativeContractEvidence.contains(
          'test/companion_scene_test.dart#companion scene resolver and record loop') ||
      !narrativeContractEvidence.contains(
          'test/companion_scene_golden_test.dart#companion scene archive records a scene')) {
    fail('narrative loop contract must be system-owned and deterministic');
  }
  final uiEvidence = File('test/golden_test.dart').existsSync()
      ? File('test/golden_test.dart').readAsStringSync()
      : '';
  final canonicalUiEvidence =
      File('test/canonical_golden_test.dart').existsSync()
          ? File('test/canonical_golden_test.dart').readAsStringSync()
          : '';
  final i18nEvidence = File('test/i18n_golden_test.dart').existsSync()
      ? File('test/i18n_golden_test.dart').readAsStringSync()
      : '';
  final localeEvidence = File('test/locale_contract_test.dart').existsSync()
      ? File('test/locale_contract_test.dart').readAsStringSync()
      : '';
  final progressionEvidence =
      File('test/progression_contract_test.dart').existsSync()
          ? File('test/progression_contract_test.dart').readAsStringSync()
          : '';
  final gameplayEvidence = File('test/gameplay_metrics_test.dart').existsSync()
      ? File('test/gameplay_metrics_test.dart').readAsStringSync()
      : '';
  final endingMatrixEvidence = File('test/ending_matrix_test.dart').existsSync()
      ? File('test/ending_matrix_test.dart').readAsStringSync()
      : '';
  final narrativeEvidence = File('test/narrative_ledger_test.dart').existsSync()
      ? File('test/narrative_ledger_test.dart').readAsStringSync()
      : '';
  final narrativeGoldenEvidence =
      File('test/narrative_ledger_golden_test.dart').existsSync()
          ? File('test/narrative_ledger_golden_test.dart').readAsStringSync()
          : '';
  final receiptGoldenEvidence =
      File('test/system_receipt_golden_test.dart').existsSync()
          ? File('test/system_receipt_golden_test.dart').readAsStringSync()
          : '';
  final characterRosterGoldenEvidence =
      File('test/character_roster_golden_test.dart').existsSync()
          ? File('test/character_roster_golden_test.dart').readAsStringSync()
          : '';
  final environmentAtlasGoldenEvidence =
      File('test/environment_golden_test.dart').existsSync()
          ? File('test/environment_golden_test.dart').readAsStringSync()
          : '';
  final sideSceneGoldenEvidence =
      File('test/side_scene_golden_test.dart').existsSync()
          ? File('test/side_scene_golden_test.dart').readAsStringSync()
          : '';
  final relationshipArchiveGoldenEvidence =
      File('test/relationship_archive_golden_test.dart').existsSync()
          ? File('test/relationship_archive_golden_test.dart')
              .readAsStringSync()
          : '';
  final companionSceneGoldenEvidence =
      File('test/companion_scene_golden_test.dart').existsSync()
          ? File('test/companion_scene_golden_test.dart').readAsStringSync()
          : '';
  final playerFacingGoldenEvidence =
      File('test/player_facing_golden_test.dart').existsSync()
          ? File('test/player_facing_golden_test.dart').readAsStringSync()
          : '';
  final activityForecastGoldenEvidence =
      File('test/activity_forecast_golden_test.dart').existsSync()
          ? File('test/activity_forecast_golden_test.dart').readAsStringSync()
          : '';
  final activityRiskGoldenEvidence =
      File('test/activity_risk_golden_test.dart').existsSync()
          ? File('test/activity_risk_golden_test.dart').readAsStringSync()
          : '';
  final memoryForecastGoldenEvidence =
      File('test/memory_forecast_golden_test.dart').existsSync()
          ? File('test/memory_forecast_golden_test.dart').readAsStringSync()
          : '';
  final activityReflectionGoldenEvidence =
      File('test/activity_reflection_golden_test.dart').existsSync()
          ? File('test/activity_reflection_golden_test.dart').readAsStringSync()
          : '';
  final activityJournalGoldenEvidence =
      File('test/activity_journal_golden_test.dart').existsSync()
          ? File('test/activity_journal_golden_test.dart').readAsStringSync()
          : '';
  final scenarioVariantEvidence =
      File('tool/verify_scenario_variants.dart').existsSync()
          ? File('tool/verify_scenario_variants.dart').readAsStringSync()
          : '';
  final readmeEvidence = File('README.md').existsSync()
      ? File('README.md').readAsStringSync()
      : '';
  const goldenNames = {
    'home.png',
    'milestone.png',
    'event.png',
    'illustration.png',
    'ending.png',
    'save.png',
    'restart.png',
    'canonical-home.png',
    'canonical-event.png',
    'canonical-handoff-event.png',
    'collection.png',
    'canonical-ending.png',
    'feedback.png',
    'relationship-tension.png',
    'outing.png',
    'relationship-gate.png',
    'memory-gate.png',
    'legacy-gate.png',
    'legacy-profile.png',
    'legacy-picker.png',
    'legacy-picker-en.png',
    'legacy-picker-selected.png',
    'legacy-home.png',
    'companion-epilogue.png',
    'companion-stargazer.png',
    'companion-gardener.png',
    'companion-pathfinder.png',
    'narrative-ledger.png',
    'narrative-ledger-en.png',
    'system-receipt.png',
    'character-roster.png',
    'character-roster-en.png',
    'environment-atlas.png',
    'environment-atlas-en.png',
    'side-scene.png',
    'side-scene-en.png',
    'relationship-archive.png',
    'relationship-archive-en.png',
    'relationship-archive-kind.png',
    'relationship-archive-bold.png',
    'personality-quiet.png',
    'personality-kind.png',
    'personality-bold.png',
    'activity-forecast.png',
    'activity-risk.png',
    'memory-forecast.png',
    'activity-reflection-en.png',
    'activity-journal-ko.png',
    'activity-journal-en.png',
    'english-illustration.png',
    'english-event.png',
    'english-ending.png',
    'companion-scenes.png',
    'companion-scene-choice.png',
    'companion-scene-recorded.png',
    'companion-scene-recorded-en.png',
    'companion-scene-lumi-mixed.png',
    'companion-scene-bora-mixed.png',
    'companion-scene-taro-mixed.png',
    'companion-scene-locked.png'
  };
  final goldenFiles = Directory('test/goldens').existsSync()
      ? Directory('test/goldens')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.png'))
          .map((f) => f.uri.pathSegments.last)
          .toSet()
      : <String>{};
  final storyEvidence = File('test/story_integration_test.dart').existsSync()
      ? File('test/story_integration_test.dart').readAsStringSync()
      : '';
  final coreEvidence = File('test/game_core_test.dart').existsSync()
      ? File('test/game_core_test.dart').readAsStringSync()
      : '';
  final purityEvidence = File('test/purity_integration_test.dart').existsSync()
      ? File('test/purity_integration_test.dart').readAsStringSync()
      : '';
  final scenarioEvidence = File('docs/scenario-completeness.md').existsSync()
      ? File('docs/scenario-completeness.md').readAsStringSync()
      : '';
  final completenessEvidence = File('docs/game-completeness.md').existsSync()
      ? File('docs/game-completeness.md').readAsStringSync()
      : '';
  final goldenCount = goldenFiles.length;
  if (!readmeEvidence.contains('전체 Canvas Golden 증적은 ${goldenCount}장') ||
      !completenessEvidence.contains('Golden | $goldenCount |') ||
      !scenarioEvidence.contains('$goldenCount Golden,')) {
    fail(
        'Golden inventory is out of sync: files=$goldenCount, README/docs/scenario evidence must agree');
  }
  final mainEvidence = File('lib/main.dart').existsSync()
      ? File('lib/main.dart').readAsStringSync()
      : '';
  final collectionEvidence =
      File('lib/collection_adapter_web.dart').existsSync()
          ? File('lib/collection_adapter_web.dart').readAsStringSync()
          : '';
  final dimensions = <String, bool>{
    'content': activities.length >= 5 &&
        people.length >= 3 &&
        companions.length >= 3 &&
        locations.length == 6 &&
        legacyProfiles.length == 3 &&
        milestones.length == progression.length,
    'branching': events.length >= 4 &&
        events.every((e) => (e['choices'] as List).length == 2) &&
        endings.length >= 6 &&
        storyEvidence
            .contains('every authored ending and event choice is reachable'),
    'determinism': File('test/game_core_test.dart').existsSync() &&
        File('test/story_integration_test.dart').existsSync() &&
        File('test/save_state_test.dart').existsSync(),
    'visual': goldenFiles.containsAll(goldenNames) &&
        goldenNames
            .every((name) => readmeEvidence.contains('test/goldens/$name')) &&
        (uiEvidence + canonicalUiEvidence + i18nEvidence)
            .contains('matchesGoldenFile') &&
        canonicalUiEvidence
            .contains('canonical SSOT renders a stable Canvas ending') &&
        canonicalUiEvidence.contains(
            "matchesGoldenFile('goldens/canonical-handoff-event.png')") &&
        uiEvidence.contains("matchesGoldenFile('goldens/outing.png')") &&
        uiEvidence.contains("matchesGoldenFile('goldens/memory-gate.png')") &&
        uiEvidence.contains("matchesGoldenFile('goldens/legacy-gate.png')") &&
        uiEvidence
            .contains('ending exposes deterministic next-run legacy picker') &&
        uiEvidence.contains("goldens/legacy-picker.png") &&
        uiEvidence.contains("goldens/legacy-picker-en.png") &&
        uiEvidence.contains("goldens/legacy-picker-selected.png") &&
        uiEvidence.contains("goldens/legacy-home.png") &&
        uiEvidence
            .contains("matchesGoldenFile('goldens/companion-epilogue.png')") &&
        uiEvidence.contains(
            'all lineage companion epilogues have distinct Canvas evidence') &&
        i18nEvidence.contains(
            'English locale renders original dialogue and authored ending epilogue') &&
        narrativeEvidence.contains('deterministic-projection') &&
        narrativeEvidence.contains('NARRATIVE_LEDGER_OK') &&
        narrativeGoldenEvidence
            .contains("matchesGoldenFile('goldens/narrative-ledger.png')") &&
        narrativeGoldenEvidence
            .contains("matchesGoldenFile('goldens/narrative-ledger-en.png')") &&
        receiptGoldenEvidence
            .contains("matchesGoldenFile('goldens/system-receipt.png')") &&
        characterRosterGoldenEvidence
            .contains("goldens/character-roster.png") &&
        characterRosterGoldenEvidence
            .contains("goldens/character-roster-en.png") &&
        environmentAtlasGoldenEvidence
            .contains("goldens/environment-atlas.png") &&
        environmentAtlasGoldenEvidence
            .contains("goldens/environment-atlas-en.png") &&
        sideSceneGoldenEvidence.contains("goldens/side-scene.png") &&
        sideSceneGoldenEvidence.contains("goldens/side-scene-en.png") &&
        relationshipArchiveGoldenEvidence.contains(
            'relationship archive renders all personality resonance states') &&
        relationshipArchiveGoldenEvidence
            .contains("goldens/relationship-archive-kind.png") &&
        relationshipArchiveGoldenEvidence
            .contains("goldens/relationship-archive-bold.png") &&
        companionSceneGoldenEvidence
            .contains('companion scene archive records a scene') &&
        companionSceneGoldenEvidence.contains("goldens/companion-scenes.png") &&
        companionSceneGoldenEvidence
            .contains("goldens/companion-scene-recorded.png") &&
        companionSceneGoldenEvidence
            .contains("goldens/companion-scene-recorded-en.png") &&
        companionSceneGoldenEvidence
            .contains("goldens/companion-scene-choice.png") &&
        companionSceneGoldenEvidence
            .contains("goldens/companion-scene-bora-mixed.png") &&
        companionSceneGoldenEvidence
            .contains("goldens/companion-scene-taro-mixed.png") &&
        companionSceneGoldenEvidence
            .contains("goldens/companion-scene-lumi-mixed.png") &&
        companionSceneGoldenEvidence
            .contains("goldens/companion-scene-locked.png") &&
        companionSceneGoldenEvidence
            .contains('CompanionSceneLayout.choiceRect(0, 0).center') &&
        companionSceneGoldenEvidence.contains('companion choice recall and archive navigation keep their hitboxes') &&
        companionSceneGoldenEvidence.contains("goldens/companion-scene-choice-recall.png") &&
        companionSceneGoldenEvidence.contains('companion scene archive records a scene') &&
        playerFacingGoldenEvidence.contains('all personality illustration pages render deterministic portraits') &&
        playerFacingGoldenEvidence.contains("goldens/personality-quiet.png") &&
        playerFacingGoldenEvidence.contains("goldens/personality-kind.png") &&
        playerFacingGoldenEvidence.contains("goldens/personality-bold.png") &&
        activityForecastGoldenEvidence.contains('home shows deterministic activity forecasts') &&
        activityForecastGoldenEvidence.contains("goldens/activity-forecast.png") &&
        activityRiskGoldenEvidence.contains('home explains deterministic fatigue risk before spending the day') &&
        activityRiskGoldenEvidence.contains("goldens/activity-risk.png") &&
        memoryForecastGoldenEvidence.contains('event shows the authored memory impact before commit') &&
        memoryForecastGoldenEvidence.contains("goldens/memory-forecast.png") &&
        activityReflectionGoldenEvidence.contains('event shows localized activity reflection after day spend') &&
        activityReflectionGoldenEvidence.contains("goldens/activity-reflection-en.png") &&
        activityJournalGoldenEvidence.contains('activity journal renders deterministic reflection pages') &&
        activityJournalGoldenEvidence.contains("goldens/activity-journal-en.png") &&
        activityJournalGoldenEvidence.contains("goldens/activity-journal-ko.png") &&
        File('story/locales/ko.jsonl').existsSync() &&
        File('story/locales/en.jsonl').existsSync(),
    'localeContract': localeEvidence.contains(
            'all SSOT dialogue keys exist and are non-empty in every locale') &&
        localeRefs.length >= 2,
    'progression': progressionEvidence.contains(
            'sixteen SSOT chapters cover the complete 48-week progression') &&
        progression.length == campaignWeeks ~/ 3 &&
        dialogueMetrics['minimumVisibleDialogueLines'] ==
            events.length + progression.length &&
        dialogueMetrics['minimumVisibleNarrativeUnits'] >= 160,
    'assets': assetRefs.length >= 5 &&
        assetPaths.contains('assets/lumen-character-roster.png') &&
        fontRefs.isNotEmpty,
    'traceability': refs.length >= 3 &&
        File('docs/review-manifest.jsonl').existsSync() &&
        File('docs/ssot-metrics.md').existsSync(),
    'delivery': File('.github/workflows/verify.yml').existsSync() &&
        File('.githooks/pre-commit').existsSync(),
    'inputContract': uiEvidence.contains('750, 580') &&
        uiEvidence.contains('300, 580') &&
        uiEvidence.contains('650, 550'),
    'saveContinuity': coreEvidence
            .contains('restore returns the saved page for reload continuity') &&
        File('lib/save_adapter_web.dart').existsSync(),
    'terminalSafety': coreEvidence
            .contains('completed campaign rejects stale event input too') &&
        storyEvidence.contains('48-week route') &&
        coreEvidence.contains('SystemDecisionPolicy'),
    'purity': purityEvidence.contains(
            'same schedule budget yields distinct authored outcomes') &&
        purityEvidence.contains("'stargazer-master'") &&
        purityEvidence.contains("'gardener-master'") &&
        gameplayEvidence.contains(
            'five SSOT schedule policies produce measurable route variety') &&
        gameplayEvidence.contains(
            'three legacy profiles produce distinct deterministic route signatures') &&
        endingMatrixEvidence.contains(
            'ending matrix materializes all eight companion route sets') &&
        scenarioVariantEvidence.contains('SCENARIO_VARIANTS_OK') &&
        gameplayEvidence.contains('endings.length, greaterThanOrEqualTo(3)') &&
        File('test/collection_test.dart').existsSync() &&
        uiEvidence.contains('ending collection survives a restart') &&
        uiEvidence
            .contains('ending exposes deterministic next-run legacy picker') &&
        mainEvidence.contains('selectedLegacyId') &&
        mainEvidence.contains('legacyPicker(c)') &&
        mainEvidence.contains('createCollectionAdapter') &&
        collectionEvidence.contains('lumen-collection-v1'),
    'scenarioCompleteness': scenarioDimensions.length == 8 &&
        chapterContractsValid &&
        scenarioEvidence.contains('막 단위 계약') &&
        scenarioEvidence.contains('장소 발견') &&
        scenarioEvidence.contains('회차 계승') &&
        scenarioEvidence.contains('choiceConsequenceRate') &&
        scenarioEvidence.contains('나비효과') &&
        storyEvidence
            .contains('every authored ending and event choice is reachable'),
  };
  final score =
      (dimensions.values.where((v) => v).length * 100 / dimensions.length)
          .round();
  if (score < 99)
    fail(
        'completeness score below 99%: $score% · failed=${dimensions.entries.where((entry) => !entry.value).map((entry) => entry.key).join(',')}');
  stdout.writeln(
      'GAME_GATE_OK: activities=${activities.length} personalities=${people.length} companions=${companions.length} personalityCompanionRoutes=${personalityCompanionRoutes.length} events=${events.length} endings=${endings.length} fateThreads=${fateThreads.length} questStages=$companionQuestStages codeRefs=${refs.length} assetRefs=${assetRefs.length} fontRefs=${fontRefs.length} goldens=$goldenCount scenarioCases=${scenarioVariantBudget['verifiedReachableCases']} routeInputs=${scenarioVariantBudget['routeInputCases']} score=$score% dimensions=${dimensions.entries.where((e) => e.value).map((e) => e.key).join(',')}');
}
