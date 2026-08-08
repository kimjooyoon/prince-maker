/// Shared, deterministic choice semantics for the game and its KPI gate.
///
/// A trade-off exists only when one authored choice gives at least one axis
/// and costs at least one other axis. Keeping this projection pure prevents
/// the UI and CI from quietly measuring different games.
class ChoiceImpact {
  const ChoiceImpact._(
      {required this.axisCount,
      required this.rewardAxes,
      required this.costAxes});

  static const numericAxes = ['delta', 'coins', 'bondDelta', 'rivalDelta'];

  final int axisCount;
  final int rewardAxes;
  final int costAxes;

  bool get effectful => axisCount > 0;
  bool get hasTradeoff => rewardAxes > 0 && costAxes > 0;

  factory ChoiceImpact.from(Map<String, dynamic> choice) {
    final values =
        numericAxes.map((key) => ((choice[key] as num?) ?? 0).toInt()).toList();
    return ChoiceImpact._(
        axisCount: values.where((value) => value != 0).length,
        rewardAxes: values.where((value) => value > 0).length,
        costAxes: values.where((value) => value < 0).length);
  }
}
