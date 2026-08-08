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

  test(
      'CanvasViewport scales a compact viewport and keeps its center invariant',
      () {
    const viewport = Size(800, 600);
    final frame = CanvasViewport.frame(viewport);
    expect(frame.scale, closeTo(600 / 700, 0.0001));
    expect(frame.offset.dx, closeTo(74.2857, 0.0001));
    expect(frame.offset.dy, 0);
    final center = CanvasViewport.logicalTap(const Offset(400, 300), viewport);
    expect(center.dx, closeTo(380, 0.0001));
    expect(center.dy, closeTo(350, 0.0001));
  });
}
