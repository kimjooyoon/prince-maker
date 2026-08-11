# Lumen Canvas Kit

프린스 메이커의 장기 개발을 위한 재활용 가능한 시각 설계 기준입니다. 현재는 Canvas 전용 토큰을 먼저 고정하고, 이후 이벤트·상점·저장 슬롯·엔딩 갤러리도 동일 규칙으로 확장합니다.

이번 버전의 canonical 계약은 `story/story.jsonl#designSystemContract`이며, 사람이 읽는 선택 근거는 [`design-decision-log.md`](design-decision-log.md), token JSONL은 [`../design/tokens.jsonl`](../design/tokens.jsonl)입니다. 새 화면은 `CanvasUiKit.variantPanel`의 `panel / card / button / hud / dialogue / status / locked` 중 하나를 선택하고, `idle / selected / disabled / warning / success / danger` 상태를 선언합니다.

## 원칙

- 원작의 캐릭터·화면·문구를 재사용하지 않는 독자 세계관과 실루엣
- 760×700 기준 좌표계, 작은 화면에서는 균일 비율 축소
- `ink / teal / sun / paper`에 `twilight / mist`를 더한 황혼 운명 기록 팔레트와 8·16·24 간격으로 화면 간 일관성 유지
- 모든 상호작용 컴포넌트는 `idle / selected / disabled` 상태를 갖고, 골든으로 상태를 고정
- 한글 텍스트는 번들 폰트로 고정하고, 활동 장식 아이콘은 폰트 글리프 대신 Canvas 벡터로 그려 플랫폼별 tofu를 차단
- 상반신 대화 화면은 `portrait_page`, 성격별 PNG 프레임은 `personality_portrait`, 막 결산의 관계 대화는 `relationship_scene_panel`, 성장 계획 화면은 `choice_card`, 결과 화면은 `ending_panel`을 조합
- 특정 작품을 복제하지 않는 어두운 이세계 판타지 감성은 황혼 surface·기록 카드·선택 후 귀환 피드백으로 표현
- 접근성 label은 Canvas를 가리지 않는 투명 Flutter `Semantics` overlay로 제공하며 logical 기준 44px hit target을 유지

## 설계 결정과 증적

홈·성격 선택·상반신 일러스트·동행 장면·Star Cellar는 모두 `ink / twilight` 구조, `sun` 진행 안내, `teal / mint` 회복·성공, `warning / coral` 주의·거절을 공유합니다. warning을 danger와 분리한 이유와 저작권 회피 원칙은 [`design-decision-log.md`](design-decision-log.md)에 기록합니다.

새 named variant 행렬은 한국어·영어 Golden [`test/goldens/design-system-ko.png`](../test/goldens/design-system-ko.png), [`test/goldens/design-system-en.png`](../test/goldens/design-system-en.png)으로 고정하고, 기존 별지하실 화면은 [`test/goldens/star-cellar.png`](../test/goldens/star-cellar.png), [`test/goldens/star-cellar-en.png`](../test/goldens/star-cellar-en.png)으로 회귀를 감시합니다.

## 재활용 단위

