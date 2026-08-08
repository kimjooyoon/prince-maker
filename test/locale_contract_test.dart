import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Set<String> authoredKeys(dynamic node) {
  final keys = <String>{};
  if (node is Map) {
    for (final entry in node.entries) {
      if (entry.key is String &&
          entry.key.toString().endsWith('Key') &&
          entry.value is String) keys.add(entry.value as String);
      keys.addAll(authoredKeys(entry.value));
    }
  } else if (node is List) {
    for (final item in node) keys.addAll(authoredKeys(item));
  }
  return keys;
}

Future<Map<String, String>> loadCatalog(String locale) async {
  final raw =
      jsonDecode(await rootBundle.loadString('story/locales/$locale.json'))
          as Map;
  return raw.map((key, value) => MapEntry('$key', '$value'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('all SSOT dialogue keys exist and are non-empty in every locale',
      () async {
    final story = jsonDecode(utf8.decode(
        (await rootBundle.load('story/story.json')).buffer.asUint8List()));
    final required = authoredKeys(story);
    expect(required, isNotEmpty);
    final catalogs = <String, Map<String, String>>{};
    for (final locale in ['ko', 'en'])
      catalogs[locale] = await loadCatalog(locale);
    for (final entry in catalogs.entries) {
      final missing = required
          .where((key) =>
              !entry.value.containsKey(key) || entry.value[key]!.trim().isEmpty)
          .toList();
      expect(missing, isEmpty,
          reason: '${entry.key} missing SSOT keys: $missing');
    }
    expect(catalogs['ko']!.keys, containsAll(required));
    expect(catalogs['en']!.keys, containsAll(required));
    const endingUiKeys = [
      'ui.locale.toggle',
      'ui.locale.current',
      'ui.ending.title',
      'ui.ending.subtitle',
      'ui.ending.record',
      'ui.ending.retrospective',
      'ui.ending.noEvents',
      'ui.ending.goalCause',
      'ui.ending.nextGoal',
      'ui.ending.allGoals',
      'ui.ending.seasonLedger',
      'ui.ending.relationshipGoals',
      'ui.ending.restart',
      'ui.event.legacy',
      'ui.event.legacyBonus',
      'ui.ledger.button',
      'ui.ledger.title',
      'ui.ledger.subtitle',
      'ui.ledger.system',
      'ui.ledger.discovered',
      'ui.ledger.hidden',
      'ui.ledger.quest',
      'ui.ledger.complete',
      'ui.ledger.progress',
      'ui.ledger.back',
      'ui.closure.recorded',
      'ui.closure.next',
      'ui.closure.week',
      'ui.closure.goalCleared',
      'ui.closure.keepGrowing',
      'ui.closure.question',
      'ui.closure.nextPage',
      'ui.closure.link',
    ];
    expect(catalogs['ko']!.keys, containsAll(endingUiKeys));
    expect(catalogs['en']!.keys, containsAll(endingUiKeys));
    final minimum =
        (story['dialogueMetrics'] as Map)['minimumLocaleKeys'] as int;
    expect(catalogs['ko']!.length, greaterThanOrEqualTo(minimum));
    expect(catalogs['en']!.length, greaterThanOrEqualTo(minimum));
    expect(catalogs['ko']!.length, catalogs['en']!.length);
  });
}
