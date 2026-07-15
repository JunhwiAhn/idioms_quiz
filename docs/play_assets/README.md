# Play Console 제출용 그래픽 자산

## 상태 (2026-07-13)

이 폴더의 기존 자산(아이콘·피처 그래픽·스크린샷)은 **전부 이전 앱(四字熟語道場) 기준이라 사용할 수 없으며 이미 제거되었습니다.**
DELE Voca Dojo 기준으로 아래 자산을 새로 제작해야 합니다.

## 새로 만들어야 하는 것

| 자산 | 요건 | 비고 |
|---|---|---|
| `icon_512.png` | 512×512 PNG, 알파 포함 | `assets/images/app_icon.png`에서 리사이즈 |
| `feature_graphic.png` | 1024×500 JPG/PNG, 불투명 | 앱 이름 + 캐치프레이즈 중앙 배치 |
| `screenshots/*.png` | 1080×1920 이상 (9:16 권장), 2~8장 | 아래 추천 구성 참조 |

## 스크린샷 추천 구성 (6장)

1. 홈 화면 (브랜드·메뉴)
2. 스테이지 선택 (별점 보이게)
3. 퀴즈 화면 (4지선다 + 예문)
4. 정답 공개 화면 (예문 밑줄 + 번역 + DELE 레벨)
5. 마라톤 결과 화면
6. 단어장 (검색/필터)

## 촬영 방법 (에뮬레이터)

에뮬레이터 실행 중 각 화면으로 이동한 뒤:

```bash
adb exec-out screencap -p > docs/play_assets/screenshots/01_home.png
```

## 개인정보처리방침 공개 (GitHub Pages)

1. GitHub 리포지토리 → **Settings → Pages**
2. Source: `Deploy from a branch`, Branch: `main`, 폴더: `/docs` → Save
3. 공개 URL (예: `https://junhwiahn.github.io/idioms_quiz/`)을 Play Console에 입력
