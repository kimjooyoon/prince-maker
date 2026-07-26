import 'save_state.dart';

typedef Entity = int;
abstract interface class StoryPort { List<Map<String, dynamic>> get events; }
abstract interface class SavePort { void write(String value); String? read(); }
class JsonStoryAdapter implements StoryPort { JsonStoryAdapter(this.source); final Map<String, dynamic> source; @override List<Map<String, dynamic>> get events => (source['events'] as List? ?? []).cast<Map<String, dynamic>>(); }
class MemorySaveAdapter implements SavePort { String? value; @override void write(String value) => this.value = value; @override String? read() => value; }

sealed class GameEvent { const GameEvent(); }
class ActivityChosen extends GameEvent { const ActivityChosen(this.stat, this.delta, this.coins, this.fatigue); final String stat; final int delta, coins, fatigue; }
class StoryChoiceMade extends GameEvent { const StoryChoiceMade(this.stat, this.delta, this.coins, this.label); final String stat, label; final int delta, coins; }
class WeekAdvanced extends GameEvent { const WeekAdvanced(); }

class StatsComponent { StatsComponent(this.values); final Map<String, int> values; }
class ProgressComponent { int week = 1; int coins = 12; int fatigue = 0; int selected = 0; int persona = 0; int eventIndex = 0; final trace = <String>[]; }

/// DOD/ECS core: components are data, systems consume ordered events.
class GameWorld {
  GameWorld() { stats[0] = StatsComponent({'지혜': 4, '공감': 5, '용기': 3}); progress[0] = ProgressComponent(); }
  final stats = <Entity, StatsComponent>{};
  final progress = <Entity, ProgressComponent>{};
  final _queue = <GameEvent>[];
  void dispatch(GameEvent event) { _queue.add(event); while (_queue.isNotEmpty) _system(_queue.removeAt(0)); }
  void _system(GameEvent e) { final s = stats[0]!.values, p = progress[0]!; switch (e) { case ActivityChosen(:final stat, :final delta, :final coins, :final fatigue): s[stat] = s[stat]! + delta; p.coins += coins; p.fatigue += fatigue; p.trace.add('activity:$stat'); case StoryChoiceMade(:final stat, :final delta, :final coins, :final label): s[stat] = s[stat]! + delta; p.coins += coins; p.trace.add('event:$label'); case WeekAdvanced(): p.week++; } }
  GameSnapshot snapshot({int page = 0}) { final p = progress[0]!; return GameSnapshot(week: p.week, coins: p.coins, fatigue: p.fatigue, selected: p.selected, persona: p.persona, page: page, eventIndex: p.eventIndex, stats: Map.of(stats[0]!.values), history: List.of(p.trace)); }
  void restore(GameSnapshot s) { final p = progress[0]!; p.week=s.week; p.coins=s.coins; p.fatigue=s.fatigue; p.selected=s.selected; p.persona=s.persona; p.eventIndex=s.eventIndex; p.trace..clear()..addAll(s.history); stats[0]!.values..clear()..addAll(s.stats); }
}

/// Application port: UI sends commands; adapters handle story and saves.
class GameSession {
  GameSession(this.story, this.save);
  final StoryPort story; final SavePort save; final world = GameWorld();
  void choose(ActivityChosen e) { world.dispatch(e); if (world.progress[0]!.week < 12) world.dispatch(const WeekAdvanced()); }
  void chooseEvent(StoryChoiceMade e) => world.dispatch(e);
  void persist({int page = 0}) => save.write(world.snapshot(page: page).encode());
  void restore() { final raw = save.read(); if (raw != null) world.restore(GameSnapshot.decode(raw)); }
  GameSnapshot snapshot({int page = 0}) => world.snapshot(page: page);
}
