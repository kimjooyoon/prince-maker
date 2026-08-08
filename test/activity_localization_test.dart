import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/activity_localization.dart';

void main() {
  test('activity result localizes deterministic reflection', () {
    const List<Map<String, dynamic>> scenes = [
      {
        'id': 'observatory-late',
        'title': '늦은 별자리',
        'titleKey': 'activityScene.observatory-late.title',
        'line': '늦었다는 사실이 틀렸다는 뜻은 아니야.',
        'lineKey': 'activityScene.observatory-late.line',
      }
    ];
    const List<Map<String, dynamic>> activities = [
      {'id': 'observatory', 'label': '별 관측'}
    ];
    const en = {
      'activity.observatory.label': 'Star watch',
      'activityScene.observatory-late.title': 'A Late Constellation',
      'activityScene.observatory-late.line':
          'Being late does not mean being wrong.',
      'ui.home.fatigueDelta': 'Fatigue {delta}',
      'ui.home.talent': 'Talent +{bonus}',
    };
    String text(String key, String fallback) => en[key] ?? fallback;
    final result = localizedActivityResult(
        raw: '별 관측 · 지혜 +3 · 피로 +1 · 성격 재능 +1 · 늦은 별자리',
        activities: scenes.isEmpty ? const [] : activities,
        scenes: scenes,
        stats: const ['지혜', '공감', '용기'],
        text: text,
        statText: (stat) => {'지혜': 'Wisdom'}[stat] ?? stat);
    expect(result,
        'Star watch · Wisdom +3 · Fatigue +1 · Talent +1 · A Late Constellation');
    expect(
        localizedActivityLine(
            scenes: scenes, rawLine: '늦었다는 사실이 틀렸다는 뜻은 아니야.', text: text),
        'Being late does not mean being wrong.');
    expect(activityReflectionForLine(scenes, 'missing'), isNull);
  });
}
