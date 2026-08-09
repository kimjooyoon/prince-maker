import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'canvas_ui_kit.dart';
import 'design_tokens.dart';
import 'game_core.dart';
import 'i18n.dart';

/// Reusable Canvas projection for the deterministic companion relationship ledger.
class RelationshipArchivePainter {
  const RelationshipArchivePainter(
      {required this.story,
      required this.bonds,
      required this.flags,
      required this.portraitSheet,
      required this.persona,
      required this.locale});
  final Map<String, dynamic> story;
  final Map<String, int> bonds;
  final Map<String, bool> flags;
  final ui.Image? portraitSheet;
  final int persona;
  final String locale;
  String tr(String key, String fallback) => localized(key, fallback);
  void t(Canvas c, String v, Offset p, double size, Color color,
          {bool bold = false, double width = 310}) =>
      TextPainter(
          text: TextSpan(
              text: v,
              style: TextStyle(
                  fontFamily: 'NotoSansKR',
                  fontSize: size,
                  color: color,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: width)
        ..paint(c, p);
  void portrait(Canvas c, Map<String, dynamic> person, Rect dst) {
    if (portraitSheet == null) return;
    final w = portraitSheet!.width / 3, h = portraitSheet!.height.toDouble();
    c.drawImageRect(
        portraitSheet!,
        Rect.fromLTWH(
            (person['portraitFrame'] as int? ?? 0).toDouble() * w, 0, w, h),
        dst,
        Paint());
  }

  void card(Canvas c, StoryPort model, Map<String, dynamic> person,
      Map<String, dynamic> quest, double x, Color accent) {
    final id = '${person['id']}',
        bond = bonds[id] ?? 0,
        threshold = person['bondThreshold'] as int? ?? 8;
    CanvasUiKit.statePanel(c, Rect.fromLTWH(x, 260, 224, 270),
        state: bond >= threshold ? CanvasUiState.success : CanvasUiState.idle,
        accent: accent,
        shadow: true);
    portrait(c, person, Rect.fromLTWH(x + 16, 278, 82, 82));
    t(c, tr('${person['nameKey']}', '${person['name']}'), Offset(x + 112, 282),
        17, ink,
        bold: true, width: 100);
    t(c, '${person['role']}', Offset(x + 112, 310), 9, teal, width: 100);
    t(c, '${tr('ui.relationship.bond', '유대')} $bond/$threshold',
        Offset(x + 16, 380), 12, ink,
        bold: true);
    CanvasUiKit.progress(
        c, Rect.fromLTWH(x + 16, 406, 190, 7), bond / threshold,
        accent: accent);
    t(
        c,
        '${tr('ui.relationship.quest', '퀘스트')} ${(quest['completedStages'] as int? ?? 0)}/${quest['totalStages'] as int? ?? 0}',
        Offset(x + 16, 432),
        11,
        teal,
        bold: true);
    t(c, '${person['routeTitle']}', Offset(x + 16, 462), 11, ink, width: 190);
    final resonance =
        resolvePersonalityCompanionRoute(model, persona, '${person['id']}');
    t(
        c,
        tr(
            resonance['matched'] == true
                ? 'ui.relationshipArchive.resonance.matched'
                : 'ui.relationshipArchive.resonance.neutral',
            resonance['matched'] == true
                ? 'Personality resonance · Bond +1'
                : 'Different grain · Base bond'),
        Offset(x + 16, 490),
        9,
        resonance['matched'] == true ? accent : ink.withValues(alpha: .52),
        bold: true,
        width: 190);
    t(c, tr('ui.relationshipArchive.scenes', '독립 장면 보기 →'), Offset(x + 16, 512),
        9, teal,
        bold: true, width: 190);
  }

  void paint(Canvas c) {
    final model = JsonStoryAdapter(story),
        state = resolveRelationshipDynamics(model, bonds, flags),
        follow = resolveRelationshipFollowup(model, state),
        quests = resolveCompanionQuests(model, bonds, flags),
        people = model.companions;
    t(c, tr('ui.relationshipArchive.title', '동행 관계 기록'), const Offset(24, 22),
        28, ink,
        bold: true, width: 500);
    t(c, tr('ui.relationshipArchive.subtitle', '유대의 간격과 다음 대화를 같은 규칙에서 읽습니다.'),
        const Offset(25, 60), 12, teal,
        width: 690);
    CanvasUiKit.statePanel(c, const Rect.fromLTWH(24, 100, 712, 128),
        state: state['id'] == 'tension'
            ? CanvasUiState.danger
            : CanvasUiState.selected,
        accent: twilight,
        shadow: true);
    t(c, tr('${state['key']}', '${state['fallback']}'), const Offset(48, 123),
        21, Colors.white,
        bold: true, width: 260);
    t(
        c,
        '${tr('ui.relationshipArchive.gap', 'bond gap')} ${state['gap']} · ${tr('ui.relationshipArchive.lead', '앞선 동행')}: ${state['leadId'] ?? '-'}',
        const Offset(48, 160),
        11,
        sun,
        bold: true,
        width: 300);
    t(
        c,
        '${tr('ui.relationshipArchive.followup', '후속 기록')} · ${tr('${follow['titleKey']}', '${follow['title']}')}',
        const Offset(390, 126),
        13,
        Colors.white,
        bold: true,
        width: 300);
    t(c, tr('${follow['lineKey']}', '${follow['line']}'),
        const Offset(390, 157), 10, Colors.white70,
        width: 305);
    for (var i = 0; i < people.length && i < 3; i++)
      card(
          c,
          model,
          people[i],
          quests[i],
          24 + i * 238.0,
          [
            const Color(0xff8777b5),
            const Color(0xff6b9f76),
            const Color(0xffd18b5d)
          ][i]);
    t(c, tr('ui.relationshipArchive.back', '← 홈으로'), const Offset(24, 665), 13,
        teal,
        bold: true);
  }
}
