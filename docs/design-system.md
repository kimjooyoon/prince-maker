# Lumen Canvas Kit

프린스 메이커의 장기 개발을 위한 재활용 가능한 시각 설계 기준입니다. 현재는 Canvas 전용 토큰을 먼저 고정하고, 이후 이벤트·상점·저장 슬롯·엔딩 갤러리도 동일 규칙으로 확장합니다.

## 원칙

- 원작의 캐릭터·화면·문구를 재사용하지 않는 독자 세계관과 실루엣
- 760×700 기준 좌표계, 작은 화면에서는 균일 비율 축소
- `ink / teal / sun / paper`에 `twilight / mist`를 더한 황혼 운명 기록 팔레트와 8·16·24 간격으로 화면 간 일관성 유지
- 모든 상호작용 컴포넌트는 `idle / selected / disabled` 상태를 갖고, 골든으로 상태를 고정
- 한글 텍스트는 번들 폰트로 고정하고, 활동 장식 아이콘은 폰트 글리프 대신 Canvas 벡터로 그려 플랫폼별 tofu를 차단
- 상반신 대화 화면은 `portrait_page`, 성격별 PNG 프레임은 `personality_portrait`, 성장 계획 화면은 `choice_card`, 결과 화면은 `ending_panel`을 조합
- 특정 작품을 복제하지 않는 어두운 이세계 판타지 감성은 황혼 surface·기록 카드·선택 후 귀환 피드백으로 표현

## 재활용 단위

| 단위 | 용도 | 현재 사용처 |
| --- | --- | --- |
| `stat_panel` | 주인공·스탯·은화 요약 | 홈 화면 |
| `choice_card` | 일정 선택과 상태 강조 | 주간 계획 |
| `portrait_page` | 성격 탭과 상반신 대화 | 노아의 기록 |
| `personality_portrait` | SSOT `portraitAsset` + `portraitFrame`을 읽는 캐릭터 프레임 | 고요·다정·용감 3종 |
| `ending_panel` | 성장 결과와 재시작 | 48주 엔딩 |
| `feedback_banner` | 마지막 행동 결과와 조건 피드백 | 홈 화면 |
| `locale_toggle` | locale catalog 전환 | 일러스트·사건 화면 |
| `vector_activity_icon` | 활동별 별·꽃·나침반·달·보석 마크 | 선택 카드 |

런타임 토큰은 [`lib/design_tokens.dart`](../lib/design_tokens.dart), 사람이 읽는 토큰 원본은 [`design/tokens.json`](../design/tokens.json)입니다. 새 화면은 색상·간격을 직접 하드코딩하지 않고 이 두 파일의 기준으로 설계합니다.

## 다음 설계 단계

1. 이벤트 카드와 대화 선택지를 `choice_card` 변형으로 정의
2. 저장 슬롯/리플레이 화면을 `stat_panel`과 `ending_panel` 조합으로 정의
3. 48주 플레이 지표(선택 분포·엔딩 분포·재시작률·막별 분량)를 SSOT와 골든에 추가
4. `story/locales/<locale>.json`와 동일한 locale coverage Golden을 언어별로 추가
