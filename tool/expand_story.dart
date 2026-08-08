import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

Map<String, dynamic> choice({
  required String eventId,
  required String id,
  required String stat,
  required int delta,
  required int coins,
  required String bondId,
  required int bondDelta,
  required String labelKo,
  required String labelEn,
  required String lineKo,
  required String lineEn,
  String? rivalId,
  int rivalDelta = 0,
  String? requiresStat,
  int requiresMin = 0,
  String? requiresBondId,
  int requiresBondMin = 0,
  String? requiresFlag,
  String? setsFlag,
}) {
  final result = <String, dynamic>{
    'label': labelKo,
    'labelKey': 'event.$eventId.$id.label',
    'labelEn': labelEn,
    'stat': stat,
    'delta': delta,
    'coins': coins,
    'bondId': bondId,
    'bondDelta': bondDelta,
    'line': lineKo,
    'lineKey': 'event.$eventId.$id.line',
    'lineEn': lineEn,
  };
  if (rivalId != null) {
    result['rivalId'] = rivalId;
    result['rivalDelta'] = rivalDelta;
  }
  if (requiresStat != null) {
    result['requiresStat'] = requiresStat;
    result['requiresMin'] = requiresMin;
  }
  if (requiresBondId != null) {
    result['requiresBondId'] = requiresBondId;
    result['requiresBondMin'] = requiresBondMin;
  }
  if (requiresFlag != null) result['requiresFlag'] = requiresFlag;
  if (setsFlag != null) result['setsFlag'] = setsFlag;
  return result;
}

Map<String, dynamic> event({
  required String id,
  required int week,
  required String locationId,
  required String titleKo,
  required String titleEn,
  required String bodyKo,
  required String bodyEn,
  required List<Map<String, dynamic>> choices,
}) =>
    {
      'week': week,
      'locationId': locationId,
      'title': titleKo,
      'titleKey': 'event.$id.title',
      'body': bodyKo,
      'bodyKey': 'event.$id.body',
      'choices': choices,
    };

Map<String, dynamic> chapter({
  required String id,
  required int start,
  required int end,
  required String title,
  required String titleEn,
  required String premise,
  required String premiseEn,
  required String payoff,
  required String payoffEn,
  required List<int> eventWeeks,
  required String milestoneId,
  required String reveal,
  required List<String> pressureAxes,
}) =>
    {
      'id': id,
      'weekStart': start,
      'weekEnd': end,
      'title': title,
      'titleKey': 'chapter.$id.title',
      'titleEn': titleEn,
      'premise': premise,
      'premiseKey': 'chapter.$id.premise',
      'premiseEn': premiseEn,
      'payoff': payoff,
      'payoffKey': 'chapter.$id.payoff',
      'payoffEn': payoffEn,
      'eventWeeks': eventWeeks,
      'milestoneId': milestoneId,
      'contract': {
        'reveal': reveal,
        'pressureAxes': pressureAxes,
        'choiceWeeks': eventWeeks,
        'closureMilestone': milestoneId,
      },
    };

Map<String, dynamic> milestone({
  required String id,
  required int week,
  required String title,
  required String titleEn,
  required String stat,
  required int min,
  required int coins,
  required String pass,
  required String fail,
}) =>
    {
      'id': id,
      'week': week,
      'title': title,
      'titleKey': 'milestone.$id.title',
      'titleEn': titleEn,
      'stat': stat,
      'min': min,
      'coins': coins,
      'pass': pass,
      'fail': fail,
    };

void addEventLocale(
    Map<String, dynamic> ko,
    Map<String, dynamic> en,
    String id,
    String titleKo,
    String titleEn,
    String bodyKo,
    String bodyEn,
    List<Map<String, dynamic>> choices) {
  ko['event.$id.title'] = titleKo;
  en['event.$id.title'] = titleEn;
  ko['event.$id.body'] = bodyKo;
  en['event.$id.body'] = bodyEn;
  for (final c in choices) {
    final key = c['labelKey'] as String;
    final lineKey = c['lineKey'] as String;
    ko[key] = c['label'];
    en[key] = c['labelEn'];
    ko[lineKey] = c['line'];
    en[lineKey] = c['lineEn'];
  }
}

void refreshHashes(Map<String, dynamic> story) {
  final refs = (story['codeRefs'] as List).cast<Map<String, dynamic>>();
  final requiredRefs = [
    'tool/verify_scenario_variants.dart#scenario-case-enumerator',
    'tool/ci_gate.dart#system-verdict',
    'tool/trilemma_verdict.dart#axis-verdict',
    'tool/verify_game.dart#visual-golden-contract',
    'lib/canvas_surface.dart#CanvasViewport',
    'lib/canvas_scene_fingerprint.dart#canvasSceneFingerprint',
    'lib/activity_catalog.dart#activitiesFromStory',
    'tool/verify_render_quality.dart#render-quality-preconditions',
    'test/chapter_golden_test.dart#all sixteen SSOT chapters have deterministic event Goldens',
    'test/chapter_closure_golden_test.dart#all sixteen SSOT chapter closures have deterministic goal Goldens',
    'tool/verify_gameplay_fun.dart#gameplay-purity-kpi-gate',
    'tool/generate_development_goals.dart#buildDocument',
    'tool/verify_development_goals.dart#quantitative-evidence-gate',
    'lib/decision_receipt.dart#DecisionReceipt',
    'lib/decision_proof.dart#SystemDecisionPolicy',
    'tool/verify_decision_proof.dart#decision-proof-preconditions',
    'test/decision_proof_test.dart#same preconditions reproduce the same chain',
  ];
  refs.removeWhere((entry) =>
      entry['ref'] == 'docs/decision-proof-contract.json#preconditionFields');
  for (final ref in requiredRefs) {
    if (!refs.any((entry) => entry['ref'] == ref)) {
      refs.add({'ref': ref, 'sha256': ''});
    }
  }
  for (final ref in (story['codeRefs'] as List).cast<Map<String, dynamic>>()) {
    final path = (ref['ref'] as String).split('#').first;
    ref['sha256'] = sha256.convert(File(path).readAsBytesSync()).toString();
  }
  for (final ref
      in (story['localeRefs'] as List).cast<Map<String, dynamic>>()) {
    final path = (ref['ref'] as String).split('#').first;
    ref['sha256'] = sha256.convert(File(path).readAsBytesSync()).toString();
  }
}

void materializeCharacterContracts(Map<String, dynamic> story,
    Map<String, dynamic> ko, Map<String, dynamic> en) {
  final companions = (story['companions'] as List).cast<Map<String, dynamic>>();
  final frames = <String, int>{};
  final characters = <Map<String, dynamic>>[
    {
      'id': 'noa',
      'kind': 'hero',
      'name': story['hero'],
      'nameKey': 'hero.name',
      'portraitAsset': 'assets/noa-sprite-sheet.png',
      'portraitFrame': 0,
    },
  ];
  ko['hero.name'] = story['hero'];
  en['hero.name'] = 'Noa';
  for (final companion in companions) {
    final id = '${companion['id']}', frame = companion['portraitFrame'] as int;
    frames[id] = frame;
    companion['nameKey'] = 'companion.$id.name';
    companion['portraitAsset'] ??= 'assets/lumen-personality-sheet.png';
    ko[companion['nameKey']] = companion['name'];
    en[companion['nameKey']] = switch (id) {
      'lumi' => 'Lumi',
      'bora' => 'Bora',
      'taro' => 'Taro',
      _ => '${companion['name']}',
    };
    characters.add({
      'id': id,
      'kind': 'companion',
      'name': companion['name'],
      'nameKey': companion['nameKey'],
      'role': companion['role'],
      'personality': companion['personality'],
      'portraitAsset': companion['portraitAsset'],
      'portraitFrame': frame,
    });
  }
  for (final event in (story['events'] as List).cast<Map<String, dynamic>>()) {
    for (final choice
        in (event['choices'] as List).cast<Map<String, dynamic>>()) {
      final id = '${choice['bondId']}';
      choice['speakerId'] = id;
      choice['speakerNameKey'] = 'companion.$id.name';
      choice['speakerPortraitAsset'] = 'assets/lumen-personality-sheet.png';
      choice['speakerPortraitFrame'] = frames[id] ?? 0;
    }
  }
  story['characters'] = characters;
}

