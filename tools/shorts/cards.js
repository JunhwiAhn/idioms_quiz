// "영어인 줄 알았는데" 세트의 카드 레이아웃.
//
// 프레임·푸터·CTA 등 세트 공통 부품은 card_base.js 에 있다.

import { KR, measure } from './fonts.js';
import {
  CW, CH, M, INNER,
  text, block, frame, footer, swipeHint, markX, markCheck,
} from './card_base.js';
import { theme } from './themes.js';

// 시리즈마다 배경색을 달리 가져간다. 이 세트는 머스터드. (themes.js)
// 오답/정답 표시는 의미가 고정된 색이라 테마와 무관하게 둔다.
const C = { ...theme('falseFriends'), wrong: '#B3261E', right: '#087F5B', rightSoft: '#DDF8E8' };

export function coverCard({ total }) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}" viewBox="0 0 ${CW} ${CH}">
${frame(C)}
${text('왕초보 스페인어', { x: CW / 2, y: 300, size: 40, weight: 500, fill: C.muted, spacing: 6 })}
<rect x="${CW / 2 - 40}" y="340" width="80" height="8" rx="4" fill="${C.accent}"/>
${block('영어인 줄 알았는데', { x: CW / 2, y: 480, maxWidth: INNER, maxLines: 1, size: 92, minSize: 60, fill: C.muted }).svg}
${block('뜻이 완전히 다른', { x: CW / 2, y: 610, maxWidth: INNER, maxLines: 1, size: 100, minSize: 64 }).svg}
${block('스페인어 7개', { x: CW / 2, y: 740, maxWidth: INNER, maxLines: 1, size: 110, minSize: 70, fill: C.accent }).svg}
<rect x="${CW / 2 - 300}" y="860" width="600" height="96" rx="48" fill="${C.accentSoft}"/>
${text('embarazada 는 "당황한" 이 아닙니다', { x: CW / 2, y: 922, size: 38, weight: 500, fill: C.accent })}
${swipeHint(C)}
${footer(1, total, C)}
</svg>`;
}

export function wordCard({ item, index, page, total }) {
  const y0 = 250;
  const term = block(item.term, {
    x: CW / 2, y: y0 + 130, maxWidth: INNER, maxLines: 1, size: 118, minSize: 64, fill: C.accent,
  });

  // 오해 / 실제 를 위아래로 붙여 대비를 만든다.
  const wrongY = y0 + 250;
  const rightY = wrongY + 230;

  const meaning = block(item.meaning, {
    x: CW / 2, y: rightY + 150, maxWidth: INNER - 80, maxLines: 2, size: 76, minSize: 46, fill: C.right,
  });

  const exampleY = rightY + 150 + meaning.height + 120;
  const example = block(item.example, {
    x: CW / 2, y: exampleY, maxWidth: INNER - 20, maxLines: 2, size: 44, minSize: 32, lineHeight: 1.35,
  });
  const translation = block(item.exampleMeaning, {
    x: CW / 2, y: exampleY + example.height + 46, maxWidth: INNER - 40, maxLines: 2, size: 38,
    minSize: 28, weight: 500, fill: C.muted, lineHeight: 1.35,
  });

  const badge = `${item.level}`;
  const badgeW = measure(badge, { family: KR, size: 30, weight: 700 }) + 48;

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}" viewBox="0 0 ${CW} ${CH}">
${frame(C)}
${text(`${index}`, { x: M, y: 190, size: 76, fill: C.accentSoft, anchor: 'start' })}
<rect x="${CW - M - badgeW}" y="146" width="${badgeW}" height="52" rx="26" fill="${C.accentSoft}"/>
${text(badge, { x: CW - M - badgeW / 2, y: 184, size: 30, fill: C.accent })}
${term.svg}

<rect x="${M}" y="${wrongY}" width="${INNER}" height="180" rx="32" fill="${C.card}"/>
${markX(M + 58, wrongY + 52, 26, C.wrong)}
${text('영어로 착각', { x: M + 90, y: wrongY + 64, size: 34, weight: 500, fill: C.wrong, anchor: 'start' })}
${block(`${item.looksLike} (${item.looksLikeKo})`, { x: M + 44, y: wrongY + 132, maxWidth: INNER - 88, maxLines: 1, size: 54, minSize: 34, fill: C.ink, anchor: 'start' }).svg}

<rect x="${M}" y="${rightY}" width="${INNER}" height="${meaning.height + 150}" rx="32" fill="${C.rightSoft}"/>
${markCheck(M + 58, rightY + 52, 28, C.right)}
${text('실제 뜻', { x: M + 90, y: rightY + 64, size: 34, weight: 500, fill: C.right, anchor: 'start' })}
${meaning.svg}

${example.svg}
${translation.svg}
${footer(page, total, C)}
</svg>`;
}
