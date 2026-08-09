<!-- generated: tool/generate_engine_decision.dart -->
<!-- ssot-sha256: 3c8dc1cfec3736ae1227bd04faf89c5d70493c8081313bd101d4da3f7a81c8eb -->
<!-- source-ref: story/story.jsonl#engineDecision -->

# 렌더러 결정 계약

선택: **`flutter-canvas-wasm`** · 규칙: `select the maximum weighted architectural-fit score`

점수는 측정된 런타임 성능이 아니라, 이 게임의 Canvas·Golden·WASM·콘텐츠 루프에 대한 정규화된 아키텍처 적합도다. 실제 성능은 [`benchmark_game.dart`](../tool/benchmark_game.dart)가 판정한다.

| 기준 | 가중치 | 판정 질문 |
| --- | ---: | --- |
| `golden-determinism` | 0.3 | Can the same state render through the existing Golden contract? |
| `wasm-public-hosting` | 0.25 | Can the public repository ship a low-cost WASM build? |
| `content-iteration` | 0.2 | Can SSOT, locale and Canvas content iterate in one Dart loop? |
| `ui-2d-composition` | 0.15 | Does the renderer fit text-rich 2D scenes and reusable UI primitives? |
| `native-throughput` | 0.1 | Does the option leave headroom for future native real-time work? |

| 선택지 | 적합도 | 결정 상태 |
| --- | ---: | --- |
| `flutter-canvas-wasm` | 0.9525 | selected |
| `bevy-wgpu-wasm` | 0.7325 | recorded alternative |
| `bevy-native` | 0.6185 | recorded alternative |

## 증거

### `flutter-canvas-wasm`
- [CustomPaint provides the Canvas paint surface.](https://docs.flutter.dev/ui/widgets/painting)
- [Flutter documents --wasm web builds.](https://docs.flutter.dev/platform-integration/web/building)
- [The local Golden suite is the active renderer contract.](../test/golden_test.dart#all)
### `bevy-wgpu-wasm`
- [Bevy provides an ECS-first runtime.](https://bevy.org/learn/quick-start/getting-started/ecs/)
- [Bevy publishes web examples compiled to WASM.](https://bevy.org/learn/)
### `bevy-native`
- [Bevy UI is ECS-driven and aimed at engine applications.](https://bevy.org/news/introducing-bevy/)

## 재검토 조건

- Flutter Canvas remains the primary renderer until a new option beats the current score and passes the same Golden/WASM gates.
- Bevy remains a recorded alternative; its ECS strengths do not replace the current text-rich Canvas content loop.
- No engine score is accepted as runtime benchmark evidence; benchmark_game.dart remains the performance authority.
