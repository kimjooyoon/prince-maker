# 프린스 메이커

독자 세계관 ‘루멘’에서 12주 동안 노아의 방향을 함께 고르는 작은 육성 시뮬레이션입니다. 원작의 캐릭터·문구·화면을 사용하지 않고, **일정 선택 → 수치 변화 → 서사 판정**이라는 장르의 구조만 새 규칙과 시각 언어로 재구성했습니다.

화면은 Flutter 위젯 카드가 아니라 `CustomPaint`/`Canvas`를 기준으로 그립니다. 입력은 얇은 `GestureDetector`가 좌표를 게임 상태 전이로 바꾸고, 상태·도형·텍스트는 한 개의 painter에서 결정론적으로 렌더링합니다.

## 실행

```bash
flutter pub get
flutter run -d chrome
flutter build web --wasm --release

# 한 번만 설정하면 이후 커밋 때 동일한 검증을 자동 실행합니다.
git config core.hooksPath .githooks
```

## 골든 테스트 증적

`flutter test --update-goldens`로 화면 기준을 갱신하고, 이후 `flutter test`가 픽셀 변화를 차단합니다.

![골든 기준 화면](test/goldens/home.png)
![성격별 상반신 일러스트 페이지](test/goldens/illustration.png)
![12주 엔딩 화면](test/goldens/ending.png)

## SSOT와 게임성 지표

스토리와 활동 정의의 단일 원천은 [`story/story.json`](story/story.json)입니다. 화면은 이 데이터의 제목·배경·주인공·성격별 이름·말투·대사를 읽고, 활동은 동일한 선언형 레지스트리로 렌더링합니다. `assets/noa-sprite-sheet.png`는 독창적인 2등신 노아의 차분·호기심·결의 표정 시트이며, 일러스트 페이지에서 상반신 대화 연출로 사용합니다. 핵심 폐쇄루프는 1주 선택, 스탯/은화 변화, 다음 주 피드백이며 테스트가 그 전이를 고정합니다.

초기 지표: 3개 활동 × 12주 = 36개의 계획 조합, 3개 성장축(지혜·공감·용기), 3개 성격 대화, 3개 골든 화면, 3개 authored 엔딩, 1회 행동 입력당 1회 상태 전이, 12주 종료 판정, versioned save/replay trace입니다.

## 장기 설계 기준

초안 이후 기능은 재활용 가능한 [Lumen Canvas Kit](docs/design-system.md)를 먼저 설계한 뒤 구현합니다. 토큰은 [`design/tokens.json`](design/tokens.json)과 [`lib/design_tokens.dart`](lib/design_tokens.dart)에 분리되어 있으며, 화면은 `stat_panel`, `choice_card`, `portrait_page`, `ending_panel` 조합으로 확장합니다.

게임 요소 분석과 정량 게이트는 [`docs/game-completeness.md`](docs/game-completeness.md), CI 강제 검사는 [`tool/verify_game.dart`](tool/verify_game.dart)에 있습니다. SSOT 검사 → 상태/Golden 테스트 → Wasm 빌드 순서가 모두 통과해야 저장소 변경이 검증됩니다.

SSOT에서 생성된 문서는 [`docs/story-ssot.md`](docs/story-ssot.md)이며, 문서 헤더의 SHA-256과 `source-ref`를 CI가 검사합니다. 핵심 변경 파일은 [`docs/review-manifest.json`](docs/review-manifest.json)에 해시와 ref가 있어, 파일을 다시 읽고 검토하지 않은 변경은 통합되지 않습니다.

런타임 구조는 [architecture.md](docs/architecture.md)에 정의된 ECS/DOD + EDA + Hexagonal 경계를 따릅니다. Canvas는 어댑터이고, `GameSession`은 애플리케이션 포트이며, `GameWorld`는 결정론적 이벤트 시스템입니다.

## 렌더러 검토: Flutter Canvas 우선

| 선택지 | 장점 | 현재 판정 |
| --- | --- | --- |
| Flutter `CustomPaint` | 웹 Wasm, Flutter 골든 테스트, 텍스트·입력·접근성 조합이 한 저장소에 있음 | 채택 |
| Rust Bevy UI | ECS 기반 게임 루프와 대규모 2D/3D 렌더링 확장성 | 보류 |

Bevy의 UI는 Flexbox/CSS Grid 모델과 ECS에 강하지만, 공식 표준 위젯 예제가 아직 실험적이라고 명시되어 있고 이 프로젝트의 핵심 증적(Flutter 골든·저비용 웹 배포)을 다시 구성해야 합니다. 프레임 시간이나 콘텐츠 규모가 병목으로 확인될 때만 Bevy를 별도 실험 브랜치에서 비교합니다.

## 근거와 추적성

- [Flutter Web](https://docs.flutter.dev/platform-integration/web), [Flutter Wasm](https://docs.flutter.dev/platform-integration/web/wasm), [Web renderers](https://docs.flutter.dev/platform-integration/web/renderers), [CustomPaint](https://api.flutter.dev/flutter/widgets/CustomPaint-class.html)
- [Bevy standard widgets](https://bevy.org/examples/ui-user-interface/standard-widgets/), [Bevy UI API](https://docs.rs/bevy/latest/bevy/ui/index.html)
- 장르 참고: [Princess Maker 1 mechanics overview](https://princessmaker.fandom.com/wiki/Princess_Maker_1), [comparative study](https://uu.diva-portal.org/smash/get/diva2:1966128/FULLTEXT01.pdf)

기준 해시: `38376acf84db0433ebddddafe6746af51316ad836b2aae7e6d5ac9686e1d4aa4` (코드·SSOT·테스트·골든·CI 입력의 SHA-256)
