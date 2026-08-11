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

/// Golden reference for the named component variants used by the five target screens.
class CanvasDesignSystemGalleryPainter extends CustomPainter {
  const CanvasDesignSystemGalleryPainter(this.localized);
  final String Function(String key, String fallback) localized;

  void _text(Canvas c, String value, Offset point, double size, Color color,
      {bool bold = false, double width = 300}) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontFamily: 'NotoSansKR',
          fontSize: size,
          color: color,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);
    painter.paint(c, point);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);
    _text(canvas, localized('ui.design.title', 'Lumen Canvas language'),
        const Offset(24, 22), 28, ink,
        bold: true, width: 520);
    _text(
        canvas,
        localized('ui.design.subtitle',
            'One quiet grammar for home, portrait, companion, and Star Cellar.'),
        const Offset(25, 62),
        12,
        teal,
        width: 660);
    CanvasUiKit.hud(canvas, const Rect.fromLTWH(24, 96, 712, 74), accent: sun);
    _text(
        canvas,
        localized('ui.design.hud', 'HUD · chapter / week / stat rhythm'),
        const Offset(46, 115),
        16,
        Colors.white,
        bold: true,
        width: 360);
    _text(
        canvas,
        localized('ui.design.hudHint',
            'Ink carries orientation; sun marks the next meaningful action.'),
        const Offset(46, 143),
        10,
        Colors.white70,
        width: 620);

    CanvasUiKit.variantPanel(canvas, const Rect.fromLTWH(24, 192, 224, 170),
        variant: CanvasComponentVariant.card, shadow: true);
    _text(canvas, localized('ui.design.card', 'CARD'), const Offset(44, 214),
        11, teal,
        bold: true);
    _text(
        canvas,
        localized('ui.design.cardHint',
            'A choice stays readable before it becomes an action.'),
        const Offset(44, 242),
        14,
        ink,
        bold: true,
        width: 180);
    CanvasUiKit.status(canvas, const Rect.fromLTWH(44, 312, 116, 26),
        localized('ui.design.status', 'READY'));

    CanvasUiKit.dialogue(canvas, const Rect.fromLTWH(268, 192, 468, 170),
        accent: teal, shadow: true);
    _text(canvas, localized('ui.design.dialogue', 'DIALOGUE BOX'),
        const Offset(292, 214), 11, teal,
        bold: true);
    _text(
        canvas,
        localized('ui.design.dialogueHint',
            'Speaker, line, and location share one reading order.'),
        const Offset(292, 244),
        15,
        ink,
        bold: true,
        width: 390);
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
    _text(
        canvas,
        localized('ui.design.warning', 'WARNING · fatigue needs a softer pace'),
        const Offset(46, 414),
        14,
        warning,
        bold: true,
        width: 620);
    _text(
        canvas,
        localized('ui.design.warningHint',
            'Warning is distinct from danger so guidance never looks like a system rejection.'),
        const Offset(46, 442),
        10,
        ink.withValues(alpha: .68),
        width: 650);

    _text(canvas, localized('ui.design.rules', 'REUSE RULES'),
        const Offset(24, 510), 11, teal,
        bold: true);
    final rules = [
      localized('ui.design.rule.touch', '44px minimum touch target'),
      localized('ui.design.rule.state',
          'idle · selected · locked · success · warning · danger'),
      localized('ui.design.rule.copy', 'ko/en copy lives in locale JSONL'),
    ];
    for (var i = 0; i < rules.length; i++) {
      CanvasUiKit.status(
          canvas, Rect.fromLTWH(24 + i * 238.0, 540, 220, 34), rules[i],
          accent: i == 1 ? sun : teal, fontSize: 9);
    }
    _text(
        canvas,
        localized('ui.design.footer',
            'Original mood: twilight ink, star-gold guidance, mint recovery, coral caution.'),
        const Offset(24, 612),
        10,
        ink.withValues(alpha: .62),
        width: 700);
  }

  @override
  bool shouldRepaint(covariant CanvasDesignSystemGalleryPainter oldDelegate) =>
      false;
}
