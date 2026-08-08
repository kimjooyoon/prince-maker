import 'save_state.dart';

export 'decision_proof.dart';
import 'decision_proof.dart';

typedef Entity = int;

abstract interface class StoryPort {
  List<Map<String, dynamic>> get activities;
  List<Map<String, dynamic>> get locations;
  List<Map<String, dynamic>> get characters;
  List<Map<String, dynamic>> get events;
  List<Map<String, dynamic>> get sideScenes;
  List<Map<String, dynamic>> get activityScenes;
  List<Map<String, dynamic>> get companionScenes;
  List<Map<String, dynamic>> get endingVariants;
  List<Map<String, dynamic>> get endings;
  List<Map<String, dynamic>> get personalities;
  List<Map<String, dynamic>> get companions;
  List<Map<String, dynamic>> get personalityCompanionRoutes;
  List<Map<String, dynamic>> get legacyProfiles;
  List<Map<String, dynamic>> get milestones;
  List<Map<String, dynamic>> get fateThreads;
  List<Map<String, dynamic>> get companionQuests;
  Map<String, dynamic> get decisionSystem;
  Map<String, dynamic> get endingDesign;
  Map<String, dynamic> get scenarioVariantBudget;
  Map<String, dynamic> get relationshipDesign;
  int get endingWeek;
  int get campaignWeeks;
}

abstract interface class SavePort {
  void write(String value);
  String? read();
  void clear();
}

class JsonStoryAdapter implements StoryPort {
  JsonStoryAdapter(this.source);
  final Map<String, dynamic> source;

