<!-- generated: tool/generate_ssot_docs.dart -->
<!-- ssot-sha256: a1e2751da583a6460471c4677522258c2e15a6414c35216f586eba1ec447f8d5 -->
<!-- source-ref: story/story.jsonl#root -->

# 프린스 메이커 · SSOT 자동 품질 지표

이 문서는 `story/story.jsonl`에서 자동 생성된다. 코드·Golden·CI의 수치가 SSOT 변경과 함께 갱신되는지 pre-commit에서 확인한다.

| 항목 | 현재 | 산출 기준 |
| --- | ---: | --- |
| 캠페인 길이 | 48주 + terminal week | `campaignWeeks`, `endingWeek` |
| 최소 플레이타임 | 120분 | `contentBudget.minimumMinutes` |
| 1회차 추정 | 156분 | `contentBudget.estimatedFirstPlaythroughMinutes` |
| 시나리오 경우의 수 | 2048개 검증 / 2000개 최소 | `scenarioVariantBudget` · CI branch-vector enumeration |
| 전체 route input | 122880개 | 활동 × 성격 × 계승 컨텍스트 × authored branch vector |
| 엔딩 route card | 48개까지 | 핵심 엔딩 × 동료 route set |
| 나비효과 기록 | 6 | `fateThreads.length` · authored memory flag 기반 |
| 동료 퀘스트 | 3개 / 9 stages | `companionQuests` · 동료별 3단계 |
| 시스템 판정 | lumen-ledger | SSOT `decisionSystem` · fail-closed receipt |
| 렌더러 결정 | `flutter-canvas-wasm` | SSOT `engineDecision` · Golden/WASM 적합도 계약 |
| 활동 | 5 | `activities.length` |
| 성격 | 3 | `personalities.length` |
| 성격 × 동료 공명 | 9 (3 matched) | `personalityCompanionRoutes` · matching choice bond +1 |
| 캐릭터 아카이브 | 20 | `characterArchive.length` · PNG sheetIndex |
| 캐릭터 아트 계약 | 20/20 | illustration·silhouette·gesture·5 emotion notes |
| 동료 | 3 | `companions.length` |
| 회차 계승 프로필 | 3 | `legacyProfiles.length` |
| 계절 목표 | 16 | `milestones.length` |
| 사건 | 47 | `events.length` |
| 전체 authored scene | 71 | `events.length + sideScenes.length` |
| 사이드 장면 | 24 | `sideScenes.length` · 탐험/위기/자원/미니게임/동료 조합 |
| 활동 미니 이벤트 | 10 | `activityScenes.length` · 활동별 2개 |
| 동료 독립 장면 | 18 | `companionScenes.length` · 3명×6개 |
| 엔딩 변형 | 18 | `endingVariants.length` · 핵심 엔딩별 실패/중립/관계 |
| 이벤트 스토밍 노드 | 133 | 본편·사이드·동료·활동·엔딩 변형·막 결산을 합친 생성 원장 |
| 사건 선택 | 94 | 모든 사건 choices 합계 |
| 교환 선택 | 72/166 (0.43373493975903615) | `gameplayKpis.current.tradeoffRate` · 양의 축과 음의 축 동시 보유 |
| 엔딩 | 6 | `endings.length` |
| Canvas Golden | 87 | `test/goldens/*.png` |
| 코드 ref | 95 | `codeRefs.length` |
| 이미지 ref | 78 | `assetRefs.length` |
| 폰트 ref | 1 | `fontRefs.length` |
| 대사 locale | 2 | `localeRefs.length` |
| 스토리 막 | 16 | `progression.length` · 1–3주 / 4–6주 / 7–9주 / 10–12주 / 13–15주 / 16–18주 / 19–21주 / 22–24주 / 25–27주 / 28–30주 / 31–33주 / 34–36주 / 37–39주 / 40–42주 / 43–45주 / 46–48주 |
| 막 계약 | 16/16 | 각 막의 `contract` 공개·압력·선택·결산 선언 |
| 시나리오 완전성 차원 | 8 | `scenarioCompleteness.dimensions.length` |
| locale 최소 키 | 1051 | `dialogueMetrics.minimumLocaleKeys` |
| 캠페인 최소 대사 줄 | 63 | 48주 authored 사건 선택 노출 기준 |
| 캠페인 최소 서사 단위 | 240 | 성격·사건 제목/본문·선택·엔딩 |

## 폐쇄루프 연결

SSOT → GameWorld 전이 → Canvas/Golden → 저장·replay → benchmark → 같은 SSOT로 재검증. 기계 판정 기준은 [`docs/trilemma-contract.jsonl`](trilemma-contract.jsonl), 상세 설계는 [`docs/trilemma.md`](trilemma.md), 전체 지표는 [`docs/game-completeness.md`](game-completeness.md)에서 확인한다.
