# Runtime Architecture

프린스 메이커는 실시간 액션 게임이 아니라 주간 의사결정 시뮬레이션이므로, 렌더링 프레임보다 상태 재현성과 콘텐츠 변경 안전성을 우선한다.

```text
Canvas adapter
    ↓ commands
GameSession (application port)
    ↓ SystemDecisionPolicy → receipt
    ↓ ordered events
GameWorld (ECS/DOD components + systems)
    ↙              ↘
StoryPort       SavePort
JsonStoryAdapter BrowserSaveAdapter / MemorySaveAdapter / GameSnapshot
```

## ECS/DOD

- `StatsComponent`와 `ProgressComponent`는 엔티티 `0`에 붙은 순수 데이터다.
- `ActivityChosen`, `StoryChoiceMade`, `WeekAdvanced`는 불변 이벤트 데이터다.
- `GameWorld.dispatch`는 FIFO 큐를 drain하며 한 번에 하나의 시스템 전이만 적용한다.
- 같은 이벤트 배열과 같은 SSOT를 주면 같은 `GameSnapshot`과 `replayTrace`가 나온다.
- 같은 목표·유대 상태를 주면 같은 엔딩과 1–3성 `rank` 결산이 나온다.
- `SystemDecisionPolicy`가 활동·사건 명령을 fail-closed로 판정하고, 승인·거절 모두 `decisionHash`가 포함된 `SystemDecisionReceipt`를 먼저 trace에 남긴다. 사람의 체크 표시나 런타임 네트워크가 판정 경로에 들어오지 않는다.
- 진행 `SavePort`와 캠페인 간 `CollectionPort`는 분리된다. 전자는 `lumen-save-v7`, 후자는 WASM `localStorage`의 `lumen-collection-v1` 키를 사용한다.

## EDA와 Hexagonal 경계

UI는 `GameSession`의 명령만 호출하고 JSON 파일이나 저장 구현을 직접 알지 않는다. 스토리는 `StoryPort`와 결정론적 `resolveEnding`, 저장은 `SavePort`로 분리해 향후 IndexedDB·파일 저장·서버 동기화 어댑터를 교체할 수 있다. WASM 웹 런타임은 `BrowserSaveAdapter`로 `window.localStorage`에 저장하고, VM Golden 테스트는 조건부 `MemorySaveAdapter` fallback을 사용한다. 활동·사건 명령이 끝날 때마다 최신 상태를 자동 snapshot하며, 브라우저 새로고침 뒤에도 진행과 저장 당시 화면(page)을 복원하고, 새 캠페인 시작 시 이전 snapshot을 명시적으로 지운다. 엔딩 도감이 비어 있지 않은 새 캠페인은 `legacy-star`를 초기 seed해 2주차 authored choice 공간을 결정론적으로 넓힌다. export/import는 동료 유대·계절 목표·기억 플래그·마지막 행동 피드백·사건 대사까지 포함한 versioned `lumen-save-v7` JSON snapshot으로 제공한다. v3/v4/v5/v6 입력도 읽어 기존 기록을 폐기하지 않는다.

