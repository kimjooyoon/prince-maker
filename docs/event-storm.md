<!-- generated: tool/generate_event_storm.dart -->
<!-- source-sha256: 7c8d7f5b032e37c63438e07a8a850ca29625fb3153b7bc5e5e43baddddb23c4e -->
<!-- source-ref: story/story.jsonl#root -->

# Lumen Event Storm

모든 authored 단위를 시스템이 검토 가능한 사건 흐름으로 고정한 생성 원장이다.

`Trigger → Command → Policy → Domain event → Feedback`

| 지표 | 현재 | 증적 기준 |
| --- | ---: | --- |
| 전체 노드 | 133 | 47 본편 + 24 사이드 + 18 동료 + 10 활동 + 18 엔딩 변형 + 16 막 결산 |
| 선택 명령 | 202 | 본편 94 + 사이드 72 |
| 효과 연결률 | 1.0 | 모든 authored choice가 상태 축 또는 기억 flag를 기록 |
| 피드백 연결률 | 1.0 | 모든 authored choice가 lineKey를 갖고 다음 화면에 반환 |
| 다축 선택 | 202 | stat·coin·bond·flag 중 2축 이상 |
| 교환 선택 | 72 | 양의 변화와 음의 변화를 동시에 보유 |
| 조건부 선택 | 65 | stat·bond·memory 정책 gate |
| 분기 노드 | 89 / 71 | 서로 다른 domain event signature |

## 책임 경계

- 판정 주체: `Lumen Ledger System` / 모드 `system-adjudicated`
- 실패 모드: `fail-closed` / 사람 승인 필요: `false`
- 원장은 코드와 CI가 재생성·검증하며, source hash가 어긋나면 승인하지 않는다.

## 사건 경계별 원장 범위

| kind | count | representative source |
| --- | ---: | --- |
| main-event | 47 | story/story.jsonl#events[0] |
| side-scene | 24 | story/story.jsonl#sideScenes[0] |
| companion-scene | 18 | story/story.jsonl#companionScenes[0] |
| activity-mini-event | 10 | story/story.jsonl#activityScenes[0] |
| ending-variant | 18 | story/story.jsonl#endingVariants[0] |
| chapter-closure | 16 | story/story.jsonl#progression[0] |

## 비이진 콘텐츠 증거

- side scene mechanics: companion-pair, exploration, mini-game, resource-crisis
- 각 side node는 위치, 명령 3개, domain event 3개, 정책 gate, 선택 피드백을 함께 보유한다.
- companion·activity·ending·chapter 노드는 선택지 수가 아니라 기록 명령과 후속 피드백을 별도 domain event로 남긴다.

상세 133개 노드는 이 문서와 같은 입력으로 생성된 [`event-storm.jsonl`](event-storm.jsonl)에서 한 줄씩 검토한다.
