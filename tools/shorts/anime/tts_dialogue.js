// episode.json 의 대사를 인물별 목소리로 합성해 audio/ 에 떨군다.
//
//   node tts_dialogue.js ep06-restaurante
//
// tools/shorts/tts.js 는 단어/예문 두 목소리만 쓰는 구조라 그대로는 못 쓴다.
// 여기서는 인물이 다섯이라 목소리·속도·피치를 인물마다 따로 잡는다.
// 인증(.env / API 키)은 tools/shorts 쪽 모듈을 그대로 재사용한다.

import '../env.js';
import { googleFetch } from '../google_auth.js';
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));

/**
 * es-ES Neural2 만 쓴다. Standard 는 티가 나고, Studio 는 열 배 비싸다.
 * 이 프로젝트에서 쓸 수 있는 목소리는 A·E·H(여) / F·G(남) 다섯 개뿐이라
 * 인물 다섯에 하나씩 배정하면 딱 맞는다.
 *
 * HIJO(10살)는 아이 목소리가 없어서 여성 음성에 피치를 올리고 속도를 낮췄다.
 * NARR(마지막 낭독)은 초보가 따라 읽을 수 있게 가장 느리다.
 */
const VOICES = {
  MADRE: { name: 'es-ES-Neural2-A', rate: 0.92, pitch: 0 },
  HIJA: { name: 'es-ES-Neural2-H', rate: 1.0, pitch: 1.0 },
  HIJO: { name: 'es-ES-Neural2-E', rate: 0.85, pitch: 5.0 },
  PADRE: { name: 'es-ES-Neural2-F', rate: 0.85, pitch: -2.0 },
  NPC: { name: 'es-ES-Neural2-G', rate: 0.95, pitch: 0 },
  NARR: { name: 'es-ES-Neural2-A', rate: 0.72, pitch: 0 },
};

const id = process.argv[2] || 'ep06-restaurante';
const dir = join(HERE, id);
const ep = JSON.parse(readFileSync(join(dir, 'episode.json'), 'utf8'));
const outDir = join(dir, 'audio');
mkdirSync(outDir, { recursive: true });

async function synth(text, who) {
  const v = VOICES[who] ?? VOICES.NPC;
  const response = await googleFetch('https://texttospeech.googleapis.com/v1/text:synthesize', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      input: { text },
      voice: { languageCode: 'es-ES', name: v.name },
      audioConfig: { audioEncoding: 'MP3', speakingRate: v.rate, pitch: v.pitch },
    }),
  });
  if (!response.ok) throw new Error(`Google TTS ${response.status}: ${(await response.text()).slice(0, 300)}`);
  const { audioContent } = await response.json();
  if (!audioContent) throw new Error('Google TTS returned no audioContent');
  return Buffer.from(audioContent, 'base64');
}

let made = 0, cached = 0, chars = 0;
for (const s of ep.shots) {
  const lines = s.lines ?? [];
  for (let k = 0; k < lines.length; k++) {
    const l = lines[k];
    const file = join(outDir, `${String(s.n).padStart(2, '0')}-${k + 1}.mp3`);
    if (existsSync(file)) { cached++; continue; }
    writeFileSync(file, await synth(l.es, l.who));
    chars += l.es.length;
    made++;
    console.log(`  ${l.who.padEnd(6)} ${VOICES[l.who]?.name ?? '-'}  ${l.es}`);
  }
}
console.log(`${id}: 합성 ${made}개 / 캐시 ${cached}개 / ${chars}자 (무료 할당량 월 100만 자)`);
