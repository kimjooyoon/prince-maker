import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

String sha(String path) => sha256.convert(File(path).readAsBytesSync()).toString();
String render(Map<String, dynamic> s, String hash) {
  final people = (s['personalities'] as List).cast<Map<String, dynamic>>();
  final companions = (s['companions'] as List? ?? []).cast<Map<String, dynamic>>();
  final acts = (s['activities'] as List).cast<Map<String, dynamic>>();
  final events = (s['events'] as List).cast<Map<String, dynamic>>();
  final endings = (s['endings'] as List).cast<Map<String, dynamic>>();
  final milestones = (s['milestones'] as List? ?? []).cast<Map<String, dynamic>>();
  final assets = (s['assetRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  final fonts = (s['fontRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  final locales = (s['localeRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  final b = StringBuffer('<!-- generated: tool/generate_ssot_docs.dart -->\n<!-- ssot-sha256: $hash -->\n<!-- source-ref: story/story.json#root -->\n\n# ${s['title']} · 스토리 SSOT\n\n');
  b.writeln('${s['setting']}에서 ${s['hero']}는 ${s['endingWeek']}주 동안 스스로 선택한 내일을 걷는다.');
  b.writeln('\n## 생성 이미지 자산\n');
  for (final a in assets) b.writeln('- [`${a['ref']}`](../${a['ref'].toString().split('#').first}) · SHA-256 `${a['sha256']}`');
  b.writeln('\n## 폰트\n');
  for (final f in fonts) b.writeln('- [`${f['ref']}`](../${f['ref'].toString().split('#').first}) · SHA-256 `${f['sha256']}`');
  b.writeln('\n## 대사 로케일\n');
  for (final l in locales) b.writeln('- [`${l['ref']}`](../${l['ref'].toString().split('#').first}) · SHA-256 `${l['sha256']}`');
  b.writeln('\n## 성격\n');
  for (final p in people) { final d = (p['design'] as Map?) ?? {}; b.writeln('- **${p['name']}** (`${p['id']}`): ${p['voice']} “${p['line']}” · ${p['focusStat']} 재능 +${p['focusBonus']} · frame ${p['portraitFrame']} · `${p['portraitAsset']}` · ${d['palette']} / ${d['motif']}'); }
  b.writeln('\n## 동료\n');
  for (final c in companions) b.writeln('- **${c['name']}** (`${c['id']}`): ${c['role']} · ${c['personality']} · frame ${c['portraitFrame']} · 유대 ${c['bondThreshold']}에서 에필로그 · “${c['greeting']}”');
  b.writeln('\n## 활동\n');
  for (final a in acts) b.writeln('- **${a['label']}** (`${a['id']}`): ${a['hint']}');
  b.writeln('\n## 계절 목표\n');
  for (final m in milestones) b.writeln('- **${m['title']}** (`${m['id']}`): ${m['week']}주차 · ${m['stat']} ≥ ${m['min']} · 성공 보상 은화 ${m['coins']} · “${m['pass']}” / “${m['fail']}”');
  b.writeln('\n## 사건\n');
  for (final e in events) { b.writeln('### ${e['week']}주차 · ${e['title']}\n\n${e['body']}'); for (final c in (e['choices'] as List)) b.writeln('- ${c['label']}: ${c['stat']} +${c['delta']}, 은화 ${c['coins']}, ${c['bondId']} 유대 +${c['bondDelta']}${c['requiresStat'] == null ? '' : ', 조건 ${c['requiresStat']} ≥ ${c['requiresMin']}'} · “${c['line']}”'); }
  b.writeln('\n## 엔딩\n');
  for (final e in endings) b.writeln('- **${e['title']}** (`${e['id']}`): ${e['stat']} ≥ ${e['min']}${(e['requiresMilestones'] as List? ?? []).isEmpty ? '' : ' · 목표 ${((e['requiresMilestones'] as List).join(', '))}'} · ${e['body']}');
  return b.toString();
}
String renderMetrics(Map<String, dynamic> s, String hash) {
  final acts = (s['activities'] as List).length, people = (s['personalities'] as List).length, companions = (s['companions'] as List? ?? []).length, milestones = (s['milestones'] as List? ?? []).length, events = (s['events'] as List).cast<Map<String, dynamic>>(), endings = (s['endings'] as List).length, choices = events.fold<int>(0, (sum, e) => sum + (e['choices'] as List).length), goldens = Directory('test/goldens').existsSync() ? Directory('test/goldens').listSync().whereType<File>().where((f) => f.path.endsWith('.png')).length : 0;
  final b = StringBuffer('<!-- generated: tool/generate_ssot_docs.dart -->\n<!-- ssot-sha256: $hash -->\n<!-- source-ref: story/story.json#root -->\n\n# ${s['title']} · SSOT 자동 품질 지표\n\n');
  b.writeln('이 문서는 `story/story.json`에서 자동 생성된다. 코드·Golden·CI의 수치가 SSOT 변경과 함께 갱신되는지 pre-commit에서 확인한다.\n');
  b.writeln('| 항목 | 현재 | 산출 기준 |\n| --- | ---: | --- |');
  b.writeln('| 캠페인 길이 | ${s['endingWeek']}주 | `endingWeek` |'); b.writeln('| 활동 | $acts | `activities.length` |'); b.writeln('| 성격 | $people | `personalities.length` |'); b.writeln('| 동료 | $companions | `companions.length` |'); b.writeln('| 계절 목표 | $milestones | `milestones.length` |'); b.writeln('| 사건 | ${events.length} | `events.length` |'); b.writeln('| 사건 선택 | $choices | 모든 사건 choices 합계 |'); b.writeln('| 엔딩 | $endings | `endings.length` |'); b.writeln('| Canvas Golden | $goldens | `test/goldens/*.png` |'); b.writeln('| 코드 ref | ${(s['codeRefs'] as List).length} | `codeRefs.length` |'); b.writeln('| 이미지 ref | ${(s['assetRefs'] as List).length} | `assetRefs.length` |'); b.writeln('| 폰트 ref | ${(s['fontRefs'] as List? ?? []).length} | `fontRefs.length` |'); b.writeln('| 대사 locale | ${(s['localeRefs'] as List? ?? []).length} | `localeRefs.length` |');
  b.writeln('\n## 폐쇄루프 연결\n\nSSOT → GameWorld 전이 → Canvas/Golden → 저장·replay → benchmark → 같은 SSOT로 재검증. 상세 설계는 [`docs/trilemma.md`](trilemma.md), 전체 지표는 [`docs/game-completeness.md`](game-completeness.md)에서 확인한다.');
  return b.toString();
}
void main(List<String> args) {
  final input = 'story/story.json', hash = sha(input), source = jsonDecode(File(input).readAsStringSync()) as Map<String, dynamic>, outputs = {'docs/story-ssot.md': render(source, hash), 'docs/ssot-metrics.md': renderMetrics(source, hash)};
  if (args.contains('--check')) { for (final entry in outputs.entries) { if (!File(entry.key).existsSync() || File(entry.key).readAsStringSync() != entry.value) { stderr.writeln('SSOT_DOC_FAIL: regenerate ${entry.key}'); exit(1); } } stdout.writeln('SSOT_DOC_OK: ${outputs.keys.join(', ')} sha256=$hash'); return; }
  for (final entry in outputs.entries) File(entry.key).writeAsStringSync(entry.value); stdout.writeln('SSOT_DOC_WRITTEN: ${outputs.keys.join(', ')} sha256=$hash');
}
