// 영어판 카드 세트를 렌더링하고 썸네일 제작 의뢰서를 만든다.
//
//   node build_sets_en.js                # 10세트 전부
//   node build_sets_en.js restaurant     # 한 세트만
//
// 결과: out/sets-en/<id>/01.png ... 10.png + caption.txt
//       out/sets-en/THUMBNAILS.md   (썸네일 사양서)
//       out/sets-en/SCHEDULE.md     (발행 순서)
//
// 레이아웃·테마는 한국어판과 같은 것을 쓴다 (themed_cards.js / themes.js).
// 바뀌는 건 데이터뿐이라 한쪽 레이아웃을 고치면 양쪽에 같이 반영된다.

import { mkdirSync, writeFileSync, rmSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { Resvg } from '@resvg/resvg-js';

import { resvgFontOptions } from './fonts.js';
import { theme, THEMES } from './themes.js';
import { coverCard, phraseCard } from './themed_cards.js';
import { SETS, RELEASE_ORDER } from './sets/en/index.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const outRoot = path.join(here, 'out', 'sets-en');

const MAX_SLIDES = 10; // 인스타그램 캐러셀 상한
const HANDLE = '@spanish_dojo';

// 표지 문구만 고쳤을 때 100장을 다시 굽지 않기 위한 스위치.
const coversOnly = process.argv.includes('--covers');
const only = coversOnly ? null : process.argv[2];
const targets = only ? SETS.filter((s) => s.id === only) : SETS;
if (only && !targets.length) {
  console.error(`"${only}" 세트가 없습니다. 가능한 값: ${SETS.map((s) => s.id).join(', ')}`);
  process.exit(1);
}

function buildCaption(set) {
  const { headline, intro, highlight, hashtags } = set.caption;
  const list = set.items
    .map((item, i) => `${i + 1}. ${item.term} [${item.pron}] — ${item.meaning} ${item.emoji}`)
    .join('\n');

  return `${headline}

${intro.join('\n')}

${list}

${highlight.join('\n')}

Save this one — you will want it later 📌

🥋 DELE Voca Dojo
A free app to drill 1,250 Spanish words with stages, marathon mode and a mistake notebook.
Available in English, Korean and Japanese 🇺🇸🇰🇷🇯🇵
👉 Link in bio ${HANDLE}

${hashtags.map((tag) => `#${tag}`).join(' ')}`;
}

function renderSet(set) {
  const items = set.items;
  if (items.length !== MAX_SLIDES - 1) {
    throw new Error(
      `"${set.id}" has ${items.length} items; with the cover that is ${items.length + 1} slides, ` +
        `which does not fit Instagram's limit of ${MAX_SLIDES}. Use ${MAX_SLIDES - 1} items.`,
    );
  }

  const t = theme(set.theme);
  const total = items.length + 1;
  const dir = path.join(outRoot, set.id);

  if (coversOnly) {
    mkdirSync(dir, { recursive: true });
    const svg = coverCard({ set, t, total });
    writeFileSync(path.join(dir, '01.png'), new Resvg(svg, { font: resvgFontOptions() }).render().asPng());
    console.log(`  ${set.id.padEnd(15)} cover only  ${path.relative(here, dir)}`);
    return;
  }

  if (existsSync(dir)) rmSync(dir, { recursive: true, force: true });
  mkdirSync(dir, { recursive: true });

  const svgs = [
    coverCard({ set, t, total }),
    ...items.map((item, i) => phraseCard({ item, index: i + 1, page: i + 2, total, t })),
  ];

  svgs.forEach((svg, i) => {
    const file = path.join(dir, `${String(i + 1).padStart(2, '0')}.png`);
    writeFileSync(file, new Resvg(svg, { font: resvgFontOptions() }).render().asPng());
  });

  writeFileSync(path.join(dir, 'caption.txt'), buildCaption(set));
  console.log(`  ${set.id.padEnd(15)} ${svgs.length} slides  ${path.relative(here, dir)}`);
}

/**
 * 썸네일 의뢰서. 01.png(표지)는 코드가 이미 만들지만, 직접 디자인한 썸네일로
 * 갈아 끼울 수 있게 세트별 사양을 뽑아 둔다. 문구는 표지 카드와 같은 것을
 * 쓰고, 색은 themes.js 값을 그대로 옮긴다 — 손으로 옮겨 적으면 어긋난다.
 */
function writeThumbnailBrief() {
  const byId = new Map(SETS.map((set) => [set.id, set]));

  const blocks = RELEASE_ORDER.map((id, i) => {
    const set = byId.get(id);
    const t = THEMES[set.theme];
    const { eyebrow, line1, line2, accentLine, pill } = set.cover;
    return `### ${i + 1}. ${set.title}  \`${set.id}\`

- **Replaces**: \`out/sets-en/${set.id}/01.png\`
- **Colors**: accent \`${t.accent}\` · background \`${t.bg}\` · soft \`${t.accentSoft}\`
- **Eyebrow** (small, muted, letter-spaced): \`${eyebrow}\`
- **Headline line 1** (muted): \`${line1}\`
- **Headline line 2** (dark): \`${line2}\`
- **Headline line 3** (accent, biggest): \`${accentLine}\`
- **Pill / subtitle**: \`${pill}\`
- **Visual idea**: ${set.thumbnailHint ?? '—'}`;
  }).join('\n\n');

  const md = `# Thumbnail brief — English card sets

카드 10장은 코드가 만들고, **표지(1번 슬라이드)만 직접 디자인한 것으로 교체**할 수 있습니다.
아래 사양대로 만들어서 각 세트 폴더의 \`01.png\` 를 덮어쓰면 됩니다.

## 공통 규격

| 항목 | 값 |
|---|---|
| 크기 | **1080 × 1350 px** (4:5). 인스타 피드에서 가장 크게 잡히는 비율 |
| 파일 | \`01.png\` — 각 세트 폴더에 덮어쓰기 |
| 안전 영역 | 상하 각 **120px** 는 비워 두기. 인스타 UI와 그리드 크롭에 잘립니다 |
| 폰트 | Noto Sans KR Bold / Medium (영문도 이 폰트로 통일해야 시리즈가 맞습니다) |
| 브랜드 | 좌하단 \`DELE Voca Dojo\`, 우하단 \`1 / 10\` |
| 금지 | 이모지 삽입 금지 — 번들 폰트에 없어 두부(□)로 렌더됩니다 |

프로필 그리드에서 10개가 한 줄로 보였을 때 **색만 다르고 구조는 같아야** 시리즈로 읽힙니다.
구조를 바꾸려면 10개 전부 같이 바꾸세요.

## 세트별 사양

${blocks}

## 유튜브로 재활용할 경우

같은 문구로 **1280 × 720 (16:9)** 을 따로 뽑아야 합니다. 4:5 를 잘라 쓰면 헤드라인이 잘립니다.
가로형은 왼쪽 절반을 문구, 오른쪽 절반을 이미지로 쓰는 편이 클릭률에 유리합니다.
`;

  writeFileSync(path.join(outRoot, 'THUMBNAILS.md'), md);
  console.log(`\n  ${path.relative(here, path.join(outRoot, 'THUMBNAILS.md'))}`);
}

function writeSchedule() {
  const byId = new Map(SETS.map((set) => [set.id, set]));
  const rows = RELEASE_ORDER.map((id, i) => {
    const set = byId.get(id);
    return `| ${i + 1} | ${set.title} | \`out/sets-en/${set.id}\` | ${set.theme} |`;
  });

  const md = `# English sets — release order

한국어 계정과 별개로 운영할 경우의 순서입니다. 후킹형(false friends / cognates)을
앞에 두고 레퍼런스형과 번갈아 배치했습니다.

| # | Set | Folder | Theme |
|---|---|---|---|
${rows.join('\n')}

각 폴더에 \`01.png ~ 10.png\` 와 \`caption.txt\` 가 있습니다.
올릴 때는 **4:5 크롭**과 **첫 장이 표지인지**를 매번 확인하세요.
`;

  writeFileSync(path.join(outRoot, 'SCHEDULE.md'), md);
  console.log(`  ${path.relative(here, path.join(outRoot, 'SCHEDULE.md'))}`);
}

mkdirSync(outRoot, { recursive: true });
targets.forEach(renderSet);
if (!only) {
  writeThumbnailBrief();
  writeSchedule();
}
console.log(`\n${targets.length} sets done.`);
