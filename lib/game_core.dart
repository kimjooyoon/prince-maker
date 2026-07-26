import 'save_state.dart';

typedef Entity = int;
abstract interface class StoryPort { List<Map<String, dynamic>> get events; List<Map<String, dynamic>> get endings; List<Map<String, dynamic>> get personalities; List<Map<String, dynamic>> get companions; int get endingWeek; }
abstract interface class SavePort { void write(String value); String? read(); }
class JsonStoryAdapter implements StoryPort { JsonStoryAdapter(this.source); final Map<String, dynamic> source; @override List<Map<String, dynamic>> get events => (source['events'] as List? ?? []).cast<Map<String, dynamic>>(); @override List<Map<String, dynamic>> get endings => (source['endings'] as List? ?? []).cast<Map<String, dynamic>>(); @override List<Map<String, dynamic>> get personalities => (source['personalities'] as List? ?? []).cast<Map<String, dynamic>>(); @override List<Map<String, dynamic>> get companions => (source['companions'] as List? ?? []).cast<Map<String, dynamic>>(); @override int get endingWeek => source['endingWeek'] as int? ?? 12; }
class MemorySaveAdapter implements SavePort { String? value; @override void write(String value) => this.value = value; @override String? read() => value; }
Map<String, dynamic> resolveEnding(StoryPort story, Map<String, int> stats, [Map<String, int>? bonds]) { final winner = stats.entries.reduce((a, b) => a.value > b.value ? a : b); final options = story.endings.where((e) => e['stat'] == winner.key).toList()..sort((a, b) => ((b['min'] as int?) ?? 0).compareTo((a['min'] as int?) ?? 0)); final result = Map<String, dynamic>.from(options.isEmpty ? {'id': 'unwritten', 'title': '루멘의 다음 장', 'body': '아직 이름 붙지 않은 가능성이 남아 있다.', 'stat': winner.key} : options.firstWhere((e) => winner.value >= ((e['min'] as int?) ?? 0), orElse: () => options.last)); if (bonds != null) { Map<String, dynamic>? chosen; for (final c in story.companions) { if ((bonds[c['id']] ?? 0) >= ((c['bondThreshold'] as int?) ?? 8) && (chosen == null || (bonds[c['id']] ?? 0) > (bonds[chosen['id']] ?? 0))) chosen = c; } if (chosen != null) result['epilogue'] = chosen['epilogue']; } return result; }

sealed class GameEvent { const GameEvent(); }
class ActivityChosen extends GameEvent { const ActivityChosen(this.stat, this.delta, this.coins, this.fatigue, {this.label = '', this.bonus = 0}); final String stat, label; final int delta, coins, fatigue, bonus; }
class StoryChoiceMade extends GameEvent { const StoryChoiceMade(this.stat, this.delta, this.coins, this.label, {this.bondId, this.bondDelta = 0}); final String stat, label; final int delta, coins, bondDelta; final String? bondId; }
class WeekAdvanced extends GameEvent { const WeekAdvanced(); }

class StatsComponent { StatsComponent(this.values); final Map<String, int> values; }
class ProgressComponent { int week = 1; int coins = 12; int fatigue = 0; int selected = 0; int persona = 0; int eventIndex = 0; String lastResult = ''; final bonds = <String, int>{'lumi':0,'bora':0,'taro':0}; final trace = <String>[]; }

/// DOD/ECS core: components are data, systems consume ordered events.
class GameWorld {
  GameWorld() { stats[0] = StatsComponent({'지혜': 4, '공감': 5, '용기': 3}); progress[0] = ProgressComponent(); }
  final stats = <Entity, StatsComponent>{};
  final progress = <Entity, ProgressComponent>{};
  final _queue = <GameEvent>[];
  void dispatch(GameEvent event) { _queue.add(event); while (_queue.isNotEmpty) _system(_queue.removeAt(0)); }
  void _system(GameEvent e) { final s = stats[0]!.values, p = progress[0]!; switch (e) { case ActivityChosen(:final stat, :final delta, :final coins, :final fatigue, :final label, :final bonus): final raw = delta + bonus, growth = (p.fatigue >= 8 ? (raw - 1).clamp(0, raw) : raw).toInt(); s[stat] = s[stat]! + growth; p.coins += coins; p.fatigue = (p.fatigue + fatigue).clamp(0, 12).toInt(); p.lastResult = '${label.isEmpty ? stat : label} · $stat +$growth · 피로 ${fatigue >= 0 ? '+' : ''}$fatigue${bonus == 0 ? '' : ' · 성격 재능 +$bonus'}'; p.trace.add('activity:$stat+$growth${bonus == 0 ? '' : '|talent+$bonus'}'); case StoryChoiceMade(:final stat, :final delta, :final coins, :final label, :final bondId, :final bondDelta): s[stat] = s[stat]! + delta; p.coins += coins; if (bondId != null) p.bonds[bondId] = ((p.bonds[bondId] ?? 0) + bondDelta).clamp(0, 100).toInt(); p.lastResult = '$label · $stat +$delta${bondId == null ? '' : ' · $bondId 유대 +$bondDelta'}'; p.trace.add('event:$label${bondId == null ? '' : '|bond:$bondId+$bondDelta'}'); case WeekAdvanced(): p.week++; } }
  GameSnapshot snapshot({int page = 0}) { final p = progress[0]!; return GameSnapshot(week: p.week, coins: p.coins, fatigue: p.fatigue, selected: p.selected, persona: p.persona, page: page, eventIndex: p.eventIndex, stats: Map.of(stats[0]!.values), bonds: Map.of(p.bonds), lastResult: p.lastResult, history: List.of(p.trace)); }
  void restore(GameSnapshot s) { final p = progress[0]!; p.week=s.week; p.coins=s.coins; p.fatigue=s.fatigue; p.selected=s.selected; p.persona=s.persona; p.eventIndex=s.eventIndex; p.lastResult=s.lastResult; p.bonds..clear()..addAll(s.bonds); p.trace..clear()..addAll(s.history); stats[0]!.values..clear()..addAll(s.stats); }
}

/// Application port: UI sends commands; adapters handle story and saves.
class GameSession {
  GameSession(this.story, this.save);
  final StoryPort story; final SavePort save; final world = GameWorld();
  void choose(ActivityChosen e) { final p = world.progress[0]!, people = story.personalities; final person = people.isEmpty ? null : people[p.persona.clamp(0, people.length - 1)]; final bonus = person?['focusStat'] == e.stat ? (person?['focusBonus'] as int? ?? 0) : 0; world.dispatch(ActivityChosen(e.stat, e.delta, e.coins, e.fatigue, label: e.label, bonus: bonus)); if (world.progress[0]!.week < story.endingWeek) world.dispatch(const WeekAdvanced()); }
  void chooseEvent(StoryChoiceMade e) => world.dispatch(e);
  void persist({int page = 0}) => save.write(world.snapshot(page: page).encode());
  void restore() { final raw = save.read(); if (raw != null) world.restore(GameSnapshot.decode(raw)); }
  GameSnapshot snapshot({int page = 0}) => world.snapshot(page: page);
}
