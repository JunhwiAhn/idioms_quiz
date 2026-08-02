// Font registry + precise text measurement for the Shorts renderer.
//
// resvg has no text-layout API, so widths are measured by rendering a probe SVG
// and reading its bounding box. Results are cached because the same labels are
// laid out for every episode.

import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { Resvg } from '@resvg/resvg-js';

const here = path.dirname(fileURLToPath(import.meta.url));
const appFonts = path.resolve(here, '../../assets/fonts');
const localFonts = path.resolve(here, 'fonts');

export const KR = 'Noto Sans KR';
export const JP = 'Noto Sans JP';

/** Downloaded separately by fetch_fonts.js — see README. */
export const REQUIRED_LOCAL_FONTS = [
  'NotoSansKR-Bold.otf',
  'NotoSansKR-Medium.otf',
];

export function fontFiles() {
  const files = [
    path.join(localFonts, 'NotoSansKR-Bold.otf'),
    path.join(localFonts, 'NotoSansKR-Medium.otf'),
    path.join(appFonts, 'NotoSansJP-Regular.ttf'),
    path.join(appFonts, 'NotoSansJP-SemiBold.ttf'),
    path.join(appFonts, 'NotoSansJP-ExtraBold.ttf'),
  ];
  const missing = files.filter((file) => !existsSync(file));
  if (missing.length) {
    throw new Error(
      `Missing font files:\n  ${missing.join('\n  ')}\n` +
        'Run `node fetch_fonts.js` first.',
    );
  }
  return files;
}

export function resvgFontOptions() {
  return {
    fontFiles: fontFiles(),
    loadSystemFonts: false,
    defaultFontFamily: KR,
  };
}

/** Font family that actually carries glyphs for a given study language. */
export function familyFor(lang) {
  return lang === 'ja' ? JP : KR;
}

const cache = new Map();

export function measure(text, { family = KR, size = 48, weight = 700 } = {}) {
  if (!text) return 0;
  const key = `${family}|${size}|${weight}|${text}`;
  const hit = cache.get(key);
  if (hit !== undefined) return hit;

  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="4000" height="400">
<text x="20" y="200" font-family="${family}" font-size="${size}" font-weight="${weight}">${escapeXml(text)}</text>
</svg>`;
  const box = new Resvg(svg, { font: resvgFontOptions() }).getBBox();
  const width = box ? box.width : 0;
  cache.set(key, width);
  return width;
}

/**
 * Greedy word wrap. CJK text has no spaces, so it falls back to per-character
 * breaking when a single "word" is wider than the line box.
 */
export function wrap(text, maxWidth, style) {
  const tokens = String(text).split(/\s+/).filter(Boolean);
  const lines = [];
  let line = '';

  const push = () => {
    if (line) lines.push(line);
    line = '';
  };

  for (const token of tokens) {
    const candidate = line ? `${line} ${token}` : token;
    if (measure(candidate, style) <= maxWidth) {
      line = candidate;
      continue;
    }
    push();
    if (measure(token, style) <= maxWidth) {
      line = token;
      continue;
    }
    // Token alone overflows: break it character by character.
    for (const ch of token) {
      const next = line + ch;
      if (measure(next, style) <= maxWidth) line = next;
      else push(), (line = ch);
    }
  }
  push();
  return lines.length ? lines : [''];
}

/** Shrink font size until the text fits on `maxLines` lines within `maxWidth`. */
export function fitLines(text, { maxWidth, maxLines = 2, size, minSize, family, weight }) {
  let current = size;
  for (;;) {
    const style = { family, weight, size: current };
    const lines = wrap(text, maxWidth, style);
    if (lines.length <= maxLines || current <= minSize) {
      return { lines: lines.slice(0, Math.max(maxLines, 1)), size: current };
    }
    current -= 2;
  }
}

export function escapeXml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');
}
