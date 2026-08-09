import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:prince_maker/jsonl.dart';

String sha(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();
String render(Map<String, dynamic> s, String hash) {
  final people = (s['personalities'] as List).cast<Map<String, dynamic>>();
  final characterArchive = (s['characterArchive'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final companions = (s['companions'] as List? ?? [])
      .cast<Map<String, dynamic>>();
  final personalityCompanionRoutes =
      (s['personalityCompanionRoutes'] as List? ?? const [])
          .cast<Map<String, dynamic>>();
  final legacyProfiles = (s['legacyProfiles'] as List? ?? [])
      .cast<Map<String, dynamic>>();
  final acts = (s['activities'] as List).cast<Map<String, dynamic>>();
  final events = (s['events'] as List).cast<Map<String, dynamic>>();
  final sideScenes = (s['sideScenes'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final companionScenes = (s['companionScenes'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final activityScenes = (s['activityScenes'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final endingVariants = (s['endingVariants'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final endings = (s['endings'] as List).cast<Map<String, dynamic>>();
  final milestones = (s['milestones'] as List? ?? [])
      .cast<Map<String, dynamic>>();
  final fateThreads = (s['fateThreads'] as List? ?? [])
      .cast<Map<String, dynamic>>();
  final companionQuests = (s['companionQuests'] as List? ?? [])
      .cast<Map<String, dynamic>>();
  final assets = (s['assetRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  final fonts = (s['fontRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  final locales = (s['localeRefs'] as List? ?? []).cast<Map<String, dynamic>>();
  final progression = (s['progression'] as List? ?? [])
      .cast<Map<String, dynamic>>();
  final dialogue = (s['dialogueMetrics'] as Map? ?? {}).cast<String, dynamic>();
  final scenario = (s['scenarioCompleteness'] as Map? ?? {})
      .cast<String, dynamic>();
  final decision = (s['decisionSystem'] as Map? ?? {}).cast<String, dynamic>();
  final engine = (s['engineDecision'] as Map? ?? {}).cast<String, dynamic>();
  final campaignWeeks =
      (s['campaignWeeks'] as int?) ?? ((s['endingWeek'] as int) - 1);
  final budget = (s['contentBudget'] as Map? ?? {}).cast<String, dynamic>();
  final scenarioVariants = (s['scenarioVariantBudget'] as Map? ?? {})
      .cast<String, dynamic>();
  final gameplay = (s['gameplayKpis'] as Map? ?? {}).cast<String, dynamic>();
  final renderQuality = (s['renderQualityKpis'] as Map? ?? {})
      .cast<String, dynamic>();
  final endingDesign = (s['endingDesign'] as Map? ?? {})
      .cast<String, dynamic>();
  final eventStormNodes =
      events.length +
      sideScenes.length +
      companionScenes.length +
      activityScenes.length +
      endingVariants.length +
      progression.length;
  final b = StringBuffer(
    '<!-- generated: tool/generate_ssot_docs.dart -->\n<!-- ssot-sha256: $hash -->\n<!-- source-ref: story/story.jsonl#root -->\n\n# ${s['title']} · 스토리 SSOT\n\n',
  );
  b.writeln(
    '${s['setting']}에서 ${s['hero']}는 ${campaignWeeks}주 동안 스스로 선택한 내일을 걷는다.',
  );
  b.writeln('\n## 시스템 판정과 책임 추적\n');
  b.writeln(
    '판정 주체: **${decision['owner']}** · 모드 `${decision['mode']}` · 사람 승인 필요 여부 `${decision['humanApprovalRequired']}` · 실패 모드 `${decision['failureMode']}`',
  );
  b.writeln('책임 증적: ${decision['responsibility']}');
  b.writeln(
    '시각 책임 증적: system decision receipt Golden `${gameplay['current']['systemDecisionReceiptGolden']}` · 승인·거절·owner·contract·rule·chained hashes',
  );
  for (final rule in (decision['rules'] as List? ?? const []))
    b.writeln('- `${rule['id']}` · ${rule['scope']} · ${rule['effect']}');
  b.writeln('\n## 렌더러 결정 계약\n');
  b.writeln(
    '선택: **`${engine['selectedOption']}`** · `${engine['decisionRule']}` · [결정 매트릭스](engine-decision.md)',
  );
  b.writeln('점수 의미: ${engine['scoreMeaning']}');
  b.writeln(
    'Golden 정책: 비정확 Canvas diff는 최대 **${renderQuality['current']['goldenTolerance'] * 100}%**까지 허용하며, 경계값 승인·초과/비유한값 거절은 `${renderQuality['definitions']['goldenToleranceBoundaryEvidence']}`로 실행 검증한다.',
  );
  b.writeln('\n## ${campaignWeeks}주 진행도\n');
  for (final c in progression)
    b.writeln(
      '- **${c['title']}** (`${c['id']}`): ${c['weekStart']}–${c['weekEnd']}주 · ${c['premise']} → ${c['payoff']} · 사건 ${((c['eventWeeks'] as List).join(', '))}주 · 목표 `${c['milestoneId']}`\n  - 막 계약: 공개 ${c['contract']['reveal']} · 압력 ${(c['contract']['pressureAxes'] as List).join('·')} · 선택 ${(c['contract']['choiceWeeks'] as List).join(', ')}주 · 결산 `${c['contract']['closureMilestone']}`',
    );
  b.writeln('\n## 대사 구성 기준\n');
  b.writeln(
    '- locale 최소 키: **${dialogue['minimumLocaleKeys']}** · 한 캠페인 최소 대사 줄: **${dialogue['minimumVisibleDialogueLines']}** · 최소 노출 서사 단위: **${dialogue['minimumVisibleNarrativeUnits']}** · 전체 authored 대사 줄: **${dialogue['authoredDialogueLines']}**',
  );
  b.writeln('- 산식: ${dialogue['formula']}');
  b.writeln('\n## 최소 플레이타임 계약\n');
  b.writeln(
    '- 최소 보장: **${budget['minimumMinutes']}분** · 보수적 1회차 추정: **${budget['estimatedFirstPlaythroughMinutes']}분**',
  );
  b.writeln('- 근거: ${budget['formula']}');
  b.writeln('\n## 시나리오 경우의 수 계약\n');
  b.writeln(
    '- 최소 보장: **${scenarioVariants['minimumCases']}개** · 실제 재생 검증: **${scenarioVariants['verifiedReachableCases']}개** · 전체 route input: **${scenarioVariants['routeInputCases']}개**',
  );
  b.writeln(
    '- 분기 주차: ${(scenarioVariants['branchWeeks'] as List? ?? const []).join(', ')}주',
  );
  b.writeln('- 산식: ${scenarioVariants['formula']}');
  b.writeln('\n## 게임성 KPI\n');
  b.writeln(
    'authored 선택 ${gameplay['current']['authoredChoices']}개 중 ${gameplay['current']['tradeoffChoices']}개가 보상과 비용을 동시에 갖는 교환 선택이다.',
  );
  b.writeln(
    '- 교환 선택 비율: **${gameplay['current']['tradeoffRate']}** · 목표 **${gameplay['targets']['minimumTradeoffRate']}** · `${gameplay['definitions']['tradeoffRate']}`',
  );
  b.writeln(
    '- 선택 영향 ${gameplay['current']['choiceImpactRate']} · 사건 분기 ${gameplay['current']['eventDivergenceRate']} · 다축 영향 ${gameplay['current']['multiAxisImpactRate']} · 조건부 선택 ${gameplay['current']['gatedChoices']}',
  );
  b.writeln(
    '- 동행 선택 사전 예고: ${gameplay['current']['companionSceneChoiceForesightRate']} · Golden `${gameplay['definitions']['companionSceneChoiceForesightGolden']}`',
  );
  b.writeln(
    '- 활동 선택 horizon: Golden `${gameplay['current']['activityForecastHorizonGolden']}` · ${gameplay['definitions']['activityForecastHorizonGolden']}',
  );
  b.writeln(
    '- 활동 피로 위험/회복 창: Golden `${gameplay['current']['activityRiskForecastGolden']}` · ${gameplay['definitions']['activityRiskForecastGolden']}',
  );
  b.writeln(
    '- 선택 기억 영향: Golden `${gameplay['current']['memoryImpactGolden']}` · ${gameplay['definitions']['memoryImpactGolden']}',
  );
  b.writeln('\n## 이벤트 스토밍 증적\n');
  b.writeln(
    '전체 authored 단위는 **${eventStormNodes}개 노드**로 `Trigger → Command → Policy → Domain event → Feedback` 원장에 생성된다. 본편·사이드 선택 ${gameplay['current']['authoredChoices']}개는 효과·피드백 연결률 1.0을 만족하며, 상세 원장은 [`docs/event-storm.jsonl`](event-storm.jsonl), 기계 판정은 `tool/verify_event_storm.dart#event-storm-gate`가 담당한다.',
  );
  b.writeln('\n## 엔딩 설계 행렬\n');
  b.writeln(
    '해결 순서: ${(endingDesign['resolutionOrder'] as List? ?? const []).join(' → ')}',
  );
  b.writeln(
    '- 핵심 엔딩군: ${(endingDesign['coreFamilies'] as List? ?? const []).map((family) => family['id']).join(', ')} · 동료 route set 최대 ${endingDesign['maximumCompanionRouteSets']}개 · terminal route card 최대 ${endingDesign['maximumTerminalRouteCards']}개',
  );
  b.writeln('\n## 나비효과 기록\n');
  b.writeln(
    '선택에서 기록된 기억 flag를 별도 상태로 복제하지 않고, 다음 장의 단서와 엔딩 회고에서 같은 SSOT flag로 재생성한다.',
  );
  for (final thread in fateThreads)
    b.writeln(
      '- **${thread['id']}** · `${thread['flag']}` · `${thread['titleRef']}` · ${thread['detail']} / ${thread['detailEn']}',
    );
  b.writeln('\n## 동료 퀘스트\n');
  for (final quest in companionQuests) {
    b.writeln(
      '- **${quest['id']}** · `${quest['companionId']}` · `${quest['titleRef']}`',
    );
    for (final stage in (quest['stages'] as List).cast<Map<String, dynamic>>())
      b.writeln(
        '  - `${stage['id']}` · `${stage['flag']}` · 유대 ${stage['bondMin']} · `${stage['eventRef']}`',
      );
  }
  b.writeln('\n## 시나리오 완전성 표본\n');
  b.writeln(
    '참조 모델: **${scenario['referenceModel']}** (`${scenario['schema']}`)\n',
  );
  b.writeln('| 차원 | 목표 | 현재 증적 | 검증 ref |\n| --- | --- | --- | --- |');
  for (final d in (scenario['dimensions'] as List? ?? const []))
    b.writeln(
      '| ${d['name']} | ${d['target']} | ${d['current']} | `${d['evidence']}` |',
    );
  b.writeln('\n## 생성 이미지 자산\n');
  for (final a in assets)
    b.writeln(
      '- [`${a['ref']}`](../${a['ref'].toString().split('#').first}) · SHA-256 `${a['sha256']}`',
    );
  b.writeln('\n## 폰트\n');
  for (final f in fonts)
    b.writeln(
      '- [`${f['ref']}`](../${f['ref'].toString().split('#').first}) · SHA-256 `${f['sha256']}`',
    );
  b.writeln('\n## 대사 로케일\n');
  for (final l in locales)
    b.writeln(
      '- [`${l['ref']}`](../${l['ref'].toString().split('#').first}) · SHA-256 `${l['sha256']}`',
    );
  b.writeln('\n## 성격\n');
  for (final p in people) {
    final d = (p['design'] as Map?) ?? {};
    b.writeln(
      '- **${p['name']}** (`${p['id']}`): ${p['voice']} “${p['line']}” · ${p['focusStat']} 재능 +${p['focusBonus']} · frame ${p['portraitFrame']} · `${p['portraitAsset']}` · ${d['palette']} / ${d['motif']}',
    );
  }
  b.writeln('\n## 캐릭터 일러스트 설계\n');
  b.writeln(
    '도감의 20명은 `characterArchive`의 PNG sheetIndex와 일러스트 방향·실루엣·시그니처 동작·5종 감정 키를 같은 SSOT에서 읽는다.',
  );
  for (final character in characterArchive) {
    final art = (character['illustration'] ?? '미정').toString();
    b.writeln(
      '- **${character['name']}** (`${character['id']}`): $art · 실루엣 `${character['silhouette'] ?? '미정'}` · 동작 `${character['gesture'] ?? '미정'}` · frame ${character['sheetIndex']}',
    );
  }
  b.writeln('\n## 동료\n');
  for (final c in companions)
    b.writeln(
      '- **${c['name']}** (`${c['id']}`): ${c['role']} · ${c['personality']} · frame ${c['portraitFrame']} · 유대 ${c['bondThreshold']}에서 에필로그 · “${c['greeting']}”',
    );
  b.writeln('\n## 성격 × 동료 공명\n');
  b.writeln(
    '성격과 동료의 3×3 matrix는 선택이 승인될 때 같은 성격 결에 해당하는 동료 유대에 +1을 적용한다. 이 보너스는 `GameWorld` resonance event와 엔딩 route set으로 재생된다.',
  );
  for (final route in personalityCompanionRoutes)
    b.writeln(
      '- `${route['id']}` · ${route['matched'] == true ? '공명 +${route['bondBonus']}' : '서로 다른 결 · 기본 유대'} · `${route['evidence']}`',
    );
  b.writeln('\n## 회차 계승 프로필\n');
  for (final p in legacyProfiles)
    b.writeln(
      '- **${p['title']}** (`${p['id']}`): 엔딩 ${(p['endingIds'] as List? ?? const []).join(', ')} · target `${p['targetEndingId']}` · ${p['stat']} 시작 보너스 +${p['bonus']} · `${p['titleKey']}`',
    );
  b.writeln('\n## 활동\n');
  for (final a in acts)
    b.writeln('- **${a['label']}** (`${a['id']}`): ${a['hint']}');
  b.writeln('\n## 계절 목표\n');
  for (final m in milestones)
    b.writeln(
      '- **${m['title']}** (`${m['id']}`): ${m['week']}주차 · ${m['stat']} ≥ ${m['min']} · 성공 보상 은화 ${m['coins']} · “${m['pass']}” / “${m['fail']}”',
    );
  b.writeln('\n## 사건\n');
  for (final e in events) {
    b.writeln('### ${e['week']}주차 · ${e['title']}\n\n${e['body']}');
    for (final c in (e['choices'] as List))
      b.writeln(
        '- ${c['label']}: ${c['stat']} +${c['delta']}, 은화 ${c['coins']}, ${c['bondId']} 유대 +${c['bondDelta']}${c['requiresStat'] == null ? '' : ', 조건 ${c['requiresStat']} ≥ ${c['requiresMin']}'}${c['requiresBondId'] == null ? '' : ', 관계 ${c['requiresBondId']} 유대 ≥ ${c['requiresBondMin']}'}${c['requiresFlag'] == null ? '' : ', 기억 ${c['requiresFlag']} 필요'}${c['setsFlag'] == null ? '' : ', 기억 ${c['setsFlag']} 기록'} · “${c['line']}”',
      );
  }
  b.writeln('\n## 사이드 장면·활동 미니 이벤트·동료 독립 장면\n');
  b.writeln(
    '본편 ${events.length}개와 사이드 장면 ${sideScenes.length}개를 합쳐 ${events.length + sideScenes.length}개의 authored scene을 보유한다. 사이드 장면은 본편 주차를 덮어쓰지 않고 독립 선택·기억 trace로 연결된다.',
  );
  for (final scene in sideScenes) {
    b.writeln(
      '- **${scene['title']}** (`${scene['id']}`) · ${scene['locationId']} · ${scene['sceneType']} / `${scene['mechanic']}` · ${scene['prompt']} · ${scene['consequence']}',
    );
  }
  b.writeln('\n활동 미니 이벤트 ${activityScenes.length}개:');
  for (final scene in activityScenes)
    b.writeln(
      '- **${scene['title']}** (`${scene['activityId']}`): ${scene['moment']} · “${scene['line']}”',
    );
  b.writeln('\n동료 독립 장면 ${companionScenes.length}개:');
  for (final scene in companionScenes)
    b.writeln(
      '- **${scene['title']}** (`${scene['companionId']}`): ${scene['body']} · “${scene['line']}”',
    );
  b.writeln('\n엔딩 변형 ${endingVariants.length}개:');
  for (final variant in endingVariants)
    b.writeln(
      '- **${variant['title']}** (`${variant['coreEndingId']}.${variant['variant']}`): ${variant['body']}',
    );
  b.writeln('\n## 엔딩\n');
  for (final e in endings)
    b.writeln(
      '- **${e['title']}** (`${e['id']}`): ${e['stat']} ≥ ${e['min']}${(e['requiresMilestones'] as List? ?? []).isEmpty ? '' : ' · 목표 ${((e['requiresMilestones'] as List).join(', '))}'} · ${e['body']}',
    );
  return b.toString();
}

String renderMetrics(Map<String, dynamic> s, String hash) {
  final acts = (s['activities'] as List).length,
      people = (s['personalities'] as List).length,
      characterArchive = (s['characterArchive'] as List? ?? const []).length,
      characterArtContracts = (s['characterArchive'] as List? ?? const [])
          .where(
            (entry) =>
                entry is Map &&
                entry['illustration'] != null &&
                entry['emotionNotes'] is List &&
                (entry['emotionNotes'] as List).length == 5,
          )
          .length,
      companions = (s['companions'] as List? ?? []).length,
      legacyProfiles = (s['legacyProfiles'] as List? ?? []).length,
      milestones = (s['milestones'] as List? ?? []).length,
      events = (s['events'] as List).cast<Map<String, dynamic>>(),
      sideScenes = (s['sideScenes'] as List? ?? const []).length,
      companionScenes = (s['companionScenes'] as List? ?? const []).length,
      activityScenes = (s['activityScenes'] as List? ?? const []).length,
      endingVariants = (s['endingVariants'] as List? ?? const []).length,
      eventStormNodes =
          events.length +
          sideScenes +
          companionScenes +
          activityScenes +
          endingVariants +
          (s['progression'] as List? ?? const []).length,
      endings = (s['endings'] as List).length,
      choices = events.fold<int>(
        0,
        (sum, e) => sum + (e['choices'] as List).length,
      ),
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
      scenarioVariants = (s['scenarioVariantBudget'] as Map? ?? {}),
      gameplay = (s['gameplayKpis'] as Map? ?? {}),
      renderQuality = (s['renderQualityKpis'] as Map? ?? {}),
      endingDesign = (s['endingDesign'] as Map? ?? {}),
      personalityCompanionRoutes =
          (s['personalityCompanionRoutes'] as List? ?? const [])
              .cast<Map<String, dynamic>>(),
      personalityCompanionMatches = personalityCompanionRoutes
          .where((route) => route['matched'] == true)
          .length,
      fateThreads = (s['fateThreads'] as List? ?? []).length,
      companionQuests = (s['companionQuests'] as List? ?? []).length,
      companionQuestStages = (s['companionQuests'] as List? ?? []).fold<int>(
        0,
        (sum, quest) =>
            sum + ((quest as Map)['stages'] as List? ?? const []).length,
      ),
      campaignWeeks =
          (s['campaignWeeks'] as int?) ?? ((s['endingWeek'] as int) - 1),
      ranges = (s['progression'] as List? ?? const [])
          .map((chapter) => '${chapter['weekStart']}–${chapter['weekEnd']}주')
          .join(' / ');
  final b = StringBuffer(
    '<!-- generated: tool/generate_ssot_docs.dart -->\n<!-- ssot-sha256: $hash -->\n<!-- source-ref: story/story.jsonl#root -->\n\n# ${s['title']} · SSOT 자동 품질 지표\n\n',
  );
  b.writeln(
    '이 문서는 `story/story.jsonl`에서 자동 생성된다. 코드·Golden·CI의 수치가 SSOT 변경과 함께 갱신되는지 pre-commit에서 확인한다.\n',
  );
  b.writeln('| 항목 | 현재 | 산출 기준 |\n| --- | ---: | --- |');
  b.writeln(
    '| 캠페인 길이 | ${campaignWeeks}주 + terminal week | `campaignWeeks`, `endingWeek` |',
  );
  b.writeln(
    '| 최소 플레이타임 | ${budget['minimumMinutes']}분 | `contentBudget.minimumMinutes` |',
  );
  b.writeln(
    '| 1회차 추정 | ${budget['estimatedFirstPlaythroughMinutes']}분 | `contentBudget.estimatedFirstPlaythroughMinutes` |',
  );
  b.writeln(
    '| 시나리오 경우의 수 | ${scenarioVariants['verifiedReachableCases']}개 검증 / ${scenarioVariants['minimumCases']}개 최소 | `scenarioVariantBudget` · CI branch-vector enumeration |',
  );
  b.writeln(
    '| 전체 route input | ${scenarioVariants['routeInputCases']}개 | 활동 × 성격 × 계승 컨텍스트 × authored branch vector |',
  );
  b.writeln(
    '| 엔딩 route card | ${endingDesign['maximumTerminalRouteCards']}개까지 | 핵심 엔딩 × 동료 route set |',
  );
  b.writeln(
    '| 나비효과 기록 | $fateThreads | `fateThreads.length` · authored memory flag 기반 |',
  );
  b.writeln(
    '| 동료 퀘스트 | $companionQuests개 / $companionQuestStages stages | `companionQuests` · 동료별 3단계 |',
  );
  b.writeln(
    '| 시스템 판정 | ${(s['decisionSystem'] as Map?)?['id'] ?? 'none'} | SSOT `decisionSystem` · fail-closed receipt |',
  );
  b.writeln(
    '| 렌더러 결정 | `${(s['engineDecision'] as Map?)?['selectedOption'] ?? 'none'}` | SSOT `engineDecision` · Golden/WASM 적합도 계약 |',
  );
  b.writeln('| 활동 | $acts | `activities.length` |');
  b.writeln('| 성격 | $people | `personalities.length` |');
  b.writeln(
    '| 성격 × 동료 공명 | ${personalityCompanionRoutes.length} ($personalityCompanionMatches matched) | `personalityCompanionRoutes` · matching choice bond +1 |',
  );
  b.writeln(
    '| 캐릭터 아카이브 | $characterArchive | `characterArchive.length` · PNG sheetIndex |',
  );
  b.writeln(
    '| 캐릭터 아트 계약 | $characterArtContracts/$characterArchive | illustration·silhouette·gesture·5 emotion notes |',
  );
  b.writeln('| 동료 | $companions | `companions.length` |');
  b.writeln('| 회차 계승 프로필 | $legacyProfiles | `legacyProfiles.length` |');
  b.writeln('| 계절 목표 | $milestones | `milestones.length` |');
  b.writeln('| 사건 | ${events.length} | `events.length` |');
  b.writeln(
    '| 전체 authored scene | ${events.length + sideScenes} | `events.length + sideScenes.length` |',
  );
  b.writeln(
    '| 사이드 장면 | $sideScenes | `sideScenes.length` · 탐험/위기/자원/미니게임/동료 조합 |',
  );
  b.writeln(
    '| 활동 미니 이벤트 | $activityScenes | `activityScenes.length` · 활동별 2개 |',
  );
  b.writeln(
    '| 동료 독립 장면 | $companionScenes | `companionScenes.length` · 3명×6개 |',
  );
  b.writeln(
    '| 엔딩 변형 | $endingVariants | `endingVariants.length` · 핵심 엔딩별 실패/중립/관계 |',
  );
  b.writeln(
    '| 이벤트 스토밍 노드 | $eventStormNodes | 본편·사이드·동료·활동·엔딩 변형·막 결산을 합친 생성 원장 |',
  );
  b.writeln('| 사건 선택 | $choices | 모든 사건 choices 합계 |');
  b.writeln(
    '| 교환 선택 | ${gameplay['current']['tradeoffChoices']}/${gameplay['current']['authoredChoices']} (${gameplay['current']['tradeoffRate']}) | `gameplayKpis.current.tradeoffRate` · 양의 축과 음의 축 동시 보유 |',
  );
  b.writeln(
    '| 시스템 판정 영수증 Golden | ${gameplay['current']['systemDecisionReceiptGolden']} | `gameplayKpis.current.systemDecisionReceiptGolden` · `test/goldens/system-receipt.png` 승인·거절·hash 표면 |',
  );
  b.writeln(
    '| Canvas Golden diff 허용오차 | ${renderQuality['current']['goldenTolerance'] * 100}% | `renderQualityKpis.current.goldenTolerance` · `test/golden_tolerance_test.dart` 경계/초과/비유한값 판정 |',
  );
  b.writeln('| 엔딩 | $endings | `endings.length` |');
  b.writeln('| Canvas Golden | $goldens | `test/goldens/*.png` |');
  b.writeln(
    '| 코드 ref | ${(s['codeRefs'] as List).length} | `codeRefs.length` |',
  );
  b.writeln(
    '| 이미지 ref | ${(s['assetRefs'] as List).length} | `assetRefs.length` |',
  );
  b.writeln(
    '| 폰트 ref | ${(s['fontRefs'] as List? ?? []).length} | `fontRefs.length` |',
  );
  b.writeln(
    '| 대사 locale | ${(s['localeRefs'] as List? ?? []).length} | `localeRefs.length` |',
  );
  b.writeln('| 스토리 막 | $progression | `progression.length` · $ranges |');
  b.writeln(
    '| 막 계약 | $chapterContracts/$progression | 각 막의 `contract` 공개·압력·선택·결산 선언 |',
  );
  b.writeln(
    '| 시나리오 완전성 차원 | ${(scenario['dimensions'] as List? ?? []).length} | `scenarioCompleteness.dimensions.length` |',
  );
  b.writeln(
    '| locale 최소 키 | ${dialogue['minimumLocaleKeys']} | `dialogueMetrics.minimumLocaleKeys` |',
  );
  b.writeln(
    '| 캠페인 최소 대사 줄 | ${dialogue['minimumVisibleDialogueLines']} | ${campaignWeeks}주 authored 사건 선택 노출 기준 |',
  );
  b.writeln(
    '| 캠페인 최소 서사 단위 | ${dialogue['minimumVisibleNarrativeUnits']} | 성격·사건 제목/본문·선택·엔딩 |',
  );
  b.writeln(
    '\n## 폐쇄루프 연결\n\nSSOT → GameWorld 전이 → Canvas/Golden → 저장·replay → benchmark → 같은 SSOT로 재검증. 기계 판정 기준은 [`docs/trilemma-contract.jsonl`](trilemma-contract.jsonl), 상세 설계는 [`docs/trilemma.md`](trilemma.md), 전체 지표는 [`docs/game-completeness.md`](game-completeness.md)에서 확인한다.',
  );
  return b.toString();
}

void main(List<String> args) {
  final input = 'story/story.jsonl',
      hash = sha(input),
      source = decodeJsonl(File(input).readAsStringSync()),
      outputs = {
        'docs/story-ssot.md': render(source, hash),
        'docs/ssot-metrics.md': renderMetrics(source, hash),
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