| 단위 | 용도 | 현재 사용처 |
| --- | --- | --- |
| `app_shell` | 760×700 Canvas 배경·locale·화면 전환의 공통 외피 | 전체 화면 |
| `status_hud` | 주차·성장축·은화·피로·관계의 한눈 요약 | 홈 |
| `stat_panel` | 주인공·스탯·은화 요약 | 홈 화면 |
| `stat_pill` | 성장축 이름과 현재 값을 빠르게 비교 | 홈 HUD |
| `fatigue_meter` | 피로 0–12와 위험 threshold를 색으로 전달 | 홈 HUD·엔딩 |
| `goal_callout` | 다음 막 목표·달성 여부·다음 단서 표시 | 홈·막 결산·엔딩 |
| `progress_tracker` | 주차 진행과 나비효과·동료 퀘스트 누적량 표시 | 홈·저장·막 결산 |
| `activity_card` | 성장·은화·피로 tradeoff를 선택 가능한 카드로 표시 | 홈 일정 선택 |
| `primary_action` | 현재 화면에서 가장 중요한 진행 행동 | 하루 보내기·다음 장·재시작 |
| `secondary_action` | 보관소·일러스트·홈·이전/다음 등 보조 이동 | 홈·저장·사이드 장면 |
| `feedback_banner` | 직전 행동의 효과·대사·조건 부족을 즉시 반환 | 홈·사건 |
| `choice_card` | 일정 선택과 상태 강조 | 주간 계획 |
| `requirement_badge` | 스탯·유대·기억·계승 조건의 충족/잠금 상태 | 사건·사이드 장면 |
| `speaker_portrait` | 선택지와 막 장면의 화자·역할·portrait frame 연결 | 사건·막 결산 |
| `dialogue_panel` | 장소·화자·대사를 하나의 읽기 순서로 묶음 | 사건·성격·막 결산 |
| `portrait_page` | 성격 탭과 상반신 대화 | 노아의 기록 |
| `personality_portrait` | SSOT `portraitAsset` + `portraitFrame`을 읽는 캐릭터 프레임 | 고요·다정·용감 3종 |
| `route_atlas` | 장소 발견 flag와 다음 탐험 경로를 노드로 표시 | 홈 |
| `side_scene_card` | 탐험·위기·자원·미니게임·동료 조합 사건의 상태와 선택 | 사이드 장면 기록 |
| `chapter_closure_scene` | 막 목표 결과와 관계 장면·다음 장 이동을 한 화면에 고정 | 막 결산 |
| `ending_panel` | 성장 결과와 재시작 | 48주 엔딩 |
| `retrospective_panel` | 원인 사건·목표 달성·다음 회차 단서를 요약 | 엔딩 |
| `save_code_panel` | replay trace·도감·복사·복원을 한 보관 단위로 표시 | 기록 보관소 |
| `ledger_thread_card` | 나비효과의 발견 전/후 상태를 구분 | 운명 기록 |
| `quest_progress_card` | 동료 퀘스트 단계와 완료 상태를 표시 | 운명 기록 |
| `receipt_row` | 승인/거절·규칙·hash를 짧은 판정 행으로 표시 | 운명 기록 |
| `character_card` | portrait sheet·이름·역할·모티프를 고정 | 캐릭터 도감 |
| `empty_state` | 기록/사이드 장면이 없을 때 다음 행동을 안내 | 기록·사이드 장면 |
| `relationship_scene_panel` | SSOT speaker·portrait·title·line을 한 패널에 고정 | 16막 chapter closure |
| `relationship_state_badge` | bond gap·기억 flag에서 나온 관계 상태를 Canvas/replay와 동일하게 표시 | 홈·막 결산·관계 Golden |
| `relationship_followup_panel` | resolved state에 대응하는 exclusive speaker·portrait·title·line을 동일 카드에 표시 | 막 결산·관계 후속 Golden |
| `environment_card` | 장소의 색·모티프·날씨·플레이 affordance를 한 카드에 표시 | 환경 아틀라스 6종 |
| `environment_surface` | 장소별 규칙을 작은 Canvas 풍경으로 압축 | 기록관·온실·시장·바람길·관측소·채석장 |
| `locale_toggle` | locale catalog 전환 | 일러스트·사건 화면 |
| `navigation_footer` | 홈·뒤로·이전·다음의 넓은 탭 영역과 방향성 | 전체 보관/아카이브 화면 |
| `vector_activity_icon` | 활동별 별·꽃·나침반·달·보석 마크 | 선택 카드 |

`CanvasUiStateGalleryPainter`의 상태 행렬은 [`test/goldens/ui-state-matrix.png`](../test/goldens/ui-state-matrix.png)으로 고정한다. 새 공통 surface는 다섯 상태를 모두 선언하고 이 Golden을 갱신해야 한다.

런타임 토큰은 [`lib/design_tokens.dart`](../lib/design_tokens.dart), 사람이 읽는 토큰 원본은 [`design/tokens.jsonl`](../design/tokens.jsonl)입니다. 공통 Canvas surface는 [`lib/canvas_ui_kit.dart`](../lib/canvas_ui_kit.dart)가 `idle / selected / disabled / success / danger` 상태의 fill·stroke·text를 일관되게 계산합니다. 새 화면은 색상·간격·컨트롤 높이를 직접 하드코딩하지 않고 이 두 토큰 파일과 UI Kit의 기준으로 설계합니다.

## UI 상태 계약

| 상태 | 시각 규칙 | 의미 |
| --- | --- | --- |
| `idle` | paper fill + teal/ink stroke | 선택 가능한 기본 상태 |
| `selected` | teal fill + white text | 현재 일정·탭·주요 선택 |
| `disabled` | paper/mist + 낮은 대비 | 조건 부족, 아직 잠긴 선택 |
| `success` | teal tint + teal stroke | 목표 달성, 저장 성공, 발견됨 |
| `danger` | warm red tint + red stroke | 조건 부족, 거절, 오류 |

모든 화면은 `loading`을 별도 애니메이션으로 만들지 않고 앱 초기 asset load 전에는 빈 Canvas를 노출하지 않습니다. 저장 복원 오류처럼 사용자 행동으로 발생하는 오류는 `danger` feedback banner 또는 SnackBar로만 표시하며, 진행 상태를 조용히 잃지 않습니다. 빈 목록은 `empty_state`로 다음 행동을 안내해야 합니다.

## 화면별 조합

