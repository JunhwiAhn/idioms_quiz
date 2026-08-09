// 표현 카드 세트의 공용 레이아웃 (표지 + 표현).
//
// 세트가 늘어나도 레이아웃은 하나만 유지하고, 색(themes.js)과 데이터(sets/)만
// 갈아 끼운다. 캐러셀을 넘길 때 요소 위치가 흔들리지 않아야 하므로 좌표는
// 세트와 무관하게 고정한다.

import { KR, measure } from './fonts.js';
import {
  CW, CH, M, INNER,
  text, block, frame, footer, swipeHint, pill, iconDataUri,
} from './card_base.js';

/** 표지 — 이 세트가 무슨 시리즈인지 한 장으로 알려 준다. 피드 썸네일이 된다. */
export function coverCard({ set, t, total }) {
  const { eyebrow, line1, line2, accentLine, pill: pillText } = set.cover;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}" viewBox="0 0 ${CW} ${CH}">
${frame(t)}
${text(eyebrow, { x: CW / 2, y: 300, size: 40, weight: 500, fill: t.muted, spacing: 6 })}
<rect x="${CW / 2 - 40}" y="340" width="80" height="8" rx="4" fill="${t.accent}"/>
${block(line1, { x: CW / 2, y: 480, maxWidth: INNER, maxLines: 1, size: 92, minSize: 52, fill: t.muted }).svg}
${block(line2, { x: CW / 2, y: 610, maxWidth: INNER, maxLines: 1, size: 100, minSize: 56, fill: t.ink }).svg}
${block(accentLine, { x: CW / 2, y: 740, maxWidth: INNER, maxLines: 1, size: 110, minSize: 60, fill: t.accent }).svg}
${pill(pillText, { cx: CW / 2, top: 860, height: 96, size: 38, weight: 500, fill: t.accentSoft, textFill: t.accent })}
${swipeHint(t, set.swipeLabel)}
${footer(1, total, t)}
</svg>`;
}

export function phraseCard({ item, index, page, total, t }) {
  const term = block(item.term, {
    x: CW / 2, y: 400, maxWidth: INNER, maxLines: 1, size: 112, minSize: 48, fill: t.accent,
  });

  const meaning = block(item.meaning, {
    x: CW / 2, y: 700, maxWidth: INNER - 40, maxLines: 2, size: 82, minSize: 42, fill: t.ink,
  });

  // 예문 패널은 뜻 아래에서 시작한다. 뜻이 두 줄이면 그만큼 밀리므로 간격을
  // 좁혀서 흡수하고, 팁은 패널 아래로 따라 내려간다. 팁이 푸터를 침범하지
  // 않도록 상한을 두는데, 이걸 안 두면 두 줄짜리 뜻에서 글자가 겹친다.
  const PANEL_H = 200;
  const panelTop = 700 + meaning.height + (meaning.height > 150 ? 34 : 60);
  const example = block(item.example, {
    x: CW / 2, y: panelTop + 88, maxWidth: INNER - 80, maxLines: 1, size: 50, minSize: 30, fill: t.accent,
  });
  // 예문 번역. 한국어 세트는 exampleKo, 영어 세트(sets/en)는 exampleTrans 를 쓴다.
  const exampleKo = block(item.exampleTrans ?? item.exampleKo, {
    x: CW / 2, y: panelTop + 160, maxWidth: INNER - 80, maxLines: 1, size: 38, minSize: 24,
    weight: 500, fill: t.muted,
  });
  const tipY = Math.min(Math.max(1160, panelTop + PANEL_H + 70), 1206);

  const badgeW = measure(item.tag, { family: KR, size: 30, weight: 700 }) + 48;

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}" viewBox="0 0 ${CW} ${CH}">
${frame(t)}
${text(`${index}`, { x: M, y: 190, size: 76, fill: t.accentSoft, anchor: 'start' })}
<rect x="${CW - M - badgeW}" y="146" width="${badgeW}" height="52" rx="26" fill="${t.accentSoft}"/>
${text(item.tag, { x: CW - M - badgeW / 2, y: 184, size: 30, fill: t.accent })}

${term.svg}
${pill(`[ ${item.pron} ]`, { cx: CW / 2, top: 452, height: 84, size: 40, fill: t.accentSoft, textFill: t.accent })}

<rect x="${CW / 2 - 40}" y="590" width="80" height="6" rx="3" fill="${t.line}"/>
${meaning.svg}

<rect x="${M}" y="${panelTop}" width="${INNER}" height="${PANEL_H}" rx="32" fill="${t.card}"/>
${example.svg}
${exampleKo.svg}

${block(item.tip, {
    x: CW / 2, y: tipY, maxWidth: INNER - 20, maxLines: 2, size: 38, minSize: 26,
    weight: 500, fill: t.muted, lineHeight: 1.35,
  }).svg}
${footer(page, total, t)}
</svg>`;
}

/** 마지막 앱 안내 카드. 10장 상한 때문에 항목이 8개 이하인 세트에만 붙인다. */
export function ctaCard({ total, storeLabel, t }) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}" viewBox="0 0 ${CW} ${CH}">
${frame(t)}
<image href="${iconDataUri}" x="${CW / 2 - 130}" y="230" width="260" height="260"/>
${text('DELE Voca Dojo', { x: CW / 2, y: 580, size: 72, fill: t.ink })}
${block('스페인어 단어 1,250개', { x: CW / 2, y: 672, maxWidth: INNER, maxLines: 1, size: 54, minSize: 36, fill: t.accent }).svg}
${block('스테이지 · 마라톤 · 오답노트로 반복 학습', { x: CW / 2, y: 748, maxWidth: INNER, maxLines: 1, size: 42, minSize: 30, weight: 500, fill: t.muted }).svg}

<rect x="${M}" y="860" width="${INNER}" height="120" rx="60" fill="${t.accent}"/>
${text('Google Play 에서 무료 설치', { x: CW / 2, y: 936, size: 46, fill: '#FFFFFF' })}
${text(storeLabel, { x: CW / 2, y: 1046, size: 36, weight: 500, fill: t.muted })}
${text('프로필 링크에서 바로 이동', { x: CW / 2, y: 1108, size: 38, fill: t.accent })}
${footer(total, total, t)}
</svg>`;
}
