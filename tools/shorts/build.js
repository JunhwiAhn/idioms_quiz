// Renders the beginner series to ready-to-upload Shorts.
//
//   node build.js                     # every language, every episode
//   node build.js --lang ko           # one language
//   node build.js --lang ko --day 3   # one episode
//   node build.js --plan              # print the curriculum, render nothing
//
// Output: out/<lang>/<epNN>/video.mp4 + metadata.json + metadata.txt

import { mkdirSync, writeFileSync, rmSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { Resvg } from '@resvg/resvg-js';
import ffmpegPath from 'ffmpeg-static';

import { resvgFontOptions } from './fonts.js';
import { buildSeries, WORDS_PER_EPISODE } from './curriculum.js';
import { topicById } from './topics.js';
import { speak, closeTts } from './tts.js';
import {
  introScene, wordScene, meaningScene, exampleScene, recapScene, tipScene, ctaScene,
} from './scenes.js';
import { tipFor } from './tips.js';
import { videoTitle, videoDescription, videoTags, pinnedComment, UI } from './strings.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const outRoot = path.join(here, 'out');
const workRoot = path.join(here, '.cache', 'work');

/** Where viewers are sent. Swap for the Play listing once the app is live. */
const STORE_URL = 'https://junhwiahn.github.io/idioms_quiz/';

const FPS = 30;
const HOLD = { intro: 2.6, recap: 6.5, cta: 3.0 };
const MIN = { word: 2.4, meaning: 2.3, example: 3.0 };

function parseArgs(argv) {
  const args = { lang: null, day: null, plan: false, metadataOnly: false };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--lang') args.lang = argv[++i];
    else if (argv[i] === '--day') args.day = Number(argv[++i]);
    else if (argv[i] === '--plan') args.plan = true;
    else if (argv[i] === '--metadata-only') args.metadataOnly = true;
  }
  return args;
}

function renderPng(svg, file) {
  const resvg = new Resvg(svg, { font: resvgFontOptions() });
  writeFileSync(file, resvg.render().asPng());
}

function ffmpeg(args) {
  execFileSync(ffmpegPath, ['-hide_banner', '-loglevel', 'error', '-y', ...args], {
    stdio: ['ignore', 'ignore', 'inherit'],
  });
}

/**
 * Builds the episode as a list of scenes. Each scene owns a still frame, a
 * duration, and optionally narration clips placed at an offset inside it.
 */
async function planScenes({ lang, episode, topic }) {
  const { day, words } = episode;
  const scenes = [];

  scenes.push({
    name: 'intro',
    svg: introScene({
      lang,
      day,
      topicTitle: topic.titles[lang],
      topicSubtitle: topic.subtitles[lang],
      wordCount: words.length,
    }),
    duration: HOLD.intro,
    audio: [],
  });

  for (const [index, word] of words.entries()) {
    const term = await speak(word.term, 'word');
    const sentence = await speak(word.example, 'sentence');
    const common = { lang, day, word, index, total: words.length };

    // The term is heard twice: once while the viewer is still guessing, once
    // more the moment the meaning appears.
    scenes.push({
      name: `word${index + 1}`,
      svg: wordScene(common),
      duration: Math.max(MIN.word, 0.35 + term.duration + 0.9),
      audio: [{ file: term.file, at: 0.35 }],
    });

    scenes.push({
      name: `meaning${index + 1}`,
      svg: meaningScene(common),
      duration: Math.max(MIN.meaning, 0.3 + term.duration + 1.1),
      audio: [{ file: term.file, at: 0.3 }],
    });

    scenes.push({
      name: `example${index + 1}`,
      svg: exampleScene(common),
      duration: Math.max(MIN.example, 0.4 + sentence.duration + 0.7),
      audio: [{ file: sentence.file, at: 0.4 }],
    });
  }

  // Recap reads every term once more, evenly spread across the scene.
  const recapClips = [];
  let cursor = 0.6;
  for (const word of words) {
    const term = await speak(word.term, 'word');
    recapClips.push({ file: term.file, at: cursor });
    cursor += term.duration + 0.3;
  }
  scenes.push({
    name: 'recap',
    svg: recapScene({ lang, day, words }),
    duration: Math.max(HOLD.recap, cursor + 0.6),
    audio: recapClips,
  });

  // Reading time for the written note, scaled to how much there is to read.
  const tip = tipFor(day, lang);
  scenes.push({
    name: 'tip',
    svg: tipScene({ lang, day, ...tip }),
    duration: Math.min(9.0, Math.max(5.5, tip.body.length * 0.075)),
    audio: [],
  });

  scenes.push({ name: 'cta', svg: ctaScene({ lang }), duration: HOLD.cta, audio: [] });
  return scenes;
}

