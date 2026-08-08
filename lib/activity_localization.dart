typedef ActivityText = String Function(String key, String fallback);

Map<String, dynamic>? activityReflectionForLine(
    List<Map<String, dynamic>> scenes, String rawLine) {
  if (rawLine.isEmpty) return null;
  for (final scene in scenes) {
    if ('${scene['line']}' == rawLine) return scene;
  }
  return null;
}

String localizedActivityLine({
  required List<Map<String, dynamic>> scenes,
  required String rawLine,
  required ActivityText text,
}) {
  final scene = activityReflectionForLine(scenes, rawLine);
  return scene == null ? rawLine : text('${scene['lineKey']}', rawLine);
}

String localizedActivityResult({
  required String raw,
  required List<Map<String, dynamic>> activities,
  required List<Map<String, dynamic>> scenes,
  required List<String> stats,
  required ActivityText text,
  required String Function(String) statText,
}) {
  if (raw.isEmpty) return raw;
  return raw.split(' · ').map((part) {
    final activity = activities.where((item) => '${item['label']}' == part);
    if (activity.isNotEmpty) {
      final item = activity.first;
      return text('activity.${item['id']}.label', part);
    }
    final reflection = scenes.where((item) => '${item['title']}' == part);
    if (reflection.isNotEmpty) {
      final item = reflection.first;
      return text('${item['titleKey']}', part);
    }
    for (final stat in stats) {
      if (part.startsWith('$stat ')) {
        return '${statText(stat)}${part.substring(stat.length)}';
      }
    }
    if (part.startsWith('피로 ')) {
      return text('ui.home.fatigueDelta', 'Fatigue {delta}')
          .replaceFirst('{delta}', part.substring(3));
    }
    if (part.startsWith('성격 재능 ')) {
      return text('ui.home.talent', 'Talent +{bonus}')
          .replaceFirst('{bonus}', part.substring(6).replaceFirst('+', ''));
    }
    return part;
  }).join(' · ');
}
