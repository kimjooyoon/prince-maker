import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/golden_tolerance.dart';

void main() {
  test('golden tolerance accepts exact and boundary diff', () {
    expect(acceptsCanvasGoldenDiff(exactMatch: true, diffPercent: 1), isTrue);
    expect(
      acceptsCanvasGoldenDiff(
        exactMatch: false,
        diffPercent: canvasGoldenTolerance,
      ),
      isTrue,
    );
  });

  test(
    'golden tolerance fails closed above boundary and for non-finite diff',
    () {
      expect(
        acceptsCanvasGoldenDiff(
          exactMatch: false,
          diffPercent: canvasGoldenTolerance + 0.000001,
        ),
        isFalse,
      );
      expect(
        acceptsCanvasGoldenDiff(exactMatch: false, diffPercent: double.nan),
        isFalse,
      );
      expect(
        acceptsCanvasGoldenDiff(
          exactMatch: false,
          diffPercent: double.infinity,
        ),
        isFalse,
      );
    },
  );
}
