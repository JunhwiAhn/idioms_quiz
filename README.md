# Español Dojo

Español Dojo는 스페인어 DELE 어휘 학습용 Flutter 게임 앱입니다. 기존 사자성어 앱의 큰 흐름이었던 스테이지, 마라톤, 도감형 단어장, 오늘의 단어, 아이템 드롭, 랭크, 크로스워드 구조를 살리면서 콘텐츠를 스페인어 단어 학습으로 교체했습니다.

현재는 사자성어 앱에서 스페인어 학습 앱으로 전환하는 중간 단계입니다. 핵심 게임 플레이는 스페인어 어휘 중심으로 바뀌었고, 스토어 문서와 최종 브랜드 이미지 등은 추후 릴리스 단계에서 다시 정리해야 합니다.

## 주요 기능

- 스테이지 모드: 5개 스테이지, 스테이지당 8라운드, 라운드당 10문제
- 마라톤 모드: 무작위 50문제 연속 풀이, 최고 기록 저장
- 단어장: 정답을 맞힌 단어를 해금하고, 검색/필터/상세 모달로 복습
- 크로스워드: 4글자 스페인어 단어 2개가 한 글자를 공유하는 퍼즐
- 문제 유형:
  - 스페인어 단어를 보고 뜻 고르기
  - 뜻을 보고 스페인어 단어 고르기
  - 예문 빈칸에 들어갈 단어 고르기
- 학습 언어 선택:
  - 한국어
  - 영어
  - 일본어
- 첫 실행 시 언어 선택 다이얼로그 표시
- 홈 화면에서 언어 재설정 가능
- `shared_preferences`를 이용한 로컬 진행도 저장
- 아이템 시스템:
  - `50:50`
  - `Pron.`
  - `Time+`
- 밝은 톤의 라이트 모드 전용 테마
- 다크 모드 비활성화

## 데이터

메인 어휘 데이터 파일:

```text
assets/data/idioms.json
```

파일명은 기존 코드 호환성 때문에 아직 `idioms.json`을 유지하고 있지만, 실제 내용은 스페인어 어휘 데이터입니다.

현재 데이터 구조:

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

현재 데이터는 500개입니다. 자동 생성 느낌의 임시 표현은 제거했지만, 출시 전에는 실제 DELE 빈도/레벨 기준으로 단어와 예문을 검수하는 것이 좋습니다.

## 기술 스택

| 영역 | 사용 기술 |
|---|---|
| 프레임워크 | Flutter / Dart |
| UI | Material 3 |
| 로컬 저장 | `shared_preferences` |
| 오디오 | `audioplayers` |
| 애니메이션 | `flutter_animate`, `confetti` |
| 외부 링크 | `url_launcher` |
| 폰트 | Noto Sans JP / Noto Serif JP 번들 |

## 실행 방법

```bash
flutter pub get
flutter run -d <device_id>
```

웹 서버로 확인:

```bash
flutter run -d web-server --web-port 8080
```

## 검증

```bash
flutter analyze
flutter test
```

현재 두 명령 모두 통과합니다.

## 프로젝트 구조

```text
lib/
├── main.dart
├── models/
│   └── idiom.dart              # 스페인어 어휘 모델, 호환성 때문에 이름은 Idiom 유지
├── data/
│   ├── app_text.dart           # 선택 언어별 UI 문구
│   ├── crossword.dart          # 스페인어 크로스워드 생성
│   ├── daily.dart              # 오늘의 단어 문구
│   ├── idiom_repository.dart   # 어휘 JSON 로더
│   ├── kanken_tier.dart        # 어휘 마스터리 티어, 레거시 파일명
│   ├── level_tier.dart         # 레벨 라벨/색상
│   ├── quiz_session.dart       # 문제 생성/채점
│   ├── rank.dart               # 랭크 이름/해금 기준
│   ├── score_service.dart      # 진행도, 아이템, 언어 설정 저장
│   └── stage_plan.dart         # 스테이지/라운드 구성
├── screens/
│   ├── collection_screen.dart
│   ├── crossword_screen.dart
│   ├── home_screen.dart
│   ├── quiz_screen.dart
│   ├── result_screen.dart
│   ├── round_screen.dart
│   ├── splash_screen.dart
│   └── stage_screen.dart
└── theme/
    └── app_theme.dart
```

## 전환 작업에서 제거한 것

- 사자성어별 생성 `.webp` 이미지
- 이미지 프롬프트 문서
- 이미지 레지스트리 코드
- 기존 Play Store 피처 그래픽
- 기존 Play Store 스크린샷
- 다크 모드 지원

## 남은 정리 작업

- `Idiom`, `idiom_repository.dart`, `idioms.json`, `kanken_tier.dart` 등 레거시 이름 변경
- 스페인어 앱에 맞는 앱 아이콘/파비콘 교체
- 스토어 문서, 개인정보처리방침, Play Console 문서 재작성
- 500개 어휘 데이터를 실제 DELE 기준으로 검수
- 크로스워드의 가변 길이 단어/가변 그리드 지원

## 라이선스

이 저장소는 별도 명시가 없는 한 proprietary 프로젝트입니다. 자세한 내용은 [LICENSE](LICENSE), [NOTICE.md](NOTICE.md)를 참고하세요.
