// SVG scene templates for one Short. 1080x1920, brand colours taken from
// lib/theme/app_theme.dart so a viewer who taps through to the store recognises
// the app instantly.
//
// Layout is built around the Shorts safe area: the player covers roughly the
// bottom 450px with the title/channel row and the right edge with the action
// buttons, so everything that matters lives between y=260 and y=1440.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { KR, JP, escapeXml, fitLines, measure } from './fonts.js';
import { UI } from './strings.js';

const here = path.dirname(fileURLToPath(import.meta.url));

export const W = 1080;
export const H = 1920;

const SAFE = { top: 260, bottom: 1440, left: 90, right: 990 };
const CONTENT_WIDTH = SAFE.right - SAFE.left;

const C = {
  bg: '#FFFBF2',
  accent: '#C44720',
  accentSoft: '#F6E2D6',
  ink: '#2E2018',
  muted: '#8A7566',
  card: '#FFFFFF',
  line: '#EADCCB',
};

const iconDataUri = (() => {
  const file = path.resolve(here, '../../assets/images/app_icon.png');
  return `data:image/png;base64,${readFileSync(file).toString('base64')}`;
})();

/** Bold/regular weights differ per family: KR ships 700/500, JP ships 800/400. */
function weight(family, kind) {
  if (family === JP) return kind === 'bold' ? 800 : 400;
  return kind === 'bold' ? 700 : 500;
}

function familyFor(lang) {
  return lang === 'ja' ? JP : KR;
}

function text(content, { x, y, size, family = KR, kind = 'bold', fill = C.ink, anchor = 'middle', spacing = 0 }) {
  return `<text x="${x}" y="${y}" font-family="${family}" font-size="${size}" font-weight="${weight(family, kind)}" fill="${fill}" text-anchor="${anchor}"${spacing ? ` letter-spacing="${spacing}"` : ''}>${escapeXml(content)}</text>`;
}

/** Multi-line block that auto-shrinks; returns svg plus the height it consumed. */
function block(content, { x, y, centerY, maxWidth, maxLines, size, minSize, family = KR, kind = 'bold', fill = C.ink, lineHeight = 1.28, anchor = 'middle' }) {
  const w = weight(family, kind);
  const fitted = fitLines(content, { maxWidth, maxLines, size, minSize, family, weight: w });
  const step = fitted.size * lineHeight;
  // `y` is the first baseline; `centerY` instead centres the whole block on it.
  const first =
    centerY === undefined
      ? y
      : centerY - ((fitted.lines.length - 1) * step) / 2 + fitted.size * 0.36;
  const svg = fitted.lines
    .map((line, i) => text(line, { x, y: first + i * step, size: fitted.size, family, kind, fill, anchor }))
    .join('\n');
  return { svg, height: step * fitted.lines.length, size: fitted.size };
}

function pill(label, { y, family, size = 44, fg = '#FFFFFF', bg = C.accent, padding = 48 }) {
  const w = measure(label, { family, size, weight: weight(family, 'bold') }) + padding * 2;
  const h = size * 2.1;
  return `<rect x="${(W - w) / 2}" y="${y}" width="${w}" height="${h}" rx="${h / 2}" fill="${bg}"/>
${text(label, { x: W / 2, y: y + h / 2 + size * 0.36, size, family, fill: fg })}`;
}

/** Speaker glyph drawn as paths — no emoji font is bundled. */
function speaker(cx, cy, scale = 1, fill = C.muted) {
  return `<g transform="translate(${cx - 44 * scale} ${cy - 34 * scale}) scale(${scale})" fill="none" stroke="${fill}" stroke-width="7" stroke-linecap="round" stroke-linejoin="round">
<path d="M6 24 L6 44 L24 44 L44 62 L44 6 L24 24 Z" fill="${fill}"/>
<path d="M58 24 A18 18 0 0 1 58 44"/>
<path d="M70 12 A32 32 0 0 1 70 56"/>
</g>`;
}

