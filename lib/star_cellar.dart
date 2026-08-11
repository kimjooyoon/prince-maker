enum CellarAction { up, down, left, right, pulse, reset }

class CellarPoint {
  const CellarPoint(this.x, this.y);
  final int x, y;

  @override
  bool operator ==(Object other) =>
      other is CellarPoint && other.x == x && other.y == y;
  @override
  int get hashCode => Object.hash(x, y);
  @override
  String toString() => '$x,$y';
}

class CellarState {
  const CellarState({
    required this.seed,
    required this.turn,
    required this.hearts,
    required this.score,
    required this.player,
    required this.wisps,
    required this.shards,
    required this.exit,
    required this.trace,
    this.won = false,
    this.lost = false,
  });

  final int seed, turn, hearts, score;
  final CellarPoint player, exit;
  final List<CellarPoint> wisps, shards;
  final List<String> trace;
  final bool won, lost;
  bool get complete => won || lost;
  String get fingerprint =>
      '$seed|$turn|$hearts|$score|$player|${wisps.join(';')}|${shards.join(';')}|$won|$lost|${trace.join('>')}';

  CellarState copyWith({
    int? turn,
    int? hearts,
    int? score,
    CellarPoint? player,
    List<CellarPoint>? wisps,
    List<CellarPoint>? shards,
    List<String>? trace,
    bool? won,
    bool? lost,
  }) =>
      CellarState(
        seed: seed,
        turn: turn ?? this.turn,
        hearts: hearts ?? this.hearts,
        score: score ?? this.score,
        player: player ?? this.player,
        wisps: List.unmodifiable(wisps ?? this.wisps),
        shards: List.unmodifiable(shards ?? this.shards),
        exit: exit,
        trace: List.unmodifiable(trace ?? this.trace),
        won: won ?? this.won,
        lost: lost ?? this.lost,
      );
}

class StarCellarEngine {
  const StarCellarEngine._();
  static const width = 7, height = 5;

  static CellarState initial({int seed = 17}) => CellarState(
        seed: seed,
        turn: 0,
        hearts: 3,
        score: 0,
        player: const CellarPoint(3, 4),
        wisps: const [CellarPoint(1, 1), CellarPoint(5, 1)],
        shards: const [CellarPoint(1, 3), CellarPoint(5, 3), CellarPoint(3, 1)],
        exit: const CellarPoint(3, 0),
        trace: const ['start:star-cellar'],
      );

  static CellarState step(CellarState state, CellarAction action) {
    if (action == CellarAction.reset) return initial(seed: state.seed);
    if (state.complete) return state;
    final nextTurn = state.turn + 1;
    final nextPlayer = _move(state.player, action);
    final nextWisps = action == CellarAction.pulse
        ? state.wisps
            .asMap()
            .entries
            .map(
              (entry) => CellarPoint(
                (entry.value.x + (entry.key.isEven ? 1 : -1))
                    .clamp(0, width - 1)
                    .toInt(),
                entry.value.y,
              ),
            )
            .toList()
        : state.wisps
            .asMap()
            .entries
            .map(
              (entry) => _drift(
                entry.value,
                nextPlayer,
                nextTurn + state.seed + entry.key,
              ),
            )
            .toList();
    final remaining = state.shards
        .where((shard) => shard != nextPlayer)
        .toList(growable: false);
    final hit = nextWisps.contains(nextPlayer),
        hearts = (state.hearts - (hit ? 1 : 0)).clamp(0, 3).toInt(),
        won = remaining.isEmpty && nextPlayer == state.exit,
        lost = hearts == 0;
    final score = (remaining.isEmpty ? 300 : (3 - remaining.length) * 100) +
        hearts * 20 -
        nextTurn;
    final trace = [
      ...state.trace,
      'turn:$nextTurn|action:${action.name}|player:$nextPlayer|'
          'shards:${3 - remaining.length}|hearts:$hearts',
    ];
    return state.copyWith(
      turn: nextTurn,
      hearts: hearts,
      score: score,
      player: nextPlayer,
      wisps: nextWisps,
      shards: remaining,
      trace: trace,
      won: won,
      lost: lost,
    );
  }

  static CellarPoint _move(CellarPoint point, CellarAction action) {
    var x = point.x, y = point.y;
    if (action == CellarAction.left) x--;
    if (action == CellarAction.right) x++;
    if (action == CellarAction.up) y--;
    if (action == CellarAction.down) y++;
    return CellarPoint(
      x.clamp(0, width - 1).toInt(),
      y.clamp(0, height - 1).toInt(),
    );
  }

  static CellarPoint _drift(CellarPoint wisp, CellarPoint player, int phase) {
    if (phase.isEven) {
      final dx = player.x.compareTo(wisp.x);
      return CellarPoint((wisp.x + dx).clamp(0, width - 1).toInt(), wisp.y);
    }
    final dy = player.y.compareTo(wisp.y);
    return CellarPoint(wisp.x, (wisp.y + dy).clamp(0, height - 1).toInt());
  }
}
