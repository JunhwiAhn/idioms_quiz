# Shorts 생성기 — 스페인어 첫걸음 20일

앱의 문제 은행(`assets/data/dele_a1_a2_b1_problem_bank.enriched.json`)에서
초보자용 YouTube Shorts를 한국어·영어·일본어로 자동 생성합니다.

**영상 20편 × 3개 언어 = 60개.** 스페인어 화면·음성은 3개 언어가 공유하고,
뜻·예문 번역·제목·설명만 언어별로 바뀝니다.

## 설치

```bash
cd tools/shorts
npm install
node fetch_fonts.js
```

`fetch_fonts.js`는 Noto Sans KR Bold/Medium(OTF, SIL OFL)을 내려받습니다.
앱이 쓰는 `NotoSansKR-VF.ttf`는 가변폰트라 resvg가 굵기 축을 무시해서
별도 정적 폰트가 필요합니다. 폰트는 용량 때문에 git에 넣지 않습니다.

## 음성 설정 (필수)

기본 음성 엔진은 **Google Cloud Text-to-Speech**입니다. 출력물의 상업적 사용이
정상 약관으로 허용되고, 이 시리즈 전체가 무료 할당량(월 100만 자) 안에 들어갑니다.
20편 전체 합성에 3,504자를 씁니다.

1. https://console.cloud.google.com 에서 프로젝트 생성
2. `Cloud Text-to-Speech API` 사용 설정
3. 사용자 인증 정보 → API 키 발급
4. 환경변수 설정 후 터미널 재시작

```powershell
[Environment]::SetEnvironmentVariable('GOOGLE_TTS_API_KEY','<발급받은 키>','User')
```

5. 확인 및 샘플 생성

```bash
node setup_google_tts.js
```

키 검증 → 사용 가능한 es-ES 음성 확인 → 샘플 mp3 2개 생성까지 한 번에 합니다.
음성을 바꾸려면 `GOOGLE_TTS_VOICE_WORD` / `GOOGLE_TTS_VOICE_SENTENCE` 를 설정하세요.

> **`TTS_PROVIDER=edge` 는 로컬 테스트 전용입니다.**
> Edge의 "소리내어 읽기" 내부 엔드포인트를 사용하는데, 이는 공개 API가 아니고
> 배포용 콘텐츠에 대한 라이선스가 없습니다. 이걸로 만든 영상은 업로드하지 마세요.

## 사용

```bash
node build.js --plan            # 20일 커리큘럼만 출력 (렌더링 없음)
node build.js --lang ko --day 1 # 1편만
node build.js --lang ko         # 한국어 20편
node build.js                   # 전체 60편
```

결과물: `out/<lang>/ep01/video.mp4`, `metadata.json`, `metadata.txt`
`metadata.txt`에 제목·설명·태그·고정 댓글이 그대로 붙여넣을 수 있게 들어 있습니다.

## 영상 구성 (약 70초)

| 장면 | 길이 | 내용 |
|---|---|---|
| 인트로 | 2.6s | DAY n + 테마 제목·부제 |
| 단어 ×5 | ~2.6s | 스페인어 단어 + 발음(TTS) + "무슨 뜻일까요?" |
| 뜻 ×5 | ~2.5s | 뜻 공개 + 단어 발음 한 번 더 |
| 예문 ×5 | ~4.5s | 예문 + 번역 + 예문 낭독 |
| 복습 | 6.5s | 5단어 한 화면 정리 + 전체 낭독 |
| 오늘의 포인트 | 5.5~9s | 그 날 단어에 맞춘 직접 작성 해설 |
| CTA | 3.0s | 앱 아이콘 + 스토어 유도 |

「오늘의 포인트」는 [tips.js](tips.js)에 회차별로 직접 써 둔 해설입니다.
유튜브의 "진정성 없는 콘텐츠" 정책은 *템플릿만 반복하고 제작자의 기여가 없는* 콘텐츠를
문제 삼기 때문에, 회차마다 고유한 설명이 있는지가 중요합니다. 회차를 추가할 때는
`tips.js`에 해당 day의 해설을 반드시 같이 추가하세요 (없으면 빌드가 실패합니다).
설명란과 고정 댓글도 회차별로 문구가 달라지도록 `strings.js`에서 로테이션됩니다.

Shorts 플레이어가 하단 약 450px와 우측을 가리기 때문에 모든 내용은
y=260~1440 안에 배치됩니다.

## 데이터 흐름

- **단어 선정** — `curriculum.js`. A1 우선, A2로 보충. 난이도 → 예문 길이 순 정렬이라
  같은 은행이면 항상 같은 결과가 나옵니다.
- **주제 분류** — `topics.js`. 문제 은행의 `theme` 필드는 실제 주제와 맞지 않아
  (`greetings`에 `avión`이 들어 있음) 앱과 똑같이 `kStageTopics`의 키워드로 매칭합니다.
- **주제 제목** — `theme_titles.js` / `topics.js`가 `lib/data/stage_plan.dart`에서
  한/영/일 제목을 직접 읽습니다. 앱 문구를 고치면 영상 문구도 같이 바뀝니다.
- **음성** — `tts.js`. Edge 신경망 음성(`es-ES-AlvaroNeural` 단어 / `es-ES-ElviraNeural` 예문),
  초보자용으로 속도를 낮췄습니다. `.cache/tts/`에 캐시되어 언어별 렌더링에서 재사용됩니다.

## 알려진 제약

- **인사말 단어가 문제 은행에 없습니다.** `hola`, `gracias`, `adiós`, `por favor`,
  `buenos días` 전부 없어서 커리큘럼에서 인사 주제를 뺐습니다. 앱의 첫 스테이지
  "Hola, 첫 인사"도 같은 이유로 단어가 1개(`llamarse`)뿐이라 라운드가 만들어지지
  않습니다. 은행에 인사말을 추가하면 앱과 영상 양쪽이 같이 해결됩니다.
- 화면은 정지 장면 전환입니다. 자막 애니메이션이 필요하면 장면을 여러 프레임으로
  쪼개 렌더링하는 방식으로 확장할 수 있습니다.
- 발음 표기(한글/가나 음차)는 넣지 않았습니다. 기계 음차는 오류가 잦아
  TTS 음성으로 대체했습니다.