function frame() {
  return `<rect width="${W}" height="${H}" fill="${C.bg}"/>
<circle cx="${W - 40}" cy="140" r="300" fill="${C.accent}" opacity="0.05"/>
<circle cx="40" cy="1560" r="300" fill="${C.accent}" opacity="0.04"/>`;
}

/** Brand + day marker. Kept at the very top, clear of the player chrome. */
function header(lang, day) {
  const ui = UI[lang];
  const family = familyFor(lang);
  return `${text('DELE VOCA DOJO', { x: W / 2, y: 132, size: 30, family: KR, fill: C.accent, spacing: 8 })}
${text(`${ui.series} · ${ui.day(day)}`, { x: W / 2, y: 208, size: 40, family, kind: 'regular', fill: C.muted, spacing: 2 })}`;
}

/** One pill per word, filled up to the word currently on screen. */
function progress(index, total) {
  const width = 110;
  const gap = 18;
  const totalWidth = total * width + (total - 1) * gap;
  let x = (W - totalWidth) / 2;
  const pills = [];
  for (let i = 0; i < total; i++) {
    pills.push(
      `<rect x="${x}" y="266" width="${width}" height="12" rx="6" fill="${i <= index ? C.accent : C.line}"/>`,
    );
    x += width + gap;
  }
  return pills.join('\n');
}

function levelBadge(level, y) {
  const w = measure(level, { family: KR, size: 34, weight: 700 }) + 56;
  return `<rect x="${(W - w) / 2}" y="${y}" width="${w}" height="58" rx="29" fill="${C.accentSoft}"/>
${text(level, { x: W / 2, y: y + 41, size: 34, family: KR, fill: C.accent, spacing: 2 })}`;
}

export function introScene({ lang, day, topicTitle, topicSubtitle, wordCount }) {
  const ui = UI[lang];
  const family = familyFor(lang);
  const title = block(topicTitle, {
    x: W / 2, y: 830, maxWidth: CONTENT_WIDTH, maxLines: 2, size: 88, minSize: 54, family,
  });
  const subtitle = block(topicSubtitle, {
    x: W / 2, y: 830 + title.height + 60, maxWidth: CONTENT_WIDTH - 40, maxLines: 3, size: 44,
    minSize: 32, family, kind: 'regular', fill: C.muted, lineHeight: 1.4,
  });

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
${frame()}
${text('DELE VOCA DOJO', { x: W / 2, y: 132, size: 30, family: KR, fill: C.accent, spacing: 8 })}
${text(ui.series, { x: W / 2, y: 480, size: 48, family, kind: 'regular', fill: C.muted, spacing: 4 })}
${text(ui.day(day), { x: W / 2, y: 680, size: 168, family: KR, fill: C.accent, spacing: 6 })}
${title.svg}
${subtitle.svg}
${pill(ui.wordsToday(wordCount), { y: 830 + title.height + subtitle.height + 130, family })}
</svg>`;
}

export function wordScene({ lang, day, word, index, total }) {
  const ui = UI[lang];
  const family = familyFor(lang);
  const term = block(word.term, {
    x: W / 2, y: 820, maxWidth: CONTENT_WIDTH, maxLines: 2, size: 148, minSize: 76,
    family: KR, fill: C.accent,
  });
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
${frame()}
${header(lang, day)}
${progress(index, total)}
${levelBadge(word.level, 560)}
${term.svg}
${speaker(W / 2, 1030, 0.9)}
${text(ui.prompt, { x: W / 2, y: 1240, size: 54, family, kind: 'regular', fill: C.muted })}
</svg>`;
}

