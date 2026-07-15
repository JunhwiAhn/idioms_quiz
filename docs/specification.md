# DELE Voca Dojo 사양서

최종 갱신일: 2026-05-08

## 1. 제품 목표

DELE Voca Dojo는 DELE 스타일의 스페인어 어휘 학습을 게임처럼 반복할 수 있게 만드는 앱이다. 기존 사자성어 앱의 구조를 최대한 살리되, 학습 콘텐츠와 화면 문구, 데이터 구조를 스페인어 단어 학습에 맞게 전환한다.

핵심 목표:

- 짧게 반복 가능한 학습 세션
- 스테이지와 별점 기반 진행도
- 50문제 마라톤을 통한 기록 경쟁
- 단어장 수집/복습
- 오늘의 단어 습관 형성
- 아이템 보상
- 밝고 친근한 스페인어 학습 게임 분위기

## 2. 지원 언어

첫 실행 시 사용자는 학습/표시 언어를 선택한다.

- 한국어
- 영어
- 일본어

선택 언어가 적용되는 영역:

- 홈 메뉴 문구
- 퀴즈 질문 문구
- 정답 선택지의 번역
- 오답노트 문구
- 예문 번역
- 단어장 의미 표시

언어 설정은 `SharedPreferences`에 저장한다.

저장 키:

```text
study_language
```

관련 파일:

```text
lib/data/app_text.dart
lib/data/score_service.dart
lib/models/idiom.dart
```

## 3. 데이터 모델

현재 모델 파일:

```text
lib/models/idiom.dart
```

현재 클래스명은 `Idiom`이다. 이는 기존 코드 호환성 때문에 유지한 이름이며, 추후 `SpanishEntry` 또는 `VocabularyEntry`로 변경하는 것이 좋다.

데이터 파일:

```text
assets/data/dele_a1_a2_b1_problem_bank.enriched.json
```

현재 데이터 개수:

```text
1,257 entries (A1 489 / A2 466 / B1 302)
```

필드 사양:

| 필드 | 타입 | 설명 |
|---|---|---|
| `spanish` | string | 스페인어 단어 또는 표현 |
| `pronunciation` | string | 발음/표시 보조 문자열 |
| `meanings` | object | `ko`, `en`, `ja` 번역 |
| `example` | string | 스페인어 예문 |
| `exampleMeanings` | object | 예문 번역 `ko`, `en`, `ja` |
| `blankedExample` | string | 빈칸 문제용 예문 |
| `answer` | string | 빈칸에 들어갈 정답 |
| `level` | string | DELE 레벨, 예: `A1`, `A2`, `B1`, `B2`, `C1` |
| `partOfSpeech` | string | 품사, 예: `noun`, `verb`, `adjective`, `expression` |
| `wrongChoices` | array | 현재는 호환성 필드. 선택지는 주로 풀에서 자동 생성 |
| `difficulty` | number | 스테이지 정렬용 난이도 |

예시:

```json
{
  "spanish": "casa",
  "pronunciation": "casa",
  "meanings": {
    "ko": "집",
    "en": "house",
    "ja": "家"
  },
  "example": "La palabra casa aparece en el examen.",
  "exampleMeanings": {
    "ko": "casa라는 단어가 시험에 나온다.",
    "en": "The word casa appears on the exam.",
    "ja": "casaという単語が試験に出ます。"
  },
  "blankedExample": "La palabra ____ aparece en el examen.",
  "answer": "casa",
  "level": "A1",
  "partOfSpeech": "noun",
  "wrongChoices": [],
  "difficulty": 1
}
```

데이터 품질 메모:

- 현재 데이터는 구조 검증과 플레이 테스트를 위한 시드 데이터다.
- `"관련 표현 1"` 같은 임시 선택지가 나오지 않도록 자동 확장 흔적은 제거했다.
- 출시 전 실제 DELE 단어 목록 기준으로 재검수해야 한다.

## 4. 퀴즈 모드

관련 파일:

```text
lib/data/quiz_session.dart
lib/screens/quiz_screen.dart
```

현재 문제 유형:

| 모드 | 문제 | 선택지 |
|---|---|---|
| `translationLookup` | 스페인어 단어 제시 | 선택 언어의 뜻 |
| `wordLookup` | 선택 언어의 뜻 제시 | 스페인어 단어 |
| `sentenceBlank` | 빈칸이 있는 스페인어 예문 제시 | 빈칸에 들어갈 스페인어 단어 |

정답 공개 시 표시:

- 정답 강조
- 스페인어 예문
- 예문 안에서 해당 단어 밑줄 강조
- 선택 언어의 예문 번역
- DELE 레벨

## 5. 스테이지 모드

관련 파일:

```text
lib/data/stage_plan.dart
lib/screens/stage_screen.dart
lib/screens/round_screen.dart
```

구성:

- 5개 스테이지
- 스테이지당 8라운드
- 라운드당 10문제
- 총 400문제 분량의 스테이지 플랜

스테이지:

- `Etapa 1 / A1`
- `Etapa 2 / A2`
- `Etapa 3 / B1`
- `Etapa 4 / B2`
- `Etapa 5 / DELE`

라운드 클리어 기준:

