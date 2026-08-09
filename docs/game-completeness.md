# 게임 완성도 지표와 폐쇄 루프

## 결정론적 게임 루프

```text
일정 선택 → 시스템 승인 영수증 → 상태 전이(스탯/은화/피로/기록) → 2–48주차 사건 선택 → 49주 terminal 엔딩 판정
       ↑                                                        ↓
       └────────────── 다시 시작 / 동일 입력 재현 ──────────────┘
```

모든 콘텐츠는 [`story/story.jsonl`](../story/story.jsonl)에 있고, 입력 순서가 같으면 동일한 상태와 replay trace가 나온다. 이벤트는 2–48주차에 고정되고, 49주차는 48주 캠페인의 terminal 상태다. 활동·사건 입력은 `SystemDecisionPolicy`가 먼저 승인하며 승인·거절 영수증 모두 같은 trace에 남는다.

## 현재 증적 지표

성능 증적은 5,000 campaign·565,000 transition을 실제 `GameSession`에서 재생하며, 독립 동료 장면 기록의 replay checksum까지 동일해야 통과한다.

개발 작업의 정량 목표·gap·투입 단위는 생성 원장인 [`docs/development-goals.md`](development-goals.md)와 [`docs/development-goals.jsonl`](development-goals.jsonl)이 관리한다. authored content 369단위, narrative/relationship 32단위, replay exploration 694,928단위, presentation 1,946단위, proof 71단위로 종류를 분리하며, 품질은 별도 10개 component 가중합으로 계산한다. `tool/verify_quality_score.dart`가 실제 증거에서 99% 목표를 재계산하고, `tool/verify_development_goals.dart`는 quality score·benchmark·결정 chain 실측과 6개 목표의 선행조건·증거를 함께 확인한다.

