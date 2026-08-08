# 폐쇄루프 트릴레마

프린스 메이커의 품질은 한 숫자만 올리는 방식으로 관리하지 않는다. 모든 변경은 다음 세 축을 함께 통과해야 한다.

| 축 | 플레이어에게 의미 | 자동 증거 |
| --- | --- | --- |
| 완전성 | 콘텐츠·분기·저장·화면·대사가 끝까지 이어지는가 | `verify_game.dart` 14차원 + 120분 분량 계약, 시나리오 8축, 2,048개 실제 분기 벡터(최소 2,000), 122,880개 route input 계약, Golden 27종(도입·중반·48주 handoff·terminal), 4개 장소 발견 flag/trace, 3개 회차 계승 프로필, 398 locale keys × 한국어·English 계약, 엔딩 원인·미달 목표 회고 |
| 순수성 | 선택이 스탯·관계·목표·엔딩을 바꾸며 다시 플레이할 이유가 있는가 | 활동 5개, 성장축 3개, 동료 3명, 관계 rival loss·상호 중재·동행 목표 3개, 동료 route set 8개 실제 코어 재생, 2,048개 분기 signature, 122,880개 route input 계약, 4개 장소 발견, 외출 2개, 목표 16개, 사건 47개, 엔딩 6개, 3개 계승 프로필의 시작 스탯 변형·2주차 authored 보정, 1–3성 결산 등급, 누적 엔딩 도감·계승 해금, 5개 SSOT 일정 정책 중 3개 이상 distinct ending/signature |
| 성능 | 같은 입력을 빠르고 재현 가능하게 처리하는가 | `benchmark_game.dart` 실제 SSOT 5,000 campaign / 475,000 application transitions, 24초 운영 예산, replay signature 3개 이상, 3개 계승 프로필별 분포 |

## 폐쇄루프

```text
SSOT 콘텐츠 → GameWorld 전이 → Canvas/Golden 증거
     ↑              ↓                 ↓
  재플레이 ← 저장·replay trace ← benchmark
```

현재 장편 계약은 48주·16막·47개 사건·94개 선택지이며, 48회 일정 반영과 16회 막 결산을 포함한 보수적 콘텐츠 예산이 최소 120분을 넘도록 SSOT에서 계산된다.

시나리오 경우의 수는 단순히 주차 수를 곱하지 않는다. SSOT의 11개 무조건 authored 분기 주차를 모두 재생하는 `tool/verify_scenario_variants.dart`가 `2^11 = 2,048`개의 결정론적 replay trace를 확인하고, 활동 5개·성격 3개·계승 컨텍스트 4개를 곱한 122,880개 route input 계약을 함께 판정한다. 각 경우는 사건 trace·성장축 엔딩·스탯·유대·막 목표·기억 flag를 포함한다.

엔딩은 3개 성장축의 기본/숙련 6개 core family를 먼저 판정하고, 기록 등급과 동료 route set을 후처리한다. 동료 route set은 solo·단일 동행·복수 동행으로 읽히며, 3명 동료의 부분집합 8개와 6개 core ending을 조합해 최대 48개 terminal route card를 만든다. 엔딩 화면은 이 경로의 유대 에필로그와 원인 회고를 함께 보여준다.

성능 benchmark는 렌더러 프레임을 임의로 측정하지 않고, `story/story.json`을 읽은 `GameSession`이 5,000개의 48주 campaign과 47개 사건 선택을 처리하는 시간을 측정한다. campaign의 절반은 엔딩 도감에서 얻은 3개 계승 프로필을 순환해 프로필의 성장축을 결정론적으로 선택하고 시작 스탯 변형을 적용한다. 각 campaign의 `(ending, stats, bonds, goals, flags)` 서명과 계승 프로필별 signature/ending cardinality/companion epilogue를 수집해 최소 3개의 순수성 signature, 3개 lineage signature 집합, 프로필이 선언한 target ending과 target companion 집합이 실제로 생기는지도 확인한다. 동일 workload를 한 번 더 실행해 `replayChecksum`, signature cardinality, lineage profile cardinality를 대조한다. 따라서 네트워크·폰트·브라우저 상태와 무관하게 SSOT 콘텐츠가 실제로 연결된 게임 규칙의 비용·재현성·결과 다양성을 함께 감시한다.