```text
kMinCorrectToClear = 4
```

별점:

- 10/10이면 5성
- 오답 수에 따라 별점 감소
- 4문제 미만 정답이면 0성

해금:

- 첫 스테이지는 기본 해금
- 다음 스테이지는 이전 스테이지 별점 절반 이상이면 해금
- 다음 라운드는 이전 라운드에서 1성 이상이면 해금

## 6. 마라톤 모드

관련 파일:

```text
lib/screens/home_screen.dart
lib/data/quiz_session.dart
lib/screens/result_screen.dart
```

동작:

- 무작위 50문제 연속 풀이
- 최근 기록 저장
- 최고 기록 저장
- 정답 단어는 단어장 해금에 반영
- 추정 퍼센타일 표시

퍼센타일은 실제 통계가 아니라 게임화된 추정 라벨이다.

## 7. 단어장

관련 파일:

```text
lib/screens/collection_screen.dart
```

기능:

- 전체 단어 표시
- 전체/해금/잠김 필터
- 스페인어, 번역, DELE 레벨 검색
- 단어 탭 시 중앙 모달 표시
- 모달은 긴 세로 공간을 사용하며 스크롤 가능

상세 모달 표시 항목:

- 스페인어 단어
- 발음/표시 보조
- 선택 언어의 뜻
- DELE 레벨
- 품사
- 예문
- 해금 상태

해금 기준:

```text
kMasteryThreshold = 1
```

## 8. 오답노트 모드

관련 파일:

```text
lib/screens/wrong_note_screen.dart
lib/data/score_service.dart
```

현재 규칙:

- 퀴즈에서 틀린 단어를 `SharedPreferences`에 저장한다.
- 저장된 오답 단어는 오답노트 화면에서 목록으로 표시한다.
- 오답노트에서 다시 퀴즈를 풀 수 있다.
- 다시 맞힌 단어는 오답노트에서 자동으로 제거한다.
- 오답이 없으면 빈 상태 안내를 표시한다.

저장 키:

```text
wrong_idioms
```

## 9. 진행도와 저장

관련 파일:

```text
lib/data/score_service.dart
```

저장 항목:

- 총 포인트
- 총 응답 수
- 총 정답 수
- 최고 연속 정답
- 아이템 개수
- 해금된 단어
- 단어별 정답 횟수
- 마라톤 최고 기록
- 마라톤 최근 기록
- 라운드별 별점
- 선택 언어

## 10. 랭크와 레벨

랭크 파일:

```text
lib/data/rank.dart
```

현재 랭크:

- Novato
- Aprendiz
- Explorador
- Estudiante
- Hablante
- Viajero
- Conversador
- Intérprete
- Lingüista
- Embajador
- Maestro
- Sabio
- Gran Maestro

레벨 티어 파일:

```text
lib/data/level_tier.dart
```

현재 레벨 라벨:

- A1 Warm-up
- A1 Ready
- A2 Builder
- B1 Runner
- B2 Speaker
- DELE Master

## 11. 아이템

내부 enum:

```text
HintKind
```

표시 이름:

- `50:50`: 오답 선택지 2개 제거
- `Pron.`: 발음/정답 힌트 보조
- `Time+`: 남은 시간 증가

획득 방식:

- 정답 시 확률 드롭
- 보상형 광고가 지원되는 환경에서는 광고 시청으로 획득

## 12. 테마

관련 파일:

```text
lib/theme/app_theme.dart
lib/main.dart
```

현재 방향:

- 밝은 라이트 모드 전용
- 다크 모드 비활성화
- 따뜻한 오렌지 primary
- 하늘색 secondary
- 노란색 tertiary
- 민트색 정답 피드백

앱은 `ThemeMode.light`로 고정한다.

## 13. 제거된 레거시 요소

기존 사자성어 앱에서 제거한 것:

- 사자성어별 `.webp` 생성 이미지
- 이미지 프롬프트 문서
- 이미지 레지스트리 코드
- 기존 Play Store 피처 그래픽
- 기존 Play Store 스크린샷
- 다크 모드

## 14. 남은 기술 부채

아직 이름이 맞지 않는 레거시 요소:

- `Idiom`
- `idiom_repository.dart`
- `kanken_tier.dart`

권장 후속 작업:

- `Idiom`을 `SpanishEntry` 또는 `VocabularyEntry`로 변경
- 레거시 파일명 정리
- 기존 사용자 저장 데이터 마이그레이션 또는 리셋 정책 결정
- 템플릿 예문(자동 생성)을 자연스러운 실제 예문으로 교체

## 15. 검증 체크리스트

자동 검증:

```bash
flutter analyze
flutter test
```

수동 검증:

- 첫 실행 시 언어 선택 다이얼로그가 뜨는가
- 퀴즈에서 틀린 단어가 오답노트에 저장되는가
- 퀴즈 정답 공개 시 예문, 밑줄, 번역, DELE 레벨이 나오는가
- 오답노트에서 다시 맞힌 단어가 목록에서 제거되는가
- 단어장 상세 모달이 중앙에 충분히 크게 나오는가
- 시스템 다크 모드에서도 앱이 라이트 테마를 유지하는가
