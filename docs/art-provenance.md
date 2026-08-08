# 루멘 캐릭터 아트 provenance

이 프로젝트의 캐릭터는 특정 작품의 캐릭터·의상·로고·대사를 재현하지 않는 독자 설계로 고정한다. “일본풍”은 장르적 조형 언어(2등신 비율, 큰 표정, 색면 중심 의상, 작은 모티프)를 뜻하며 특정 작가나 시리즈의 화풍 모사는 목표로 삼지 않는다.

## 일러스트 방향과 감정표현 계약

각 characterArchive 항목은 illustration, silhouette, gesture의 한국어·영어 방향과 emotionNotes, emotionNotesEn 5종 배열을 함께 가진다. 이 필드가 캐릭터별 장면 구상과 표정 큐의 SSOT이며 lib/character_art.dart가 이를 LumenCharacterArt로 읽는다. 도감 카드 탭은 page 10의 lib/character_art_painter.dart로 이동해 동일한 5×4 PNG 셀, 역할별 장면 방향, 실루엣, 대표 동작을 한 화면에 보여 준다.

모든 주민이 공유하는 표정 vocabulary는 calm / joy / concern / resolve / wonder이며, 각 주민은 같은 감정 이름 안에서 눈썹·시선·입·소품의 고유 큐를 가진다. 감정 칩은 idle / selected 상태를 사용하고, 현재 표정은 대화·기억 장면에서 재사용할 수 있는 시각 기준으로 명시한다. 새 주민을 추가할 때는 20개 archive identity, 5개 한국어·영어 emotion note, 독자 일러스트 방향을 함께 채워야 한다.

## 설계 계약

| 자산 | 독자 조형 규칙 | SSOT 연결 |
| --- | --- | --- |
| Noa | 2등신, 남색 단발, 초승달 가방, 별 장식, 차분·호기심·결의 3표정 | `story.jsonl#assetRefs` + hero runtime sheet |
| 고요한 관찰자 | 인디고·라벤더, 달 모티프, 짧은 단발 | `personalities[0].portraitAsset` / `portraitFrame` |
| 다정한 연결자 | 틸·크림, 꽃 모티프, 긴 땋은 머리 | `personalities[1].portraitAsset` / `portraitFrame` |
| 용감한 개척자 | 코랄·황토, 나침반 모티프, 짧은 곱슬머리 | `personalities[2].portraitAsset` / `portraitFrame` |

## 캐릭터 도감 확장

서사 registry의 노아·3명 동료를 보존하면서, 세계관 확장용 독자 주민 디자인 20종을 별도 도감 레이어로 추가했다. [`story/story.jsonl`](../story/story.jsonl)의 `characterArchive`가 이름·역할·모티프·색상·시트 위치를 단일 원천으로 선언하고, [`assets/lumen-character-roster.png`](../assets/lumen-character-roster.png)는 5×4 시트로 이를 렌더링한다. [`lib/character_roster.dart`](../lib/character_roster.dart)는 이 SSOT를 Canvas 입력용 타입으로 변환한다. 각 디자인은 등불 배달부, 별 기록관, 씨앗 보관자, 비 정원사, 구름 관측가, 강의 연주자, 다리 수리공, 기억 식물학자, 제빵사, 길목 서기, 편지 주자, 빛구슬 세공사, 바람 길잡이, 지도 견습생, 동물 돌봄이, 바람종 장인, 차 조향사, 찻집 주인, 밤의 돌봄이, 시계 장인으로 역할·소품·실루엣을 분리한다. 도감은 기존 Canvas UI에서만 표시되며, 스토리 사건의 speaker binding이나 게임 규칙을 변경하지 않는다.

## 추적성과 검증

- 생성된 PNG와 chroma-key 원본은 [`story/story.jsonl`](../story/story.jsonl)의 `assetRefs`에 SHA-256으로 선언한다.
- 각 성격의 `portraitAsset`과 `portraitFrame`은 Canvas 일러스트 페이지에서 읽고, `test/asset_test.dart`가 PNG 로딩을 검증한다.
- `tool/verify_game.dart`는 주인공·성격 PNG 선언과 성격별 `palette`·`motif`·`silhouette` 설계 필드를 강제한다.
- 원작의 화면 캡처, 캐릭터명, 대사, 로고, 복제된 실루엣은 저장소에 포함하지 않는다.

이 문서는 법률 자문이 아니며, 배포 전에는 실제 상표·저작권 검색과 전문 검토를 별도로 수행한다.
