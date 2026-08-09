# ep07-tienda — `null`

> 마드리드 동네 옷 가게. 딸이 옷을 하나 고르는 동안 구경·피팅·사이즈·세일·결제가 순서대로 지나간다.

목표 표현은 샷  에서 0번 나온다.

예상 비용: 이미지 0장 0 + 영상 8편 672 = **672 크레딧**

## SHOT 1 — 0.0s ~ 5.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.

PADRE: Spanish man in his 40s from Madrid, long narrow face, warm olive skin, receding dark brown hair, light stubble, square dark-rimmed glasses, muted teal short-sleeve shirt tucked into warm grey-brown slacks, permanently deadpan half-lidded eyes.

HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.

HIJO: Spanish boy, 10, messy curly dark brown hair, round cheeks, freckles across the nose, mustard striped t-shirt, muted teal shorts, brown leather sandals.

NPC: Spanish shop assistant woman in her 30s, dark hair in a high ponytail, thin gold necklace, cream knit top and dark jeans, measuring tape draped over one shoulder.

SHOT 1: Wide vertical shot inside a small Madrid clothing shop, cream walls, wooden rails of folded clothes, a mirror at the back. The family has just come in. HIJA is already running her hand along a rail. The shop assistant steps forward with a friendly open gesture. PADRE stops just inside the door holding shopping bags. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Slow push in toward HIJA at the rail. The assistant steps forward once. Clothes on the rail sway slightly.
```

- **NPC**: `¿Te ayudo en algo?`
  - en: Can I help you with anything?
  - ko: 뭐 도와드릴까요?
- **HIJA**: `Solo estoy mirando.` ← 핵심 표현 (크게)
  - en: I'm just looking.
  - ko: 그냥 구경 중이에요

## SHOT 2 — 5.0s ~ 10.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.

NPC: Spanish shop assistant woman in her 30s, dark hair in a high ponytail, thin gold necklace, cream knit top and dark jeans, measuring tape draped over one shoulder.

SHOT 2: Medium two-shot. HIJA holds a terracotta jacket up against her shoulders, chin tilted, asking. The shop assistant points off-frame toward the fitting rooms with an open palm, smiling. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. HIJA lifts the jacket against her shoulders. The assistant extends her arm to point.
```

- **HIJA**: `¿Puedo probármelo?` ← 핵심 표현 (크게)
  - en: Can I try it on?
  - ko: 입어봐도 돼요?
- **NPC**: `Claro, al fondo.`
  - en: Sure, at the back.
  - ko: 그럼요, 안쪽이에요

## SHOT 3 — 10.0s ~ 15.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.

NPC: Spanish shop assistant woman in her 30s, dark hair in a high ponytail, thin gold necklace, cream knit top and dark jeans, measuring tape draped over one shoulder.

SHOT 3: Medium shot at the fitting room curtain. HIJA leans out wearing the jacket, which is visibly too big, sleeves swallowing her hands. The shop assistant looks her up and down with a knowing expression, already turning away. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. HIJA raises one arm and the oversized sleeve flops. The assistant turns her head.
```

- **HIJA**: `¿Tiene otra talla?` ← 핵심 표현 (크게)
  - en: Do you have another size?
  - ko: 다른 사이즈 있어요?
- **NPC**: `Te traigo la mediana.`
  - en: I'll get you the medium.
  - ko: 미디엄으로 갖다드릴게요

## SHOT 4 — 15.0s ~ 20.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.

HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.

SHOT 4: Close two-shot. MADRE has turned the price tag over between two fingers and is staring at it with her eyebrows climbing. HIJA, now in the correct size, watches her mother's face with dread. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. MADRE turns the price tag once. HIJA's shoulders drop slightly.
```

- **MADRE**: `Es un poco caro.`
  - en: It's a bit expensive.
  - ko: 좀 비싸네
- **HIJA**: `Mamá...`
  - en: Mum...
  - ko: 엄마아...

## SHOT 5 — 20.0s ~ 25.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.