| 페이지 | 조합 | 필수 상호작용 |
| --- | --- | --- |
| 홈 `0` | `status_hud` + `goal_callout` + `activity_card` + `feedback_banner` + `route_atlas` + `navigation_footer` | 일정 선택, 하루 보내기, 보관소/일러스트/도감/환경 이동 |
| 성격 `1` | `portrait_page` + `personality_portrait` + `locale_toggle` | 성격 선택, 언어 전환, 홈 복귀 |
| 엔딩 `2` | `ending_panel` + `retrospective_panel` + `primary_action` | 기록 확인, 다음 회차 시작 |
| 사건 `3` | `dialogue_panel` + `choice_card` + `requirement_badge` + `speaker_portrait` | 효과가 있는 선택, 잠금 조건 확인 |
| 저장 `4` | `save_code_panel` + `secondary_action` | 코드 복사, 코드 복원, 오류 피드백 |
| 운명 기록 `5` | `ledger_thread_card` + `quest_progress_card` + `receipt_row` | 발견/퀘스트/판정 기록 확인 |
| 막 결산 `6` | `chapter_closure_scene` + `relationship_followup_panel` | 목표 결과와 관계 장면 확인 |
| 캐릭터 도감 `7` | `character_card` + `navigation_footer` | 20종 주민 확인, 언어 전환 |
| 캐릭터 아트 `10` | `character_art_panel` + `emotion_chip` + `locale_toggle` + `navigation_footer` | 선택 주민의 일러스트 방향·실루엣·동작·5종 감정 키 확인 |
| 환경 아틀라스 `8` | `environment_card` + `environment_surface` | 장소 규칙 확인, 사이드 장면 진입 |
| 사이드 장면 `9` | `side_scene_card` + `requirement_badge` + `navigation_footer` | 이전/다음 장면, 선택/잠금 확인 |
| 동행 관계 기록 `11` | `relationship_archive_panel` + `quest_progress_card` + `speaker_portrait` + `locale_toggle` | 동일 resolver의 관계 상태·유대 간격·후속 기록·동료 퀘스트 확인 |

## 환경 게임디자인 시스템

환경은 `location → surface → affordance → memory`의 네 단계로 설계합니다.

| 단계 | 질문 | 루멘 구현 |
| --- | --- | --- |
| `location` | 어디에서 일어나는가? | SSOT `locations` 6곳 |
| `surface` | 무엇을 보고 만지는가? | 장소별 색·모티프·날씨와 Canvas 풍경 |
| `affordance` | 그곳에서 어떤 선택이 자연스러운가? | 기록·돌봄·교환·횡단의 플레이 약속 |
| `memory` | 선택 뒤 무엇이 남는가? | `place:<id>` 발견 flag와 사건/나비효과 trace |

장소별 기본 축은 `archive = 지혜/기억`, `greenhouse = 공감/유대`, `market = 은화/교환`, `river-road = 용기/발견`, `observatory = 지혜/발견`, `quarry = 용기/자원`입니다. 환경 아틀라스는 이 축을 설명하는 정보 화면이며, 활동·사건 시스템은 기존 결정론적 코어와 같은 SSOT를 계속 사용합니다. 따라서 환경의 시각적 의미와 실제 선택 효과가 분리되지 않고, 새 장소를 추가할 때도 `surface`, `affordance`, `memory`를 함께 정의해야 합니다.

## 캐릭터 아트 구성

| surface | role | current use |
| --- | --- | --- |
| character_art_panel | portrait sheet·일러스트 방향·실루엣·대표 동작·표정 키 | 캐릭터 도감 상세 |
| emotion_chip | 감정 얼굴·라벨·개별 시각 큐를 idle / selected 상태로 표시 | 캐릭터 도감 상세 |
| event_illustration_strip | 메인 이벤트의 장소 장면과 노아·루미·보라·타로 4패널을 한 장의 스토리보드로 표시 | 사건 선택 |
| relationship_archive_panel | 순수 관계 resolver의 상태·유대 간격·후속 기록·동료 퀘스트를 한 화면에 표시 | 동행 관계 기록 |

캐릭터 도감 7은 20종 character_card를 보여 주고, 카드를 누르면 캐릭터 아트 10으로 이동한다. 아트 상세는 locale_toggle, character_art_panel, emotion_chip, navigation_footer를 조합하며, 5종 감정 전환과 도감 복귀를 필수 상호작용으로 고정한다.

메인 사건 3은 `event_illustration_strip`을 `choice_card` 위에 배치한다. 각 이벤트 시트는 `story/story.jsonl`의 `illustrationAsset`을 통해 4개 주요 캐릭터 프레임을 제공하며, 47개 사건 전체가 같은 `assets/generated/event-illustrations/event-<week>.png` 규칙을 사용한다.

동행 관계 기록 11은 `resolveRelationshipDynamics`와 `resolveRelationshipFollowup`의 동일 결과를 상태·유대 간격·후속 기록·3명 동료 카드로 투영한다. 홈·막 결산·기록 보관소와 다른 surface가 같은 입력에서 같은 state id를 얻는지 `relationship-archive.png`와 replay 테스트로 고정한다.

## 다음 설계 단계

1. 이벤트 카드와 대화 선택지를 `choice_card` 변형으로 정의
2. 저장 슬롯/리플레이 화면을 `stat_panel`과 `ending_panel` 조합으로 정의
3. 48주 플레이 지표(선택 분포·엔딩 분포·재시작률·막별 분량)를 SSOT와 골든에 추가
4. `story/locales/<locale>.jsonl`와 동일한 locale coverage Golden을 언어별로 추가
5. `relationship_scene_panel`을 동료 긴장·중재·소원함 장면의 공통 변형으로 확장
6. 새 장소를 추가할 때 `locations`·환경 surface·affordance·발견 flag·Golden을 한 묶음으로 추가
