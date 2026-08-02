// Verifies the Google Cloud TTS setup end to end and produces sample audio.
//
//   node setup_google_tts.js
//
// Checks, in order: the API key is present, the key works, the Text-to-Speech
// API is enabled, the configured voices exist, and synthesis actually returns
// audio. Writes two samples so the voices can be judged before committing to a
// full 60-video render.

import { mkdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { googleListVoices, googleSynthesize, GOOGLE_VOICES, durationOf } from './tts.js';
import { envFile } from './env.js';
import { authMode, credentialsPath, apiKey, projectHint } from './google_auth.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const sampleDir = path.join(here, 'out', '_tts_sample');

const SAMPLES = {
  word: 'cenar',
  sentence: 'Hoy vamos a cenar fuera con mi familia.',
};

function fail(message) {
  console.error(`\n✗ ${message}\n`);
  process.exit(1);
}

const mode = authMode();
if (!mode) {
  console.error(`
✗ Google Cloud 인증 정보가 설정되지 않았습니다.

  아래 파일을 메모장으로 열어 둘 중 하나를 채우고 저장하세요.

     ${envFile}

  A) 서비스 계정 키 파일이 있는 경우
     GOOGLE_APPLICATION_CREDENTIALS=C:\\경로\\키파일.json

  B) API 키가 있는 경우
     GOOGLE_TTS_API_KEY=AIza...

  그리고 프로젝트 쪽 준비:
     https://console.cloud.google.com/apis/library/texttospeech.googleapis.com  (사용 설정)
     https://console.cloud.google.com/billing/linkedaccount                     (결제 연결)

  다시:  node setup_google_tts.js
`);
  process.exit(1);
}

if (mode === 'service-account') {
  const project = projectHint();
  console.log(`✓ 서비스 계정 키 확인  ${credentialsPath()}`);
  if (project) console.log(`  프로젝트: ${project}`);
} else {
  console.log(`✓ API 키 확인 (${apiKey().length}자)`);
}

let voices;
try {
  voices = await googleListVoices();
} catch (error) {
  fail(error.message);
}
console.log(`✓ API 연결 성공 — es-ES 음성 ${voices.length}개 사용 가능`);

const available = new Set(voices.map((voice) => voice.name));
for (const [kind, name] of Object.entries(GOOGLE_VOICES)) {
  if (!available.has(name)) {
    console.error(`\n✗ 설정된 음성 "${name}" (${kind}) 을 사용할 수 없습니다.`);
    console.error('  사용 가능한 es-ES 음성:');
    for (const voice of voices) console.error(`    ${voice.name.padEnd(26)} ${voice.gender}`);
    console.error('\n  GOOGLE_TTS_VOICE_WORD / GOOGLE_TTS_VOICE_SENTENCE 환경변수로 바꿀 수 있습니다.');
    process.exit(1);
  }
}

const genderOf = (name) => voices.find((voice) => voice.name === name)?.gender ?? '?';
console.log(`✓ 단어 음성   ${GOOGLE_VOICES.word} (${genderOf(GOOGLE_VOICES.word)})`);
console.log(`✓ 예문 음성   ${GOOGLE_VOICES.sentence} (${genderOf(GOOGLE_VOICES.sentence)})`);

mkdirSync(sampleDir, { recursive: true });
for (const [kind, text] of Object.entries(SAMPLES)) {
  const file = path.join(sampleDir, `${kind}.mp3`);
  writeFileSync(file, await googleSynthesize(text, kind));
  console.log(`✓ 샘플 생성   ${path.relative(here, file)}  "${text}"  (${durationOf(file).toFixed(2)}초)`);
}

const chars = Object.values(SAMPLES).reduce((n, text) => n + text.length, 0);
console.log(`
설정 완료. 방금 ${chars}자를 사용했습니다 (무료 할당 월 100만 자).

샘플을 들어보고 괜찮으면 전체 재렌더링:

    node build.js

음성을 바꾸고 싶으면 위 목록에서 골라 GOOGLE_TTS_VOICE_WORD / GOOGLE_TTS_VOICE_SENTENCE 를 설정하세요.
`);
