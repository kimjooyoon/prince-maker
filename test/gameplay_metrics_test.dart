import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';

Map<String, dynamic> play(StoryPort story, Map<String, dynamic> activity,
    {String? legacyId}) {
  final session = GameSession(story, MemorySaveAdapter(),
      legacyUnlocked: legacyId != null, legacyId: legacyId);
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
    final choice = legacyId == null
        ? available.first
        : available.firstWhere(
            (choice) =>
                (choice['legacyBonuses'] as Map?)?.containsKey(legacyId) ==
                true,
            orElse: () => available.first);
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
    'trace': List.of(progress.trace)
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('five SSOT schedule policies produce measurable route variety',
      () async {
    final source = jsonDecode(await rootBundle.loadString('story/story.json'))
        as Map<String, dynamic>;
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
    final source = jsonDecode(await rootBundle.loadString('story/story.json'))
        as Map<String, dynamic>;
    final story = JsonStoryAdapter(source),
        activity =
            (source['activities'] as List).cast<Map<String, dynamic>>().first;
    final ids =
        story.legacyProfiles.map((profile) => '${profile['id']}').toList();
    final routes = [for (final id in ids) play(story, activity, legacyId: id)];
    final signatures = routes
        .map(
            (route) => '${route['ending']}|${route['stats']}|${route['bonds']}')
        .toSet();
    expect(ids, hasLength(3));
    expect(signatures, hasLength(3));
    expect(
        routes.every((route) => (route['trace'] as List)
            .any((entry) => entry.contains('|legacy:'))),
        isTrue);
    print(
        'LEGACY_METRICS_OK: profiles=${ids.length} distinctSignatures=${signatures.length}');
  });
}