| 지표 | 기준 | 현재 |
| --- | --- | ---: |
| 게임성 KPI | effectful choice·사건별 결과 분기·다축 선택·보상/비용 교환 선택·조건부 선택·Canvas 결과 피드백·동행 선택 결과를 동시에 판정 | 166/166 · 71/71 · 166/166 · 72/166 (0.4337) · 29 · companion 36/36 · Golden |
| 활동 조합 공간 | 활동 5개 × 48주 | 240 |
| 성장 축 | 지혜·공감·용기 | 3 |
| 중반 공간 | 별자리 기록관·루멘 온실·달빛 시장·강 건너 바람길·새벽 관측소·별씨앗 채석장의 최초 발견 flag/trace | 6 |
| 회차 계승 | authored 엔딩 계열 3개가 다음 회차 시작 스탯·flag·trace와 2주차 선택 보정으로 전달 | 3 |
| 리스크 축 | 피로 0–12, 휴식/과로/성장 페널티 | 1 |
| 성격 대화 | 독립 성격 3개 + 성장축 재능 보너스 | 3 + 3 |
| 캐릭터 대화 자산 | 노아·3명 동료 registry + 사건 authored choice 94개의 speaker key/frame binding | 4 characters + 94 bindings |
| 동행 장면 기록 | 유대·막 조건으로 18개 독립 장면을 열고 장면당 2-way 선택의 성장축·피로·유대·memory flag·응답·route signature를 시스템 승인·trace·save로 기록 | 18 scenes + 36 choices + 18 record commands |
| 동료 관계 | 루미·보라·타로 유대 0–100 + 임계 에필로그 | 3 + 3 |
| 나비효과·동료 퀘스트 | authored memory flag 6개 + 동료별 3단계 퀘스트 9개 + route atlas | 6 + 9 |
| 나비효과 기록 | authored memory flag를 다음 장 단서·엔딩 회고로 투영 | 6 |
| 동료 개인 퀘스트 | 동료별 유대 임계치가 있는 3단계 목표 | 3 × 3 = 9 |
| 발견 경로 | 장소 발견 flag를 홈 route atlas로 표시 | 6 |
| 장기 목표 | 16개 막 목표/보상/성공·실패 피드백 | 16 |
| 막 관계 장면 | 각 막 결산에 동료 speaker·portrait·i18n title/line을 묶은 결정론적 관계 beat | 16/16 |
| 관계 상태 투영 | bond gap·windmill-truce flag를 `unformed/balanced/tension/estranged/truce`로 판정하고 Canvas·ECS trace에 반영 | 5 states + replay trace + 5 exclusive follow-ups |
| 엔딩 콘텐츠 | 스탯별 SSOT 핵심 엔딩 6개(기본/숙련) + 실패·중립·관계 변형 | 6 + 18 |
| 엔딩 결산 | 달성 계절 목표·임계 동료 유대를 합산한 결정론적 루멘 기록 등급 1–3성 | 3 |
| 분기 사건 | 47개 사건 × 선택 2개 | 47 × 2 |
| 분기 도달성 | SSOT의 6개 엔딩·94개 사건 선택 계약 테스트 + 11개 authored branch 축 전수 열거 | 100/100 + 2,048 vectors |
| 조건부 선택 | 스탯·동료 유대·동료 조합·이전 선택 기억·계승을 사용하는 잠금 선택지 | 29 |
| 시각 회귀 | 한국어 fixture·English locale·사건 피드백·관계 상태·관계 긴장·관계 중재·관계 후속 대화·외출·유대 게이트·기억 게이트·계승 게이트·나비효과/동료 퀘스트 기록 보관소(ko/en)·시스템 승인/거절 영수증·동행 장면 선택/잠금/혼합 상태(ko/en) + canonical SSOT 홈·사이드 장면·6개 장소 atlas·48주 handoff 사건·엔딩·원인 회고·엔딩 도감·16막 canonical 사건·실제 16막 chapter-closure 관계 장면·활동 forecast·활동 회고 일지(ko/en)·엔딩 뒤 다음 회차 계승 선택(ko/en)·선택 프로필 상태·새 회차 적용 프로필 피드백·Canvas UI 다섯 상태 행렬 Golden | 102 |
| canonical 통합 경로 | 실제 `story/story.jsonl` 48주 완주·사건 47개·목표 16개·에필로그·승인 영수증·48주 handoff·16막 사건·16막 결산 Golden 행렬 | 1 |
| 최소 1회차 분량 | 48회 일정 + 47회 본편 사건 선택 + 24개 사이드 장면 + 16회 막 결산 + 16회 관계 장면 + 활동 미니 이벤트, SSOT 페이싱 계약 | 156분 (최소 120분) |
| 종료 불변식 | 48주 완료 뒤 49주 terminal에서 추가 활동/사건 입력 차단 + 새 세션 재시작 | 1 |
| Canvas 입력 계약 | 활동·일러스트·성격 탭·일러스트 복귀·사건·보관소 좌표 회귀 | 1 |
| personality campaign 경로 | 지혜·공감·용기 각 성격의 숙련 엔딩 재현 | 3 |
| 글리프 안정성 | 번들 Noto Sans KR + Canvas 벡터 활동 아이콘 | 1 |
| i18n 대사 | `key → locale catalog → Canvas` 한국어/English 대사·엔딩·동료·장소 결산 경로 | 2 locale |
| locale 계약 | SSOT `*Key` 전수 존재·비공백·ko/en 각 800키 이상(실제 1157) 및 character speaker·엔딩·사이드 장면·activity reflection·activity journal·relationship state/follow-up·companion scene choice/rejection UI 키 검사 | 1 |
| 스토리 진행도 | 1–3부터 46–48주까지 16막, 47개 사건·막 목표 연결 | 16 chapters |
| 순수성 분기 | 동일 일정 예산의 지혜·공감 경로 + 5개 SSOT 일정 정책 + 동료 8 route set + 6개 fate thread·9개 퀘스트 stage가 서로 다른 authored 엔딩·유대·목표 서명을 생성 | 2,048 vectors + 8 route sets + 6/9 narrative |
| 자동 게이트 | SSOT 검사·시나리오 vector 열거·해시 매니페스트·정적 분석·Flutter test·Golden·코어 benchmark·Wasm | 8 |
| 상태 안전성 | 저장 화면 복원·종료 후 활동/사건 입력 차단 | 2 |
| 저장/replay | 행동·사건 후 자동 `lumen-save-v7` snapshot + WASM `localStorage` 새로고침 복원 + trace round trip | 1 |
| 엔딩 컬렉션 | 캠페인 종료 시 별도 컬렉션 키에 엔딩 id·최고 등급·관계 route id를 기록하고 재시작 후 도감에 표시 | 6 + 3 routes |

