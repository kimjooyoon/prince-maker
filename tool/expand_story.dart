import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:prince_maker/choice_impact.dart';
import 'package:prince_maker/jsonl.dart';

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

Map<String, dynamic> sideScene({
  required String id,
  required int unlockWeek,
  required String locationId,
  required String sceneType,
  required String mechanic,
  required String titleKo,
  required String titleEn,
  required String bodyKo,
  required String bodyEn,
  required String promptKo,
  required String promptEn,
  required String consequenceKo,
  required String consequenceEn,
  required List<Map<String, dynamic>> choices,
  List<String> requiresCompanions = const [],
}) =>
    {
      'id': id,
      'unlockWeek': unlockWeek,
      'locationId': locationId,
      'sceneType': sceneType,
      'mechanic': mechanic,
      'title': titleKo,
      'titleKey': 'event.$id.title',
      'titleEn': titleEn,
      'body': bodyKo,
      'bodyKey': 'event.$id.body',
      'bodyEn': bodyEn,
      'prompt': promptKo,
      'promptKey': 'event.$id.prompt',
      'promptEn': promptEn,
      'consequence': consequenceKo,
      'consequenceKey': 'event.$id.consequence',
      'consequenceEn': consequenceEn,
      'choices': choices,
      'requiresCompanions': requiresCompanions,
    };

Map<String, dynamic> companionScene({
  required String id,
  required String companionId,
  required int chapter,
  required String titleKo,
  required String titleEn,
  required String bodyKo,
  required String bodyEn,
  required String promptKo,
  required String promptEn,
  required String lineKo,
  required String lineEn,
  required String closingKo,
  required String closingEn,
}) =>
    {
      'id': id,
      'companionId': companionId,
      'chapter': chapter,
      'title': titleKo,
      'titleKey': 'companionScene.$id.title',
      'body': bodyKo,
      'bodyKey': 'companionScene.$id.body',
      'prompt': promptKo,
      'promptKey': 'companionScene.$id.prompt',
      'line': lineKo,
      'lineKey': 'companionScene.$id.line',
      'closing': closingKo,
      'closingKey': 'companionScene.$id.closing',
      'titleEn': titleEn,
      'bodyEn': bodyEn,
      'promptEn': promptEn,
      'lineEn': lineEn,
      'closingEn': closingEn,
    };

Map<String, dynamic> activityScene({
  required String id,
  required String activityId,
  required String titleKo,
  required String titleEn,
  required String momentKo,
  required String momentEn,
  required String lineKo,
  required String lineEn,
}) =>
    {
      'id': id,
      'activityId': activityId,
      'title': titleKo,
      'titleKey': 'activityScene.$id.title',
      'moment': momentKo,
      'momentKey': 'activityScene.$id.moment',
      'line': lineKo,
      'lineKey': 'activityScene.$id.line',
      'titleEn': titleEn,
      'momentEn': momentEn,
      'lineEn': lineEn,
    };

