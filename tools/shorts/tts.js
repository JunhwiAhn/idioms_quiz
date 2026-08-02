// Spanish narration, cached on disk.
//
// Two voices on purpose: the word itself is read by one speaker and the example
// sentence by another, so beginners hear the same vocabulary from more than one
// voice. Rate is dialled down because native-speed audio is useless to someone
// on day one.
//
// Default provider is Google Cloud Text-to-Speech, which grants commercial use
// of the output under the normal Cloud terms and covers this series inside its
// free monthly quota. The old Edge path is still reachable with
// TTS_PROVIDER=edge, but it talks to an undocumented endpoint meant for the
// browser's Read Aloud feature and carries no licence for published content —
// do not ship videos made with it.

import './env.js'; // must run before any process.env read below
import { googleFetch, authMode, projectHint } from './google_auth.js';
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, renameSync, rmSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import ffmpegPath from 'ffmpeg-static';

const here = path.dirname(fileURLToPath(import.meta.url));
const cacheDir = path.join(here, '.cache', 'tts');

export const PROVIDER = (process.env.TTS_PROVIDER ?? 'google').toLowerCase();

/**
 * `word` reads the vocabulary item, `sentence` reads the example.
 * Neural2 is the sweet spot: it sits inside the 1M-character free tier and
 * supports speakingRate, which Chirp3-HD does not. Studio voices sound great
 * but cost roughly ten times as much, so they are deliberately not the default.
 */
export const GOOGLE_VOICES = {
  word: process.env.GOOGLE_TTS_VOICE_WORD ?? 'es-ES-Neural2-F',
  sentence: process.env.GOOGLE_TTS_VOICE_SENTENCE ?? 'es-ES-Neural2-A',
};

const GOOGLE_RATES = { word: 0.75, sentence: 0.88 };

const EDGE_VOICES = { word: 'es-ES-AlvaroNeural', sentence: 'es-ES-ElviraNeural' };
const EDGE_RATES = { word: '-25%', sentence: '-12%' };

mkdirSync(cacheDir, { recursive: true });

// ---------------------------------------------------------------- Google ----

const TTS_BASE = 'https://texttospeech.googleapis.com/v1';

/** Turns Google's error bodies into something that says what to click. */
async function googleError(response) {
  const detail = await response.text();
  const project = projectHint();
  const where = project ? ` (프로젝트: ${project})` : '';

  if (detail.includes('SERVICE_DISABLED') || detail.includes('has not been used')) {
    return new Error(
      `Cloud Text-to-Speech API 가 사용 설정되지 않았습니다${where}.\n` +
        '  https://console.cloud.google.com/apis/library/texttospeech.googleapis.com\n' +
        '  사용 설정 후 1~2분 뒤 다시 실행하세요.',
    );
  }
  if (detail.includes('billing') || detail.includes('BILLING')) {
    return new Error(
      `프로젝트에 결제 계정이 연결되어 있지 않습니다${where}.\n` +
        '  https://console.cloud.google.com/billing/linkedaccount\n' +
        '  무료 할당량(월 100만 자) 안이라 청구되지 않습니다.',
    );
  }
  if (response.status === 401 || response.status === 403) {
    return new Error(
      `인증이 거부되었습니다 (${response.status})${where}.\n` +
        '  서비스 계정이라면 IAM 에서 역할이 필요할 수 있습니다:\n' +
        '  https://console.cloud.google.com/iam-admin/iam  ->  해당 서비스 계정에 "편집자" 부여\n\n' +
        detail.slice(0, 300),
    );
  }
  return new Error(`Google TTS ${response.status}: ${detail.slice(0, 400)}`);
}

/** Raw synth call; also used by setup_google_tts.js to validate the setup. */
export async function googleSynthesize(text, kind = 'word') {
  const response = await googleFetch(`${TTS_BASE}/text:synthesize`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      input: { text },
      voice: { languageCode: 'es-ES', name: GOOGLE_VOICES[kind] },
      audioConfig: { audioEncoding: 'MP3', speakingRate: GOOGLE_RATES[kind] },
    }),
  });

  if (!response.ok) throw await googleError(response);
  const { audioContent } = await response.json();
  if (!audioContent) throw new Error('Google TTS returned no audioContent');
  return Buffer.from(audioContent, 'base64');
}

/** Lists the es-ES voices this project can actually reach. */
export async function googleListVoices() {
  const response = await googleFetch(`${TTS_BASE}/voices?languageCode=es-ES`);
  if (!response.ok) throw await googleError(response);
  const { voices = [] } = await response.json();
  return voices
    .map((voice) => ({ name: voice.name, gender: voice.ssmlGender }))
    .sort((a, b) => a.name.localeCompare(b.name));
}

// ------------------------------------------------------------------ Edge ----

let edgeClient = null;
let edgeVoice = null;

async function edgeClientFor(voice) {
  const { MsEdgeTTS, OUTPUT_FORMAT } = await import('msedge-tts');
  if (edgeVoice !== voice) {
    edgeClient?.close();
    edgeClient = new MsEdgeTTS();
    await edgeClient.setMetadata(voice, OUTPUT_FORMAT.AUDIO_24KHZ_48KBITRATE_MONO_MP3);
    edgeVoice = voice;
  }
  return edgeClient;
}

export function closeTts() {
  edgeClient?.close();
  edgeClient = null;
  edgeVoice = null;
}

// ----------------------------------------------------------------- shared ---

/** Duration in seconds, read back from the encoded file. */
export function durationOf(file) {
  let stderr = '';
  try {
    execFileSync(ffmpegPath, ['-i', file], { stdio: ['ignore', 'ignore', 'pipe'] });
  } catch (error) {
    stderr = error.stderr?.toString() ?? '';
  }
  const match = stderr.match(/Duration:\s*(\d+):(\d+):(\d+\.\d+)/);
  if (!match) throw new Error(`Could not read duration of ${file}`);
  const [, h, m, s] = match;
  return Number(h) * 3600 + Number(m) * 60 + Number(s);
}

/**
 * Synthesise `text`, returning the cached mp3 path and its duration.
 * `kind` selects the voice/rate pair. The cache key carries the provider and
 * voice so switching providers never reuses the previous engine's audio.
 */
export async function speak(text, kind = 'word') {
  const voice = PROVIDER === 'edge' ? EDGE_VOICES[kind] : GOOGLE_VOICES[kind];
  const rate = PROVIDER === 'edge' ? EDGE_RATES[kind] : GOOGLE_RATES[kind];
  const key = createHash('sha1')
    .update(`${PROVIDER}|${voice}|${rate}|${text}`)
    .digest('hex');
  const file = path.join(cacheDir, `${key}.mp3`);

  if (!existsSync(file)) {
    if (PROVIDER === 'edge') {
      const stage = path.join(cacheDir, `stage-${key}`);
      mkdirSync(stage, { recursive: true });
      const tts = await edgeClientFor(voice);
      const { audioFilePath } = await tts.toFile(stage, text, { rate });
      renameSync(audioFilePath, file);
      rmSync(stage, { recursive: true, force: true });
    } else {
      writeFileSync(file, await googleSynthesize(text, kind));
    }
  }

  return { file, duration: durationOf(file) };
}
