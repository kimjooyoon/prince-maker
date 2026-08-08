import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

String sha(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();
String render(Map<String, dynamic> s, String hash) {
  final people = (s['personalities'] as List).cast<Map<String, dynamic>>();
  final companions =
      (s['companions'] as List? ?? []).cast<Map<String, dynamic>>();
  final legacyProfiles =
      (s['legacyProfiles'] as List? ?? []).cast<Map<String, dynamic>>();
  final acts = (s['activities'] as List).cast<Map<String, dynamic>>();
  final events = (s['events'] as List).cast<Map<String, dynamic>>();
  final endings = (s['endings'] as List).cast<Map<String, dynamic>>();
  final milestones =
      (s['milestones'] as List? ?? []).cast<Map<String, dynamic>>();
  final assets = (s['assetRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  final fonts = (s['fontRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  final locales = (s['localeRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  final progression =
      (s['progression'] as List? ?? []).cast<Map<String, dynamic>>();
  final dialogue = (s['dialogueMetrics'] as Map? ?? {}).cast<String, dynamic>();
  final scenario =
      (s['scenarioCompleteness'] as Map? ?? {}).cast<String, dynamic>();
  final decision = (s['decisionSystem'] as Map? ?? {}).cast<String, dynamic>();
  final campaignWeeks =
      (s['campaignWeeks'] as int?) ?? ((s['endingWeek'] as int) - 1);
  final budget = (s['contentBudget'] as Map? ?? {}).cast<String, dynamic>();
  final b = StringBuffer(
      '<!-- generated: tool/generate_ssot_docs.dart -->\n<!-- ssot-sha256: $hash -->\n<!-- source-ref: story/story.json#root -->\n\n# ${s['title']} · 스토리 SSOT\n\n');
  b.writeln(
      '${s['setting']}에서 ${s['hero']}는 ${campaignWeeks}주 동안 스스로 선택한 내일을 걷는다.');
  b.writeln('\n## 시스템 판정과 책임 추적\n');
  b.writeln(
      '판정 주체: **${decision['owner']}** · 모드 `${decision['mode']}` · 사람 승인 필요 여부 `${decision['humanApprovalRequired']}` · 실패 모드 `${decision['failureMode']}`');
  b.writeln('책임 증적: ${decision['responsibility']}');
  for (final rule in (decision['rules'] as List? ?? const []))
    b.writeln('- `${rule['id']}` · ${rule['scope']} · ${rule['effect']}');
  b.writeln('\n## ${campaignWeeks}주 진행도\n');
  for (final c in progression)
    b.writeln(
        '- **${c['title']}** (`${c['id']}`): ${c['weekStart']}–${c['weekEnd']}주 · ${c['premise']} → ${c['payoff']} · 사건 ${((c['eventWeeks'] as List).join(', '))}주 · 목표 `${c['milestoneId']}`\n  - 막 계약: 공개 ${c['contract']['reveal']} · 압력 ${(c['contract']['pressureAxes'] as List).join('·')} · 선택 ${(c['contract']['choiceWeeks'] as List).join(', ')}주 · 결산 `${c['contract']['closureMilestone']}`');
  b.writeln('\n## 대사 구성 기준\n');
  b.writeln(
      '- locale 최소 키: **${dialogue['minimumLocaleKeys']}** · 한 캠페인 최소 대사 줄: **${dialogue['minimumVisibleDialogueLines']}** · 최소 노출 서사 단위: **${dialogue['minimumVisibleNarrativeUnits']}** · 전체 authored 대사 줄: **${dialogue['authoredDialogueLines']}**');
  b.writeln('- 산식: ${dialogue['formula']}');
  b.writeln('\n## 최소 플레이타임 계약\n');
  b.writeln(
      '- 최소 보장: **${budget['minimumMinutes']}분** · 보수적 1회차 추정: **${budget['estimatedFirstPlaythroughMinutes']}분**');
  b.writeln('- 근거: ${budget['formula']}');
  b.writeln('\n## 시나리오 완전성 표본\n');
  b.writeln(
      '참조 모델: **${scenario['referenceModel']}** (`${scenario['schema']}`)\n');
  b.writeln('| 차원 | 목표 | 현재 증적 | 검증 ref |\n| --- | --- | --- | --- |');
  for (final d in (scenario['dimensions'] as List? ?? const []))
    b.writeln(
        '| ${d['name']} | ${d['target']} | ${d['current']} | `${d['evidence']}` |');
  b.writeln('\n## 생성 이미지 자산\n');
  for (final a in assets)
    b.writeln(
        '- [`${a['ref']}`](../${a['ref'].toString().split('#').first}) · SHA-256 `${a['sha256']}`');
  b.writeln('\n## 폰트\n');
  for (final f in fonts)
    b.writeln(
        '- [`${f['ref']}`](../${f['ref'].toString().split('#').first}) · SHA-256 `${f['sha256']}`');
  b.writeln('\n## 대사 로케일\n');
  for (final l in locales)
    b.writeln(
        '- [`${l['ref']}`](../${l['ref'].toString().split('#').first}) · SHA-256 `${l['sha256']}`');
  b.writeln('\n## 성격\n');
  for (final p in people) {
    final d = (p['design'] as Map?) ?? {};
    b.writeln(
        '- **${p['name']}** (`${p['id']}`): ${p['voice']} “${p['line']}” · ${p['focusStat']} 재능 +${p['focusBonus']} · frame ${p['portraitFrame']} · `${p['portraitAsset']}` · ${d['palette']} / ${d['motif']}');
  }
  b.writeln('\n## 동료\n');
  for (final c in companions)
    b.writeln(
        '- **${c['name']}** (`${c['id']}`): ${c['role']} · ${c['personality']} · frame ${c['portraitFrame']} · 유대 ${c['bondThreshold']}에서 에필로그 · “${c['greeting']}”');
  b.writeln('\n## 회차 계승 프로필\n');
  for (final p in legacyProfiles)
    b.writeln(
        '- **${p['title']}** (`${p['id']}`): 엔딩 ${(p['endingIds'] as List? ?? const []).join(', ')} · ${p['stat']} 시작 보너스 +${p['bonus']} · `${p['titleKey']}`');
  b.writeln('\n## 활동\n');
  for (final a in acts)
    b.writeln('- **${a['label']}** (`${a['id']}`): ${a['hint']}');
  b.writeln('\n## 계절 목표\n');
  for (final m in milestones)
    b.writeln(
        '- **${m['title']}** (`${m['id']}`): ${m['week']}주차 · ${m['stat']} ≥ ${m['min']} · 성공 보상 은화 ${m['coins']} · “${m['pass']}” / “${m['fail']}”');
  b.writeln('\n## 사건\n');
  for (final e in events) {
    b.writeln('### ${e['week']}주차 · ${e['title']}\n\n${e['body']}');
    for (final c in (e['choices'] as List))
      b.writeln(
          '- ${c['label']}: ${c['stat']} +${c['delta']}, 은화 ${c['coins']}, ${c['bondId']} 유대 +${c['bondDelta']}${c['requiresStat'] == null ? '' : ', 조건 ${c['requiresStat']} ≥ ${c['requiresMin']}'}${c['requiresBondId'] == null ? '' : ', 관계 ${c['requiresBondId']} 유대 ≥ ${c['requiresBondMin']}'}${c['requiresFlag'] == null ? '' : ', 기억 ${c['requiresFlag']} 필요'}${c['setsFlag'] == null ? '' : ', 기억 ${c['setsFlag']} 기록'} · “${c['line']}”');
  }
  b.writeln('\n## 엔딩\n');
  for (final e in endings)
    b.writeln(
        '- **${e['title']}** (`${e['id']}`): ${e['stat']} ≥ ${e['min']}${(e['requiresMilestones'] as List? ?? []).isEmpty ? '' : ' · 목표 ${((e['requiresMilestones'] as List).join(', '))}'} · ${e['body']}');
  return b.toString();
}

String renderMetrics(Map<String, dynamic> s, String hash) {
  final acts = (s['activities'] as List).length,
      people = (s['personalities'] as List).length,
      companions = (s['companions'] as List? ?? []).length,
      legacyProfiles = (s['legacyProfiles'] as List? ?? []).length,
      milestones = (s['milestones'] as List? ?? []).length,
      events = (s['events'] as List).cast<Map<String, dynamic>>(),
      endings = (s['endings'] as List).length,
      choices =
          events.fold<int>(0, (sum, e) => sum + (e['choices'] as List).length),
      goldens = Directory('test/goldens').existsSync()
          ? Directory('test/goldens')
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.png'))
              .length
          : 0,
      progression = (s['progression'] as List? ?? []).length,
      chapterContracts = (s['progression'] as List? ?? [])
          .where((chapter) => (chapter as Map)['contract'] is Map)
          .length,
      dialogue = (s['dialogueMetrics'] as Map? ?? {}),
      scenario = (s['scenarioCompleteness'] as Map? ?? {}),
      budget = (s['contentBudget'] as Map? ?? {}),
      campaignWeeks =
          (s['campaignWeeks'] as int?) ?? ((s['endingWeek'] as int) - 1),
      ranges = (s['progression'] as List? ?? const [])
          .map((chapter) => '${chapter['weekStart']}–${chapter['weekEnd']}주')
          .join(' / ');
  final b = StringBuffer(
      '<!-- generated: tool/generate_ssot_docs.dart -->\n<!-- ssot-sha256: $hash -->\n<!-- source-ref: story/story.json#root -->\n\n# ${s['title']} · SSOT 자동 품질 지표\n\n');
  b.writeln(
      '이 문서는 `story/story.json`에서 자동 생성된다. 코드·Golden·CI의 수치가 SSOT 변경과 함께 갱신되는지 pre-commit에서 확인한다.\n');
  b.writeln('| 항목 | 현재 | 산출 기준 |\n| --- | ---: | --- |');
  b.writeln(
      '| 캠페인 길이 | ${campaignWeeks}주 + terminal week | `campaignWeeks`, `endingWeek` |');
  b.writeln(
      '| 최소 플레이타임 | ${budget['minimumMinutes']}분 | `contentBudget.minimumMinutes` |');
  b.writeln(
      '| 1회차 추정 | ${budget['estimatedFirstPlaythroughMinutes']}분 | `contentBudget.estimatedFirstPlaythroughMinutes` |');
  b.writeln(
      '| 시스템 판정 | ${(s['decisionSystem'] as Map?)?['id'] ?? 'none'} | SSOT `decisionSystem` · fail-closed receipt |');
  b.writeln('| 활동 | $acts | `activities.length` |');
  b.writeln('| 성격 | $people | `personalities.length` |');
  b.writeln('| 동료 | $companions | `companions.length` |');
  b.writeln('| 회차 계승 프로필 | $legacyProfiles | `legacyProfiles.length` |');
  b.writeln('| 계절 목표 | $milestones | `milestones.length` |');
  b.writeln('| 사건 | ${events.length} | `events.length` |');
  b.writeln('| 사건 선택 | $choices | 모든 사건 choices 합계 |');
  b.writeln('| 엔딩 | $endings | `endings.length` |');
  b.writeln('| Canvas Golden | $goldens | `test/goldens/*.png` |');
  b.writeln(
      '| 코드 ref | ${(s['codeRefs'] as List).length} | `codeRefs.length` |');
  b.writeln(
      '| 이미지 ref | ${(s['assetRefs'] as List).length} | `assetRefs.length` |');
  b.writeln(
      '| 폰트 ref | ${(s['fontRefs'] as List? ?? []).length} | `fontRefs.length` |');
  b.writeln(
      '| 대사 locale | ${(s['localeRefs'] as List? ?? []).length} | `localeRefs.length` |');
  b.writeln('| 스토리 막 | $progression | `progression.length` · $ranges |');
  b.writeln(
      '| 막 계약 | $chapterContracts/$progression | 각 막의 `contract` 공개·압력·선택·결산 선언 |');
  b.writeln(
      '| 시나리오 완전성 차원 | ${(scenario['dimensions'] as List? ?? []).length} | `scenarioCompleteness.dimensions.length` |');
  b.writeln(
      '| locale 최소 키 | ${dialogue['minimumLocaleKeys']} | `dialogueMetrics.minimumLocaleKeys` |');
  b.writeln(
      '| 캠페인 최소 대사 줄 | ${dialogue['minimumVisibleDialogueLines']} | ${campaignWeeks}주 authored 사건 선택 노출 기준 |');
  b.writeln(
      '| 캠페인 최소 서사 단위 | ${dialogue['minimumVisibleNarrativeUnits']} | 성격·사건 제목/본문·선택·엔딩 |');
  b.writeln(
      '\n## 폐쇄루프 연결\n\nSSOT → GameWorld 전이 → Canvas/Golden → 저장·replay → benchmark → 같은 SSOT로 재검증. 기계 판정 기준은 [`docs/trilemma-contract.json`](trilemma-contract.json), 상세 설계는 [`docs/trilemma.md`](trilemma.md), 전체 지표는 [`docs/game-completeness.md`](game-completeness.md)에서 확인한다.');
  return b.toString();
}

void main(List<String> args) {
  final input = 'story/story.json',
      hash = sha(input),
      source =
          jsonDecode(File(input).readAsStringSync()) as Map<String, dynamic>,
      outputs = {
        'docs/story-ssot.md': render(source, hash),
        'docs/ssot-metrics.md': renderMetrics(source, hash)
      };
  if (args.contains('--check')) {
    for (final entry in outputs.entries) {
      if (!File(entry.key).existsSync() ||
          File(entry.key).readAsStringSync() != entry.value) {
        stderr.writeln('SSOT_DOC_FAIL: regenerate ${entry.key}');
        exit(1);
      }
    }
    stdout.writeln('SSOT_DOC_OK: ${outputs.keys.join(', ')} sha256=$hash');
    return;
  }
  for (final entry in outputs.entries)
    File(entry.key).writeAsStringSync(entry.value);
  stdout.writeln('SSOT_DOC_WRITTEN: ${outputs.keys.join(', ')} sha256=$hash');
}
