// 완성 영상을 미국·영어권 대상 앱 프로모션 버전으로 다시 굽는다.
//
//   node build_promo.js ep06-restaurante
//
// 학습용 완성본(out.mp4)과 다른 점 세 가지:
//   1. 영어 번역을 화면에 굽는다. 프로모는 CC를 켜 줄 거라 기대할 수 없다.
//   2. 앞 3초에 훅을 얹는다. 스크롤을 멈춰 세우는 건 첫 컷이 아니라 첫 문장이다.
//   3. 끝에 앱 카드 4초를 붙인다. 44초라 쇼츠 60초 제한 안에 들어간다.
//
// 앱 이름·태그라인은 docs/store_listing.md 의 en-US 등록정보에서 가져온 값이다.
// 스토어 배지나 URL은 넣지 않는다 — 게시 상태를 확인할 수 없는 걸 화면에
// 적으면 그건 광고가 아니라 거짓말이 된다.

import { readFileSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const HERE = dirname(fileURLToPath(import.meta.url));
const require_ = createRequire(join(HERE, '../package.json'));
const ffmpeg = require_('ffmpeg-static');
const { Resvg } = require_('@resvg/resvg-js');

const id = process.argv[2] || 'ep06-restaurante';
const dir = join(HERE, id);
const ep = JSON.parse(readFileSync(join(dir, 'episode.json'), 'utf8'));

const W = 1080, H = 1920, FPS = 24, CARD_SEC = 4;
const FONTS = resolve(HERE, '../fonts');

// 앱과 같은 색. 영상·카드뉴스·앱이 한 팔레트를 쓰는 게 이 시리즈의 브랜딩이다.
const C = { bg: '#FFFBF2', accent: '#C44720', ink: '#2E2018', muted: '#8A7566', line: '#EADCCB' };

const APP = {
  name: 'Spanish Words: Travel & DELE',
  tagline: '1,250+ words up to DELE B1',
  cta: 'Learn these phrases in the app',
};

const HOOK = ['Order a full meal in Spain', '6 phrases. 40 seconds.'];

// ── 엔드카드 ────────────────────────────────────────────────────────────────
const icon = readFileSync(resolve(HERE, '../../../assets/images/app_icon.png')).toString('base64');
const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

const keyPhrases = ep.shots
  .flatMap((s) => (s.lines ?? []).filter((l) => l.highlight))
  .map((l) => l.es);

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
<rect width="${W}" height="${H}" fill="${C.bg}"/>
<circle cx="${W - 40}" cy="180" r="300" fill="${C.accent}" opacity="0.06"/>
<circle cx="60" cy="${H - 160}" r="260" fill="${C.accent}" opacity="0.05"/>

<text x="${W / 2}" y="470" font-family="Noto Sans KR" font-size="40" font-weight="700"
      fill="${C.accent}" text-anchor="middle" letter-spacing="4">YOU JUST LEARNED</text>

${keyPhrases
  .map(
    (p, i) =>
      `<text x="${W / 2}" y="${560 + i * 62}" font-family="Noto Sans KR" font-size="42" font-weight="700" fill="${C.ink}" text-anchor="middle">${esc(p)}</text>`,
  )
  .join('\n')}

<line x1="240" y1="${560 + keyPhrases.length * 62 + 20}" x2="${W - 240}" y2="${560 + keyPhrases.length * 62 + 20}" stroke="${C.line}" stroke-width="3"/>

<image x="${(W - 240) / 2}" y="1090" width="240" height="240" href="data:image/png;base64,${icon}"/>

<text x="${W / 2}" y="1420" font-family="Noto Sans KR" font-size="56" font-weight="700"
      fill="${C.ink}" text-anchor="middle">${esc(APP.name)}</text>
<text x="${W / 2}" y="1482" font-family="Noto Sans KR" font-size="38" font-weight="500"
      fill="${C.muted}" text-anchor="middle">${esc(APP.tagline)}</text>

<rect x="${(W - 640) / 2}" y="1540" width="640" height="92" rx="46" fill="${C.accent}"/>
<text x="${W / 2}" y="1599" font-family="Noto Sans KR" font-size="38" font-weight="700"
      fill="${C.bg}" text-anchor="middle">${esc(APP.cta)}</text>
</svg>`;

writeFileSync(
  join(dir, 'endcard.png'),
  new Resvg(svg, { font: { fontDirs: [FONTS], defaultFontFamily: 'Noto Sans KR', loadSystemFonts: false } })
    .render()
    .asPng(),
);

// ── 자막 (스페인어 + 영어, 훅 포함) ─────────────────────────────────────────
const bgr = (hex) => `&H00${hex.slice(5, 7)}${hex.slice(3, 5)}${hex.slice(1, 3)}`;
const CREAM = bgr(C.bg), ACCENT = bgr(C.accent), INK = bgr(C.ink);

const t = (sec) => {
  const m = Math.floor(sec / 60);
  const s = (sec % 60).toFixed(2).padStart(5, '0');
  return `0:${String(m).padStart(2, '0')}:${s}`;
};

const ass = [`[Script Info]
ScriptType: v4.00+
PlayResX: ${W}
PlayResY: ${H}
WrapStyle: 2
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: HOOK,Noto Sans KR,72,${CREAM},${INK},${INK},1,0,0,0,100,100,0,0,1,9,3,5,50,50,0,1
Style: ES,Noto Sans KR,62,${CREAM},${INK},${INK},1,0,0,0,100,100,0,0,1,7,3,5,60,60,0,1
Style: KEY,Noto Sans KR,74,${ACCENT},${INK},${INK},1,0,0,0,100,100,0,0,1,9,3,5,60,60,0,1
Style: EN,Noto Sans KR,44,${CREAM},${INK},${INK},0,0,0,0,100,100,0,0,1,5,2,5,60,60,0,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
`];

const cue = (from, to, style, y, text) =>
  ass.push(`Dialogue: 0,${t(from)},${t(to)},${style},,0,0,0,,{\\pos(${W / 2},${y})}${text}`);

HOOK.forEach((h, i) => cue(0.2, 3.2, 'HOOK', 400 + i * 88, h));

for (const s of ep.shots) {
  const lines = s.lines ?? [];
  const slot = (s.dur - 0.3) / Math.max(lines.length, 1);
  lines.forEach((l, k) => {
    const from = s.start + 0.15 + k * slot;
    const to = from + slot;
    cue(from, to, l.highlight ? 'KEY' : 'ES', l.highlight ? 1222 : 1230, l.es);
    if (l.sub?.en) cue(from, to, 'EN', 1340, l.sub.en);
  });
}

writeFileSync(join(dir, 'subs.promo.ass'), ass.join('\n') + '\n');

// ── 굽기 ────────────────────────────────────────────────────────────────────
const run = (args) => execFileSync(ffmpeg, args, { cwd: dir, stdio: ['ignore', 'ignore', 'inherit'] });

writeFileSync(
  join(dir, 'list.txt'),
  ep.shots.map((s) => `file 'clips/${String(s.n).padStart(2, '0')}.mp4'`).join('\n') + '\n',
);

// 본편: 클립 + TTS + 자막
const slots = [];
for (const s of ep.shots) {
  const lines = s.lines ?? [];
  const slot = (s.dur - 0.3) / Math.max(lines.length, 1);
  lines.forEach((_, k) => slots.push({ shot: s.n, k, from: s.start + 0.15 + k * slot }));
}

const args = ['-y', '-f', 'concat', '-safe', '0', '-i', 'list.txt'];
for (const a of slots) args.push('-i', `audio/${String(a.shot).padStart(2, '0')}-${a.k + 1}.mp3`);

const filters = [`[0:v]scale=${W}:${H},ass=subs.promo.ass:fontsdir=../../fonts[v]`];
slots.forEach((a, i) => {
  const ms = Math.round(a.from * 1000);
  filters.push(`[${i + 1}:a]adelay=${ms}|${ms},volume=1.3[a${i}]`);
});
filters.push(
  `${slots.map((_, i) => `[a${i}]`).join('')}amix=inputs=${slots.length}:normalize=0:dropout_transition=0,` +
    `alimiter=limit=0.92,aresample=48000[a]`,
);

run([...args, '-filter_complex', filters.join(';'), '-map', '[v]', '-map', '[a]',
  '-c:a', 'aac', '-b:a', '160k', '-c:v', 'libx264', '-preset', 'medium', '-crf', '20',
  '-pix_fmt', 'yuv420p', '-r', String(FPS), 'body.mp4']);

// 엔드카드: 무음 4초. 본편과 코덱·해상도·프레임레이트를 맞춰야 concat 이 붙는다.
run(['-y', '-loop', '1', '-t', String(CARD_SEC), '-i', 'endcard.png',
  '-f', 'lavfi', '-t', String(CARD_SEC), '-i', 'anullsrc=r=48000:cl=mono',
  '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-pix_fmt', 'yuv420p',
  '-r', String(FPS), '-c:a', 'aac', '-b:a', '160k', '-shortest', 'endcard.mp4']);

writeFileSync(join(dir, 'promo_list.txt'), "file 'body.mp4'\nfile 'endcard.mp4'\n");
run(['-y', '-f', 'concat', '-safe', '0', '-i', 'promo_list.txt', '-c', 'copy', 'promo.en.mp4']);

console.log(`${id}/promo.en.mp4  (본편 ${ep.shots.length * 5}초 + 엔드카드 ${CARD_SEC}초)`);