Map<String, dynamic> endingVariant({
  required String coreEndingId,
  required String variant,
  required String titleKo,
  required String titleEn,
  required String bodyKo,
  required String bodyEn,
}) =>
    {
      'id': '$coreEndingId.$variant',
      'coreEndingId': coreEndingId,
      'variant': variant,
      'title': titleKo,
      'titleKey': 'endingVariant.$coreEndingId.$variant.title',
      'body': bodyKo,
      'bodyKey': 'endingVariant.$coreEndingId.$variant.body',
      'titleEn': titleEn,
      'bodyEn': bodyEn,
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
    List<Map<String, dynamic>> choices,
    {String? promptKo,
    String? promptEn,
    String? consequenceKo,
    String? consequenceEn}) {
  ko['event.$id.title'] = titleKo;
  en['event.$id.title'] = titleEn;
  ko['event.$id.body'] = bodyKo;
  en['event.$id.body'] = bodyEn;
  if (promptKo != null && promptEn != null) {
    ko['event.$id.prompt'] = promptKo;
    en['event.$id.prompt'] = promptEn;
  }
  if (consequenceKo != null && consequenceEn != null) {
    ko['event.$id.consequence'] = consequenceKo;
    en['event.$id.consequence'] = consequenceEn;
  }
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
    'tool/trilemma_verdict.dart#closed-loop-receipt',
    'tool/verify_game.dart#visual-golden-contract',
    'lib/canvas_surface.dart#CanvasViewport',
    'lib/canvas_scene_fingerprint.dart#canvasSceneFingerprint',
    'lib/activity_catalog.dart#activitiesFromStory',
    'tool/verify_render_quality.dart#render-quality-preconditions',
    'test/chapter_golden_test.dart#all sixteen SSOT chapters have deterministic event Goldens',
    'test/chapter_closure_golden_test.dart#all sixteen SSOT chapter closures have deterministic goal Goldens',
    'tool/verify_gameplay_fun.dart#gameplay-purity-kpi-gate',
    'tool/verify_content_depth.dart#content-depth-gate',
    'test/content_depth_test.dart#SSOT exposes depth targets and all non-binary scene mechanics',
    'tool/verify_quality_score.dart#quality-score-99',
    'lib/character_roster.dart#archiveCharacters',
    'test/character_roster_test.dart#SSOT character archive binding',
    'test/character_roster_golden_test.dart#home opens the twenty-character archive',
    'lib/environment_catalog.dart#environmentsFromStory',
    'lib/design_tokens.dart#DesignTokens',
    'lib/canvas_ui_kit.dart#CanvasUiKit',
    'lib/choice_impact.dart#ChoiceImpact',
    'lib/ui_state_gallery.dart#CanvasUiStateGalleryPainter',
    'test/canvas_ui_kit_test.dart#Canvas UI primitives paint every required state',
    'test/choice_impact_test.dart#shared projection distinguishes a meaningful trade-off',
    'test/ui_design_contract_test.dart#design token catalog covers every game UI surface',
    'test/ui_state_golden_test.dart#Canvas UI state contract renders one deterministic matrix',
    'test/environment_catalog_test.dart#six locations expose a complete environment design contract',
    'test/environment_golden_test.dart#environment atlas renders the six gameplay surfaces',
    'tool/generate_development_goals.dart#buildDocument',
    'tool/verify_development_goals.dart#quantitative-evidence-gate',
    'lib/decision_receipt.dart#DecisionReceipt',
    'lib/decision_proof.dart#SystemDecisionPolicy',
    'tool/verify_decision_proof.dart#decision-proof-preconditions',
    'test/decision_proof_test.dart#same preconditions reproduce the same chain',
    'lib/game_core.dart#resolveRelationshipDynamics',
    'lib/main.dart#relationshipFollowup',
    'lib/game_core.dart#resolveRelationshipFollowup',
    'test/relationship_dynamics_test.dart#deterministic relationship states',
    'lib/jsonl.dart#decodeJsonl',
    'lib/quality_score.dart#qualityScoreModel',
    'tool/verify_jsonl.dart#jsonl-contract',
    'tool/refresh_ssot_contract_hashes.dart#storyHash',
    'test/jsonl_contract_test.dart#story JSONL is canonical and reconstructs authored collections',
    'test/quality_score_test.dart#quality score weights are a deterministic closed sum',
    'test/trilemma_verdict_test.dart#closed-loop-receipt',
  ];
  refs.removeWhere((entry) =>
      entry['ref'] == 'docs/decision-proof-contract.jsonl#preconditionFields' ||
      entry['ref'] ==
          'test/environment_catalog_test.dart#four locations expose a complete environment design contract' ||
      entry['ref'] ==
          'test/environment_golden_test.dart#environment atlas renders the four gameplay surfaces');
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
  final authoredScenes = [
    ...(story['events'] as List).cast<Map<String, dynamic>>(),
    ...(story['sideScenes'] as List? ?? const []).cast<Map<String, dynamic>>(),
  ];
  for (final event in authoredScenes) {
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

void materializeChapterScenes(Map<String, dynamic> story,
    Map<String, dynamic> ko, Map<String, dynamic> en) {
  const speakers = {
    'arrival': 'lumi',
    'crossing': 'taro',
    'reply': 'bora',
    'threshold': 'lumi',
    'frost': 'bora',
    'return': 'taro',
    'constellation': 'lumi',
    'horizon': 'bora',
    'seedReturn': 'taro',
    'fairShare': 'bora',
    'memoryHouse': 'lumi',
    'farShore': 'taro',
    'blankMap': 'lumi',
    'commons': 'bora',
    'returningGarden': 'bora',
    'handoff': 'taro',
  };
  const beats = <String, List<String>>{
    'arrival': [
      '편지의 첫 가장자리',
      '모르는 이름을 서둘러 채우지 말자. 빈칸도 함께 읽으면 길이 돼.',
      'The First Edge of a Letter',
      'Do not fill an unknown name too quickly. A blank can become a road when we read it together.'
    ],
    'crossing': [
      '부서진 다리의 박자',
      '한 번에 건너려 하지 마. 서로 다른 발걸음이 맞는 자리를 먼저 찾자.',
      'The Rhythm of a Broken Bridge',
      'Do not cross in one leap. Find the place where different footsteps can meet.'
    ],
    'reply': [
      '답장을 접는 손',
      '마음은 크게 약속할수록 무거워져. 오늘 지킬 만큼만 따뜻하게 접자.',
      'Hands Folding a Reply',
      'A promise grows heavy when it grows too large. Fold it warmly to the size we can keep today.'
    ],
    'threshold': [
      '첫 장부의 여백',
      '숫자와 목소리 사이에 여백을 남기면, 다음 사람이 물을 수 있어.',
      'The Margin of the First Ledger',
      'Leave a margin between numbers and voices, so the next person can still ask.'
    ],
    'frost': [
      '멈춘 계절의 온기',
      '자라지 않는 날도 돌봄의 날이야. 우리는 멈춤을 잊지 말자.',
      'Warmth in a Stopped Season',
      'A day without growth can still be a day of care. Let us not forget how to pause.'
    ],
    'return': [
      '돌아온 바람',
      '길이 돌아왔다고 처음으로 돌아간 건 아니야. 발자국이 방향을 고쳤으니까.',
      'The Wind That Returned',
      'A returning road is not the beginning again. The footsteps have corrected its direction.'
    ],
    'constellation': [
      '서로 다른 별자리',
      '같은 하늘 아래 이유가 다르면, 별을 잇는 선도 여러 개여야 해.',
      'Different Constellations',
      'When reasons differ beneath one sky, there must be more than one line between the stars.'
    ],
    'horizon': [
      '먼 영지의 목소리',
      '도움의 이름을 먼저 정하지 말고, 그곳의 목소리가 무엇을 필요로 하는지 들어보자.',
      'The Far Province Speaks',
      'Do not name help before listening to what the voices there actually need.'
    ],
    'seedReturn': [
      '빈 터의 첫 물길',
      '물을 나누는 건 소유를 잃는 일이 아니야. 다시 흐를 자리를 만드는 일이야.',
      'The First Waterway in the Empty Field',
      'Sharing water is not losing ownership. It is making a place where it can flow again.'
    ],
    'fairShare': [
      '공정한 하루',
      '빠른 사람의 속도를 기준으로 삼으면 돌봄은 늘 늦은 것으로 남아.',
      'A Fair Day',
      'If the fastest pace is the measure, care will always be left behind.'
    ],
    'memoryHouse': [
      '기억의 문턱',
      '기억을 모두 잠그지 말자. 다시 찾을 수 있는 표식 하나면 충분해.',
      'The Threshold of Memory',
      'Let us not lock every memory. One marker that can be found again is enough.'
    ],
    'farShore': [
      '건너온 답',
      '좋은 의도가 먼 곳에서 다른 힘이 될 수 있어. 돌아온 말을 먼저 고치자.',
      'The Answer That Crossed',
      'A good intention can become another force far away. First, repair the words that returned.'
    ],
    'blankMap': [
      '빈 지도 옆의 등불',
      '모른다는 말을 지우지 않으면, 같이 확인할 약속을 세울 수 있어.',
      'A Lamp Beside the Blank Map',
      'If we keep the words “we do not know,” we can promise to check together.'
    ],
    'commons': [
      '작은 목소리의 자리',
      '합의가 조용해질수록, 아직 들리지 않은 사람을 먼저 살펴야 해.',
      'A Place for the Small Voice',
      'The quieter an agreement becomes, the more we must look for someone not yet heard.'
    ],
    'returningGarden': [
      '떠남과 머묾의 정원',
      '꽃이 피는 자리만 고르지 말고, 떠나는 발걸음도 다치지 않을 자리를 남겨줘.',
      'A Garden for Leaving and Staying',
      'Do not choose only where flowers bloom. Leave a place where departing feet will not be hurt.'
    ],
    'handoff': [
      '다음 사람의 손',
      '마지막 장은 닫는 덮개가 아니야. 다음 사람이 다시 펼칠 손잡이야.',
      'The Next Person’s Hand',
      'The last page is not a cover that closes. It is a handle for the next person to open again.'
    ],
  };
  final companions = (story['companions'] as List).cast<Map<String, dynamic>>();
  for (final chapter
      in (story['progression'] as List).cast<Map<String, dynamic>>()) {
    final id = '${chapter['id']}', speakerId = speakers[id]!, beat = beats[id]!;
    final companion = companions.firstWhere((item) => item['id'] == speakerId);
    final prefix = 'chapter.$id.scene';
    chapter['relationshipScene'] = {
      'id': '$id-relationship',
      'speakerId': speakerId,
      'speakerNameKey': companion['nameKey'],
      'speakerPortraitAsset': companion['portraitAsset'],
      'speakerPortraitFrame': companion['portraitFrame'],
      'title': beat[0],
      'titleKey': '$prefix.title',
      'titleEn': beat[2],
      'line': beat[1],
      'lineKey': '$prefix.line',
      'lineEn': beat[3],
    };
    ko['$prefix.title'] = beat[0];
    ko['$prefix.line'] = beat[1];
    en['$prefix.title'] = beat[2];
    en['$prefix.line'] = beat[3];
  }
  story['chapterSceneContract'] = {
    'schema': 'lumen-chapter-scene-v1',
    'count': speakers.length,
    'purpose':
        'mid-chapter relationship beat rendered at deterministic closure',
    'evidence':
        'test/chapter_closure_golden_test.dart#relationship-scene-binding',
  };
}

void main() {
  final storyFile = File('story/story.jsonl');
  final koFile = File('story/locales/ko.jsonl');
  final enFile = File('story/locales/en.jsonl');
  final story = decodeJsonl(storyFile.readAsStringSync());
  final ko = decodeJsonl(koFile.readAsStringSync());
  final en = decodeJsonl(enFile.readAsStringSync());

  final newEvents = <Map<String, dynamic>>[];
  void add(Map<String, dynamic> e, String titleEn, String bodyEn) {
    newEvents.add(e);
    addEventLocale(ko, en, e['titleKey'].toString().split('.')[1], e['title'],
        titleEn, e['body'], bodyEn, (e['choices'] as List).cast());
  }

  final newSideScenes = <Map<String, dynamic>>[];
  void addSide(Map<String, dynamic> scene) {
    newSideScenes.add(scene);
    final id = '${scene['id']}';
    addEventLocale(
      ko,
      en,
      id,
      '${scene['title']}',
      '${scene['titleEn']}',
      '${scene['body']}',
      '${scene['bodyEn']}',
      (scene['choices'] as List).cast<Map<String, dynamic>>(),
      promptKo: '${scene['prompt']}',
      promptEn: '${scene['promptEn']}',
      consequenceKo: '${scene['consequence']}',
      consequenceEn: '${scene['consequenceEn']}',
    );
  }

  Map<String, dynamic> sideChoice(String eventId, Map<String, dynamic> raw) =>
      choice(
        eventId: eventId,
        id: '${raw['id']}',
        stat: '${raw['stat']}',
        delta: raw['delta'] as int,
        coins: raw['coins'] as int,
        bondId: '${raw['bondId']}',
        bondDelta: raw['bondDelta'] as int,
        labelKo: '${raw['labelKo']}',
        labelEn: '${raw['labelEn']}',
        lineKo: '${raw['lineKo']}',
        lineEn: '${raw['lineEn']}',
        rivalId: raw['rivalId'] as String?,
        rivalDelta: (raw['rivalDelta'] as int?) ?? 0,
        requiresStat: raw['requiresStat'] as String?,
        requiresMin: (raw['requiresMin'] as int?) ?? 0,
        requiresBondId: raw['requiresBondId'] as String?,
        requiresBondMin: (raw['requiresBondMin'] as int?) ?? 0,
        requiresFlag: raw['requiresFlag'] as String?,
        setsFlag: raw['setsFlag'] as String?,
      );
  Map<String, dynamic> seedSide(Map<String, dynamic> raw) {
    final id = '${raw['id']}',
        choices = (raw['choices'] as List)
            .cast<Map<String, dynamic>>()
            .map((c) => sideChoice(id, c))
            .toList();
    final scene = sideScene(
      id: id,
      unlockWeek: raw['unlockWeek'] as int,
      locationId: '${raw['locationId']}',
      sceneType: '${raw['sceneType']}',
      mechanic: '${raw['mechanic']}',
      titleKo: '${raw['titleKo']}',
      titleEn: '${raw['titleEn']}',
      bodyKo: '${raw['bodyKo']}',
      bodyEn: '${raw['bodyEn']}',
      promptKo: '${raw['promptKo']}',
      promptEn: '${raw['promptEn']}',
      consequenceKo: '${raw['consequenceKo']}',
      consequenceEn: '${raw['consequenceEn']}',
      choices: choices,
      requiresCompanions:
          (raw['requiresCompanions'] as List? ?? const []).cast<String>(),
    );
    scene['titleEn'] = raw['titleEn'];
    scene['bodyEn'] = raw['bodyEn'];
    scene['promptEn'] = raw['promptEn'];
    scene['consequenceEn'] = raw['consequenceEn'];
    return scene;
  }

  Map<String, dynamic> sideRawChoice({
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
    String? flag,
    String? requiresStat,
    int requiresMin = 0,
  }) =>
      {
        'id': id,
        'stat': stat,
        'delta': delta,
        'coins': coins,
        'bondId': bondId,
        'bondDelta': bondDelta,
        'labelKo': labelKo,
        'labelEn': labelEn,
        'lineKo': lineKo,
        'lineEn': lineEn,
        if (flag != null) 'setsFlag': flag,
        if (requiresStat != null) 'requiresStat': requiresStat,
        if (requiresStat != null) 'requiresMin': requiresMin,
      };
  Map<String, dynamic> sideRaw({
    required String id,
    required int unlockWeek,
    required String locationId,
    required String sceneType,
    required String mechanic,
    required String titleKo,
    required String titleEn,
    required String bodyKo,
    required String bodyEn,
    required String promptKo,
    required String promptEn,
    required String consequenceKo,
    required String consequenceEn,
    required List<Map<String, dynamic>> choices,
    List<String> requiresCompanions = const [],
  }) =>
      {
        'id': id,
        'unlockWeek': unlockWeek,
        'locationId': locationId,
        'sceneType': sceneType,
        'mechanic': mechanic,
        'titleKo': titleKo,
        'titleEn': titleEn,
        'bodyKo': bodyKo,
        'bodyEn': bodyEn,
        'promptKo': promptKo,
        'promptEn': promptEn,
        'consequenceKo': consequenceKo,
        'consequenceEn': consequenceEn,
        'choices': choices,
        'requiresCompanions': requiresCompanions,
      };
  final sideSeeds = <Map<String, dynamic>>[
    sideRaw(
      id: 'sideArchiveLantern',
      unlockWeek: 2,
      locationId: 'archive',
      sceneType: 'exploration',
      mechanic: 'clue-sort',
      titleKo: '꺼진 등불의 색인',
      titleEn: 'Index of the Unlit Lantern',
      bodyKo: '기록관 뒤편의 등불 세 개가 서로 다른 색으로 꺼졌다. 불을 켜기 전에 누가 무엇을 읽을지 정해야 한다.',
      bodyEn:
          'Three lanterns behind the archive went dark in different colours. Before lighting them, decide who gets to read what.',
      promptKo: '단서를 색·시간·사람 중 하나의 순서로 정렬한다.',
      promptEn:
          'Sort the clues by colour, time, or the people who carried them.',
      consequenceKo: '정렬 방식은 이후 기록을 읽는 루틴으로 남는다.',
      consequenceEn:
          'The sorting method remains as a reading routine for later records.',
      choices: [
        sideRawChoice(
            id: 'lumi',
            stat: '지혜',
            delta: 1,
            coins: 0,
            bondId: 'lumi',
            bondDelta: 2,
            labelKo: '루미와 시간순으로 맞춘다',
            labelEn: 'Order them by time with Lumi',
            lineKo: '먼저와 나중을 보이면 사라진 손도 다시 보일 거야.',
            lineEn:
                'When we show before and after, the missing hands can be seen again.',
            flag: 'side-archive-time'),
        sideRawChoice(
            id: 'bora',
            stat: '공감',
            delta: 1,
            coins: -1,
            bondId: 'bora',
            bondDelta: 2,
            labelKo: '보라와 사람순으로 맞춘다',
            labelEn: 'Order them by people with Bora',
            lineKo: '색보다 먼저 누가 기다렸는지를 놓치지 말자.',
            lineEn: 'Before colour, let us not lose who was waiting.',
            flag: 'side-archive-people'),
        sideRawChoice(
            id: 'taro',
            stat: '용기',
            delta: 2,
            coins: -1,
            bondId: 'taro',
            bondDelta: 2,
            labelKo: '타로와 직접 불을 옮긴다',
            labelEn: 'Move the flame by hand with Taro',
            lineKo: '어둠을 설명하기 전에 한 등불부터 다시 세워 보자.',
            lineEn:
                'Before explaining the dark, let us raise one lantern again.',
            flag: 'side-archive-flame'),
      ],
    ),
    sideRaw(
      id: 'sideArchiveIndex',
      unlockWeek: 8,
      locationId: 'archive',
      sceneType: 'resource-crisis',
      mechanic: 'resource-draft',
      titleKo: '비어 있는 서랍',
      titleEn: 'The Empty Drawer',
      bodyKo: '새 기록을 넣을 서랍이 하나뿐이다. 오래된 종이와 오늘의 증거 중 하나만 먼저 보존할 수 있다.',
      bodyEn:
          'Only one drawer remains for a new record. You can preserve either old paper or today’s evidence first.',
      promptKo: '은화와 보존 공간을 함께 계산해야 한다.',
      promptEn: 'Calculate coins and preservation space together.',
      consequenceKo: '무엇을 먼저 보존했는지가 기록의 빈칸으로 표시된다.',
      consequenceEn:
          'What you preserved first is marked as a gap in the record.',
      choices: [
        sideRawChoice(
            id: 'lumi',
            stat: '지혜',
            delta: 2,
            coins: -2,
            bondId: 'lumi',
            bondDelta: 2,
            labelKo: '오래된 종이를 먼저 묶는다',
            labelEn: 'Bind the old papers first',
            lineKo: '과거를 지켜야 오늘의 판단도 어디서 왔는지 보이지.',
            lineEn: 'Today’s judgement needs to show where it came from.',
            flag: 'side-archive-past',
            requiresStat: '지혜',
            requiresMin: 8),
        sideRawChoice(
            id: 'bora',
            stat: '공감',
            delta: 1,
            coins: -1,
            bondId: 'bora',
            bondDelta: 3,
            labelKo: '오늘 기다린 사람의 기록을 넣는다',
            labelEn: 'Keep the record of who waited today',
            lineKo: '기다린 시간도 한 사람의 하루였다는 걸 남기자.',
            lineEn: 'Leave proof that waiting was also someone’s day.',
            flag: 'side-archive-wait'),
        sideRawChoice(
            id: 'taro',
            stat: '용기',
            delta: 2,
            coins: 0,
            bondId: 'taro',
            bondDelta: 2,
            labelKo: '서랍을 고쳐 하나 더 만든다',
            labelEn: 'Repair the drawer and make one more',
            lineKo: '공간이 없다면 공간을 만드는 일부터 책임지자.',
            lineEn: 'If there is no room, take responsibility for making room.',
            flag: 'side-archive-space'),
      ],
    ),
    sideRaw(
      id: 'sideArchiveNight',
      unlockWeek: 16,
      locationId: 'archive',
      sceneType: 'companion-pair',
      mechanic: 'paired-reading',
      requiresCompanions: ['lumi', 'bora'],
      titleKo: '두 목소리의 여백',
      titleEn: 'Margin Between Two Voices',
      bodyKo: '루미와 보라가 같은 기록을 서로 다른 속도로 읽는다. 침묵을 오류로 볼지, 생각할 자리로 둘지 정해야 한다.',
      bodyEn:
          'Lumi and Bora read the same record at different speeds. Decide whether silence is an error or room to think.',
      promptKo: '두 동료의 해석을 겹치지 않게 남긴다.',
      promptEn:
          'Leave both companions’ interpretations without collapsing them.',
      consequenceKo: '한 문장에 두 개의 근거가 붙어 다음 사건의 조건이 된다.',
      consequenceEn:
          'Two reasons attach to one sentence and become a condition for a later event.',
      choices: [
        sideRawChoice(
            id: 'lumi',
            stat: '지혜',
            delta: 2,
            coins: 0,
            bondId: 'lumi',
            bondDelta: 3,
            labelKo: '루미의 여백을 측정한다',
            labelEn: 'Measure Lumi’s margin',
            lineKo: '말하지 않은 부분도 기록의 일부로 보이게 하자.',
            lineEn:
                'Let what was not said become visible as part of the record.',
            flag: 'side-paired-margin'),
        sideRawChoice(
            id: 'bora',
            stat: '공감',
            delta: 2,
            coins: -1,
            bondId: 'bora',
            bondDelta: 3,
            labelKo: '보라의 침묵을 기다린다',
            labelEn: 'Wait through Bora’s silence',
            lineKo: '대답을 재촉하지 않는 시간이 두 사람을 지켜 줘.',
            lineEn:
                'Time that does not hurry an answer can protect both people.',
            flag: 'side-paired-wait'),
        sideRawChoice(
            id: 'taro',
            stat: '용기',
            delta: 1,
            coins: 1,
            bondId: 'taro',
            bondDelta: 1,
            labelKo: '타로에게 읽는 규칙을 맡긴다',
            labelEn: 'Give Taro the reading rule',
            lineKo: '누가 읽을지 바뀌어도 근거가 남는지 시험해 보자.',
            lineEn: 'Test whether the reason remains when the reader changes.',
            flag: 'side-paired-rule'),
      ],
    ),
    sideRaw(
      id: 'sideArchiveWitness',
      unlockWeek: 30,
      locationId: 'archive',
      sceneType: 'exploration',
      mechanic: 'witness-chain',
      titleKo: '증인의 자리',
      titleEn: 'The Witness Seat',
      bodyKo: '오래된 증언의 마지막 칸이 비어 있다. 기억하는 사람과 기록하는 사람 중 누가 그 자리를 맡을까?',
      bodyEn:
          'The final seat in an old testimony is empty. Should the remembering person or the recording person take it?',
      promptKo: '증언의 순서를 세 명의 증인에게 다시 확인한다.',
      promptEn: 'Check the order of testimony with three witnesses again.',
      consequenceKo: '증인의 순서가 누락을 찾는 탐험 규칙이 된다.',
      consequenceEn:
          'The witness order becomes an exploration rule for finding omissions.',
      choices: [
        sideRawChoice(
            id: 'lumi',
            stat: '지혜',
            delta: 2,
            coins: 1,
            bondId: 'lumi',
            bondDelta: 2,
            labelKo: '루미에게 증언의 순서를 맡긴다',
            labelEn: 'Let Lumi hold the testimony order',
            lineKo: '기억을 믿되, 다시 확인할 계단도 남겨야 해.',
            lineEn: 'Trust memory, but leave steps for checking it again.',
            flag: 'side-witness-order'),
        sideRawChoice(
            id: 'bora',
            stat: '공감',
            delta: 2,
            coins: -1,
            bondId: 'bora',
            bondDelta: 2,
            labelKo: '보라와 빈 자리를 함께 지킨다',
            labelEn: 'Guard the empty seat with Bora',
            lineKo: '대신 이름을 채우지 않는 돌봄도 증언이 될 수 있어.',
            lineEn:
                'Care can also be testimony when it does not fill in a name.',
            flag: 'side-witness-empty'),
        sideRawChoice(
            id: 'taro',
            stat: '용기',
            delta: 2,
            coins: 0,
            bondId: 'taro',
            bondDelta: 2,
            labelKo: '타로와 현장 표식을 찾는다',
            labelEn: 'Find the field marker with Taro',
            lineKo: '종이 밖에 남은 흔적도 한 번은 직접 확인하자.',
            lineEn: 'Let us check the trace outside the paper at least once.',
            flag: 'side-witness-field'),
      ],
    ),
  ];
  sideSeeds.addAll([
    sideRaw(
        id: 'sideGreenhouseRain',
        unlockWeek: 4,
        locationId: 'greenhouse',
        sceneType: 'resource-crisis',
        mechanic: 'water-ration',
        titleKo: '비가 늦은 온실',
        titleEn: 'The Greenhouse Where Rain Is Late',
        bodyKo: '물이 모자란 날, 새싹과 오래된 나무가 같은 물통을 바라본다. 모두에게 같은 양이 공정할까?',
        bodyEn:
            'On a dry day, a sprout and an old tree look at the same bucket. Is equal water fair to both?',
        promptKo: '물의 양보다 기다린 시간과 회복 가능성을 비교한다.',
        promptEn:
            'Compare waiting time and recovery potential, not only the amount of water.',
        consequenceKo: '물 배분표가 자원 위기에서 다시 쓸 수 있는 규칙이 된다.',
        consequenceEn:
            'The water plan becomes a reusable rule for resource crises.',
        choices: [
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '기다린 순서대로 나눈다',
              labelEn: 'Share by waiting order',
              lineKo: '오래 기다린 마음부터 회복할 물을 건네자.',
              lineEn:
                  'Give recovery water first to those who have waited longest.',
              flag: 'side-rain-queue'),
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '회복 가능성을 계산한다',
              labelEn: 'Calculate recovery potential',
              lineKo: '같은 양이 아니라 다시 살아날 가능성을 같이 보자.',
              lineEn:
                  'Look at the chance to live again, not only equal portions.',
              flag: 'side-rain-recovery'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 1,
              coins: 1,
              bondId: 'taro',
              bondDelta: 2,
              labelKo: '다음 비를 받을 통을 만든다',
              labelEn: 'Build a barrel for the next rain',
              lineKo: '분배표를 고치기 전에 다음 비를 받을 곳을 만들자.',
              lineEn:
                  'Before fixing the table, make a place to catch the next rain.',
              flag: 'side-rain-barrel'),
        ]),
    sideRaw(
        id: 'sideGreenhouseSeed',
        unlockWeek: 12,
        locationId: 'greenhouse',
        sceneType: 'mini-game',
        mechanic: 'seed-match',
        titleKo: '씨앗 이름 맞추기',
        titleEn: 'Match the Seed Names',
        bodyKo: '라벨이 젖어 네 봉지의 이름이 번졌다. 생김새·계절·기억 중 두 단서를 골라야 한다.',
        bodyEn:
            'Rain blurred four seed labels. Choose two clues from shape, season, and memory.',
        promptKo: '단서 두 개만 사용해 씨앗과 자리를 맞춘다.',
        promptEn: 'Use only two clues to match seeds with their places.',
        consequenceKo: '맞춘 단서가 이후 수확의 이름과 보상에 남는다.',
        consequenceEn:
            'The clues you matched remain in the harvest name and reward.',
        choices: [
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: 1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '계절 기억을 고른다',
              labelEn: 'Choose the season memory',
              lineKo: '꽃이 핀 날을 기억하면 씨앗도 서두르지 않을 거야.',
              lineEn:
                  'If we remember the flowering day, the seed need not be hurried.',
              flag: 'side-seed-season'),
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '생김새 단서를 고른다',
              labelEn: 'Choose the shape clue',
              lineKo: '보이는 차이를 남기면 다음 사람도 다시 맞출 수 있어.',
              lineEn:
                  'Leave visible differences so the next person can match them again.',
              flag: 'side-seed-shape'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 2,
              labelKo: '시험 줄을 직접 심는다',
              labelEn: 'Plant a test row',
              lineKo: '모든 답을 기다리기보다 한 줄을 심어 확인하자.',
              lineEn:
                  'Instead of waiting for every answer, plant one row and check.',
              flag: 'side-seed-test'),
        ]),
    sideRaw(
        id: 'sideGreenhouseCompost',
        unlockWeek: 22,
        locationId: 'greenhouse',
        sceneType: 'exploration',
        mechanic: 'soil-layer',
        titleKo: '흙 아래의 편지',
        titleEn: 'Letter Beneath the Soil',
        bodyKo: '퇴비를 뒤집다 접힌 편지 한 장이 나온다. 누군가 버린 말인지, 일부러 묻은 약속인지 알 수 없다.',
        bodyEn:
            'A folded letter appears while turning the compost. It may be discarded words or a promise buried on purpose.',
        promptKo: '흙의 층과 편지의 접힌 방향을 함께 조사한다.',
        promptEn:
            'Investigate the soil layers and the direction of the fold together.',
        consequenceKo: '편지의 출처는 기억이 아니라 조사 가능한 단서로 남는다.',
        consequenceEn:
            'The letter’s source remains an investigable clue, not a memory.',
        choices: [
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '종이의 층을 기록한다',
              labelEn: 'Record the paper layers',
              lineKo: '편지보다 먼저 그것이 묻힌 시간을 읽어 보자.',
              lineEn: 'Before reading the letter, read when it was buried.',
              flag: 'side-compost-layer'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: -1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '봉투를 기다린다',
              labelEn: 'Wait for the envelope',
              lineKo: '누군가의 말을 대신 열어 버리지 않는 것도 돌봄이야.',
              lineEn: 'Care can mean not opening someone’s words for them.',
              flag: 'side-compost-wait'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: 1,
              bondId: 'taro',
              bondDelta: 2,
              labelKo: '묻힌 자리를 되짚는다',
              labelEn: 'Retrace the buried place',
              lineKo: '발자국이 사라지기 전에 누가 여기 왔는지 찾아 보자.',
              lineEn: 'Find who came here before the footprints disappear.',
              flag: 'side-compost-trace'),
        ]),
    sideRaw(
        id: 'sideGreenhouseBell',
        unlockWeek: 38,
        locationId: 'greenhouse',
        sceneType: 'companion-pair',
        mechanic: 'care-rotation',
        requiresCompanions: ['bora', 'taro'],
        titleKo: '새벽 종의 순서',
        titleEn: 'Order of the Dawn Bell',
        bodyKo: '온실 종이 울릴 때마다 한 사람이 먼저 일어난다. 돌봄을 의무로 만들지, 서로 바꿀 약속으로 만들지 선택한다.',
        bodyEn:
            'Each time the greenhouse bell rings, one person wakes first. Make care a duty, or a promise to rotate.',
        promptKo: '일어나는 순서와 회복 시간을 작은 표로 맞춘다.',
        promptEn: 'Match waking order and recovery time on a small table.',
        consequenceKo: '돌봄의 순환표가 동료 조합의 독립 기록이 된다.',
        consequenceEn:
            'The care rotation becomes an independent record of the companion pair.',
        choices: [
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '순서를 번갈아 적는다',
              labelEn: 'Alternate the order',
              lineKo: '돌봄을 한 사람의 성격으로 남기지 말고 바꿀 수 있게 하자.',
              lineEn:
                  'Do not make care one person’s nature; make it changeable.',
              flag: 'side-care-rotation'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: 0,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '종을 낮춘다',
              labelEn: 'Lower the bell',
              lineKo: '모두를 깨우는 소리보다 쉬어도 되는 신호가 필요해.',
              lineEn:
                  'We need a signal that allows rest, not a sound that wakes everyone.',
              flag: 'side-care-rest'),
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 1,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '표의 빈칸을 남긴다',
              labelEn: 'Leave blanks in the table',
              lineKo: '비어 있는 칸이 누구의 차례인지 말해 줄 거야.',
              lineEn: 'The blank spaces will tell us whose turn is missing.',
              flag: 'side-care-gap'),
        ]),
    sideRaw(
        id: 'sideMarketToken',
        unlockWeek: 6,
        locationId: 'market',
        sceneType: 'resource-crisis',
        mechanic: 'token-budget',
        titleKo: '한 닢의 표식',
        titleEn: 'The One-Coin Marker',
        bodyKo: '장터의 공동 지갑에 은화 한 닢만 남았다. 식사·씨앗·기록 도구 중 어디에 쓰면 다음 주가 덜 흔들릴까?',
        bodyEn:
            'Only one coin remains in the market’s shared purse. Which meal, seed, or record tool keeps next week steadier?',
        promptKo: '지금의 만족보다 다음 주의 선택 가능성을 계산한다.',
        promptEn:
            'Calculate next week’s choice space, not only today’s satisfaction.',
        consequenceKo: '마지막 한 닢을 쓴 방향이 자원관리 사건의 기준선이 된다.',
        consequenceEn:
            'Where the last coin went becomes the baseline for resource-management scenes.',
        choices: [
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: 0,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '오늘 함께 먹을 것을 산다',
              labelEn: 'Buy food to share today',
              lineKo: '다음 주를 위해 오늘의 배고픔을 숨기지는 말자.',
              lineEn: 'Do not hide today’s hunger for the sake of next week.',
              flag: 'side-market-meal'),
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '기록 잉크를 산다',
              labelEn: 'Buy record ink',
              lineKo: '계산할 근거가 없으면 남은 닢도 다시 잃게 돼.',
              lineEn:
                  'Without evidence to calculate, the remaining coin is lost again.',
              flag: 'side-market-ink'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: 0,
              bondId: 'taro',
              bondDelta: 2,
              labelKo: '다음 씨앗을 예약한다',
              labelEn: 'Reserve the next seed',
              lineKo: '불확실해도 다음 시작을 살 자리는 남겨 두자.',
              lineEn:
                  'Even with uncertainty, leave room to buy the next beginning.',
              flag: 'side-market-seed'),
        ]),
    sideRaw(
        id: 'sideMarketScale',
        unlockWeek: 14,
        locationId: 'market',
        sceneType: 'mini-game',
        mechanic: 'fair-scale',
        titleKo: '저울의 세 칸',
        titleEn: 'Three Notches on the Scale',
        bodyKo: '상인들의 저울 눈금이 조금씩 다르다. 빠르게 맞출지, 서로의 오차를 먼저 보일지 선택한다.',
        bodyEn:
            'The merchants’ scale marks differ slightly. Match them quickly, or expose each error first.',
        promptKo: '세 번의 측정 중 두 번 이상 같은 기준을 찾아야 한다.',
        promptEn:
            'Find the shared standard in at least two of three measurements.',
        consequenceKo: '측정 기준은 장터의 가격과 신뢰를 함께 바꾼다.',
        consequenceEn:
            'The measurement standard changes both market prices and trust.',
        choices: [
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '오차를 먼저 공개한다',
              labelEn: 'Publish the errors first',
              lineKo: '맞는 숫자보다 틀릴 수 있는 폭을 같이 보여 주자.',
              lineEn:
                  'Show the possible error range along with the right number.',
              flag: 'side-scale-error'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: 1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '불리한 사람부터 잰다',
              labelEn: 'Measure the least advantaged first',
              lineKo: '저울이 누구에게 먼저 기울었는지부터 확인하자.',
              lineEn: 'First check whom the scale tilted toward.',
              flag: 'side-scale-care'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 2,
              labelKo: '새 눈금을 박는다',
              labelEn: 'Set a new mark',
              lineKo: '오래된 눈금이 틀렸다면 오늘 바꾸는 책임을 지자.',
              lineEn:
                  'If the old mark is wrong, take responsibility for changing it today.',
              flag: 'side-scale-new'),
        ]),
    sideRaw(
        id: 'sideMarketQuiet',
        unlockWeek: 26,
        locationId: 'market',
        sceneType: 'exploration',
        mechanic: 'rumour-map',
        titleKo: '소문이 지나간 자리',
        titleEn: 'Where a Rumour Passed',
        bodyKo: '장터에 같은 소문이 세 방향으로 번졌다. 말의 출발점보다, 그 말 때문에 비어 버린 자리를 먼저 찾는다.',
        bodyEn:
            'The same rumour spread in three directions. Find the spaces it emptied before finding its source.',
        promptKo: '소문을 믿음·피해·확인 요청의 세 표식으로 나눈다.',
        promptEn:
            'Split the rumour into belief, harm, and requests for verification.',
        consequenceKo: '소문을 다루는 표식이 이후 공개 회의의 입구가 된다.',
        consequenceEn:
            'The rumour markers become the entrance to a later public council.',
        choices: [
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '비어 버린 자리를 찾는다',
              labelEn: 'Find the emptied spaces',
              lineKo: '사실을 말하기 전에 그 말이 밀어낸 사람을 보자.',
              lineEn: 'Before speaking facts, see whom the words pushed away.',
              flag: 'side-rumour-harm'),
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '출처의 경로를 그린다',
              labelEn: 'Map the source path',
              lineKo: '소문은 한 점이 아니라 여러 손을 거쳐 온 경로야.',
              lineEn: 'A rumour is a path through many hands, not one point.',
              flag: 'side-rumour-path'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 1,
              coins: 1,
              bondId: 'taro',
              bondDelta: 2,
              labelKo: '확인 요청을 공개한다',
              labelEn: 'Publish a verification request',
              lineKo: '틀릴까 봐 조용히 있기보다 확인할 문을 열자.',
              lineEn:
                  'Instead of staying quiet for fear of being wrong, open a door to check.',
              flag: 'side-rumour-ask'),
        ]),
    sideRaw(
        id: 'sideMarketReturn',
        unlockWeek: 42,
        locationId: 'market',
        sceneType: 'companion-pair',
        mechanic: 'shared-contract',
        requiresCompanions: ['lumi', 'taro'],
        titleKo: '시장 끝의 계약서',
        titleEn: 'Contract at the Market’s Edge',
        bodyKo: '마지막 장터에서 루미와 타로가 서로 다른 계약서를 내민다. 한 장으로 합치면 무엇이 사라질까?',
        bodyEn:
            'At the last market, Lumi and Taro offer different contracts. What disappears if they become one?',
        promptKo: '계약의 공통 조항과 서로 양보할 수 없는 조항을 분리한다.',
        promptEn:
            'Separate shared clauses from clauses neither side can surrender.',
        consequenceKo: '합쳐지지 않은 조항도 다음 사람의 협상 기록으로 남는다.',
        consequenceEn:
            'Clauses that cannot merge remain the next person’s negotiation record.',
        choices: [
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 4,
              labelKo: '공통 조항을 세운다',
              labelEn: 'Build shared clauses',
              lineKo: '계약을 짧게 만들기보다 무엇이 함께 남는지 보이자.',
              lineEn:
                  'Instead of shortening the contract, show what remains shared.',
              flag: 'side-contract-common'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '양보할 수 없는 선을 긋는다',
              labelEn: 'Draw the non-negotiable line',
              lineKo: '좋은 합의는 넘지 말아야 할 선도 숨기지 않아.',
              lineEn:
                  'A good agreement does not hide the line it must not cross.',
              flag: 'side-contract-line'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: 0,
              bondId: 'bora',
              bondDelta: 2,
              labelKo: '사라진 조항을 묻는다',
              labelEn: 'Ask about the missing clause',
              lineKo: '서명 뒤에 남은 침묵이 누구의 비용인지 물어야 해.',
              lineEn: 'Ask whose cost is carried by the silence after signing.',
              flag: 'side-contract-silence'),
        ]),
  ]);
  sideSeeds.addAll([
    sideRaw(
        id: 'sideRiverRope',
        unlockWeek: 10,
        locationId: 'river-road',
        sceneType: 'exploration',
        mechanic: 'route-memory',
        titleKo: '끊어진 밧줄의 지도',
        titleEn: 'Map of the Broken Rope',
        bodyKo: '강을 건너는 밧줄이 세 곳에서 닳았다. 어느 매듭을 먼저 고칠지에 따라 탐험 가능한 길이 달라진다.',
        bodyEn:
            'The river rope is worn at three places. Which knot you fix first changes the route you can explore.',
        promptKo: '물살·거리·돌아올 표식을 함께 기억해야 한다.',
        promptEn: 'Remember current, distance, and a marker for the return.',
        consequenceKo: '선택한 매듭이 강 건너 탐험의 첫 기준점이 된다.',
        consequenceEn:
            'The knot you choose becomes the first reference point for crossing.',
        choices: [
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '가장 센 물살을 고친다',
              labelEn: 'Fix the strongest current',
              lineKo: '가장 위험한 곳을 먼저 알아야 돌아오는 길도 남아.',
              lineEn:
                  'We must know the most dangerous place first to leave a way back.',
              flag: 'side-rope-current'),
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '돌아올 표식을 계산한다',
              labelEn: 'Calculate a return marker',
              lineKo: '건너는 용기만큼 돌아올 근거도 필요해.',
              lineEn: 'A reason to return matters as much as courage to cross.',
              flag: 'side-rope-return'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: 1,
              bondId: 'bora',
              bondDelta: 2,
              labelKo: '기다릴 자리를 만든다',
              labelEn: 'Make a waiting place',
              lineKo: '건너는 사람뿐 아니라 기다리는 사람도 길의 일부야.',
              lineEn: 'The people waiting are part of the route too.',
              flag: 'side-rope-wait'),
        ]),
    sideRaw(
        id: 'sideRiverTide',
        unlockWeek: 18,
        locationId: 'river-road',
        sceneType: 'mini-game',
        mechanic: 'tide-timing',
        requiresCompanions: ['taro'],
        titleKo: '물결의 세 박자',
        titleEn: 'Three Beats of the Current',
        bodyKo: '강물은 세 번 숨을 고른 뒤 다시 빨라진다. 타로와 발을 맞출지, 표식을 보고 혼자 건널지 결정한다.',
        bodyEn:
            'The river pauses for three breaths before speeding up. Match Taro’s steps, or cross alone by the markers.',
        promptKo: '멈춤·건넘·귀환의 박자를 기억하는 미니게임이다.',
        promptEn: 'Remember the beats of pause, crossing, and return.',
        consequenceKo: '맞춘 박자가 이후 위기 상황의 피로 비용을 낮춘다.',
        consequenceEn:
            'The matched rhythm lowers fatigue costs in a later crisis.',
        choices: [
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: 0,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '세 박자를 따라간다',
              labelEn: 'Follow the three beats',
              lineKo: '혼자 빠르기보다 서로 같은 때를 기다려 보자.',
              lineEn:
                  'Instead of being fast alone, let us wait for the same moment.',
              flag: 'side-tide-rhythm'),
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '표식만 보고 건넌다',
              labelEn: 'Cross by the markers',
              lineKo: '박자를 잊어도 다시 읽을 표식이 있으면 돼.',
              lineEn:
                  'Even if the rhythm is forgotten, a marker can be read again.',
              flag: 'side-tide-marker'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: -1,
              bondId: 'bora',
              bondDelta: 2,
              labelKo: '강가에 남는다',
              labelEn: 'Stay by the river',
              lineKo: '건너지 않는 선택도 함께 지키는 선택일 수 있어.',
              lineEn:
                  'Choosing not to cross can also be a choice to protect together.',
              flag: 'side-tide-stay'),
        ]),
    sideRaw(
        id: 'sideRiverMarker',
        unlockWeek: 32,
        locationId: 'river-road',
        sceneType: 'resource-crisis',
        mechanic: 'marker-budget',
        titleKo: '표식에 쓸 재료',
        titleEn: 'Material for a Marker',
        bodyKo: '돌·천·잉크 중 하나만 충분하다. 오래 가는 표식과 지금 찾기 쉬운 표식의 비용이 다르다.',
        bodyEn:
            'There is enough of only stone, cloth, or ink. Durable and easy-to-find markers cost different things.',
        promptKo: '은화와 탐험 가능성을 한 번에 비교한다.',
        promptEn: 'Compare coins and exploration access at once.',
        consequenceKo: '재료 선택은 지도의 빈칸을 공개하는 방식으로 되돌아온다.',
        consequenceEn:
            'The material choice returns as the way the map reveals its blank.',
        choices: [
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -2,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '돌로 오래 남긴다',
              labelEn: 'Make it last with stone',
              lineKo: '다음 비바람 뒤에도 누군가 찾을 수 있어야 해.',
              lineEn: 'Someone must be able to find it after the next storm.',
              flag: 'side-marker-stone'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: -1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '천으로 멀리서 보이게 한다',
              labelEn: 'Make it visible with cloth',
              lineKo: '오래보다 먼저 지금 돌아올 사람이 볼 수 있어야 해.',
              lineEn:
                  'Before lasting, it must be visible to the person returning now.',
              flag: 'side-marker-cloth'),
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '잉크로 근거를 남긴다',
              labelEn: 'Leave the reason in ink',
              lineKo: '표식만 아니라 왜 그곳에 세웠는지도 읽혀야 해.',
              lineEn:
                  'The reason for the marker must be readable, not only the marker.',
              flag: 'side-marker-ink'),
        ]),
    sideRaw(
        id: 'sideRiverQuestion',
        unlockWeek: 46,
        locationId: 'river-road',
        sceneType: 'companion-pair',
        mechanic: 'handoff-crossing',
        requiresCompanions: ['bora', 'taro'],
        titleKo: '강 건너 첫 질문',
        titleEn: 'First Question Across the River',
        bodyKo: '마지막 건넘에서 보라와 타로가 다음 여행자에게 남길 질문을 고른다. 답보다 질문의 방향이 길을 만든다.',
        bodyEn:
            'At the final crossing, Bora and Taro choose a question for the next traveller. Its direction makes the road, not its answer.',
        promptKo: '돌아올 사람도 다시 물을 수 있는 문장을 만든다.',
        promptEn: 'Write a sentence the returning traveller can ask again.',
        consequenceKo: '첫 질문은 넘겨지는 지평의 독립 에필로그로 남는다.',
        consequenceEn:
            'The first question remains as an independent epilogue of the passed horizon.',
        choices: [
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: 0,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '누가 아직 기다리는지 묻는다',
              labelEn: 'Ask who is still waiting',
              lineKo: '길의 끝보다 길가에 남은 마음부터 다시 보자.',
              lineEn:
                  'Before the road’s end, look again at the hearts left beside it.',
              flag: 'side-question-wait'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '어디서 다시 시작할지 묻는다',
              labelEn: 'Ask where to begin again',
              lineKo: '끝을 설명하기보다 다음 발이 닿을 곳을 남기자.',
              lineEn:
                  'Instead of explaining the end, leave where the next foot can land.',
              flag: 'side-question-start'),
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 1,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '무엇을 모르는지 묻는다',
              labelEn: 'Ask what remains unknown',
              lineKo: '빈칸을 숨기지 않는 질문이 가장 오래 살아남아.',
              lineEn: 'The question that hides no blank survives the longest.',
              flag: 'side-question-unknown'),
        ]),
  ]);
  sideSeeds.addAll([
    sideRaw(
        id: 'sideObservatoryCloud',
        unlockWeek: 8,
        locationId: 'observatory',
        sceneType: 'exploration',
        mechanic: 'cloud-window',
        titleKo: '구름 뒤의 작은 별',
        titleEn: 'Small Star Behind the Cloud',
        bodyKo: '구름이 별 하나를 가린 밤, 관측소의 창문 세 곳이 서로 다른 방향을 가리킨다. 무엇을 먼저 확인할까?',
        bodyEn:
            'On a night when clouds hide one star, three observatory windows point in different directions. What comes first?',
        promptKo: '보이는 것과 보이지 않는 것을 같은 지도에 표시한다.',
        promptEn: 'Mark the visible and invisible on the same map.',
        consequenceKo: '가려진 별도 관측 가능한 대상이라는 기준을 남긴다.',
        consequenceEn:
            'Leave the rule that a hidden star is still an observable subject.',
        choices: [
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '빈 하늘을 측정한다',
              labelEn: 'Measure the empty sky',
              lineKo: '안 보이는 곳도 측정하면 다음 밤의 기준이 돼.',
              lineEn:
                  'Measuring what cannot be seen becomes a standard for the next night.',
              flag: 'side-cloud-blank'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 2,
              labelKo: '지붕 위로 오른다',
              labelEn: 'Climb the roof',
              lineKo: '창문을 믿기 전에 시야가 바뀌는 곳까지 가 보자.',
              lineEn: 'Before trusting the windows, go where the view changes.',
              flag: 'side-cloud-roof'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: 1,
              bondId: 'bora',
              bondDelta: 2,
              labelKo: '구름을 기다린다',
              labelEn: 'Wait for the cloud',
              lineKo: '보이지 않는 시간을 함께 보내는 것도 관측이야.',
              lineEn: 'Spending unseen time together is also observation.',
              flag: 'side-cloud-wait'),
        ]),
    sideRaw(
        id: 'sideObservatoryLens',
        unlockWeek: 20,
        locationId: 'observatory',
        sceneType: 'resource-crisis',
        mechanic: 'lens-repair',
        titleKo: '금 간 렌즈',
        titleEn: 'The Cracked Lens',
        bodyKo: '렌즈 하나에 금이 갔다. 관측을 멈추고 고칠지, 금 간 시야로 오늘의 하늘을 남길지 결정해야 한다.',
        bodyEn:
            'One lens has cracked. Stop to repair it, or record today’s sky through the damaged view.',
        promptKo: '정확도와 기록의 연속성을 자원으로 비교한다.',
        promptEn: 'Compare accuracy and continuity of the record as resources.',
        consequenceKo: '금 간 시야의 한계가 판정 영수증에 표시된다.',
        consequenceEn:
            'The damaged view’s limit is shown on the decision receipt.',
        choices: [
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: -2,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '렌즈를 먼저 고친다',
              labelEn: 'Repair the lens first',
              lineKo: '기록이 이어져도 다시 검증할 수 없다면 길을 잃어.',
              lineEn:
                  'A continuous record is lost if it cannot be verified again.',
              flag: 'side-lens-repair'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: 0,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '금 간 하늘도 남긴다',
              labelEn: 'Record the cracked sky too',
              lineKo: '흠집을 숨기지 않은 오늘도 다음 판단의 증거야.',
              lineEn:
                  'Today’s unhidden flaw is also evidence for the next judgement.',
              flag: 'side-lens-flaw'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: -1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '기다릴 사람에게 먼저 알린다',
              labelEn: 'Tell waiting people first',
              lineKo: '정확한 답보다 기다리는 사람이 알아야 할 사실을 먼저 건네자.',
              lineEn:
                  'Before a precise answer, give waiting people the fact they need.',
              flag: 'side-lens-notice'),
        ]),
    sideRaw(
        id: 'sideObservatorySignal',
        unlockWeek: 34,
        locationId: 'observatory',
        sceneType: 'companion-pair',
        mechanic: 'signal-pattern',
        requiresCompanions: ['lumi', 'taro'],
        titleKo: '두 번 울린 신호',
        titleEn: 'The Signal That Rang Twice',
        bodyKo:
            '먼 곳에서 신호가 두 번 울렸다. 루미는 좌표를, 타로는 길의 안전을 먼저 본다. 둘을 하나의 출발점으로 묶을 수 있을까?',
        bodyEn:
            'A distant signal rang twice. Lumi reads coordinates; Taro reads route safety. Can both become one starting point?',
        promptKo: '신호의 순서와 실제 발걸음의 순서를 맞춘다.',
        promptEn: 'Match the signal order with the order of actual footsteps.',
        consequenceKo: '짝을 이룬 신호는 후반 탐험의 분기 조건이 된다.',
        consequenceEn:
            'The paired signal becomes a branch condition for later exploration.',
        choices: [
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 4,
              labelKo: '좌표를 먼저 고정한다',
              labelEn: 'Fix the coordinates first',
              lineKo: '갈 곳을 잃지 않아야 안전을 다시 계산할 수 있어.',
              lineEn:
                  'We need a destination fixed before safety can be recalculated.',
              flag: 'side-signal-coordinate'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '안전한 발판부터 확인한다',
              labelEn: 'Check safe footholds first',
              lineKo: '좌표가 맞아도 발을 놓을 곳이 없다면 못 가.',
              lineEn:
                  'Even a correct coordinate cannot be reached without a foothold.',
              flag: 'side-signal-foothold'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: 0,
              bondId: 'bora',
              bondDelta: 2,
              labelKo: '신호를 기다린 사람을 묻는다',
              labelEn: 'Ask who waited for the signal',
              lineKo: '신호를 보낸 사람의 하루도 지도에 같이 있어야 해.',
              lineEn: 'The sender’s day must be on the map too.',
              flag: 'side-signal-sender'),
        ]),
    sideRaw(
        id: 'sideObservatoryDawn',
        unlockWeek: 44,
        locationId: 'observatory',
        sceneType: 'mini-game',
        mechanic: 'constellation-trace',
        titleKo: '새벽의 별자리 잇기',
        titleEn: 'Connect the Dawn Constellation',
        bodyKo: '새벽빛이 별 세 개의 선을 지운다. 남은 점과 기억한 방향으로 하나의 별자리를 다시 그려야 한다.',
        bodyEn:
            'Dawn erases the lines between three stars. Redraw one constellation from remaining points and remembered direction.',
        promptKo: '세 점 중 두 점의 근거를 선택하고 마지막 점은 열어 둔다.',
        promptEn:
            'Choose reasons for two points and leave the last point open.',
        consequenceKo: '완성하지 않은 점 하나가 다음 사람의 탐험 초대가 된다.',
        consequenceEn:
            'One unfinished point becomes an invitation for the next explorer.',
        choices: [
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 4,
              labelKo: '두 점의 근거를 기록한다',
              labelEn: 'Record reasons for two points',
              lineKo: '모든 선을 닫지 않아도 다시 그릴 근거는 남길 수 있어.',
              lineEn:
                  'We can leave reasons to redraw without closing every line.',
              flag: 'side-dawn-reason'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: 0,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '지워진 선을 직접 따라간다',
              labelEn: 'Follow the erased line by hand',
              lineKo: '사라진 길도 발로 확인하면 다음 손이 이어갈 수 있어.',
              lineEn: 'A vanished road can be continued when checked by foot.',
              flag: 'side-dawn-walk'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: -1,
              bondId: 'bora',
              bondDelta: 3,
              labelKo: '빈 점을 다음 사람에게 남긴다',
              labelEn: 'Leave the blank point for the next person',
              lineKo: '완성되지 않은 곳을 함께 기다리는 약속도 별자리야.',
              lineEn:
                  'A constellation can be a promise to wait together at an unfinished place.',
              flag: 'side-dawn-open'),
        ]),
  ]);
  sideSeeds.addAll([
    sideRaw(
        id: 'sideQuarryEcho',
        unlockWeek: 12,
        locationId: 'quarry',
        sceneType: 'exploration',
        mechanic: 'echo-map',
        titleKo: '채석장의 메아리',
        titleEn: 'Echo in the Quarry',
        bodyKo: '돌벽 안쪽에서 같은 노래가 세 번 돌아온다. 메아리의 방향이 숨은 길인지, 빈 벽인지 찾아야 한다.',
        bodyEn:
            'The same song returns three times inside the quarry. Find whether its direction is a hidden route or an empty wall.',
        promptKo: '소리의 간격과 발걸음의 위치를 겹쳐 본다.',
        promptEn:
            'Overlay the gaps between sounds with the positions of footsteps.',
        consequenceKo: '메아리의 간격이 탐험 지도의 새로운 눈금이 된다.',
        consequenceEn:
            'The echo interval becomes a new scale on the exploration map.',
        choices: [
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '소리가 큰 벽을 연다',
              labelEn: 'Open the loudest wall',
              lineKo: '길일 수도 있는 벽을 한 번은 직접 두드려 보자.',
              lineEn: 'Knock once on a wall that might be a road.',
              flag: 'side-echo-wall'),
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '메아리 간격을 잰다',
              labelEn: 'Measure the intervals',
              lineKo: '메아리도 반복되면 기록 가능한 패턴이 돼.',
              lineEn: 'An echo becomes a recordable pattern when it repeats.',
              flag: 'side-echo-pattern'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: 1,
              bondId: 'bora',
              bondDelta: 2,
              labelKo: '노래를 기다린다',
              labelEn: 'Wait for the song',
              lineKo: '누군가 부른 노래라면 돌아올 시간도 함께 들어야 해.',
              lineEn:
                  'If someone sang it, we must hear the time it takes to return.',
              flag: 'side-echo-song'),
        ]),
    sideRaw(
        id: 'sideQuarryLift',
        unlockWeek: 24,
        locationId: 'quarry',
        sceneType: 'resource-crisis',
        mechanic: 'load-balance',
        requiresCompanions: ['bora', 'taro'],
        titleKo: '무거운 돌 하나',
        titleEn: 'One Heavy Stone',
        bodyKo: '길을 막은 돌 하나를 옮기려면 모두의 힘을 빌려야 한다. 빠르게 들지, 쉬는 순서를 먼저 만들지 결정한다.',
        bodyEn:
            'Everyone’s strength is needed to move one stone blocking the route. Lift quickly, or make a rest order first.',
        promptKo: '힘·피로·돌아올 자원을 함께 배분한다.',
        promptEn:
            'Allocate strength, fatigue, and resources for the return together.',
        consequenceKo: '돌을 옮긴 순서가 동료 조합의 위기 대응 기록으로 남는다.',
        consequenceEn:
            'The lifting order remains as the companion pair’s crisis response record.',
        choices: [
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: 0,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '먼저 힘을 모은다',
              labelEn: 'Gather strength first',
              lineKo: '한 번에 옮기지 못해도 같이 들 수 있다는 걸 남기자.',
              lineEn:
                  'Even if it does not move at once, leave proof we can lift together.',
              flag: 'side-lift-strength'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: -1,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '쉬는 순서를 만든다',
              labelEn: 'Make a rest order',
              lineKo: '돌보다 사람이 먼저 돌아올 수 있어야 해.',
              lineEn: 'People must be able to return before the stone does.',
              flag: 'side-lift-rest'),
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 1,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 2,
              labelKo: '무게를 다시 잰다',
              labelEn: 'Measure the weight again',
              lineKo: '무거움의 감각을 숫자로 바꾸면 다음 계산이 달라져.',
              lineEn:
                  'Turning heaviness into a number changes the next calculation.',
              flag: 'side-lift-measure'),
        ]),
    sideRaw(
        id: 'sideQuarryLedger',
        unlockWeek: 36,
        locationId: 'quarry',
        sceneType: 'mini-game',
        mechanic: 'stone-pattern',
        titleKo: '돌의 무늬 읽기',
        titleEn: 'Read the Stone Pattern',
        bodyKo: '돌마다 금의 방향이 다르다. 세 조각 중 둘의 무늬를 맞춰야 안전한 통로를 고를 수 있다.',
        bodyEn:
            'Each stone has a different crack direction. Match two of three patterns to choose a safe passage.',
        promptKo: '무늬·소리·빛 중 두 단서를 선택한다.',
        promptEn: 'Choose two clues from pattern, sound, and light.',
        consequenceKo: '고른 단서가 채석장 탈출 경로의 공개 기준이 된다.',
        consequenceEn:
            'The chosen clues become the public standard for the quarry exit route.',
        choices: [
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 0,
              bondId: 'lumi',
              bondDelta: 3,
              labelKo: '무늬와 빛을 맞춘다',
              labelEn: 'Match pattern and light',
              lineKo: '보이는 선과 숨은 균열이 만나는 지점을 찾자.',
              lineEn: 'Find where visible lines meet hidden cracks.',
              flag: 'side-stone-light'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 3,
              labelKo: '소리를 두드려 확인한다',
              labelEn: 'Check by tapping the sound',
              lineKo: '안전한 길인지 손끝으로 확인하는 책임을 지자.',
              lineEn:
                  'Take responsibility for checking the route with our fingertips.',
              flag: 'side-stone-sound'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 1,
              coins: 1,
              bondId: 'bora',
              bondDelta: 2,
              labelKo: '누가 걸을지 먼저 묻는다',
              labelEn: 'Ask who will walk it first',
              lineKo: '길의 안전은 사람의 몸과 함께 읽어야 해.',
              lineEn: 'A route’s safety must be read with the people’s bodies.',
              flag: 'side-stone-body'),
        ]),
    sideRaw(
        id: 'sideQuarryExit',
        unlockWeek: 48,
        locationId: 'quarry',
        sceneType: 'companion-pair',
        mechanic: 'handoff-cairn',
        requiresCompanions: ['lumi', 'bora', 'taro'],
        titleKo: '세 손의 돌무더기',
        titleEn: 'Cairn Made by Three Hands',
        bodyKo: '세 동료가 각자 다른 돌을 하나씩 고른다. 돌무더기는 기념비가 아니라 다음 길을 찾는 장치가 되어야 한다.',
        bodyEn:
            'Each of the three companions chooses a different stone. The cairn must guide the next road, not become a monument.',
        promptKo: '세 돌의 위치·이름·돌아올 방향을 함께 기록한다.',
        promptEn:
            'Record the three stones’ positions, names, and return direction together.',
        consequenceKo: '세 손의 돌무더기가 여섯 장소를 잇는 마지막 탐험 증거가 된다.',
        consequenceEn:
            'The three-handed cairn becomes the final exploration evidence linking six places.',
        choices: [
          sideRawChoice(
              id: 'lumi',
              stat: '지혜',
              delta: 2,
              coins: 1,
              bondId: 'lumi',
              bondDelta: 4,
              labelKo: '세 돌의 좌표를 남긴다',
              labelEn: 'Leave all three coordinates',
              lineKo: '기념보다 다시 찾을 수 있는 좌표가 오래 남아.',
              lineEn:
                  'Coordinates that can be found again last longer than a monument.',
              flag: 'side-cairn-coordinates'),
          sideRawChoice(
              id: 'bora',
              stat: '공감',
              delta: 2,
              coins: 0,
              bondId: 'bora',
              bondDelta: 4,
              labelKo: '세 돌의 이름을 서로 읽는다',
              labelEn: 'Read each stone’s name aloud',
              lineKo: '각자의 돌을 함께 불러야 한 길이 되지 않아.',
              lineEn: 'A single route needs us to call each stone together.',
              flag: 'side-cairn-names'),
          sideRawChoice(
              id: 'taro',
              stat: '용기',
              delta: 2,
              coins: -1,
              bondId: 'taro',
              bondDelta: 4,
              labelKo: '돌무더기에서 다음 길로 나선다',
              labelEn: 'Set out from the cairn',
              lineKo: '표식은 멈추라고만 있는 게 아니라 다시 가라고 있는 거야.',
              lineEn: 'A marker does not only say stop; it also says go again.',
              flag: 'side-cairn-departure'),
        ]),
  ]);
  for (final raw in sideSeeds) addSide(seedSide(raw));

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

  final locations = (story['locations'] as List).cast<Map<String, dynamic>>();
  final extraLocations = [
    {
      'id': 'observatory',
      'name': '새벽 관측소',
      'nameKey': 'location.observatory.name',
      'kind': 'observation',
    },
    {
      'id': 'quarry',
      'name': '별씨앗 채석장',
      'nameKey': 'location.quarry.name',
      'kind': 'resource',
    },
  ];
  for (final location in extraLocations) {
    locations.removeWhere((item) => item['id'] == location['id']);
    locations.add(location);
    ko['${location['nameKey']}'] = '${location['name']}';
    en['${location['nameKey']}'] = location['id'] == 'observatory'
        ? 'Dawn Observatory'
        : 'Star-seed Quarry';
  }
  story['locations'] = locations;
  final existingSideScenes =
      (story['sideScenes'] as List? ?? const []).cast<Map<String, dynamic>>();
  final sideById = <String, Map<String, dynamic>>{
    for (final scene in existingSideScenes) '${scene['id']}': scene,
  };
  for (final scene in newSideScenes) sideById['${scene['id']}'] = scene;
  story['sideScenes'] = sideById.values.toList()
    ..sort(
        (a, b) => (a['unlockWeek'] as int).compareTo(b['unlockWeek'] as int));

  final activities = (story['activities'] as List).cast<Map<String, dynamic>>();
  const activityIds = ['observatory', 'garden', 'workshop', 'rest', 'market'];
  for (var i = 0; i < activities.length && i < activityIds.length; i++) {
    activities[i]['id'] ??= activityIds[i];
  }
  final activityScenes = [
    activityScene(
        id: 'observatory-mist',
        activityId: 'observatory',
        titleKo: '안개 속 첫 별',
        titleEn: 'First Star in the Mist',
        momentKo: '관측소의 지붕이 안개에 잠겼다.',
        momentEn: 'The observatory roof sank into mist.',
        lineKo: '보이지 않는 날도 하늘의 일부로 적어 두자.',
        lineEn: 'Record the unseen day as part of the sky.'),
    activityScene(
        id: 'observatory-late',
        activityId: 'observatory',
        titleKo: '늦은 별자리',
        titleEn: 'A Late Constellation',
        momentKo: '별 하나가 예상보다 늦게 나타났다.',
        momentEn: 'One star appeared later than expected.',
        lineKo: '늦었다는 사실이 틀렸다는 뜻은 아니야.',
        lineEn: 'Being late does not mean being wrong.'),
    activityScene(
        id: 'garden-thin-leaf',
        activityId: 'garden',
        titleKo: '얇은 잎의 방향',
        titleEn: 'Direction of a Thin Leaf',
        momentKo: '얇은 잎 하나가 바람을 거슬러 자랐다.',
        momentEn: 'A thin leaf grew against the wind.',
        lineKo: '약한 방향도 계속되면 정원이 기억해.',
        lineEn: 'A fragile direction becomes memorable when it continues.'),
    activityScene(
        id: 'garden-shared-water',
        activityId: 'garden',
        titleKo: '함께 든 물통',
        titleEn: 'A Bucket Carried Together',
        momentKo: '물통의 손잡이를 두 사람이 함께 잡았다.',
        momentEn: 'Two people held the bucket handle together.',
        lineKo: '무게가 반으로 줄지 않아도 혼자 들지 않을 수 있어.',
        lineEn: 'The weight need not halve for no one to carry it alone.'),
    activityScene(
        id: 'workshop-loose-nail',
        activityId: 'workshop',
        titleKo: '느슨한 못',
        titleEn: 'The Loose Nail',
        momentKo: '작은 못 하나가 계속 흔들렸다.',
        momentEn: 'One small nail kept shaking loose.',
        lineKo: '작은 흔들림을 고치면 다음 실패가 덜 커져.',
        lineEn: 'Fixing a small shake keeps the next failure smaller.'),
    activityScene(
        id: 'workshop-scrap',
        activityId: 'workshop',
        titleKo: '남은 조각',
        titleEn: 'The Remaining Piece',
        momentKo: '버려질 조각에서 맞는 모서리를 찾았다.',
        momentEn: 'A matching edge was found in the scrap pile.',
        lineKo: '남은 것은 낭비가 아니라 다음 설계의 단서가 될 수 있어.',
        lineEn: 'What remains can be a clue for the next design, not waste.'),
    activityScene(
        id: 'rest-window',
        activityId: 'rest',
        titleKo: '창가의 쉼표',
        titleEn: 'Comma by the Window',
        momentKo: '창가의 빛이 하루의 속도를 늦췄다.',
        momentEn: 'Window light slowed the day’s pace.',
        lineKo: '멈춤도 다음 선택을 오래 보게 하는 활동이야.',
        lineEn: 'Rest is an activity that lets the next choice stay visible.'),
    activityScene(
        id: 'rest-unread',
        activityId: 'rest',
        titleKo: '읽지 않은 쪽',
        titleEn: 'The Unread Page',
        momentKo: '읽지 않은 쪽을 남겨 둔 채 책을 덮었다.',
        momentEn: 'The book closed with one page unread.',
        lineKo: '모든 빈칸을 오늘 채우지 않아도 기록은 이어져.',
        lineEn:
            'The record continues even when every blank is not filled today.'),
    activityScene(
        id: 'market-small-change',
        activityId: 'market',
        titleKo: '작은 거스름돈',
        titleEn: 'Small Change',
        momentKo: '상인이 거스름돈을 한 번 더 세었다.',
        momentEn: 'A merchant counted the change one more time.',
        lineKo: '다시 세는 습관이 은화보다 오래 남아.',
        lineEn: 'The habit of counting again lasts longer than the coin.'),
    activityScene(
        id: 'market-warm-bread',
        activityId: 'market',
        titleKo: '따뜻한 빵의 방향',
        titleEn: 'Direction of Warm Bread',
        momentKo: '빵 하나가 가장 늦게 온 사람에게 먼저 갔다.',
        momentEn: 'A loaf went first to the person who arrived last.',
        lineKo: '순서를 바꾸는 작은 친절도 장터의 규칙이 돼.',
        lineEn:
            'A small kindness that changes order can become a market rule.'),
  ];
  story['activityScenes'] = activityScenes;
  for (final scene in activityScenes) {
    for (final field in ['title', 'moment', 'line']) {
      ko['${scene['${field}Key']}'] = '${scene[field]}';
      en['${scene['${field}Key']}'] = '${scene['${field}En']}';
    }
  }

  final endingVariants = [
    endingVariant(
        coreEndingId: 'stargazer',
        variant: 'failure',
        titleKo: '흐린 별의 기록',
        titleEn: 'Record Beneath Clouded Stars',
        bodyKo: '별을 다 읽지는 못했지만, 어디가 흐렸는지는 남겼다.',
        bodyEn:
            'The stars were not fully read, but where they blurred was recorded.'),
    endingVariant(
        coreEndingId: 'stargazer',
        variant: 'neutral',
        titleKo: '다시 보는 별자리',
        titleEn: 'A Constellation to Revisit',
        bodyKo: '노아는 해답보다 다음 관측의 기준을 남겼다.',
        bodyEn:
            'Noa left a standard for the next observation rather than a final answer.'),
    endingVariant(
        coreEndingId: 'stargazer',
        variant: 'relationship',
        titleKo: '둘이 읽은 새벽',
        titleEn: 'Dawn Read Together',
        bodyKo: '루미와 노아는 같은 하늘을 다른 근거로 읽으며 기록을 이어 갔다.',
        bodyEn:
            'Lumi and Noa continued the record, reading one sky from different reasons.'),
    endingVariant(
        coreEndingId: 'stargazer-master',
        variant: 'failure',
        titleKo: '계산 밖의 새벽',
        titleEn: 'Dawn Outside the Calculation',
        bodyKo: '지도는 완성되지 않았고, 다음 사람이 고칠 빈칸을 남겼다.',
        bodyEn:
            'The map stayed unfinished and left blanks for the next person to repair.'),
    endingVariant(
        coreEndingId: 'stargazer-master',
        variant: 'neutral',
        titleKo: '열린 항로',
        titleEn: 'An Open Course',
        bodyKo: '별과 바람의 주기는 누구나 다시 검증할 수 있는 길이 되었다.',
        bodyEn:
            'The cycles of stars and wind became a course anyone could verify again.'),
    endingVariant(
        coreEndingId: 'stargazer-master',
        variant: 'relationship',
        titleKo: '루미의 별표',
        titleEn: 'Lumi’s Star Mark',
        bodyKo: '루미는 마지막 장에 노아와 함께 다시 읽을 별표를 남겼다.',
        bodyEn: 'Lumi left a star mark to reread with Noa on the final page.'),
    endingVariant(
        coreEndingId: 'gardener',
        variant: 'failure',
        titleKo: '아직 마르지 않은 흙',
        titleEn: 'Soil Not Yet Dry',
        bodyKo: '정원은 피지 않았지만, 물이 부족했던 날의 이름은 남았다.',
        bodyEn:
            'The garden did not bloom, but the names of dry days remained.'),
    endingVariant(
        coreEndingId: 'gardener',
        variant: 'neutral',
        titleKo: '함께 쉬는 정원',
        titleEn: 'A Garden That Rests Together',
        bodyKo: '노아는 성장 속도보다 서로 회복할 시간을 정원에 심었다.',
        bodyEn:
            'Noa planted time to recover together rather than a faster growth rate.'),
    endingVariant(
        coreEndingId: 'gardener',
        variant: 'relationship',
        titleKo: '보라의 계절표',
        titleEn: 'Bora’s Season Table',
        bodyKo: '보라와 노아는 매 계절 돌봄의 순서를 다시 읽는 정원을 만들었다.',
        bodyEn:
            'Bora and Noa made a garden that rereads the order of care each season.'),
    endingVariant(
        coreEndingId: 'gardener-master',
        variant: 'failure',
        titleKo: '닫힌 온실의 불빛',
        titleEn: 'Light in the Closed Greenhouse',
        bodyKo: '광장은 열리지 않았지만, 누구를 기다렸는지는 다음 장에 남았다.',
        bodyEn:
            'The commons did not open, but who waited remains in the next chapter.'),
    endingVariant(
        coreEndingId: 'gardener-master',
        variant: 'neutral',
        titleKo: '공동의 온기',
        titleEn: 'Shared Warmth',
        bodyKo: '서로 다른 속도가 함께 쉴 수 있는 규칙이 되었다.',
        bodyEn:
            'Different paces became a rule that lets everyone rest together.'),
    endingVariant(
        coreEndingId: 'gardener-master',
        variant: 'relationship',
        titleKo: '보라와 열린 문',
        titleEn: 'The Open Gate with Bora',
        bodyKo: '보라와 노아는 닫아야 할 때와 열어 둘 때를 함께 기록했다.',
        bodyEn:
            'Bora and Noa recorded together when to close and when to leave the gate open.'),
    endingVariant(
        coreEndingId: 'pathfinder',
        variant: 'failure',
        titleKo: '길 앞의 멈춤',
        titleEn: 'A Pause Before the Road',
        bodyKo: '첫 발은 늦었지만, 멈춰야 했던 이유가 표식으로 남았다.',
        bodyEn:
            'The first step was late, but the reason to pause became a marker.'),
    endingVariant(
        coreEndingId: 'pathfinder',
        variant: 'neutral',
        titleKo: '이름 없는 길',
        titleEn: 'The Unnamed Road',
        bodyKo: '노아는 모든 길에 이름을 붙이지 않고 다시 찾을 기준을 남겼다.',
        bodyEn:
            'Noa left ways to find the road again without naming every road.'),
    endingVariant(
        coreEndingId: 'pathfinder',
        variant: 'relationship',
        titleKo: '타로와 다음 발판',
        titleEn: 'The Next Foothold with Taro',
        bodyKo: '타로와 노아는 지도 밖에서도 서로 확인할 발판을 만들었다.',
        bodyEn:
            'Taro and Noa made footholds they could check even beyond the map.'),
    endingVariant(
        coreEndingId: 'pathfinder-master',
        variant: 'failure',
        titleKo: '아직 건너지 않은 경계',
        titleEn: 'The Boundary Not Yet Crossed',
        bodyKo: '경계를 넘지 못했지만, 위험한 곳과 돌아올 곳은 표시했다.',
        bodyEn:
            'The boundary was not crossed, but dangers and returns were marked.'),
    endingVariant(
        coreEndingId: 'pathfinder-master',
        variant: 'neutral',
        titleKo: '다시 건널 표식',
        titleEn: 'Marker for Crossing Again',
        bodyKo: '두려움이 사라지지 않아도 다음 사람이 길을 재현할 수 있게 되었다.',
        bodyEn:
            'Even with fear intact, the next person can reproduce the route.'),
    endingVariant(
        coreEndingId: 'pathfinder-master',
        variant: 'relationship',
        titleKo: '타로가 남긴 방향',
        titleEn: 'Taro’s Direction',
        bodyKo: '타로와 노아는 마지막 표식을 다음 여행자의 출발점으로 넘겼다.',
        bodyEn:
            'Taro and Noa passed the final marker on as the next traveller’s start.'),
  ];
  story['endingVariants'] = endingVariants;
  for (final variant in endingVariants) {
    ko['${variant['titleKey']}'] = '${variant['title']}';
    en['${variant['titleKey']}'] = '${variant['titleEn']}';
    ko['${variant['bodyKey']}'] = '${variant['body']}';
    en['${variant['bodyKey']}'] = '${variant['bodyEn']}';
  }

  final companionSceneSeeds = <Map<String, dynamic>>[
    {
      'id': 'lumi-first-margin',
      'companionId': 'lumi',
      'chapter': 1,
      'titleKo': '첫 여백을 접는 법',
      'titleEn': 'How to Fold the First Margin',
      'themeKo': '빈칸을 지우지 않고 모서리를 접는다.',
      'themeEn': 'folds the corner without erasing the blank.',
      'lineKo': '빈칸이 있어야 다음 사람이 어디를 봐야 하는지 알 수 있어.',
      'lineEn': 'A blank tells the next person where to look.'
    },
    {
      'id': 'lumi-slow-star',
      'companionId': 'lumi',
      'chapter': 3,
      'titleKo': '느린 별의 이름',
      'titleEn': 'Name of a Slow Star',
      'themeKo': '예측보다 늦게 뜬 별을 오래 바라본다.',
      'themeEn': 'watches a star rise later than predicted.',
      'lineKo': '늦게 도착한 사실도 사실의 자리를 가질 수 있어.',
      'lineEn': 'A late-arriving fact can still have a place among facts.'
    },
    {
      'id': 'lumi-open-ledger',
      'companionId': 'lumi',
      'chapter': 5,
      'titleKo': '열린 장부의 첫 줄',
      'titleEn': 'First Line of an Open Ledger',
      'themeKo': '누구나 읽을 수 있는 장부의 첫 줄을 비워 둔다.',
      'themeEn': 'leaves the first line of a public ledger open.',
      'lineKo': '공개는 다 보여 주는 일이 아니라 다시 물을 자리를 남기는 일이야.',
      'lineEn': 'Openness leaves a place where someone can ask again.'
    },
    {
      'id': 'lumi-cloud-measure',
      'companionId': 'lumi',
      'chapter': 7,
      'titleKo': '구름의 측정값',
      'titleEn': 'Measurement of a Cloud',
      'themeKo': '숫자로 잡히지 않는 구름의 한계를 표시한다.',
      'themeEn': 'marks the limit of a cloud that resists numbers.',
      'lineKo': '측정 한계를 보이는 것도 정확함의 일부야.',
      'lineEn': 'Showing a measurement limit is part of accuracy.'
    },
    {
      'id': 'lumi-two-signals',
      'companionId': 'lumi',
      'chapter': 11,
      'titleKo': '두 번 울린 신호',
      'titleEn': 'The Twice-Rung Signal',
      'themeKo': '두 신호 사이의 간격을 지도에 남긴다.',
      'themeEn': 'leaves the interval between two signals on the map.',
      'lineKo': '삭제된 시작도 다음 판단의 원인이 될 수 있어.',
      'lineEn': 'A deleted beginning can still cause the next judgement.'
    },
    {
      'id': 'lumi-first-question',
      'companionId': 'lumi',
      'chapter': 16,
      'titleKo': '다음 사람의 질문',
      'titleEn': 'The Next Person’s Question',
      'themeKo': '마지막 장에 답 대신 질문 하나를 남긴다.',
      'themeEn': 'leaves one question instead of an answer on the last page.',
      'lineKo': '좋은 기록은 답을 닫지 않고 다음 손을 초대해.',
      'lineEn':
          'A good record does not close the answer; it invites the next hand.'
    },
    {
      'id': 'bora-shared-water',
      'companionId': 'bora',
      'chapter': 2,
      'titleKo': '같이 든 물통',
      'titleEn': 'The Shared Water Bucket',
      'themeKo': '같은 물통을 두 사람이 들 수 있도록 손잡이를 고친다.',
      'themeEn': 'repairs the handle so two people can carry one bucket.',
      'lineKo': '무게가 줄지 않아도 혼자 들지 않게 만들 수 있어.',
      'lineEn': 'The weight may not shrink, but no one has to carry it alone.'
    },
    {
      'id': 'bora-waiting-seat',
      'companionId': 'bora',
      'chapter': 4,
      'titleKo': '기다리는 자리',
      'titleEn': 'A Place to Wait',
      'themeKo': '늦게 오는 사람이 앉을 의자를 온실 문 앞에 둔다.',
      'themeEn': 'places a chair for the late arrival by the greenhouse gate.',
      'lineKo': '기다리는 시간도 함께 만든 하루의 일부야.',
      'lineEn': 'Waiting time is part of the day we make together.'
    },
    {
      'id': 'bora-first-harvest',
      'companionId': 'bora',
      'chapter': 6,
      'titleKo': '첫 수확의 몫',
      'titleEn': 'Share of the First Harvest',
      'themeKo': '작은 첫 수확을 누구에게 먼저 건넬지 멈춰 선다.',
      'themeEn': 'pauses over who receives the small first harvest.',
      'lineKo': '공정함은 모두에게 같은 조각이 아니라 기준을 함께 읽는 일이야.',
      'lineEn':
          'Fairness is reading the standard together, not giving everyone the same piece.'
    },
    {
      'id': 'bora-care-ledger',
      'companionId': 'bora',
      'chapter': 8,
      'titleKo': '돌봄의 영수증',
      'titleEn': 'Receipt for Care',
      'themeKo': '보이지 않는 돌봄 시간을 장부의 빈칸에서 꺼낸다.',
      'themeEn': 'pulls invisible care time out of the ledger’s blank.',
      'lineKo': '기록되지 않은 수고는 없는 일이 되기 쉬워.',
      'lineEn': 'Unrecorded effort is easily treated as if it never happened.'
    },
    {
      'id': 'bora-rain-queue',
      'companionId': 'bora',
      'chapter': 12,
      'titleKo': '비를 기다리는 순서',
      'titleEn': 'Order of Waiting for Rain',
      'themeKo': '비가 늦어진 온실에서 기다린 순서를 다시 부른다.',
      'themeEn': 'calls the waiting order again in the late-rain greenhouse.',
      'lineKo': '순서도 사람의 상태를 만날 때 다시 읽어야 해.',
      'lineEn': 'Order must be reread when it meets a person’s condition.'
    },
    {
      'id': 'bora-open-garden',
      'companionId': 'bora',
      'chapter': 15,
      'titleKo': '열린 정원의 문',
      'titleEn': 'Gate of the Open Garden',
      'themeKo': '정원의 문을 잠그는 대신 누구나 볼 표식을 단다.',
      'themeEn': 'marks the garden for all to see instead of locking its gate.',
      'lineKo': '열어 두는 일에도 다시 닫을 수 있는 기준이 필요해.',
      'lineEn': 'Openness still needs a rule for closing again.'
    },
    {
      'id': 'taro-broken-rope',
      'companionId': 'taro',
      'chapter': 1,
      'titleKo': '끊어진 밧줄의 매듭',
      'titleEn': 'Knot in the Broken Rope',
      'themeKo': '강 건너 밧줄의 가장 닳은 매듭을 먼저 잡는다.',
      'themeEn': 'grabs the most worn knot on the river rope first.',
      'lineKo': '먼저 고친 곳이 다음 사람이 믿을 발판이 돼.',
      'lineEn': 'The first repair becomes a foothold the next person can trust.'
    },
    {
      'id': 'taro-first-workshop',
      'companionId': 'taro',
      'chapter': 3,
      'titleKo': '공방의 첫 못',
      'titleEn': 'The Workshop’s First Nail',
      'themeKo': '느슨한 못 하나를 버리지 않고 다시 박는다.',
      'themeEn': 'resets one loose nail instead of throwing it away.',
      'lineKo': '고치는 시간도 만드는 시간의 일부로 세어 줘.',
      'lineEn': 'Count repair time as part of making.'
    },
    {
      'id': 'taro-roof-line',
      'companionId': 'taro',
      'chapter': 6,
      'titleKo': '지붕 위의 선',
      'titleEn': 'Line on the Roof',
      'themeKo': '구름 뒤의 별을 보기 위해 지붕 위에 선을 긋는다.',
      'themeEn': 'draws a line on the roof to see the star behind clouds.',
      'lineKo': '경계는 멈추게도 하지만 어디서 다시 시작할지도 알려 줘.',
      'lineEn': 'A boundary can stop us and tell us where to start again.'
    },
    {
      'id': 'taro-field-marker',
      'companionId': 'taro',
      'chapter': 9,
      'titleKo': '빈 터의 표식',
      'titleEn': 'Marker in the Empty Field',
      'themeKo': '누군가 돌아올 높이로 빈 터에 돌을 쌓는다.',
      'themeEn': 'stacks stones at the height of someone returning.',
      'lineKo': '표식은 만드는 사람보다 돌아오는 사람의 몸을 먼저 생각해야 해.',
      'lineEn':
          'A marker must think first of the returning body, not its maker.'
    },
    {
      'id': 'taro-quarry-weight',
      'companionId': 'taro',
      'chapter': 13,
      'titleKo': '돌의 무게를 나누기',
      'titleEn': 'Divide the Stone’s Weight',
      'themeKo': '채석장의 돌을 혼자 들려다 다른 손을 부른다.',
      'themeEn':
          'calls for another hand while trying to lift a quarry stone alone.',
      'lineKo': '용기는 혼자 버티는 힘이 아니라 손을 부르는 힘이기도 해.',
      'lineEn': 'Courage is also the strength to call for another hand.'
    },
    {
      'id': 'taro-next-foothold',
      'companionId': 'taro',
      'chapter': 16,
      'titleKo': '다음 발판',
      'titleEn': 'The Next Foothold',
      'themeKo': '마지막 길에 답 대신 발을 놓을 곳을 표시한다.',
      'themeEn': 'marks where a foot can land instead of leaving an answer.',
      'lineKo': '끝난 길도 다음 발이 닿으면 다시 시작할 수 있어.',
      'lineEn': 'A finished road can begin again when the next foot lands.'
    },
  ];
  final companionNames = {'lumi': '루미', 'bora': '보라', 'taro': '타로'},
      companionNamesEn = {'lumi': 'Lumi', 'bora': 'Bora', 'taro': 'Taro'};
  final companionScenes = companionSceneSeeds.map((raw) {
    final id = '${raw['id']}',
        companionId = '${raw['companionId']}',
        nameKo = companionNames[companionId]!,
        nameEn = companionNamesEn[companionId]!;
    return companionScene(
      id: id,
      companionId: companionId,
      chapter: raw['chapter'] as int,
      titleKo: '${raw['titleKo']}',
      titleEn: '${raw['titleEn']}',
      bodyKo: '$nameKo와 노아는 ${raw['themeKo']}',
      bodyEn: '$nameEn and Noa ${raw['themeEn']}',
      promptKo: '$nameKo의 판단을 대신 정하지 않고, 다음 질문을 함께 고른다.',
      promptEn:
          'Choose the next question together without deciding ${nameEn}’s judgement for them.',
      lineKo: '${raw['lineKo']}',
      lineEn: '${raw['lineEn']}',
      closingKo: '$nameKo의 독립 장면은 다음 막의 조건으로 기록되었다.',
      closingEn:
          '$nameEn’s independent scene was recorded as a condition for the next chapter.',
    );
  }).toList();
  story['companionScenes'] = companionScenes;
  for (final scene in companionScenes) {
    for (final field in ['title', 'body', 'prompt', 'line', 'closing']) {
      ko['${scene['${field}Key']}'] = '${scene[field]}';
      en['${scene['${field}Key']}'] = '${scene['${field}En']}';
    }
  }

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
    'estimatedFirstPlaythroughMinutes': 156,
    'benchmarkMaxMillis': 24000,
    'campaignWeeks': 48,
    'terminalWeek': 49,
    'authoredEvents': 47,
    'authoredChoices': 94,
    'sideScenes': 24,
    'sideSceneChoices': 72,
    'authoredScenes': 71,
    'activityMiniEvents': 10,
    'companionScenes': 18,
    'endingVariants': 18,
    'locations': 6,
    'chapterClosures': 16,
    'chapterSceneBeats': 16,
    'pacingSeconds': {
      'activityReflection': 75,
      'storyChoice': 75,
      'sideScene': 45,
      'chapterClosure': 30,
      'chapterSceneBeat': 30,
      'activityMiniEvent': 20,
    },
    'formula':
        '48 activity reflections × 75s + 47 story choices × 75s + 24 side scenes × 45s + 16 chapter closures × 30s + 16 relationship beats × 30s + 10 activity mini-events × 20s = 9,365s = 156m; optional side content is counted separately from the mandatory 48-week route.',
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
    'ui.event.tradeoff': '교환이 있는 선택',
    'ui.event.commitment': '축을 쌓는 선택',
    'ui.closure.recorded': '장 결산 · 기록됨',
    'ui.closure.next': '장 결산 · 다음 기회',
    'ui.closure.week': '주차',
    'ui.closure.goalCleared': '목표 달성',
    'ui.closure.keepGrowing': '다음에 이어가기',
    'ui.closure.question': '이번 장의 질문',
    'ui.closure.scene': '동행의 한마디',
    'ui.closure.nextPage': '다음 장으로 →',
    'ui.closure.link': '결과는 시스템 영수증과 다음 선택에 연결됩니다.',
    'ui.relationship.label': '관계 상태',
    'ui.relationship.state.unformed': '아직 얽히지 않음',
    'ui.relationship.state.balanced': '나란한 동행',
    'ui.relationship.state.tension': '갈라지는 마음',
    'ui.relationship.state.estranged': '멀어진 동행',
    'ui.relationship.state.truce': '다시 잇는 동행',
    'ui.relationship.followup': '상태별 후속 기록',
    'ui.relationship.followup.unformed.title': '빈칸의 약속',
    'ui.relationship.followup.unformed.line':
        '아직 누구의 길도 정하지 않았으니, 다음 기록은 열어 둔 채 걷자.',
    'ui.relationship.followup.balanced.title': '같은 속도의 표식',
    'ui.relationship.followup.balanced.line': '누가 먼저인지 세지 않아도, 나란히 간 흔적은 남아.',
    'ui.relationship.followup.tension.title': '금이 간 온실',
    'ui.relationship.followup.tension.line':
        '마음이 갈라진 자리를 덮지 말고, 다음 말이 닿을 틈을 남겨.',
    'ui.relationship.followup.estranged.title': '늦은 답장',
    'ui.relationship.followup.estranged.line':
        '멀어진 거리는 실패의 이름이 아니야. 답장이 올 자리를 지켜 보자.',
    'ui.relationship.followup.truce.title': '다시 묶은 바람',
    'ui.relationship.followup.truce.line': '서로의 몫을 돌려준 뒤에야, 같은 바람을 다시 탈 수 있어.',
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
    'ui.event.tradeoff': 'Trade-off choice',
    'ui.event.commitment': 'Builds one axis',
    'ui.closure.recorded': 'Chapter closure · recorded',
    'ui.closure.next': 'Chapter closure · next chance',
    'ui.closure.week': ' weeks',
    'ui.closure.goalCleared': 'GOAL CLEARED',
    'ui.closure.keepGrowing': 'KEEP GROWING',
    'ui.closure.question': 'This chapter\'s question',
    'ui.closure.scene': 'A companion\'s line',
    'ui.closure.nextPage': 'Next chapter →',
    'ui.closure.link':
        'The result is linked to the system receipt and next choice.',
    'ui.relationship.label': 'Relationship state',
    'ui.relationship.state.unformed': 'Not yet woven',
    'ui.relationship.state.balanced': 'Side-by-side',
    'ui.relationship.state.tension': 'Tension',
    'ui.relationship.state.estranged': 'Estranged',
    'ui.relationship.state.truce': 'Truce',
    'ui.relationship.followup': 'State follow-up',
    'ui.relationship.followup.unformed.title': 'A Promise in the Blank',
    'ui.relationship.followup.unformed.line':
        'No path has been chosen yet, so leave the next record open as we walk.',
    'ui.relationship.followup.balanced.title': 'A Mark of Equal Pace',
    'ui.relationship.followup.balanced.line':
        'We do not need to count who leads; the path remembers walking side by side.',
    'ui.relationship.followup.tension.title': 'The Cracked Greenhouse',
    'ui.relationship.followup.tension.line':
        'Do not cover the split in our hearts; leave a gap for the next words to reach.',
    'ui.relationship.followup.estranged.title': 'A Late Reply',
    'ui.relationship.followup.estranged.line':
        'Distance is not the name of failure. Let us keep a place for an answer.',
    'ui.relationship.followup.truce.title': 'Wind Tied Again',
    'ui.relationship.followup.truce.line':
        'Only after returning each share can we ride the same wind again.',
  });
  final relationshipFollowups = <Map<String, dynamic>>[
    {
      'id': 'unformed-followup',
      'stateId': 'unformed',
      'speakerId': 'lumi',
      'title': '빈칸의 약속',
      'titleEn': 'A Promise in the Blank',
      'line': '아직 누구의 길도 정하지 않았으니, 다음 기록은 열어 둔 채 걷자.',
      'lineEn':
          'No path has been chosen yet, so leave the next record open as we walk.'
    },
    {
      'id': 'balanced-followup',
      'stateId': 'balanced',
      'speakerId': 'taro',
      'title': '같은 속도의 표식',
      'titleEn': 'A Mark of Equal Pace',
      'line': '누가 먼저인지 세지 않아도, 나란히 간 흔적은 남아.',
      'lineEn':
          'We do not need to count who leads; the path remembers walking side by side.'
    },
    {
      'id': 'tension-followup',
      'stateId': 'tension',
      'speakerId': 'bora',
      'title': '금이 간 온실',
      'titleEn': 'The Cracked Greenhouse',
      'line': '마음이 갈라진 자리를 덮지 말고, 다음 말이 닿을 틈을 남겨.',
      'lineEn':
          'Do not cover the split in our hearts; leave a gap for the next words to reach.'
    },
    {
      'id': 'estranged-followup',
      'stateId': 'estranged',
      'speakerId': 'lumi',
      'title': '늦은 답장',
      'titleEn': 'A Late Reply',
      'line': '멀어진 거리는 실패의 이름이 아니야. 답장이 올 자리를 지켜 보자.',
      'lineEn':
          'Distance is not the name of failure. Let us keep a place for an answer.'
    },
    {
      'id': 'truce-followup',
      'stateId': 'truce',
      'speakerId': 'taro',
      'title': '다시 묶은 바람',
      'titleEn': 'Wind Tied Again',
      'line': '서로의 몫을 돌려준 뒤에야, 같은 바람을 다시 탈 수 있어.',
      'lineEn':
          'Only after returning each share can we ride the same wind again.'
    },
  ];
  final companions = (story['companions'] as List).cast<Map<String, dynamic>>();
  final companionById = {
    for (final companion in companions) '${companion['id']}': companion
  };
  for (final followup in relationshipFollowups) {
    final stateId = '${followup['stateId']}',
        speaker = companionById[followup['speakerId']]!;
    followup['exclusiveGroup'] = 'relationship-followup';
    followup['speakerNameKey'] = speaker['nameKey'];
    followup['speakerPortraitAsset'] = speaker['portraitAsset'];
    followup['speakerPortraitFrame'] = speaker['portraitFrame'];
    followup['titleKey'] = 'ui.relationship.followup.$stateId.title';
    followup['lineKey'] = 'ui.relationship.followup.$stateId.line';
    ko[followup['titleKey']] = followup['title'];
    ko[followup['lineKey']] = followup['line'];
    en[followup['titleKey']] = followup['titleEn'];
    en[followup['lineKey']] = followup['lineEn'];
  }
  story['relationshipDesign'] = {
    'schema': 'lumen-relationship-dynamics-v1',
    'purpose':
        'derive a visible relationship state from deterministic bond gaps and authored memory flags',
    'stateOrder': ['unformed', 'balanced', 'tension', 'estranged', 'truce'],
    'thresholds': {'tensionGap': 2, 'estrangedGap': 5},
    'truceFlag': 'windmill-truce',
    'followupExclusiveGroup': 'relationship-followup',
    'followups': relationshipFollowups,
    'states': [
      {
        'id': 'unformed',
        'key': 'ui.relationship.state.unformed',
        'fallback': '아직 얽히지 않음',
        'fallbackEn': 'Not yet woven',
      },
      {
        'id': 'balanced',
        'key': 'ui.relationship.state.balanced',
        'fallback': '나란한 동행',
        'fallbackEn': 'Side-by-side',
      },
      {
        'id': 'tension',
        'key': 'ui.relationship.state.tension',
        'fallback': '갈라지는 마음',
        'fallbackEn': 'Tension',
      },
      {
        'id': 'estranged',
        'key': 'ui.relationship.state.estranged',
        'fallback': '멀어진 동행',
        'fallbackEn': 'Estranged',
      },
      {
        'id': 'truce',
        'key': 'ui.relationship.state.truce',
        'fallback': '다시 잇는 동행',
        'fallbackEn': 'Truce',
      },
    ],
    'evidence': [
      'lib/game_core.dart#resolveRelationshipDynamics',
      'test/relationship_dynamics_test.dart#deterministic relationship states',
      'lib/main.dart#relationshipState',
      'lib/main.dart#relationshipFollowup',
      'lib/game_core.dart#resolveRelationshipFollowup',
      'test/relationship_dynamics_test.dart#deterministic relationship followups',
    ],
  };
  story['narrativeLoop'] = {
    'schema': 'lumen-memory-companion-loop-v1',
    'fateThreadCount': (story['fateThreads'] as List).length,
    'companionQuestCount': (story['companionQuests'] as List).length,
    'stagesPerQuest': 3,
    'derivedFrom': 'event choice flags + deterministic companion bonds',
    'resolver':
        'lib/game_core.dart#resolveFateThreads,lib/game_core.dart#resolveCompanionQuests,lib/game_core.dart#resolveRelationshipDynamics,lib/game_core.dart#resolveRelationshipFollowup',
    'relationshipStateContract': 'lumen-relationship-dynamics-v1',
    'relationshipFollowupCount': 5,
    'relationshipFollowupContract':
        'one exclusive follow-up per resolved state',
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
    'minimumLocaleKeys': ko.length,
    'minimumVisibleDialogueLines': 63,
    'minimumVisibleNarrativeUnits': 240,
    'authoredDialogueLines': 612,
    'baseAuthoredDialogueLines': 216,
    'sideSceneDialogueLines': 240,
    'companionSceneDialogueLines': 90,
    'activityMiniEventDialogueLines': 30,
    'endingVariantDialogueLines': 36,
    'formula':
        'authored dialogue 612 = existing campaign 216 + 24 side scenes × 10 lines (title/body/prompt/consequence + 3 choice labels + 3 response lines) + 18 companion scenes × 5 lines + 10 activity mini-events × 3 lines + 18 ending variants × 2 lines; mandatory route exposes 63 authored dialogue lines and 240 narrative units',
  };
  final mainChoices = (story['events'] as List)
      .cast<Map<String, dynamic>>()
      .expand(
          (event) => (event['choices'] as List).cast<Map<String, dynamic>>())
      .toList();
  final sideChoices = (story['sideScenes'] as List)
      .cast<Map<String, dynamic>>()
      .expand(
          (scene) => (scene['choices'] as List).cast<Map<String, dynamic>>())
      .toList();
  final choices = [...mainChoices, ...sideChoices];
  final authoredScenes = [
    ...(story['events'] as List).cast<Map<String, dynamic>>(),
    ...(story['sideScenes'] as List).cast<Map<String, dynamic>>(),
  ];
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
              ChoiceImpact.from(choice).effectful ||
              choice['setsFlag'] != null ||
              choice['legacyBonuses'] != null)
          .length,
      multiAxis = choices
          .where((choice) => ChoiceImpact.from(choice).axisCount >= 2)
          .length,
      tradeoffChoices = choices
          .where((choice) => ChoiceImpact.from(choice).hasTradeoff)
          .length,
      divergentEvents = authoredScenes
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
    'source': 'story/story.jsonl#events',
    'targets': {
      'choiceImpactRate': 1.0,
      'eventDivergenceRate': 1.0,
      'multiAxisImpactRate': 0.9,
      'minimumTradeoffRate': 0.4,
      'minimumGatedChoices': 20,
    },
    'current': {
      'authoredChoices': choices.length,
      'effectfulChoices': impactful,
      'choiceImpactRate': impactful / choices.length,
      'multiAxisChoices': multiAxis,
      'multiAxisImpactRate': multiAxis / choices.length,
      'tradeoffChoices': tradeoffChoices,
      'tradeoffRate': tradeoffChoices / choices.length,
      'divergentEvents': divergentEvents,
      'eventDivergenceRate': divergentEvents / authoredScenes.length,
      'gatedChoices': gatedChoices,
    },
    'definitions': {
      'choiceImpactRate': 'effectful authored choices / authored choices',
      'eventDivergenceRate':
          'events with at least two distinct effect vectors / events',
      'multiAxisImpactRate':
          'choices changing at least two numeric axes / choices',
      'tradeoffRate':
          'choices with at least one positive and one negative numeric axis / choices',
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
      '16 chapters / 47 main events + 24 side scenes = 71 authored scenes / 6 locations / 16 milestones / terminal week 49';
  byId['agency']!['current'] =
      '94 main choices + 72 side-scene choices; crisis, exploration, resource, mini-game and companion-pair mechanics; memory flags carry consequences';
  byId['relationship']!['current'] =
      '3 companions / 18 independent companion scenes (6 each) / rival conflict / deterministic relationship states / 3 bond-route epilogues / 16 chapter relationship beats';
  byId['feedback']!['current'] =
      'stats, coins, fatigue, 16 milestones, 10 activity mini-events, 6 core endings and 18 ending variants';
  byId['gating']!['current'] =
      '16 closing milestones / 16 chapter contracts / locked stat, bond, memory and legacy gates / milestone-gated master endings';
  byId['presentation']!['current'] =
      'Canvas event and closure evidence plus 6-location route atlas, 18 companion scenes, 24 side-scene records, 10 activity reflections, 18 ending variants, ko+en catalogs, speaker portrait bindings and system decision receipts';
  byId['closure']!['current'] =
      '48-week terminal campaign / system decision receipts / save v7 with memory flags / butterfly ledger / route atlas / collection / deterministic event-cause retrospective / target companion quests and epilogues / SSOT campaign benchmark';
  story['scenarioCompleteness']['dimensions'] = dimensions;

  materializeCharacterContracts(story, ko, en);
  materializeChapterScenes(story, ko, en);
  story['narrativeLoop']['chapterSceneCount'] =
      (story['progression'] as List).length;
  story['dialogueMetrics']['minimumLocaleKeys'] = ko.length;
  story['dialogueMetrics']['minimumVisibleDialogueLines'] =
      (story['events'] as List).length + (story['progression'] as List).length;
  story['dialogueMetrics']['minimumVisibleNarrativeUnits'] = 240;
  story['dialogueMetrics']['authoredDialogueLines'] =
      (story['dialogueMetrics']['baseAuthoredDialogueLines'] as int) +
          (story['dialogueMetrics']['sideSceneDialogueLines'] as int) +
          (story['dialogueMetrics']['companionSceneDialogueLines'] as int) +
          (story['dialogueMetrics']['activityMiniEventDialogueLines'] as int) +
          (story['dialogueMetrics']['endingVariantDialogueLines'] as int);
  story['dialogueMetrics']['formula'] =
      'authored dialogue 612 = existing campaign 216 + 24 side scenes × 10 lines + 18 companion scenes × 5 lines + 10 activity mini-events × 3 lines + 18 ending variants × 2 lines; mandatory route exposes 63 authored dialogue lines and 240 narrative units';

  koFile.writeAsStringSync(encodeJsonlCatalog(
      ko.map((key, value) => MapEntry(key, '$value')),
      locale: 'ko'));
  enFile.writeAsStringSync(encodeJsonlCatalog(
      en.map((key, value) => MapEntry(key, '$value')),
      locale: 'en'));
  refreshHashes(story);
  storyFile.writeAsStringSync(encodeJsonl(story,
      schema: 'lumen-story-ssot-jsonl-v1', document: 'story/story.jsonl'));
  stdout.writeln(
      'STORY_EXPANSION_OK: weeks=48 terminal=49 events=${(story['events'] as List).length} choices=94 chapters=${chapters.length} milestones=${milestones.length} koKeys=${ko.length} enKeys=${en.length}');
}