검증 스크립트는 [`tool/verify_game.dart`](../tool/verify_game.dart), [`tool/verify_scenario_variants.dart`](../tool/verify_scenario_variants.dart), [`tool/verify_quality_score.dart`](../tool/verify_quality_score.dart)이며, 콘텐츠·분기·결정론·시각 회귀·locale 계약·스토리 진행도·자산·추적성·배포·입력 계약·저장 연속성·종료 안전성·순수성·시나리오 완전성·최소 플레이타임 계약을 실제 파일과 SSOT에서 계산하고 99% quality score 또는 2,000 vector 미만이면 실패한다. 세 축의 목표·가드레일은 [`docs/trilemma-contract.jsonl`](trilemma-contract.jsonl)에 SSOT 해시와 함께 생성되며 `verify_game.dart`가 먼저 계약 드리프트를 차단한다. 상세 표본은 [`docs/scenario-completeness.md`](scenario-completeness.md)와 `story/story.jsonl#scenarioCompleteness`에 있다. 저장 코드는 [`lib/save_state.dart`](../lib/save_state.dart)의 `lumen-save-v7` 형식으로 복사/복원되고 v3/v4/v5/v6 입력도 호환하며, `history` trace·동료 유대·막 목표·기억 플래그·마지막 행동 결과·사건 대사가 동일하게 보존된다. 피로 8 이상에서는 활동 성장량이 1 감소하고 휴식은 피로를 낮추며, 은화는 코어에서 0–999 범위로 제한된다. 성격 선택은 대응 성장축에 +1 재능을 주고 선택 카드에도 표시하며, 3×3 성격×동료 matrix에서 matching choice는 resonance ECS event로 동료 유대 +1을 적용해 실제 엔딩 route set을 바꾼다. 사건 선택은 동료 유대를 최대 100까지 올려 위험-보상·관계·피드백 루프를 만든다. 이전 사건 선택은 기억 플래그를 기록하고 이후 사건의 authored choice를 열어 재플레이 결과를 바꾼다. 동일한 일정 예산으로도 성장축을 바꾸면 authored 엔딩·유대·replay 결과가 달라지는 순수성 경로를 통합 테스트한다. 조건부 사건 선택은 UI와 `GameSession` 코어 양쪽에서 스탯·관계·기억 잠금을 검증한다. 나비효과 기록은 `resolveFateThreads`가 동일 flag에서 투영하고, 동료별 3단계 퀘스트는 `resolveCompanionQuests`가 유대 임계치와 사건 flag를 함께 판정하며, 여섯 장소 발견은 홈 route atlas로 가시화한다. 임계 유대에 도달하면 엔딩에 동료 에필로그가 결정론적으로 붙고, 달성한 동료별 관계 목표명이 엔딩 상반신 카드에 표시되며, 48주 이후 코어는 활동·사건 입력을 모두 거부한다. `SystemDecisionPolicy`는 사람 승인 없이 fail-closed로 입력을 승인하고 `decisionHash` 영수증을 trace에 추가해 규칙·입력·결과의 계산 가능한 책임을 남긴다. 엔딩 회고는 `history`의 authored 사건을 최대 3개와 달성 목표 수로 요약하고, 미달 목표 최대 2개를 locale-aware 다음 회차 단서로 표시해 결말 원인과 재플레이 방향을 같은 입력에서 재현한다. Canvas Golden 회귀에는 성격 탭 선택과 일러스트 화면의 홈 복귀 입력도 포함되며, 비교기는 Linux/로컬 Canvas 안티앨리어싱 차이에 한해 2% 이하의 bounded tolerance를 허용한다.
