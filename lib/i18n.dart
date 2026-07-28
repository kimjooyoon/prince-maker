import 'package:flutter/material.dart';
import 'design_tokens.dart';

class LocaleCatalog {
  const LocaleCatalog(this.bundles);
  final Map<String, Map<String, String>> bundles;
  String text(String locale, String key, {String fallback = ''}) =>
      bundles[locale]?[key] ?? bundles['ko']?[key] ?? fallback;
}

String activeLocale = 'ko';
LocaleCatalog activeCatalog = const LocaleCatalog({});
Map<String, bool> activeFlags = const {};
void setActiveLocale(String locale, LocaleCatalog catalog) {
  activeLocale = locale;
  activeCatalog = catalog;
}

void setActiveFlags(Map<String, bool> flags) => activeFlags = flags;

String localized(String key, String fallback) =>
    activeCatalog.text(activeLocale, key, fallback: fallback);

void _text(Canvas c, String value, Offset offset, double size, Color color,
    {bool bold = false, double width = 680}) {
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
  painter.paint(c, offset);
}

void drawLocalizedIllustration(
    Canvas c, Map<String, dynamic> story, int persona) {
  if (activeLocale == 'ko') return;
  final p = story['personalities'][persona] as Map;
  c.drawRect(const Rect.fromLTWH(370, 105, 370, 335), Paint()..color = paper);
  final id = p['id'] as String? ?? 'quiet';
  _text(c, localized('personality.$id.name', p['name'] as String),
      const Offset(390, 125), 24, ink,
      bold: true);
  _text(c, localized('personality.$id.voice', p['voice'] as String),
      const Offset(390, 165), 14, teal);
  _text(c, 'Talent · ${p['focusStat']} +${p['focusBonus']}',
      const Offset(390, 195), 13, teal);
  c.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(390, 220, 330, 150), const Radius.circular(20)),
      Paint()..color = Colors.white);
  _text(c, '“${localized(p['lineKey'] as String? ?? '', p['line'] as String)}”',
      const Offset(415, 250), 20, ink,
      bold: true, width: 290);
  _text(c, '${story['hero']} · weekly record', const Offset(390, 400), 14,
      ink.withValues(alpha: .55));
}

void drawLocalizedEvent(Canvas c, Map<String, dynamic> story, int eventIndex,
    Map<String, int> stats, Map<String, int> bonds,
    [Map<String, bool>? flags]) {
  if (activeLocale == 'ko') return;
  final memoryFlags = flags ?? activeFlags;
  final event = story['events'][eventIndex] as Map;
  c.drawRect(const Rect.fromLTWH(0, 0, 590, 100), Paint()..color = paper);
  final locations = (story['locations'] as List? ?? const []).cast<Map>(),
      location = locations.firstWhere((l) => l['id'] == event['locationId'],
          orElse: () => {'name': event['locationId'] ?? ''});
  _text(
      c,
      '${event['week']} · ${localized('${location['nameKey']}', '${location['name']}')}',
      const Offset(25, 28),
      12,
      teal,
      bold: true);
  _text(
      c,
      '${event['titleKey'] == null ? event['title'] : localized(event['titleKey'], event['title'])}',
      const Offset(25, 72),
      18,
      teal);
  c.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(24, 120, 712, 110), const Radius.circular(22)),
      Paint()..color = ink);
  _text(
      c,
      '${event['bodyKey'] == null ? event['body'] : localized(event['bodyKey'], event['body'])}',
      const Offset(48, 158),
      22,
      Colors.white,
      bold: true,
      width: 660);
  final choices = (event['choices'] as List).cast<Map>();
  for (var i = 0; i < 2; i++) {
    final x = 24 + i * 356.0,
        choice = choices[i],
        req = choice['requiresStat'] as String?,
        min = choice['requiresMin'] as int?,
        bondReq = choice['requiresBondId'] as String?,
        bondMin = choice['requiresBondMin'] as int?,
        flagReq = choice['requiresFlag'] as String?,
        locked = (req != null && (stats[req] ?? 0) < (min ?? 0)) ||
            (bondReq != null && (bonds[bondReq] ?? 0) < (bondMin ?? 0)) ||
            (flagReq != null && memoryFlags[flagReq] != true);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, 270, 332, 190), const Radius.circular(18)),
        Paint()..color = locked ? paper : Colors.white);
    _text(c, locked ? 'Locked' : 'Choice ${i + 1}', Offset(x + 22, 295), 14,
        locked ? ink.withValues(alpha: .45) : teal,
        bold: true);
    _text(
        c,
        '${choice['labelKey'] == null ? choice['label'] : localized(choice['labelKey'], choice['label'])}',
        Offset(x + 22, 340),
        17,
        locked ? ink.withValues(alpha: .45) : ink,
        bold: true,
        width: 280);
  }
}

