import 'package:flutter/material.dart';

import 'canvas_ui_kit.dart';
import 'design_tokens.dart';

/// Geometry-only Golden for the five shared Canvas state surfaces.
class CanvasUiStateGalleryPainter extends CustomPainter {
  const CanvasUiStateGalleryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);
    CanvasUiKit.panel(canvas, const Rect.fromLTWH(24, 24, 712, 28), fill: ink);
    CanvasUiKit.panel(canvas, const Rect.fromLTWH(24, 64, 380, 8), fill: teal,
        radius: 4);
    for (var i = 0; i < CanvasUiState.values.length; i++) {
      final state = CanvasUiState.values[i], x = 24 + i * 143.0;
      final card = Rect.fromLTWH(x, 112, 132, 286);
      CanvasUiKit.statePanel(canvas, card,
          state: state, shadow: state != CanvasUiState.disabled);
      CanvasUiKit.statePanel(canvas, Rect.fromLTWH(x + 14, 168, 104, 26),
          state: state, radius: DesignTokens.radiusBadge);
      CanvasUiKit.statePanel(canvas, Rect.fromLTWH(x + 14, 218, 104, 44),
          state: state, radius: DesignTokens.radiusControl,
          shadow: state != CanvasUiState.disabled);
      CanvasUiKit.progress(canvas, Rect.fromLTWH(x + 14, 294, 104, 7),
          (i + 1) / CanvasUiState.values.length,
          accent: CanvasUiKit.stateStroke(state, teal));
      CanvasUiKit.panel(canvas, Rect.fromLTWH(x + 14, 334, 80, 8),
          fill: CanvasUiKit.stateText(state, teal), radius: 4);
      CanvasUiKit.divider(canvas, Offset(x + 14, 354), Offset(x + 118, 354));
      CanvasUiKit.panel(canvas, Rect.fromLTWH(x + 14, 366, 52 + i * 8, 7),
          fill: ink.withValues(alpha: .65), radius: 3);
    }
    CanvasUiKit.statePanel(canvas, const Rect.fromLTWH(24, 452, 712, 138),
        state: CanvasUiState.success, shadow: true);
    CanvasUiKit.panel(canvas, const Rect.fromLTWH(46, 474, 180, 10), fill: teal,
        radius: 5);
    CanvasUiKit.panel(canvas, const Rect.fromLTWH(46, 506, 560, 9), fill: ink,
        radius: 4);
    CanvasUiKit.panel(canvas, const Rect.fromLTWH(46, 534, 330, 8),
        fill: ink.withValues(alpha: .65), radius: 4);
    CanvasUiKit.divider(canvas, const Offset(46, 566), const Offset(714, 566));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
