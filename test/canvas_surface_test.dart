import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/canvas_surface.dart';

void main() {
  test('CanvasViewport maps centered taps deterministically', () {
    const viewport = Size(1200, 900);
    final frame = CanvasViewport.frame(viewport);
    expect(frame.scale, closeTo(1, 0.0001));
    expect(frame.offset, const Offset(220, 100));
    expect(CanvasViewport.logicalTap(const Offset(220, 100), viewport),
        Offset.zero);
    expect(CanvasViewport.logicalTap(const Offset(980, 800), viewport),
        const Offset(760, 700));
  });
}
