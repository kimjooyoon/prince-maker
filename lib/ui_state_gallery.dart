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
    CanvasUiKit.panel(canvas, const Rect.fromLTWH(24, 64, 380, 8),
        fill: teal, radius: 4);
    for (var i = 0; i < CanvasUiState.values.length; i++) {
      final state = CanvasUiState.values[i], x = 16 + i * 122.0;
      final card = Rect.fromLTWH(x, 112, 112, 286);
      CanvasUiKit.statePanel(canvas, card,
          state: state, shadow: state != CanvasUiState.disabled);
      CanvasUiKit.statePanel(canvas, Rect.fromLTWH(x + 10, 168, 92, 26),
          state: state, radius: DesignTokens.radiusBadge);
      CanvasUiKit.statePanel(canvas, Rect.fromLTWH(x + 10, 218, 92, 44),
          state: state,
          radius: DesignTokens.radiusControl,
          shadow: state != CanvasUiState.disabled);
      CanvasUiKit.progress(canvas, Rect.fromLTWH(x + 10, 294, 92, 7),
          (i + 1) / CanvasUiState.values.length,
          accent: CanvasUiKit.stateStroke(state, teal));
      CanvasUiKit.panel(canvas, Rect.fromLTWH(x + 10, 334, 72, 8),
          fill: CanvasUiKit.stateText(state, teal), radius: 4);
      CanvasUiKit.divider(canvas, Offset(x + 10, 354), Offset(x + 102, 354));
      CanvasUiKit.panel(canvas, Rect.fromLTWH(x + 10, 366, 42 + i * 6, 7),
          fill: ink.withValues(alpha: .65), radius: 3);
    }
    CanvasUiKit.statePanel(canvas, const Rect.fromLTWH(24, 452, 712, 138),
        state: CanvasUiState.success, shadow: true);
    CanvasUiKit.panel(canvas, const Rect.fromLTWH(46, 474, 180, 10),
        fill: teal, radius: 5);
    CanvasUiKit.panel(canvas, const Rect.fromLTWH(46, 506, 560, 9),
        fill: ink, radius: 4);
    CanvasUiKit.panel(canvas, const Rect.fromLTWH(46, 534, 330, 8),
        fill: ink.withValues(alpha: .65), radius: 4);
    CanvasUiKit.divider(canvas, const Offset(46, 566), const Offset(714, 566));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Geometry-first Golden reference for the named component variants used by the
/// five target screens. Copy and typography are covered by the locale and
/// semantic contracts; keeping this evidence geometric makes it stable across
/// macOS/Linux text rasterizers.
class CanvasDesignSystemGalleryPainter extends CustomPainter {
  const CanvasDesignSystemGalleryPainter(this.localized);
  final String Function(String key, String fallback) localized;

  void _bar(Canvas c, Rect rect, Color color, {double radius = 4}) {
    CanvasUiKit.panel(c, rect, fill: color, radius: radius);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);
    final localeAccent =
        localized('ui.design.title', '').contains('Lumen') ? sun : teal;
    _bar(canvas, const Rect.fromLTWH(24, 22, 320, 18), ink, radius: 6);
    _bar(canvas, const Rect.fromLTWH(25, 62, 620, 6), localeAccent, radius: 3);
    CanvasUiKit.hud(canvas, const Rect.fromLTWH(24, 96, 712, 74), accent: sun);
    _bar(canvas, const Rect.fromLTWH(46, 115, 280, 12), Colors.white,
        radius: 5);
    _bar(canvas, const Rect.fromLTWH(46, 143, 510, 6), Colors.white70,
        radius: 3);

    CanvasUiKit.variantPanel(canvas, const Rect.fromLTWH(24, 192, 224, 170),
        variant: CanvasComponentVariant.card, shadow: true);
    _bar(canvas, const Rect.fromLTWH(44, 214, 74, 8), teal, radius: 4);
    _bar(canvas, const Rect.fromLTWH(44, 242, 170, 12), ink, radius: 5);
    _bar(canvas, const Rect.fromLTWH(44, 263, 150, 8),
        ink.withValues(alpha: .65),
        radius: 4);
    CanvasUiKit.variantPanel(canvas, const Rect.fromLTWH(44, 312, 116, 26),
        variant: CanvasComponentVariant.status,
        accent: teal,
        radius: DesignTokens.radiusBadge);
    _bar(canvas, const Rect.fromLTWH(56, 321, 70, 7), teal, radius: 3);

    CanvasUiKit.dialogue(canvas, const Rect.fromLTWH(268, 192, 468, 170),
        accent: teal, shadow: true);
    _bar(canvas, const Rect.fromLTWH(292, 214, 124, 8), teal, radius: 4);
    _bar(canvas, const Rect.fromLTWH(292, 244, 350, 12), ink, radius: 5);
    _bar(canvas, const Rect.fromLTWH(292, 265, 270, 8),
        ink.withValues(alpha: .65),
        radius: 4);
    CanvasUiKit.variantPanel(canvas, const Rect.fromLTWH(292, 306, 154, 34),
        variant: CanvasComponentVariant.button,
        state: CanvasUiState.selected,
        accent: teal);
    CanvasUiKit.variantPanel(canvas, const Rect.fromLTWH(462, 306, 154, 34),
        variant: CanvasComponentVariant.locked,
        state: CanvasUiState.disabled,
        accent: teal);

    CanvasUiKit.variantPanel(canvas, const Rect.fromLTWH(24, 390, 712, 84),
        variant: CanvasComponentVariant.status,
        state: CanvasUiState.warning,
        accent: warning);
    _bar(canvas, const Rect.fromLTWH(46, 414, 420, 10), warning, radius: 5);
    _bar(canvas, const Rect.fromLTWH(46, 442, 560, 6),
        ink.withValues(alpha: .68),
        radius: 3);
    _bar(canvas, const Rect.fromLTWH(24, 510, 116, 8), teal, radius: 4);
    for (var i = 0; i < 3; i++) {
      final x = 24 + i * 238.0;
      CanvasUiKit.variantPanel(canvas, Rect.fromLTWH(x, 540, 220, 34),
          variant: CanvasComponentVariant.status,
          accent: i == 1 ? sun : teal,
          radius: DesignTokens.radiusBadge);
      _bar(canvas, Rect.fromLTWH(x + 12, 553, 150 - i * 20, 7),
          i == 1 ? sun : teal,
          radius: 3);
    }
    _bar(canvas, const Rect.fromLTWH(24, 612, 510, 6),
        ink.withValues(alpha: .62),
        radius: 3);
  }

  @override
  bool shouldRepaint(covariant CanvasDesignSystemGalleryPainter oldDelegate) =>
      false;
}
