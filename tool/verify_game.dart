import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

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
  final story = jsonDecode(File('story/story.json').readAsStringSync())
      as Map<String, dynamic>;
  final activities = (story['activities'] as List).cast<Map<String, dynamic>>();
  final people = (story['personalities'] as List).cast<Map<String, dynamic>>();
  final companions = (story['companions'] as List).cast<Map<String, dynamic>>();
  final events = (story['events'] as List).cast<Map<String, dynamic>>();
  final endings = (story['endings'] as List).cast<Map<String, dynamic>>();
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
  if (story['endingWeek'] != 12) fail('endingWeek must be 12');
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
  if (events.length != 8 ||
      events.map((e) => e['week']).toList().join(',') != '2,3,4,6,7,8,9,10')
    fail('events must occur at weeks 2, 3, 4, 6, 7, 8, 9 and 10');
  if (progression.length != 4 ||
      progression.map((c) => '${c['weekStart']}-${c['weekEnd']}').join(',') !=
          '1-3,4-6,7-9,10-12')
    fail('progression must cover four contiguous chapters from week 1 to 12');
  final eventWeeks = events.map((e) => e['week']).toSet();
  if (progression.any((c) =>
      c['titleKey'] is! String ||
      c['premiseKey'] is! String ||
      c['payoffKey'] is! String ||
      (c['eventWeeks'] as List? ?? [])
          .any((week) => !eventWeeks.contains(week))))
    fail('chapter progression contract invalid');
  final milestones =
      (story['milestones'] as List? ?? []).cast<Map<String, dynamic>>();
  if (milestones.length != 4 ||
      milestones.map((m) => m['week']).join(',') != '3,6,9,12')
    fail('milestones must cover the four seasons');
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
    final contract = (chapter['contract'] as Map? ?? {}).cast<String, dynamic>();
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
        choiceWeeks.every((week) => events.any((event) => event['week'] == week)) &&
        chapterEvents.isNotEmpty &&
        chapterEvents.every((event) => (event['choices'] as List).length == 2) &&
        closureGoal != null &&
        closureGoal['week'] == chapter['weekEnd'];
  });
  if (!chapterContractsValid)
    fail('each chapter needs reveal, two pressure axes, authored choices and a closing milestone');
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
    final catalog = (jsonDecode(File(path).readAsStringSync()) as Map)
        .map((key, value) => MapEntry('$key', '$value'));
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
    }
  }
  if (!events.any((e) => (e['choices'] as List)
      .cast<Map<String, dynamic>>()
      .any((choice) => choice['rivalId'] != null))) {
    fail('scenario needs at least one rival-bond choice');
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
    'collection.png',
    'canonical-ending.png',
    'feedback.png',
    'relationship-tension.png',
    'english-illustration.png',
    'english-event.png',
    'english-ending.png'
  };
  final goldenFiles = Directory('test/goldens').existsSync()
      ? Directory('test/goldens')
          .listSync()
          .whereType<File>()
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
        milestones.length == 4,
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
        i18nEvidence.contains(
            'English locale renders original dialogue and authored ending epilogue') &&
        File('story/locales/ko.json').existsSync() &&
        File('story/locales/en.json').existsSync(),
    'localeContract': localeEvidence.contains(
            'all SSOT dialogue keys exist and are non-empty in every locale') &&
        localeRefs.length >= 2,
    'progression': progressionEvidence.contains(
            'four SSOT chapters cover the complete 12-week progression') &&
        progression.length == 4 &&
        dialogueMetrics['minimumVisibleDialogueLines'] == 7 &&
        dialogueMetrics['minimumVisibleNarrativeUnits'] == 27,
    'assets': assetRefs.length >= 4 && fontRefs.isNotEmpty,
    'traceability': refs.length >= 3 &&
        File('docs/review-manifest.json').existsSync() &&
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
        storyEvidence.contains('12-week route'),
    'purity': purityEvidence.contains(
            'same schedule budget yields distinct authored outcomes') &&
        purityEvidence.contains("'stargazer-master'") &&
        purityEvidence.contains("'gardener-master'") &&
        gameplayEvidence.contains(
            'five SSOT schedule policies produce measurable route variety') &&
        gameplayEvidence.contains('endings.length, greaterThanOrEqualTo(3)') &&
        File('test/collection_test.dart').existsSync() &&
        uiEvidence.contains('ending collection survives a restart') &&
        mainEvidence.contains('createCollectionAdapter') &&
        collectionEvidence.contains('lumen-collection-v1'),
    'scenarioCompleteness': scenarioDimensions.length == 8 &&
        chapterContractsValid &&
        scenarioEvidence.contains('막 단위 계약') &&
        scenarioEvidence.contains('choiceConsequenceRate') &&
        storyEvidence
            .contains('every authored ending and event choice is reachable'),
  };
  final score =
      (dimensions.values.where((v) => v).length * 100 / dimensions.length)
          .round();
  if (score < 95) fail('completeness score below 95%: $score%');
  stdout.writeln(
      'GAME_GATE_OK: activities=${activities.length} personalities=${people.length} events=${events.length} endings=${endings.length} codeRefs=${refs.length} assetRefs=${assetRefs.length} fontRefs=${fontRefs.length} combinations=${activities.length * (story['endingWeek'] as int)} score=$score% dimensions=${dimensions.entries.where((e) => e.value).map((e) => e.key).join(',')}');
}
