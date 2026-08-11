# Lumen Canvas design decision log

이 문서는 `story/story.jsonl#designSystemContract`의 사람이 읽는 근거다. 런타임 토큰은 [`lib/design_tokens.dart`](../lib/design_tokens.dart), Canvas 변형은 [`lib/canvas_ui_kit.dart`](../lib/canvas_ui_kit.dart), canonical token source는 [`design/tokens.jsonl`](../design/tokens.jsonl)에서 관리한다.

## 2026-08-12 · Canvas language v1

- 선택: `ink / twilight`를 방향과 구조, `sun`을 다음 행동, `teal / mint`를 회복과 성공, `warning / coral`을 주의와 거절에 배정한다.
  - 근거: 홈 HUD·성격 상반신·동행 기록·대화·Star Cellar가 같은 정보 위계를 공유하면서도, 진행 가능·주의·실패를 색 하나만으로 오인하지 않게 한다.
- 선택: `panel / card / button / hud / dialogue / status / locked`를 이름 있는 Canvas variant로 만든다.
  - 재사용 규칙: 새 화면은 `CanvasUiKit.variantPanel`을 먼저 선택하고, 하드코딩한 radius/fill/stroke는 추가하지 않는다. 상태는 `idle → selected → disabled/warning/success/danger`로만 투영한다.
- 선택: `warning`을 `danger`와 분리한다.
  - 근거: 피로·회복 안내는 입력 거절이나 규칙 오류가 아니므로, 플레이어에게 조정 가능한 정보로 읽혀야 한다.
- 선택: Canvas 위에 투명 Flutter `Semantics` hit target을 겹친다.
  - 재사용 규칙: 최소 44px, 화면에 보이는 Canvas 좌표와 같은 logical rect, label은 `story/locales/ko.jsonl`·`en.jsonl`의 key를 사용한다. 게임 규칙과 painter 상태는 변경하지 않는다.
- 선택: 760×700 logical canvas와 8/16/24 spacing rhythm을 유지한다.
  - 근거: 기존 Golden/replay fingerprint와 좌표 계약을 보호하면서 작은 화면에서는 `CanvasViewport`가 균일하게 축소한다.
- 선택: design-system Golden은 텍스트가 아닌 기하 증적으로 두고, ko/en 카피는 locale contract와 semantic test로 검증한다.
  - 근거: macOS/Linux Canvas 텍스트 래스터 차이가 새 evidence를 오염시키지 않으면서도 variant geometry와 상태 색 계약을 결정론적으로 비교하기 위해서다.
- 선택: OS 간 Canvas 안티앨리어싱에 대한 비정확 Golden 허용 상한을 4%로 고정한다.
  - 근거: Actions에서 관측된 최대 3.63% 차이만 수용하며, exact/경계/초과/비유한값 판정은 별도 테스트로 fail-closed 유지한다.

## 저작권 회피 원칙

장르의 추상적인 감각(육성 일정, 어두운 방의 회피, 별빛·기록 분위기)만 참고한다. 특정 작품의 캐릭터, 방 배치, 아이템 이름·형태, UI 구조, 로고, 대사, 그래픽 실루엣을 복제하거나 트레이싱하지 않는다. Lumen은 독자 캐릭터 시트·독자 장소 모티프·독자 규칙·독자 카피를 SSOT에 둔다.

## 검증 연결

- `test/goldens/design-system-ko.png` / `design-system-en.png`: named variant geometry·locale별 accent·warning/locked 상태의 기준; 카피는 `test/design_system_golden_test.dart` locale assertions로 고정한다.
- `test/goldens/star-cellar.png` / `star-cellar-en.png`: 기존 결정론적 미니게임의 화면 언어와 i18n 기준.
- `test/canvas_render_perf_test.dart`: 홈·사건·엔딩·기록·관계·동행 representative Canvas의 평균 paint budget.
- `test/canvas_scene_fingerprint_test.dart`: 상태가 바뀔 때만 repaint key가 달라지는지 확인.
