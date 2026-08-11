import 'package:flutter/material.dart';
import 'design_tokens.dart';

enum CanvasUiState { idle, selected, disabled, warning, success, danger }

/// Named Canvas surfaces keep page painters on the same layout language.
enum CanvasComponentVariant {
  panel,
  card,
  button,
  hud,
  dialogue,
  status,
  locked,
}

/// Shared state-aware Canvas primitives; story copy stays in SSOT catalogs.
abstract final class CanvasUiKit {
  static Color stateFill(CanvasUiState s, Color a) => switch (s) {
        CanvasUiState.selected => a,
        CanvasUiState.disabled => paper,
        CanvasUiState.warning => warning.withValues(alpha: .16),
        CanvasUiState.success => teal.withValues(alpha: .12),
        CanvasUiState.danger => danger.withValues(alpha: .10),
        CanvasUiState.idle => Colors.white,
      };
  static Color stateStroke(CanvasUiState s, Color a) => switch (s) {
        CanvasUiState.disabled => ink.withValues(alpha: .18),
        CanvasUiState.warning => warning,
        CanvasUiState.danger => danger,
        _ => a,
      };
  static Color stateText(CanvasUiState s, Color a) => switch (s) {
        CanvasUiState.selected => Colors.white,
        CanvasUiState.disabled => ink.withValues(alpha: .45),
        CanvasUiState.warning => warning,
        CanvasUiState.danger => danger,
        CanvasUiState.success => success,
        CanvasUiState.idle => a,
      };

  static double variantRadius(CanvasComponentVariant variant) =>
      switch (variant) {
        CanvasComponentVariant.panel => DesignTokens.radiusPanel,
        CanvasComponentVariant.card => DesignTokens.radiusCard,
        CanvasComponentVariant.button => DesignTokens.radiusControl,
        CanvasComponentVariant.hud => DesignTokens.hudRadius,
        CanvasComponentVariant.dialogue => DesignTokens.dialogueRadius,
        CanvasComponentVariant.status => DesignTokens.radiusControl,
        CanvasComponentVariant.locked => DesignTokens.radiusCard,
      };

  /// Paint a named surface while preserving the state contract used by older pages.
  static void variantPanel(Canvas c, Rect r,
      {CanvasComponentVariant variant = CanvasComponentVariant.panel,
      CanvasUiState state = CanvasUiState.idle,
      Color accent = teal,
      Color? fill,
      Color? stroke,
      double? radius,
      bool shadow = false}) {
    final baseFill = fill ??
        switch (variant) {
          CanvasComponentVariant.hud => twilight,
          CanvasComponentVariant.dialogue => paper,
          CanvasComponentVariant.locked => mist.withValues(alpha: .18),
          CanvasComponentVariant.status => surfaceTint,
          _ => Colors.white,
        };
    final resolvedFill =
        state == CanvasUiState.idle ? baseFill : stateFill(state, accent);
    final resolvedStroke =
        stroke ?? (variant == CanvasComponentVariant.hud ? mist : accent);
    panel(c, r,
        fill: resolvedFill,
        stroke: resolvedStroke,
        radius: radius ?? variantRadius(variant),
        shadow: shadow && state != CanvasUiState.disabled);
  }

  static void panel(Canvas c, Rect r,
      {Color fill = Colors.white,
      Color? stroke,
      double radius = DesignTokens.radiusCard,
      bool shadow = false}) {
    final shape = RRect.fromRectAndRadius(r, Radius.circular(radius));
    if (shadow)
      c.drawRRect(shape.shift(const Offset(0, DesignTokens.shadowOffsetY)),
          Paint()..color = ink.withValues(alpha: .08));
    c.drawRRect(shape, Paint()..color = fill);
    if (stroke != null)
      c.drawRRect(
          shape,
          Paint()
            ..color = stroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
  }

  static void statePanel(Canvas c, Rect r,
          {CanvasUiState state = CanvasUiState.idle,
          Color accent = teal,
          double radius = DesignTokens.radiusCard,
          bool shadow = false}) =>
      panel(c, r,
          fill: stateFill(state, accent),
          stroke: stateStroke(state, accent),
          radius: radius,
          shadow: shadow && state != CanvasUiState.disabled);

  static void hud(Canvas c, Rect r,
          {CanvasUiState state = CanvasUiState.idle,
          Color accent = teal,
          bool shadow = true}) =>
      variantPanel(c, r,
          variant: CanvasComponentVariant.hud,
          state: state,
          accent: accent,
          shadow: shadow);

  static void dialogue(Canvas c, Rect r,
          {CanvasUiState state = CanvasUiState.idle,
          Color accent = teal,
          bool shadow = true}) =>
      variantPanel(c, r,
          variant: CanvasComponentVariant.dialogue,
          state: state,
          accent: accent,
          shadow: shadow);

  static void status(Canvas c, Rect r, String label,
      {CanvasUiState state = CanvasUiState.idle,
      Color accent = teal,
      double fontSize = 10}) {
    variantPanel(c, r,
        variant: CanvasComponentVariant.status,
        state: state,
        accent: accent,
        radius: DesignTokens.radiusBadge);
    _text(c, r, label, stateText(state, accent), fontSize);
  }

  static void badge(Canvas c, Rect r, String label,
      {CanvasUiState state = CanvasUiState.idle,
      Color accent = teal,
      double fontSize = 10}) {
    statePanel(c, r,
        state: state, accent: accent, radius: DesignTokens.radiusBadge);
    _text(c, r, label, stateText(state, accent), fontSize);
  }

  static void button(Canvas c, Rect r, String label,
      {CanvasUiState state = CanvasUiState.idle,
      Color accent = teal,
      double fontSize = 14,
      double radius = DesignTokens.radiusControl}) {
    statePanel(c, r,
        state: state,
        accent: accent,
        radius: radius,
        shadow: state != CanvasUiState.disabled);
    _text(c, r, label, stateText(state, accent), fontSize);
  }

  static void _text(Canvas c, Rect r, String value, Color color, double size) {
    final p = TextPainter(
        text: TextSpan(
            text: value,
            style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: size,
                color: color,
                fontWeight: FontWeight.w800)),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…')
      ..layout(maxWidth: r.width - 12);
    p.paint(
        c,
        Offset(r.left + (r.width - p.width) / 2,
            r.top + (r.height - p.height) / 2));
  }

  static void progress(Canvas c, Rect r, double value, {Color accent = teal}) {
    final v = value.clamp(0.0, 1.0);
    panel(c, r, fill: ink.withValues(alpha: .12), radius: r.height / 2);
    if (v > 0)
      panel(c, Rect.fromLTWH(r.left, r.top, r.width * v, r.height),
          fill: accent, radius: r.height / 2);
  }

  static void divider(Canvas c, Offset a, Offset b,
          {Color color = mist, double width = 1}) =>
      c.drawLine(
          a,
          b,
          Paint()
            ..color = color.withValues(alpha: .35)
            ..strokeWidth = width);
}