  // Story JSON is immutable for the lifetime of a session. Cache the typed
  // projections so a 48-week replay does not repeatedly cast the full SSOT
  // document on every activity, event, and system receipt.
  late final List<Map<String, dynamic>> _activities =
      (source['activities'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _locations =
      (source['locations'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _characters =
      (source['characters'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _events =
      (source['events'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _sideScenes =
      (source['sideScenes'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _activityScenes =
      (source['activityScenes'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _companionScenes =
      (source['companionScenes'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _endingVariants =
      (source['endingVariants'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _endings =
      (source['endings'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _personalities =
      (source['personalities'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _companions =
      (source['companions'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _personalityCompanionRoutes =
      (source['personalityCompanionRoutes'] as List? ?? [])
          .cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _legacyProfiles =
      (source['legacyProfiles'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _milestones =
      (source['milestones'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _fateThreads =
      (source['fateThreads'] as List? ?? []).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _companionQuests =
      (source['companionQuests'] as List? ?? []).cast<Map<String, dynamic>>();
  late final Map<String, dynamic> _decisionSystem =
      (source['decisionSystem'] as Map? ?? {}).cast<String, dynamic>();
  late final Map<String, dynamic> _endingDesign =
      (source['endingDesign'] as Map? ?? {}).cast<String, dynamic>();
  late final Map<String, dynamic> _scenarioVariantBudget =
      (source['scenarioVariantBudget'] as Map? ?? {}).cast<String, dynamic>();
  late final Map<String, dynamic> _relationshipDesign =
      _readRelationshipDesign();
  late final int _endingWeek = source['endingWeek'] as int? ?? 12;
  late final int _campaignWeeks =
      source['campaignWeeks'] as int? ?? ((_endingWeek - 1).clamp(1, 999));

  @override
  List<Map<String, dynamic>> get activities => _activities;
  @override
  List<Map<String, dynamic>> get locations => _locations;
  @override
  List<Map<String, dynamic>> get characters => _characters;
  @override
  List<Map<String, dynamic>> get events => _events;
  @override
  List<Map<String, dynamic>> get sideScenes => _sideScenes;
  @override
  List<Map<String, dynamic>> get activityScenes => _activityScenes;
  @override
  List<Map<String, dynamic>> get companionScenes => _companionScenes;
  @override
  List<Map<String, dynamic>> get endingVariants => _endingVariants;
  @override
  List<Map<String, dynamic>> get endings => _endings;
  @override
  List<Map<String, dynamic>> get personalities => _personalities;
  @override
  List<Map<String, dynamic>> get companions => _companions;
  @override
  List<Map<String, dynamic>> get personalityCompanionRoutes =>
      _personalityCompanionRoutes;
  @override
  List<Map<String, dynamic>> get legacyProfiles => _legacyProfiles;
  @override
  List<Map<String, dynamic>> get milestones => _milestones;
  @override
  List<Map<String, dynamic>> get fateThreads => _fateThreads;
  @override
  List<Map<String, dynamic>> get companionQuests => _companionQuests;
  @override
  Map<String, dynamic> get decisionSystem => _decisionSystem;
  @override
  Map<String, dynamic> get endingDesign => _endingDesign;
  @override
  Map<String, dynamic> get scenarioVariantBudget => _scenarioVariantBudget;
  @override
  Map<String, dynamic> get relationshipDesign => _relationshipDesign;

  Map<String, dynamic> _readRelationshipDesign() {
    final raw = source['relationshipDesign'];
    if (raw is Map) return raw.cast<String, dynamic>();
    return const {
      'thresholds': {'tensionGap': 2, 'estrangedGap': 5},
      'truceFlag': 'windmill-truce',
      'states': [
        {
          'id': 'unformed',
          'key': 'ui.relationship.state.unformed',
          'fallback': '아직 얽히지 않음'
        },
        {
          'id': 'balanced',
          'key': 'ui.relationship.state.balanced',
          'fallback': '나란한 동행'
        },
        {
          'id': 'tension',
          'key': 'ui.relationship.state.tension',
          'fallback': '갈라지는 마음'
        },
        {
          'id': 'estranged',
          'key': 'ui.relationship.state.estranged',
          'fallback': '멀어진 동행'
        },
        {
          'id': 'truce',
          'key': 'ui.relationship.state.truce',
          'fallback': '다시 잇는 동행'
        },
      ],
    };
  }

  @override
  int get endingWeek => _endingWeek;
  @override
  int get campaignWeeks => _campaignWeeks;
}

/// Projects authored bond opportunity-cost into one deterministic UI/replay state.
/// The resolver is pure: equal bonds and memory flags always produce equal output.
Map<String, dynamic> resolveRelationshipDynamics(
    StoryPort story, Map<String, int> bonds, Map<String, bool> flags) {
  final design = story.relationshipDesign,
      states =
          (design['states'] as List? ?? const []).cast<Map<String, dynamic>>(),
      stateById = {for (final state in states) '${state['id']}': state},
      thresholds =
          (design['thresholds'] as Map? ?? const {}).cast<String, dynamic>(),
      tensionGap = (thresholds['tensionGap'] as int?) ?? 2,
      estrangedGap = (thresholds['estrangedGap'] as int?) ?? 5,
      truceFlag = design['truceFlag'] as String? ?? 'windmill-truce';
  final ranking = bonds.entries.toList()
    ..sort((a, b) {
      final value = b.value.compareTo(a.value);
      return value == 0 ? a.key.compareTo(b.key) : value;
    });
  final lead = ranking.isEmpty ? null : ranking.first,
      distant = ranking.isEmpty ? null : ranking.last,
      top = lead?.value ?? 0,
      bottom = distant?.value ?? 0,
      gap = top - bottom;
  final id = flags[truceFlag] == true
      ? 'truce'
      : top == 0
          ? 'unformed'
          : gap >= estrangedGap
              ? 'estranged'
              : gap >= tensionGap
                  ? 'tension'
                  : 'balanced';
  final state = stateById[id] ??
      <String, dynamic>{
        'id': id,
        'key': 'ui.relationship.state.$id',
        'fallback': id,
      };
  return {
    ...state,
    'id': id,
    'gap': gap,
    'leadId': lead?.key,
    'distantId': distant?.key,
  };
}

Map<String, dynamic> resolveRelationshipFollowup(
    StoryPort story, Map<String, dynamic> relationship) {
  final design = story.relationshipDesign,
      stateId = '${relationship['id']}',
      group = design['followupExclusiveGroup'] as String? ??
          'relationship-followup',
      followups = (design['followups'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .where((item) =>
              item['exclusiveGroup'] == group && item['stateId'] == stateId)
          .toList();
  if (followups.length != 1) return const {};
  return {...followups.single, 'resolvedStateId': stateId};
}

class MemorySaveAdapter implements SavePort {
  String? value;
  @override
  void write(String value) => this.value = value;
  @override
  String? read() => value;
  @override
  void clear() => value = null;
}

int resolveRank(StoryPort story,
    {Map<String, int>? bonds, Map<String, bool>? milestones}) {
  final goals = milestones?.values.where((v) => v).length ?? 0;
  final companions = story.companions
      .where(
          (c) => (bonds?[c['id']] ?? 0) >= ((c['bondThreshold'] as int?) ?? 8))
      .length;
  return (1 + goals + companions).clamp(1, 3).toInt();
}

/// Replays the visible "butterfly effect" ledger from authored memory flags.
/// A flag is deliberately enough: the same state is shown in UI, endings and
/// save/replay traces without introducing a second mutable narrative system.
List<Map<String, dynamic>> resolveFateThreads(
    StoryPort story, Map<String, bool> flags) {
  return story.fateThreads.map((thread) {
    return {
      ...thread,
      'discovered': flags[thread['flag']] == true,
    };
  }).toList();
}

Map<String, dynamic> resolveCompanionQuest(StoryPort story, String companionId,
    Map<String, int> bonds, Map<String, bool> flags) {
  final quest = story.companionQuests
      .firstWhere((candidate) => candidate['companionId'] == companionId,
          orElse: () => {
                'id': 'missing-$companionId',
                'companionId': companionId,
                'title': companionId,
                'stages': const [],
              });
  final stages =
      (quest['stages'] as List? ?? const []).cast<Map<String, dynamic>>();
  final completed = stages.where((stage) {
    final flag = stage['flag'] as String?;
    final bondMin = (stage['bondMin'] as int?) ?? 0;
    return flag != null &&
        flags[flag] == true &&
        (bonds[companionId] ?? 0) >= bondMin;
  }).length;
  return {
    ...quest,
    'completedStages': completed,
    'totalStages': stages.length,
    'complete': stages.isNotEmpty && completed == stages.length,
  };
}

List<Map<String, dynamic>> resolveCompanionQuests(
    StoryPort story, Map<String, int> bonds, Map<String, bool> flags) {
  return story.companions
      .map((companion) =>
          resolveCompanionQuest(story, '${companion['id']}', bonds, flags))
      .toList();
}

/// Projects the independent companion scenes into a deterministic archive.
/// A scene is unlocked by the first bond point with its companion and is
/// marked complete by a persisted `companion-scene:<id>` memory flag.
List<Map<String, dynamic>> resolveCompanionScenes(
    StoryPort story, Map<String, int> bonds, Map<String, bool> flags) {
  return story.companionScenes.map((scene) {
    final companionId = '${scene['companionId']}', id = '${scene['id']}';
    return {
      ...scene,
      'unlocked': (bonds[companionId] ?? 0) > 0,
      'completed': flags['companion-scene:$id'] == true,
    };
  }).toList();
}

/// Resolves the authored personality×companion matrix without mutating state.
/// A matching pair adds one bond point to every accepted choice for that
/// companion; the same input always produces the same route receipt.
Map<String, dynamic> resolvePersonalityCompanionRoute(
    StoryPort story, int persona, String? companionId) {
  final person = story.personalities.isEmpty
      ? null
      : story.personalities[persona.clamp(0, story.personalities.length - 1)];
  final personId = '${person?['id'] ?? ''}', target = companionId ?? '';
  final route = story.personalityCompanionRoutes.firstWhere(
      (candidate) =>
          '${candidate['personaId']}' == personId &&
          '${candidate['companionId']}' == target,
      orElse: () => <String, dynamic>{});
  return route.isEmpty
      ? {
          'id': '$personId:$target',
          'personaId': personId,
          'companionId': target,
          'matched': false,
          'bondBonus': 0,
        }
      : Map<String, dynamic>.from(route);
}

Map<String, dynamic> resolveEnding(StoryPort story, Map<String, int> stats,
    {Map<String, int>? bonds, Map<String, bool>? milestones}) {
  final winner = stats.entries.reduce((a, b) => a.value > b.value ? a : b);
  final options = story.endings.where((e) => e['stat'] == winner.key).toList()
    ..sort(
        (a, b) => ((b['min'] as int?) ?? 0).compareTo((a['min'] as int?) ?? 0));
  final eligible = options
      .where((e) =>
          winner.value >= ((e['min'] as int?) ?? 0) &&
          ((e['requiresMilestones'] as List?) ?? const [])
              .every((id) => milestones?[id] == true))
      .toList();
  final result = Map<String, dynamic>.from(options.isEmpty
      ? {
          'id': 'unwritten',
          'title': '루멘의 다음 장',
          'body': '아직 이름 붙지 않은 가능성이 남아 있다.',
          'stat': winner.key
        }
      : eligible.isEmpty
          ? options.last
          : eligible.first);
  result['rank'] = resolveRank(story, bonds: bonds, milestones: milestones);
  if (bonds != null) {
    final routes = story.companions
        .where(
            (c) => (bonds[c['id']] ?? 0) >= ((c['bondThreshold'] as int?) ?? 8))
        .toList();
    if (routes.isNotEmpty) {
      Map<String, dynamic>? chosen;
      for (final c in routes) {
        if (chosen == null ||
            (bonds[c['id']] ?? 0) > (bonds[chosen['id']] ?? 0)) chosen = c;
      }
      result['epilogue'] = chosen?['epilogue'];
      result['epilogues'] = routes
          .map((route) => {
                'id': route['id'],
                'text': route['epilogue'],
                'key': route['epilogueKey']
              })
          .toList();
    }
  }
  final routeIds = ((result['epilogues'] as List?) ?? const [])
      .cast<Map>()
      .map((route) => '${route['id']}')
      .toList();
  final variant = routeIds.isNotEmpty
      ? 'relationship'
      : (result['rank'] as int? ?? 1) <= 1
          ? 'failure'
          : 'neutral';
  final variantData = story.endingVariants
      .where((candidate) =>
          candidate['coreEndingId'] == result['id'] &&
          candidate['variant'] == variant)
      .firstOrNull;
  if (variantData != null) {
    result['endingVariantId'] = variantData['id'];
    result['endingVariant'] = variant;
    result['variantTitle'] = variantData['title'];
    result['variantTitleKey'] = variantData['titleKey'];
    result['variantBody'] = variantData['body'];
    result['variantBodyKey'] = variantData['bodyKey'];
    result['variantTitleEn'] = variantData['titleEn'];
    result['variantBodyEn'] = variantData['bodyEn'];
  }
  result['endingFamily'] = '${result['id']}'.split('-').first;
  result['endingTier'] =
      '${result['id']}'.endsWith('-master') ? 'master' : 'seed';
  result['companionRouteIds'] = routeIds;
  result['routeId'] =
      '${result['id']}::${routeIds.isEmpty ? 'solo' : routeIds.join('+')}';
  return result;
}

sealed class GameEvent {
  const GameEvent();
}

class ActivityChosen extends GameEvent {
  const ActivityChosen(this.stat, this.delta, this.coins, this.fatigue,
      {this.label = '', this.activityId, this.bonus = 0});
  final String stat, label;
  final String? activityId;
  final int delta, coins, fatigue, bonus;
}

class StoryChoiceMade extends GameEvent {
  const StoryChoiceMade(this.stat, this.delta, this.coins, this.label,
      {this.bondId,
      this.bondDelta = 0,
      this.rivalId,
      this.rivalDelta = 0,
      this.requiresStat,
      this.requiresMin = 0,
      this.requiresBondId,
      this.requiresBondMin = 0,
      this.requiresFlag,
      this.setsFlag,
      this.line = '',
      this.legacyBonuses,
      this.legacyId,
      this.sourceId,
      this.requiredCompanions = const []});
  final String stat, label, line;
  final int delta, coins, bondDelta, rivalDelta, requiresMin, requiresBondMin;
  final String? bondId,
      rivalId,
      requiresStat,
      requiresBondId,
      requiresFlag,
      setsFlag;
  final Map<String, dynamic>? legacyBonuses;
  final String? legacyId;
  final String? sourceId;
  final List<String> requiredCompanions;
}

class ActivityReflectionResolved extends GameEvent {
  const ActivityReflectionResolved(this.id, this.title, this.line);
  final String id, title, line;
}

class SystemDecisionApproved extends GameEvent {
  const SystemDecisionApproved(this.receipt);
  final SystemDecisionReceipt receipt;
}

class WeekAdvanced extends GameEvent {
  const WeekAdvanced();
}

class LocationDiscovered extends GameEvent {
  const LocationDiscovered(this.id, this.name);
  final String id, name;
}

class RelationshipStateResolved extends GameEvent {
  const RelationshipStateResolved(this.id, this.gap);
  final String id;
  final int gap;
}

class RelationshipFollowupResolved extends GameEvent {
  const RelationshipFollowupResolved(this.id);
  final String id;
}

class PersonalityCompanionResonanceApplied extends GameEvent {
  const PersonalityCompanionResonanceApplied(
      this.routeId, this.companionId, this.bonus);
  final String routeId, companionId;
  final int bonus;
}

class MilestoneResolved extends GameEvent {
  const MilestoneResolved(this.id, this.title, this.stat, this.min, this.coins,
      this.pass, this.fail);
  final String id, title, stat, pass, fail;
  final int min, coins;
}

class StatsComponent {
  StatsComponent(this.values);
  final Map<String, int> values;
}

class ProgressComponent {
  int week = 1;
  int coins = 12;
  int fatigue = 0;
  int selected = 0;
  int persona = 0;
  int eventIndex = 0;
  String lastResult = '', lastLine = '';
  final bonds = <String, int>{'lumi': 0, 'bora': 0, 'taro': 0};
  final milestones = <String, bool>{};
  final flags = <String, bool>{};
  final trace = <String>[];
}

/// DOD/ECS core: components are data, systems consume ordered events.
class GameWorld {
  GameWorld() {
    stats[0] = StatsComponent({'지혜': 4, '공감': 5, '용기': 3});
    progress[0] = ProgressComponent();
  }
  final stats = <Entity, StatsComponent>{};
  final progress = <Entity, ProgressComponent>{};
  final _queue = <GameEvent>[];
  void dispatch(GameEvent event) {
    _queue.add(event);
    while (_queue.isNotEmpty) _system(_queue.removeAt(0));
    progress[0]!.coins = progress[0]!.coins.clamp(0, 999).toInt();
  }

  void _system(GameEvent e) {
    final s = stats[0]!.values, p = progress[0]!;
    switch (e) {
      case SystemDecisionApproved(:final receipt):
        p.trace.add(receipt.trace);
      case ActivityChosen(
          :final stat,
          :final delta,
          :final coins,
          :final fatigue,
          :final label,
          :final bonus
        ):
        final raw = delta + bonus,
            growth = (p.fatigue >= 8 ? (raw - 1).clamp(0, raw) : raw).toInt();
        s[stat] = s[stat]! + growth;
        p.coins += coins;
        p.fatigue = (p.fatigue + fatigue).clamp(0, 12).toInt();
        p.lastResult =
            '${label.isEmpty ? stat : label} · $stat +$growth · 피로 ${fatigue >= 0 ? '+' : ''}$fatigue${bonus == 0 ? '' : ' · 성격 재능 +$bonus'}';
        p.lastLine = '';
        p.trace
            .add('activity:$stat+$growth${bonus == 0 ? '' : '|talent+$bonus'}');
      case ActivityReflectionResolved(:final id, :final title, :final line):
        p.lastLine = line;
        p.lastResult = '${p.lastResult} · $title';
        p.trace.add('activity-scene:$id');
      case StoryChoiceMade(
          :final stat,
          :final delta,
          :final coins,
          :final label,
          :final bondId,
          :final bondDelta,
          :final rivalId,
          :final rivalDelta,
          :final setsFlag,
          :final line,
          :final legacyBonuses,
          :final legacyId
        ):
        s[stat] = s[stat]! + delta;
        p.coins += coins;
        if (bondId != null)
          p.bonds[bondId] =
              ((p.bonds[bondId] ?? 0) + bondDelta).clamp(0, 100).toInt();
        if (rivalId != null)
          p.bonds[rivalId] =
              ((p.bonds[rivalId] ?? 0) + rivalDelta).clamp(0, 100).toInt();
        final legacy = legacyId == null ? null : legacyBonuses?[legacyId];
        final legacyStat = legacy is Map ? legacy['stat'] as String? : null,
            legacyDelta = legacy is Map ? legacy['delta'] as int? ?? 0 : 0;
        if (legacyStat != null && s.containsKey(legacyStat))
          s[legacyStat] = s[legacyStat]! + legacyDelta;
        if (setsFlag != null) p.flags[setsFlag] = true;
        final relation = bondId == null
            ? ''
            : ' · $bondId 유대 +$bondDelta${rivalId == null ? '' : ' · $rivalId 유대 ${rivalDelta >= 0 ? '+' : ''}$rivalDelta'}';
        p.lastResult =
            '$label · $stat +$delta$relation${legacyStat == null ? '' : ' · 계승 $legacyStat +$legacyDelta'}${setsFlag == null ? '' : ' · 기억 기록'}';
        p.lastLine = line;
        p.trace.add(
            'event:$label${bondId == null ? '' : '|bond:$bondId+$bondDelta'}${rivalId == null ? '' : '|rival:$rivalId$rivalDelta'}${legacyStat == null ? '' : '|legacy:$legacyStat+$legacyDelta'}${setsFlag == null ? '' : '|flag:$setsFlag'}${line.isEmpty ? '' : '|line:$line'}');
      case RelationshipStateResolved(:final id, :final gap):
        p.trace.add('relationship:$id|gap:$gap');
      case RelationshipFollowupResolved(:final id):
        p.trace.add('relationship-followup:$id');
      case PersonalityCompanionResonanceApplied(
          :final routeId,
          :final companionId,
          :final bonus
        ):
        p.bonds[companionId] =
            ((p.bonds[companionId] ?? 0) + bonus).clamp(0, 100).toInt();
        p.trace.add('resonance:$routeId|bond+$bonus');
      case WeekAdvanced():
        p.week++;
      case LocationDiscovered(:final id, :final name):
        final flag = 'place:$id';
        if (p.flags[flag] != true) {
          p.flags[flag] = true;
          p.lastResult = '새 장소 · $name';
          p.lastLine = '';
          p.trace.add('location:$id');
        }
      case MilestoneResolved(
          :final id,
          :final title,
          :final stat,
          :final min,
          :final coins,
          :final pass,
          :final fail
        ):
        final success = (s[stat] ?? 0) >= min;
        p.milestones[id] = success;
        if (success) p.coins += coins;
        p.lastResult =
            '$title · ${success ? pass : fail}${success ? ' · 은화 +$coins' : ''}';
        p.lastLine = '';
        p.trace.add('milestone:$id:${success ? 'pass' : 'fail'}');
    }
  }

  GameSnapshot snapshot({int page = 0}) {
    final p = progress[0]!;
    return GameSnapshot(
        week: p.week,
        coins: p.coins,
        fatigue: p.fatigue,
        selected: p.selected,
        persona: p.persona,
        page: page,
        eventIndex: p.eventIndex,
        stats: Map.of(stats[0]!.values),
        bonds: Map.of(p.bonds),
        milestones: Map.of(p.milestones),
        flags: Map.of(p.flags),
        lastResult: p.lastResult,
        lastLine: p.lastLine,
        history: List.of(p.trace));
  }

  void restore(GameSnapshot s) {
    final p = progress[0]!;
    p.week = s.week;
    p.coins = s.coins;
    p.fatigue = s.fatigue;
    p.selected = s.selected;
    p.persona = s.persona;
    p.eventIndex = s.eventIndex;
    p.lastResult = s.lastResult;
    p.lastLine = s.lastLine;
    p.bonds
      ..clear()
      ..addAll(s.bonds);
    p.milestones
      ..clear()
      ..addAll(s.milestones);
    p.flags
      ..clear()
      ..addAll(s.flags);
    p.trace
      ..clear()
      ..addAll(s.history);
    stats[0]!.values
      ..clear()
      ..addAll(s.stats);
  }
}

/// Application port: UI sends commands; adapters handle story and saves.
class GameSession {
  GameSession(this.story, this.save,
      {this.legacyUnlocked = false, this.legacyId, this.autoPersist = true}) {
    if (legacyUnlocked) {
      world.progress[0]!.flags['legacy-star'] = true;
      final profile =
          story.legacyProfiles.where((p) => p['id'] == legacyId).firstOrNull;
      final stat = profile?['stat'] as String?,
          bonus = (profile?['bonus'] as int?) ?? 0;
      if (stat != null && world.stats[0]!.values.containsKey(stat)) {
        world.stats[0]!.values[stat] = world.stats[0]!.values[stat]! + bonus;
        world.progress[0]!.flags['legacy:$legacyId'] = true;
        world.progress[0]!.trace.add('legacy:$legacyId|$stat+$bonus');
      } else {
        world.progress[0]!.trace.add('legacy:star');
      }
    }
  }
  final StoryPort story;
  final SavePort save;
  final world = GameWorld();
  final bool legacyUnlocked;
  final String? legacyId;
  String _lastDecisionHash = 'genesis';

  /// Batch/replay ports may disable persistence without changing game rules.
  final bool autoPersist;
  SystemDecisionReceipt _decision(String kind, String subject,
      {required bool conditions}) {
    final model = story.decisionSystem,
        owner = model['owner'] as String? ?? 'Lumen Ledger System',
        contract = model['id'] as String? ?? 'lumen-ledger';
    final receipt = SystemDecisionPolicy.evaluate(
        kind: kind,
        subject: subject,
        week: world.progress[0]!.week,
        endingWeek: story.endingWeek,
        conditions: conditions,
        owner: owner,
        contract: contract,
        preconditions: _preconditionState(kind, subject, conditions),
        parentDecisionHash: _lastDecisionHash);
    _lastDecisionHash = receipt.decisionHash;
    return receipt;
  }

  String _preconditionState(String kind, String subject, bool conditions) {
    final p = world.progress[0]!, s = world.stats[0]!.values;
    // GameWorld builds every map in a fixed key order; retaining that order
    // keeps the proof payload deterministic without sorting on every input.
    String mapState(Map<Object?, Object?> values) =>
        values.entries.map((entry) => '${entry.key}=${entry.value}').join(',');
    return [
      'kind=$kind',
      'subject=$subject',
      'week=${p.week}',
      'endingWeek=${story.endingWeek}',
      'coins=${p.coins}',
      'fatigue=${p.fatigue}',
      'selected=${p.selected}',
      'persona=${p.persona}',
      'eventIndex=${p.eventIndex}',
      'stats=${mapState(s)}',
      'bonds=${mapState(p.bonds)}',
      'milestones=${mapState(p.milestones)}',
      'flags=${mapState(p.flags)}',
      'conditions=$conditions',
    ].join('|');
  }

  void _recordRejected(SystemDecisionReceipt receipt, String message) {
    final p = world.progress[0]!;
    p.lastResult = message;
    p.lastLine = '';
    p.trace.add(receipt.trace);
    persist();
  }

  void choose(ActivityChosen e) {
    final p = world.progress[0]!;
    final terminal = '${story.campaignWeeks}주 기록이 완성되었습니다 · 새 기록을 시작하세요.';
    final message = p.week >= story.endingWeek
        ? terminal
        : !world.stats[0]!.values.containsKey(e.stat)
            ? '시스템 판정 · 등록되지 않은 성장축'
            : null;
    final receipt = _decision('activity', e.label.isEmpty ? e.stat : e.label,
        conditions: message == null);
    if (!receipt.approved) {
      _recordRejected(receipt, message ?? '시스템 판정 · 입력 계약 위반');
      return;
    }
    world.dispatch(SystemDecisionApproved(receipt));
    final people = story.personalities,
        person = people.isEmpty
            ? null
            : people[p.persona.clamp(0, people.length - 1)];
    final bonus = e.delta > 0 && person?['focusStat'] == e.stat
        ? (person?['focusBonus'] as int? ?? 0)
        : 0;
    world.dispatch(ActivityChosen(e.stat, e.delta, e.coins, e.fatigue,
        label: e.label, activityId: e.activityId, bonus: bonus));
    final reflections = story.activityScenes
        .where((scene) => scene['activityId'] == e.activityId)
        .toList();
    Map<String, dynamic>? activityReflection;
    if (reflections.isNotEmpty) {
      final reflection =
          reflections[world.progress[0]!.week % reflections.length];
      activityReflection = reflection;
    }
    world.dispatch(const WeekAdvanced());
    if (!story.events.any((e) => e['week'] == world.progress[0]!.week))
      _resolveMilestone();
    final event = story.events
        .where((e) => e['week'] == world.progress[0]!.week)
        .firstOrNull;
    final locationId = event?['locationId'] as String?;
    if (locationId != null) {
      final name = event?['location'] as String? ?? locationId;
      world.dispatch(LocationDiscovered(locationId, name));
    }
    if (activityReflection != null) {
      world.dispatch(ActivityReflectionResolved('${activityReflection['id']}',
          '${activityReflection['title']}', '${activityReflection['line']}'));
    }
    persist();
  }

  void chooseEvent(StoryChoiceMade e) {
    final p = world.progress[0]!;
    final message = p.week >= story.endingWeek
        ? '${story.campaignWeeks}주 기록이 완성되었습니다 · 새 기록을 시작하세요.'
        : !world.stats[0]!.values.containsKey(e.stat)
            ? '시스템 판정 · 등록되지 않은 성장축'
            : e.sourceId != null && p.flags['side-scene:${e.sourceId}'] == true
                ? '사이드 장면은 이미 완료되었습니다 · 새로운 장면을 선택하세요.'
                : e.requiresStat != null &&
                        (world.stats[0]!.values[e.requiresStat] ?? 0) <
                            e.requiresMin
                    ? '조건 부족 · ${e.requiresStat} ${e.requiresMin} 필요'
                    : e.requiresBondId != null &&
                            (p.bonds[e.requiresBondId] ?? 0) < e.requiresBondMin
                        ? '관계 조건 부족 · ${e.requiresBondId} 유대 ${e.requiresBondMin} 필요'
                        : e.requiresFlag != null &&
                                p.flags[e.requiresFlag] != true
                            ? '기억 조건 부족 · ${e.requiresFlag} 필요'
                            : e.requiredCompanions
                                    .any((id) => (p.bonds[id] ?? 0) <= 0)
                                ? '동료 조건 부족 · ${e.requiredCompanions.join(',')} 유대 필요'
                                : null;
    final receipt =
        _decision('story-choice', e.label, conditions: message == null);
    if (!receipt.approved) {
      _recordRejected(receipt, message ?? '시스템 판정 · 입력 계약 위반');
      return;
    }
    world.dispatch(SystemDecisionApproved(receipt));
    world.dispatch(e);
    final resonance =
            resolvePersonalityCompanionRoute(story, p.persona, e.bondId),
        resonanceBonus = (resonance['bondBonus'] as int?) ?? 0;
    if (resonanceBonus > 0)
      world.dispatch(PersonalityCompanionResonanceApplied(
          '${resonance['id']}', '${resonance['companionId']}', resonanceBonus));
    final relationship = resolveRelationshipDynamics(story, p.bonds, p.flags);
    world.dispatch(RelationshipStateResolved(
        '${relationship['id']}', (relationship['gap'] as int?) ?? 0));
    final followup = resolveRelationshipFollowup(story, relationship);
    if (followup.isNotEmpty)
      world.dispatch(RelationshipFollowupResolved('${followup['id']}'));
    _resolveMilestone();
    persist();
  }

  void chooseSideScene(String sceneId, int choiceIndex) {
    final scene = story.sideScenes
        .where((candidate) => candidate['id'] == sceneId)
        .firstOrNull;
    if (scene == null) return;
    final choices = (scene['choices'] as List).cast<Map<String, dynamic>>();
    if (choiceIndex < 0 || choiceIndex >= choices.length) return;
    final c = choices[choiceIndex], p = world.progress[0]!;
    final command = StoryChoiceMade(
      c['stat'] as String,
      c['delta'] as int,
      c['coins'] as int,
      c['label'] as String,
      bondId: c['bondId'] as String?,
      bondDelta: (c['bondDelta'] as int?) ?? 0,
      rivalId: c['rivalId'] as String?,
      rivalDelta: (c['rivalDelta'] as int?) ?? 0,
      requiresStat: c['requiresStat'] as String?,
      requiresMin: (c['requiresMin'] as int?) ?? 0,
      requiresBondId: c['requiresBondId'] as String?,
      requiresBondMin: (c['requiresBondMin'] as int?) ?? 0,
      requiresFlag: c['requiresFlag'] as String?,
      setsFlag: c['setsFlag'] as String?,
      line: c['line'] as String? ?? '',
      sourceId: sceneId,
      requiredCompanions:
          (scene['requiresCompanions'] as List? ?? const []).cast<String>(),
    );
    final before = p.trace.length;
    chooseEvent(command);
    final accepted =
        p.trace.skip(before).any((trace) => trace.startsWith('event:'));
    if (accepted) {
      p.flags['side-scene:$sceneId'] = true;
      final location = story.locations
          .where((candidate) => candidate['id'] == scene['locationId'])
          .firstOrNull;
      if (location != null) {
        world.dispatch(
            LocationDiscovered('${location['id']}', '${location['name']}'));
      }
      p.trace.add('side-scene:$sceneId');
      persist();
    }
  }

  void _resolveMilestone() {
    final m = story.milestones
        .where((m) =>
            m['week'] == world.progress[0]!.week &&
            !world.progress[0]!.milestones.containsKey(m['id']))
        .firstOrNull;
    if (m != null)
      world.dispatch(MilestoneResolved(m['id'], m['title'], m['stat'], m['min'],
          m['coins'], m['pass'], m['fail']));
  }

  void persist({int page = 0}) {
    if (autoPersist) save.write(world.snapshot(page: page).encode());
  }

  GameSnapshot? restore() {
    final raw = save.read();
    if (raw == null) return null;
    final snapshot = GameSnapshot.decode(raw);
    restoreSnapshot(snapshot);
    return snapshot;
  }

  /// Restores imported state and immediately makes it the durable browser
  /// snapshot. This keeps paste/import recovery equivalent to a reload.
  void restoreSnapshot(GameSnapshot snapshot) {
    world.restore(snapshot);
    _lastDecisionHash =
        SystemDecisionPolicy.parentHash(world.progress[0]!.trace);
    persist(page: snapshot.page);
  }

  GameSnapshot snapshot({int page = 0}) => world.snapshot(page: page);
}
