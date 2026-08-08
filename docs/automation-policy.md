# 시스템 승인·CI 운영 정책

## 결정 권한

이 저장소에서 코드 품질과 게임 규칙의 통합 가능 여부를 판단하는 주체는 사람의 체크 표시가 아니라 `tool/ci_gate.dart`의 결정론적 게이트다. 모든 검사가 통과하면 다음 판정을 남긴다.

```text
SYSTEM_APPROVAL: APPROVE
```

하나라도 실패하면 즉시 중단하고 `SYSTEM_APPROVAL: REJECT`를 남긴다. 결과 증적은 무시되지 않도록 `build/ci-verdict.json`과 완전성·순수성·성능 축별 판정인 `build/trilemma-verdict.json`에 기록한다. 두 파일은 빌드 산출물이므로 Git에 커밋하지 않는다.

## 동일한 검증 경로

로컬 커밋과 Pull Request는 같은 순서를 사용한다.

```text
pre-commit / pull_request
        ↓
tool/ci_gate.dart
        ↓
CI 정책 → SSOT/완전성 → benchmark → 생성물 → 해시 매니페스트
        ↓
정적 분석 → Flutter 테스트/Golden → (CI에서) Wasm release build
        ↓
SYSTEM_APPROVAL: APPROVE | REJECT
```

`trilemma-verdict.json`은 완전성에 SSOT·분기·생성물·Golden·정적 분석, 순수성에 분기 다양성·replay·benchmark, 성능에 benchmark·테스트·CI Wasm build를 각각 필수 게이트로 묶는다. 한 축이라도 누락되거나 실패하면 전체 시스템 판정도 거절된다.

`.githooks/pre-commit`은 `--local`, GitHub Actions의 `system-approval` job은 `--ci`를 호출한다. 두 모드의 차이는 CI에서만 Wasm release build를 추가하는 것뿐이다. 실패를 무시하는 `continue-on-error`와 `|| true`는 정책 위반이다.

## 저장소 설정

GitHub 저장소의 기본 브랜치 ruleset에는 다음 상태 검사를 required status check로 등록한다.

- `system-approval / system-approval`

브랜치가 최신 상태가 아니면 다시 검사하도록 하고, 이 검사가 성공하지 않은 Pull Request는 병합할 수 없게 한다. 사람의 승인 여부는 게임 규칙·Golden·benchmark의 정합성을 대신하지 않는다. 보안상 필요한 관리자 예외 권한은 조직의 GitHub 설정으로 별도 관리한다.

## 게임 독창성 변경 규칙

외부 게임은 캐릭터·문구·아트가 아니라 공개된 규칙 단위를 비교하는 참고 자료로만 기록한다. 새 요소는 [`originality-contract.json`](originality-contract.json)에 규칙, 외부 원리, 루멘에서의 차이, 실제 코드·테스트 증거를 함께 남겨야 한다.
