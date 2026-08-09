// "여행가서 꼭 쓰는 스페인어" 인스타그램 캐러셀을 렌더링한다.
//
//   node build_travel_cards.js               # 표현 10장 (기본)
//   node build_travel_cards.js --with-cover  # 표지 + 표현 + CTA = 12장
//   node build_travel_cards.js --photo       # 사진 배경 (images/travel/)
//
// 인스타그램 캐러셀은 한 게시물에 10장까지만 올라간다. 그래서 기본값은
// 표지·CTA 없이 표현 카드만 내보내는 10장 구성이다. 12장 구성을 쓰려면
// 두 게시물로 나눠야 한다.
//
// 결과: out/travel/01.png ... + caption.txt

import { mkdirSync, writeFileSync, rmSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { Resvg } from '@resvg/resvg-js';

import { resvgFontOptions } from './fonts.js';
import { TRAVEL_PHRASES } from './travel_phrases.js';
import { findPhoto } from './card_photo.js';

const usePhoto = process.argv.includes('--photo');
const { travelCoverCard, phraseCard, travelCtaCard } = usePhoto
  ? await import('./travel_cards_photo.js')
  : await import('./travel_cards.js');

const here = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.join(here, 'out', 'travel');

const STORE_URL =
  'https://play.google.com/store/apps/details?id=com.junhwiahn.spanishworddojo&referrer=utm_source%3Dinstagram';
const STORE_LABEL = 'Google Play → "DELE Voca Dojo" 검색';

const withCover = process.argv.includes('--with-cover');
const items = TRAVEL_PHRASES;
const total = items.length + (withCover ? 2 : 0);

if (existsSync(outDir)) rmSync(outDir, { recursive: true, force: true });
mkdirSync(outDir, { recursive: true });

const svgs = [
  ...(withCover ? [travelCoverCard({ total, count: items.length })] : []),
  ...items.map((item, i) =>
    phraseCard({ item, index: i + 1, page: i + 1 + (withCover ? 1 : 0), total }),
  ),
  ...(withCover ? [travelCtaCard({ total, storeLabel: STORE_LABEL })] : []),
];

// 사진이 아직 없는 카드는 그라데이션으로 나간다. 조용히 넘어가면 "사진이 다
// 들어갔다"고 착각하게 되므로 빌드 때마다 빠진 걸 알려 준다.
const missing = !usePhoto
  ? []
  : [
      ...(withCover ? ['cover'] : []),
      ...items.map((item) => item.image),
      ...(withCover ? ['cta'] : []),
    ].filter((name) => !findPhoto(name));
if (missing.length) {
  console.log(`\n배경 사진 없음 (${missing.length}/${total}) — 그라데이션으로 대체:`);
  console.log(`  ${missing.join(', ')}`);
  console.log(`  images/travel/<이름>.jpg 를 넣고 다시 실행하면 반영됩니다.\n`);
}

svgs.forEach((svg, i) => {
  const file = path.join(outDir, `${String(i + 1).padStart(2, '0')}.png`);
  writeFileSync(file, new Resvg(svg, { font: resvgFontOptions() }).render().asPng());
  console.log(`  ${path.relative(here, file)}`);
});

const caption = `여행가서 꼭 쓰는 스페인어 ${items.length}개 🇪🇸✈️

스페인 여행에서 실제로 입 밖으로 나오는 말은 생각보다 몇 개 안 됩니다.
문법을 몰라도 이 ${items.length}개만 알면 인사, 주문, 길찾기, 계산까지 다 됩니다.

${items.map((item, i) => `${i + 1}. ${item.term} [${item.pron}] — ${item.meaning}`).join('\n')}

가장 활용도가 높은 건 ¿Dónde está...? 입니다.
뒤에 장소만 바꿔 끼우면 어디든 물어볼 수 있어요.

저장해두고 여행 갈 때 꺼내 보세요 📌

—
DELE A1~B1 단어 1,250개를 스테이지·마라톤·오답노트로 반복 학습하는 앱을 만들었습니다.
무료이고, 한국어·영어·일본어로 학습할 수 있어요.

👉 프로필 링크에서 설치 (@spanish_dojo)
${STORE_URL}

#스페인여행 #스페인어 #여행스페인어 #스페인어공부 #스페인어회화 #왕초보스페인어 #스페인어독학 #바르셀로나여행 #마드리드여행 #유럽여행 #여행준비 #스페인어단어 #어학공부 #DELE #공부스타그램`;

writeFileSync(path.join(outDir, 'caption.txt'), caption);
console.log(`  ${path.relative(here, path.join(outDir, 'caption.txt'))}`);
console.log(`\n카드 ${svgs.length}장 완료.`);
