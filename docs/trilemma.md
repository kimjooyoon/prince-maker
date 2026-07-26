# 폐쇄루프 트릴레마

프린스 메이커의 품질은 한 숫자만 올리는 방식으로 관리하지 않는다. 모든 변경은 다음 세 축을 함께 통과해야 한다.

| 축 | 플레이어에게 의미 | 자동 증거 |
| --- | --- | --- |
| 완전성 | 콘텐츠·분기·저장·화면이 끝까지 이어지는가 | `verify_game.dart` 11차원, 18/18 authored branch, Golden 10종(SSOT canonical 홈·엔딩·도감 포함) |
| 순수성 | 선택이 스탯·관계·목표·엔딩을 바꾸며 다시 플레이할 이유가 있는가 | 활동 5개, 성장축 3개, 동료 3명, 목표 4개, 사건 6개, 엔딩 6개, 1–3성 결산 등급, 누적 엔딩 도감, 60개 일정 조합 |
| 성능 | 같은 입력을 빠르고 재현 가능하게 처리하는가 | `benchmark_game.dart` 5,000 campaign / 120,000 core transitions, 5초 예산 |

## 폐쇄루프

```text
SSOT 콘텐츠 → GameWorld 전이 → Canvas/Golden 증거
     ↑              ↓                 ↓
  재플레이 ← 저장·replay trace ← benchmark
```

성능 benchmark는 렌더러 프레임을 임의로 측정하지 않고, 게임의 순수 결정론 코어가 5,000개의 12주 campaign을 처리하는 시간을 측정한다. 측정 후 동일 workload를 한 번 더 실행해 `replayChecksum`을 첫 checksum과 대조한다. 따라서 네트워크·폰트·브라우저 상태와 무관하게 게임 규칙의 비용과 checksum 재현성을 함께 감시한다.

각 축이 독립적으로 통과해야 하며, 하나라도 실패하면 pre-commit과 GitHub Actions가 변경을 거부한다. 완전성의 시각 하위 게이트는 7개 Golden 파일과 README 연결을 정확히 대조하고, 순수성의 replay 하위 게이트는 같은 입력의 snapshot·trace 동일성과 다른 성장축의 authored 결과 차이를 함께 확인한다.