NPC: Spanish shop assistant woman in her 30s, dark hair in a high ponytail, thin gold necklace, cream knit top and dark jeans, measuring tape draped over one shoulder.

SHOT 5: Medium two-shot at the counter. MADRE turns to the shop assistant with a bright hopeful face, still holding the price tag. The assistant brightens and holds up three fingers and a zero shape. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. MADRE turns her head to the assistant. The assistant raises three fingers.
```

- **MADRE**: `¿Está en rebajas?` ← 핵심 표현 (크게)
  - en: Is it on sale?
  - ko: 세일 중이에요?
- **NPC**: `Sí, treinta por ciento.`
  - en: Yes, thirty percent off.
  - ko: 네, 30% 할인이에요

## SHOT 6 — 25.0s ~ 30.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.

SHOT 6: Close-up of HIJA hugging the folded jacket to her chest with both arms, eyes shining, decision made. Blurred shop rails behind her. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Slight push in. HIJA hugs the jacket tighter and nods once.
```

- **HIJA**: `Me lo llevo.` ← 핵심 표현 (크게)
  - en: I'll take it.
  - ko: 이걸로 할게요

## SHOT 7 — 30.0s ~ 35.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.

NPC: Spanish shop assistant woman in her 30s, dark hair in a high ponytail, thin gold necklace, cream knit top and dark jeans, measuring tape draped over one shoulder.

SHOT 7: Medium two-shot at the counter. MADRE holds a card out between two fingers. The shop assistant is already reaching for the card terminal with a nod. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. MADRE extends the card. The assistant reaches for the terminal.
```

- **MADRE**: `¿Puedo pagar con tarjeta?` ← 핵심 표현 (크게)
  - en: Can I pay by card?
  - ko: 카드로 계산돼요?
- **NPC**: `Por supuesto.`
  - en: Of course.
  - ko: 물론이죠

## SHOT 8 — 35.0s ~ 40.0s

**이미지 프롬프트**

```
STYLE: 1990s Japanese TV anime cel look, hand-painted flat matte color fills, no gradients, no rim light, no glossy highlights. Uniform dark warm-brown ink outlines of even thin weight, never pure black. Rounded simplified shapes, small simple facial features, gentle exaggerated expressions. Shadows are single flat tones only. Simple background art with few details. Static TV-anime framing. Slight paper grain. 9:16 vertical, 1080x1920.

PALETTE (strict, use only these): warm cream #FFFBF2, terracotta #C44720, soft peach #F6E2D6, warm sand #EADCCB, muted teal #007C99, mustard #8B6500, warm brown ink #2E2018.

MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.

PADRE: Spanish man in his 40s from Madrid, long narrow face, warm olive skin, receding dark brown hair, light stubble, square dark-rimmed glasses, muted teal short-sleeve shirt tucked into warm grey-brown slacks, permanently deadpan half-lidded eyes.

HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.

HIJO: Spanish boy, 10, messy curly dark brown hair, round cheeks, freckles across the nose, mustard striped t-shirt, muted teal shorts, brown leather sandals.

SHOT 8: Wide shot by the shop door. MADRE turns back toward the counter asking for one more bag. HIJA hugs her new jacket. HIJO is spinning a hanger. PADRE stands motionless with five shopping bags hanging off both arms, staring flatly straight ahead. Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.

NEGATIVE: photorealistic, 3D render, CGI, glossy skin, cinematic lighting, depth of field, lens flare, hyperdetailed, extra fingers, deformed hands, watermark, logo, western cartoon style, moe anime style, sexualized, heavy shadows, saturated primary colors
```

**모션 프롬프트**

```
Static shot. MADRE turns her head back. PADRE does not move at all. The hanger spins.
```

- **MADRE**: `¿Me da una bolsa?`
  - en: Could I have a bag?
  - ko: 봉투 하나 주시겠어요?
- **PADRE**: `Ya llevo cinco.`
  - en: I'm already carrying five.
  - ko: 나 벌써 다섯 개 들었어
