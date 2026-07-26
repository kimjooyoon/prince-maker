# 프린스 메이커

독자 세계관 ‘루멘’에서 12주 동안 노아의 방향을 함께 고르는 작은 육성 시뮬레이션입니다. 원작의 캐릭터·문구·화면을 사용하지 않고, **일정 선택 → 수치 변화 → 서사 판정**이라는 장르의 구조만 새 규칙과 시각 언어로 재구성했습니다.

화면은 Flutter 위젯 카드가 아니라 `CustomPaint`/`Canvas`를 기준으로 그립니다. 입력은 얇은 `GestureDetector`가 좌표를 게임 상태 전이로 바꾸고, 상태·도형·텍스트는 한 개의 painter에서 결정론적으로 렌더링합니다.

한글 Golden 재현성을 위해 [Noto Sans KR](https://github.com/google/fonts/tree/main/ofl/notosanskr)을 OFL 폰트 자산으로 번들합니다. 캐릭터와 UI 일러스트는 이 폰트와 독자 PNG 시트만 사용하며 원작의 이미지·문구·캐릭터를 복제하지 않습니다.

## 실행

```bash
flutter pub get
flutter run -d chrome
flutter build web --wasm --release

# 한 번만 설정하면 이후 커밋 때 동일한 검증을 자동 실행합니다.
git config core.hooksPath .githooks
```

## 골든 테스트 증적

`flutter test --update-goldens`로 화면 기준을 갱신하고, 이후 `flutter test`가 픽셀 변화를 차단합니다. OS별 Canvas 글꼴 안티앨리어싱 차이는 2.0% 이하의 bounded tolerance만 허용하며, 그 이상은 실패합니다.

![골든 기준 화면](test/goldens/home.png)
![계절 목표가 보이는 계획 화면](test/goldens/milestone.png)
![사건 선택 Golden](test/goldens/event.png)
![성격별 상반신 일러스트 페이지](test/goldens/illustration.png)
![12주 엔딩 화면](test/goldens/ending.png)
![replay 기록 보관소 화면](test/goldens/save.png)
![새 캠페인 재시작 화면](test/goldens/restart.png)
![SSOT에서 직접 렌더링한 canonical 홈](test/goldens/canonical-home.png)
![SSOT 4주차 온실 사건](test/goldens/canonical-event.png)
![엔딩 도감이 보이는 replay 보관소](test/goldens/collection.png)
![실제 SSOT 12주 경로의 canonical 엔딩](test/goldens/canonical-ending.png)
![사건 선택 결과 피드백 배너](test/goldens/feedback.png)
![관계 긴장 선택 결과 피드백](test/goldens/relationship-tension.png)
![English locale 성격 대화](test/goldens/english-illustration.png)
![English locale 사건 선택](test/goldens/english-event.png)
![English locale 엔딩·동료 에필로그](test/goldens/english-ending.png)

## SSOT와 게임성 지표

스토리와 활동 정의의 단일 원천은 [`story/story.json`](story/story.json)입니다. 화면은 이 데이터의 제목·배경·주인공·성격별 이름·말투·대사를 읽고, 활동은 동일한 선언형 레지스트리로 렌더링합니다. `assets/noa-sprite-sheet.png`는 독창적인 2등신 노아의 차분·호기심·결의 표정 시트이며, `assets/lumen-personality-sheet.png`는 고요·다정·용감 성격의 3프레임 상반신 시트입니다. 두 PNG는 SSOT의 `assetRefs`와 각 personality의 `portraitAsset`/`portraitFrame`으로 연결되어 Canvas 일러스트 페이지에서 표시됩니다. 핵심 폐쇄루프는 1주 선택, 스탯/은화 변화, 다음 주 피드백이며 테스트가 그 전이를 고정합니다.

캐릭터의 독자 조형 규칙과 자산 provenance는 [`docs/art-provenance.md`](docs/art-provenance.md)에 기록하고, SSOT verifier가 PNG 매핑·성격별 색상·모티프·실루엣 필드를 강제합니다.

### 성격 유형 캐릭터 시트

![루멘 성격 유형 3종 캐릭터 시트](assets/lumen-personality-sheet.png)

| SSOT id | 유형 | 디자인 연결 |
| --- | --- | --- |
| `quiet` | 고요한 관찰자 | 인디고·라벤더 / 달 모티프 / frame 0 |
| `kind` | 다정한 연결자 | 틸·크림 / 꽃 모티프 / frame 1 |
| `bold` | 용감한 개척자 | 코랄·황토 / 나침반 모티프 / frame 2 |

현재 지표: 5개 활동 × 12주 = 60개의 계획 조합, 5개 SSOT 일정 정책 실험에서 distinct ending/signature 3개 이상, 3개 성장축(지혜·공감·용기), 성격별 재능 보너스 3개와 선택 카드 내 가시화, 3개 성격 대화, 3명 동료 유대도·rival bond·에필로그, 4개 계절 목표·보상, 8개 고정 사건(각 2선택, 조건부 잠금 포함), 6개 엔딩·16개 사건 선택의 22/22 도달성 계약 테스트, 한국어 fixture 8개·English locale 3개·canonical SSOT 홈·4주차 사건·canonical SSOT 12주 엔딩·엔딩 도감·사건 피드백·관계 긴장 피드백의 16개 골든 화면, `story/locales/ko.json`·`en.json` 키 기반 대사, 모든 SSOT `*Key`와 엔딩 UI 93키의 locale 계약 테스트, 성격 화면 언어 토글, 세 성격 숙련 엔딩 campaign 3종, 목표·유대에 따른 결정론적 1–3성 루멘 기록 등급, 재시작 후에도 누적되는 엔딩 도감, 피로 기반 성장 페널티, 사건 대사 replay, 행동·사건 직후 자동 생성되는 최근 기록 보관소, WASM `localStorage` 새로고침 복원(저장 당시 화면 포함), 목표·유대 포함 `lumen-save-v6` trace, 12주 이후 추가 입력을 차단하는 terminal 상태 불변식입니다.

대사의 확장 단위는 `key → locale catalog → Canvas`이며, 새로운 언어는 게임 규칙을 건드리지 않고 `story/locales/<locale>.json`과 Golden만 추가합니다. 시각 방향은 기존 작품을 모사하지 않는 독자적 **황혼 운명 기록** 무드(`twilight / mist / sun / paper`)로 확장합니다.

## 장기 설계 기준

초안 이후 기능은 재활용 가능한 [Lumen Canvas Kit](docs/design-system.md)를 먼저 설계한 뒤 구현합니다. 토큰은 [`design/tokens.json`](design/tokens.json)과 [`lib/design_tokens.dart`](lib/design_tokens.dart)에 분리되어 있으며, 화면은 `stat_panel`, `choice_card`, `portrait_page`, `ending_panel` 조합으로 확장합니다.

게임 요소 분석과 정량 게이트는 [`docs/game-completeness.md`](docs/game-completeness.md), 시나리오 표본은 [`docs/scenario-completeness.md`](docs/scenario-completeness.md), 트릴레마 폐쇄루프는 [`docs/trilemma.md`](docs/trilemma.md), CI 강제 검사는 [`tool/verify_game.dart`](tool/verify_game.dart)와 [`tool/benchmark_game.dart`](tool/benchmark_game.dart)에 있습니다. 게이트는 완전성·순수성·성능을 함께 확인하며, 완전성 점수가 95% 미만이거나 실제 SSOT campaign benchmark가 실패하면 변경을 거부합니다. 동일한 일정 예산으로 지혜·공감 경로가 서로 다른 authored 엔딩과 유대를 만드는 순수성 회귀도 고정합니다. SSOT 검사 → 해시 매니페스트 → 정적 분석 → 상태/Golden 테스트 → 실제 SSOT campaign benchmark → Wasm 빌드 순서가 모두 통과해야 저장소 변경이 검증됩니다.

SSOT에서 생성된 문서는 [`docs/story-ssot.md`](docs/story-ssot.md)와 [`docs/ssot-metrics.md`](docs/ssot-metrics.md)이며, 문서 헤더의 SHA-256과 `source-ref`를 CI가 검사합니다. 성능 benchmark는 `story/story.json`을 실제 `GameSession`에 주입해 8개 사건을 포함한 같은 5,000 campaign workload를 재실행하고, checksum·replayChecksum·3개 이상 결과 signature까지 일치해야 통과합니다. 핵심 변경 파일은 [`docs/review-manifest.json`](docs/review-manifest.json)에 해시와 ref가 있어, 파일을 다시 읽고 검토하지 않은 변경은 통합되지 않습니다.

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

리뷰 매니페스트의 파일별 SHA-256은 [`docs/review-manifest.json`](docs/review-manifest.json)을 단일 기준으로 사용합니다.
