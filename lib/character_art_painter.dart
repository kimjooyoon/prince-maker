import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'canvas_ui_kit.dart';
import 'character_art.dart';
import 'character_roster.dart';
import 'design_tokens.dart';

/// Reusable Canvas surface for the authored character-art direction page.
class CharacterArtPainter {
  const CharacterArtPainter({
    required this.story,
    required this.sheet,
    required this.characterIndex,
    required this.emotionIndex,
    required this.locale,
  });

  final Map<String, dynamic> story;
  final ui.Image? sheet;
  final int characterIndex, emotionIndex;
  final String locale;

  void text(Canvas c, String value, Offset at, double size, Color color,
      {bool bold = false, double width = 330}) {
    final painter = TextPainter(
        text: TextSpan(
            text: value,
            style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: size,
                color: color,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: width);
    painter.paint(c, at);
  }

  void panel(Canvas c, Rect rect, Color fill, Color accent) =>
      CanvasUiKit.panel(c, rect,
          fill: fill,
          stroke: accent.withValues(alpha: .55),
          radius: 20,
          shadow: true);

  void face(Canvas c, Rect rect, int emotion, Color accent) {
    final center = Offset(rect.center.dx, rect.top + rect.height * .42),
        radius = rect.width * .34,
        feature = Paint()
          ..color = ink
          ..strokeWidth = rect.width * .045
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    c.drawCircle(center, radius, Paint()..color = const Color(0xffffd9c0));
    c.drawArc(
        Rect.fromCircle(
            center: Offset(center.dx, center.dy - radius * .42),
            radius: radius * 1.02),
        pi,
        pi,
        true,
        Paint()..color = ink);
    for (final x in [-.35, .35]) {
      c.drawCircle(Offset(center.dx + radius * x, center.dy - radius * .02),
          radius * .08, Paint()..color = accent);
    }
    final left = Offset(center.dx - radius * .32, center.dy - radius * .08),
        right = Offset(center.dx + radius * .32, center.dy - radius * .08);
    if (emotion == 0) {
      c.drawLine(left + Offset(-radius * .12, 0),
          left + Offset(radius * .12, 0), feature);
      c.drawLine(right + Offset(-radius * .12, 0),
          right + Offset(radius * .12, 0), feature);
    } else if (emotion == 1) {
      for (final eye in [left, right]) {
        c.drawArc(
            Rect.fromCenter(
                center: eye, width: radius * .32, height: radius * .22),
            0,
            pi,
            false,
            feature);
      }
    } else if (emotion == 2) {
      c.drawLine(left + Offset(-radius * .12, -radius * .08),
          left + Offset(radius * .12, radius * .03), feature);
      c.drawLine(right + Offset(-radius * .12, radius * .03),
          right + Offset(radius * .12, -radius * .08), feature);
    } else if (emotion == 3) {
      for (final eye in [left, right]) {
        c.drawLine(eye + Offset(-radius * .13, -radius * .04),
            eye + Offset(radius * .13, -radius * .04), feature);
      }
    } else {
      for (final eye in [left, right]) c.drawCircle(eye, radius * .13, feature);
    }
    final mouth = Path()
      ..moveTo(center.dx - radius * .26, center.dy + radius * .35);
    mouth.quadraticBezierTo(
        center.dx,
        center.dy + radius * (emotion == 1 || emotion == 4 ? .58 : .25),
        center.dx + radius * .26,
        center.dy + radius * .35);
    c.drawPath(mouth, feature);
  }

  void drawSheet(Canvas c, LumenCharacter character, Rect destination) {
    if (sheet == null) return;
    final width = sheet!.width / 5.0, height = sheet!.height / 4.0;
    c.drawImageRect(
        sheet!,
        Rect.fromLTWH((character.sheetIndex % 5) * width,
            (character.sheetIndex ~/ 5) * height, width, height),
        destination,
        Paint());
  }

  void paint(Canvas c) {
    final characters = archiveCharacters(story);
    if (characters.isEmpty) return;
    final character =
            characters[characterIndex.clamp(0, characters.length - 1)],
        art = characterArtFor(story, character.id),
        emotion = emotionIndex.clamp(0, lumenEmotionStates.length - 1),
        accent = Color(character.accent),
        ko = locale == 'ko';
    text(c, ko ? '캐릭터 일러스트 설계' : 'Character art direction',
        const Offset(24, 22), 28, ink,
        bold: true, width: 520);
    text(
        c,
        ko
            ? '도감 카드에서 재사용 가능한 포즈와 감정 키를 확인하세요.'
            : 'Inspect reusable pose and emotion keys from the archive card.',
        const Offset(25, 60),
        12,
        teal,
        width: 650);
    text(
        c,
        '${characterIndex + 1} / ${characters.length} · ${character.title(locale)} · ${character.subtitle(locale)}',
        const Offset(25, 84),
        10,
        ink.withValues(alpha: .55),
        bold: true,
        width: 650);
    panel(c, const Rect.fromLTWH(24, 108, 270, 410), twilight, accent);
    c.drawRect(const Rect.fromLTWH(44, 126, 230, 4), Paint()..color = accent);
    drawSheet(c, character, const Rect.fromLTWH(44, 140, 230, 184));
    if (sheet == null)
      face(c, const Rect.fromLTWH(88, 148, 122, 122), emotion, accent);
    text(c, character.title(locale), const Offset(46, 342), 22, Colors.white,
        bold: true, width: 220);
    text(c, character.subtitle(locale), const Offset(46, 374), 11, accent,
        bold: true, width: 220);
    text(c, ko ? '대표 모티프' : 'Signature motif', const Offset(46, 405), 9,
        Colors.white70,
        bold: true);
    text(c, character.motif, const Offset(46, 424), 14, Colors.white,
        bold: true, width: 220);
    CanvasUiKit.badge(
        c, const Rect.fromLTWH(46, 466, 108, 28), ko ? '5종 표정' : '5 emotions',
        accent: accent, state: CanvasUiState.selected, fontSize: 9);

    panel(c, const Rect.fromLTWH(316, 108, 420, 198), Colors.white, accent);
    text(c, ko ? '일러스트 방향' : 'Illustration brief', const Offset(338, 130), 13,
        accent,
        bold: true);
    text(c, art.illustrationFor(locale), const Offset(338, 158), 12, ink,
        bold: true, width: 370);
    text(c, ko ? '실루엣' : 'Silhouette', const Offset(338, 208), 9, teal,
        bold: true);
    text(c, art.silhouetteFor(locale), const Offset(338, 226), 10, ink,
        width: 370);
    text(c, ko ? '시그니처 동작' : 'Signature gesture', const Offset(338, 257), 9,
        teal,
        bold: true);
    text(c, art.gestureFor(locale), const Offset(338, 275), 10, ink,
        width: 370);

    panel(c, const Rect.fromLTWH(316, 320, 420, 190), Colors.white, accent);
    text(c, ko ? '현재 표정 키' : 'Active expression key', const Offset(338, 340),
        12, accent,
        bold: true);
    CanvasUiKit.statePanel(c, const Rect.fromLTWH(338, 366, 88, 104),
        state: CanvasUiState.selected, accent: accent, radius: 16);
    face(c, const Rect.fromLTWH(354, 378, 56, 72), emotion, accent);
    text(c, lumenEmotionStates[emotion].title(locale), const Offset(450, 368),
        19, ink,
        bold: true, width: 230);
    text(c, art.emotionNote(emotion, locale), const Offset(450, 405), 11,
        ink.withValues(alpha: .7),
        width: 250);
    for (var i = 0; i < lumenEmotionStates.length; i++) {
      final chip = Rect.fromLTWH(316 + i * 80.0, 528, 74, 66),
          selected = i == emotion;
      CanvasUiKit.statePanel(c, chip,
          state: selected ? CanvasUiState.selected : CanvasUiState.idle,
          accent: accent,
          radius: 14,
          shadow: selected);
      face(c, Rect.fromLTWH(chip.left + 24, chip.top + 5, 26, 29), i,
          selected ? Colors.white : accent);
      text(
          c,
          lumenEmotionStates[i].title(locale),
          Offset(chip.left + 7, chip.top + 43),
          8.5,
          selected ? Colors.white : ink,
          bold: true,
          width: 60);
    }
    text(c, ko ? '← 도감으로 돌아가기' : '← Back to archive', const Offset(24, 665), 13,
        teal,
        bold: true);
    text(
        c,
        ko
            ? '표정 키는 대화·기억 장면에서 재사용됩니다.'
            : 'Emotion keys are reused by dialogue and memory scenes.',
        const Offset(316, 665),
        9,
        ink.withValues(alpha: .55),
        bold: true,
        width: 420);
  }
}
