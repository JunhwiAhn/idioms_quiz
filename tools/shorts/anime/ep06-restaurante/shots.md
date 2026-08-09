# ep06-restaurante — `null`

> 마드리드 동네 식당. 네 식구가 들어가서 앉고, 시키고, 먹고, 계산하고 나온다. 40초 안에 식사 한 판이 다 지나간다.

목표 표현은 샷  에서 0번 나온다.

예상 비용: 이미지 9장 4.5 + 영상 8편 60 = **64.5 크레딧**

## SHOT 1 — 0.0s ~ 5.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.

PADRE: Spanish man in his 40s from Madrid, long narrow face, warm olive skin, receding dark brown hair, light stubble, square dark-rimmed glasses, muted teal short-sleeve shirt tucked into warm grey-brown slacks, permanently deadpan half-lidded eyes.

HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.

HIJO: Spanish boy, 10, messy curly dark brown hair, round cheeks, freckles across the nose, mustard striped t-shirt, muted teal shorts, brown leather sandals.

NPC: Spanish waiter in his 50s, thick grey moustache, balding, black apron over a white shirt, small notepad in his breast pocket, a folded towel over his forearm.

SHOT 1: Wide vertical shot of the doorway of a small Madrid neighbourhood restaurant, cream walls, dark wood trim, tiled floor, a chalkboard by the door. The family of four has just stepped inside in a loose cluster. The waiter turns from the bar toward them, towel over his forearm, raising one hand in greeting. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Slow push in toward the family. The waiter raises his hand once. The door swings shut behind them. Background static.
```

- **NPC**: `¡Hola! ¿Cuántos sois?`
  - en: Hi there! How many of you?
  - ko: 안녕하세요! 몇 분이세요?
- **MADRE**: `Una mesa para cuatro.` ← 핵심 표현 (크게)
  - en: A table for four.
  - ko: 네 명 자리 주세요

## SHOT 2 — 5.0s ~ 10.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.

PADRE: Spanish man in his 40s from Madrid, long narrow face, warm olive skin, receding dark brown hair, light stubble, square dark-rimmed glasses, muted teal short-sleeve shirt tucked into warm grey-brown slacks, permanently deadpan half-lidded eyes.

HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.

HIJO: Spanish boy, 10, messy curly dark brown hair, round cheeks, freckles across the nose, mustard striped t-shirt, muted teal shorts, brown leather sandals.

NPC: Spanish waiter in his 50s, thick grey moustache, balding, black apron over a white shirt, small notepad in his breast pocket, a folded towel over his forearm.

SHOT 2: Medium wide shot of the family settling around a square table with a paper tablecloth. HIJO scrambles onto his chair on his knees. HIJA drops her phone on the table. The waiter is already handing menus across, one to MADRE. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. The waiter passes a menu across the table. HIJO settles onto his knees. Background static.
```

- **MADRE**: `La carta, por favor.` ← 핵심 표현 (크게)
  - en: The menu, please.
  - ko: 메뉴판 주세요

## SHOT 3 — 10.0s ~ 15.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.

NPC: Spanish waiter in his 50s, thick grey moustache, balding, black apron over a white shirt, small notepad in his breast pocket, a folded towel over his forearm.

SHOT 3: Medium two-shot. HIJA holds the open menu up with both hands, peering over the top of it at the waiter with a slightly lost expression. The waiter leans in, one hand on the back of a chair, pointing at a line on her menu. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. HIJA lowers the menu slightly. The waiter taps the menu once. Background static.
```

- **HIJA**: `¿Qué me recomienda?` ← 핵심 표현 (크게)
  - en: What do you recommend?
  - ko: 뭐가 맛있어요?
- **NPC**: `La paella está muy buena.`
  - en: The paella is very good.
  - ko: 빠에야가 아주 좋아요

## SHOT 4 — 15.0s ~ 20.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.

PADRE: Spanish man in his 40s from Madrid, long narrow face, warm olive skin, receding dark brown hair, light stubble, square dark-rimmed glasses, muted teal short-sleeve shirt tucked into warm grey-brown slacks, permanently deadpan half-lidded eyes.

HIJO: Spanish boy, 10, messy curly dark brown hair, round cheeks, freckles across the nose, mustard striped t-shirt, muted teal shorts, brown leather sandals.

NPC: Spanish waiter in his 50s, thick grey moustache, balding, black apron over a white shirt, small notepad in his breast pocket, a folded towel over his forearm.

SHOT 4: Medium shot across the table. HIJO is up on his knees with one arm shot straight into the air, ordering before anyone else. MADRE holds up two fingers. PADRE does not look up from the menu, raising one lazy finger. The waiter writes on his notepad. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. HIJO's raised arm wobbles. PADRE lifts one finger without moving his head. Background static.
```

