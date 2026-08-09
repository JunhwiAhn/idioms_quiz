// Builds the accumulating-list Spanish phrase Short described by
// .claude/skills/spanish-phrase-shorts/SKILL.md.
//
//   node build_phrase_short.js everyday --lang en
//
// Output: out/phrase/<lang>/<set>/video.mp4 plus metadata and an editable
// Canva-ready HTML storyboard. The video itself is 45.2 seconds long.

import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { Resvg } from '@resvg/resvg-js';
import ffmpegPath from 'ffmpeg-static';

import { escapeXml, resvgFontOptions } from './fonts.js';
import { closeTts, speak } from './tts.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const outRoot = path.join(here, 'out', 'phrase');
const workRoot = path.join(here, '.cache', 'phrase-short');
const bgm = {
  file: path.join(here, 'assets', 'music', 'classical-pop-instrumental.mp3'),
  title: 'Classical Pop (Instrumental)',
  author: 'Alex McCulloch / Pro Sensory',
  license: 'CC0 1.0 Universal (public domain)',
  source: 'https://opengameart.org/content/classical-pop-instrumental',
};

const WIDTH = 1080;
const HEIGHT = 1920;
const FPS = 30;
const appIconFile = path.resolve(here, '../../docs/play_assets/icon_512.png');
const appIconData = `data:image/png;base64,${readFileSync(appIconFile).toString('base64')}`;
const serifFontFiles = [
  path.resolve(here, '../../assets/fonts/NotoSerifJP-Regular.ttf'),
  path.resolve(here, '../../assets/fonts/NotoSerifJP-Bold.ttf'),
  path.resolve(here, '../../assets/fonts/NotoSerifJP-ExtraBold.ttf'),
];

const COLORS = {
  background: '#FFFBF2',
  paper: '#FFFDFC',
  title: '#7A2508',
  primary: '#C44720',
  primarySoft: '#FFE1D5',
  secondary: '#007C99',
  secondarySoft: '#D8F6FF',
  ink: '#2E2018',
  muted: '#6F5E57',
  border: '#FFC8A8',
  rule: '#BFEAF2',
};

const SETS = {
  everyday: {
    header: 'Learn Spanish',
    title: '10 Everyday Spanish Phrases',
    rows: [
      { en: 'Me too', es: 'Yo también', roman: 'yoh tahm-BYEN' },
      { en: 'Not yet', es: 'Aún no', roman: 'ah-OON noh' },
      { en: 'Of course', es: 'Claro que sí', roman: 'KLAH-roh keh SEE' },
      { en: 'No problem', es: 'No pasa nada', roman: 'noh PAH-sah NAH-dah' },
      { en: 'See you', es: 'Nos vemos', roman: 'nohs VEH-mohs' },
      { en: 'Right away', es: 'Ahora mismo', roman: 'ah-OH-rah MEES-moh' },
      { en: 'It depends', es: 'Depende', roman: 'deh-PEN-deh' },
      { en: 'Why not?', es: '¿Por qué no?', roman: 'por keh NOH' },
      { en: 'Be careful', es: 'Ten cuidado', roman: 'ten kwee-DAH-doh' },
      { en: 'My pleasure', es: 'Un placer', roman: 'oon plah-SEHR' },
    ],
  },
};

function parseArgs(argv) {
  const args = {
    set: 'everyday',
    lang: 'en',
    metadataOnly: false,
    tts: process.env.PHRASE_TTS_PROVIDER ?? 'google',
  };
  for (let i = 0; i < argv.length; i += 1) {
    if (argv[i] === '--lang') args.lang = argv[++i];
    else if (argv[i] === '--tts') args.tts = argv[++i];
    else if (argv[i] === '--metadata-only') args.metadataOnly = true;
    else if (!argv[i].startsWith('--')) args.set = argv[i];
  }
  if (args.lang !== 'en') throw new Error('The phrase-list format currently supports --lang en only.');
  if (!['google', 'piper'].includes(args.tts)) throw new Error('--tts must be google or piper.');
  if (!SETS[args.set]) throw new Error(`Unknown set: ${args.set}. Available: ${Object.keys(SETS).join(', ')}`);
  return args;
}

function ffmpeg(args) {
  execFileSync(ffmpegPath, ['-hide_banner', '-loglevel', 'error', '-y', ...args], {
    stdio: ['ignore', 'ignore', 'inherit'],
  });
}