void drawEndingRetrospective(
    Canvas c,
    List<String> history,
    int goalCount,
    List<String> missingGoals,
    List<Map<String, dynamic>> milestones,
    Map<String, bool> milestoneState) {
  final events = history
      .where((entry) => entry.startsWith('event:'))
      .map((entry) => entry.replaceFirst('event:', '').split('|').first)
      .take(3)
      .toList();
  final title = localized('ui.ending.retrospective', '기록 회고');
  final next = missingGoals.isEmpty
      ? localized('ui.ending.allGoals', '모든 목표를 확인했습니다.')
      : '${localized('ui.ending.nextGoal', '다음 회차 단서')} · ${missingGoals.join(' · ')}';
  final causes = events.isEmpty
      ? localized('ui.ending.noEvents', '기록된 사건이 없습니다.')
      : events.asMap().entries.map((entry) {
          final value = entry.value.length > 15
              ? '${entry.value.substring(0, 15)}…'
              : entry.value;
          return '${entry.key + 1}. $value';
        }).join('\n');
  final ledger = milestones.map((goal) {
    final title = activeLocale == 'ko'
        ? '${goal['title']}'
        : localized(goal['titleKey'] as String? ?? '', '${goal['title']}');
    final compact = title.length > 7 ? '${title.substring(0, 7)}…' : title;
    return '$compact${milestoneState[goal['id']] == true ? ' ✓' : ' ·'}';
  }).join('   ');
  c.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(365, 400, 300, 125), const Radius.circular(18)),
      Paint()..color = Colors.white);
  _text(c, title, const Offset(385, 410), 14, teal, bold: true, width: 260);
  _text(c, causes, const Offset(385, 437), 10, ink, width: 260);
  _text(c, localized('ui.ending.seasonLedger', '계절 목표'), const Offset(385, 473),
      10, teal,
      bold: true, width: 260);
  _text(c, ledger, const Offset(385, 489), 9, ink, width: 260);
  _text(c, '${localized('ui.ending.goalCause', '달성 목표')} · $goalCount',
      const Offset(385, 507), 10, ink,
      width: 260);
  _text(c, next, const Offset(385, 521), 10, teal, width: 260);
}

void drawLocalizedEnding(
    Canvas c,
    Map<String, dynamic> story,
    Map<String, dynamic> ending,
    int rank,
    List<String> history,
    int goalCount,
    List<String> missingGoals,
    List<Map<String, dynamic>> milestones,
    Map<String, bool> milestoneState) {
  if (activeLocale == 'ko') return;
  c.drawRect(const Rect.fromLTWH(0, 0, 740, 100), Paint()..color = paper);
  _text(c, localized('ui.ending.title', 'The End of 12 Weeks'),
      const Offset(24, 28), 32, ink,
      bold: true, width: 700);
  _text(
      c,
      localized(
          'ui.ending.subtitle', 'Lumen remembers the direction Noa chose.'),
      const Offset(25, 70),
      14,
      teal,
      width: 700);
  c.drawRect(const Rect.fromLTWH(345, 105, 395, 310), Paint()..color = paper);
  final id = ending['id'] as String? ?? '';
  final authored = (story['endings'] as List? ?? const [])
      .cast<Map>()
      .firstWhere((candidate) => candidate['id'] == id, orElse: () => ending);
  _text(
      c,
      localized('ending.$id.title', '${authored['title'] ?? ending['title']}'),
      const Offset(365, 145),
      22,
      ink,
      bold: true,
      width: 350);
  _text(
      c,
      localized('ending.$id.body', '${authored['body'] ?? ending['body']}'),
      const Offset(365, 200),
      16,
      ink,
      width: 350);
  _text(
      c,
      '${localized('ui.ending.record', 'Lumen record')} · ${List.filled(rank, '★').join()}',
      const Offset(365, 350),
      15,
      teal,
      bold: true,
      width: 350);
  final epilogues = (ending['epilogues'] as List? ?? const []).cast<Map>();
  final epilogueLine = epilogues.isEmpty
      ? '${ending['epilogue'] ?? ''}'
      : epilogues.map((epilogue) {
          final text =
              localized('${epilogue['key']}', '${epilogue['text'] ?? ''}');
          return text.length > 10 ? '${text.substring(0, 10)}…' : text;
        }).join(' · ');
  if (epilogueLine.isNotEmpty)
    _text(c, epilogueLine, const Offset(365, 378), 11, teal, width: 350);
  drawEndingRetrospective(
      c, history, goalCount, missingGoals, milestones, milestoneState);
  c.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(365, 535, 300, 64), const Radius.circular(18)),
      Paint()..color = sun);
  _text(c, localized('ui.ending.restart', 'Return to Lumen'),
      const Offset(450, 557), 17, ink,
      bold: true, width: 220);
}

void drawLocaleToggle(Canvas c, String locale, LocaleCatalog catalog) {
  final rect = const Rect.fromLTWH(600, 24, 120, 40);
  c.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()..color = twilight);
  final label = TextPainter(
      text: TextSpan(
          text: catalog.text(locale, 'ui.locale.toggle',
              fallback: locale == 'ko' ? 'EN' : '한국어'),
          style: const TextStyle(
              fontFamily: 'NotoSansKR',
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr)
    ..layout(maxWidth: 100);
  label.paint(c, const Offset(635, 36));
}
