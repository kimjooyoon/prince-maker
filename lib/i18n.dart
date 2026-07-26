import 'package:flutter/material.dart';
import 'design_tokens.dart';

class LocaleCatalog {
  const LocaleCatalog(this.bundles);
  final Map<String, Map<String, String>> bundles;
  String text(String locale, String key, {String fallback = ''}) => bundles[locale]?[key] ?? bundles['ko']?[key] ?? fallback;
}

String activeLocale = 'ko';
LocaleCatalog activeCatalog = const LocaleCatalog({});
void setActiveLocale(String locale, LocaleCatalog catalog) { activeLocale = locale; activeCatalog = catalog; }
String localized(String key, String fallback) => activeCatalog.text(activeLocale, key, fallback: fallback);

void _text(Canvas c, String value, Offset offset, double size, Color color, {bool bold = false, double width = 680}) {
  final painter = TextPainter(text: TextSpan(text: value, style: TextStyle(fontFamily: 'NotoSansKR', fontSize: size, color: color, fontWeight: bold ? FontWeight.w800 : FontWeight.w400)), textDirection: TextDirection.ltr)..layout(maxWidth: width);
  painter.paint(c, offset);
}

void drawLocalizedIllustration(Canvas c, Map<String, dynamic> story, int persona) {
  if (activeLocale == 'ko') return;
  final p = story['personalities'][persona] as Map;
  c.drawRect(const Rect.fromLTWH(370, 105, 370, 335), Paint()..color = paper);
  final id = p['id'] as String? ?? 'quiet';
  _text(c, localized('personality.$id.name', p['name'] as String), const Offset(390, 125), 24, ink, bold: true);
  _text(c, localized('personality.$id.voice', p['voice'] as String), const Offset(390, 165), 14, teal);
  _text(c, 'Talent · ${p['focusStat']} +${p['focusBonus']}', const Offset(390, 195), 13, teal);
  c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(390, 220, 330, 150), const Radius.circular(20)), Paint()..color = Colors.white);
  _text(c, '“${localized(p['lineKey'] as String? ?? '', p['line'] as String)}”', const Offset(415, 250), 20, ink, bold: true, width: 290);
  _text(c, '${story['hero']} · weekly record', const Offset(390, 400), 14, ink.withValues(alpha: .55));
}

void drawLocalizedEvent(Canvas c, Map<String, dynamic> story, int eventIndex, Map<String, int> stats) {
  if (activeLocale == 'ko') return;
  final event = story['events'][eventIndex] as Map;
  c.drawRect(const Rect.fromLTWH(0, 0, 590, 100), Paint()..color = paper);
  _text(c, '${event['titleKey'] == null ? event['title'] : localized(event['titleKey'], event['title'])}', const Offset(25, 72), 18, teal);
  c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(24, 120, 712, 110), const Radius.circular(22)), Paint()..color = ink);
  _text(c, '${event['bodyKey'] == null ? event['body'] : localized(event['bodyKey'], event['body'])}', const Offset(48, 158), 22, Colors.white, bold: true, width: 660);
  final choices = (event['choices'] as List).cast<Map>();
  for (var i = 0; i < 2; i++) {
    final x = 24 + i * 356.0, choice = choices[i], req = choice['requiresStat'] as String?, min = choice['requiresMin'] as int?, locked = req != null && (stats[req] ?? 0) < (min ?? 0);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, 270, 332, 190), const Radius.circular(18)), Paint()..color = locked ? paper : Colors.white);
    _text(c, locked ? 'Locked' : 'Choice ${i + 1}', Offset(x + 22, 295), 14, locked ? ink.withValues(alpha: .45) : teal, bold: true);
    _text(c, '${choice['labelKey'] == null ? choice['label'] : localized(choice['labelKey'], choice['label'])}', Offset(x + 22, 340), 17, locked ? ink.withValues(alpha: .45) : ink, bold: true, width: 280);
  }
}

void drawLocaleToggle(Canvas c, String locale, LocaleCatalog catalog) {
  final rect = const Rect.fromLTWH(600, 24, 120, 40);
  c.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(14)), Paint()..color = twilight);
  final label = TextPainter(text: TextSpan(text: catalog.text(locale, 'ui.locale.toggle', fallback: locale == 'ko' ? 'EN' : '한국어'), style: const TextStyle(fontFamily: 'NotoSansKR', fontSize: 13, color: Colors.white, fontWeight: FontWeight.w800)), textDirection: TextDirection.ltr)..layout(maxWidth: 100);
  label.paint(c, const Offset(635, 36));
}
