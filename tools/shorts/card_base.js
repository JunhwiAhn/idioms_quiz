// 인스타그램 캐러셀 카드의 공용 부품 (1080x1350, 4:5).
//
// 세로 4:5는 피드에서 가장 넓게 잡히는 비율이라 카드뉴스 기본값으로 쓴다.
// 색과 폰트는 앱과 동일하게 맞춰서, 카드를 본 사람이 스토어에서 앱을 보고
// 같은 브랜드라는 걸 바로 알아보게 한다.
//
// 카드 세트(false friends / 여행 표현 …)가 늘어나도 프레임·푸터·CTA는
// 똑같아야 하므로 여기 모아 두고, 세트별 파일은 본문 레이아웃만 갖는다.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { KR, escapeXml, fitLines, measure } from './fonts.js';

const here = path.dirname(fileURLToPath(import.meta.url));

export const CW = 1080;
export const CH = 1350;

export const M = 90; // 좌우 여백
export const INNER = CW - M * 2;

export const C = {
  bg: '#FFFBF2',
  accent: '#C44720',
  accentSoft: '#F6E2D6',
  ink: '#2E2018',
  muted: '#8A7566',
  card: '#FFFFFF',
  line: '#EADCCB',
  wrong: '#B3261E',
  right: '#087F5B',
  rightSoft: '#DDF8E8',
};

export const iconDataUri = (() => {
  const file = path.resolve(here, '../../assets/images/app_icon.png');
  return `data:image/png;base64,${readFileSync(file).toString('base64')}`;
})();

export function text(content, { x, y, size, weight = 700, fill = C.ink, anchor = 'middle', spacing = 0 }) {
  return `<text x="${x}" y="${y}" font-family="${KR}" font-size="${size}" font-weight="${weight}" fill="${fill}" text-anchor="${anchor}"${spacing ? ` letter-spacing="${spacing}"` : ''}>${escapeXml(content)}</text>`;
}

export function block(content, { x, y, maxWidth, maxLines, size, minSize, weight = 700, fill = C.ink, lineHeight = 1.3, anchor = 'middle' }) {
  const fitted = fitLines(content, { maxWidth, maxLines, size, minSize, family: KR, weight });
  const step = fitted.size * lineHeight;
  return {
    svg: fitted.lines
      .map((line, i) => text(line, { x, y: y + i * step, size: fitted.size, weight, fill, anchor }))
      .join('\n'),
    height: step * fitted.lines.length,
  };
}

export function frame(t = C) {
  return `<rect width="${CW}" height="${CH}" fill="${t.bg}"/>
<circle cx="${CW - 30}" cy="90" r="230" fill="${t.accent}" opacity="0.05"/>
<circle cx="40" cy="${CH - 60}" r="200" fill="${t.accent}" opacity="0.04"/>`;
}

/** 우하단 브랜드 + 페이지 번호. 캐러셀 내내 같은 자리에 고정. */
export function footer(page, total, t = C) {
  return `${text('DELE Voca Dojo', { x: M, y: CH - 60, size: 32, fill: t.accent, anchor: 'start', spacing: 1 })}
${text(`${page} / ${total}`, { x: CW - M, y: CH - 60, size: 32, weight: 500, fill: t.muted, anchor: 'end' })}`;
}

/** ✕ / ○ 는 번들 폰트에 없어서 두부가 된다. 직접 그린다. */
export function markX(cx, cy, size, color) {
  const r = size / 2;
  return `<g stroke="${color}" stroke-width="6" stroke-linecap="round">
<line x1="${cx - r}" y1="${cy - r}" x2="${cx + r}" y2="${cy + r}"/>
<line x1="${cx + r}" y1="${cy - r}" x2="${cx - r}" y2="${cy + r}"/>
</g>`;
}

export function markCheck(cx, cy, size, color) {
  const r = size / 2;
  return `<polyline points="${cx - r},${cy} ${cx - r * 0.2},${cy + r * 0.7} ${cx + r},${cy - r * 0.8}" fill="none" stroke="${color}" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>`;
}

/** 스와이프 유도 화살표. 1장에서 이탈하는 걸 막는 장치. */
export function swipeHint(t = C, label = '넘겨서 확인하기') {
  const y = CH - 150;
  const size = 34;
  // 화살표 위치를 고정값으로 두면 문구 길이가 바뀔 때 글자와 겹친다
  // (영어판 "Swipe to see all" 이 한국어 기본 문구보다 길다). 폭을 재서 배치한다.
  const width = measure(label, { family: KR, size, weight: 500 });
  const gap = 22;
  const arrow = 22;
  const left = CW / 2 - (width + gap + arrow) / 2;
  const arrowX = left + width + gap;
  return `<g opacity="0.9">
${text(label, { x: left + width / 2, y, size, weight: 500, fill: t.muted })}
<path d="M${arrowX} ${y - 14} l ${arrow} 12 l -${arrow} 12" fill="none" stroke="${t.accent}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>
</g>`;
}

/** 가운데 정렬 알약 배지. 글자 폭을 재서 좌우 패딩을 맞춘다. */
export function pill(content, { cx, top, height = 84, size = 40, weight = 700, fill = C.accentSoft, textFill = C.accent, padding = 44 }) {
  const width = measure(content, { family: KR, size, weight }) + padding * 2;
  return `<rect x="${cx - width / 2}" y="${top}" width="${width}" height="${height}" rx="${height / 2}" fill="${fill}"/>
${text(content, { x: cx, y: top + height / 2 + size * 0.36, size, weight, fill: textFill })}`;
}

export function ctaCard({ total, storeLabel }) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}" viewBox="0 0 ${CW} ${CH}">
${frame()}
<image href="${iconDataUri}" x="${CW / 2 - 130}" y="230" width="260" height="260"/>
${text('DELE Voca Dojo', { x: CW / 2, y: 580, size: 72 })}
${block('스페인어 단어 1,250개', { x: CW / 2, y: 672, maxWidth: INNER, maxLines: 1, size: 54, minSize: 36, fill: C.accent }).svg}
${block('스테이지 · 마라톤 · 오답노트로 반복 학습', { x: CW / 2, y: 748, maxWidth: INNER, maxLines: 1, size: 42, minSize: 30, weight: 500, fill: C.muted }).svg}

<rect x="${M}" y="860" width="${INNER}" height="120" rx="60" fill="${C.accent}"/>
${text('Google Play 에서 무료 설치', { x: CW / 2, y: 936, size: 46, fill: '#FFFFFF' })}
${text(storeLabel, { x: CW / 2, y: 1046, size: 36, weight: 500, fill: C.muted })}
${text('프로필 링크에서 바로 이동', { x: CW / 2, y: 1108, size: 38, fill: C.accent })}
${footer(total, total)}
</svg>`;
}
