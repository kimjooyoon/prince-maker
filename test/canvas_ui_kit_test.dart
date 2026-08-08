import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/canvas_ui_kit.dart';
import 'package:prince_maker/design_tokens.dart';

void main() {
  test('Canvas UI states keep semantic color contracts', () {
    expect(CanvasUiKit.stateFill(CanvasUiState.selected, teal), teal);
    expect(CanvasUiKit.stateText(CanvasUiState.selected, teal), isNot(teal));
    expect(CanvasUiKit.stateStroke(CanvasUiState.disabled, teal),
        ink.withValues(alpha: .18));
    expect(CanvasUiKit.stateStroke(CanvasUiState.danger, teal),
        const Color(0xffa84f3c));
  });

  test('Canvas UI primitives paint every required state', () {
    final recorder = PictureRecorder(), canvas = Canvas(recorder);
    for (final state in CanvasUiState.values) {
      CanvasUiKit.statePanel(canvas, const Rect.fromLTWH(0, 0, 120, 40),
          state: state, shadow: true);
      CanvasUiKit.badge(canvas, const Rect.fromLTWH(0, 48, 120, 24), 'state',
          state: state);
      CanvasUiKit.button(canvas, const Rect.fromLTWH(0, 80, 120, 44), 'action',
          state: state);
    }
    CanvasUiKit.progress(canvas, const Rect.fromLTWH(0, 132, 120, 6), .6);
    CanvasUiKit.divider(canvas, const Offset(0, 150), const Offset(120, 150));
    expect(recorder.endRecording(), isA<Picture>());
  });
}
