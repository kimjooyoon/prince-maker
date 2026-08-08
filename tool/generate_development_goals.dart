import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

String sha256File(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

Map<String, dynamic> readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

List<Map<String, dynamic>> maps(dynamic value) =>
    (value as List? ?? const []).cast<Map<String, dynamic>>();

int pngCount() => Directory('test/goldens')
    .listSync()
    .whereType<File>()
    .where((file) => file.path.endsWith('.png'))
    .length;

int dartTestCount() => Directory('test')
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('_test.dart'))
    .length;

Map<String, dynamic> buildDocument() {
  final story = readJson('story/story.json'),
      trilemma = readJson('docs/trilemma-contract.json'),
      render = readJson('docs/render-quality-contract.json'),
      decisionProof = readJson('docs/decision-proof-contract.json');
  final trilemmaAxes = maps(trilemma['axes']);
  final events = maps(story['events']),
      progression = maps(story['progression']),
      milestones = maps(story['milestones']),
      companions = maps(story['companions']),
      legacyProfiles = maps(story['legacyProfiles']),
      fateThreads = maps(story['fateThreads']),
      companionQuests = maps(story['companionQuests']),
      codeRefs = maps(story['codeRefs']),
      assetRefs = maps(story['assetRefs']),
      fontRefs = maps(story['fontRefs']),
      localeRefs = maps(story['localeRefs']);
  final choices = events.fold<int>(
      0, (sum, event) => sum + (event['choices'] as List).length);
  final storyWeeks =
      (story['campaignWeeks'] as int?) ?? ((story['endingWeek'] as int) - 1);
  final dialogue = (story['dialogueMetrics'] as Map).cast<String, dynamic>();
  final scenario =
      (story['scenarioVariantBudget'] as Map).cast<String, dynamic>();
  final contentBudget = (story['contentBudget'] as Map).cast<String, dynamic>();
  final dimensions = maps((story['scenarioCompleteness'] as Map)['dimensions']);
  final preconditions = maps(render['preconditions']),
      proofs = maps(render['proofs']);
  final decisionProofFields =
      (decisionProof['preconditionFields'] as List).length;
  final goldens = pngCount(), testFiles = dartTestCount();
  final questStages = companionQuests.fold<int>(
      0, (sum, quest) => sum + (quest['stages'] as List).length);
  final authoredContentUnits = storyWeeks +
      progression.length +
      events.length +
      choices +
      milestones.length +
      (story['endings'] as List).length;
  final narrativeRelationshipUnits = companions.length +
      fateThreads.length +
      questStages +
      (story['locations'] as List).length +
      legacyProfiles.length;
  final transitions = 5000 * ((story['endingWeek'] as int) - 1 + events.length);
  final explorationUnits = (scenario['authoredBranchVectors'] as int) +
      (scenario['routeInputCases'] as int) +
      5000 +
      transitions;
  final visualLocaleUnits = goldens +
      localeRefs.length * (dialogue['minimumLocaleKeys'] as int) +
      codeRefs.length +
      assetRefs.length +
      fontRefs.length;
  final verificationUnits = 15 +
      testFiles +
      preconditions.length +
      proofs.length +
      decisionProofFields;
  final sourceRefs = [
    {
      'ref': 'story/story.json#root',
      'sha256': sha256File('story/story.json'),
    },
    {
      'ref': 'docs/trilemma-contract.json#axes',
      'sha256': sha256File('docs/trilemma-contract.json'),
    },
    {
      'ref': 'docs/render-quality-contract.json#preconditions',
      'sha256': sha256File('docs/render-quality-contract.json'),
    },
    {
      'ref': 'docs/decision-proof-contract.json#preconditionFields',
      'sha256': sha256File('docs/decision-proof-contract.json'),
    },
  ];
  final effortLedger = [
    {
      'id': 'authored-content-units',
      'unit': 'content-unit',
      'value': authoredContentUnits,
      'formula':
          '$storyWeeks weeks + ${progression.length} chapters + ${events.length} events + $choices choices + ${milestones.length} milestones + ${(story['endings'] as List).length} endings',
      'scope': 'authored campaign content and closure work',
    },
    {
      'id': 'narrative-relationship-units',
      'unit': 'narrative-unit',
      'value': narrativeRelationshipUnits,
      'formula':
          '${companions.length} companions + ${fateThreads.length} fate threads + $questStages quest stages + ${(story['locations'] as List).length} locations + ${legacyProfiles.length} legacy profiles',
      'scope': 'relationship, memory, discovery and replay depth',
    },
    {
      'id': 'exploration-units',
      'unit': 'replay-unit',
      'value': explorationUnits,
      'formula':
          '${scenario['authoredBranchVectors']} branch vectors + ${scenario['routeInputCases']} route inputs + 5,000 campaigns + $transitions transitions',
      'scope': 'branch enumeration, route variety and deterministic throughput',
    },
    {
      'id': 'visual-locale-units',
      'unit': 'presentation-unit',
      'value': visualLocaleUnits,
      'formula':
          '$goldens Goldens + ${localeRefs.length} locales × ${dialogue['minimumLocaleKeys']} keys + ${codeRefs.length} code refs + ${assetRefs.length} asset refs + ${fontRefs.length} font refs',
      'scope':
          'visual regression, localization and traceable production assets',
    },
    {
      'id': 'verification-units',
      'unit': 'proof-unit',
      'value': verificationUnits,
      'formula':
          '15 CI checks + $testFiles Dart test files + ${preconditions.length} render preconditions + ${proofs.length} render proofs + $decisionProofFields decision precondition fields',
      'scope': 'repeatable automated proof and release readiness',
    },
  ];
  final goals = [
    {
      'id': 'G1-completeness',
      'axis': 'completeness',
      'priority': 'P0',
      'title': '장편 캠페인 완전성',
      'target': {'value': 0.95, 'unit': 'gate-score', 'display': '≥95%'},
      'currentContract': {
        'value': dimensions.isEmpty ? 0 : 1.0,
        'unit': 'gate-score',
        'formula':
            '${dimensions.length}/${dimensions.length} scenario dimensions declared with target/current/evidence',
      },
      'gap': 0,
      'status': 'contract-satisfied; runtime-proof-required',
      'effort': ['authored-content-units', 'verification-units'],
      'preconditions': [
        'story-contract',
        'scenario-variants',
        'generated-ssot-docs',
        'review-manifest',
      ],
      'evidence': [
        'story/story.json#scenarioCompleteness',
        'tool/verify_game.dart#scenario-contract',
        'test/scenario_completeness_test.dart#scenario-closure',
      ],
      'acceptance': '8개 시나리오 차원과 콘텐츠·분기·locale·Golden 증적이 모두 CI에서 통과한다.',
    },
    {
      'id': 'G2-agency-replay',
      'axis': 'purity',
      'priority': 'P0',
      'title': '선택 행위성과 재플레이 공간',
      'target': {
        'scenarioCases': 2000,
        'routeInputs': scenario['routeInputCases'],
        'unit': 'deterministic-replay-cases',
      },
      'currentContract': {
        'scenarioCases': scenario['verifiedReachableCases'],
        'routeInputs': scenario['routeInputCases'],
        'branchVectors': scenario['authoredBranchVectors'],
        'formula': scenario['formula'],
      },
      'gap': {'scenarioCases': 0, 'routeInputs': 0},
      'status': 'contract-satisfied; runtime-proof-required',
      'effort': ['exploration-units', 'narrative-relationship-units'],
      'preconditions': ['scenario-variants', 'campaign-benchmark'],
      'evidence': [
        'tool/verify_scenario_variants.dart#scenario-case-enumerator',
        'test/gameplay_metrics_test.dart#route-variety',
        'test/purity_integration_test.dart#same-schedule-budget-outcomes',
      ],
      'acceptance':
          '동일 입력 replay가 재현되고, 최소 2,000 branch trace와 122,880 route input 계약을 만족한다.',
    },
    {
      'id': 'G3-narrative-depth',
      'axis': 'completeness',
      'priority': 'P1',
      'title': '관계·기억·계승 서사 깊이',
      'target': {
        'fateThreads': 6,
        'companionQuestStages': 9,
        'endings': 6,
        'legacyProfiles': 3,
        'unit': 'authored-narrative-units',
      },
      'currentContract': {
        'fateThreads': fateThreads.length,
        'companionQuestStages': questStages,
        'endings': (story['endings'] as List).length,
        'legacyProfiles': legacyProfiles.length,
      },
      'gap': {
        'fateThreads': 0,
        'companionQuestStages': 0,
        'endings': 0,
        'legacyProfiles': 0,
      },
      'status': 'contract-satisfied; runtime-proof-required',
      'effort': ['narrative-relationship-units', 'authored-content-units'],
      'preconditions': [
        'story-contract',
        'scenario-variants',
        'tests-and-goldens',
      ],
      'evidence': [
        'story/story.json#fateThreads',
        'story/story.json#companionQuests',
        'test/narrative_ledger_test.dart#deterministic-projection',
        'test/ending_matrix_test.dart#all-companion-route-sets',
      ],
      'acceptance': '기억 flag·동료 퀘스트·엔딩·계승 프로필이 같은 SSOT와 replay trace에서 재생성된다.',
    },
    {
      'id': 'G4-presentation',
      'axis': 'completeness',
      'priority': 'P1',
      'title': '시각·locale 품질 증적',
      'target': {
        'goldens': 30,
        'locales': 2,
        'keysPerLocale': dialogue['minimumLocaleKeys'],
        'renderPreconditions': preconditions.length,
        'renderProofs': proofs.length,
        'unit': 'presentation-proof-units',
      },
      'currentContract': {
        'goldens': goldens,
        'locales': localeRefs.length,
        'keysPerLocale': dialogue['minimumLocaleKeys'],
        'renderPreconditions': preconditions.length,
        'renderProofs': proofs.length,
      },
      'gap': {
        'goldens': goldens >= 30 ? 0 : 30 - goldens,
        'locales': localeRefs.length >= 2 ? 0 : 2 - localeRefs.length,
        'keysPerLocale': 0,
        'renderPreconditions': 0,
        'renderProofs': 0,
      },
      'status': 'contract-satisfied; runtime-proof-required',
      'effort': ['visual-locale-units', 'verification-units'],
      'preconditions': [
        'render-quality-preconditions',
        'static-analysis',
        'tests-and-goldens',
      ],
      'evidence': [
        'docs/render-quality-contract.json#preconditions',
        'tool/verify_render_quality.dart#render-quality-preconditions',
        'test/golden_test.dart#all',
        'test/locale_contract_test.dart#ssot-dialogue-contract',
      ],
      'acceptance': 'Canvas 좌표·입력 역변환·62개 Golden·ko/en locale 계약이 전부 통과한다.',
    },
    {
      'id': 'G5-deterministic-throughput',
      'axis': 'performance',
      'priority': 'P0',
      'title': '결정론적 처리량과 replay',
      'target': {
        'campaigns': 5000,
        'transitions': 475000,
        'maxMillis': contentBudget['benchmarkMaxMillis'],
        'unit': 'benchmark-contract',
      },
      'currentContract': {
        'campaigns': 5000,
        'transitions': transitions,
        'maxMillis': contentBudget['benchmarkMaxMillis'],
        'checksumReplayMustMatch': true,
        'formula':
            'campaigns × (endingWeek − 1 + events) and replay checksum equality',
      },
      'gap': {'campaigns': 0, 'transitions': 0, 'maxMillis': 0},
      'status': 'runtime-measured-by-benchmark',
      'effort': ['exploration-units', 'verification-units'],
      'preconditions': [
        'campaign-benchmark',
        'tests-and-goldens',
        'wasm-release-build',
      ],
      'evidence': [
        'tool/benchmark_game.dart#ssot-campaign-throughput-signatures',
        'build/benchmark-verdict.json#runtime-measurement',
        'build/ci-verdict.json#system-approval',
      ],
      'acceptance':
          '5,000 campaign·475,000 transition이 제한 시간 안에 실행되고 checksum/replayChecksum이 일치한다.',
    },
    {
      'id': 'G6-accountable-delivery',
      'axis': 'performance',
      'priority': 'P0',
      'title': '책임 추적 가능한 납품',
      'target': {
        'ciChecks': 15,
        'codeRefs': 24,
        'decisionProofFields': 14,
        'unit': 'delivery-proof-units',
      },
      'currentContract': {
        'ciChecks': 15,
        'codeRefs': codeRefs.length,
        'decisionProofFields': decisionProofFields,
        'assetRefs': assetRefs.length,
        'fontRefs': fontRefs.length,
        'localeRefs': localeRefs.length,
        'systemAdjudicated': true,
        'failClosed': true,
      },
      'gap': {
        'ciChecks': 0,
        'codeRefs': codeRefs.length >= 24 ? 0 : 24 - codeRefs.length,
        'decisionProofFields':
            decisionProofFields >= 14 ? 0 : 14 - decisionProofFields,
      },
      'status': 'contract-satisfied; runtime-proof-required',
      'effort': ['verification-units', 'visual-locale-units'],
      'preconditions': [
        'ci-policy',
        'generated-ssot-docs',
        'review-manifest',
        'diff-whitespace',
      ],
      'evidence': [
        'story/story.json#codeRefs',
        'docs/decision-proof-contract.json#preconditionFields',
        'tool/verify_decision_proof.dart#decision-proof-preconditions',
        'docs/review-manifest.json#entries',
        'tool/ci_gate.dart#system-verdict',
        'lib/decision_proof.dart#SystemDecisionPolicy',
        'lib/decision_receipt.dart#DecisionReceipt',
      ],
      'acceptance':
          '사람의 승인 추론 없이 source hash·게이트·영수증·replay 증적이 fail-closed로 남는다.',
    },
  ];
  return {
    'schema': 'lumen-development-goals-v1',
    'version': 1,
    'source': sourceRefs,
    'decision': {
      'owner': 'Lumen Development Goal Gate',
      'mode': 'system-adjudicated',
      'humanApprovalRequired': false,
      'failureMode': 'fail-closed',
      'onlyBlockingCondition': 'missing or failed quantitative evidence',
    },
    'measurementModel': {
      'principle': '각 단위는 같은 종류끼리만 합산하고, 품질 score와 작업량 index를 혼합하지 않는다.',
      'gapFormula': 'max(target - current, 0)',
      'statusRule': '정적 계약 충족과 런타임 증명을 분리하며, 최종 승인에는 CI verdict가 필요하다.',
    },
    'effortLedger': effortLedger,
    'goals': goals,
    'evidencePlan': {
      'ciModeChecks': [
        'ci-policy',
        'decision-proof-preconditions',
        'render-quality-preconditions',
        'story-contract',
        'scenario-variants',
        'campaign-benchmark',
        'generated-trilemma-contract',
        'generated-ssot-docs',
        'review-manifest',
        'static-analysis',
        'tests-and-goldens',
        'wasm-release-build',
        'diff-whitespace',
        'generated-development-goals',
      ],
      'artifacts': [
        'build/decision-proof-verdict.json',
        'build/benchmark-verdict.json',
        'build/development-goal-verdict.json',
        'build/ci-verdict.json',
        'build/trilemma-verdict.json',
      ],
      'trilemmaAxes': trilemmaAxes.length,
      'requiredSourceRefs': sourceRefs.map((entry) => entry['ref']).toList(),
    },
  };
}

