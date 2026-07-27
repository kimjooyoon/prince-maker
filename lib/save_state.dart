import 'dart:convert';

/// Versioned, deterministic state used by save slots and replay evidence.
class GameSnapshot {
  const GameSnapshot({required this.week, required this.coins, required this.fatigue, required this.selected, required this.persona, required this.page, required this.eventIndex, required this.stats, required this.history, this.bonds = const {}, this.milestones = const {}, this.flags = const {}, this.lastResult = '', this.lastLine = '', this.schema = 'lumen-save-v7'});
  final String schema;
  final int week, coins, fatigue, selected, persona, page, eventIndex;
  final Map<String, int> stats, bonds;
  final Map<String, bool> milestones, flags;
  final String lastResult, lastLine;
  final List<String> history;

  String encode() => jsonEncode(toJson());
  Map<String, dynamic> toJson() => {'schema': schema, 'week': week, 'coins': coins, 'fatigue': fatigue, 'selected': selected, 'persona': persona, 'page': page, 'eventIndex': eventIndex, 'stats': stats, 'bonds': bonds, 'milestones': milestones, 'flags': flags, 'lastResult': lastResult, 'lastLine': lastLine, 'history': history};
  String get replayTrace => history.join('>');

  factory GameSnapshot.decode(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    if (j['schema'] != 'lumen-save-v3' && j['schema'] != 'lumen-save-v4' && j['schema'] != 'lumen-save-v5' && j['schema'] != 'lumen-save-v6' && j['schema'] != 'lumen-save-v7') throw const FormatException('unsupported save schema');
    return GameSnapshot(week: j['week'], coins: j['coins'], fatigue: j['fatigue'], selected: j['selected'], page: j['page'], persona: j['persona'], eventIndex: j['eventIndex'], stats: (j['stats'] as Map).map((k, v) => MapEntry('$k', v as int)), bonds: (j['bonds'] as Map? ?? {}).map((k, v) => MapEntry('$k', v as int)), milestones: (j['milestones'] as Map? ?? {}).map((k, v) => MapEntry('$k', v as bool)), flags: (j['flags'] as Map? ?? {}).map((k, v) => MapEntry('$k', v as bool)), lastResult: j['lastResult'] as String? ?? '', lastLine: j['lastLine'] as String? ?? '', history: (j['history'] as List).cast<String>(), schema: j['schema'] as String);
  }
}
