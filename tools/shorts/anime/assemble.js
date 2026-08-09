// clips/01..08.mp4 을 이어 붙이고, TTS 음성을 얹고, 자막을 구워서 완성본을 만든다.
//
//   node assemble.js ep06-restaurante          # 스페인어 자막만  → out.mp4
//   node assemble.js ep06-restaurante ko       # 스페인어 + 한국어 → out.ko.mp4
//
// 기본이 스페인어 자막 단독인 이유: 이 시리즈는 스페인 사람들의 대화를 그대로
// 따라가는 게 목적이라, 번역이 붙으면 눈이 번역으로 먼저 간다. 번역판은
// 필요할 때 두 번째 인자로 따로 굽는다. 영상은 다시 만들지 않는다.
//
// 자막은 SRT가 아니라 ASS다. 스페인어 줄과 번역 줄의 크기·색이 달라야 하는데
// SRT로는 줄마다 스타일을 못 준다.

import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const HERE = dirname(fileURLToPath(import.meta.url));
const ffmpeg = createRequire(join(HERE, '../package.json'))('ffmpeg-static');

const id = process.argv[2] || 'ep06-restaurante';
const lang = process.argv[3] || null; // null 이면 스페인어 자막만
const dir = join(HERE, id);
const ep = JSON.parse(readFileSync(join(dir, 'episode.json'), 'utf8'));

const W = 1080, H = 1920, FPS = 24;

/** #RRGGBB → ASS의 &H00BBGGRR. ASS는 BGR 순서다. */
const bgr = (hex) => `&H00${hex.slice(5, 7)}${hex.slice(3, 5)}${hex.slice(1, 3)}`;
const CREAM = bgr('#FFFBF2');
const ACCENT = bgr('#C44720');
const INK = bgr('#2E2018');

// 자막은 안전 영역(y=260~1440) 안에 둔다. Shorts 플레이어가 하단 약 450px를 가린다.
// 번역이 없을 때는 스페인어 한 줄만 남으므로 조금 내려 잡는다.
const Y_ES = lang ? 1230 : 1300;
const Y_TR = 1340;

const t = (sec) => {
  const h = Math.floor(sec / 3600);
  const m = Math.floor((sec % 3600) / 60);
  const s = (sec % 60).toFixed(2).padStart(5, '0');
  return `${h}:${String(m).padStart(2, '0')}:${s}`;
};

const head = `[Script Info]
ScriptType: v4.00+
PlayResX: ${W}
PlayResY: ${H}
WrapStyle: 2
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: ES,Noto Sans KR,66,${CREAM},${INK},${INK},1,0,0,0,100,100,0,0,1,7,3,5,60,60,0,1
Style: KEY,Noto Sans KR,80,${ACCENT},${INK},${INK},1,0,0,0,100,100,0,0,1,9,3,5,60,60,0,1
Style: TR,Noto Sans KR,42,${CREAM},${INK},${INK},0,0,0,0,100,100,0,0,1,5,2,5,60,60,0,1
Style: NOTE,Noto Sans KR,38,${CREAM},${INK},${INK},0,0,0,0,100,100,0,0,1,5,2,5,60,60,0,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
`;

const ev = [];
const cue = (from, to, style, y, text) =>
  ev.push(`Dialogue: 0,${t(from)},${t(to)},${style},,0,0,0,,{\\pos(${W / 2},${y})}${text}`);

/** 대사 하나가 차지하는 구간. 자막과 음성이 같은 값을 써야 입과 글자가 안 어긋난다. */
const slots = [];
for (const s of ep.shots) {
  const lines = s.lines ?? [];
  const slot = (s.dur - 0.3) / Math.max(lines.length, 1);
  lines.forEach((l, k) => {
    const from = s.start + 0.15 + k * slot;
    slots.push({ shot: s.n, k, from, to: from + slot, line: l });
  });
  if (lang && s.note?.[lang]) {
    cue(s.start + 0.15, s.start + s.dur - 0.15, 'NOTE', Y_TR + 70, s.note[lang]);
  }
}

for (const { from, to, line } of slots) {
  cue(from, to, line.highlight ? 'KEY' : 'ES', line.highlight ? Y_ES - 8 : Y_ES, line.es);
  if (lang && line.sub?.[lang]) cue(from, to, 'TR', Y_TR, line.sub[lang]);
}

const assName = `subs${lang ? '.' + lang : ''}.ass`;
writeFileSync(join(dir, assName), head + ev.join('\n') + '\n');

// concat 목록은 상대 경로로 적는다. 절대 경로를 쓰면 드라이브 문자(C:)가
// ffmpeg 필터 문법의 구분자로 잘못 파싱된다.
writeFileSync(
  join(dir, 'list.txt'),
  ep.shots.map((s) => `file 'clips/${String(s.n).padStart(2, '0')}.mp4'`).join('\n') + '\n',
);

// ── 오디오 ───────────────────────────────────────────────────────────────────
// 클립 자체의 오디오는 버린다. 생성 모델이 넣은 웅얼거림이 스페인어 위에
// 겹치면 학습용으로 못 쓴다. 소리는 TTS만 남긴다.
const audio = slots
  .map((s) => ({ ...s, file: `audio/${String(s.shot).padStart(2, '0')}-${s.k + 1}.mp3` }))
  .filter((s) => existsSync(join(dir, s.file)));

if (audio.length !== slots.length) {
  console.warn(`음성 ${slots.length - audio.length}개 없음 — 먼저 tts_dialogue.js 를 돌리세요.`);
}

const args = ['-y', '-f', 'concat', '-safe', '0', '-i', 'list.txt'];
for (const a of audio) args.push('-i', a.file);

const filters = [`[0:v]scale=${W}:${H},ass=${assName}:fontsdir=../../fonts[v]`];
audio.forEach((a, i) => {
  const ms = Math.round(a.from * 1000);
  filters.push(`[${i + 1}:a]adelay=${ms}|${ms},volume=1.3[a${i}]`);
});
if (audio.length) {
  // alimiter 로 천장을 눌러 둔다. 대사가 겹치는 구간에서 amix 합이 0dB를 넘어
  // 찌그러지는 걸 막는다.
  filters.push(
    `${audio.map((_, i) => `[a${i}]`).join('')}amix=inputs=${audio.length}:normalize=0:dropout_transition=0,` +
      `alimiter=limit=0.92,aresample=48000[a]`,
  );
}

const out = `out${lang ? '.' + lang : ''}.mp4`;
args.push('-filter_complex', filters.join(';'), '-map', '[v]');
if (audio.length) args.push('-map', '[a]', '-c:a', 'aac', '-b:a', '160k');
// -shortest 는 쓰지 않는다. 마지막 대사가 영상보다 먼저 끝나서 뒷부분이 잘린다.
args.push(
  '-c:v', 'libx264', '-preset', 'medium', '-crf', '20',
  '-pix_fmt', 'yuv420p', '-r', String(FPS), out,
);

execFileSync(ffmpeg, args, { cwd: dir, stdio: ['ignore', 'ignore', 'inherit'] });
console.log(`${id}/${out}  (자막 ${lang ? 'es+' + lang : 'es only'} / 음성 ${audio.length}줄)`);
