// 카드 세트를 전부 렌더링하고 발행 캘린더를 만든다.
//
//   node build_sets.js                 # 전체
//   node build_sets.js restaurant      # 한 세트만
//
// 결과: out/sets/<id>/01.png ... 10.png + caption.txt
//       out/sets/SCHEDULE.md
//
// 인스타그램 캐러셀은 한 게시물에 10장까지다. 그래서 세트마다 표지 1 + 항목 9
// 로 맞춰 두었고, 항목이 9개가 아니면 빌드가 실패한다.

import { mkdirSync, writeFileSync, rmSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { Resvg } from '@resvg/resvg-js';

import { resvgFontOptions } from './fonts.js';
import { theme } from './themes.js';
import { coverCard, phraseCard } from './themed_cards.js';
import { SETS, RELEASE_ORDER } from './sets/index.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const outRoot = path.join(here, 'out', 'sets');

const MAX_SLIDES = 10; // 인스타그램 캐러셀 상한
const HANDLE = '@spanish_dojo';

/** 월·수·금 발행. 1편(여행)은 2026-08-03 에 이미 나갔다. */
const FIRST_SLOT = '2026-08-05';

const scheduleOnly = process.argv.includes('--schedule');
const only = scheduleOnly ? null : process.argv[2];
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

저장해두고 필요할 때 꺼내 보세요 📌

🥋 DELE Voca Dojo
스페인어 단어 1,250개를 스테이지·마라톤·오답노트로 반복 학습하는 앱이에요.
무료고 한국어·영어·일본어로 공부할 수 있어요 🇰🇷🇺🇸🇯🇵
👉 프로필 링크에서 설치 ${HANDLE}

${hashtags.map((tag) => `#${tag}`).join(' ')}`;
}

function renderSet(set) {
  const items = set.items;
  if (items.length !== MAX_SLIDES - 1) {
    throw new Error(
      `"${set.id}" 항목이 ${items.length}개입니다. 표지 1장을 더하면 ${items.length + 1}장이 되어 ` +
        `인스타 상한(${MAX_SLIDES})과 맞지 않습니다. 항목을 ${MAX_SLIDES - 1}개로 맞춰 주세요.`,
    );
  }

  const t = theme(set.theme);
  const total = items.length + 1;
  const dir = path.join(outRoot, set.id);

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
  console.log(`  ${set.id.padEnd(14)} ${svgs.length}장  ${path.relative(here, dir)}`);
}

/** FIRST_SLOT 부터 월·수·금 슬롯을 필요한 개수만큼 만든다. */
function slots(count) {
  const out = [];
  const day = new Date(`${FIRST_SLOT}T00:00:00Z`);
  while (out.length < count) {
    const weekday = day.getUTCDay(); // 1 월, 3 수, 5 금
    if (weekday === 1 || weekday === 3 || weekday === 5) {
      out.push(day.toISOString().slice(0, 10));
    }
    day.setUTCDate(day.getUTCDate() + 1);
  }
  return out;
}

function writeSchedule() {
  const byId = new Map(SETS.map((set) => [set.id, set]));
  const dates = slots(RELEASE_ORDER.length);
  const weekdayKo = ['일', '월', '화', '수', '목', '금', '토'];

  const rows = RELEASE_ORDER.map((entry, i) => {
    const set = byId.get(entry.id);
    const title = set ? set.title : '영어인 줄 알았는데 (false friends)';
    const dir = entry.out ?? `out/sets/${entry.id}`;
    const slides = set ? set.items.length + 1 : 9;
    const date = dates[i];
    const wd = weekdayKo[new Date(`${date}T00:00:00Z`).getUTCDay()];
    return `| ${date} (${wd}) | ${title} | ${slides}장 | \`${dir}\` |`;
  });

  const md = `# 발행 캘린더 — 월·수·금 20:00

1편 「여행가서 꼭 쓰는 스페인어 10개」는 2026-08-03(월)에 발행 완료.
아래는 그 다음 슬롯부터입니다.

| 날짜 | 세트 | 장수 | 파일 |
|---|---|---|---|
${rows.join('\n')}

## 올릴 때마다 확인할 것

1. **파일 10장을 넣고 첫 장이 표지인지 확인.** 드래그하면 *잡은 파일*이 1번
   슬라이드가 되기 때문에 순서가 자주 뒤집힙니다. 아니면 하단 썸네일 트레이에서
   표지를 맨 앞으로 끌어다 놓으면 됩니다.
2. 자르기 단계에서 **4:5** 로 변경. 기본값이 1:1 이라 그냥 두면 카드 위아래
   (번호·푸터)가 잘립니다.
3. 필터 없음(원본).
4. \`caption.txt\` 내용을 그대로 붙여넣기.

## 예약 발행

인스타그램 웹에는 예약 기능이 없습니다. Meta Business Suite
(business.facebook.com)에서 예약하려면 계정이 **프로페셔널(비즈니스/크리에이터)**
계정이어야 하고, 페이스북 페이지와 연결돼 있어야 합니다.
설정 → 계정 유형 및 도구 → 프로페셔널 계정으로 전환에서 바꿀 수 있습니다.

전환하면 Business Suite 에서 한 번에 여러 건을 걸어둘 수 있어, 위 표대로
2~3주치를 한 자리에서 예약할 수 있습니다.
`;

  writeFileSync(path.join(outRoot, 'SCHEDULE.md'), md);
  console.log(`\n  ${path.relative(here, path.join(outRoot, 'SCHEDULE.md'))}`);
}

mkdirSync(outRoot, { recursive: true });
if (scheduleOnly) {
  writeSchedule();
} else {
  targets.forEach(renderSet);
  if (!only) writeSchedule();
  console.log(`\n세트 ${targets.length}개 완료.`);
}
