<!-- generated: tool/generate_ssot_docs.dart -->
<!-- ssot-sha256: 40ca769e2189b24dcf3541f56a755faff9b2257cd91638a4d60c302d5d7a4072 -->
<!-- source-ref: story/story.json#root -->

# 프린스 메이커 · SSOT 자동 품질 지표

이 문서는 `story/story.json`에서 자동 생성된다. 코드·Golden·CI의 수치가 SSOT 변경과 함께 갱신되는지 pre-commit에서 확인한다.

| 항목 | 현재 | 산출 기준 |
| --- | ---: | --- |
| 캠페인 길이 | 48주 + terminal week | `campaignWeeks`, `endingWeek` |
| 최소 플레이타임 | 120분 | `contentBudget.minimumMinutes` |
| 1회차 추정 | 129분 | `contentBudget.estimatedFirstPlaythroughMinutes` |
| 시나리오 경우의 수 | 2048개 검증 / 2000개 최소 | `scenarioVariantBudget` · CI branch-vector enumeration |
| 전체 route input | 122880개 | 활동 × 성격 × 계승 컨텍스트 × authored branch vector |
| 엔딩 route card | 48개까지 | 핵심 엔딩 × 동료 route set |
| 시스템 판정 | lumen-ledger | SSOT `decisionSystem` · fail-closed receipt |
| 활동 | 5 | `activities.length` |
| 성격 | 3 | `personalities.length` |
| 동료 | 3 | `companions.length` |
| 회차 계승 프로필 | 3 | `legacyProfiles.length` |
| 계절 목표 | 16 | `milestones.length` |
| 사건 | 47 | `events.length` |
| 사건 선택 | 94 | 모든 사건 choices 합계 |
| 엔딩 | 6 | `endings.length` |
| Canvas Golden | 27 | `test/goldens/*.png` |
| 코드 ref | 13 | `codeRefs.length` |
| 이미지 ref | 4 | `assetRefs.length` |
| 폰트 ref | 1 | `fontRefs.length` |
| 대사 locale | 2 | `localeRefs.length` |
| 스토리 막 | 16 | `progression.length` · 1–3주 / 4–6주 / 7–9주 / 10–12주 / 13–15주 / 16–18주 / 19–21주 / 22–24주 / 25–27주 / 28–30주 / 31–33주 / 34–36주 / 37–39주 / 40–42주 / 43–45주 / 46–48주 |
| 막 계약 | 16/16 | 각 막의 `contract` 공개·압력·선택·결산 선언 |
| 시나리오 완전성 차원 | 8 | `scenarioCompleteness.dimensions.length` |
| locale 최소 키 | 398 | `dialogueMetrics.minimumLocaleKeys` |
| 캠페인 최소 대사 줄 | 47 | 48주 authored 사건 선택 노출 기준 |
| 캠페인 최소 서사 단위 | 160 | 성격·사건 제목/본문·선택·엔딩 |

## 폐쇄루프 연결

SSOT → GameWorld 전이 → Canvas/Golden → 저장·replay → benchmark → 같은 SSOT로 재검증. 기계 판정 기준은 [`docs/trilemma-contract.json`](trilemma-contract.json), 상세 설계는 [`docs/trilemma.md`](trilemma.md), 전체 지표는 [`docs/game-completeness.md`](game-completeness.md)에서 확인한다.
