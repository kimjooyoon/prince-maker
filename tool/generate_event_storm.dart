import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:prince_maker/jsonl.dart';

// event-storm-generator: deterministic Trigger → Command → Policy → Domain event → Feedback ledger.

String sha(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

List<Map<String, dynamic>> maps(dynamic value) => value is List
    ? value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList()
    : <Map<String, dynamic>>[];

Map<String, dynamic> mapValue(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<String> strings(dynamic value) => value is List
    ? value.map((item) => '$item').where((item) => item.isNotEmpty).toList()
    : <String>[];

String idOf(Map<String, dynamic> item) =>
    '${item['id'] ?? item['labelKey'] ?? item['titleKey']}';

Map<String, dynamic> gateFor(Map<String, dynamic> choice) {
  final gates = <Map<String, dynamic>>[];
  if (choice['requiresStat'] != null) {
    gates.add({
      'type': 'stat',
      'id': choice['requiresStat'],
      'minimum': choice['requiresMin'],
    });
  }
  if (choice['requiresBondId'] != null) {
    gates.add({
      'type': 'bond',
      'id': choice['requiresBondId'],
      'minimum': choice['requiresBondMin'],
    });
  }
  if (choice['requiresFlag'] != null) {
    gates.add({'type': 'memory-flag', 'id': choice['requiresFlag']});
  }
  return {'gates': gates, 'gated': gates.isNotEmpty};
}

Map<String, dynamic> choiceDomainEvent(Map<String, dynamic> choice) {
  final changes = <Map<String, dynamic>>[];
  final axes = <String>[];
  void addNumeric(String axis, dynamic value, String type) {
    if (value is! num || value == 0) return;
    axes.add(axis);
    changes.add({'type': type, 'axis': axis, 'delta': value});
  }

  final stat = choice['stat'];
  if (stat != null) addNumeric('stat:$stat', choice['delta'], 'stat-change');
  addNumeric('coins', choice['coins'], 'coin-change');
  final bond = choice['bondId'];
  if (bond != null) {
    addNumeric('bond:$bond', choice['bondDelta'], 'bond-change');
  }
  final rival = choice['rivalId'];
  if (rival != null) {
    addNumeric('rival:$rival', choice['rivalDelta'], 'rival-change');
  }
  if (choice['setsFlag'] != null) {
    axes.add('flag:${choice['setsFlag']}');
    changes
        .add({'type': 'memory-flag-set', 'axis': 'flag:${choice['setsFlag']}'});
  }
  if (choice['legacyBonuses'] != null) {
    axes.add('legacy-bonus');
    changes.add({'type': 'legacy-bonus-recorded', 'axis': 'legacy-bonus'});
  }
  final uniqueAxes = axes.toSet().toList();
  final gates = gateFor(choice);
  return {
    'sourceId': choice['labelKey'] ?? choice['label'],
    'command': choice['labelKey'] ?? choice['label'],
    'effects': changes,
    'axes': uniqueAxes,
    'policies': gates['gates'],
    'feedbackRef': choice['lineKey'] ?? choice['line'],
    'hasFeedback':
        choice['lineKey'] is String && '${choice['lineKey']}'.trim().isNotEmpty,
  };
}

Map<String, dynamic> choiceNode({
  required Map<String, dynamic> source,
  required int index,
  required String kind,
  required String context,
  required Map<String, dynamic> trigger,
  required String locationId,
  required String? mechanic,
}) {
  final choices = maps(source['choices']);
  final traces = <Map<String, dynamic>>[];
  for (final choice in choices) {
    final trace = choiceDomainEvent(choice);
    traces.add(trace);
  }
  final policies = <String, dynamic>{
    'choiceGates': traces
        .expand((trace) => (trace['policies'] as List).cast<dynamic>())
        .toList(),
    'requiresCompanions': strings(source['requiresCompanions']),
  };
  return {
    'id': '$context.${idOf(source)}',
    'sourceRef':
        'story/story.jsonl#${kind == 'main-event' ? 'events' : 'sideScenes'}[$index]',
    'kind': kind,
    'context': context,
    'trigger': trigger,
    'locationId': locationId,
    'mechanic': mechanic ?? kind,
    'participants': [
      if (source['speakerId'] != null) source['speakerId'],
      ...choices
          .map((choice) => choice['speakerId'])
          .where((speaker) => speaker != null)
          .toSet(),
    ],
    'commands': [
      for (var choiceIndex = 0; choiceIndex < choices.length; choiceIndex++)
        {
          'id': traces[choiceIndex]['command'],
          'label': choices[choiceIndex]['label'],
          'index': choiceIndex,
        }
    ],
    'domainEvents': traces,
    'policies': policies,
    'feedback': {
      'title': source['titleKey'],
      'body': source['bodyKey'],
      'prompt': source['promptKey'],
      'consequence': source['consequenceKey'],
      'choiceLines': traces.map((trace) => trace['feedbackRef']).toList(),
    },
  };
}

Map<String, dynamic> simpleNode({
  required String id,
  required String sourceRef,
  required String kind,
  required String context,
  required Map<String, dynamic> trigger,
  required String? locationId,
  required String mechanic,
  required List<String> participants,
  required Map<String, dynamic> command,
  required Map<String, dynamic> domainEvent,
  required Map<String, dynamic> policies,
  required Map<String, dynamic> feedback,
}) =>
    {
      'id': id,
      'sourceRef': sourceRef,
      'kind': kind,
      'context': context,
      'trigger': trigger,
      'locationId': locationId,
      'mechanic': mechanic,
      'participants': participants,
      'commands': [command],
      'domainEvents': [domainEvent],
      'policies': policies,
      'feedback': feedback,
    };

Map<String, dynamic> buildEventStorm(
    Map<String, dynamic> story, String sourceHash) {
  final events = maps(story['events']);
  final sideScenes = maps(story['sideScenes']);
  final companionScenes = maps(story['companionScenes']);
  final activityScenes = maps(story['activityScenes']);
  final endingVariants = maps(story['endingVariants']);
  final progression = maps(story['progression']);
  final choiceNodes = <Map<String, dynamic>>[
    for (var index = 0; index < events.length; index++)
      choiceNode(
        source: events[index],
        index: index,
        kind: 'main-event',
        context: 'event',
        trigger: {
          'week': events[index]['week'],
          'eventId': idOf(events[index])
        },
        locationId: '${events[index]['locationId']}',
        mechanic: 'campaign-choice',
      ),
    for (var index = 0; index < sideScenes.length; index++)
      choiceNode(
        source: sideScenes[index],
        index: index,
        kind: 'side-scene',
        context: 'sideScene',
        trigger: {
          'unlockWeek': sideScenes[index]['unlockWeek'],
          'sceneId': idOf(sideScenes[index])
        },
        locationId: '${sideScenes[index]['locationId']}',
        mechanic: '${sideScenes[index]['mechanic']}',
      ),
  ];

  final nodes = <Map<String, dynamic>>[...choiceNodes];
  for (var index = 0; index < companionScenes.length; index++) {
    final scene = companionScenes[index];
    nodes.add(simpleNode(
      id: 'companion.${idOf(scene)}',
      sourceRef: 'story/story.jsonl#companionScenes[$index]',
      kind: 'companion-scene',
      context: 'relationship',
      trigger: {'chapter': scene['chapter'], 'sceneId': idOf(scene)},
      locationId: null,
      mechanic: 'independent-relationship-scene',
      participants: ['${scene['companionId']}'],
      command: {
        'id': scene['promptKey'],
        'label': scene['prompt'],
        'index': 0,
      },
      domainEvent: {
        'type': 'relationship-scene-recorded',
        'companionId': scene['companionId'],
        'chapter': scene['chapter'],
      },
      policies: {
        'independent': true,
        'chapter': scene['chapter'],
      },
      feedback: {
        'title': scene['titleKey'],
        'body': scene['bodyKey'],
        'prompt': scene['promptKey'],
        'line': scene['lineKey'],
        'closing': scene['closingKey'],
      },
    ));
  }
  for (var index = 0; index < activityScenes.length; index++) {
    final scene = activityScenes[index];
    nodes.add(simpleNode(
      id: 'activity.${idOf(scene)}',
      sourceRef: 'story/story.jsonl#activityScenes[$index]',
      kind: 'activity-mini-event',
      context: 'activity',
      trigger: {'activityId': scene['activityId'], 'sceneId': idOf(scene)},
      locationId: null,
      mechanic: 'activity-reflection',
      participants: const [],
      command: {
        'id': scene['activityId'],
        'label': scene['moment'],
        'index': 0,
      },
      domainEvent: {
        'type': 'activity-mini-event-recorded',
        'activityId': scene['activityId'],
        'sceneId': idOf(scene),
      },
      policies: {'activityId': scene['activityId']},
      feedback: {
        'title': scene['titleKey'],
        'moment': scene['momentKey'],
        'line': scene['lineKey'],
      },
    ));
  }
  for (var index = 0; index < endingVariants.length; index++) {
    final variant = endingVariants[index];
    nodes.add(simpleNode(
      id: 'ending.${idOf(variant)}',
      sourceRef: 'story/story.jsonl#endingVariants[$index]',
      kind: 'ending-variant',
      context: 'ending',
      trigger: {
        'coreEndingId': variant['coreEndingId'],
        'variant': variant['variant'],
      },
      locationId: null,
      mechanic: 'terminal-route-card',
      participants: const [],
      command: {
        'id': '${variant['coreEndingId']}.${variant['variant']}',
        'label': variant['title'],
        'index': 0,
      },
      domainEvent: {
        'type': 'ending-variant-resolved',
        'coreEndingId': variant['coreEndingId'],
        'variant': variant['variant'],
      },
      policies: {
        'coreEndingId': variant['coreEndingId'],
        'variant': variant['variant'],
      },
      feedback: {
        'title': variant['titleKey'],
        'body': variant['bodyKey'],
      },
    ));
  }
  for (var index = 0; index < progression.length; index++) {
    final chapter = progression[index];
    final contract = mapValue(chapter['contract']);
    final relationship = mapValue(chapter['relationshipScene']);
    nodes.add(simpleNode(
      id: 'chapter.${idOf(chapter)}',
      sourceRef: 'story/story.jsonl#progression[$index]',
      kind: 'chapter-closure',
      context: 'closure',
      trigger: {
        'weekStart': chapter['weekStart'],
        'weekEnd': chapter['weekEnd'],
        'eventWeeks': chapter['eventWeeks'],
      },
      locationId: null,
      mechanic: 'chapter-contract-closure',
      participants: [
        if (relationship['speakerId'] != null) relationship['speakerId']
      ],
      command: {
        'id': contract['closureMilestone'],
        'label': chapter['payoff'],
        'index': 0,
      },
      domainEvent: {
        'type': 'chapter-closure-recorded',
        'chapterId': idOf(chapter),
        'milestoneId': chapter['milestoneId'],
      },
      policies: {
        'pressureAxes': contract['pressureAxes'],
        'choiceWeeks': contract['choiceWeeks'],
        'closureMilestone': contract['closureMilestone'],
      },
      feedback: {
        'title': chapter['titleKey'],
        'premise': chapter['premiseKey'],
        'payoff': chapter['payoffKey'],
        'relationshipTitle': relationship['titleKey'],
        'relationshipLine': relationship['lineKey'],
      },
    ));
  }

  final choiceTraces = choiceNodes
      .expand(
          (node) => (node['domainEvents'] as List).cast<Map<String, dynamic>>())
      .toList();
  final effectful =
      choiceTraces.where((trace) => (trace['axes'] as List).isNotEmpty).length;
  final feedback =
      choiceTraces.where((trace) => trace['hasFeedback'] == true).length;
  final gated = choiceTraces
      .where((trace) => (trace['policies'] as List).isNotEmpty)
      .length;
  final tradeoff = choiceTraces.where((trace) {
    final changes = (trace['effects'] as List).whereType<Map>();
    final positive = changes.any(
        (change) => change['delta'] is num && (change['delta'] as num) > 0);
    final negative = changes.any(
        (change) => change['delta'] is num && (change['delta'] as num) < 0);
    return positive && negative;
  }).length;
  final multiAxis =
      choiceTraces.where((trace) => (trace['axes'] as List).length >= 2).length;
  final divergent = choiceNodes.where((node) {
    final signatures = (node['domainEvents'] as List)
        .cast<Map<String, dynamic>>()
        .map((trace) => jsonEncode({
              'effects': trace['effects'],
              'flags': trace['axes'],
            }))
        .toSet();
    return signatures.length >= 2;
  }).length;
  final summary = {
    'nodeCount': nodes.length,
    'choiceCount': choiceTraces.length,
    'mainEvents': events.length,
    'sideScenes': sideScenes.length,
    'companionScenes': companionScenes.length,
    'activityScenes': activityScenes.length,
    'endingVariants': endingVariants.length,
    'chapterClosures': progression.length,
    'effectCoverage': effectful / choiceTraces.length,
    'feedbackCoverage': feedback / choiceTraces.length,
    'multiAxisChoices': multiAxis,
    'tradeoffChoices': tradeoff,
    'gatedChoices': gated,
    'divergentNodes': divergent,
    'divergenceRate': divergent / choiceNodes.length,
    'mechanics': sideScenes.map((scene) => scene['sceneType']).toSet().toList()
      ..sort(),
  };
  final decision = mapValue(story['decisionSystem']);
  return {
    'schema': 'lumen-event-storm-v1',
    'source': {'ref': 'story/story.jsonl#root', 'sha256': sourceHash},
    'responsibility': {
      'owner': decision['owner'],
      'mode': decision['mode'],
      'failureMode': decision['failureMode'],
      'humanApprovalRequired': decision['humanApprovalRequired'],
      'approvalEvidence': [
        'tool/verify_event_storm.dart#event-storm-gate',
        'tool/ci_gate.dart#system-verdict',
      ],
    },
    'loop': const [
      'trigger',
      'command',
      'policy',
      'domain-event',
      'feedback',
    ],
    'summary': summary,
    'nodes': nodes,
    'evidence': const [
      'tool/generate_event_storm.dart#event-storm-generator',
      'tool/verify_event_storm.dart#event-storm-gate',
      'test/event_storm_test.dart#event storm covers every authored unit',
      'story/story.jsonl#events',
      'story/story.jsonl#sideScenes',
      'story/story.jsonl#companionScenes',
      'story/story.jsonl#activityScenes',
      'story/story.jsonl#endingVariants',
      'story/story.jsonl#progression',
    ],
  };
}

String renderMarkdown(Map<String, dynamic> artifact) {
  final summary = mapValue(artifact['summary']);
  final nodes = maps(artifact['nodes']);
  final byKind = <String, List<Map<String, dynamic>>>{};
  for (final node in nodes) {
    byKind
        .putIfAbsent('${node['kind']}', () => <Map<String, dynamic>>[])
        .add(node);
  }
  final b = StringBuffer()
    ..writeln('<!-- generated: tool/generate_event_storm.dart -->')
    ..writeln(
        '<!-- source-sha256: ${mapValue(artifact['source'])['sha256']} -->')
    ..writeln('<!-- source-ref: story/story.jsonl#root -->')
    ..writeln()
    ..writeln('# Lumen Event Storm')
    ..writeln()
    ..writeln('모든 authored 단위를 시스템이 검토 가능한 사건 흐름으로 고정한 생성 원장이다.')
    ..writeln()
    ..writeln('`Trigger → Command → Policy → Domain event → Feedback`')
    ..writeln()
    ..writeln('| 지표 | 현재 | 증적 기준 |')
    ..writeln('| --- | ---: | --- |')
    ..writeln(
        '| 전체 노드 | ${summary['nodeCount']} | 47 본편 + 24 사이드 + 18 동료 + 10 활동 + 18 엔딩 변형 + 16 막 결산 |')
    ..writeln('| 선택 명령 | ${summary['choiceCount']} | 본편 94 + 사이드 72 |')
    ..writeln(
        '| 효과 연결률 | ${summary['effectCoverage']} | 모든 authored choice가 상태 축 또는 기억 flag를 기록 |')
    ..writeln(
        '| 피드백 연결률 | ${summary['feedbackCoverage']} | 모든 authored choice가 lineKey를 갖고 다음 화면에 반환 |')
    ..writeln(
        '| 다축 선택 | ${summary['multiAxisChoices']} | stat·coin·bond·flag 중 2축 이상 |')
    ..writeln(
        '| 교환 선택 | ${summary['tradeoffChoices']} | 양의 변화와 음의 변화를 동시에 보유 |')
    ..writeln(
        '| 조건부 선택 | ${summary['gatedChoices']} | stat·bond·memory 정책 gate |')
    ..writeln(
        '| 분기 노드 | ${summary['divergentNodes']} / ${summary['mainEvents'] + summary['sideScenes']} | 서로 다른 domain event signature |')
    ..writeln()
    ..writeln('## 책임 경계')
    ..writeln()
    ..writeln(
        '- 판정 주체: `${mapValue(artifact['responsibility'])['owner']}` / 모드 `${mapValue(artifact['responsibility'])['mode']}`')
    ..writeln(
        '- 실패 모드: `${mapValue(artifact['responsibility'])['failureMode']}` / 사람 승인 필요: `${mapValue(artifact['responsibility'])['humanApprovalRequired']}`')
    ..writeln('- 원장은 코드와 CI가 재생성·검증하며, source hash가 어긋나면 승인하지 않는다.')
    ..writeln()
    ..writeln('## 사건 경계별 원장 범위')
    ..writeln()
    ..writeln('| kind | count | representative source |')
    ..writeln('| --- | ---: | --- |');
  for (final kind in [
    'main-event',
    'side-scene',
    'companion-scene',
    'activity-mini-event',
    'ending-variant',
    'chapter-closure',
  ]) {
    final entries = byKind[kind] ?? const <Map<String, dynamic>>[];
    b.writeln(
        '| $kind | ${entries.length} | ${entries.isEmpty ? '-' : entries.first['sourceRef']} |');
  }
  b
    ..writeln()
    ..writeln('## 비이진 콘텐츠 증거')
    ..writeln()
    ..writeln(
        '- side scene mechanics: ${(summary['mechanics'] as List).join(', ')}')
    ..writeln(
        '- 각 side node는 위치, 명령 3개, domain event 3개, 정책 gate, 선택 피드백을 함께 보유한다.')
    ..writeln(
        '- companion·activity·ending·chapter 노드는 선택지 수가 아니라 기록 명령과 후속 피드백을 별도 domain event로 남긴다.')
    ..writeln()
    ..writeln(
        '상세 133개 노드는 이 문서와 같은 입력으로 생성된 [`event-storm.jsonl`](event-storm.jsonl)에서 한 줄씩 검토한다.');
  return b.toString();
}

void main(List<String> args) {
  const input = 'story/story.jsonl';
  final story = decodeJsonl(File(input).readAsStringSync());
  final artifact = buildEventStorm(story, sha(input));
  final jsonl = encodeJsonl(artifact,
      schema: 'lumen-document-jsonl-v1', document: 'docs/event-storm.jsonl');
  final markdown = renderMarkdown(artifact);
  const jsonPath = 'docs/event-storm.jsonl', mdPath = 'docs/event-storm.md';
  if (args.contains('--check')) {
    if (!File(jsonPath).existsSync() ||
        File(jsonPath).readAsStringSync() != jsonl) {
      stderr.writeln('EVENT_STORM_DOC_FAIL: regenerate $jsonPath');
      exit(1);
    }
    if (!File(mdPath).existsSync() ||
        File(mdPath).readAsStringSync() != markdown) {
      stderr.writeln('EVENT_STORM_DOC_FAIL: regenerate $mdPath');
      exit(1);
    }
    stdout.writeln(
        'EVENT_STORM_DOC_OK: $jsonPath, $mdPath nodes=${mapValue(artifact['summary'])['nodeCount']}');
    return;
  }
  File(jsonPath).writeAsStringSync(jsonl);
  File(mdPath).writeAsStringSync(markdown);
  stdout.writeln(
      'EVENT_STORM_DOC_WRITTEN: $jsonPath, $mdPath nodes=${mapValue(artifact['summary'])['nodeCount']}');
}
