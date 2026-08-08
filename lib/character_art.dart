import 'character_roster.dart';

/// The shared expression vocabulary keeps every resident readable in the UI.
/// Each character still supplies a custom visual cue for every state in the
/// story SSOT, so the five faces do not collapse into one generic emote set.
class LumenEmotionSpec {
  const LumenEmotionSpec({
    required this.id,
    required this.label,
    required this.labelEn,
  });

  final String id;
  final String label;
  final String labelEn;

  String title(String locale) => locale == 'ko' ? label : labelEn;
}

const lumenEmotionStates = <LumenEmotionSpec>[
  LumenEmotionSpec(id: 'calm', label: '차분', labelEn: 'Calm'),
  LumenEmotionSpec(id: 'joy', label: '기쁨', labelEn: 'Joy'),
  LumenEmotionSpec(id: 'concern', label: '걱정', labelEn: 'Concern'),
  LumenEmotionSpec(id: 'resolve', label: '결의', labelEn: 'Resolve'),
  LumenEmotionSpec(id: 'wonder', label: '경이', labelEn: 'Wonder'),
];

class LumenCharacterArt {
  const LumenCharacterArt({
    required this.id,
    required this.illustration,
    required this.illustrationEn,
    required this.silhouette,
    required this.silhouetteEn,
    required this.gesture,
    required this.gestureEn,
    required this.emotionNotes,
    required this.emotionNotesEn,
  });

  final String id;
  final String illustration;
  final String illustrationEn;
  final String silhouette;
  final String silhouetteEn;
  final String gesture;
  final String gestureEn;
  final List<String> emotionNotes;
  final List<String> emotionNotesEn;

  factory LumenCharacterArt.fromJson(Map<String, dynamic> json) {
    return LumenCharacterArt(
      id: '${json['id']}',
      illustration: '${json['illustration']}',
      illustrationEn: '${json['illustrationEn']}',
      silhouette: '${json['silhouette']}',
      silhouetteEn: '${json['silhouetteEn']}',
      gesture: '${json['gesture']}',
      gestureEn: '${json['gestureEn']}',
      emotionNotes: _fiveStrings(json['emotionNotes']),
      emotionNotesEn: _fiveStrings(json['emotionNotesEn']),
    );
  }

  factory LumenCharacterArt.fallback(LumenCharacter character) =>
      LumenCharacterArt(
        id: character.id,
        illustration:
            '${character.role}가 ${character.motif}을/를 들고 루멘의 하루를 지키는 장면',
        illustrationEn:
            '${character.roleEn} carrying ${character.motif} through an ordinary Lumen day',
        silhouette: '모티프를 몸 앞에 둔 둥근 2등신 실루엣',
        silhouetteEn:
            'A rounded chibi silhouette framing the motif at chest height',
        gesture: '${character.motif}을/를 가슴 앞에 들어 올리기',
        gestureEn: 'Lift the signature motif to chest height',
        emotionNotes: const [
          '시선을 낮추고 호흡을 고른다',
          '작은 미소와 함께 모티프를 살짝 흔든다',
          '눈썹을 모으고 모티프를 확인한다',
          '발을 단단히 딛고 정면을 본다',
          '모티프 너머의 빛을 올려다본다',
        ],
        emotionNotesEn: const [
          'Lower the gaze and settle the breath',
          'Smile softly and let the motif sway',
          'Draw the brows together to check the motif',
          'Plant both feet and face forward',
          'Look up toward the light beyond the motif',
        ],
      );

  String illustrationFor(String locale) =>
      locale == 'ko' ? illustration : illustrationEn;

  String silhouetteFor(String locale) =>
      locale == 'ko' ? silhouette : silhouetteEn;

  String gestureFor(String locale) => locale == 'ko' ? gesture : gestureEn;

  String emotionNote(int index, String locale) {
    final notes = locale == 'ko' ? emotionNotes : emotionNotesEn;
    return notes[index.clamp(0, notes.length - 1)];
  }
}

List<LumenCharacterArt> characterArtFromStory(Map<String, dynamic> story) {
  final raw = story['characterArchive'];
  if (raw is List && raw.length == 20) {
    final entries = raw
        .whereType<Map>()
        .map((entry) => entry.cast<String, dynamic>())
        .where((entry) => entry['illustration'] != null)
        .map(LumenCharacterArt.fromJson)
        .toList(growable: false);
    if (entries.length == 20) return entries;
  }
  return lumenCharacters
      .map(LumenCharacterArt.fallback)
      .toList(growable: false);
}

LumenCharacterArt characterArtFor(Map<String, dynamic> story, String id) {
  final art = characterArtFromStory(story);
  return art.firstWhere(
    (candidate) => candidate.id == id,
    orElse: () => LumenCharacterArt.fallback(lumenCharacters.firstWhere(
        (character) => character.id == id,
        orElse: () => lumenCharacters.first)),
  );
}

List<String> _fiveStrings(dynamic value) {
  final values =
      value is List ? value.map((item) => '$item').toList() : <String>[];
  if (values.length >= lumenEmotionStates.length) {
    return values.take(lumenEmotionStates.length).toList(growable: false);
  }
  return [
    ...values,
    ...List<String>.filled(
        lumenEmotionStates.length - values.length, '표정을 천천히 읽는다'),
  ];
}