function writeVideo({ scenes, workDir, outFile }) {
  // Frames: one still per scene, held for its duration by the concat demuxer.
  const lines = [];
  scenes.forEach((scene, i) => {
    const frame = path.join(workDir, `${String(i).padStart(2, '0')}-${scene.name}.png`);
    renderPng(scene.svg, frame);
    lines.push(`file '${frame.replaceAll('\\', '/')}'`, `duration ${scene.duration.toFixed(3)}`);
    // concat needs the final image repeated or it drops the last frame.
    if (i === scenes.length - 1) lines.push(`file '${frame.replaceAll('\\', '/')}'`);
  });
  const listFile = path.join(workDir, 'frames.txt');
  writeFileSync(listFile, lines.join('\n'));

  // Audio: every narration clip delayed to its absolute position, mixed over
  // one silent bed that defines the total length.
  const total = scenes.reduce((sum, scene) => sum + scene.duration, 0);
  const clips = [];
  let offset = 0;
  for (const scene of scenes) {
    for (const clip of scene.audio) clips.push({ file: clip.file, at: offset + clip.at });
    offset += scene.duration;
  }

  const audioFile = path.join(workDir, 'audio.m4a');
  const inputs = clips.flatMap((clip) => ['-i', clip.file]);
  const delays = clips
    .map((clip, i) => `[${i + 1}:a]adelay=${Math.round(clip.at * 1000)}:all=1[d${i}]`)
    .join(';');
  const mixLabels = clips.map((_, i) => `[d${i}]`).join('');
  const filter = clips.length
    ? `${delays};[0:a]${mixLabels}amix=inputs=${clips.length + 1}:normalize=0:duration=longest[out]`
    : '[0:a]anull[out]';

  ffmpeg([
    '-f', 'lavfi', '-t', total.toFixed(3), '-i', 'anullsrc=r=24000:cl=mono',
    ...inputs,
    '-filter_complex', filter,
    '-map', '[out]', '-c:a', 'aac', '-b:a', '128k', '-ar', '44100',
    '-t', total.toFixed(3),
    audioFile,
  ]);

  ffmpeg([
    '-f', 'concat', '-safe', '0', '-i', listFile,
    '-i', audioFile,
    '-c:v', 'libx264', '-preset', 'medium', '-crf', '20',
    '-pix_fmt', 'yuv420p', '-r', String(FPS),
    '-vf', 'scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2',
    '-c:a', 'copy', '-movflags', '+faststart', '-shortest',
    outFile,
  ]);

  return total;
}

function writeMetadata({ lang, episode, topic, dir }) {
  const payload = {
    language: lang,
    day: episode.day,
    topic: episode.topicId,
    title: videoTitle({ lang, day: episode.day, topicTitle: topic.titles[lang] }),
    description: videoDescription({
      lang,
      day: episode.day,
      topicTitle: topic.titles[lang],
      topicSubtitle: topic.subtitles[lang],
      words: episode.words,
      tip: tipFor(episode.day, lang),
      storeUrl: STORE_URL,
    }),
    tags: videoTags({ lang, words: episode.words }),
    pinnedComment: pinnedComment({
      lang,
      day: episode.day,
      topicTitle: topic.titles[lang],
      words: episode.words,
      storeUrl: STORE_URL,
    }),
    words: episode.words.map((word) => ({
      term: word.term,
      level: word.level,
      meaning: word.meanings[lang],
      example: word.example,
      exampleMeaning: word.exampleMeanings[lang],
    })),
  };
  writeFileSync(path.join(dir, 'metadata.json'), JSON.stringify(payload, null, 2));
  writeFileSync(
    path.join(dir, 'metadata.txt'),
    [
      `[TITLE]\n${payload.title}`,
      `[DESCRIPTION]\n${payload.description}`,
      `[TAGS]\n${payload.tags.join(', ')}`,
      `[PINNED COMMENT]\n${payload.pinnedComment}`,
    ].join('\n\n'),
  );
  return payload;
}

const args = parseArgs(process.argv.slice(2));
const series = buildSeries();

if (args.plan) {
  for (const episode of series) {
    const topic = topicById(episode.topicId);
    const suffix = episode.totalParts > 1 ? ` (${episode.part}/${episode.totalParts})` : '';
    console.log(`Day ${String(episode.day).padStart(2)}  ${topic.titles.ko}${suffix}`);
    console.log(`        ${episode.words.map((w) => `${w.term} = ${w.meanings.ko}`).join(' · ')}`);
  }
  process.exit(0);
}

const languages = args.lang ? [args.lang] : ['ko', 'en', 'ja'];
const episodes = args.day ? series.filter((e) => e.day === args.day) : series;
if (!episodes.length) throw new Error(`No episode for day ${args.day}`);

console.log(
  `Rendering ${episodes.length} episode(s) x ${languages.length} language(s) ` +
    `= ${episodes.length * languages.length} videos\n`,
);

for (const lang of languages) {
  for (const episode of episodes) {
    const topic = topicById(episode.topicId);
    const dir = path.join(outRoot, lang, episode.id);
    mkdirSync(dir, { recursive: true });

    const label = `${lang} ${episode.id} ${topic.titles[lang]}`;
    process.stdout.write(`  ${label.padEnd(52)} `);

    if (args.metadataOnly) {
      writeMetadata({ lang, episode, topic, dir });
      console.log('metadata');
      continue;
    }

    const workDir = path.join(workRoot, lang, episode.id);
    if (existsSync(workDir)) rmSync(workDir, { recursive: true, force: true });
    mkdirSync(workDir, { recursive: true });

    const scenes = await planScenes({ lang, episode, topic });
    const outFile = path.join(dir, 'video.mp4');
    const total = writeVideo({ scenes, workDir, outFile });
    writeMetadata({ lang, episode, topic, dir });

    console.log(`${total.toFixed(1)}s  ->  ${path.relative(here, outFile)}`);
  }
}

closeTts();
console.log(
  `\nDone. ${WORDS_PER_EPISODE} words per episode. Upload from ${path.relative(here, outRoot)}/`,
);
