<!-- generated: tool/generate_development_goals.dart -->
<!-- source-sha256: c418c8c1d83368829d97fe41a385e6cda2a9cf98ba2ae5c3335d7cd2277431f7|46effa15c0a274540db07bfad7ad40e934cfb2cf30ca26d6cf271421329e4377|74ba654bc5102848bcb4fd6100254f01819e140415f7ae32308aa46254179626|356e5e1740274e131b3c51f5517342374c5060431e39772f611b0be3ae0169d1 -->
<!-- source-ref: story/story.jsonl#root -->

# 프린스 메이커 · 정량 개발목표 원장

이 문서는 SSOT·트릴레마·렌더 계약에서 개발 목표, 현재 계약값, gap, 투입 단위와 검증 증거를 결정론적으로 생성한다.

## 판정 규칙

- 판정 주체: **Lumen Development Goal Gate** · 사람 승인 필요: `false` · 실패 모드: `fail-closed`
- gap 산식: `max(target - current, 0)` · 정적 계약 충족과 실제 실행 증명은 분리한다.

## 개발 목표

| ID | 축 | 우선순위 | 목표 | 현재 계약값 | gap | 상태 |
| --- | --- | --- | --- | --- | ---: | --- |
| `G1-completeness` | completeness | P0 | 장편 캠페인 완전성 · `{"value":0.95,"unit":"gate-score","display":"≥95%"}` | `{"value":1.0,"unit":"gate-score","formula":"8/8 scenario dimensions declared with target/current/evidence"}` | `0` | contract-satisfied; runtime-proof-required |
| `G2-agency-replay` | purity | P0 | 선택 행위성과 재플레이 공간 · `{"scenarioCases":2000,"routeInputs":122880,"unit":"deterministic-replay-cases"}` | `{"scenarioCases":2048,"routeInputs":122880,"branchVectors":2048,"formula":"2^11 unconditional authored branch vectors × 5 activity policies × 3 personality routes × 4 legacy contexts = 122,880 route inputs; the CI enumerator replays all 2,048 branch vectors and requires at least 2,000 distinct deterministic scenario traces."}` | `{scenarioCases: 0, routeInputs: 0}` | contract-satisfied; runtime-proof-required |
| `G3-narrative-depth` | completeness | P1 | 관계·기억·계승 서사 깊이 · `{"fateThreads":6,"companionQuestStages":9,"endings":6,"legacyProfiles":3,"unit":"authored-narrative-units"}` | `{"fateThreads":6,"companionQuestStages":9,"endings":6,"legacyProfiles":3}` | `{fateThreads: 0, companionQuestStages: 0, endings: 0, legacyProfiles: 0}` | contract-satisfied; runtime-proof-required |
| `G4-presentation` | completeness | P1 | 시각·locale 품질 증적 · `{"goldens":30,"locales":2,"keysPerLocale":505,"renderPreconditions":3,"renderProofs":3,"unit":"presentation-proof-units"}` | `{"goldens":63,"locales":2,"keysPerLocale":505,"renderPreconditions":3,"renderProofs":3}` | `{goldens: 0, locales: 0, keysPerLocale: 0, renderPreconditions: 0, renderProofs: 0}` | contract-satisfied; runtime-proof-required |
| `G5-deterministic-throughput` | performance | P0 | 결정론적 처리량과 replay · `{"campaigns":5000,"transitions":475000,"maxMillis":24000,"unit":"benchmark-contract"}` | `{"campaigns":5000,"transitions":475000,"maxMillis":24000,"checksumReplayMustMatch":true,"formula":"campaigns × (endingWeek − 1 + events) and replay checksum equality"}` | `{campaigns: 0, transitions: 0, maxMillis: 0}` | runtime-measured-by-benchmark |
| `G6-accountable-delivery` | performance | P0 | 책임 추적 가능한 납품 · `{"ciChecks":15,"codeRefs":24,"decisionProofFields":14,"unit":"delivery-proof-units"}` | `{"ciChecks":15,"codeRefs":37,"decisionProofFields":14,"assetRefs":4,"fontRefs":1,"localeRefs":2,"systemAdjudicated":true,"failClosed":true}` | `{ciChecks: 0, codeRefs: 0, decisionProofFields: 0}` | contract-satisfied; runtime-proof-required |

## 투입·증적 원장

| 원장 ID | 단위 | 수량 | 산식 | 범위 |
| --- | --- | ---: | --- | --- |
| `authored-content-units` | content-unit | **227** | 48 weeks + 16 chapters + 47 events + 94 choices + 16 milestones + 6 endings | authored campaign content and closure work |
| `narrative-relationship-units` | narrative-unit | **30** | 3 companions + 6 fate threads + 9 quest stages + 4 locations + 3 legacy profiles + 5 exclusive follow-ups | relationship, memory, discovery and replay depth |
| `exploration-units` | replay-unit | **604928** | 2048 branch vectors + 122880 route inputs + 5,000 campaigns + 475000 transitions | branch enumeration, route variety and deterministic throughput |
| `visual-locale-units` | presentation-unit | **1115** | 63 Goldens + 2 locales × 505 keys + 37 code refs + 4 asset refs + 1 font refs | visual regression, localization and traceable production assets |
| `verification-units` | proof-unit | **63** | 15 CI checks + 28 Dart test files + 3 render preconditions + 3 render proofs + 14 decision precondition fields | repeatable automated proof and release readiness |

## 선행조건과 증거

### `G1-completeness` · 장편 캠페인 완전성

- 선행조건: `story-contract` · `scenario-variants` · `generated-ssot-docs` · `review-manifest`
- 증거: `story/story.jsonl#scenarioCompleteness` · `tool/verify_game.dart#scenario-contract` · `test/scenario_completeness_test.dart#scenario-closure`
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
- 승인 조건: Canvas 좌표·입력 역변환·63개 Golden·ko/en locale 계약이 전부 통과한다.
- 사용 원장: `visual-locale-units` · `verification-units`

### `G5-deterministic-throughput` · 결정론적 처리량과 replay

- 선행조건: `campaign-benchmark` · `tests-and-goldens` · `wasm-release-build`
- 증거: `tool/benchmark_game.dart#ssot-campaign-throughput-signatures` · `build/benchmark-verdict.json#runtime-measurement` · `build/ci-verdict.json#system-approval`
- 승인 조건: 5,000 campaign·475,000 transition이 제한 시간 안에 실행되고 checksum/replayChecksum이 일치한다.
- 사용 원장: `exploration-units` · `verification-units`

### `G6-accountable-delivery` · 책임 추적 가능한 납품

- 선행조건: `ci-policy` · `generated-ssot-docs` · `review-manifest` · `diff-whitespace`
- 증거: `story/story.jsonl#codeRefs` · `docs/decision-proof-contract.jsonl#preconditionFields` · `tool/verify_decision_proof.dart#decision-proof-preconditions` · `docs/review-manifest.jsonl#entries` · `tool/ci_gate.dart#system-verdict` · `lib/decision_proof.dart#SystemDecisionPolicy` · `lib/decision_receipt.dart#DecisionReceipt`
- 승인 조건: 사람의 승인 추론 없이 source hash·게이트·영수증·replay 증적이 fail-closed로 남는다.
- 사용 원장: `verification-units` · `visual-locale-units`

## CI 증적 산출물

`14`개 CI check가 실행되며 benchmark·개발목표·시스템·트릴레마 verdict를 `build/`에 남긴다. 어느 하나라도 누락되거나 실패하면 전체 승인을 거절한다.
