<!-- generated: tool/generate_ssot_docs.dart -->
<!-- ssot-sha256: 5eb6fd9fae7a7eeaa3eb0864e82de1babf5fcfba20f529a21c69a2103acac67f -->
<!-- source-ref: story/story.json#root -->

# 프린스 메이커 · SSOT 자동 품질 지표

이 문서는 `story/story.json`에서 자동 생성된다. 코드·Golden·CI의 수치가 SSOT 변경과 함께 갱신되는지 pre-commit에서 확인한다.

| 항목 | 현재 | 산출 기준 |
| --- | ---: | --- |
| 캠페인 길이 | 12주 | `endingWeek` |
| 활동 | 5 | `activities.length` |
| 성격 | 3 | `personalities.length` |
| 동료 | 3 | `companions.length` |
| 계절 목표 | 4 | `milestones.length` |
| 사건 | 6 | `events.length` |
| 사건 선택 | 12 | 모든 사건 choices 합계 |
| 엔딩 | 6 | `endings.length` |
| Canvas Golden | 13 | `test/goldens/*.png` |
| 코드 ref | 11 | `codeRefs.length` |
| 이미지 ref | 4 | `assetRefs.length` |
| 폰트 ref | 1 | `fontRefs.length` |
| 대사 locale | 2 | `localeRefs.length` |

## 폐쇄루프 연결

SSOT → GameWorld 전이 → Canvas/Golden → 저장·replay → benchmark → 같은 SSOT로 재검증. 상세 설계는 [`docs/trilemma.md`](trilemma.md), 전체 지표는 [`docs/game-completeness.md`](game-completeness.md)에서 확인한다.
