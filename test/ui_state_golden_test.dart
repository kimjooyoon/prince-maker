import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/ui_state_gallery.dart';

void main() {
  testWidgets('Canvas UI state contract renders one deterministic matrix',
      (tester) async {
    await tester.pumpWidget(const SizedBox(
        width: 760,
        height: 700,
        child: RepaintBoundary(
            key: ValueKey('canvas-ui-state-matrix'),
            child: CustomPaint(painter: CanvasUiStateGalleryPainter()))));
    await expectLater(find.byKey(const ValueKey('canvas-ui-state-matrix')),
        matchesGoldenFile('goldens/ui-state-matrix.png'));
  });
}
