import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Environment design is authored beside the location registry so a place is
/// both a visual surface and a legible gameplay promise.
class LumenEnvironment {
  const LumenEnvironment({
    required this.id,
    required this.name,
    required this.nameKey,
    required this.kind,
    required this.kindEn,
    required this.motif,
    required this.motifEn,
    required this.affordance,
    required this.affordanceEn,
    required this.weather,
    required this.weatherEn,
    required this.primary,
    required this.secondary,
    required this.stat,
    required this.statEn,
    required this.activity,
    required this.activityEn,
  });

  final String id;
  final String name;
  final String nameKey;
  final String kind;
  final String kindEn;
  final String motif;
  final String motifEn;
  final String affordance;
  final String affordanceEn;
  final String weather;
  final String weatherEn;
  final Color primary;
  final Color secondary;
  final String stat;
  final String statEn;
  final String activity;
  final String activityEn;

  String kindLabel(String locale) => locale == 'ko' ? kind : kindEn;
  String motifLabel(String locale) => locale == 'ko' ? motif : motifEn;
  String affordanceLabel(String locale) =>
      locale == 'ko' ? affordance : affordanceEn;
  String weatherLabel(String locale) => locale == 'ko' ? weather : weatherEn;
  String statLabel(String locale) => locale == 'ko' ? stat : statEn;
  String activityLabel(String locale) => locale == 'ko' ? activity : activityEn;
}

const _environmentDesign = <String, LumenEnvironment>{
  'archive': LumenEnvironment(
    id: 'archive',
    name: '별자리 기록관',
    nameKey: 'location.archive.name',
    kind: '기억의 장소',
    kindEn: 'Place of memory',
    motif: '종이·별자리·잠긴 서랍',
    motifEn: 'Paper · constellations · locked drawers',
    affordance: '기억을 남기면 다음 질문이 열린다',
    affordanceEn: 'Leaving a memory opens the next question',
    weather: '새벽의 잔광',
    weatherEn: 'Afterglow before dawn',
    primary: twilight,
    secondary: mist,
    stat: '지혜 / 기억',
    statEn: 'Wisdom / memory',
    activity: '별 관측',
    activityEn: 'Star watch',
  ),
  'greenhouse': LumenEnvironment(
    id: 'greenhouse',
    name: '루멘 온실',
    nameKey: 'location.greenhouse.name',
    kind: '돌봄의 장소',
    kindEn: 'Place of care',
    motif: '유리·씨앗·풍차',
    motifEn: 'Glass · seeds · windmill',
    affordance: '작은 돌봄이 유대와 계절 목표를 키운다',
    affordanceEn: 'Small acts of care grow bonds and seasonal goals',
    weather: '잎 사이의 비',
    weatherEn: 'Rain between leaves',
    primary: teal,
    secondary: const Color(0xff9bc58e),
    stat: '공감 / 유대',
    statEn: 'Empathy / bonds',
    activity: '정원 돌보기',
    activityEn: 'Tend the garden',
  ),
  'market': LumenEnvironment(
    id: 'market',
    name: '달빛 시장',
    nameKey: 'location.market.name',
    kind: '교환의 장소',
    kindEn: 'Place of exchange',
    motif: '등불·천막·은화',
    motifEn: 'Lanterns · awnings · silver coins',
    affordance: '은화를 시간·성장·관계로 바꾼다',
    affordanceEn: 'Trade coins for time, growth, or connection',
    weather: '천막을 흔드는 저녁 바람',
    weatherEn: 'Evening wind through the awnings',
    primary: sun,
    secondary: const Color(0xffd9886a),
    stat: '은화 / 선택',
    statEn: 'Coins / choice',
    activity: '장터 심부름',
    activityEn: 'Market errand',
  ),
  'river-road': LumenEnvironment(
    id: 'river-road',
    name: '강 건너 바람길',
    nameKey: 'location.riverRoad.name',
    kind: '횡단의 장소',
    kindEn: 'Place of crossing',
    motif: '물결·다리·바람종',
    motifEn: 'Water · bridge · wind chimes',
    affordance: '위험을 함께 알면 다음 사람의 길이 된다',
    affordanceEn: 'Shared risks become a road for the next person',
    weather: '다리를 건너는 강바람',
    weatherEn: 'River wind crossing the bridge',
    primary: const Color(0xff58738b),
    secondary: mist,
    stat: '용기 / 발견',
    statEn: 'Courage / discovery',
    activity: '공방 돕기',
    activityEn: 'Help the workshop',
  ),
  'observatory': LumenEnvironment(
    id: 'observatory',
    name: '새벽 관측소',
    nameKey: 'location.observatory.name',
    kind: '발견의 장소',
    kindEn: 'Place of discovery',
    motif: '망원경·새벽별·기록판',
    motifEn: 'Telescope · dawn stars · record boards',
    affordance: '모르는 것을 남기면 다음 관측의 기준이 된다',
    affordanceEn: 'Leaving the unknown sets the next observation standard',
    weather: '별빛이 걷히는 새벽',
    weatherEn: 'Dawn clearing the starlight',
    primary: const Color(0xff6b5ca5),
    secondary: const Color(0xffc6b6e8),
    stat: '지혜 / 발견',
    statEn: 'Wisdom / discovery',
    activity: '별 관측',
    activityEn: 'Observe the stars',
  ),
  'quarry': LumenEnvironment(
    id: 'quarry',
    name: '별씨앗 채석장',
    nameKey: 'location.quarry.name',
    kind: '자원의 장소',
    kindEn: 'Place of resources',
    motif: '돌무늬·곡괭이·세 손의 표식',
    motifEn: 'Stone grain · picks · three-handed markers',
    affordance: '위험의 근거를 기록하면 다음 길이 열린다',
    affordanceEn: 'Recording why a risk is safe opens the next road',
    weather: '돌 틈에 머무는 먼지',
    weatherEn: 'Dust resting in the stone seams',
    primary: const Color(0xff8a6a58),
    secondary: const Color(0xffd5b27c),
    stat: '용기 / 자원',
    statEn: 'Courage / resources',
    activity: '돌무늬 기록',
    activityEn: 'Read the stone grain',
  ),
};

List<LumenEnvironment> environmentsFromStory(Map<String, dynamic> story) {
  final locations = (story['locations'] as List? ?? const [])
      .whereType<Map>()
      .map((item) => item.cast<String, dynamic>());
  final result = <LumenEnvironment>[];
  for (final location in locations) {
    final id = '${location['id']}', design = _environmentDesign[id];
    if (design == null) continue;
    result.add(LumenEnvironment(
      id: design.id,
      name: '${location['name'] ?? design.name}',
      nameKey: '${location['nameKey'] ?? design.nameKey}',
      kind: design.kind,
      kindEn: design.kindEn,
      motif: design.motif,
      motifEn: design.motifEn,
      affordance: design.affordance,
      affordanceEn: design.affordanceEn,
      weather: design.weather,
      weatherEn: design.weatherEn,
      primary: design.primary,
      secondary: design.secondary,
      stat: design.stat,
      statEn: design.statEn,
      activity: design.activity,
      activityEn: design.activityEn,
    ));
  }
  return result.isEmpty
      ? _environmentDesign.values.toList(growable: false)
      : result;
}
