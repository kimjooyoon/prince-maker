# Lumen Canvas Kit

프린스 메이커의 장기 개발을 위한 재활용 가능한 시각 설계 기준입니다. 현재는 Canvas 전용 토큰을 먼저 고정하고, 이후 이벤트·상점·저장 슬롯·엔딩 갤러리도 동일 규칙으로 확장합니다.

## 원칙

- 원작의 캐릭터·화면·문구를 재사용하지 않는 독자 세계관과 실루엣
- 760×700 기준 좌표계, 작은 화면에서는 균일 비율 축소
- `ink / teal / sun / paper` 4색과 8·16·24 간격만으로 화면 간 일관성 유지
- 모든 상호작용 컴포넌트는 `idle / selected / disabled` 상태를 갖고, 골든으로 상태를 고정
- 상반신 대화 화면은 `portrait_page`, 성격별 PNG 프레임은 `personality_portrait`, 성장 계획 화면은 `choice_card`, 결과 화면은 `ending_panel`을 조합

## 재활용 단위

| 단위 | 용도 | 현재 사용처 |
| --- | --- | --- |
| `stat_panel` | 주인공·스탯·은화 요약 | 홈 화면 |
| `choice_card` | 일정 선택과 상태 강조 | 주간 계획 |
| `portrait_page` | 성격 탭과 상반신 대화 | 노아의 기록 |
| `personality_portrait` | SSOT `portraitAsset` + `portraitFrame`을 읽는 캐릭터 프레임 | 고요·다정·용감 3종 |
| `ending_panel` | 성장 결과와 재시작 | 12주 엔딩 |

런타임 토큰은 [`lib/design_tokens.dart`](../lib/design_tokens.dart), 사람이 읽는 토큰 원본은 [`design/tokens.json`](../design/tokens.json)입니다. 새 화면은 색상·간격을 직접 하드코딩하지 않고 이 두 파일의 기준으로 설계합니다.

## 다음 설계 단계

1. 이벤트 카드와 대화 선택지를 `choice_card` 변형으로 정의
2. 저장 슬롯/리플레이 화면을 `stat_panel`과 `ending_panel` 조합으로 정의
3. 12주 플레이 지표(선택 분포·엔딩 분포·재시작률)를 SSOT와 골든에 추가