export function meaningScene({ lang, day, word, index, total }) {
  const family = familyFor(lang);
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
${frame()}
${header(lang, day)}
${progress(index, total)}
${block(word.term, { x: W / 2, y: 720, maxWidth: CONTENT_WIDTH, maxLines: 1, size: 96, minSize: 56, family: KR, fill: C.accent }).svg}
<rect x="${W / 2 - 70}" y="800" width="140" height="8" rx="4" fill="${C.line}"/>
${block(word.meanings[lang], { x: W / 2, y: 990, maxWidth: CONTENT_WIDTH, maxLines: 3, size: 96, minSize: 52, family }).svg}
</svg>`;
}

export function exampleScene({ lang, day, word, index, total }) {
  const ui = UI[lang];
  const family = familyFor(lang);
  const sentence = block(word.example, {
    x: W / 2, y: 780, maxWidth: CONTENT_WIDTH, maxLines: 3, size: 66, minSize: 42,
    family: KR, lineHeight: 1.35,
  });
  const translation = block(word.exampleMeanings[lang], {
    x: W / 2, y: 780 + sentence.height + 90, maxWidth: CONTENT_WIDTH - 40, maxLines: 3, size: 48,
    minSize: 32, family, kind: 'regular', fill: C.muted, lineHeight: 1.4,
  });
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
${frame()}
${header(lang, day)}
${progress(index, total)}
${text(ui.example, { x: W / 2, y: 620, size: 40, family, kind: 'regular', fill: C.accent, spacing: 4 })}
${speaker(W / 2, 680, 0.5, C.accent)}
${sentence.svg}
${translation.svg}
</svg>`;
}

export function recapScene({ lang, day, words }) {
  const ui = UI[lang];
  const family = familyFor(lang);
  const top = 560;
  const rowHeight = 168;
  const rows = words
    .map((word, i) => {
      const y = top + i * rowHeight;
      const cardHeight = rowHeight - 24;
      const centerY = y + cardHeight / 2;
      const term = block(word.term, {
        x: 140, centerY, maxWidth: 380, maxLines: 1, size: 56, minSize: 34,
        family: KR, fill: C.accent, anchor: 'start',
      });
      const meaning = block(word.meanings[lang], {
        x: W - 140, centerY, maxWidth: 420, maxLines: 2, size: 44, minSize: 28,
        family, kind: 'regular', anchor: 'end', lineHeight: 1.2,
      });
      return `<rect x="90" y="${y}" width="${W - 180}" height="${cardHeight}" rx="28" fill="${C.card}"/>
${term.svg}
${meaning.svg}`;
    })
    .join('\n');

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
${frame()}
${header(lang, day)}
${text(ui.recap(words.length), { x: W / 2, y: 440, size: 68, family })}
${rows}
</svg>`;
}

/** The one screen per episode that is written, not generated. */
export function tipScene({ lang, day, headline, body }) {
  const family = familyFor(lang);
  const label = { ko: '오늘의 포인트', en: "Today's point", ja: '今日のポイント' }[lang];
  const head = block(headline, {
    x: W / 2, y: 700, maxWidth: CONTENT_WIDTH, maxLines: 2, size: 72, minSize: 48, family,
  });
  const text_ = block(body, {
    x: W / 2, y: 700 + head.height + 90, maxWidth: CONTENT_WIDTH - 30, maxLines: 6, size: 46,
    minSize: 34, family, kind: 'regular', fill: C.muted, lineHeight: 1.5,
  });
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
${frame()}
${header(lang, day)}
<rect x="${W / 2 - 4}" y="440" width="8" height="72" rx="4" fill="${C.accent}"/>
${text(label, { x: W / 2, y: 600, size: 42, family, fill: C.accent, spacing: 3 })}
${head.svg}
${text_.svg}
</svg>`;
}

export function ctaScene({ lang }) {
  const ui = UI[lang];
  const family = familyFor(lang);
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
${frame()}
<image href="${iconDataUri}" x="${W / 2 - 140}" y="420" width="280" height="280" />
${text('DELE Voca Dojo', { x: W / 2, y: 820, size: 78, family: KR })}
${block(ui.ctaHeadline, { x: W / 2, y: 930, maxWidth: CONTENT_WIDTH, maxLines: 2, size: 62, minSize: 40, family, fill: C.accent }).svg}
${block(ui.ctaSub, { x: W / 2, y: 1040, maxWidth: CONTENT_WIDTH, maxLines: 2, size: 42, minSize: 30, family, kind: 'regular', fill: C.muted }).svg}
${pill(ui.ctaLine, { y: 1160, family, size: 46 })}
</svg>`;
}
