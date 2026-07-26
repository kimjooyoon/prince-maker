# Runtime Architecture

프린스 메이커는 실시간 액션 게임이 아니라 주간 의사결정 시뮬레이션이므로, 렌더링 프레임보다 상태 재현성과 콘텐츠 변경 안전성을 우선한다.

```text
Canvas adapter
    ↓ commands
GameSession (application port)
    ↓ ordered events
GameWorld (ECS/DOD components + systems)
    ↙              ↘
StoryPort       SavePort
JsonStoryAdapter MemorySaveAdapter / GameSnapshot
```

## ECS/DOD

- `StatsComponent`와 `ProgressComponent`는 엔티티 `0`에 붙은 순수 데이터다.
- `ActivityChosen`, `StoryChoiceMade`, `WeekAdvanced`는 불변 이벤트 데이터다.
- `GameWorld.dispatch`는 FIFO 큐를 drain하며 한 번에 하나의 시스템 전이만 적용한다.
- 같은 이벤트 배열과 같은 SSOT를 주면 같은 `GameSnapshot`과 `replayTrace`가 나온다.

## EDA와 Hexagonal 경계

UI는 `GameSession`의 명령만 호출하고 JSON 파일이나 저장 구현을 직접 알지 않는다. 스토리는 `StoryPort`와 결정론적 `resolveEnding`, 저장은 `SavePort`로 분리해 향후 IndexedDB·파일 저장·서버 동기화 어댑터를 교체할 수 있다. 현재 기본 저장 어댑터는 단일 사용자 로컬 플레이를 위한 메모리 어댑터이며, export/import는 동료 유대·계절 목표·마지막 행동 피드백까지 포함한 versioned `lumen-save-v5` JSON snapshot으로 제공한다. v3/v4 입력도 읽어 기존 기록을 폐기하지 않는다.

스토리 영향 코드의 연결은 [`story/story.json#codeRefs`](../story/story.json)에서 파일 ref와 SHA-256으로 선언하고, `verify_game.dart`가 drift를 거부한다. 문서 생성 결과와 에이전트 검토 해시는 [`docs/review-manifest.json`](review-manifest.json)이 관리한다.
