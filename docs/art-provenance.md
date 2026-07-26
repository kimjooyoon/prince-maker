# 루멘 캐릭터 아트 provenance

이 프로젝트의 캐릭터는 특정 작품의 캐릭터·의상·로고·대사를 재현하지 않는 독자 설계로 고정한다. “일본풍”은 장르적 조형 언어(2등신 비율, 큰 표정, 색면 중심 의상, 작은 모티프)를 뜻하며 특정 작가나 시리즈의 화풍 모사는 목표로 삼지 않는다.

## 설계 계약

| 자산 | 독자 조형 규칙 | SSOT 연결 |
| --- | --- | --- |
| Noa | 2등신, 남색 단발, 초승달 가방, 별 장식, 차분·호기심·결의 3표정 | `story.json#assetRefs` + hero runtime sheet |
| 고요한 관찰자 | 인디고·라벤더, 달 모티프, 짧은 단발 | `personalities[0].portraitAsset` / `portraitFrame` |
| 다정한 연결자 | 틸·크림, 꽃 모티프, 긴 땋은 머리 | `personalities[1].portraitAsset` / `portraitFrame` |
| 용감한 개척자 | 코랄·황토, 나침반 모티프, 짧은 곱슬머리 | `personalities[2].portraitAsset` / `portraitFrame` |

## 추적성과 검증

- 생성된 PNG와 chroma-key 원본은 [`story/story.json`](../story/story.json)의 `assetRefs`에 SHA-256으로 선언한다.
- 각 성격의 `portraitAsset`과 `portraitFrame`은 Canvas 일러스트 페이지에서 읽고, `test/asset_test.dart`가 PNG 로딩을 검증한다.
- `tool/verify_game.dart`는 주인공·성격 PNG 선언과 성격별 `palette`·`motif`·`silhouette` 설계 필드를 강제한다.
- 원작의 화면 캡처, 캐릭터명, 대사, 로고, 복제된 실루엣은 저장소에 포함하지 않는다.

이 문서는 법률 자문이 아니며, 배포 전에는 실제 상표·저작권 검색과 전문 검토를 별도로 수행한다.
