import 'dart:convert';

/// Versioned, deterministic state used by save slots and replay evidence.
class GameSnapshot {
  const GameSnapshot({
    required this.week,
    required this.coins,
    required this.fatigue,
    required this.selected,
    required this.persona,
    required this.page,
    required this.eventIndex,
    required this.stats,
    required this.history,
    this.bonds = const {},
    this.milestones = const {},
    this.flags = const {},
    this.lastResult = '',
    this.lastLine = '',
    this.sideSceneCursor = 0,
    this.companionSceneIndex = 0,
    this.pendingCompanionSceneId,
    this.archiveCharacterIndex = 0,
    this.archiveEmotionIndex = 0,
    this.locale = 'ko',
    this.selectedLegacyId,
    this.schema = 'lumen-save-v7',
  });

  final String schema;
  final int week, coins, fatigue, selected, persona, page, eventIndex;
  final int sideSceneCursor,
      companionSceneIndex,
      archiveCharacterIndex,
      archiveEmotionIndex;
  final String locale;
  final String? pendingCompanionSceneId, selectedLegacyId;
  final Map<String, int> stats, bonds;
  final Map<String, bool> milestones, flags;
  final String lastResult, lastLine;
  final List<String> history;

  String encode() => jsonEncode(toJson());

  Map<String, dynamic> toJson() {
    final ui = <String, dynamic>{};
    if (sideSceneCursor != 0) ui['sideSceneCursor'] = sideSceneCursor;
    if (companionSceneIndex != 0) {
      ui['companionSceneIndex'] = companionSceneIndex;
    }
    if (pendingCompanionSceneId != null) {
      ui['pendingCompanionSceneId'] = pendingCompanionSceneId;
    }
    if (archiveCharacterIndex != 0) {
      ui['archiveCharacterIndex'] = archiveCharacterIndex;
    }
    if (archiveEmotionIndex != 0) {
      ui['archiveEmotionIndex'] = archiveEmotionIndex;
    }
    if (locale != 'ko') ui['locale'] = locale;
    if (selectedLegacyId != null) ui['selectedLegacyId'] = selectedLegacyId;
    return {
      'schema': schema,
      'week': week,
      'coins': coins,
      'fatigue': fatigue,
      'selected': selected,
      'page': page,
      'persona': persona,
      'eventIndex': eventIndex,
      'stats': stats,
      'bonds': bonds,
      'milestones': milestones,
      'flags': flags,
      'lastResult': lastResult,
      'lastLine': lastLine,
      'history': history,
      if (ui.isNotEmpty) 'ui': ui,
    };
  }

  String get replayTrace => history.join('>');

  factory GameSnapshot.decode(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    if (j['schema'] != 'lumen-save-v3' &&
        j['schema'] != 'lumen-save-v4' &&
        j['schema'] != 'lumen-save-v5' &&
        j['schema'] != 'lumen-save-v6' &&
        j['schema'] != 'lumen-save-v7') {
      throw const FormatException('unsupported save schema');
    }
    final ui = (j['ui'] as Map? ?? const {}).cast<String, dynamic>();
    return GameSnapshot(
      week: j['week'],
      coins: j['coins'],
      fatigue: j['fatigue'],
      selected: j['selected'],
      page: j['page'],
      persona: j['persona'],
      eventIndex: j['eventIndex'],
      stats: (j['stats'] as Map).map((k, v) => MapEntry('$k', v as int)),
      bonds: (j['bonds'] as Map? ?? {}).map((k, v) => MapEntry('$k', v as int)),
      milestones: (j['milestones'] as Map? ?? {})
          .map((k, v) => MapEntry('$k', v as bool)),
      flags:
          (j['flags'] as Map? ?? {}).map((k, v) => MapEntry('$k', v as bool)),
      lastResult: j['lastResult'] as String? ?? '',
      lastLine: j['lastLine'] as String? ?? '',
      history: (j['history'] as List).cast<String>(),
      sideSceneCursor: ui['sideSceneCursor'] as int? ?? 0,
      companionSceneIndex: ui['companionSceneIndex'] as int? ?? 0,
      pendingCompanionSceneId: ui['pendingCompanionSceneId'] as String?,
      archiveCharacterIndex: ui['archiveCharacterIndex'] as int? ?? 0,
      archiveEmotionIndex: ui['archiveEmotionIndex'] as int? ?? 0,
      locale: ui['locale'] as String? ?? 'ko',
      selectedLegacyId: ui['selectedLegacyId'] as String?,
      schema: j['schema'] as String,
    );
  }
}
