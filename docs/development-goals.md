<!-- generated: tool/generate_development_goals.dart -->
<!-- source-sha256: bb3906303e6ec5bdfb7cdfd911afbfdd1bc216fe032c9045850e0953a20236cb|df76a255dcd652fb75441fefa10d101edd06a26f0c40cc651ead4ca1321ee477|1ce94c96d1e2f54e039a51d7d63e78a84f26b615ff18ebf5c70c8c63f7ef1bc3|854f4732b73c4fcc9dffeb287ae6577d8481430d301f567cf1da93d9df9bd460 -->
<!-- source-ref: story/story.jsonl#root -->

# 프린스 메이커 · 정량 개발목표 원장

이 문서는 SSOT·트릴레마·렌더 계약에서 개발 목표, 현재 계약값, gap, 투입 단위와 검증 증거를 결정론적으로 생성한다.

## 판정 규칙

- 판정 주체: **Lumen Development Goal Gate** · 사람 승인 필요: `false` · 실패 모드: `fail-closed`
- gap 산식: `max(target - current, 0)` · 정적 계약 충족과 실제 실행 증명은 분리한다.

## 99% 품질 점수

품질 점수는 `sum(component.score × component.weight)`로 계산하며, 목표는 `0.99`(99%)다. 각 component는 실제 SSOT·검증 산출물에서 재계산되고 0.99 미만이면 fail-closed로 거절된다.

| Component | 가중치 | 목표 | 산식 | 증거 |
| --- | ---: | ---: | --- | --- |
| `scenario-contract` | 0.12 | 8 | valid scenario dimensions / 8 | `tool/verify_game.dart#scenario-contract` |
| `choice-impact` | 0.12 | 1.0 | effectful authored choices / authored choices | `build/gameplay-fun-verdict.json#metrics.choiceImpactRate` |
| `event-divergence` | 0.1 | 1.0 | events with distinct authored effects / events | `build/gameplay-fun-verdict.json#metrics.eventDivergenceRate` |
| `multi-axis-choice` | 0.1 | 0.9 | choices changing at least two numeric axes / choices | `build/gameplay-fun-verdict.json#metrics.multiAxisImpactRate` |
| `gated-choice` | 0.08 | 20 | min(gated authored choices / 20, 1) | `build/gameplay-fun-verdict.json#metrics.gatedChoices` |
| `chapter-event-golden` | 0.1 | 16 | chapter event Goldens / 16 | `test/goldens/chapter-*.png` |
| `chapter-closure-golden` | 0.1 | 16 | chapter closure Goldens / 16 | `test/goldens/chapter-closure-*.png` |
| `locale-coverage` | 0.08 | 505 | minimum locale catalog keys / 505 | `story/locales/{ko,en}.jsonl#catalog` |
| `replay-determinism` | 0.1 | 1.0 | benchmark checksum == replayChecksum and approved | `build/benchmark-verdict.json#checksumReplayMustMatch` |
| `runtime-proof` | 0.1 | 1.0 | decision proof + gameplay proof + benchmark all approve | `build/{decision-proof,gameplay-fun,benchmark}-verdict.json` |

## 개발 목표

