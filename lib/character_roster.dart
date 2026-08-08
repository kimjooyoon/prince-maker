/// The 20 original residents shown in the Lumen character archive.
///
/// The art is a single 5 x 4 sheet so the Canvas can keep one deterministic
/// asset while the authored data below supplies the readable UI layer.
class LumenCharacter {
  const LumenCharacter({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.role,
    required this.roleEn,
    required this.motif,
    required this.accent,
    required this.sheetIndex,
  });

  final String id;
  final String name;
  final String nameEn;
  final String role;
  final String roleEn;
  final String motif;
  final int accent;
  final int sheetIndex;

  factory LumenCharacter.fromJson(Map<String, dynamic> json) => LumenCharacter(
        id: '${json['id']}',
        name: '${json['name']}',
        nameEn: '${json['nameEn']}',
        role: '${json['role']}',
        roleEn: '${json['roleEn']}',
        motif: '${json['motif']}',
        accent: (json['accent'] as num).toInt(),
        sheetIndex: (json['sheetIndex'] as num).toInt(),
      );

  String title(String locale) => locale == 'ko' ? name : nameEn;
  String subtitle(String locale) => locale == 'ko' ? role : roleEn;
}

List<LumenCharacter> archiveCharacters(Map<String, dynamic> story) {
  final raw = story['characterArchive'];
  if (raw is List && raw.length == 20) {
    return raw
        .map((entry) =>
            LumenCharacter.fromJson((entry as Map).cast<String, dynamic>()))
        .toList(growable: false);
  }
  return lumenCharacters;
}

const lumenCharacters = <LumenCharacter>[
  LumenCharacter(
      id: 'doran',
      name: '도란',
      nameEn: 'Doran',
      role: '등불 배달부',
      roleEn: 'Lantern courier',
      motif: '작은 등불',
      accent: 0xff4fa7a0,
      sheetIndex: 0),
  LumenCharacter(
      id: 'mira',
      name: '미라',
      nameEn: 'Mira',
      role: '별 기록관',
      roleEn: 'Star archivist',
      motif: '주석 책',
      accent: 0xff8777b5,
      sheetIndex: 1),
  LumenCharacter(
      id: 'kai',
      name: '카이',
      nameEn: 'Kai',
      role: '씨앗 보관자',
      roleEn: 'Seed keeper',
      motif: '화분',
      accent: 0xff6b9f76,
      sheetIndex: 2),
  LumenCharacter(
      id: 'ria',
      name: '리아',
      nameEn: 'Ria',
      role: '비 정원사',
      roleEn: 'Rain gardener',
      motif: '꽃 물뿌리개',
      accent: 0xffd18b5d,
      sheetIndex: 3),
  LumenCharacter(
      id: 'or',
      name: '오르',
      nameEn: 'Or',
      role: '구름 관측가',
      roleEn: 'Cloud watcher',
      motif: '황동 망원경',
      accent: 0xffd3a84f,
      sheetIndex: 4),
  LumenCharacter(
      id: 'sena',
      name: '세나',
      nameEn: 'Sena',
      role: '강의 연주자',
      roleEn: 'River musician',
      motif: '현악기',
      accent: 0xffa55c83,
      sheetIndex: 5),
  LumenCharacter(
      id: 'bron',
      name: '브론',
      nameEn: 'Bron',
      role: '다리 수리공',
      roleEn: 'Bridge tinkerer',
      motif: '나무 새',
      accent: 0xff9d734a,
      sheetIndex: 6),
  LumenCharacter(
      id: 'elbi',
      name: '엘비',
      nameEn: 'Elbi',
      role: '기억 식물학자',
      roleEn: 'Memory botanist',
      motif: '말린 잎',
      accent: 0xff7f9b70,
      sheetIndex: 7),
  LumenCharacter(
      id: 'haon',
      name: '하온',
      nameEn: 'Haon',
      role: '온기 제빵사',
      roleEn: 'Warmth baker',
      motif: '빵 바구니',
      accent: 0xffc67b43,
      sheetIndex: 8),
  LumenCharacter(
      id: 'navin',
      name: '나빈',
      nameEn: 'Navin',
      role: '길목 서기',
      roleEn: 'Route clerk',
      motif: '접힌 지도',
      accent: 0xff8b6e54,
      sheetIndex: 9),
  LumenCharacter(
      id: 'yoonseul',
      name: '윤슬',
      nameEn: 'Yoonseul',
      role: '편지 주자',
      roleEn: 'Letter runner',
      motif: '봉인 편지',
      accent: 0xffc77f64,
      sheetIndex: 10),
  LumenCharacter(
      id: 'moa',
      name: '모아',
      nameEn: 'Moa',
      role: '빛구슬 세공사',
      roleEn: 'Glass bead maker',
      motif: '빛구슬',
      accent: 0xff8e86bd,
      sheetIndex: 11),
  LumenCharacter(
      id: 'sol',
      name: '솔',
      nameEn: 'Sol',
      role: '바람 길잡이',
      roleEn: 'Wind pathfinder',
      motif: '바람 바구니',
      accent: 0xffb17b52,
      sheetIndex: 12),
  LumenCharacter(
      id: 'eil',
      name: '에일',
      nameEn: 'Eil',
      role: '지도 견습생',
      roleEn: 'Map apprentice',
      motif: '푸른 지도',
      accent: 0xff58758c,
      sheetIndex: 13),
  LumenCharacter(
      id: 'raon',
      name: '라온',
      nameEn: 'Raon',
      role: '작은 동물 돌봄이',
      roleEn: 'Small-animal keeper',
      motif: '고양이 인형',
      accent: 0xffbf8c79,
      sheetIndex: 14),
  LumenCharacter(
      id: 'morin',
      name: '모린',
      nameEn: 'Morin',
      role: '바람종 장인',
      roleEn: 'Wind-chime maker',
      motif: '황동 나침반',
      accent: 0xffc99344,
      sheetIndex: 15),
  LumenCharacter(
      id: 'daon',
      name: '다온',
      nameEn: 'Daon',
      role: '구름 차 조향사',
      roleEn: 'Cloud-tea blender',
      motif: '유리 병',
      accent: 0xff6e9a87,
      sheetIndex: 16),
  LumenCharacter(
      id: 'biyo',
      name: '비오',
      nameEn: 'Biyo',
      role: '저녁 찻집 주인',
      roleEn: 'Evening tea host',
      motif: '찻잔 쟁반',
      accent: 0xffbb725c,
      sheetIndex: 17),
  LumenCharacter(
      id: 'luka',
      name: '루카',
      nameEn: 'Luka',
      role: '밤의 돌봄이',
      roleEn: 'Night caretaker',
      motif: '푸른 약병',
      accent: 0xff58738b,
      sheetIndex: 18),
  LumenCharacter(
      id: 'hez',
      name: '헤즈',
      nameEn: 'Hez',
      role: '시계 장인',
      roleEn: 'Brass clocksmith',
      motif: '작은 찻주전자',
      accent: 0xffb9795a,
      sheetIndex: 19),
];
