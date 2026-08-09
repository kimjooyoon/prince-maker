import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/jsonl.dart';

Map<String, dynamic> play(StoryPort story, Map<String, dynamic> activity,
    {String? legacyId}) {
  final session = GameSession(story, MemorySaveAdapter(),
      legacyUnlocked: legacyId != null, legacyId: legacyId);
  final targetCompanion = legacyId == null
      ? null
      : story.legacyProfiles
          .firstWhere((profile) => profile['id'] == legacyId)['companionId'];
  while (session.world.progress[0]!.week < story.endingWeek) {
    session.choose(ActivityChosen(activity['stat'], activity['delta'],
        activity['coins'], activity['fatigue'],
        label: activity['label']));
    final week = session.world.progress[0]!.week;
    final events = story.events.where((event) => event['week'] == week);
    if (events.isEmpty) continue;
    final choices =
        (events.first['choices'] as List).cast<Map<String, dynamic>>();
    final available = choices.where((choice) =>
        (choice['requiresStat'] == null ||
            (session.world.stats[0]!.values[choice['requiresStat']] ?? 0) >=
                (choice['requiresMin'] as int? ?? 0)) &&
        (choice['requiresBondId'] == null ||
            (session.world.progress[0]!.bonds[choice['requiresBondId']] ?? 0) >=
                (choice['requiresBondMin'] as int? ?? 0)) &&
        (choice['requiresFlag'] == null ||
            session.world.progress[0]!.flags[choice['requiresFlag']] == true));
    final legacyChoice = available.where((choice) =>
        (choice['legacyBonuses'] as Map?)?.containsKey(legacyId) == true);
    final companionChoice =
        available.where((choice) => choice['bondId'] == targetCompanion);
    final choice = legacyId == null
        ? available.first
        : legacyChoice.firstOrNull ??
            companionChoice.firstOrNull ??
            available.first;
    session.chooseEvent(StoryChoiceMade(
        choice['stat'], choice['delta'], choice['coins'], choice['label'],
        bondId: choice['bondId'],
        bondDelta: choice['bondDelta'],
        rivalId: choice['rivalId'],
        rivalDelta: choice['rivalDelta'] ?? 0,
        requiresStat: choice['requiresStat'],
        requiresMin: choice['requiresMin'] ?? 0,
        requiresBondId: choice['requiresBondId'],
        requiresBondMin: choice['requiresBondMin'] ?? 0,
        requiresFlag: choice['requiresFlag'],
        setsFlag: choice['setsFlag'],
        legacyBonuses:
            (choice['legacyBonuses'] as Map?)?.cast<String, dynamic>(),
        legacyId: session.legacyId,
        line: choice['line']));
  }
  final progress = session.world.progress[0]!,
      ending = resolveEnding(story, session.world.stats[0]!.values,
          bonds: progress.bonds, milestones: progress.milestones);
  return {
    'ending': ending['id'],
    'stats': Map.of(session.world.stats[0]!.values),
    'bonds': Map.of(progress.bonds),
    'goals': progress.milestones.values.where((value) => value).length,
    'epilogues': (ending['epilogues'] as List? ?? const [])
        .map((route) => '${(route as Map)['id']}')
        .toList(),
    'trace': List.of(progress.trace)
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('five SSOT schedule policies produce measurable route variety',
      () async {
    final source = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final story = JsonStoryAdapter(source),
        activities =
            (source['activities'] as List).cast<Map<String, dynamic>>();
    final routes = activities.map((activity) => play(story, activity)).toList();
    final endings = routes.map((route) => route['ending']).toSet();
    final signatures = routes
        .map(
            (route) => '${route['ending']}|${route['bonds']}|${route['goals']}')
        .toSet();
    expect(routes.length, 5);
    expect(endings.length, greaterThanOrEqualTo(3));
    expect(signatures.length, greaterThanOrEqualTo(3));
    expect(
        routes.every((route) => (route['trace'] as List).length >= 12), isTrue);
    print(
        'GAMEPLAY_METRICS_OK: policies=${routes.length} distinctEndings=${endings.length} distinctSignatures=${signatures.length}');
  });
  test('three legacy profiles produce distinct deterministic route signatures',
      () async {
    final source = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final story = JsonStoryAdapter(source),
        activities =
            (source['activities'] as List).cast<Map<String, dynamic>>();
    final ids =
        story.legacyProfiles.map((profile) => '${profile['id']}').toList();
    final routes = <Map<String, dynamic>>[];
    for (final id in ids) {
      final profile = story.legacyProfiles.firstWhere((p) => p['id'] == id),
          activity = activities.firstWhere((a) => a['stat'] == profile['stat']);
      routes.add(play(story, activity, legacyId: id));
    }
    final signatures = routes
        .map(
            (route) => '${route['ending']}|${route['stats']}|${route['bonds']}')
        .toSet();
    final endings = routes.map((route) => '${route['ending']}').toSet();
    final targetEndings = story.legacyProfiles
        .map((profile) => '${profile['targetEndingId']}')
        .toSet();
    expect(ids, hasLength(3));
    expect(signatures, hasLength(3));
    expect(targetEndings, hasLength(3));
    expect(
        story.legacyProfiles.every((profile) =>
            (profile['endingIds'] as List).contains(profile['targetEndingId'])),
        isTrue);
    expect(endings.every(targetEndings.contains), isTrue);
    expect(endings, hasLength(3));
    for (var i = 0; i < ids.length; i++) {
      final target = story.legacyProfiles[i]['companionId'];
      expect((routes[i]['epilogues'] as List).contains(target), isTrue);
    }
    expect(
        routes.every((route) => (route['trace'] as List)
            .any((entry) => entry.contains('|legacy:'))),
        isTrue);
    print(
        'LEGACY_METRICS_OK: profiles=${ids.length} distinctEndings=${endings.length} targetCompanionEpilogues=3 distinctSignatures=${signatures.length}');
  });

  test('each legacy profile keeps a deterministic distribution across policies',
      () async {
    final source = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final story = JsonStoryAdapter(source),
        activities =
            (source['activities'] as List).cast<Map<String, dynamic>>();
    final contract =
        (source['lineageDistribution'] as Map).cast<String, dynamic>();
    Future<Map<String, Map<String, Set<String>>>> collect() async {
      final result = <String, Map<String, Set<String>>>{};
      for (final profile in story.legacyProfiles) {
        final id = '${profile['id']}',
            endings = <String>{},
            signatures = <String>{};
        for (final activity in activities) {
          final route = await play(story, activity, legacyId: id);
          endings.add('${route['ending']}');
          signatures
              .add('${route['ending']}|${route['stats']}|${route['bonds']}');
        }
        result[id] = {'endings': endings, 'signatures': signatures};
      }
      return result;
    }

    final distributions = await collect(), replay = await collect();
    final observedEndings =
        contract['observedDistinctEndingsPerProfile'] as int;
    final observedSignatures =
        contract['observedDistinctSignaturesPerProfile'] as int;
    expect(activities.length, contract['policyCount']);
    expect(distributions.keys, hasLength(contract['profileCount']));
    for (final profile in story.legacyProfiles) {
      final id = '${profile['id']}', result = distributions[id]!;
      final targets = (profile['endingIds'] as List).map((id) => '$id').toSet();
      expect(result['endings']!.length, observedEndings);
      expect(result['signatures']!.length, observedSignatures);
      expect(result['endings']!.any(targets.contains), isTrue);
      expect(replay[id]!['endings'], equals(result['endings']));
      expect(replay[id]!['signatures'], equals(result['signatures']));
    }
    final fingerprints = distributions.values
        .map((result) => (result['endings']!.toList()..sort()).join('|'))
        .toSet();
    expect(fingerprints, hasLength(contract['distinctProfileFingerprints']));
    print('LEGACY_DISTRIBUTION_OK: policies=${activities.length} '
        'profiles=${distributions.length} fingerprints=${fingerprints.length}');
  });
}
