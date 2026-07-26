import 'dart:convert';

/// Versioned, deterministic state used by save slots and replay evidence.
class GameSnapshot {
  const GameSnapshot({required this.week, required this.coins, required this.fatigue, required this.selected, required this.persona, required this.page, required this.eventIndex, required this.stats, required this.history, this.schema = 'lumen-save-v2'});
  final String schema;
  final int week, coins, fatigue, selected, persona, page, eventIndex;
  final Map<String, int> stats;
  final List<String> history;

  String encode() => jsonEncode(toJson());
  Map<String, dynamic> toJson() => {'schema': schema, 'week': week, 'coins': coins, 'fatigue': fatigue, 'selected': selected, 'persona': persona, 'page': page, 'eventIndex': eventIndex, 'stats': stats, 'history': history};
  String get replayTrace => history.join('>');

  factory GameSnapshot.decode(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    if (j['schema'] != 'lumen-save-v2') throw const FormatException('unsupported save schema');
    return GameSnapshot(week: j['week'], coins: j['coins'], fatigue: j['fatigue'], selected: j['selected'], persona: j['persona'], page: j['page'], eventIndex: j['eventIndex'], stats: (j['stats'] as Map).map((k, v) => MapEntry('$k', v as int)), history: (j['history'] as List).cast<String>());
  }
}
