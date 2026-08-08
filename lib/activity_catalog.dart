typedef Activity = ({
  String label,
  String icon,
  String hint,
  String stat,
  int delta,
  int fatigue,
  int coins
});

const defaultActivities = <Activity>[
  (
    label: '별 관측',
    icon: '✦',
    hint: '지혜 +3 · 피로 +1',
    stat: '지혜',
    delta: 3,
    fatigue: 1,
    coins: 0
  ),
  (
    label: '정원 돌보기',
    icon: '❈',
    hint: '공감 +3 · 피로 +1',
    stat: '공감',
    delta: 3,
    fatigue: 1,
    coins: 0
  ),
  (
    label: '공방 돕기',
    icon: '◈',
    hint: '용기 +2 · 은화 +4',
    stat: '용기',
    delta: 2,
    fatigue: 1,
    coins: 4
  ),
  (
    label: '달빛 아래 휴식',
    icon: '☾',
    hint: '피로 -2 · 성장 없음',
    stat: '지혜',
    delta: 0,
    fatigue: -2,
    coins: 0
  ),
  (
    label: '장터 심부름',
    icon: '◇',
    hint: '은화 +6 · 피로 +1',
    stat: '공감',
    delta: 0,
    fatigue: 1,
    coins: 6
  ),
];

List<Activity> activitiesFromStory(Map<String, dynamic> story) {
  final raw = story['activities'] as List?;
  if (raw == null || raw.isEmpty) return defaultActivities;
  return raw.map((entry) {
    final activity = entry as Map;
    return (
      label: '${activity['label']}',
      icon: '${activity['icon']}',
      hint: '${activity['hint']}',
      stat: '${activity['stat']}',
      delta: (activity['delta'] as int?) ?? 0,
      fatigue: (activity['fatigue'] as int?) ?? 0,
      coins: (activity['coins'] as int?) ?? 0,
    );
  }).toList();
}
