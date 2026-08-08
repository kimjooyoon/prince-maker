import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/choice_impact.dart';

void main() {
  test('shared projection distinguishes a meaningful trade-off', () {
    final impact = ChoiceImpact.from({
      'delta': 2,
      'coins': -1,
      'bondDelta': 3,
      'rivalDelta': 0,
    });
    expect(impact.axisCount, 3);
    expect(impact.rewardAxes, 2);
    expect(impact.costAxes, 1);
    expect(impact.hasTradeoff, isTrue);
  });

  test('a positive bundle is not mislabeled as a trade-off', () {
    final impact = ChoiceImpact.from({
      'delta': 2,
      'coins': 1,
      'bondDelta': 3,
    });
    expect(impact.effectful, isTrue);
    expect(impact.hasTradeoff, isFalse);
  });
}