| ID | 축 | 우선순위 | 목표 | 현재 계약값 | gap | 상태 |
| --- | --- | --- | --- | --- | ---: | --- |
| `G1-completeness` | completeness | P0 | 장편 캠페인 완전성 · `{"value":0.99,"unit":"gate-score","display":"≥99%"}` | `{"value":1.0,"unit":"gate-score","formula":"8/8 scenario dimensions declared with target/current/evidence"}` | `0` | contract-satisfied; runtime-proof-required |
| `G2-agency-replay` | purity | P0 | 선택 행위성과 재플레이 공간 · `{"scenarioCases":2000,"routeInputs":122880,"unit":"deterministic-replay-cases"}` | `{"scenarioCases":2048,"routeInputs":122880,"branchVectors":2048,"formula":"2^11 unconditional authored branch vectors × 5 activity policies × 3 personality routes × 4 legacy contexts = 122,880 route inputs; the CI enumerator replays all 2,048 branch vectors and requires at least 2,000 distinct deterministic scenario traces."}` | `{scenarioCases: 0, routeInputs: 0}` | contract-satisfied; runtime-proof-required |
| `G3-narrative-depth` | completeness | P1 | 관계·기억·계승 서사 깊이 · `{"fateThreads":6,"companionQuestStages":9,"endings":6,"legacyProfiles":3,"unit":"authored-narrative-units"}` | `{"fateThreads":6,"companionQuestStages":9,"endings":6,"legacyProfiles":3}` | `{fateThreads: 0, companionQuestStages: 0, endings: 0, legacyProfiles: 0}` | contract-satisfied; runtime-proof-required |
| `G4-presentation` | completeness | P1 | 시각·locale 품질 증적 · `{"goldens":30,"locales":2,"keysPerLocale":1187,"renderPreconditions":3,"renderProofs":5,"unit":"presentation-proof-units"}` | `{"goldens":107,"locales":2,"keysPerLocale":1187,"renderPreconditions":3,"renderProofs":5}` | `{goldens: 0, locales: 0, keysPerLocale: 0, renderPreconditions: 0, renderProofs: 0}` | contract-satisfied; runtime-proof-required |
| `G5-deterministic-throughput` | performance | P0 | 결정론적 처리량과 replay · `{"campaigns":5000,"transitions":565000,"maxMillis":24000,"unit":"benchmark-contract"}` | `{"campaigns":5000,"transitions":565000,"maxMillis":24000,"checksumReplayMustMatch":true,"formula":"campaigns × (endingWeek − 1 + events + companion scenes) and replay checksum equality"}` | `{campaigns: 0, transitions: 0, maxMillis: 0}` | runtime-measured-by-benchmark |
| `G6-accountable-delivery` | performance | P0 | 책임 추적 가능한 납품 · `{"ciChecks":22,"codeRefs":24,"decisionProofFields":14,"unit":"delivery-proof-units"}` | `{"ciChecks":22,"localCiChecks":21,"wasmCiChecks":1,"codeRefs":128,"decisionProofFields":14,"assetRefs":78,"fontRefs":1,"localeRefs":2,"systemAdjudicated":true,"failClosed":true}` | `{ciChecks: 0, codeRefs: 0, decisionProofFields: 0}` | contract-satisfied; runtime-proof-required |

## 투입·증적 원장

| 원장 ID | 단위 | 수량 | 산식 | 범위 |
| --- | --- | ---: | --- | --- |
| `authored-content-units` | content-unit | **369** | 48 weeks + 16 chapters + 47 main events + 24 side scenes + 94 main choices + 72 side choices + 10 activity mini-events + 18 companion scenes + 18 ending variants + 16 milestones + 6 core endings | authored campaign content and closure work |
| `narrative-relationship-units` | narrative-unit | **32** | 3 companions + 6 fate threads + 9 quest stages + 6 locations + 3 legacy profiles + 5 exclusive follow-ups | relationship, memory, discovery and replay depth |
| `exploration-units` | replay-unit | **694928** | 2048 branch vectors + 122880 route inputs + 5,000 campaigns + 565000 transitions | branch enumeration, route variety and deterministic throughput |
| `visual-locale-units` | presentation-unit | **2688** | 107 Goldens + 2 locales × 1187 keys + 128 code refs + 78 asset refs + 1 font refs | visual regression, localization and traceable production assets |
| `verification-units` | proof-unit | **112** | 21 local CI checks + 1 Wasm CI check + 73 Dart test files + 3 render preconditions + 5 render proofs + 14 decision precondition fields | repeatable automated proof and release readiness |

## 선행조건과 증거

### `G1-completeness` · 장편 캠페인 완전성

