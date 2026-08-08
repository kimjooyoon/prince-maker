import 'package:flutter/material.dart';

typedef JournalText = String Function(String key, String fallback);
List<Map<String, dynamic>> activityJournalEntries(
        List<Map<String, dynamic>> scenes, List<String> history) =>
    scenes
        .map((scene) => {
              ...scene,
              'open': history.contains('activity-scene:${scene['id']}'),
            })
        .toList();
class ActivityJournalPainter {
  ActivityJournalPainter(this.scenes, this.history, this.text);
  final List<Map<String, dynamic>> scenes;
  final List<String> history;
  final JournalText text;
  static const ink = Color(0xff17324d), teal = Color(0xff4eaaa4);
  static const paper = Color(0xfff7f2e9);
  void paint(Canvas c) {
    final entries = activityJournalEntries(scenes, history),
        found = entries.where((scene) => scene['open'] == true).length;
    _t(c, text('ui.journal.title', '활동 회고 일지'), const Offset(24, 24), 30, ink,
        bold: true, maxWidth: 550);
    _t(c, text('ui.journal.subtitle', '오늘의 선택은 사라지지 않고 다음 시선이 됩니다.'),
        const Offset(25, 65), 13, teal,
        maxWidth: 680);
    _t(
        c,
        text('ui.journal.count', '발견 {found}/{total}')
            .replaceAll('{found}', '$found')
            .replaceAll('{total}', '${scenes.length}'),
        const Offset(25, 91),
        10,
        ink.withValues(alpha: .55));
    for (var i = 0; i < scenes.length; i++) {
      final scene = entries[i], open = scene['open'] == true;
      final x = 24 + (i % 2) * 360.0, y = 116 + (i ~/ 2) * 108.0;
      _card(c, Rect.fromLTWH(x, y, 344, 94), open);
      _t(
          c,
          open
              ? text('${scene['titleKey']}', '${scene['title']}')
              : text('ui.journal.hiddenTitle', 'Unwritten page'),
          Offset(x + 16, y + 12),
          12,
          open ? ink : ink.withValues(alpha: .42),
          bold: true,
          maxWidth: 310);
      _t(
          c,
          open
              ? text('${scene['momentKey']}', '${scene['moment']}')
              : text('ui.journal.hidden', 'Keep walking to reveal this page.'),
          Offset(x + 16, y + 37),
          9,
          open ? ink.withValues(alpha: .68) : ink.withValues(alpha: .42),
          maxWidth: 310);
      _t(
          c,
          open
              ? text('${scene['lineKey']}', '${scene['line']}')
              : text('ui.journal.lock', 'A future day will leave a line here.'),
          Offset(x + 16, y + 62),
          9,
          open ? teal : ink.withValues(alpha: .35),
          maxWidth: 310,
          maxLines: 1);
    }
    _t(c, text('ui.journal.back', '← 홈으로'), const Offset(24, 665), 14, teal,
        bold: true);
  }

  void _card(Canvas c, Rect r, bool open) {
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(18)),
        Paint()..color = open ? Colors.white : paper);
    c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(18)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = open ? teal : ink.withValues(alpha: .14));
  }

  void _t(Canvas c, String value, Offset p, double size, Color color,
      {bool bold = false, double maxWidth = 330, int? maxLines}) {
    final painter = TextPainter(
        text: TextSpan(
            text: value,
            style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: size,
                color: color,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
        ellipsis: '…')
      ..layout(maxWidth: maxWidth);
    painter.paint(c, p);
  }
}
