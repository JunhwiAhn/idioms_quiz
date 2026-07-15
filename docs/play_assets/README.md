# Play Console 제출용 그래픽 자산 — DELE Voca Dojo

## 상태 (2026-07-15) — 3개국(한국/미국/일본) 출시용 자산 준비 완료

| 자산 | 파일 | 용도 |
|---|---|---|
| 고해상도 아이콘 | `icon_512.png` (512×512) | 모든 언어 공통 |
| 피처 그래픽 (한국어) | `feature_graphic.png` (1024×500) | ko-KR 등록정보 |
| 피처 그래픽 (영어) | `feature_graphic_en.png` | en-US 등록정보 |
| 피처 그래픽 (일본어) | `feature_graphic_ja.png` | ja-JP 등록정보 |
| 스크린샷 (한국어) | `screenshots/ko/*.png` 5장 (1080×2400) | ko-KR 등록정보 |
| 스크린샷 (영어) | `screenshots/en/*.png` 5장 | en-US 등록정보 |
| 스크린샷 (일본어) | `screenshots/ja/*.png` 5장 | ja-JP 등록정보 |

스크린샷 구성(언어별 동일): ① 홈 ② 스테이지 선택 ③ 퀴즈 ④ 정답 공개 ⑤ 단어장

피처 그래픽 원본은 `feature_graphic*.html` — 문구 수정 후 headless Chrome으로 재렌더링:

```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --headless --disable-gpu `
  --screenshot="<절대경로>\feature_graphic.png" --window-size=1024,500 --hide-scrollbars `
  "file:///C:/dev/idioms_quiz/docs/play_assets/feature_graphic.html"
```

## Play Console 업로드 방법 (언어별)

1. 「스토어 등록정보」 → 「번역 관리」에서 en-US, ja-JP 추가 (기본 언어: ko-KR)
2. 각 언어 탭에서 해당 언어의 피처 그래픽·스크린샷 업로드
3. 텍스트는 [store_listing.md](../store_listing.md)의 언어별 섹션 사용

## 개인정보처리방침 공개 (GitHub Pages)

이미 활성화됨: `https://junhwiahn.github.io/idioms_quiz/` (한/영/일 병기 페이지, push 시 자동 갱신)