function rowMarkup(row, index, { englishCount, spanishCount }) {
  const visibleEnglish = index < englishCount;
  const visibleSpanish = index < spanishCount;
  if (!visibleEnglish) return '';

  const y = 518 + index * 88;
  const underline = Math.min(330, Math.max(145, row.es.length * 25));
  return `
    <circle cx="116" cy="${y - 5}" r="25" fill="${COLORS.secondarySoft}" stroke="${COLORS.secondary}" stroke-width="2"/>
    <text x="116" y="${y + 4}" text-anchor="middle" class="number">${String(index + 1).padStart(2, '0')}</text>
    <text x="170" y="${y + 2}" class="english">${escapeXml(row.en)}</text>
    <path d="M 397 ${y - 5} l 27 0 m -9 -9 l 9 9 l -9 9" fill="none" stroke="${COLORS.primary}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
    ${visibleSpanish ? `
      <text x="462" y="${y + 7}" class="spanish">${escapeXml(row.es)}</text>
      <path d="M 462 ${y + 19} Q ${462 + underline / 2} ${y + 25}, ${462 + underline} ${y + 18}" fill="none" stroke="${COLORS.primary}" stroke-width="3" stroke-linecap="round" opacity="0.72"/>` : ''}`;
}

/** Render the one persistent list frame with only the requested answers revealed. */
export function listFrame(rows, { englishCount = 0, spanishCount = 0 } = {}) {
  const renderedRows = rows
    .map((row, index) => rowMarkup(row, index, { englishCount, spanishCount }))
    .join('');
  const introNote = englishCount === 0 ? `
    <text x="540" y="780" text-anchor="middle" class="intro serif">10 everyday phrases</text>
    <path d="M 326 806 Q 540 820, 754 805" fill="none" stroke="${COLORS.primary}" stroke-width="5" stroke-linecap="round" opacity="0.75"/>
    <text x="540" y="866" text-anchor="middle" class="introSub">Can you write them in Spanish?</text>
    <path d="M 850 736 l 72 72 l -18 18 l -72 -72 z M 922 808 l 14 34 l -32 -16" fill="${COLORS.primarySoft}" stroke="${COLORS.primary}" stroke-width="4" stroke-linejoin="round"/>` : '';
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${WIDTH}" height="${HEIGHT}" viewBox="0 0 ${WIDTH} ${HEIGHT}">
  <defs>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%"><feDropShadow dx="0" dy="18" stdDeviation="22" flood-color="#7A2508" flood-opacity="0.12"/></filter>
    <linearGradient id="tab" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#7A2508"/><stop offset="0.55" stop-color="#C44720"/><stop offset="1" stop-color="#FF8A3D"/></linearGradient>
  </defs>
  <rect width="${WIDTH}" height="${HEIGHT}" fill="${COLORS.background}"/>
  <circle cx="1010" cy="260" r="210" fill="${COLORS.primarySoft}" opacity="0.55"/>
  <circle cx="70" cy="1450" r="160" fill="${COLORS.secondarySoft}" opacity="0.65"/>
  <rect x="58" y="252" width="964" height="1220" rx="34" fill="#F8EADF" opacity="0.8" transform="rotate(1 540 862)"/>
  <rect x="48" y="238" width="984" height="1220" rx="34" fill="${COLORS.paper}" stroke="${COLORS.border}" stroke-width="3" filter="url(#shadow)"/>
  <rect x="48" y="238" width="984" height="196" rx="34" fill="url(#tab)"/>
  <rect x="48" y="398" width="984" height="36" fill="url(#tab)"/>
  <image href="${appIconData}" x="86" y="274" width="112" height="112" preserveAspectRatio="xMidYMid meet"/>
  <style>
    text { font-family: "Noto Sans KR", sans-serif; }
    .serif { font-family: "Noto Serif JP", serif; }
    .eyebrow { font-size: 25px; font-weight: 700; fill: #FFF3E8; letter-spacing: 3px; }
    .title { font-size: 55px; font-weight: 800; fill: white; }
    .pill { font-size: 23px; font-weight: 700; fill: ${COLORS.title}; }
    .number { font-size: 19px; font-weight: 800; fill: ${COLORS.secondary}; }
    .english { font-size: 31px; font-weight: 600; fill: ${COLORS.muted}; }
    .spanish { font-family: "Noto Serif JP", serif; font-size: 43px; font-weight: 800; font-style: italic; fill: ${COLORS.ink}; }
    .waiting { font-family: "Noto Serif JP", serif; font-size: 27px; font-style: italic; fill: ${COLORS.secondary}; opacity: 0.45; }
    .footer { font-size: 22px; font-weight: 700; fill: ${COLORS.muted}; letter-spacing: 1.5px; }
    .intro { font-size: 61px; font-weight: 800; font-style: italic; fill: ${COLORS.ink}; }
    .introSub { font-size: 29px; font-weight: 600; fill: ${COLORS.secondary}; }
  </style>
  <text x="226" y="310" class="eyebrow">DELE VOCA DOJO</text>
  <text x="226" y="374" class="title serif">Spanish notebook</text>
  <rect x="782" y="287" width="190" height="60" rx="30" fill="#FFF6ED" opacity="0.94"/>
  <text x="877" y="326" text-anchor="middle" class="pill">EN  →  ES</text>
  <line x1="150" y1="458" x2="150" y2="1378" stroke="${COLORS.primary}" stroke-width="3" opacity="0.55"/>
  ${Array.from({ length: 11 }, (_, i) => `<line x1="80" y1="${550 + i * 88}" x2="992" y2="${550 + i * 88}" stroke="${COLORS.rule}" stroke-width="2"/>`).join('')}
  ${[522, 786, 1050, 1314].map((y) => `<circle cx="77" cy="${y}" r="11" fill="${COLORS.background}" stroke="${COLORS.border}" stroke-width="3"/>`).join('')}
  ${introNote}
  ${renderedRows}
  <rect x="354" y="1390" width="372" height="46" rx="23" fill="${COLORS.primarySoft}"/>
  <text x="540" y="1421" text-anchor="middle" class="footer">LISTEN  •  REPEAT  •  SAVE</text>
</svg>`;
}

function planVisualScenes(set) {
  const scenes = [{
    name: 'title',
    duration: 1.2,
    svg: listFrame(set.rows, { englishCount: set.rows.length, spanishCount: 0 }),
    audio: [],
    note: 'Show the complete English prompt column; Spanish column stays blank',
  }];

  set.rows.forEach((row, index) => {
    scenes.push({
      name: `${String(index + 1).padStart(2, '0')}-prompt`,
      duration: 0.6,
      svg: listFrame(set.rows, { englishCount: set.rows.length, spanishCount: index }),
      audio: [],
      note: `Show English prompt: ${row.en}`,
    });
    scenes.push({
      name: `${String(index + 1).padStart(2, '0')}-answer`,
      duration: 3.4,
      svg: listFrame(set.rows, { englishCount: set.rows.length, spanishCount: index + 1 }),
      audio: [],
      tts: row.es,
      note: `Reveal Spanish and speak: ${row.es}`,
    });
  });

  scenes.push({
    name: 'recap',
    duration: 4.0,
    svg: listFrame(set.rows, { englishCount: set.rows.length, spanishCount: set.rows.length }),
    audio: [],
    note: 'Hold the complete list',
  });
  return scenes;
}

function durationOf(file) {
  let stderr = '';
  try {
    execFileSync(ffmpegPath, ['-i', file], { stdio: ['ignore', 'ignore', 'pipe'] });
  } catch (error) {
    stderr = error.stderr?.toString() ?? '';
  }
  const match = stderr.match(/Duration:\s*(\d+):(\d+):(\d+\.\d+)/);
  if (!match) throw new Error(`Could not read duration of ${file}`);
  return Number(match[1]) * 3600 + Number(match[2]) * 60 + Number(match[3]);
}

function piperSpeak(text) {
  const python = process.env.PIPER_PYTHON ?? 'python';
  const model = process.env.PIPER_MODEL ?? path.join(
    here, '.cache', 'piper', 'es_ES-mls_9972-low.onnx',
  );
  if (!existsSync(model)) {
    throw new Error(
      `Piper model not found: ${model}\n` +
      'Install piper-tts and download es_ES-mls_9972-low, or set PIPER_MODEL.',
    );
  }
  const cacheDir = path.join(here, '.cache', 'tts-piper');
  mkdirSync(cacheDir, { recursive: true });
  const key = createHash('sha1').update(`es_ES-mls_9972-low|${text}`).digest('hex');
  const file = path.join(cacheDir, `${key}.wav`);
  if (!existsSync(file)) {
    execFileSync(python, ['-m', 'piper', '--model', model, '--output_file', file], {
      input: `${text}\n`,
      stdio: ['pipe', 'ignore', 'inherit'],
    });
  }
  return { file, duration: durationOf(file) };
}

async function addNarration(scenes, provider) {
  for (const scene of scenes) {
    if (!scene.tts) continue;
    const clip = provider === 'piper' ? piperSpeak(scene.tts) : await speak(scene.tts, 'word');
    scene.audio.push({ file: clip.file, at: 0.05 });
  }
  return scenes;
}

function renderPng(svg, file) {
  const base = resvgFontOptions();
  const resvg = new Resvg(svg, { font: { ...base, fontFiles: [...base.fontFiles, ...serifFontFiles] } });
  writeFileSync(file, resvg.render().asPng());
}

function writeVideo({ scenes, workDir, outFile }) {
  const frameList = [];
  scenes.forEach((scene, index) => {
    const frame = path.join(workDir, `${String(index).padStart(2, '0')}-${scene.name}.png`);
    renderPng(scene.svg, frame);
    frameList.push(`file '${frame.replaceAll('\\', '/')}'`, `duration ${scene.duration.toFixed(3)}`);
    if (index === scenes.length - 1) frameList.push(`file '${frame.replaceAll('\\', '/')}'`);
  });
  const listFile = path.join(workDir, 'frames.txt');
  writeFileSync(listFile, frameList.join('\n'));

  const total = scenes.reduce((sum, scene) => sum + scene.duration, 0);
  const clips = [];
  let sceneStart = 0;
  for (const scene of scenes) {
    for (const clip of scene.audio) clips.push({ file: clip.file, at: sceneStart + clip.at });
    sceneStart += scene.duration;
  }

  const audioFile = path.join(workDir, 'audio.m4a');
  if (!existsSync(bgm.file)) throw new Error(`BGM file not found: ${bgm.file}`);
  const bgmBed = path.join(workDir, 'bgm-bed.m4a');
  ffmpeg([
    '-stream_loop', '-1', '-i', bgm.file,
    '-t', total.toFixed(3),
    '-filter:a', 'volume=0.10,aresample=24000',
    '-ac', '1', '-c:a', 'aac', '-b:a', '96k', bgmBed,
  ]);
  const inputs = clips.flatMap((clip) => ['-i', clip.file]);
  const delays = clips
    .map((clip, index) => `[${index + 2}:a]adelay=${Math.round(clip.at * 1000)}:all=1[d${index}]`)
    .join(';');
  const mixLabels = clips.map((_, index) => `[d${index}]`).join('');
  const filter = clips.length
    ? `${delays};[1:a]${mixLabels}amix=inputs=${clips.length + 1}:normalize=0:duration=longest[out]`
    : '[1:a]anull[out]';

  ffmpeg([
    '-f', 'lavfi', '-t', total.toFixed(3), '-i', 'anullsrc=r=24000:cl=mono',
    '-i', bgmBed,
    ...inputs,
    '-filter_complex', filter,
    '-map', '[out]', '-c:a', 'aac', '-b:a', '128k', '-ar', '44100',
    '-t', total.toFixed(3), audioFile,
  ]);
  ffmpeg([
    '-f', 'concat', '-safe', '0', '-i', listFile,
    '-i', audioFile,
    '-c:v', 'libx264', '-preset', 'medium', '-crf', '20',
    '-pix_fmt', 'yuv420p', '-r', String(FPS),
    '-vf', `scale=${WIDTH}:${HEIGHT}`,
    '-c:a', 'copy', '-movflags', '+faststart', '-shortest', outFile,
  ]);
  return total;
}

function htmlEscape(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

function frameHtml(set, scene) {
  const answerMatch = scene.name.match(/^(\d+)-(prompt|answer)$/);
  let englishCount = 0;
  let spanishCount = 0;
  if (scene.name === 'title') englishCount = set.rows.length;
  else if (scene.name === 'recap') englishCount = spanishCount = set.rows.length;
  else if (answerMatch) {
    englishCount = set.rows.length;
    const rowNumber = Number(answerMatch[1]);
    spanishCount = answerMatch[2] === 'answer' ? rowNumber : rowNumber - 1;
  }
  const rows = set.rows.map((row, index) => {
    if (index >= englishCount) return '';
    return `<div class="row" style="top:${476 + index * 88}px"><div class="num">${String(index + 1).padStart(2, '0')}</div><div class="en">${htmlEscape(row.en)}</div><div class="arrow">→</div>${index < spanishCount ? `<div class="es"><span>${htmlEscape(row.es)}</span></div>` : ''}</div>`;
  }).join('');
  return `<section class="page" data-document-role="page" data-label="${htmlEscape(scene.name)}" data-speaker-notes="${scene.duration.toFixed(1)}s — ${htmlEscape(scene.note)}">
    <div class="blob one"></div><div class="blob two"></div><div class="paper-back"></div><div class="paper"><header><div class="logo"></div><div class="heading"><div class="eyebrow">DELE VOCA DOJO</div><h1>Spanish notebook</h1></div><div class="pill">EN → ES</div></header><div class="margin"></div><div class="rules"></div>${rows}<div class="footer">LISTEN • REPEAT • SAVE</div></div>
  </section>`;
}

function writeCanvaStoryboard(set, scenes, dir) {
  const pages = scenes.map((scene) => frameHtml(set, scene)).join('\n');
  const html = `<!doctype html><html><head><meta charset="utf-8"><title>${htmlEscape(set.title)}</title><style>
  :root{--logo:url('${appIconData}')}*{box-sizing:border-box}body{margin:0;background:#ddd;font-family:Arial,sans-serif}.page{position:relative;width:1080px;height:1920px;overflow:hidden;background:${COLORS.background};page-break-after:always}.blob{position:absolute;border-radius:50%}.blob.one{width:420px;height:420px;right:-170px;top:50px;background:${COLORS.primarySoft};opacity:.55}.blob.two{width:320px;height:320px;left:-150px;top:1300px;background:${COLORS.secondarySoft};opacity:.65}.paper-back,.paper{position:absolute;left:48px;top:238px;width:984px;height:1220px;border-radius:34px}.paper-back{background:#f8eadf;transform:rotate(1deg);top:252px;left:58px}.paper{overflow:hidden;background:${COLORS.paper};border:3px solid ${COLORS.border};box-shadow:0 18px 44px rgba(122,37,8,.13)}header{height:196px;padding:36px 58px 28px 36px;display:flex;align-items:center;background:linear-gradient(135deg,#7A2508,#C44720 55%,#FF8A3D);color:white}.logo{width:112px;height:112px;flex:0 0 112px;background-image:var(--logo);background-size:contain;background-position:center;background-repeat:no-repeat}.heading{margin-left:28px}.eyebrow{font-size:25px;font-weight:700;letter-spacing:3px;color:#fff3e8}.heading h1{margin:10px 0 0;font-family:Georgia,serif;font-size:55px;line-height:1;font-weight:700}.pill{margin-left:auto;padding:16px 24px;border-radius:30px;background:#fff6ed;color:${COLORS.title};font-size:23px;font-weight:700}.margin{position:absolute;left:99px;top:220px;width:3px;height:920px;background:${COLORS.primary};opacity:.55}.rules{position:absolute;left:30px;right:40px;top:310px;height:968px;background:repeating-linear-gradient(to bottom,transparent 0,transparent 86px,${COLORS.rule} 86px,${COLORS.rule} 88px)}.intro-note{position:absolute;left:220px;top:520px;width:600px;text-align:center}.intro-note strong{display:block;font-family:Georgia,serif;font-size:61px;font-style:italic;color:${COLORS.ink}}.intro-note i{display:block;width:430px;height:16px;margin:2px auto 22px;border-bottom:5px solid rgba(196,71,32,.75);border-radius:50%}.intro-note span{font-size:29px;font-weight:600;color:${COLORS.secondary}}.intro-note b{position:absolute;right:-90px;top:-34px;font-size:76px;color:${COLORS.primary};transform:rotate(-12deg)}.row{position:absolute;left:42px;width:890px;height:64px;display:flex;align-items:center}.num{width:50px;height:50px;border-radius:50%;display:flex;align-items:center;justify-content:center;background:${COLORS.secondarySoft};border:2px solid ${COLORS.secondary};color:${COLORS.secondary};font-size:19px;font-weight:800}.en{margin-left:28px;width:210px;color:${COLORS.muted};font-size:31px;font-weight:600;white-space:nowrap}.arrow{width:62px;color:${COLORS.primary};font-size:34px}.es{color:${COLORS.ink};font-family:Georgia,serif;font-size:43px;font-weight:700;font-style:italic;white-space:nowrap}.es span{border-bottom:3px solid rgba(196,71,32,.72);padding-bottom:4px}.waiting{color:${COLORS.secondary};font-family:Georgia,serif;font-size:27px;font-style:italic;opacity:.45}.footer{position:absolute;left:306px;bottom:20px;width:372px;height:46px;border-radius:23px;display:flex;align-items:center;justify-content:center;background:${COLORS.primarySoft};color:${COLORS.muted};font-size:22px;font-weight:700;letter-spacing:1.5px}@media print{body{background:white}.page{break-after:page}}
  </style></head><body>${pages}</body></html>`;
  writeFileSync(path.join(dir, 'canva_storyboard.html'), html);
  writeFileSync(path.join(dir, 'canva_timing.json'), JSON.stringify({
    designType: 'mobile_video',
    size: { width: WIDTH, height: HEIGHT },
    totalDurationSeconds: scenes.reduce((sum, scene) => sum + scene.duration, 0),
    pages: scenes.map((scene, index) => ({ page: index + 1, name: scene.name, duration: scene.duration, narration: scene.tts ?? null })),
  }, null, 2));
}

function writeMetadata(set, total, dir, ttsProvider) {
  const lines = set.rows.map((row) => `${row.es} (${row.roman}) — ${row.en}`);
  const description = [
    'Learn 10 short, everyday Spanish phrases. Listen, repeat, and save this Short for review.',
    '', ...lines,
    '',
    `BGM: ${bgm.title} — ${bgm.author}`,
    `BGM license: ${bgm.license}`,
    `BGM source: ${bgm.source}`,
    ...(ttsProvider === 'piper' ? [
      '',
      'Voice: Piper es_ES-mls_9972-low (MLS dataset, CC BY 4.0)',
      'https://huggingface.co/rhasspy/piper-voices/tree/main/es/es_ES/mls_9972/low',
    ] : []),
    '', '#learnspanish #spanishphrases #spain #shorts',
  ].join('\n');
  const metadata = {
    title: set.title,
    durationSeconds: total,
    language: 'en',
    locale: 'es-ES',
    ttsProvider,
    description,
    tags: ['learn spanish', 'spanish phrases', 'spanish for beginners', 'spain', 'shorts'],
    alteredContent: false,
    bgm,
    phrases: set.rows,
  };
  writeFileSync(path.join(dir, 'metadata.json'), JSON.stringify(metadata, null, 2));
  writeFileSync(path.join(dir, 'metadata.txt'), `[TITLE]\n${set.title}\n\n[DESCRIPTION]\n${description}\n\n[TAGS]\n${metadata.tags.join(', ')}`);
}

const args = parseArgs(process.argv.slice(2));
const set = SETS[args.set];
const dir = path.join(outRoot, args.lang, args.set);
mkdirSync(dir, { recursive: true });
const scenes = planVisualScenes(set);
const plannedTotal = scenes.reduce((sum, scene) => sum + scene.duration, 0);
writeCanvaStoryboard(set, scenes, dir);

if (args.metadataOnly) {
  writeMetadata(set, plannedTotal, dir, args.tts);
  console.log(`Metadata and Canva storyboard -> ${path.relative(here, dir)}`);
  process.exit(0);
}

const workDir = path.join(workRoot, args.lang, args.set);
if (existsSync(workDir)) rmSync(workDir, { recursive: true, force: true });
mkdirSync(workDir, { recursive: true });

try {
  await addNarration(scenes, args.tts);
  const outFile = path.join(dir, 'video.mp4');
  const total = writeVideo({ scenes, workDir, outFile });
  writeMetadata(set, total, dir, args.tts);
  console.log(`${set.title}: ${total.toFixed(1)}s -> ${path.relative(here, outFile)}`);
} finally {
  closeTts();
}
