# 프린스 메이커

독자 세계관 ‘루멘’에서 12주 동안 노아의 방향을 함께 고르는 작은 육성 시뮬레이션입니다. 원작의 캐릭터·문구·화면을 사용하지 않고, **일정 선택 → 수치 변화 → 서사 판정**이라는 장르의 구조만 새 규칙과 시각 언어로 재구성했습니다.

화면은 Flutter 위젯 카드가 아니라 `CustomPaint`/`Canvas`를 기준으로 그립니다. 입력은 얇은 `GestureDetector`가 좌표를 게임 상태 전이로 바꾸고, 상태·도형·텍스트는 한 개의 painter에서 결정론적으로 렌더링합니다.

## 실행

```bash
flutter pub get
flutter run -d chrome
flutter build web --wasm --release
```

## 골든 테스트 증적

`flutter test --update-goldens`로 화면 기준을 갱신하고, 이후 `flutter test`가 픽셀 변화를 차단합니다.

![골든 기준 화면](test/goldens/home.png)

## SSOT와 게임성 지표

스토리와 활동 정의의 단일 원천은 [`story/story.json`](story/story.json)입니다. 화면은 이 데이터의 제목·배경·주인공을 읽고, 활동은 동일한 선언형 레지스트리로 렌더링합니다. 핵심 폐쇄루프는 1주 선택, 스탯/은화 변화, 다음 주 피드백이며 테스트가 그 전이를 고정합니다.

초기 지표: 3개 활동 × 12주 = 36개의 계획 조합, 3개 성장축(지혜·공감·용기), 1회 행동 입력당 1회 상태 전이, 정적 홈 골든 1장. 다음 단계에서 12주 종료 판정과 리플레이 지표를 추가합니다.

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

기준 해시: `c192b2a82569c02c15cf58edd9d7ef22d8477136cb335ea59987c63e23eafca9` (코드·SSOT·테스트·골든·CI 입력의 SHA-256)