Canvas 입력과 렌더링은 [`lib/canvas_surface.dart`](../lib/canvas_surface.dart)의 `CanvasViewport`를 공유한다. 따라서 화면의 중앙 정렬·축소 비율·logical hit-test가 하나의 순수 좌표 함수에서 나오며, [`test/canvas_surface_test.dart`](../test/canvas_surface_test.dart)가 같은 viewport 입력의 경계값을 결정론적으로 고정한다. 화면 컴포넌트를 분리해도 Golden 좌표계는 변하지 않는다.
시스템 책임 화면은 [`lib/decision_receipt.dart`](../lib/decision_receipt.dart)의 순수 parser가 `GameWorld` trace에서 승인·거절 영수증만 역순으로 투영한다. Canvas는 이 projection의 owner·contract·rule·decisionHash를 표시하고, [`test/system_receipt_golden_test.dart`](../test/system_receipt_golden_test.dart)가 사람의 별도 확인 없이 같은 trace를 재현한다.
`Scene.shouldRepaint`는 [`lib/canvas_scene_fingerprint.dart`](../lib/canvas_scene_fingerprint.dart)의 순서 독립 fingerprint 하나만 비교한다. Map 삽입 순서가 바뀌어도 같은 상태는 같은 key를 만들고, 스탯·선택·페이지·trace가 바뀌면 key가 달라진다. 이 경계는 [`test/canvas_scene_fingerprint_test.dart`](../test/canvas_scene_fingerprint_test.dart)와 전체 Canvas Golden으로 검증한다.
활동 카드는 [`lib/activity_catalog.dart`](../lib/activity_catalog.dart)의 SSOT adapter가 authored 순서와 성장·피로·은화 tradeoff를 `Activity` 데이터로 투영한다. Canvas와 `GameSession`은 같은 catalog를 소비하며, 기본 5개 활동과 임의 story 입력의 순서·축·비용을 [`test/activity_catalog_test.dart`](../test/activity_catalog_test.dart)가 고정한다.
렌더링 경계는 [`docs/render-quality-contract.jsonl`](render-quality-contract.jsonl)의 세 선행조건을 먼저 통과해야 한다. [`tool/verify_render_quality.dart`](../tool/verify_render_quality.dart)는 viewport 기하·tap inverse·single render path를 실제 소스와 테스트/Golden 증적으로 확인하며, `ci_gate.dart`가 이를 완전성·순수성·성능 축의 필수 check로 실행한다. 따라서 선행 증명이 없는 Canvas 변경은 사람의 추론이나 승인으로 우회되지 않는다.
개발 작업량과 다음 목표도 [`docs/development-goals.jsonl`](development-goals.jsonl)의 authored content·narrative relationship·replay·presentation·proof 단위 원장으로 계산한다. [`tool/verify_development_goals.dart`](../tool/verify_development_goals.dart)는 목표별 target/current/gap·선행조건·증거를 검증하고, benchmark 실측과 함께 `build/development-goal-verdict.json`에 시스템 판정을 남긴다.
UI는 `GameSession`의 명령만 호출하고 JSON 파일이나 저장 구현을 직접 알지 않는다. 스토리는 `StoryPort`와 결정론적 `resolveEnding`, 저장은 `SavePort`로 분리해 향후 IndexedDB·파일 저장·서버 동기화 어댑터를 교체할 수 있다. WASM 웹 런타임은 `BrowserSaveAdapter`로 `window.localStorage`에 저장하고, VM Golden 테스트는 조건부 `MemorySaveAdapter` fallback을 사용한다. 활동·사건 명령이 끝날 때마다 최신 상태를 자동 snapshot하며, 브라우저 새로고침 뒤에도 진행과 저장 당시 화면(page)을 복원하고, 새 캠페인 시작 시 이전 snapshot을 명시적으로 지운다. 엔딩 도감이 비어 있지 않은 새 캠페인은 `legacy-star`를 초기 seed해 2주차 authored choice 공간을 결정론적으로 넓힌다. export/import는 동료 유대·계절 목표·기억 플래그·마지막 행동 피드백·사건 대사까지 포함한 versioned `lumen-save-v7` JSON snapshot으로 제공한다. v3/v4/v5/v6 입력도 읽어 기존 기록을 폐기하지 않는다.

## 시스템 책임 경계

`story/story.jsonl#decisionSystem`이 승인 주체·규칙·실패 모드·영수증 필드를 선언한다. [`lib/decision_proof.dart`](../lib/decision_proof.dart)의 `SystemDecisionPolicy`는 SSOT 계약·현재 precondition·직전 parent hash를 함께 해시하고, `GameSession`은 이를 호출해 승인된 `SystemDecisionApproved` 이벤트를 ECS 큐에 넣는다. 조건 미충족·미등록 성장축·terminal 입력은 같은 정책으로 거절되며 상태 전이를 만들지 않는다. 게임 규칙의 책임은 “누가 버튼을 눌렀는가”가 아니라 “어떤 SSOT 규칙과 입력 해시가 이 상태를 만들었는가”로 정의하고, CI에서는 `tool/ci_gate.dart`가 동일한 원칙으로 Golden·benchmark·Wasm을 승인한다.
[`docs/decision-proof-contract.jsonl`](decision-proof-contract.jsonl)이 precondition 필드·genesis root·parent/decision hash·replay 일치 규칙을 선언하며, [`tool/verify_decision_proof.dart`](../tool/verify_decision_proof.dart)가 렌더링·스토리·benchmark보다 먼저 이 계약을 판정한다. 계약 누락이나 hash drift는 사람의 승인으로 우회할 수 없고 fail-closed로 거절된다.

스토리 영향 코드의 연결은 [`story/story.jsonl#codeRefs`](../story/story.jsonl)에서 파일 ref와 SHA-256으로 선언하고, `verify_game.dart`가 drift를 거부한다. 문서 생성 결과와 에이전트 검토 해시는 [`docs/review-manifest.jsonl`](review-manifest.jsonl)이 관리한다.
