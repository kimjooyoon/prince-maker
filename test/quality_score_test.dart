import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/quality_score.dart';

void main() {
  test('quality score weights are a deterministic closed sum', () {
    expect(
      qualityScoreComponents.fold<double>(
          0, (sum, component) => sum + component.weight),
      closeTo(1.0, 1e-12),
    );
    expect(
      weightedQualityScore({
        for (final component in qualityScoreComponents) component.id: 1.0,
      }),
      1.0,
    );
  });

  test('quality component normalization is capped and fail-closed', () {
    expect(cappedRatio(2, 1), 1.0);
    expect(cappedRatio(1, 2), 0.5);
    expect(cappedRatio(0, 2), 0.0);
  });
}