각 축이 독립적으로 통과해야 하며, 하나라도 실패하면 pre-commit과 GitHub Actions가 변경을 거부한다. 완전성의 시각 하위 게이트는 27개 Golden 파일과 README 연결을 정확히 대조하고, canonical 경로가 4주차 중반 사건뿐 아니라 46–48주 `handoff` 막의 마지막 사건과 terminal 엔딩까지 실제 SSOT에서 렌더링하는지 고정한다. 시나리오 하위 게이트는 SSOT의 8축(아크·행위성·관계·피드백·조건·재플레이·장면·종결)과 16막 각각의 `reveal → pressureAxes → choiceWeeks → closureMilestone` 계약을 실제 사건·막 목표와 대조한다. 장소 하위 게이트는 네 장소가 사건 진입 시 ECS `LocationDiscovered`와 `place:<id>` flag/trace로 한 번씩만 기록되는지 통합 테스트와 benchmark가 대조한다. 회차 계승 하위 게이트는 도감 엔딩이 3개 legacy profile 중 하나로 정규화되고 시작 스탯 +2·`legacy:<id>` flag·trace·2주차 프로필별 보정 trace를 같은 입력에서 재현하는지 코어·Golden·benchmark가 대조한다. 대사 하위 게이트는 SSOT의 모든 `*Key`와 엔딩 UI 키가 각 locale에 존재하고 비어 있지 않은지 확인한다. 시스템 책임 하위 게이트는 `SystemDecisionPolicy`가 사람 승인 없이 fail-closed로 입력을 판정하고, 승인·거절 모두 `decisionHash` 영수증을 trace에 남기며 동일 replay에서 일치하는지 확인한다. 순수성의 replay 하위 게이트는 같은 입력의 snapshot·trace 동일성, rival bond의 손실·상호 중재와 `windmill-truce` 기억 trace, 외출의 은화-성장-유대 교환, 유대 2 이상을 요구하는 관계 게이트와 이전 선택 기억을 요구하는 memory 게이트, 엔딩 도감에서 다음 회차의 선택을 여는 legacy 게이트의 코어/UI 일치, 다른 성장축의 authored 결과 차이, 5개 SSOT 일정 정책의 실제 결과 다양성, 엔딩 회고의 사건 순서·미달 목표 단서 보존을 함께 확인한다.

세 축의 목표와 가드레일은 [`trilemma-contract.json`](trilemma-contract.json)에 SSOT 해시와 함께 생성된다. 완전성은 최소 95%·8개 시나리오 차원·2,048개 실제 분기 vector(최소 2,000)·27개 Golden·398 locale 키·4개 장소 trace·3개 계승 프로필·3개 프로필별 선택 보정·120분 플레이타임, 순수성은 2,048개 branch signature·8개 동료 route set·122,880개 route input 계약·3개 이상 authored 엔딩·replay signature·계승 프로필별 route signature·target ending·target companion epilogue, 성능은 5,000 campaign·475,000 transition·24초 운영 예산·checksum 재현·4개 장소 집합·3개 lineage 분포·계승 프로필 순환을 계약으로 고정한다. 24초는 9.3–9.4초 로컬 측정과 원격 runner 변동을 감안한 fail-closed 상한이며, 캠페인 수·전이 수·결과 재현성은 낮추지 않는다. 시스템 승인과 Wasm까지 같은 `tool/ci_gate.dart`가 순서대로 실행하며 하나라도 실패하면 `SYSTEM_APPROVAL: REJECT`로 종료한다. 계약 검사는 `verify_game.dart`와 `ending_matrix_test.dart`가 담당하고 실제 시간·분기 다양성은 `benchmark_game.dart`와 `verify_scenario_variants.dart`가 매 실행 측정한다.
