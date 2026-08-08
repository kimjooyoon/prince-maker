import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'canvas_ui_kit.dart';

void drawFeedbackBanner(Canvas c, String result, String line,
    {String emptyLabel = '일정을 고르고 하루를 보냅니다.'}) {
  final active = result.isNotEmpty;
  final rect = const Rect.fromLTWH(24, 452, 712, 48);
  CanvasUiKit.statePanel(c, rect,
      state: active ? CanvasUiState.success : CanvasUiState.idle,
      accent: active ? teal : ink.withValues(alpha: .12),
      radius: DesignTokens.radiusControl,
      shadow: true);
  final title = TextPainter(
      text: TextSpan(
          text: active ? result : emptyLabel,
          style: TextStyle(
              fontFamily: 'NotoSansKR',
              fontSize: 12,
              color: active ? teal : ink.withValues(alpha: .55),
              fontWeight: active ? FontWeight.w800 : FontWeight.w400)),
      maxLines: 1,
      ellipsis: '…',
      textDirection: TextDirection.ltr)
    ..layout(maxWidth: 680);
  title.paint(c, const Offset(40, 463));
  if (line.isNotEmpty) {
    final quote = TextPainter(
        text: TextSpan(
            text: '“$line”',
            style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 10,
                color: ink.withValues(alpha: .65))),
        maxLines: 1,
        ellipsis: '…',
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: 680);
    quote.paint(c, const Offset(40, 482));
  }
}
