import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'canvas_ui_kit.dart';
import 'companion_scene_layout.dart';
import 'design_tokens.dart';
import 'game_core.dart';
import 'i18n.dart';

/// Canvas projection for the authored companion-scene record loop.
class CompanionSceneArchivePainter {
  CompanionSceneArchivePainter(
      {required this.story,
      required this.bonds,
      required this.flags,
      required this.portraitSheet,
      required this.persona,
      required this.companionIndex,
      required this.currentChapter,
      required this.pendingSceneId,
      required this.lastResult,
      this.lastLine = ''});
  final Map<String, dynamic> story;
  final Map<String, int> bonds;
  final Map<String, bool> flags;
  final ui.Image? portraitSheet;
  final int persona, companionIndex, currentChapter;
  final String? pendingSceneId;
  final String lastResult, lastLine;
  // A painter is reused for every frame while the archive state is stable.
  // Keep the immutable SSOT projection outside paint() so frame cost measures
  // Canvas work rather than rebuilding the story adapter and route state.
  late final JsonStoryAdapter _model = JsonStoryAdapter(story);
  late final List<Map<String, dynamic>> _resolvedScenes =
      resolveCompanionScenes(_model, bonds, flags,
          currentChapter: currentChapter);
  String tr(String key, String fallback) => localized(key, fallback);
  String format(String key, String fallback, Map<String, Object?> values) {
    var value = tr(key, fallback);
    for (final entry in values.entries) {
      value = value.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return value;
  }

  void t(Canvas c, String v, Offset p, double size, Color color,
          {bool bold = false, double width = 330, int? lines}) =>
      TextPainter(
          text: TextSpan(
              text: v,
              style: TextStyle(
                  fontFamily: 'NotoSansKR',
                  fontSize: size,
                  color: color,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
          textDirection: TextDirection.ltr,
          maxLines: lines,
          ellipsis: lines == null ? null : '…')
        ..layout(maxWidth: width)
        ..paint(c, p);
  void portrait(Canvas c, Map<String, dynamic> person, Rect dst) {
    final sheet = portraitSheet;
    if (sheet == null) return;
    final w = sheet.width / 3;
    c.drawImageRect(
        sheet,
        Rect.fromLTWH((person['portraitFrame'] as int? ?? 0) * w, 0, w,
            sheet.height.toDouble()),
        dst,
        Paint());
  }

  void paint(Canvas c) {
    final model = _model, people = model.companions;
    if (people.isEmpty) return;
    final index = companionIndex.clamp(0, people.length - 1),
        person = people[index],
        id = '${person['id']}';
    final scenes = _resolvedScenes
        .where((scene) => '${scene['companionId']}' == id)
        .toList();
    final completedCount =
            scenes.where((scene) => scene['completed'] == true).length,
        progress = scenes.isEmpty ? 0.0 : completedCount / scenes.length;
    final bond = bonds[id] ?? 0,
        threshold = person['bondThreshold'] as int? ?? 8;
    t(c, tr('ui.companionScenes.title', '동행 장면 기록'), const Offset(24, 22), 28,
        ink,
        bold: true, width: 540);
    t(c, tr('ui.companionScenes.subtitle', '유대와 막의 조건이 여는 독립 기록'),
        const Offset(25, 60), 12, teal,
        width: 650);
    CanvasUiKit.statePanel(c, const Rect.fromLTWH(24, 96, 712, 106),
        state: CanvasUiState.selected, accent: teal, shadow: true);
    portrait(c, person, const Rect.fromLTWH(42, 108, 74, 82));
    t(c, tr('${person['nameKey']}', '${person['name']}'),
        const Offset(135, 115), 20, Colors.white,
        bold: true, width: 220);
    t(
        c,
        '${person['routeTitle']} · ${tr('ui.companionScenes.bond', '유대')} $bond/$threshold',
        const Offset(135, 148),
        11,
        sun,
        bold: true,
        width: 310);
    final feedback = lastResult == 'companion-scene-rejected:bond'
        ? tr('ui.companionScenes.notice.bond', '유대가 더 필요합니다.')
        : lastResult == 'companion-scene-rejected:chapter'
            ? tr('ui.companionScenes.notice.chapter', '아직 이 막에 도착하지 않았습니다.')
            : lastResult == 'companion-scene-rejected:duplicate'
                ? tr('ui.companionScenes.notice.duplicate', '이 장면은 이미 기록되었습니다.')
                : lastResult == 'companion-scene-rejected:invalid'
                    ? tr('ui.companionScenes.notice.invalid',
                        '시스템이 이 기록 입력을 거절했습니다.')
                    : lastResult.contains('동행 장면 기록')
                        ? tr('ui.companionScenes.notice.recorded',
                            '선택한 기록이 저장되었습니다.')
                        : '';
    final priorChoice = scenes
        .map((scene) => scene['choiceEcho'])
        .whereType<Map>()
        .map((choice) => choice.cast<String, dynamic>())
        .lastOrNull;
    if (feedback.isEmpty) {
      t(
          c,
          tr('ui.companionScenes.chooseHint',
              '두 선택 모두 다음 장면과 엔딩 기록에 흔적을 남깁니다.'),
          const Offset(410, 126),
          10,
          Colors.white70,
          width: 280,
          lines: 2);
    } else {
      CanvasUiKit.statePanel(c, const Rect.fromLTWH(398, 112, 310, 48),
          state: CanvasUiState.danger, accent: sun, shadow: true);
      t(c, feedback, const Offset(412, 126), 10, const Color(0xffa84f3c),
          bold: true, width: 282, lines: 2);
    }
    if (feedback.isNotEmpty && lastLine.isNotEmpty) {
      t(c, lastLine, const Offset(410, 151), 8, Colors.white70,
          width: 280, lines: 1);
    }
    t(
        c,
        format('ui.companionScenes.progress', '기록 {done}/{total}', {
          'done': completedCount,
          'total': scenes.length,
        }),
        const Offset(410, 166),
        10,
        sun,
        bold: true,
        width: 160);
    CanvasUiKit.progress(c, const Rect.fromLTWH(410, 185, 280, 7), progress,
        accent: sun);
    for (var i = 0;
        i < scenes.length && i < CompanionSceneLayout.maxVisibleCards;
        i++) {
      final scene = scenes[i],
          card = CompanionSceneLayout.cardRect(i),
          x = card.left,
          y = card.top,
          done = scene['completed'] == true,
          available = scene['available'] == true,
          unlocked = scene['unlocked'] == true,
          chapterReady = scene['chapterReady'] == true,
          pending = pendingSceneId == '${scene['id']}',
          state = pending
              ? CanvasUiState.selected
              : done
                  ? CanvasUiState.success
                  : available
                      ? CanvasUiState.idle
                      : CanvasUiState.disabled,
          status = done
              ? tr('ui.companionScenes.status.completed', '기록됨')
              : available
                  ? tr('ui.companionScenes.status.available', '기록하기')
                  : tr('ui.companionScenes.status.locked', '잠김');
      CanvasUiKit.statePanel(c, card,
          state: state,
          accent: pending ? sun : teal,
          shadow: available || done);
      t(
          c,
          '${scene['chapter']}${tr('ui.companionScenes.chapter', '막')} · $status',
          Offset(x + 18, y + 14),
          9,
          available ? teal : ink.withValues(alpha: .45),
          bold: true,
          width: 300);
      t(c, tr('${scene['titleKey']}', '${scene['title']}'),
          Offset(x + 18, y + 34), 14, ink,
          bold: true, width: 300, lines: 1);
      final choices =
          (scene['choices'] as List? ?? const []).cast<Map<String, dynamic>>();
      final selectedChoice = scene['selectedChoice'] is Map
              ? (scene['selectedChoice'] as Map).cast<String, dynamic>()
              : null,
          choiceEcho = scene['choiceEcho'] is Map
              ? (scene['choiceEcho'] as Map).cast<String, dynamic>()
              : null;
      final lockCopy = !unlocked
          ? tr('ui.companionScenes.notice.bond', 'A stronger bond is required.')
          : !chapterReady
              ? tr('ui.companionScenes.notice.chapter',
                  'This chapter has not arrived yet.')
              : tr('ui.companionScenes.notice.duplicate',
                  'This scene is already recorded.');
      if (done) {
        t(
            c,
            '${selectedChoice == null ? tr('${scene['lineKey']}', '${scene['line']}') : tr('${selectedChoice['responseKey']}', '${selectedChoice['response']}')} · ${format('ui.companionScenes.reward', '기록 보상 · 유대 +{bond}', {
                  'bond': (selectedChoice?['bondDelta'] as int?) ??
                      (scene['bondDelta'] as int?) ??
                      1
                })}',
            Offset(x + 18, y + 62),
            9,
            teal,
            width: 300,
            lines: 2);
      } else if (available && !pending && choiceEcho != null) {
        t(
            c,
            format('ui.companionScenes.choiceEcho', '앞선 선택 · {choice}', {
              'choice': tr('${choiceEcho['labelKey']}',
                  '${choiceEcho['label'] ?? choiceEcho['choiceId']}'),
            }),
            Offset(x + 18, y + 58),
            8,
            sun,
            bold: true,
            width: 300,
            lines: 1);
        t(c, tr('${scene['promptKey']}', '${scene['prompt']}'),
            Offset(x + 18, y + 72), 8, teal,
            width: 300, lines: 1);
      } else {
        t(
            c,
            available
                ? tr('ui.companionScenes.choose', '이 장면에서 어떤 기록을 남길까요?')
                : lockCopy,
            Offset(x + 18, y + 62),
            9,
            available ? teal : ink.withValues(alpha: .45),
            width: 300,
            lines: available ? 1 : 2);
      }
      if (available && choices.length >= 2) {
        CanvasUiKit.button(c, CompanionSceneLayout.choiceRect(i, 0),
            tr('${choices[0]['labelKey']}', '${choices[0]['label']}'),
            state: pending ? CanvasUiState.selected : CanvasUiState.idle,
            accent: teal,
            fontSize: 8,
            radius: 5);
        CanvasUiKit.button(c, CompanionSceneLayout.choiceRect(i, 1),
            tr('${choices[1]['labelKey']}', '${choices[1]['label']}'),
            accent: teal, fontSize: 8, radius: 5);
      }
    }
    CanvasUiKit.button(c, CompanionSceneLayout.previousRect,
        tr('ui.companionScenes.previous', '← 이전 동행'));
    t(c, '${index + 1}/${people.length}', const Offset(354, 616), 11, teal,
        bold: true, width: 60);
    CanvasUiKit.button(c, CompanionSceneLayout.nextRect,
        tr('ui.companionScenes.next', '다음 동행 →'));
    if (priorChoice != null) {
      t(
          c,
          format('ui.companionScenes.choiceEchoHint',
              '앞선 선택이 다음 장면에 남아 있습니다 · {choice} → {response}', {
            'choice': tr('${priorChoice['labelKey']}',
                '${priorChoice['label'] ?? priorChoice['choiceId']}'),
            'response': tr('${priorChoice['responseKey']}',
                '${priorChoice['response'] ?? ''}'),
          }),
          const Offset(216, 665),
          8,
          teal,
          bold: true,
          width: 490,
          lines: 2);
    }
    t(c, tr('ui.companionScenes.back', '← 관계 기록'), const Offset(24, 665), 13,
        teal,
        bold: true);
  }
}