- 선행조건: `story-contract` · `content-depth` · `scenario-variants` · `quality-score` · `generated-ssot-docs` · `review-manifest`
- 증거: `story/story.jsonl#scenarioCompleteness` · `tool/verify_game.dart#scenario-contract` · `tool/verify_content_depth.dart#content-depth-gate` · `tool/verify_quality_score.dart#quality-score-99` · `test/scenario_completeness_test.dart#scenario-closure`
- 승인 조건: 8개 시나리오 차원과 콘텐츠·분기·locale·Golden 증적이 모두 CI에서 통과한다.
- 사용 원장: `authored-content-units` · `verification-units`

### `G2-agency-replay` · 선택 행위성과 재플레이 공간

- 선행조건: `scenario-variants` · `campaign-benchmark`
- 증거: `tool/verify_scenario_variants.dart#scenario-case-enumerator` · `test/gameplay_metrics_test.dart#route-variety` · `test/purity_integration_test.dart#same-schedule-budget-outcomes`
- 승인 조건: 동일 입력 replay가 재현되고, 최소 2,000 branch trace와 122,880 route input 계약을 만족한다.
- 사용 원장: `exploration-units` · `narrative-relationship-units`

### `G3-narrative-depth` · 관계·기억·계승 서사 깊이

- 선행조건: `story-contract` · `scenario-variants` · `tests-and-goldens`
- 증거: `story/story.jsonl#fateThreads` · `story/story.jsonl#companionQuests` · `test/narrative_ledger_test.dart#deterministic-projection` · `test/ending_matrix_test.dart#all-companion-route-sets`
- 승인 조건: 기억 flag·동료 퀘스트·엔딩·계승 프로필이 같은 SSOT와 replay trace에서 재생성된다.
- 사용 원장: `narrative-relationship-units` · `authored-content-units`

### `G4-presentation` · 시각·locale 품질 증적

- 선행조건: `render-quality-preconditions` · `static-analysis` · `tests-and-goldens`
- 증거: `docs/render-quality-contract.jsonl#preconditions` · `tool/verify_render_quality.dart#render-quality-preconditions` · `test/golden_test.dart#all` · `test/locale_contract_test.dart#ssot-dialogue-contract`
- 승인 조건: Canvas 좌표·입력 역변환·107개 Golden·ko/en locale 계약이 전부 통과한다.
- 사용 원장: `visual-locale-units` · `verification-units`

### `G5-deterministic-throughput` · 결정론적 처리량과 replay

- 선행조건: `campaign-benchmark` · `tests-and-goldens` · `wasm-release-build`
- 증거: `tool/benchmark_game.dart#ssot-campaign-throughput-signatures` · `tool/benchmark_game.dart#companion-scene-replay-checksum` · `build/benchmark-verdict.json#runtime-measurement` · `build/ci-verdict.json#system-approval`
- 승인 조건: 5,000 campaign·565000 transition이 제한 시간 안에 실행되고 companion scene replay checksum까지 일치한다.
- 사용 원장: `exploration-units` · `verification-units`

### `G6-accountable-delivery` · 책임 추적 가능한 납품

- 선행조건: `jsonl-contract` · `quality-score` · `ci-policy` · `generated-ssot-docs` · `review-manifest` · `diff-whitespace`
- 증거: `story/story.jsonl#codeRefs` · `docs/decision-proof-contract.jsonl#preconditionFields` · `tool/verify_decision_proof.dart#decision-proof-preconditions` · `docs/review-manifest.jsonl#entries` · `tool/ci_gate.dart#system-verdict` · `tool/verify_quality_score.dart#quality-score-99` · `tool/trilemma_verdict.dart#closed-loop-receipt` · `test/trilemma_verdict_test.dart#closed-loop-receipt` · `lib/decision_proof.dart#SystemDecisionPolicy` · `lib/decision_receipt.dart#DecisionReceipt`
- 승인 조건: 사람의 승인 추론 없이 source hash·게이트·영수증·replay 증적이 fail-closed로 남는다.
- 사용 원장: `verification-units` · `visual-locale-units`

## CI 증적 산출물

`21`개 CI check가 실행되며 benchmark·개발목표·시스템·트릴레마 verdict를 `build/`에 남긴다. 어느 하나라도 누락되거나 실패하면 전체 승인을 거절한다.
