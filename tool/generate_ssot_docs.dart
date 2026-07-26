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
  final b = StringBuffer('<!-- generated: tool/generate_ssot_docs.dart -->\n<!-- ssot-sha256: $hash -->\n<!-- source-ref: story/story.json#root -->\n\n# ${s['title']} · 스토리 SSOT\n\n');
  b.writeln('${s['setting']}에서 ${s['hero']}는 ${s['endingWeek']}주 동안 스스로 선택한 내일을 걷는다.');
  b.writeln('\n## 생성 이미지 자산\n');
  for (final a in assets) b.writeln('- [`${a['ref']}`](../${a['ref'].toString().split('#').first}) · SHA-256 `${a['sha256']}`');
  b.writeln('\n## 폰트\n');
  for (final f in fonts) b.writeln('- [`${f['ref']}`](../${f['ref'].toString().split('#').first}) · SHA-256 `${f['sha256']}`');
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
  for (final e in endings) b.writeln('- **${e['title']}** (`${e['id']}`): ${e['stat']} ≥ ${e['min']} · ${e['body']}');
  return b.toString();
}
void main(List<String> args) {
  final input = 'story/story.json', output = 'docs/story-ssot.md', hash = sha(input), expected = render(jsonDecode(File(input).readAsStringSync()), hash);
  if (args.contains('--check')) { if (!File(output).existsSync() || File(output).readAsStringSync() != expected) { stderr.writeln('SSOT_DOC_FAIL: regenerate $output'); exit(1); } stdout.writeln('SSOT_DOC_OK: $output sha256=$hash'); return; }
  File(output).writeAsStringSync(expected); stdout.writeln('SSOT_DOC_WRITTEN: $output sha256=$hash');
}
