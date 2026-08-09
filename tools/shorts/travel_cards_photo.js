// "여행가서 꼭 쓰는 스페인어" 세트의 카드 레이아웃 — 사진 배경형.
//
// 표현 하나를 보여주는 구조라 대비(오해/실제)가 없고, 표현 → 발음 → 뜻 → 예문 →
// 한 줄 해설의 세로 흐름으로 고정한다. 카드마다 요소 위치가 같아야 캐러셀을
// 넘길 때 눈이 흔들리지 않는다.
//
// 배경 사진은 images/travel/ 에서 찾고, 없으면 브랜드 색 그라데이션으로
// 대체된다(card_photo.js). 사진 유무와 무관하게 레이아웃은 동일하다.

import { KR, measure } from './fonts.js';
import { CW, CH, M, INNER, C, text, block, iconDataUri } from './card_base.js';
import { P, photoBackground, glass } from './card_photo.js';

/** 흰 글자용 푸터. 캐러셀 내내 같은 자리에 고정. */
function footer(page, total) {
  return `${text('DELE Voca Dojo', { x: M, y: CH - 60, size: 32, fill: P.text, anchor: 'start', spacing: 1 })}
${text(`${page} / ${total}`, { x: CW - M, y: CH - 60, size: 32, weight: 500, fill: P.muted, anchor: 'end' })}`;
}

/** 스와이프 유도 화살표. 1장에서 이탈하는 걸 막는 장치. */
function swipeHint() {
  const y = CH - 150;
  return `<g opacity="0.92">
${text('넘겨서 확인하기', { x: CW / 2 - 30, y, size: 34, weight: 500, fill: P.soft })}
<path d="M${CW / 2 + 84} ${y - 14} l 22 12 l -22 12" fill="none" stroke="${P.accent}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>
</g>`;
}

/** 가운데 정렬 유리 배지. 글자 폭을 재서 좌우 패딩을 맞춘다. */
function glassPill(content, { cx, top, height = 84, size = 40, weight = 700, fill = P.text, padding = 44 }) {
  const width = measure(content, { family: KR, size, weight }) + padding * 2;
  return `${glass(cx - width / 2, top, width, height, { radius: height / 2, opacity: 0.18 })}
${text(content, { x: cx, y: top + height / 2 + size * 0.36, size, weight, fill })}`;
}

export function travelCoverCard({ total, count }) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}" viewBox="0 0 ${CW} ${CH}">
${photoBackground('cover', { tone: 'dark' })}
${text('여행 스페인어', { x: CW / 2, y: 300, size: 40, weight: 500, fill: P.soft, spacing: 6 })}
<rect x="${CW / 2 - 40}" y="340" width="80" height="8" rx="4" fill="${P.accent}"/>
${block('여행가서', { x: CW / 2, y: 480, maxWidth: INNER, maxLines: 1, size: 92, minSize: 60, fill: P.soft }).svg}
${block('꼭 쓰는 표현', { x: CW / 2, y: 610, maxWidth: INNER, maxLines: 1, size: 100, minSize: 64, fill: P.text }).svg}
${block(`스페인어 ${count}개`, { x: CW / 2, y: 740, maxWidth: INNER, maxLines: 1, size: 110, minSize: 70, fill: P.accent }).svg}
${glassPill('이것만 알아도 스페인 여행 걱정 끝', { cx: CW / 2, top: 860, height: 96, size: 38 })}
${swipeHint()}
${footer(1, total)}
</svg>`;
}

export function phraseCard({ item, index, page, total }) {
  const term = block(item.term, {
    x: CW / 2, y: 400, maxWidth: INNER, maxLines: 1, size: 112, minSize: 56, fill: P.text,
  });

  const meaning = block(item.meaning, {
    x: CW / 2, y: 700, maxWidth: INNER - 40, maxLines: 2, size: 82, minSize: 46, fill: P.text,
  });

  // 예문 패널은 뜻 아래에서 시작하되, 뜻이 두 줄이 되면 그만큼 밀린다.
  const panelTop = 700 + meaning.height + 60;
  const example = block(item.example, {
    x: CW / 2, y: panelTop + 88, maxWidth: INNER - 100, maxLines: 1, size: 50, minSize: 34, fill: P.accent,
  });
  const exampleKo = block(item.exampleKo, {
    x: CW / 2, y: panelTop + 160, maxWidth: INNER - 100, maxLines: 1, size: 38, minSize: 26,
    weight: 500, fill: P.soft,
  });

  const badgeW = measure(item.tag, { family: KR, size: 30, weight: 700 }) + 48;

  return `<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}" viewBox="0 0 ${CW} ${CH}">
${photoBackground(item.image, { tone: 'dark' })}
<g opacity="0.45">${text(`${index}`, { x: M, y: 190, size: 76, fill: P.text, anchor: 'start' })}</g>
${glass(CW - M - badgeW, 146, badgeW, 52, { radius: 26, opacity: 0.2 })}
${text(item.tag, { x: CW - M - badgeW / 2, y: 184, size: 30, fill: P.text })}

${term.svg}
${glassPill(`[ ${item.pron} ]`, { cx: CW / 2, top: 452, height: 84, size: 40, fill: P.accent })}

<rect x="${CW / 2 - 40}" y="590" width="80" height="6" rx="3" fill="${P.text}" fill-opacity="0.5"/>
${meaning.svg}

${glass(M, panelTop, INNER, 200)}
${example.svg}
${exampleKo.svg}

${block(item.tip, {
    x: CW / 2, y: 1160, maxWidth: INNER - 20, maxLines: 2, size: 38, minSize: 28,
    weight: 500, fill: P.soft, lineHeight: 1.35,
  }).svg}
${footer(page, total)}
</svg>`;
}

export function travelCtaCard({ total, storeLabel }) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${CW}" height="${CH}" viewBox="0 0 ${CW} ${CH}">
${photoBackground('cta', { tone: 'dark' })}
<image href="${iconDataUri}" x="${CW / 2 - 130}" y="230" width="260" height="260"/>
${text('DELE Voca Dojo', { x: CW / 2, y: 580, size: 72, fill: P.text })}
${block('스페인어 단어 1,250개', { x: CW / 2, y: 672, maxWidth: INNER, maxLines: 1, size: 54, minSize: 36, fill: P.accent }).svg}
${block('스테이지 · 마라톤 · 오답노트로 반복 학습', { x: CW / 2, y: 748, maxWidth: INNER, maxLines: 1, size: 42, minSize: 30, weight: 500, fill: P.soft }).svg}

<rect x="${M}" y="860" width="${INNER}" height="120" rx="60" fill="${C.accent}"/>
${text('Google Play 에서 무료 설치', { x: CW / 2, y: 936, size: 46, fill: '#FFFFFF' })}
${text(storeLabel, { x: CW / 2, y: 1046, size: 36, weight: 500, fill: P.soft })}
${text('프로필 링크에서 바로 이동', { x: CW / 2, y: 1108, size: 38, fill: P.accent })}
${footer(total, total)}
</svg>`;
}
