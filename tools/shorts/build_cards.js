// 인스타그램 캐러셀 카드뉴스를 렌더링한다.
//
//   node build_cards.js
//
// 결과: out/cards/01.png ... 09.png + caption.txt

import { mkdirSync, writeFileSync, rmSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { Resvg } from '@resvg/resvg-js';

import { resvgFontOptions } from './fonts.js';
import { loadFalseFriends } from './false_friends.js';
import { theme } from './themes.js';
import { ctaCard } from './themed_cards.js';
import { coverCard, wordCard } from './cards.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.join(here, 'out', 'cards');

const STORE_URL =
  'https://play.google.com/store/apps/details?id=com.junhwiahn.spanishworddojo&referrer=utm_source%3Dinstagram';
const STORE_LABEL = 'Google Play → "DELE Voca Dojo" 검색';

const items = loadFalseFriends();
const total = items.length + 2; // 표지 + 단어 + CTA

if (existsSync(outDir)) rmSync(outDir, { recursive: true, force: true });
mkdirSync(outDir, { recursive: true });

const svgs = [
  coverCard({ total }),
  ...items.map((item, i) =>
    wordCard({ item, index: i + 1, page: i + 2, total }),
  ),
  ctaCard({ total, storeLabel: STORE_LABEL, t: theme('falseFriends') }),
];

svgs.forEach((svg, i) => {
  const file = path.join(outDir, `${String(i + 1).padStart(2, '0')}.png`);
  writeFileSync(file, new Resvg(svg, { font: resvgFontOptions() }).render().asPng());
  console.log(`  ${path.relative(here, file)}`);
});

const caption = `🇪🇸 영어인 줄 알았는데 뜻이 완전히 다른 스페인어 7개

스페인어 처음 시작하면 영어랑 닮은 단어에 먼저 눈이 가요 👀
근데 그중 몇 개는 뜻이 아예 달라요. 모르고 쓰면 곤란해지는 것만 모았어요 🥲

${items.map((item, i) => `${i + 1}. ${item.term} — ${item.meaning} (${item.looksLike} 아님!)`).join('\n')}

제일 조심해야 할 건 embarazada 예요 😳
"당황했어"라고 생각하고 쓰면 "저 임신했어요"가 됩니다...

저장해두고 헷갈릴 때마다 꺼내 보세요 📌

🥋 DELE Voca Dojo
스페인어 단어 1,250개를 스테이지·마라톤·오답노트로 반복 학습하는 앱이에요.
무료고 한국어·영어·일본어로 공부할 수 있어요 🇰🇷🇺🇸🇯🇵
👉 프로필 링크에서 설치 @spanish_dojo

#스페인어 #스페인어공부 #스페인어단어 #왕초보스페인어 #스페인어독학 #DELE #델레 #스페인어회화 #어학공부 #스페인어시험 #스페인유학 #외국어공부 #공부스타그램 #스페인어초보 #언어공부 #스페인여행 #여행스페인어 #스페인어기초`;

writeFileSync(path.join(outDir, 'caption.txt'), caption);
console.log(`  ${path.relative(here, path.join(outDir, 'caption.txt'))}`);
console.log(`\n카드 ${svgs.length}장 완료.`);
