import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

Never fail(String message) { stderr.writeln('GAME_GATE_FAIL: $message'); exit(1); }
void main() {
  final story = jsonDecode(File('story/story.json').readAsStringSync()) as Map<String, dynamic>;
  final activities = (story['activities'] as List).cast<Map<String, dynamic>>();
  final people = (story['personalities'] as List).cast<Map<String, dynamic>>();
  final companions = (story['companions'] as List).cast<Map<String, dynamic>>();
  final events = (story['events'] as List).cast<Map<String, dynamic>>();
  final endings = (story['endings'] as List).cast<Map<String, dynamic>>();
  final refs = (story['codeRefs'] as List).cast<Map<String, dynamic>>();
  final assetRefs = (story['assetRefs'] as List).cast<Map<String, dynamic>>();
  final fontRefs = (story['fontRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  if (story['endingWeek'] != 12) fail('endingWeek must be 12');
  if (activities.length != 5 || people.length != 3 || companions.length != 3) fail('expected 5 activities, 3 personalities and 3 companions');
  if (endings.length != 6) fail('expected 6 authored endings');
  if ({...activities.map((e) => e['id'])}.length != activities.length) fail('activity ids are not unique');
  if ({...people.map((e) => e['id'])}.length != people.length) fail('personality ids are not unique');
  if ({...companions.map((e) => e['id'])}.length != companions.length) fail('companion ids are not unique');
  if (people.any((e) => e['focusStat'] is! String || e['focusBonus'] is! int || e['focusBonus'] < 1)) fail('personality talent contract invalid');
  if (companions.any((e) => e['bondThreshold'] is! int || e['bondThreshold'] < 1 || e['epilogue'] is! String || (e['epilogue'] as String).isEmpty)) fail('companion epilogue contract invalid');
  if (events.map((e) => e['week']).toList().join(',') != '2,3,6,8,9,10') fail('events must occur at weeks 2, 3, 6, 8, 9 and 10');
  final milestones = (story['milestones'] as List? ?? []).cast<Map<String, dynamic>>();
  if (milestones.length != 4 || milestones.map((m) => m['week']).join(',') != '3,6,9,12') fail('milestones must cover the four seasons');
  if (milestones.any((m) => m['id'] is! String || m['title'] is! String || m['stat'] is! String || m['min'] is! int || m['coins'] is! int || m['pass'] is! String || m['fail'] is! String)) fail('milestone contract invalid');
  for (final ref in refs) { final path = (ref['ref'] as String).split('#').first; if (!File(path).existsSync()) fail('missing code ref $path'); final actual = sha256.convert(File(path).readAsBytesSync()).toString(); if (actual != ref['sha256']) fail('code ref hash drift: $path'); }
  for (final ref in assetRefs) { final path = (ref['ref'] as String).split('#').first; if (!File(path).existsSync()) fail('missing asset ref $path'); final actual = sha256.convert(File(path).readAsBytesSync()).toString(); if (actual != ref['sha256']) fail('asset ref hash drift: $path'); }
  final assetPaths = assetRefs.map((r) => (r['ref'] as String).split('#').first).toSet();
  if (!assetPaths.contains('assets/noa-sprite-sheet.png') || !assetPaths.contains('assets/lumen-personality-sheet.png')) fail('hero/personality PNGs must be declared in assetRefs');
  if (people.any((p) => !assetPaths.contains(p['portraitAsset']) || (p['design'] as Map?)?['palette'] is! String || (p['design'] as Map?)?['motif'] is! String || (p['design'] as Map?)?['silhouette'] is! String)) fail('personality design-to-PNG contract invalid');
  for (final ref in fontRefs) { final path = (ref['ref'] as String).split('#').first; if (!File(path).existsSync()) fail('missing font ref $path'); final actual = sha256.convert(File(path).readAsBytesSync()).toString(); if (actual != ref['sha256']) fail('font ref hash drift: $path'); }
  final stats = activities.map((e) => e['stat']).toSet();
  if (endings.any((e) => !stats.contains(e['stat']) || e['min'] is! int || e['min'] < 1 || ((e['requiresMilestones'] as List? ?? []).any((id) => !milestones.any((m) => m['id'] == id))))) fail('ending stat/min/milestone contract invalid');
  if ({...endings.map((e) => e['id'])}.length != endings.length) fail('ending ids are not unique');
  if (endings.map((e) => e['stat']).toSet().length != stats.length) fail('every growth axis needs an ending');
  final masters = endings.where((e) => (e['id'] as String).endsWith('-master')).toList();
  if (masters.length != stats.length || masters.any((e) => (e['requiresMilestones'] as List? ?? []).isEmpty)) fail('every growth axis needs a milestone-gated master ending');
  if (activities.any((e) => e['fatigue'] is! int || e['fatigue'] < -2 || e['fatigue'] > 2 || e['coins'] is! int)) fail('activity risk/reward contract invalid');
  for (final event in events) {
    final choices = (event['choices'] as List).cast<Map<String, dynamic>>();
    if (choices.length != 2) fail('each event needs exactly 2 choices');
    for (final choice in choices) {
      if (!stats.contains(choice['stat'])) fail('event choice targets an unknown stat');
      if (choice['delta'] is! int || choice['coins'] is! int) fail('event deltas must be ints');
      if (!companions.any((c) => c['id'] == choice['bondId']) || choice['bondDelta'] is! int || choice['bondDelta'] < 0) fail('event bond contract invalid');
      if (choice['requiresStat'] != null && (!stats.contains(choice['requiresStat']) || choice['requiresMin'] is! int || choice['requiresMin'] < 1)) fail('event requirement contract invalid');
    }
  }
  final uiEvidence = File('test/golden_test.dart').existsSync() ? File('test/golden_test.dart').readAsStringSync() : '';
  final canonicalUiEvidence = File('test/canonical_golden_test.dart').existsSync() ? File('test/canonical_golden_test.dart').readAsStringSync() : '';
  final readmeEvidence = File('README.md').existsSync() ? File('README.md').readAsStringSync() : '';
  const goldenNames = {'home.png', 'milestone.png', 'event.png', 'illustration.png', 'ending.png', 'save.png', 'restart.png', 'canonical-home.png', 'collection.png', 'canonical-ending.png'};
  final goldenFiles = Directory('test/goldens').existsSync()
      ? Directory('test/goldens').listSync().whereType<File>().map((f) => f.uri.pathSegments.last).toSet()
      : <String>{};
  final storyEvidence = File('test/story_integration_test.dart').existsSync() ? File('test/story_integration_test.dart').readAsStringSync() : '';
  final coreEvidence = File('test/game_core_test.dart').existsSync() ? File('test/game_core_test.dart').readAsStringSync() : '';
  final purityEvidence = File('test/purity_integration_test.dart').existsSync() ? File('test/purity_integration_test.dart').readAsStringSync() : '';
  final mainEvidence = File('lib/main.dart').existsSync() ? File('lib/main.dart').readAsStringSync() : '';
  final collectionEvidence = File('lib/collection_adapter_web.dart').existsSync() ? File('lib/collection_adapter_web.dart').readAsStringSync() : '';
  final dimensions = <String, bool>{
    'content': activities.length >= 5 && people.length >= 3 && companions.length >= 3 && milestones.length == 4,
    'branching': events.length >= 4 && events.every((e) => (e['choices'] as List).length == 2) && endings.length >= 6 && storyEvidence.contains('every authored ending and event choice is reachable'),
    'determinism': File('test/game_core_test.dart').existsSync() && File('test/story_integration_test.dart').existsSync() && File('test/save_state_test.dart').existsSync(),
    'visual': goldenFiles.containsAll(goldenNames) && goldenNames.every((name) => readmeEvidence.contains('test/goldens/$name')) && (uiEvidence + canonicalUiEvidence).contains('matchesGoldenFile') && canonicalUiEvidence.contains('canonical SSOT renders a stable Canvas ending'),
    'assets': assetRefs.length >= 4 && fontRefs.isNotEmpty,
    'traceability': refs.length >= 3 && File('docs/review-manifest.json').existsSync() && File('docs/ssot-metrics.md').existsSync(),
    'delivery': File('.github/workflows/verify.yml').existsSync() && File('.githooks/pre-commit').existsSync(),
    'inputContract': uiEvidence.contains('750, 580') && uiEvidence.contains('300, 580') && uiEvidence.contains('650, 550'),
    'saveContinuity': coreEvidence.contains('restore returns the saved page for reload continuity') && File('lib/save_adapter_web.dart').existsSync(),
    'terminalSafety': coreEvidence.contains('completed campaign rejects stale event input too') && storyEvidence.contains('12-week route'),
    'purity': purityEvidence.contains('same schedule budget yields distinct authored outcomes') && purityEvidence.contains("'stargazer-master'") && purityEvidence.contains("'gardener-master'") && File('test/collection_test.dart').existsSync() && uiEvidence.contains('ending collection survives a restart') && mainEvidence.contains('createCollectionAdapter') && collectionEvidence.contains('lumen-collection-v1'),
  };
  final score = (dimensions.values.where((v) => v).length * 100 / dimensions.length).round();
  if (score < 95) fail('completeness score below 95%: $score%');
  stdout.writeln('GAME_GATE_OK: activities=${activities.length} personalities=${people.length} events=${events.length} endings=${endings.length} codeRefs=${refs.length} assetRefs=${assetRefs.length} fontRefs=${fontRefs.length} combinations=${activities.length * (story['endingWeek'] as int)} score=$score% dimensions=${dimensions.entries.where((e) => e.value).map((e) => e.key).join(',')}');
}
