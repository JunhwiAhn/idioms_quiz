// 사진 배경 카드용 부품.
//
// 사진 위에 글자를 얹으면 사진이 조금만 밝아도 글이 안 읽힌다. 그래서 사진은
// 항상 스크림(어두운 그라데이션) 아래에 깔고, 글자는 흰색으로 고정한다.
//
// 사진 파일이 없으면 브랜드 색 그라데이션으로 자동 대체된다. images/README.md 와
// 같은 규칙이라, 사진을 만드는 대로 한 장씩 넣어도 빌드가 깨지지 않는다.

import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { CW, CH } from './card_base.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const photoDir = path.join(here, 'images', 'travel');

/** 흰 글자용 팔레트. card_base 의 C 는 밝은 배경 기준이라 여기선 못 쓴다. */
export const P = {
  text: '#FFFFFF',
  soft: '#F3E4D8',
  muted: '#D9C4B4',
  accent: '#FFC9A8',
  glass: '#FFFFFF',
};

function dataUri(file) {
  const ext = path.extname(file).toLowerCase();
  const mime = ext === '.png' ? 'image/png' : 'image/jpeg';
  return `data:${mime};base64,${readFileSync(file).toString('base64')}`;
}

/** name 에 해당하는 사진을 찾는다. .jpg / .jpeg / .png 순으로 본다. */
export function findPhoto(name) {
  for (const ext of ['.jpg', '.jpeg', '.png']) {
    const file = path.join(photoDir, name + ext);
    if (existsSync(file)) return file;
  }
  return null;
}

/**
 * 배경 + 스크림. 사진이 없으면 그라데이션만 깐다.
 * tone: 'dark' 는 아래쪽을 더 눌러 본문이 많은 카드에 쓴다.
 */
export function photoBackground(name, { tone = 'dark' } = {}) {
  const file = findPhoto(name);
  const id = `bg_${name.replace(/[^a-z0-9]/gi, '')}`;

  const fallback = `<defs>
<linearGradient id="${id}_f" x1="0" y1="0" x2="0.4" y2="1">
<stop offset="0" stop-color="#8C3416"/>
<stop offset="0.55" stop-color="#5E2415"/>
<stop offset="1" stop-color="#2E2018"/>
</linearGradient>
<radialGradient id="${id}_g" cx="0.75" cy="0.15" r="0.75">
<stop offset="0" stop-color="#E4753F" stop-opacity="0.55"/>
<stop offset="1" stop-color="#E4753F" stop-opacity="0"/>
</radialGradient>
</defs>
<rect width="${CW}" height="${CH}" fill="url(#${id}_f)"/>
<rect width="${CW}" height="${CH}" fill="url(#${id}_g)"/>`;

  const photo = file
    ? `<image href="${dataUri(file)}" x="0" y="0" width="${CW}" height="${CH}" preserveAspectRatio="xMidYMid slice"/>`
    : '';

  // 위/아래를 눌러 헤더(번호·배지)와 하단 해설·푸터를 확보한다.
  const top = tone === 'dark' ? 0.55 : 0.4;
  const bottom = tone === 'dark' ? 0.88 : 0.75;

  const scrim = `<defs>
<linearGradient id="${id}_s" x1="0" y1="0" x2="0" y2="1">
<stop offset="0" stop-color="#241309" stop-opacity="${top}"/>
<stop offset="0.32" stop-color="#241309" stop-opacity="0.34"/>
<stop offset="0.62" stop-color="#241309" stop-opacity="0.6"/>
<stop offset="1" stop-color="#241309" stop-opacity="${bottom}"/>
</linearGradient>
</defs>
<rect width="${CW}" height="${CH}" fill="url(#${id}_s)"/>`;

  return `${file ? photo : fallback}\n${scrim}`;
}

/** 사진 위 반투명 유리 패널. */
export function glass(x, y, width, height, { radius = 32, opacity = 0.16, stroke = 0.28 } = {}) {
  return `<rect x="${x}" y="${y}" width="${width}" height="${height}" rx="${radius}" fill="${P.glass}" fill-opacity="${opacity}" stroke="${P.glass}" stroke-opacity="${stroke}" stroke-width="2"/>`;
}
