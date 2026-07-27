# 폐쇄루프 트릴레마

프린스 메이커의 품질은 한 숫자만 올리는 방식으로 관리하지 않는다. 모든 변경은 다음 세 축을 함께 통과해야 한다.

| 축 | 플레이어에게 의미 | 자동 증거 |
| --- | --- | --- |
| 완전성 | 콘텐츠·분기·저장·화면·대사가 끝까지 이어지는가 | `verify_game.dart` 14차원, 시나리오 8축, 26/26 authored branch, Golden 20종, SSOT 대사 키 × 한국어·English locale 계약 |
| 순수성 | 선택이 스탯·관계·목표·엔딩을 바꾸며 다시 플레이할 이유가 있는가 | 활동 5개, 성장축 3개, 동료 3명, 관계 rival bond, 외출 2개, 목표 4개, 사건 10개, 엔딩 6개, 1–3성 결산 등급, 누적 엔딩 도감·계승 해금, 5개 SSOT 일정 정책 중 3개 이상 distinct ending/signature |
| 성능 | 같은 입력을 빠르고 재현 가능하게 처리하는가 | `benchmark_game.dart` 실제 SSOT 5,000 campaign / 105,000 application transitions, 10 사건, 5초 예산, replay signature 3개 이상 |

## 폐쇄루프

```text
SSOT 콘텐츠 → GameWorld 전이 → Canvas/Golden 증거
     ↑              ↓                 ↓
  재플레이 ← 저장·replay trace ← benchmark
```

성능 benchmark는 렌더러 프레임을 임의로 측정하지 않고, `story/story.json`을 읽은 `GameSession`이 5,000개의 12주 campaign과 10개 사건 선택(5·11주차 외출 포함)을 처리하는 시간을 측정한다. campaign의 절반은 엔딩 도감 계승을 나타내는 `legacy-star` seed로 실행하고, 각 campaign의 `(ending, stats, bonds, goals, flags)` 서명을 수집해 최소 3개의 순수성 signature가 생기는지도 확인한다. 동일 workload를 한 번 더 실행해 `replayChecksum`과 signature cardinality를 대조한다. 따라서 네트워크·폰트·브라우저 상태와 무관하게 SSOT 콘텐츠가 실제로 연결된 게임 규칙의 비용·재현성·결과 다양성을 함께 감시한다.

각 축이 독립적으로 통과해야 하며, 하나라도 실패하면 pre-commit과 GitHub Actions가 변경을 거부한다. 완전성의 시각 하위 게이트는 20개 Golden 파일과 README 연결을 정확히 대조하고, 시나리오 하위 게이트는 SSOT의 8축(아크·행위성·관계·피드백·조건·재플레이·장면·종결)과 4막 각각의 `reveal → pressureAxes → choiceWeeks → closureMilestone` 계약을 실제 사건·계절 목표와 대조한다. 대사 하위 게이트는 SSOT의 모든 `*Key`와 엔딩 UI 키가 각 locale에 존재하고 비어 있지 않은지 확인한다. 순수성의 replay 하위 게이트는 같은 입력의 snapshot·trace 동일성, rival bond의 기회비용 trace, 외출의 은화-성장-유대 교환, 유대 2 이상을 요구하는 관계 게이트와 이전 선택 기억을 요구하는 memory 게이트, 엔딩 도감에서 다음 회차의 선택을 여는 legacy 게이트의 코어/UI 일치, 다른 성장축의 authored 결과 차이, 5개 SSOT 일정 정책의 실제 결과 다양성을 함께 확인한다.
