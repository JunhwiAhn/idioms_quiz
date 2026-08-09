// "여행가서 꼭 쓰는 스페인어" 세트의 카드 레이아웃 — 기본(밝은 배경).
//
// 표현 하나를 보여주는 구조라 대비(오해/실제)가 없고, 표현 → 발음 → 뜻 → 예문 →
// 한 줄 해설의 세로 흐름으로 고정한다. 카드마다 요소 위치가 같아야 캐러셀을
// 넘길 때 눈이 흔들리지 않는다.
//
// 사진 배경 버전은 travel_cards_photo.js 에 따로 있다 (build --photo).

import { KR, measure } from './fonts.js';
import {
  CW, CH, M, INNER, C,
  text, block, frame, footer, swipeHint, pill, ctaCard,
} from './card_base.js';

export { ctaCard as travelCtaCard };

export function travelCoverCard({ total, count }) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}" viewBox="0 0 ${CW} ${CH}">
${frame()}
${text('여행 스페인어', { x: CW / 2, y: 300, size: 40, weight: 500, fill: C.muted, spacing: 6 })}
<rect x="${CW / 2 - 40}" y="340" width="80" height="8" rx="4" fill="${C.accent}"/>
${block('여행가서', { x: CW / 2, y: 480, maxWidth: INNER, maxLines: 1, size: 92, minSize: 60, fill: C.muted }).svg}
${block('꼭 쓰는 표현', { x: CW / 2, y: 610, maxWidth: INNER, maxLines: 1, size: 100, minSize: 64 }).svg}
${block(`스페인어 ${count}개`, { x: CW / 2, y: 740, maxWidth: INNER, maxLines: 1, size: 110, minSize: 70, fill: C.accent }).svg}
<rect x="${CW / 2 - 320}" y="860" width="640" height="96" rx="48" fill="${C.accentSoft}"/>
${text('이것만 알아도 스페인 여행 걱정 끝', { x: CW / 2, y: 922, size: 38, weight: 500, fill: C.accent })}
${swipeHint()}
${footer(1, total)}
</svg>`;
}

export function phraseCard({ item, index, page, total }) {
  const term = block(item.term, {
    x: CW / 2, y: 400, maxWidth: INNER, maxLines: 1, size: 112, minSize: 56, fill: C.accent,
  });

  const meaning = block(item.meaning, {
    x: CW / 2, y: 700, maxWidth: INNER - 40, maxLines: 2, size: 82, minSize: 46,
  });

  // 예문 카드는 뜻 아래에서 시작하되, 뜻이 두 줄이 되면 그만큼 밀린다.
  const exampleTop = 700 + meaning.height + 60;
  const example = block(item.example, {
    x: CW / 2, y: exampleTop + 88, maxWidth: INNER - 80, maxLines: 1, size: 50, minSize: 34, fill: C.right,
  });
  const exampleKo = block(item.exampleKo, {
    x: CW / 2, y: exampleTop + 160, maxWidth: INNER - 80, maxLines: 1, size: 38, minSize: 26,
    weight: 500, fill: C.muted,
  });

  const badgeW = measure(item.tag, { family: KR, size: 30, weight: 700 }) + 48;

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}" viewBox="0 0 ${CW} ${CH}">
${frame()}
${text(`${index}`, { x: M, y: 190, size: 76, fill: C.accentSoft, anchor: 'start' })}
<rect x="${CW - M - badgeW}" y="146" width="${badgeW}" height="52" rx="26" fill="${C.accentSoft}"/>
${text(item.tag, { x: CW - M - badgeW / 2, y: 184, size: 30, fill: C.accent })}

${term.svg}
${pill(`[ ${item.pron} ]`, { cx: CW / 2, top: 452, height: 84, size: 40 })}

<rect x="${CW / 2 - 40}" y="590" width="80" height="6" rx="3" fill="${C.line}"/>
${meaning.svg}

<rect x="${M}" y="${exampleTop}" width="${INNER}" height="200" rx="32" fill="${C.card}"/>
${example.svg}
${exampleKo.svg}

${block(item.tip, {
    x: CW / 2, y: 1160, maxWidth: INNER - 20, maxLines: 2, size: 38, minSize: 28,
    weight: 500, fill: C.muted, lineHeight: 1.35,
  }).svg}
${footer(page, total)}
</svg>`;
}
