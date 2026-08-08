import 'package:flutter/material.dart';

import 'canvas_ui_kit.dart';
import 'design_tokens.dart';

/// A deterministic visual contract for the reusable Canvas state surfaces.
class CanvasUiStateGalleryPainter extends CustomPainter {
  const CanvasUiStateGalleryPainter();

  static const labels = ['IDLE', 'SELECTED', 'DISABLED', 'SUCCESS', 'DANGER'];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);
    _text(canvas, 'Lumen Canvas Kit · state contract', const Offset(24, 26), 24,
        ink, true);
    _text(canvas, 'One reusable surface, five deterministic meanings.',
        const Offset(25, 62), 13, teal, false);
    for (var i = 0; i < CanvasUiState.values.length; i++) {
      final state = CanvasUiState.values[i];
      final x = 24 + i * 143.0;
      final card = Rect.fromLTWH(x, 112, 132, 286);
      CanvasUiKit.statePanel(canvas, card,
          state: state, shadow: state != CanvasUiState.disabled);
      _text(canvas, labels[i], Offset(x + 14, 132), 12,
          CanvasUiKit.stateText(state, teal), true);
      CanvasUiKit.badge(canvas, Rect.fromLTWH(x + 14, 168, 104, 26),
          state == CanvasUiState.disabled ? 'LOCKED' : 'AVAILABLE',
          state: state, fontSize: 10);
      CanvasUiKit.button(canvas, Rect.fromLTWH(x + 14, 218, 104, 44),
          state == CanvasUiState.danger ? 'REVIEW' : 'CHOOSE',
          state: state, fontSize: 11);
      CanvasUiKit.progress(canvas, Rect.fromLTWH(x + 14, 294, 104, 7),
          (i + 1) / CanvasUiState.values.length,
          accent: CanvasUiKit.stateStroke(state, teal));
      _text(canvas, 'feedback', Offset(x + 14, 334), 10, ink.withValues(alpha: .6),
          false);
      CanvasUiKit.divider(canvas, Offset(x + 14, 354), Offset(x + 118, 354));
      _text(canvas, state == CanvasUiState.danger ? 'needs care' : 'stable route',
          Offset(x + 14, 366), 9, ink.withValues(alpha: .7), false);
    }
    _text(canvas, 'Canvas state coverage is a render precondition, not a runtime guess.',
        const Offset(24, 452), 13, twilight, true);
    CanvasUiKit.statePanel(canvas, const Rect.fromLTWH(24, 494, 712, 96),
        state: CanvasUiState.success, shadow: true);
    _text(canvas, 'Golden evidence', const Offset(46, 514), 14, teal, true);
    _text(canvas, 'Every state owns fill, stroke, text, control and progress semantics.',
        const Offset(46, 543), 13, ink, false);
    _text(canvas, 'reusable · deterministic · bounded', const Offset(46, 568), 11,
        ink.withValues(alpha: .65), false);
  }

  void _text(Canvas canvas, String value, Offset offset, double size, Color color,
      bool bold) {
    final painter = TextPainter(
        text: TextSpan(
            text: value,
            style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: size,
                color: color,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: 700);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