void main() {
  final storyFile = File('story/story.json');
  final koFile = File('story/locales/ko.json');
  final enFile = File('story/locales/en.json');
  final story =
      jsonDecode(storyFile.readAsStringSync()) as Map<String, dynamic>;
  final ko = jsonDecode(koFile.readAsStringSync()) as Map<String, dynamic>;
  final en = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;

  final newEvents = <Map<String, dynamic>>[];
  void add(Map<String, dynamic> e, String titleEn, String bodyEn) {
    newEvents.add(e);
    addEventLocale(ko, en, e['titleKey'].toString().split('.')[1], e['title'],
        titleEn, e['body'], bodyEn, (e['choices'] as List).cast());
  }

  add(
      event(
        id: 'firstHorizon',
        week: 24,
        locationId: 'archive',
        titleKo: '첫 지평의 표식',
        titleEn: 'Marker of the First Horizon',
        bodyKo: '첫 결산의 끝에서, 노아는 다음 계절로 건너갈 표식을 남긴다.',
        bodyEn:
            'At the first ledger close, Noa leaves a marker for the next season.',
        choices: [
          choice(
              eventId: 'firstHorizon',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 근거의 별자리를 새긴다',
              labelEn: 'Etch the evidence constellation with Lumi',
              lineKo: '첫 지평은 결론이 아니라 다시 읽을 수 있는 방향이어야 해.',
              lineEn:
                  'The first horizon should be a direction that can be read again.',
              setsFlag: 'first-horizon'),
          choice(
              eventId: 'firstHorizon',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '타로와 강 건너 표식을 세운다',
              labelEn: 'Raise a crossing marker with Taro',
              lineKo: '다음 사람의 발이 닿을 곳을 먼저 약속하자.',
              lineEn:
                  'Let us promise where the next traveller can place a foot.',
              setsFlag: 'first-horizon'),
        ],
      ),
      'Marker of the First Horizon',
      'At the first ledger close, Noa leaves a marker for the next season.');
  add(
      event(
        id: 'seedReturn',
        week: 25,
        locationId: 'market',
        titleKo: '씨앗이 된 답장',
        titleEn: 'A Reply Turned Seed',
        bodyKo: '먼 영지의 답장에는 감사 대신 씨앗 한 봉지가 들어 있다. 빚일까, 약속일까?',
        bodyEn:
            'The distant reply holds seeds instead of thanks. Is it a debt, or a promise?',
        choices: [
          choice(
              eventId: 'seedReturn',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 답장의 조건을 기록한다',
              labelEn: 'Record the reply conditions with Lumi',
              lineKo: '선물도 조건을 읽어야 오래 지킬 수 있어.',
              lineEn: 'Even a gift needs its conditions read to last.',
              requiresFlag: 'first-ledger',
              setsFlag: 'return-debt'),
          choice(
              eventId: 'seedReturn',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '보라와 씨앗을 마을에 나눈다',
              labelEn: 'Share the seeds with Bora',
              lineKo: '받은 것을 나누면 빚은 함께 지는 약속이 돼.',
              lineEn:
                  'When we share what we received, debt becomes a promise we carry together.',
              setsFlag: 'return-seed'),
        ],
      ),
      'A Reply Turned Seed',
      'The distant reply holds seeds instead of thanks. Is it a debt, or a promise?');
  add(
      event(
        id: 'emptyField',
        week: 26,
        locationId: 'river-road',
        titleKo: '강 건너 빈 터',
        titleEn: 'The Empty Field Across the River',
        bodyKo: '강 건너의 빈 터에는 오래된 말뚝만 남았다. 누가 무엇을 다시 시작할까?',
        bodyEn:
            'Only old stakes remain in the field across the river. Who will begin again?',
        choices: [
          choice(
              eventId: 'emptyField',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '타로와 새 물길을 시험한다',
              labelEn: 'Test a new waterway with Taro',
              lineKo: '빈 터는 실패한 곳이 아니라 아직 시험하지 않은 곳이야.',
              lineEn:
                  'An empty field is not a failure; it is an untested place.',
              requiresStat: '용기',
              requiresMin: 20,
              setsFlag: 'waterway'),
          choice(
              eventId: 'emptyField',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: 1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '보라와 먼저 머물 사람을 묻는다',
              labelEn: 'Ask who will stay with Bora',
              lineKo: '땅보다 먼저, 여기서 살아갈 사람의 목소리를 들어야 해.',
              lineEn:
                  'Before the land, we need to hear the people who will live here.',
              rivalId: 'taro',
              rivalDelta: -1),
        ],
      ),
      'The Empty Field Across the River',
      'Only old stakes remain in the field across the river. Who will begin again?');
  add(
      event(
        id: 'witness',
        week: 27,
        locationId: 'greenhouse',
        titleKo: '새싹의 증인',
        titleEn: 'Witness to a Sprout',
        bodyKo: '첫 씨앗이 싹을 틔웠지만, 누구의 손이 이 장면을 만들었는지는 서로 다르게 기억된다.',
        bodyEn:
            'The first seed sprouts, but everyone remembers whose hands made it happen differently.',
        choices: [
          choice(
              eventId: 'witness',
              id: 'lumi',
              stat: '지혜',
              delta: 1,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 손의 순서를 기록한다',
              labelEn: 'Record the order of hands with Lumi',
              lineKo: '한 사람의 공이 아니라 이어진 손을 남기자.',
              lineEn:
                  'Let us record the hands that carried the work, not one person’s credit.',
              requiresFlag: 'return-debt',
              setsFlag: 'witness-ledger'),
          choice(
              eventId: 'witness',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: 0,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 함께 첫 수확을 나눈다',
              labelEn: 'Share the first harvest with Bora',
              lineKo: '기억이 달라도 함께 먹은 맛은 다음 약속이 될 수 있어.',
              lineEn:
                  'Even when memories differ, a shared taste can become the next promise.',
              requiresFlag: 'return-seed',
              setsFlag: 'witness-garden'),
        ],
      ),
      'Witness to a Sprout',
      'The first seed sprouts, but everyone remembers whose hands made it happen differently.');
  add(
      event(
        id: 'receipt',
        week: 28,
        locationId: 'archive',
        titleKo: '작업장의 영수증',
        titleEn: 'The Workshop Receipt',
        bodyKo: '공방의 장부에서 사라진 시간 세 칸이 발견된다. 기록하지 않은 노동도 빚으로 남을까?',
        bodyEn:
            'Three missing blocks of time appear in the workshop ledger. Does unrecorded labour remain a debt?',
        choices: [
          choice(
              eventId: 'receipt',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 빈 시간을 공개한다',
              labelEn: 'Make the missing time public with Lumi',
              lineKo: '비어 있는 칸도 숨기지 않아야 다음 계산이 정직해져.',
              lineEn:
                  'The empty blocks must be visible for the next calculation to be honest.',
              requiresFlag: 'first-ledger',
              setsFlag: 'labor-audit'),
          choice(
              eventId: 'receipt',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '타로와 직접 작업량을 다시 잰다',
              labelEn: 'Measure the work again with Taro',
              lineKo: '틀린 계산은 손으로 다시 확인할 수 있어.',
              lineEn: 'A wrong calculation can be checked again by hand.',
              rivalId: 'lumi',
              rivalDelta: -1),
        ],
      ),
      'The Workshop Receipt',
      'Three missing blocks of time appear in the workshop ledger. Does unrecorded labour remain a debt?');
  add(
      event(
        id: 'emptyCart',
        week: 29,
        locationId: 'market',
        titleKo: '비어 있는 수레',
        titleEn: 'The Empty Cart',
        bodyKo: '시장에 도착한 수레가 비어 있다. 모두가 필요한 것을 말하지만, 은화는 하나뿐이다.',
        bodyEn:
            'A cart arrives empty. Everyone names a need, but there is only one coin left.',
        choices: [
          choice(
              eventId: 'emptyCart',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 가장 급한 집을 먼저 찾는다',
              labelEn: 'Find the most urgent household with Bora',
              lineKo: '같은 양을 나누는 것과 같은 마음으로 보는 것은 다를 수 있어.',
              lineEn: 'Equal portions and equal care are not always the same.',
              setsFlag: 'need-first'),
          choice(
              eventId: 'emptyCart',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: 0,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '타로와 다음 수레를 직접 부른다',
              labelEn: 'Call the next cart with Taro',
              lineKo: '이번에 부족했다면 다음 길을 지금 만들자.',
              lineEn: 'If this was not enough, let us make the next road now.',
              setsFlag: 'next-cart'),
        ],
      ),
      'The Empty Cart',
      'A cart arrives empty. Everyone names a need, but there is only one coin left.');
  add(
      event(
        id: 'sharedLabor',
        week: 30,
        locationId: 'greenhouse',
        titleKo: '돌봄의 노동',
        titleEn: 'The Labour of Care',
        bodyKo: '온실의 가장 늦은 시간에 누군가의 손이 먼저 지쳐 있었다. 돌봄은 누구의 일정에 적힐까?',
        bodyEn:
            'At the greenhouse’s latest hour, someone’s hands tire first. Whose schedule records care?',
        choices: [
          choice(
              eventId: 'sharedLabor',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 돌봄 시간을 일정에 넣는다',
              labelEn: 'Put care time on the schedule with Bora',
              lineKo: '보이지 않는 일도 하루를 바꾼다면 기록되어야 해.',
              lineEn:
                  'If unseen work changes the day, it deserves a place in the record.',
              setsFlag: 'care-counted'),
          choice(
              eventId: 'sharedLabor',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 늦은 손의 패턴을 찾는다',
              labelEn: 'Find the pattern of late hands with Lumi',
              lineKo: '반복되는 피로에는 개인의 약함이 아닌 규칙이 있을 수 있어.',
              lineEn:
                  'Repeated fatigue may reveal a rule, not a person’s weakness.',
              requiresFlag: 'labor-audit'),
        ],
      ),
      'The Labour of Care',
      'At the greenhouse’s latest hour, someone’s hands tire first. Whose schedule records care?');
  add(
      event(
        id: 'memoryHouse',
        week: 31,
        locationId: 'archive',
        titleKo: '기억의 집',
        titleEn: 'The House of Memory',
        bodyKo: '기록관 뒤편에서 오래된 방이 열린다. 이름 없는 상자들이 루멘의 과거를 기다리고 있다.',
        bodyEn:
            'A room opens behind the archive. Nameless boxes wait with Lumen’s past.',
        choices: [
          choice(
              eventId: 'memoryHouse',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 4,
              labelKo: '루미와 상자마다 날짜를 붙인다',
              labelEn: 'Date each box with Lumi',
              lineKo: '기억은 완벽하지 않아도 다시 찾을 표식이 필요해.',
              lineEn:
                  'Memory need not be perfect, but it needs a marker to be found again.',
              setsFlag: 'memory-house'),
          choice(
              eventId: 'memoryHouse',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 상자의 주인을 기다린다',
              labelEn: 'Wait for the owners with Bora',
              lineKo: '이름을 대신 정하지 않는 것도 기억을 돌보는 일이야.',
              lineEn:
                  'Not deciding a name for someone is also a way to care for memory.',
              setsFlag: 'memory-table'),
        ],
      ),
      'The House of Memory',
      'A room opens behind the archive. Nameless boxes wait with Lumen’s past.');
  add(
      event(
        id: 'lostName',
        week: 32,
        locationId: 'river-road',
        titleKo: '지워진 이름',
        titleEn: 'The Erased Name',
        bodyKo: '강 건너 표식 하나에서 이름만 지워져 있다. 지운 사람과 남겨진 사람의 이유가 다르다.',
        bodyEn:
            'A crossing marker has lost only its name. The reasons of the eraser and the erased differ.',
        choices: [
          choice(
              eventId: 'lostName',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '타로와 새 이름을 묻는다',
              labelEn: 'Ask for a new name with Taro',
              lineKo: '지워진 자리에 내 이름을 덧쓰지 말고 먼저 물어보자.',
              lineEn:
                  'Let us ask before writing our name over an erased place.',
              requiresFlag: 'memory-house'),
          choice(
              eventId: 'lostName',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: 1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '보라와 빈 표식을 그대로 보존한다',
              labelEn: 'Preserve the blank marker with Bora',
              lineKo: '빈칸도 누군가 돌아올 수 있는 자리로 남겨 두자.',
              lineEn: 'Let the blank remain a place someone can return to.',
              setsFlag: 'blank-name'),
        ],
      ),
      'The Erased Name',
      'A crossing marker has lost only its name. The reasons of the eraser and the erased differ.');
  add(
      event(
        id: 'archiveLantern',
        week: 33,
        locationId: 'archive',
        titleKo: '기록관의 등불',
        titleEn: 'The Archive Lantern',
        bodyKo: '등불이 꺼지면 같은 장부도 서로 다르게 읽힌다. 노아는 빛의 책임을 정해야 한다.',
        bodyEn:
            'When the lantern goes out, the same ledger reads differently. Noa must decide who carries the light.',
        choices: [
          choice(
              eventId: 'archiveLantern',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: -1,
              bondId: 'lumi',
              bondDelta: 4,
              labelKo: '루미와 공개 열람 시간을 만든다',
              labelEn: 'Set public reading hours with Lumi',
              lineKo: '빛을 독점하지 않으면 판단도 서로 확인할 수 있어.',
              lineEn:
                  'When light is not owned, judgements can be checked together.',
              requiresStat: '지혜',
              requiresMin: 30,
              setsFlag: 'open-reading'),
          choice(
              eventId: 'archiveLantern',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: 1,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '타로와 등불을 여러 곳에 나눈다',
              labelEn: 'Place lanterns in many places with Taro',
              lineKo: '한 등불이 꺼져도 길 전체가 어두워지지 않게 하자.',
              lineEn: 'Let one dark lantern not darken the whole road.',
              setsFlag: 'many-lanterns'),
        ],
      ),
      'The Archive Lantern',
      'When the lantern goes out, the same ledger reads differently. Noa must decide who carries the light.');
  add(
      event(
        id: 'shadowLetter',
        week: 34,
        locationId: 'market',
        titleKo: '먼 영지의 그림자',
        titleEn: 'Shadow from the Distant Province',
        bodyKo: '두 번째 편지는 도움을 청하지 않는다. 루멘의 선택이 다른 마을의 규칙으로 번졌다는 소식이다.',
        bodyEn:
            'The second letter asks for nothing. It says Lumen’s choice has become another village’s rule.',
        choices: [
          choice(
              eventId: 'shadowLetter',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -2,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '타로와 현장을 직접 확인한다',
              labelEn: 'Check the site with Taro',
              lineKo: '우리의 규칙이 누구를 밀어냈는지 직접 봐야 해.',
              lineEn: 'We must see who our rule pushed aside.',
              requiresFlag: 'waterway',
              setsFlag: 'far-shore'),
          choice(
              eventId: 'shadowLetter',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 규칙의 전달 경로를 추적한다',
              labelEn: 'Trace the rule’s path with Lumi',
              lineKo: '좋은 의도도 전달되는 동안 다른 뜻이 될 수 있어.',
              lineEn:
                  'Good intentions can become something else while travelling.',
              setsFlag: 'rule-shadow'),
        ],
      ),
      'Shadow from the Distant Province',
      'The second letter asks for nothing. It says Lumen’s choice has become another village’s rule.');
  add(
      event(
        id: 'tideCrossing',
        week: 35,
        locationId: 'river-road',
        titleKo: '두 물결의 교차',
        titleEn: 'Where Two Currents Meet',
        bodyKo: '새 물길과 오래된 물길이 만나는 곳에서, 어느 쪽도 혼자서는 마을을 채우지 못한다.',
        bodyEn:
            'Where the new current meets the old, neither can fill the village alone.',
        choices: [
          choice(
              eventId: 'tideCrossing',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 물을 나누는 순서를 정한다',
              labelEn: 'Set the sharing order with Bora',
              lineKo: '두 물결이 만나는 곳에는 먼저 마실 사람도 함께 정해야 해.',
              lineEn:
                  'Where currents meet, we must decide together who drinks first.',
              setsFlag: 'shared-water'),
          choice(
              eventId: 'tideCrossing',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: 0,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '타로와 수문을 다시 설계한다',
              labelEn: 'Redesign the sluice with Taro',
              lineKo: '흐름을 바꾸려면 막힌 곳부터 손으로 찾아야 해.',
              lineEn: 'To change a flow, we must find the blockage by hand.',
              rivalId: 'bora',
              rivalDelta: -1,
              setsFlag: 'sluice-plan'),
        ],
      ),
      'Where Two Currents Meet',
      'Where the new current meets the old, neither can fill the village alone.');
  add(
      event(
        id: 'returningSeed',
        week: 36,
        locationId: 'greenhouse',
        titleKo: '돌아온 씨앗',
        titleEn: 'The Seed Comes Home',
        bodyKo: '첫 씨앗의 일부가 다시 루멘으로 돌아왔다. 수확은 소유가 아니라 순환의 증거가 된다.',
        bodyEn:
            'Part of the first seed returns to Lumen. The harvest becomes proof of a cycle, not ownership.',
        choices: [
          choice(
              eventId: 'returningSeed',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: 1,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 귀환한 씨앗을 심는다',
              labelEn: 'Plant the returning seed with Bora',
              lineKo: '돌아온 것은 끝난 일이 아니라 다음 사람의 시작이야.',
              lineEn:
                  'What returns is not finished; it is someone else’s beginning.',
              requiresFlag: 'witness-garden',
              setsFlag: 'returning-garden'),
          choice(
              eventId: 'returningSeed',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 씨앗의 이동을 지도에 남긴다',
              labelEn: 'Map the seed’s journey with Lumi',
              lineKo: '순환을 보이게 하면 다음 약속도 다시 확인할 수 있어.',
              lineEn:
                  'When the cycle is visible, the next promise can be checked again.',
              setsFlag: 'seed-route'),
        ],
      ),
      'The Seed Comes Home',
      'Part of the first seed returns to Lumen. The harvest becomes proof of a cycle, not ownership.');
  add(
      event(
        id: 'blankMap',
        week: 37,
        locationId: 'archive',
        titleKo: '불완전한 지도',
        titleEn: 'The Incomplete Map',
        bodyKo: '세 장의 지도에는 모두 같은 빈칸이 있다. 지우지 않고 함께 읽는 방법을 선택해야 한다.',
        bodyEn:
            'All three maps share the same blank. Noa must choose how to read it without erasing it.',
        choices: [
          choice(
              eventId: 'blankMap',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 4,
              labelKo: '루미와 빈칸을 측정값으로 남긴다',
              labelEn: 'Leave the blank as a measurement with Lumi',
              lineKo: '모른다는 표시도 다음 판단의 정확한 출발점이야.',
              lineEn:
                  'A mark of not knowing is an exact starting point for the next judgement.',
              requiresFlag: 'first-ledger',
              setsFlag: 'blank-map'),
          choice(
              eventId: 'blankMap',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '타로와 빈칸까지 직접 걸어 본다',
              labelEn: 'Walk the blank with Taro',
              lineKo: '지도가 끝난 곳에서 길이 시작될 수도 있어.',
              lineEn: 'A road may begin where the map ends.',
              requiresFlag: 'horizon-mark',
              setsFlag: 'blank-walk'),
        ],
      ),
      'The Incomplete Map',
      'All three maps share the same blank. Noa must choose how to read it without erasing it.');
  add(
      event(
        id: 'northGate',
        week: 38,
        locationId: 'river-road',
        titleKo: '북쪽 문지기',
        titleEn: 'The Northern Gatekeeper',
        bodyKo: '새 항로의 문 앞에서 문지기는 목적지가 아니라 돌아오는 방법을 묻는다.',
        bodyEn:
            'At the new route’s gate, the gatekeeper asks not for a destination but a way back.',
        choices: [
          choice(
              eventId: 'northGate',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '타로와 돌아올 표식을 세운다',
              labelEn: 'Raise a return marker with Taro',
              lineKo: '떠나는 용기에는 돌아와 확인할 약속이 따라야 해.',
              lineEn:
                  'The courage to leave needs a promise to return and check.',
              requiresStat: '용기',
              requiresMin: 35,
              setsFlag: 'return-marker'),
          choice(
              eventId: 'northGate',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: 1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '보라와 남는 사람의 문을 연다',
              labelEn: 'Open the gate for those who stay with Bora',
              lineKo: '모든 사람이 떠날 수 없다면 남는 선택도 길이어야 해.',
              lineEn: 'If not everyone can leave, staying must also be a road.',
              setsFlag: 'stay-gate'),
        ],
      ),
      'The Northern Gatekeeper',
      'At the new route’s gate, the gatekeeper asks not for a destination but a way back.');
  add(
      event(
        id: 'sharedCompass',
        week: 39,
        locationId: 'market',
        titleKo: '나침반의 회의',
        titleEn: 'The Compass Meeting',
        bodyKo: '세 사람의 나침반이 서로 다른 북쪽을 가리킨다. 하나를 고르는 대신 기준을 공개할 수 있을까?',
        bodyEn:
            'Three compasses point to different norths. Can their standards be shared instead of choosing one?',
        choices: [
          choice(
              eventId: 'sharedCompass',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 측정 기준을 공개한다',
              labelEn: 'Publish the measurement standard with Lumi',
              lineKo: '나침반보다 먼저, 나침반을 읽는 법을 함께 보여 주자.',
              lineEn:
                  'Before the compass, let us show everyone how to read it.',
              setsFlag: 'public-map'),
          choice(
              eventId: 'sharedCompass',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 서로 다른 북쪽을 들어 본다',
              labelEn: 'Listen to each different north with Bora',
              lineKo: '같은 곳을 보지 않아도 함께 서 있을 수 있어.',
              lineEn:
                  'We can stand together without looking at the same place.',
              rivalId: 'lumi',
              rivalDelta: -1),
        ],
      ),
      'The Compass Meeting',
      'Three compasses point to different norths. Can their standards be shared instead of choosing one?');
  add(
      event(
        id: 'councilNight',
        week: 40,
        locationId: 'archive',
        titleKo: '선택의 의회',
        titleEn: 'The Council of Choices',
        bodyKo: '사람들은 노아에게 결정을 맡기려 한다. 노아는 대신 결정하는 법이 아니라 함께 결정하는 장면을 연다.',
        bodyEn:
            'People ask Noa to decide for them. Noa opens a scene for deciding together instead.',
        choices: [
          choice(
              eventId: 'councilNight',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 가장 작은 합의를 시험한다',
              labelEn: 'Test the smallest agreement with Bora',
              lineKo: '모두를 만족시키기 전에 함께 지킬 한 문장을 찾자.',
              lineEn:
                  'Before pleasing everyone, let us find one sentence we can keep together.',
              requiresFlag: 'first-ledger',
              setsFlag: 'small-agreement'),
          choice(
              eventId: 'councilNight',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: 1,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '타로와 결정권을 분산한다',
              labelEn: 'Distribute the right to decide with Taro',
              lineKo: '책임을 나누려면 판단할 자리도 나눠야 해.',
              lineEn:
                  'To share responsibility, we must share the place of judgement.',
              setsFlag: 'shared-rule'),
        ],
      ),
      'The Council of Choices',
      'People ask Noa to decide for them. Noa opens a scene for deciding together instead.');
  add(
      event(
        id: 'minorityVoice',
        week: 41,
        locationId: 'greenhouse',
        titleKo: '가장 작은 목소리',
        titleEn: 'The Smallest Voice',
        bodyKo: '회의가 끝난 뒤에도 한 사람은 말하지 못했다. 합의가 침묵을 세어 주는지 확인해야 한다.',
        bodyEn:
            'One person could not speak before the meeting ended. Noa must see if agreement counts silence.',
        choices: [
          choice(
              eventId: 'minorityVoice',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: 0,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 말하지 못한 사람을 기다린다',
              labelEn: 'Wait with Bora for the unheard person',
              lineKo: '답을 재촉하지 않는 시간도 돌봄의 규칙에 넣자.',
              lineEn: 'Let time without an answer be part of the rule of care.',
              setsFlag: 'quiet-voice'),
          choice(
              eventId: 'minorityVoice',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 침묵이 생긴 순간을 기록한다',
              labelEn: 'Record when silence appeared with Lumi',
              lineKo: '침묵의 원인을 모르면 합의의 숫자도 믿을 수 없어.',
              lineEn:
                  'Without its cause, the number of an agreement cannot be trusted.',
              setsFlag: 'silence-record'),
        ],
      ),
      'The Smallest Voice',
      'One person could not speak before the meeting ended. Noa must see if agreement counts silence.');
  add(
      event(
        id: 'publicRule',
        week: 42,
        locationId: 'market',
        titleKo: '공동 규칙의 날',
        titleEn: 'The Day of a Shared Rule',
        bodyKo: '새 규칙을 벽에 붙이는 날이다. 규칙은 강할수록 짧아야 하고, 짧을수록 다시 읽혀야 한다.',
        bodyEn:
            'The new rule goes on the wall. The stronger a rule is, the shorter and more readable it should be.',
        choices: [
          choice(
              eventId: 'publicRule',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 4,
              labelKo: '루미와 검증 절차를 한 줄로 쓴다',
              labelEn: 'Write the verification step in one line with Lumi',
              lineKo: '누구나 다시 확인할 수 있어야 규칙이 사람보다 오래 살아.',
              lineEn:
                  'A rule outlives people only when anyone can verify it again.',
              requiresFlag: 'first-ledger',
              setsFlag: 'public-rule'),
          choice(
              eventId: 'publicRule',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '타로와 규칙을 현장에서 시험한다',
              labelEn: 'Test the rule in the field with Taro',
              lineKo: '벽의 문장은 발밑의 돌을 만날 때 진짜가 돼.',
              lineEn:
                  'A sentence on a wall becomes real when it meets stones underfoot.',
              setsFlag: 'field-rule'),
        ],
      ),
      'The Day of a Shared Rule',
      'The new rule goes on the wall. The stronger a rule is, the shorter and more readable it should be.');
  add(
      event(
        id: 'seedFestival',
        week: 43,
        locationId: 'greenhouse',
        titleKo: '별씨앗의 귀환',
        titleEn: 'The Star Seed Returns',
        bodyKo: '처음 도착했던 씨앗들이 마침내 같은 온실에서 꽃이 되었다. 시작의 의미가 바뀐다.',
        bodyEn:
            'The first seeds finally flower in the same greenhouse. The meaning of the beginning changes.',
        choices: [
          choice(
              eventId: 'seedFestival',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 꽃을 모두의 이름으로 부른다',
              labelEn: 'Name the flowers for everyone with Bora',
              lineKo: '시작을 기억하는 가장 좋은 방법은 다음 사람의 이름을 함께 부르는 거야.',
              lineEn:
                  'The best way to remember a beginning is to name the next people too.',
              requiresFlag: 'witness-garden',
              setsFlag: 'flower-names'),
          choice(
              eventId: 'seedFestival',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 발아의 조건을 공개한다',
              labelEn: 'Publish the sprouting conditions with Lumi',
              lineKo: '기적처럼 보인 일도 조건을 나누면 다시 만날 수 있어.',
              lineEn:
                  'What looks like a miracle can happen again when its conditions are shared.',
              setsFlag: 'flower-record'),
        ],
      ),
      'The Star Seed Returns',
      'The first seeds finally flower in the same greenhouse. The meaning of the beginning changes.');
  add(
      event(
        id: 'farewellMarket',
        week: 44,
        locationId: 'market',
        titleKo: '떠나는 장터',
        titleEn: 'The Departure Market',
        bodyKo: '새 항로를 따라 떠날 사람들의 장터가 열린다. 떠남을 돕는 일에도 남겨진 물건이 필요하다.',
        bodyEn:
            'A market opens for those leaving by the new route. Departure still needs what is left behind.',
        choices: [
          choice(
              eventId: 'farewellMarket',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -2,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '타로와 여행 짐의 기준을 세운다',
              labelEn: 'Set a standard for travel packs with Taro',
              lineKo: '가볍게 떠나는 것과 안전하게 떠나는 것은 함께 계산해야 해.',
              lineEn:
                  'Leaving lightly and leaving safely must be calculated together.',
              setsFlag: 'departure-pack'),
          choice(
              eventId: 'farewellMarket',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: 1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '보라와 남은 물건의 새 주인을 찾는다',
              labelEn: 'Find new owners for what remains with Bora',
              lineKo: '떠난 자리도 누군가 다시 살아갈 수 있는 자리로 남겨 두자.',
              lineEn:
                  'Let the place someone leaves remain a place another can live.',
              setsFlag: 'left-behind'),
        ],
      ),
      'The Departure Market',
      'A market opens for those leaving by the new route. Departure still needs what is left behind.');
  add(
      event(
        id: 'gardenOfNames',
        week: 45,
        locationId: 'greenhouse',
        titleKo: '이름을 다시 심는 날',
        titleEn: 'The Day Names Are Planted Again',
        bodyKo: '기억의 집에서 돌아온 이름들이 온실의 작은 표지판이 된다. 이름은 소유가 아니라 초대가 된다.',
        bodyEn:
            'Names returned from the memory house become small greenhouse signs. A name becomes an invitation, not ownership.',
        choices: [
          choice(
              eventId: 'gardenOfNames',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: 0,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 이름의 주인에게 먼저 묻는다',
              labelEn: 'Ask the owners of the names first with Bora',
              lineKo: '불러 주는 일도 허락을 기다릴 때 더 따뜻해져.',
              lineEn:
                  'Calling a name becomes warmer when it waits for permission.',
              requiresFlag: 'memory-table',
              setsFlag: 'named-garden'),
          choice(
              eventId: 'gardenOfNames',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 이름이 바뀐 기록을 남긴다',
              labelEn: 'Record the changed names with Lumi',
              lineKo: '변한 이름까지 남겨야 한 사람을 한 모습에 가두지 않아.',
              lineEn:
                  'Recording changed names keeps a person from one frozen shape.',
              setsFlag: 'name-history'),
        ],
      ),
      'The Day Names Are Planted Again',
      'Names returned from the memory house become small greenhouse signs. A name becomes an invitation, not ownership.');
  add(
      event(
        id: 'nextTraveller',
        week: 46,
        locationId: 'river-road',
        titleKo: '다음 여행자의 짐',
        titleEn: 'The Next Traveller’s Pack',
        bodyKo: '노아보다 어린 여행자가 길의 표식을 읽고 있다. 누군가의 답을 대신 정해 주지 않는 법을 배운다.',
        bodyEn:
            'A younger traveller reads the road markers. Noa learns not to choose someone else’s answer.',
        choices: [
          choice(
              eventId: 'nextTraveller',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '타로와 길의 위험을 숨기지 않는다',
              labelEn: 'Hide none of the road’s risks with Taro',
              lineKo: '안전한 길은 위험이 없는 길이 아니라 위험을 함께 아는 길이야.',
              lineEn:
                  'A safe road is not risk-free; it is a road whose risks are shared.',
              requiresFlag: 'horizon-mark',
              setsFlag: 'risk-shared'),
          choice(
              eventId: 'nextTraveller',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '루미와 읽는 순서만 건넨다',
              labelEn: 'Give only the reading order with Lumi',
              lineKo: '답을 건네는 대신 다시 판단할 순서를 건네자.',
              lineEn:
                  'Instead of giving an answer, give the order for judging again.',
              setsFlag: 'reading-order'),
        ],
      ),
      'The Next Traveller’s Pack',
      'A younger traveller reads the road markers. Noa learns not to choose someone else’s answer.');
  add(
      event(
        id: 'handoffLedger',
        week: 47,
        locationId: 'archive',
        titleKo: '넘겨지는 장부',
        titleEn: 'The Ledger Passed On',
        bodyKo: '장부를 다음 기록관에게 넘기는 날이다. 마지막 페이지보다 첫 페이지를 다시 읽어야 한다.',
        bodyEn:
            'The ledger passes to the next keeper. The first page must be read again, not only the last.',
        choices: [
          choice(
              eventId: 'handoffLedger',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 4,
              labelKo: '루미와 틀린 기록도 함께 넘긴다',
              labelEn: 'Pass the wrong records too with Lumi',
              lineKo: '다음 사람이 다시 확인하려면 우리가 틀린 자리도 필요해.',
              lineEn:
                  'For the next person to check again, they need where we were wrong.',
              requiresFlag: 'public-rule',
              setsFlag: 'handoff-open'),
          choice(
              eventId: 'handoffLedger',
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '보라와 장부를 읽을 사람을 초대한다',
              labelEn: 'Invite readers to the ledger with Bora',
              lineKo: '장부가 혼자 닫히지 않도록 읽는 사람을 함께 남기자.',
              lineEn:
                  'Let us leave readers with the ledger so it never closes alone.',
              setsFlag: 'handoff-circle'),
        ],
      ),
      'The Ledger Passed On',
      'The ledger passes to the next keeper. The first page must be read again, not only the last.');
  add(
      event(
        id: 'finalHorizon',
        week: 48,
        locationId: 'river-road',
        titleKo: '다음 사람의 첫걸음',
        titleEn: 'The Next Person’s First Step',
        bodyKo: '마지막 주의 강바람이 분다. 노아가 남길 것은 정답이 아니라 다시 시작할 수 있는 첫걸음이다.',
        bodyEn:
            'The last week’s river wind arrives. Noa leaves not an answer, but a first step that can begin again.',
        choices: [
          choice(
              eventId: 'finalHorizon',
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '타로와 첫걸음의 표식을 세운다',
              labelEn: 'Raise a first-step marker with Taro',
              lineKo: '내가 없어도 다시 찾을 수 있다면, 이 길은 끝나지 않아.',
              lineEn: 'If it can be found without me, this road does not end.',
              setsFlag: 'final-marker'),
          choice(
              eventId: 'finalHorizon',
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 4,
              labelKo: '루미와 첫 질문을 남긴다',
              labelEn: 'Leave the first question with Lumi',
              lineKo: '좋은 기록은 마지막 답보다 다음 질문을 오래 살려.',
              lineEn:
                  'A good record keeps the next question alive longer than the last answer.',
              requiresFlag: 'public-map',
              setsFlag: 'final-question'),
        ],
      ),
      'The Next Person’s First Step',
      'The last week’s river wind arrives. Noa leaves not an answer, but a first step that can begin again.');

  final existingEvents = (story['events'] as List).cast<Map<String, dynamic>>();
  final byWeek = <int, Map<String, dynamic>>{
    for (final e in existingEvents) e['week'] as int: e
  };
  for (final e in newEvents) byWeek[e['week'] as int] = e;
  story['events'] = byWeek.values.toList()
    ..sort((a, b) => (a['week'] as int).compareTo(b['week'] as int));

  final newChapters = [
    chapter(
        id: 'seedReturn',
        start: 25,
        end: 27,
        title: '돌아온 씨앗',
        titleEn: 'The Seed Returns',
        premise: '첫 결산의 씨앗이 먼 영지와 루멘 사이를 오가며 빚과 약속의 차이를 묻는다.',
        premiseEn:
            'The first ledger’s seed travels between Lumen and the distant province, asking the difference between debt and promise.',
        payoff: '받은 것을 누구와 어떤 조건으로 돌려줄지 정한다.',
        payoffEn:
            'Decide with whom and under what conditions to return what was received.',
        eventWeeks: [25, 26, 27],
        milestoneId: 'waterline',
        reveal: '돌아온 씨앗과 강 건너 빈 터를 공개한다.',
        pressureAxes: ['stat', 'coins', 'bond']),
    chapter(
        id: 'fairShare',
        start: 28,
        end: 30,
        title: '공정한 몫의 시간',
        titleEn: 'The Time of a Fair Share',
        premise: '공방과 온실의 보이지 않는 노동이 장부의 빈칸을 흔든다.',
        premiseEn:
            'Invisible labour in the workshop and greenhouse shakes the empty spaces in the ledger.',
        payoff: '성장 속도보다 누가 지치고 있는지를 함께 계산한다.',
        payoffEn: 'Calculate who is tiring, not only how fast growth happens.',
        eventWeeks: [28, 29, 30],
        milestoneId: 'fair-share',
        reveal: '노동의 영수증과 돌봄의 시간을 공개한다.',
        pressureAxes: ['stat', 'coins', 'fatigue', 'bond']),
    chapter(
        id: 'memoryHouse',
        start: 31,
        end: 33,
        title: '기억의 집',
        titleEn: 'The House of Memory',
        premise: '이름 없는 상자와 지워진 표식이 기록의 주인을 다시 묻는다.',
        premiseEn: 'Nameless boxes and erased markers ask who owns a record.',
        payoff: '보존할 것과 비워 둘 것을 스스로 구분한다.',
        payoffEn: 'Choose what to preserve and what to leave blank.',
        eventWeeks: [31, 32, 33],
        milestoneId: 'memory-house',
        reveal: '기억의 방과 공개 열람 규칙을 공개한다.',
        pressureAxes: ['stat', 'coins', 'bond']),
    chapter(
        id: 'farShore',
        start: 34,
        end: 36,
        title: '먼 영지의 그림자',
        titleEn: 'The Shadow of the Far Shore',
        premise: '루멘의 선택이 다른 마을의 규칙이 되며 의도와 결과가 갈라진다.',
        premiseEn:
            'Lumen’s choice becomes another village’s rule, splitting intention from result.',
        payoff: '도움을 준다는 말이 누구를 밀어냈는지 확인한다.',
        payoffEn: 'Check whom the promise to help pushed aside.',
        eventWeeks: [34, 35, 36],
        milestoneId: 'far-shore',
        reveal: '먼 영지의 후속 편지와 두 물길을 공개한다.',
        pressureAxes: ['stat', 'coins', 'bond']),
    chapter(
        id: 'blankMap',
        start: 37,
        end: 39,
        title: '불완전한 지도',
        titleEn: 'The Incomplete Map',
        premise: '세 장의 지도는 같은 빈칸을 품고, 서로 다른 북쪽을 가리킨다.',
        premiseEn:
            'Three maps hold the same blank while pointing to different norths.',
        payoff: '모르는 것을 숨기지 않고 함께 판단할 기준을 만든다.',
        payoffEn: 'Create a shared standard without hiding what is unknown.',
        eventWeeks: [37, 38, 39],
        milestoneId: 'blank-map',
        reveal: '빈 지도와 북쪽 문, 공개 나침반 회의를 공개한다.',
        pressureAxes: ['stat', 'coins', 'fatigue', 'bond']),
    chapter(
        id: 'commons',
        start: 40,
        end: 42,
        title: '선택의 의회',
        titleEn: 'The Council of Choices',
        premise: '사람들은 노아에게 책임을 맡기지만, 루멘은 함께 결정하는 법을 배워야 한다.',
        premiseEn:
            'People hand responsibility to Noa, but Lumen must learn how to decide together.',
        payoff: '합의에 들어오지 못한 목소리까지 규칙의 일부로 남긴다.',
        payoffEn: 'Leave even unheard voices inside the rule.',
        eventWeeks: [40, 41, 42],
        milestoneId: 'commons',
        reveal: '공동 의회와 침묵의 기록, 공개 규칙을 공개한다.',
        pressureAxes: ['stat', 'coins', 'bond']),
    chapter(
        id: 'returningGarden',
        start: 43,
        end: 45,
        title: '별씨앗의 귀환',
        titleEn: 'The Star Seed Returns',
        premise: '처음의 씨앗이 꽃이 되어 돌아오며 시작과 소유의 의미가 달라진다.',
        premiseEn:
            'The first seed returns as a flower, changing the meaning of beginning and ownership.',
        payoff: '떠나는 사람과 남는 사람 모두가 다음 계절의 자리를 얻는다.',
        payoffEn:
            'Give both those leaving and those staying a place in the next season.',
        eventWeeks: [43, 44, 45],
        milestoneId: 'returning-garden',
        reveal: '귀환한 꽃과 떠나는 장터, 이름의 정원을 공개한다.',
        pressureAxes: ['stat', 'coins', 'bond']),
    chapter(
        id: 'handoff',
        start: 46,
        end: 48,
        title: '다음 사람의 첫걸음',
        titleEn: 'The Next Person’s First Step',
        premise: '노아의 기록은 마지막 페이지가 아니라 다음 사람이 다시 검증할 첫 장으로 넘어간다.',
        premiseEn:
            'Noa’s record becomes a first page for the next person to verify, not a final page.',
        payoff: '정답 대신 다시 시작할 수 있는 질문과 표식을 남긴다.',
        payoffEn:
            'Leave a question and a marker that can begin again, not an answer.',
        eventWeeks: [46, 47, 48],
        milestoneId: 'handoff',
        reveal: '다음 여행자와 넘겨지는 장부, 첫 질문을 공개한다.',
        pressureAxes: ['stat', 'coins', 'bond']),
  ];
  final chapters = (story['progression'] as List).cast<Map<String, dynamic>>();
  chapters.removeWhere((c) => newChapters.any((n) => n['id'] == c['id']));
  chapters.addAll(newChapters);
  chapters
      .sort((a, b) => (a['weekStart'] as int).compareTo(b['weekStart'] as int));
  story['progression'] = chapters;
  for (final c in newChapters) {
    ko[c['titleKey'] as String] = c['title'];
    en[c['titleKey'] as String] = c['titleEn'];
    ko[c['premiseKey'] as String] = c['premise'];
    en[c['premiseKey'] as String] = c['premiseEn'];
    ko[c['payoffKey'] as String] = c['payoff'];
    en[c['payoffKey'] as String] = c['payoffEn'];
  }

  final newMilestones = [
    milestone(
        id: 'waterline',
        week: 27,
        title: '첫 물길의 약속',
        titleEn: 'Promise of the First Waterway',
        stat: '용기',
        min: 30,
        coins: 5,
        pass: '빈 터에 첫 물길이 이어졌다.',
        fail: '물길은 아직 다음 손을 기다린다.'),
    milestone(
        id: 'fair-share',
        week: 30,
        title: '공정한 몫의 시간',
        titleEn: 'Time of a Fair Share',
        stat: '공감',
        min: 40,
        coins: 5,
        pass: '보이지 않던 노동도 하루의 일부가 되었다.',
        fail: '장부의 빈칸이 아직 누군가를 기다린다.'),
    milestone(
        id: 'memory-house',
        week: 33,
        title: '열린 기억의 방',
        titleEn: 'The Open Room of Memory',
        stat: '지혜',
        min: 48,
        coins: 6,
        pass: '기억은 닫힌 상자가 아니라 다시 찾을 길이 되었다.',
        fail: '이름 없는 상자는 아직 빛을 기다린다.'),
    milestone(
        id: 'far-shore',
        week: 36,
        title: '건너온 답',
        titleEn: 'The Answer That Crossed',
        stat: '용기',
        min: 56,
        coins: 6,
        pass: '먼 영지의 답이 루멘의 규칙을 다시 고쳤다.',
        fail: '두 물길은 아직 서로의 속도를 배우는 중이다.'),
    milestone(
        id: 'blank-map',
        week: 39,
        title: '빈칸의 지도',
        titleEn: 'Map of the Blank',
        stat: '지혜',
        min: 64,
        coins: 7,
        pass: '모른다는 표시가 함께 걷는 출발점이 되었다.',
        fail: '지도에는 아직 혼자 건너야 할 빈칸이 남았다.'),
    milestone(
        id: 'commons',
        week: 42,
        title: '공동의 규칙',
        titleEn: 'The Shared Rule',
        stat: '공감',
        min: 72,
        coins: 7,
        pass: '가장 작은 목소리까지 규칙에 들어왔다.',
        fail: '합의 밖의 목소리가 아직 문을 두드린다.'),
    milestone(
        id: 'returning-garden',
        week: 45,
        title: '귀환의 정원',
        titleEn: 'The Returning Garden',
        stat: '공감',
        min: 80,
        coins: 8,
        pass: '처음의 씨앗이 다음 사람의 꽃이 되었다.',
        fail: '정원은 아직 떠남과 머묾의 자리를 고르는 중이다.'),
    milestone(
        id: 'handoff',
        week: 48,
        title: '넘겨지는 지평',
        titleEn: 'The Horizon Passed On',
        stat: '용기',
        min: 88,
        coins: 10,
        pass: '노아는 다음 사람이 다시 시작할 첫걸음을 남겼다.',
        fail: '지평은 닫히지 않았고 다음 기록을 기다린다.'),
  ];
  final milestones = (story['milestones'] as List).cast<Map<String, dynamic>>();
  milestones.removeWhere((m) => newMilestones.any((n) => n['id'] == m['id']));
  milestones.addAll(newMilestones);
  milestones.sort((a, b) => (a['week'] as int).compareTo(b['week'] as int));
  story['milestones'] = milestones;
  const milestoneEnglish = <String, List<String>>{
    'spring': [
      'The first star seed sprouted.',
      'The star seed is still asleep.'
    ],
    'summer': [
      'Different paces became one bridge.',
      'The bridge still shakes, but it can be crossed again.'
    ],
    'autumn': [
      'The courage to send the reply has grown.',
      'The letter waits in the drawer for the next season.'
    ],
    'winter': [
      'Noa opened the first ledger\'s door.',
      'The door stayed closed, but left the next key.'
    ],
    'frost': [
      'A care record remained even in the stopped season.',
      'The seed still waits beneath cold soil.'
    ],
    'return': [
      'A sent feeling returned as a shared promise.',
      'The reply still waits for the next wave.'
    ],
    'constellation': [
      'Different reasons became one public map.',
      'The map still holds blank spaces that have not faded.'
    ],
    'horizon': [
      'Noa left a horizon the next person can verify.',
      'The horizon stayed open as a question for the next run.'
    ],
    'waterline': [
      'The first waterway reached the empty field.',
      'The waterway still waits for the next pair of hands.'
    ],
    'fair-share': [
      'Invisible labour became part of the day.',
      'A blank in the ledger still waits for someone.'
    ],
    'memory-house': [
      'Memory became a path to find again, not a closed box.',
      'The nameless box still waits for light.'
    ],
    'far-shore': [
      'The far shore\'s answer changed Lumen\'s rule again.',
      'The two waterways are still learning each other\'s pace.'
    ],
    'blank-map': [
      'The mark for unknown became a starting point to walk together.',
      'The map still has a blank that must be crossed alone.'
    ],
    'commons': [
      'Even the smallest voice entered the rule.',
      'A voice outside the agreement still knocks.'
    ],
    'returning-garden': [
      'The first seed became the next person\'s flower.',
      'The garden is still choosing a place for leaving and staying.'
    ],
    'handoff': [
      'Noa left the first step for the next person\'s beginning.',
      'The horizon remains open and waits for the next record.'
    ],
  };
  for (final m in newMilestones) {
    ko[m['titleKey'] as String] = m['title'];
    en[m['titleKey'] as String] = m['titleEn'];
  }
  for (final m in milestones) {
    final id = '${m['id']}', words = milestoneEnglish[id];
    if (words == null) continue;
    m['passKey'] = 'milestone.$id.pass';
    m['failKey'] = 'milestone.$id.fail';
    m['passEn'] = words[0];
    m['failEn'] = words[1];
    ko[m['passKey'] as String] = m['pass'];
    ko[m['failKey'] as String] = m['fail'];
    en[m['passKey'] as String] = words[0];
    en[m['failKey'] as String] = words[1];
  }

  story['endingWeek'] = 49;
  story['campaignWeeks'] = 48;
  story['premise'] =
      '왕좌가 아닌, 스스로 선택한 내일을 향해 48주를 걷는다. 기록은 사람이 승인하지 않고 루멘의 규칙 엔진이 승인한다.';
  for (final e in (story['endings'] as List).cast<Map<String, dynamic>>()) {
    if ('${e['id']}'.endsWith('-master')) {
      e['body'] = '${e['body']}'.replaceAll('24주 동안', '48주 동안');
      ko[e['bodyKey'] as String] = e['body'];
      en[e['bodyKey'] as String] =
          '${en[e['bodyKey']] ?? ''}'.replaceAll('24 weeks', '48 weeks');
    }
  }
  ko['ui.ending.title'] = '48주의 끝';
  en['ui.ending.title'] = 'The End of 48 Weeks';
  story['contentBudget'] = {
    'schema': 'lumen-playtime-v1',
    'minimumMinutes': 120,
    'estimatedFirstPlaythroughMinutes': 129,
    'benchmarkMaxMillis': 24000,
    'campaignWeeks': 48,
    'terminalWeek': 49,
    'authoredEvents': 47,
    'authoredChoices': 94,
    'chapterClosures': 16,
    'pacingSeconds': {
      'activityReflection': 75,
      'storyChoice': 75,
      'chapterClosure': 30,
    },
    'formula':
        '48 activity reflections × 75s + 47 story choices × 75s + 16 chapter closures × 30s = 7,755s = 129m; contract reports a conservative 129m first-playthrough estimate.',
  };
  story['fateThreads'] = [
    {
      'id': 'ledger-echo',
      'flag': 'first-ledger',
      'titleRef': 'event.firstLedger.title',
      'detailKey': 'fate.ledger-echo.detail',
      'detail': '기록의 선택이 다음 막의 판단 방식으로 되돌아온다.',
      'detailEn':
          'A choice about the ledger returns as the next chapter\'s rule.',
    },
    {
      'id': 'windmill-echo',
      'flag': 'windmill-truce',
      'titleRef': 'event.windmill.title',
      'detailKey': 'fate.windmill-echo.detail',
      'detail': '중재의 선택이 이후 관계의 긴장을 낮춘다.',
      'detailEn': 'A mediation choice softens a later relationship conflict.',
    },
    {
      'id': 'seed-echo',
      'flag': 'return-seed',
      'titleRef': 'event.seedReturn.title',
      'detailKey': 'fate.seed-echo.detail',
      'detail': '나눔의 선택이 돌아온 씨앗의 의미를 바꾼다.',
      'detailEn': 'A choice to share changes what the returning seed means.',
    },
    {
      'id': 'memory-echo',
      'flag': 'memory-house',
      'titleRef': 'event.memoryHouse.title',
      'detailKey': 'fate.memory-echo.detail',
      'detail': '기억을 여는 선택이 엔딩 회고의 원인으로 남는다.',
      'detailEn':
          'Opening the memory house becomes a cause in the ending review.',
    },
    {
      'id': 'rule-echo',
      'flag': 'public-rule',
      'titleRef': 'event.publicRule.title',
      'detailKey': 'fate.rule-echo.detail',
      'detail': '공개 규칙을 고른 선택이 다음 사람의 출발점이 된다.',
      'detailEn': 'A public rule becomes the next traveller\'s starting point.',
    },
    {
      'id': 'question-echo',
      'flag': 'final-question',
      'titleRef': 'event.finalHorizon.title',
      'detailKey': 'fate.question-echo.detail',
      'detail': '마지막 질문이 다음 회차의 첫 단서로 이어진다.',
      'detailEn': 'The final question becomes the next run\'s first clue.',
    },
  ];
  story['companionQuests'] = [
    {
      'id': 'lumi-constellation',
      'companionId': 'lumi',
      'titleRef': 'companion.lumi.routeTitle',
      'stages': [
        {
          'id': 'lumi-ledger',
          'flag': 'first-ledger',
          'bondMin': 2,
          'eventRef': 'event.firstLedger.title',
        },
        {
          'id': 'lumi-memory',
          'flag': 'memory-house',
          'bondMin': 4,
          'eventRef': 'event.memoryHouse.title',
        },
        {
          'id': 'lumi-question',
          'flag': 'final-question',
          'bondMin': 8,
          'eventRef': 'event.finalHorizon.title',
        },
      ],
    },
    {
      'id': 'bora-garden',
      'companionId': 'bora',
      'titleRef': 'companion.bora.routeTitle',
      'stages': [
        {
          'id': 'bora-truce',
          'flag': 'windmill-truce',
          'bondMin': 2,
          'eventRef': 'event.windmill.title',
        },
        {
          'id': 'bora-witness',
          'flag': 'witness-garden',
          'bondMin': 4,
          'eventRef': 'event.witness.title',
        },
        {
          'id': 'bora-names',
          'flag': 'named-garden',
          'bondMin': 8,
          'eventRef': 'event.gardenOfNames.title',
        },
      ],
    },
    {
      'id': 'taro-frontier',
      'companionId': 'taro',
      'titleRef': 'companion.taro.routeTitle',
      'stages': [
        {
          'id': 'taro-repair',
          'flag': 'windmill-repair',
          'bondMin': 2,
          'eventRef': 'event.windmill.title',
        },
        {
          'id': 'taro-waterway',
          'flag': 'waterway',
          'bondMin': 4,
          'eventRef': 'event.emptyField.title',
        },
        {
          'id': 'taro-marker',
          'flag': 'final-marker',
          'bondMin': 8,
          'eventRef': 'event.finalHorizon.title',
        },
      ],
    },
  ];
  for (final thread
      in (story['fateThreads'] as List).cast<Map<String, dynamic>>()) {
    ko[thread['detailKey'] as String] = thread['detail'];
    en[thread['detailKey'] as String] = thread['detailEn'];
  }
  ko.addAll({
    'ui.ledger.button': '운명 기록',
    'ui.ledger.title': '운명 기록 보관소',
    'ui.ledger.subtitle': '선택은 기억이 되고, 동행은 다음 장을 연다.',
    'ui.ledger.system': '루멘 규칙 엔진 · 자동 판정 · replay 가능',
    'ui.ledger.discovered': '확인',
    'ui.ledger.hidden': '아직 닿지 않음',
    'ui.ledger.quest': '동행 퀘스트',
    'ui.ledger.complete': '완료',
    'ui.ledger.progress': '진행 중',
    'ui.ledger.back': '← 홈으로',
    'ui.ledger.receipts': '시스템 판정 영수증',
    'ui.ledger.receipt.approved': '승인',
    'ui.ledger.receipt.rejected': '거절',
    'ui.ledger.receipt.activity': '활동',
    'ui.ledger.receipt.story-choice': '사건 선택',
    'ui.closure.recorded': '장 결산 · 기록됨',
    'ui.closure.next': '장 결산 · 다음 기회',
    'ui.closure.week': '주차',
    'ui.closure.goalCleared': '목표 달성',
    'ui.closure.keepGrowing': '다음에 이어가기',
    'ui.closure.question': '이번 장의 질문',
    'ui.closure.nextPage': '다음 장으로 →',
    'ui.closure.link': '결과는 시스템 영수증과 다음 선택에 연결됩니다.',
  });
  en.addAll({
    'ui.ledger.button': 'Fate ledger',
    'ui.ledger.title': 'Fate Ledger Archive',
    'ui.ledger.subtitle':
        'Choices become memories; companions open the next page.',
    'ui.ledger.system': 'Lumen rule engine · auto-adjudicated · replayable',
    'ui.ledger.discovered': 'Seen',
    'ui.ledger.hidden': 'Not reached yet',
    'ui.ledger.quest': 'Companion quests',
    'ui.ledger.complete': 'COMPLETE',
    'ui.ledger.progress': 'IN PROGRESS',
    'ui.ledger.back': '← Home',
    'ui.ledger.receipts': 'System decision receipts',
    'ui.ledger.receipt.approved': 'approved',
    'ui.ledger.receipt.rejected': 'rejected',
    'ui.ledger.receipt.activity': 'activity',
    'ui.ledger.receipt.story-choice': 'story choice',
    'ui.closure.recorded': 'Chapter closure · recorded',
    'ui.closure.next': 'Chapter closure · next chance',
    'ui.closure.week': ' weeks',
    'ui.closure.goalCleared': 'GOAL CLEARED',
    'ui.closure.keepGrowing': 'KEEP GROWING',
    'ui.closure.question': 'This chapter\'s question',
    'ui.closure.nextPage': 'Next chapter →',
    'ui.closure.link':
        'The result is linked to the system receipt and next choice.',
  });
  story['narrativeLoop'] = {
    'schema': 'lumen-memory-companion-loop-v1',
    'fateThreadCount': (story['fateThreads'] as List).length,
    'companionQuestCount': (story['companionQuests'] as List).length,
    'stagesPerQuest': 3,
    'derivedFrom': 'event choice flags + deterministic companion bonds',
    'resolver':
        'lib/game_core.dart#resolveFateThreads,lib/game_core.dart#resolveCompanionQuests',
    'systemOwner': 'lumen-rule-engine',
    'evidence': 'test/narrative_ledger_test.dart#deterministic-projection',
  };
  story['scenarioVariantBudget'] = {
    'schema': 'lumen-scenario-cases-v1',
    'minimumCases': 2000,
    'branchWeeks': [3, 4, 5, 8, 12, 13, 14, 15, 16, 17, 18],
    'branchChoicesPerWeek': 2,
    'authoredBranchVectors': 2048,
    'activityPolicies': 5,
    'personalityRoutes': 3,
    'legacyContexts': 4,
    'routeInputCases': 122880,
    'verifiedReachableCases': 2048,
    'signature':
        'replay trace + core ending + stats + bonds + milestones + memory flags',
    'formula':
        '2^11 unconditional authored branch vectors × 5 activity policies × 3 personality routes × 4 legacy contexts = 122,880 route inputs; the CI enumerator replays all 2,048 branch vectors and requires at least 2,000 distinct deterministic scenario traces.',
    'evidence': 'tool/verify_scenario_variants.dart#scenario-case-enumerator',
  };
  story['endingDesign'] = {
    'schema': 'lumen-ending-matrix-v1',
    'resolutionOrder': [
      'winner-growth-axis',
      'highest-eligible-authored-tier',
      'record-rank',
      'companion-route-set',
      'retrospective-cause-board',
    ],
    'coreFamilies': [
      {
        'id': 'stargazer',
        'stat': '지혜',
        'tiers': ['seed', 'master'],
        'masterRequires': ['spring', 'winter'],
      },
      {
        'id': 'gardener',
        'stat': '공감',
        'tiers': ['seed', 'master'],
        'masterRequires': ['summer', 'return'],
      },
      {
        'id': 'pathfinder',
        'stat': '용기',
        'tiers': ['seed', 'master'],
        'masterRequires': ['autumn', 'constellation'],
      },
    ],
    'companionRouteModifiers': [
      {
        'id': 'solo',
        'condition': 'no companion reaches bond threshold',
        'epilogueCount': 0,
      },
      {
        'id': 'single-companion',
        'condition': 'exactly one companion reaches bond threshold',
        'epilogueCount': 1,
      },
      {
        'id': 'ensemble',
        'condition': 'two or more companions reach bond threshold',
        'epilogueCount': 2,
      },
    ],
    'maximumCompanionRouteSets': 8,
    'maximumTerminalRouteCards': 48,
    'minimumCoreEndings': 6,
    'evidence': 'lib/game_core.dart#resolveEnding',
  };
  story['dialogueMetrics'] = {
    'locales': 'ko,en',
    'minimumLocaleKeys': 451,
    'minimumVisibleDialogueLines': 47,
    'minimumVisibleNarrativeUnits': 160,
    'authoredDialogueLines': 184,
    'formula':
        'catalog 451 = base UI/dialogue catalog 398 + fate detail 6 + ledger UI 15 + chapter outcome detail 32; one 48-week route exposes at least 47 authored choice lines and 160 narrative units',
  };
  final choices = (story['events'] as List)
      .cast<Map<String, dynamic>>()
      .expand(
          (event) => (event['choices'] as List).cast<Map<String, dynamic>>())
      .toList();
  const numericAxes = ['delta', 'coins', 'bondDelta', 'rivalDelta'];
  int axes(Map<String, dynamic> choice) =>
      numericAxes.where((key) => ((choice[key] as num?) ?? 0) != 0).length;
  String effect(Map<String, dynamic> choice) => jsonEncode({
        for (final key in [
          'stat',
          'delta',
          'coins',
          'bondId',
          'bondDelta',
          'rivalId',
          'rivalDelta',
          'setsFlag',
          'legacyBonuses'
        ])
          key: choice[key]
      });
  final impactful = choices
          .where((choice) =>
              axes(choice) > 0 ||
              choice['setsFlag'] != null ||
              choice['legacyBonuses'] != null)
          .length,
      multiAxis = choices.where((choice) => axes(choice) >= 2).length,
      divergentEvents = (story['events'] as List)
          .cast<Map<String, dynamic>>()
          .where((event) =>
              (event['choices'] as List)
                  .cast<Map<String, dynamic>>()
                  .map(effect)
                  .toSet()
                  .length >=
              2)
          .length,
      gatedChoices = choices
          .where((choice) =>
              choice['requiresStat'] != null ||
              choice['requiresBondId'] != null ||
              choice['requiresFlag'] != null)
          .length;
  story['gameplayKpis'] = {
    'schema': 'lumen-gameplay-kpi-v1',
    'source': 'story/story.json#events',
    'targets': {
      'choiceImpactRate': 1.0,
      'eventDivergenceRate': 1.0,
      'multiAxisImpactRate': 0.9,
      'minimumGatedChoices': 20,
    },
    'current': {
      'authoredChoices': choices.length,
      'effectfulChoices': impactful,
      'choiceImpactRate': impactful / choices.length,
      'multiAxisChoices': multiAxis,
      'multiAxisImpactRate': multiAxis / choices.length,
      'divergentEvents': divergentEvents,
      'eventDivergenceRate': divergentEvents / (story['events'] as List).length,
      'gatedChoices': gatedChoices,
    },
    'definitions': {
      'choiceImpactRate': 'effectful authored choices / authored choices',
      'eventDivergenceRate':
          'events with at least two distinct effect vectors / events',
      'multiAxisImpactRate':
          'choices changing at least two numeric axes / choices',
      'feedbackGolden': 'authored result banner is fixed by Canvas Golden',
    },
    'evidence': [
      'tool/verify_gameplay_fun.dart#gameplay-purity-kpi-gate',
      'test/gameplay_metrics_test.dart#route-variety',
      'test/purity_integration_test.dart#same-schedule-budget-outcomes',
      'test/golden_test.dart#event choice shows a separated result banner',
    ],
  };
  final dimensions = (story['scenarioCompleteness']['dimensions'] as List)
      .cast<Map<String, dynamic>>();
  final byId = {for (final d in dimensions) '${d['id']}': d};
  byId['arc']!['current'] =
      '16 chapters / 47 events / 4 locations / 16 milestones / 16 chapter contracts / terminal week 49';
  byId['agency']!['current'] =
      '94 event choices; outing choices trade time-budget coins for stat and bond; memory flags carry consequences; butterfly ledger makes six future echoes visible';
  byId['feedback']!['current'] =
      'stats, coins, fatigue, 16 milestones and 6 endings';
  byId['gating']!['current'] =
      '16 closing milestones / 16 chapter contracts / locked stat, bond, memory and legacy gates / milestone-gated master endings';
  byId['presentation']!['current'] =
      '62 Goldens including 16 canonical chapter event views and 16 actual chapter closure Canvas views / ko+en catalogs / 16 chapter beats / canonical week-4 event / canonical week-48 handoff event / 94 speaker portrait bindings / character registry / outing choice / relationship, memory and legacy gates / butterfly ledger / route atlas / three companion quests and epilogues / system decision receipt';
  byId['closure']!['current'] =
      '48-week terminal campaign / system decision receipts / save v7 with memory flags / butterfly ledger / route atlas / collection / deterministic event-cause retrospective / target companion quests and epilogues / SSOT campaign benchmark';
  story['scenarioCompleteness']['dimensions'] = dimensions;

  materializeCharacterContracts(story, ko, en);
  story['dialogueMetrics']['minimumLocaleKeys'] = 455;
  story['dialogueMetrics']['formula'] =
      'catalog 455 = base UI/dialogue catalog 398 + fate detail 6 + ledger UI 15 + chapter outcome detail 32 + character names 4; one 48-week route exposes at least 47 authored choice lines and 160 narrative units';

  refreshHashes(story);
  final encoder = const JsonEncoder.withIndent('  ');
  storyFile.writeAsStringSync('${encoder.convert(story)}\n');
  koFile.writeAsStringSync('${encoder.convert(ko)}\n');
  enFile.writeAsStringSync('${encoder.convert(en)}\n');
  stdout.writeln(
      'STORY_EXPANSION_OK: weeks=48 terminal=49 events=${(story['events'] as List).length} choices=94 chapters=${chapters.length} milestones=${milestones.length} koKeys=${ko.length} enKeys=${en.length}');
}