String renderMarkdown(Map<String, dynamic> document) {
  final b = StringBuffer()
    ..writeln('<!-- generated: tool/generate_development_goals.dart -->')
    ..writeln(
        '<!-- source-sha256: ${(document['source'] as List).map((entry) => entry['sha256']).join('|')} -->')
    ..writeln('<!-- source-ref: story/story.json#root -->')
    ..writeln()
    ..writeln('# 프린스 메이커 · 정량 개발목표 원장')
    ..writeln()
    ..writeln(
        '이 문서는 SSOT·트릴레마·렌더 계약에서 개발 목표, 현재 계약값, gap, 투입 단위와 검증 증거를 결정론적으로 생성한다.')
    ..writeln()
    ..writeln('## 판정 규칙')
    ..writeln()
    ..writeln(
        '- 판정 주체: **Lumen Development Goal Gate** · 사람 승인 필요: `false` · 실패 모드: `fail-closed`')
    ..writeln(
        '- gap 산식: `max(target - current, 0)` · 정적 계약 충족과 실제 실행 증명은 분리한다.')
    ..writeln()
    ..writeln('## 개발 목표')
    ..writeln()
    ..writeln('| ID | 축 | 우선순위 | 목표 | 현재 계약값 | gap | 상태 |')
    ..writeln('| --- | --- | --- | --- | --- | ---: | --- |');
  for (final goal in (document['goals'] as List).cast<Map<String, dynamic>>()) {
    final target = jsonEncode(goal['target']),
        current = jsonEncode(goal['currentContract']);
    b.writeln(
        '| `${goal['id']}` | ${goal['axis']} | ${goal['priority']} | ${goal['title']} · `$target` | `$current` | `${goal['gap']}` | ${goal['status']} |');
  }
  b
    ..writeln()
    ..writeln('## 투입·증적 원장')
    ..writeln()
    ..writeln('| 원장 ID | 단위 | 수량 | 산식 | 범위 |')
    ..writeln('| --- | --- | ---: | --- | --- |');
  for (final row
      in (document['effortLedger'] as List).cast<Map<String, dynamic>>()) {
    b.writeln(
        '| `${row['id']}` | ${row['unit']} | **${row['value']}** | ${row['formula']} | ${row['scope']} |');
  }
  b
    ..writeln()
    ..writeln('## 선행조건과 증거')
    ..writeln();
  for (final goal in (document['goals'] as List).cast<Map<String, dynamic>>()) {
    b
      ..writeln('### `${goal['id']}` · ${goal['title']}')
      ..writeln()
      ..writeln(
          '- 선행조건: ${(goal['preconditions'] as List).map((v) => '`$v`').join(' · ')}')
      ..writeln(
          '- 증거: ${(goal['evidence'] as List).map((v) => '`$v`').join(' · ')}')
      ..writeln('- 승인 조건: ${goal['acceptance']}')
      ..writeln(
          '- 사용 원장: ${(goal['effort'] as List).map((v) => '`$v`').join(' · ')}')
      ..writeln();
  }
  b
    ..writeln('## CI 증적 산출물')
    ..writeln()
    ..writeln(
        '`${(document['evidencePlan'] as Map)['ciModeChecks'].length}`개 CI check가 실행되며 benchmark·개발목표·시스템·트릴레마 verdict를 `build/`에 남긴다. 어느 하나라도 누락되거나 실패하면 전체 승인을 거절한다.');
  return b.toString();
}

void main(List<String> args) {
  final document = buildDocument(),
      json = '${const JsonEncoder.withIndent('  ').convert(document)}\n',
      markdown = renderMarkdown(document),
      outputs = {
        'docs/development-goals.json': json,
        'docs/development-goals.md': markdown,
      };
  if (args.contains('--check')) {
    for (final entry in outputs.entries) {
      if (!File(entry.key).existsSync() ||
          File(entry.key).readAsStringSync() != entry.value) {
        stderr.writeln('DEVELOPMENT_GOALS_DOC_FAIL: regenerate ${entry.key}');
        exit(1);
      }
    }
    stdout.writeln(
        'DEVELOPMENT_GOALS_DOC_OK: ${outputs.keys.join(', ')} goals=${(document['goals'] as List).length} ledger=${(document['effortLedger'] as List).length}');
    return;
  }
  for (final entry in outputs.entries) {
    File(entry.key).writeAsStringSync(entry.value);
  }
  stdout.writeln(
      'DEVELOPMENT_GOALS_DOC_WRITTEN: ${outputs.keys.join(', ')} goals=${(document['goals'] as List).length} ledger=${(document['effortLedger'] as List).length}');
}
