# 여행 스페인어 카드뉴스 — 배경 사진 제작 의뢰서

`build_travel_cards.js` 가 이 폴더에서 배경을 찾습니다.
**없는 파일은 브랜드 색 그라데이션으로 자동 대체**되므로 만들어지는 대로 하나씩 넣어도 됩니다.

- 파일명은 아래 표 그대로. `.jpg` / `.jpeg` / `.png` 모두 인식합니다.
- **비율 4:5**, 1080×1350 이상. 다른 비율을 넣으면 가운데를 기준으로 잘립니다.
- 다 넣은 뒤 `node build_travel_cards.js` 를 다시 실행하면 반영됩니다.

## 반드시 지켜야 할 것

1. **글자 금지.** 이미지 안에 간판·표지판 글자가 크게 들어가면 위에 얹는 문구와 부딪힙니다.
2. **가운데를 비워 두세요.** 화면 중앙(세로 25~75%)에 표현·발음·뜻이 올라갑니다.
   주요 피사체는 위쪽이나 아래쪽 가장자리에 두세요.
3. **12장이 한 세트로 보여야 합니다.** 같은 대화창에서 이어서 만들어야 색감이 통일됩니다.
4. 렌더러가 어두운 스크림을 자동으로 덮습니다. 그래서 **원본은 밝고 채도가 있어야**
   최종 결과가 탁하지 않습니다. 미리 어둡게 만들지 마세요.

## 공통 스타일 (모든 이미지에 동일 적용)

```
Warm, sunlit travel photography of Spain. Golden-hour Mediterranean light.
Terracotta, cream, warm sand, and deep teal accents.
Shallow depth of field, softly blurred background, no harsh shadows.
Inviting and calm, the feeling of a good trip.
Absolutely no text, no letters, no numbers, no logos, no watermarks, no faces in focus.
Vertical 4:5 composition with the center of the frame left visually quiet.
```

## 목록

| 파일명 | 카드 | 프롬프트 |
|---|---|---|
| `cover.jpg` | 표지 | A sunlit Spanish plaza seen from a low angle, terracotta rooftops and a warm sky, wide open quiet center |
| `01-hola.jpg` | Hola | A bright Spanish street corner in the morning, open shop shutters and a café awning, empty sidewalk |
| `02-gracias.jpg` | Gracias | A small café counter with a coffee cup being set down, warm light, hands only, no faces |
| `03-por-favor.jpg` | Por favor | A café table from above with a cortado, a glass of water, and a napkin on warm stone |
| `04-si-no.jpg` | Sí / No | A simple sunlit whitewashed wall with two shuttered windows, strong warm shadows |
| `05-cuanto-cuesta.jpg` | ¿Cuánto cuesta? | A colorful Spanish market stall with fruit crates and a hanging scale, blurred background |
| `06-donde-esta.jpg` | ¿Dónde está...? | A narrow old-town alley leading toward bright light, cobblestones, flower balconies |
| `07-bano.jpg` | Baño | A clean tiled interior corridor with warm lamps and blue-and-white Spanish tiles |
| `08-agua.jpg` | Agua | A glass bottle and a tumbler of sparkling water on a sunlit terrace table, condensation |
| `09-ayuda.jpg` | Ayuda | A calm evening street with a soft streetlight glow and a distant open pharmacy cross |
| `10-perdon.jpg` | Lo siento / Perdón | A busy but softly blurred pedestrian street, people out of focus, warm dusk light |
| `cta.jpg` | 마무리 | A Spanish balcony at dusk with warm lamp light and distant rooftops, calm end-of-trip mood |

## 사진을 직접 구할 경우

생성 대신 스톡 사진을 쓸 거라면 **상업적 사용이 허용되는 라이선스**인지 꼭 확인하세요
(Unsplash / Pexels 라이선스는 허용, 출처 표기 불필요). 앱 홍보 계정이라 상업적
이용에 해당합니다. 인물 얼굴이 식별되는 사진은 초상권 문제가 있어 피하는 게 안전합니다.