- **HIJO**: `¡Yo quiero patatas bravas!`
  - en: I want patatas bravas!
  - ko: 저는 파타타스 브라바스요!
- **PADRE**: `Y una caña.`
  - en: And a small draft beer.
  - ko: 그리고 생맥주 한 잔

## SHOT 5 — 20.0s ~ 25.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.

PADRE: Spanish man in his 40s from Madrid, long narrow face, warm olive skin, receding dark brown hair, light stubble, square dark-rimmed glasses, muted teal short-sleeve shirt tucked into warm grey-brown slacks, permanently deadpan half-lidded eyes.

HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.

HIJO: Spanish boy, 10, messy curly dark brown hair, round cheeks, freckles across the nose, mustard striped t-shirt, muted teal shorts, brown leather sandals.

NPC: Spanish waiter in his 50s, thick grey moustache, balding, black apron over a white shirt, small notepad in his breast pocket, a folded towel over his forearm.

SHOT 5: Medium wide shot of the waiter lowering a wide paella pan into the centre of the table with both hands, steam rising in simple flat curls. All four faces lean in over the table, eyes wide, lit warmly from below by the dish. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Slow push in toward the pan. Steam curls rise. All four lean in together once. Background static.
```

- **NPC**: `¡Que aproveche!` ← 핵심 표현 (크게)
  - en: Enjoy your meal!
  - ko: 맛있게 드세요!
- **HIJO**: `¡Gracias!`
  - en: Thank you!
  - ko: 감사합니다!

## SHOT 6 — 25.0s ~ 30.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.

HIJO: Spanish boy, 10, messy curly dark brown hair, round cheeks, freckles across the nose, mustard striped t-shirt, muted teal shorts, brown leather sandals.

SHOT 6: Close two-shot. HIJO has both cheeks packed full, fork still in his mouth, eyes squeezed shut in bliss, a smear of sauce on his chin. MADRE watches him with a small satisfied smile, chin resting on her hand. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. HIJO chews twice. MADRE's smile widens slightly. Background static.
```

- **HIJO**: `Está muy rico.` ← 핵심 표현 (크게)
  - en: It's really good.
  - ko: 정말 맛있어요

## SHOT 7 — 30.0s ~ 35.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

PADRE: Spanish man in his 40s from Madrid, long narrow face, warm olive skin, receding dark brown hair, light stubble, square dark-rimmed glasses, muted teal short-sleeve shirt tucked into warm grey-brown slacks, permanently deadpan half-lidded eyes.

NPC: Spanish waiter in his 50s, thick grey moustache, balding, black apron over a white shirt, small notepad in his breast pocket, a folded towel over his forearm.

SHOT 7: Medium two-shot. The table is a wreck of empty plates and crumpled napkins. PADRE raises one hand just above shoulder height without any expression at all. The waiter is already turning toward him from across the room, nodding. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. PADRE raises one hand. The waiter nods once and turns. Background static.
```

- **PADRE**: `La cuenta, por favor.` ← 핵심 표현 (크게)
  - en: The bill, please.
  - ko: 계산서 주세요
- **NPC**: `Ahora mismo.`
  - en: Right away.
  - ko: 바로 갖다 드릴게요

## SHOT 8 — 35.0s ~ 40.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.

PADRE: Spanish man in his 40s from Madrid, long narrow face, warm olive skin, receding dark brown hair, light stubble, square dark-rimmed glasses, muted teal short-sleeve shirt tucked into warm grey-brown slacks, permanently deadpan half-lidded eyes.

HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.

HIJO: Spanish boy, 10, messy curly dark brown hair, round cheeks, freckles across the nose, mustard striped t-shirt, muted teal shorts, brown leather sandals.

SHOT 8: Wide shot of the table. HIJO has both palms pressed together in a pleading gesture, leaning across the empty plates with enormous hopeful eyes. HIJA films him on her phone. MADRE looks away, biting back a laugh. PADRE stares straight ahead, absolutely deadpan. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. HIJO leans further forward. PADRE does not move at all. Background static.
```

- **HIJO**: `¿Y el postre?`
  - en: What about dessert?
  - ko: 그럼 디저트는?
- **PADRE**: `No.`
  - en: No.
  - ko: 안 돼
