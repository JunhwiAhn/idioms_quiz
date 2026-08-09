// episode.json 하나를 Higgsfield에 붙여 넣을 수 있는 파일들로 펼친다.
//
//   node build_episode.js ep01-agua
//
// 의존성 없음(fs/path만). tools/shorts 의 npm install 과 무관하게 돈다.
//
// 캐릭터·스타일 서술을 episode.json 에 넣지 않고 여기 두는 이유: 이 문자열이
// 편마다 조금씩 달라지면 얼굴이 표류한다. 시리즈 전체가 같은 상수를 쓰게 강제한다.

import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));

/** 프롬프트에 그대로 들어가는 인물 서술. 한 글자도 바꾸지 않는다. */
const CHARACTERS = {
  MADRE: 'MADRE: Spanish woman in her 40s from Madrid, round face, warm olive skin, wavy shoulder-length dark brown hair, thick eyebrows, small round eyes, small gold hoop earrings, terracotta short-sleeve blouse, warm sand wide pants, terracotta crossbody bag, brown leather sandals.',
  PADRE: 'PADRE: Spanish man in his 40s from Madrid, long narrow face, warm olive skin, receding dark brown hair, light stubble, square dark-rimmed glasses, muted teal short-sleeve shirt tucked into warm grey-brown slacks, permanently deadpan half-lidded eyes.',
  HIJA: 'HIJA: Spanish girl, 17, long wavy dark brown hair, oval face, warm olive skin, cream t-shirt, muted teal denim shorts, cream sneakers, phone in hand.',
  HIJO: 'HIJO: Spanish boy, 10, messy curly dark brown hair, round cheeks, freckles across the nose, mustard striped t-shirt, muted teal shorts, brown leather sandals.',
};

const ep = JSON.parse(readFileSync(join(HERE, process.argv[2] || 'ep01-agua', 'episode.json'), 'utf8'));
const dir = join(HERE, ep.id);

// 글자 금지는 네거티브에 넣어도 무시당한다(첫 시트에 라벨이 그대로 박혔다).
// 본문 지시로 올려야 먹는다.
const NO_TEXT = 'Absolutely no lettering, no labels, no captions, no signage text anywhere in the image.';

/** 샷 하나의 이미지 프롬프트. 스타일 → 팔레트 → 인물 → 샷 → 네거티브 순서를 고정한다. */
function imagePrompt(shot) {
  const cast = shot.cast.map((k) => (k === 'NPC' ? ep.npc : CHARACTERS[k])).filter(Boolean);
  return [
    `STYLE: ${ep.style}`,
    `PALETTE (strict, use only these): ${ep.palette}`,
    cast.join('\n\n'),
    `SHOT ${shot.n}: ${shot.shotDescription} ${NO_TEXT}`,
    `NEGATIVE: ${ep.negative}`,
  ].filter(Boolean).join('\n\n');
}

const IMG = ep.budget.images.model;
const VID = ep.budget.videos.model;

// ── shots.md ────────────────────────────────────────────────────────────────
const md = [`# ${ep.id} — \`${ep.target.es}\``, '', `> ${ep.situation}`, '',
  `목표 표현은 샷 ${ep.shots.filter((s) => s.es === ep.target.es).map((s) => s.n).join('·')} 에서 ${ep.shots.filter((s) => s.es === ep.target.es).length}번 나온다.`,
  '', `예상 비용: 이미지 ${ep.budget.images.count}장 ${ep.budget.images.credits} + 영상 ${ep.budget.videos.count}편 ${ep.budget.videos.credits} = **${ep.budget.total} 크레딧**`, ''];

for (const s of ep.shots) {
  md.push(`## SHOT ${s.n} — ${s.start.toFixed(1)}s ~ ${(s.start + s.dur).toFixed(1)}s`, '');
  md.push('**이미지 프롬프트**', '', '```', imagePrompt(s), '```', '');
  md.push('**모션 프롬프트**', '', '```', s.motionPrompt, '```', '');
  const rows = [];
  for (const l of s.lines ?? []) {
    rows.push(`- **${l.who}**: \`${l.es}\`${l.highlight ? ' ← 핵심 표현 (크게)' : ''}`);
    for (const lang of ep.langs) if (l.sub?.[lang]) rows.push(`  - ${lang}: ${l.sub[lang]}`);
  }
  for (const lang of ep.langs) if (s.note?.[lang]) rows.push(`- 해설 자막(${lang}): ${s.note[lang]}`);
  if (s.onScreen) rows.push(`- 화면 대문 자막: \`${s.onScreen}\``);
  md.push(...rows, '');
}
writeFileSync(join(dir, 'shots.md'), md.join('\n'));

// ── run.sh ──────────────────────────────────────────────────────────────────
// 이미지 → 영상 순서. 이미지 결과를 frames/ 에 받아 두고 start_image 로 넘긴다.
const sh = ['#!/usr/bin/env bash', 'set -euo pipefail', '',
  `# ${ep.id} — 총 ${ep.budget.total} 크레딧`,
  '#',
  '# 각 단계는 결과 URL만 출력한다. 다음 단계로 넘어가기 전에 그 URL을 지정된',
  '# 경로로 내려받아야 한다. 자동화하지 않은 건 매 단계에서 눈으로 보고',
  '# 다시 뽑을지 정해야 하기 때문이다.',
  '',
  `# 0단계: 캐릭터 시트 (${ep.budget.images.creditsEach} cr). 마음에 들 때까지 여기서만 다시 뽑는다.`,
  '#         결과를 charsheet.png 로 저장한다. 시리즈 전체가 이 한 장을 재사용한다.',
  `higgsfield generate create ${IMG} --aspect_ratio 16:9 --wait --prompt "$(cat prompts/00-charsheet.txt)"`,
  '',
  '# 1단계: 키프레임 8장. 캐릭터 시트를 레퍼런스로 물린다. → frames/NN.png', ''];
for (const s of ep.shots) {
  const ref = s.cast.length ? ' --image charsheet.png' : '';
  sh.push(`# --- SHOT ${s.n} 키프레임 (${ep.budget.images.creditsEach} cr) ---`,
    `higgsfield generate create ${IMG} --aspect_ratio 9:16${ref} --wait --prompt "$(cat prompts/${String(s.n).padStart(2, '0')}.txt)"`, '');
}
sh.push('# 2단계: 키프레임 → 영상. frames/NN.png 가 다 있어야 한다.', '');
for (const s of ep.shots) {
  sh.push(`# --- SHOT ${s.n} 영상 (${ep.budget.videos.creditsEach} cr) ---`,
    `higgsfield generate create ${VID} \\`,
    `  --start-image frames/${String(s.n).padStart(2, '0')}.png \\`,
    `  --prompt ${JSON.stringify(s.motionPrompt)} \\`,
    `  --duration ${s.dur} --resolution 1080p --aspect_ratio 9:16 --wait`, '');
}
writeFileSync(join(dir, 'run.sh'), sh.join('\n'));

// 프롬프트를 파일로도 떨어뜨린다 — run.sh 가 cat 으로 읽고, 수동 복붙도 편하다.
mkdirSync(join(dir, 'prompts'), { recursive: true });
for (const s of ep.shots) {
  writeFileSync(join(dir, 'prompts', `${String(s.n).padStart(2, '0')}.txt`), imagePrompt(s));
}
// 캐릭터 시트는 가로 한 장이라 스타일 문구의 9:16 지정을 빼고 넣는다.
writeFileSync(join(dir, 'prompts', '00-charsheet.txt'), [
  `Character reference sheet: a Spanish family of four standing in a row, full body, front view, neutral standing pose, evenly spaced, plain flat cream background, no props. ${NO_TEXT}`,
  `STYLE: ${ep.style.replace(/\s*9:16 vertical, 1080x1920\.\s*$/, '')}`,
  `PALETTE (strict, use only these): ${ep.palette}`,
  Object.values(CHARACTERS).join('\n\n'),
  `NEGATIVE: ${ep.negative}`,
].join('\n\n'));

// ── lumina.md ───────────────────────────────────────────────────────────────
// BytePlus Lumina(Seedance 2.5) 용. Higgsfield 와 달리 키프레임을 따로 굽지 않고
// 캐릭터 시트 한 장을 자료로 올린 뒤 프롬프트에서 @로 물린다. 그래서 프롬프트
// 하나에 스타일·인물·동작·카메라가 다 들어가야 한다.
const REF = '@charsheet';
const lum = [`# ${ep.id} — Lumina (Seedance 2.5) 프롬프트`, '',
  '**먼저 할 것** — `charsheet.png` 를 자료(material)로 업로드하고 이름을 `charsheet` 로 둔다.',
  '프롬프트의 `@charsheet` 가 그 자료를 가리킨다. 시리즈 내내 같은 자료를 재사용한다.', '',
  '**설정** — 9:16 세로 / 최고 해상도 / 5초 / 샷마다 한 번씩 총 8회.', '',
  `**비용** — 1회 ${ep.budget.videos.creditsEach} 크레딧 × ${ep.budget.videos.count} = ${ep.budget.videos.credits}.`, '', '---', ''];

for (const s of ep.shots) {
  const cast = s.cast.map((k) => (k === 'NPC' ? ep.npc : CHARACTERS[k])).filter(Boolean);
  lum.push(`## SHOT ${s.n} — ${s.start.toFixed(0)}s`, '', '```');
  lum.push(`${REF} Keep every character exactly as in the reference sheet — same faces, hair, clothes, colors, proportions.`);
  lum.push('');
  lum.push(`STYLE: ${ep.style}`);
  lum.push('');
  lum.push(`PALETTE (strict, use only these): ${ep.palette}`);
  if (cast.length) lum.push('', cast.join('\n\n'));
  lum.push('', `SCENE: ${s.shotDescription} ${NO_TEXT}`);
  lum.push('', `MOTION: ${s.motionPrompt}`);
  lum.push('', `NEGATIVE: ${ep.negative}`);
  lum.push('```', '');
  for (const l of s.lines ?? []) lum.push(`- ${l.who}: \`${l.es}\`${l.highlight ? ' ★' : ''}`);
  lum.push('');
}
writeFileSync(join(dir, 'lumina.md'), lum.join('\n'));

// ── tts.txt ─────────────────────────────────────────────────────────────────
// 인물별 음성 지정까지 같이 적는다. 한 편에 목소리가 섞이지 않게 하는 게 목적이다.
const VOICE = {
  MADRE: 'es-ES female',
  HIJA: 'es-ES female (younger, faster)',
  PADRE: 'es-ES male (flat, low)',
  HIJO: 'es-ES female (slowest — child)',
  NPC: 'es-ES male',
  NARR: 'es-ES female (slowest)',
};
const tts = [];
for (const s of ep.shots) {
  for (const l of s.lines ?? []) {
    tts.push(`${String(s.n).padStart(2, '0')}\t${l.who}\t${VOICE[l.who] ?? VOICE.NPC}\t${l.es}`);
  }
}
writeFileSync(join(dir, 'tts.txt'), tts.join('\n') + '\n');

// ── dialogue.md ─────────────────────────────────────────────────────────────
// 대사만 위에서 아래로. 이걸 읽어서 대화가 안 이어지면 대본이 틀린 것이다.
const dlg = [`# ${ep.id} — 대화 전문`, '', `> ${ep.situation}`, ''];
if (ep.format === 'dialogue') {
  dlg.push('**핵심 표현**', '');
  for (const s of ep.shots) {
    for (const l of (s.lines ?? []).filter((x) => x.highlight)) {
      dlg.push(`- \`${l.es}\` — ${l.sub?.ko ?? ''}${l.pron ? ` (${l.pron})` : ''}`);
    }
  }
} else {
  dlg.push(`**목표 표현** \`${ep.target.es}\` — ${ep.target.ko} (${ep.target.pron})`);
}
dlg.push('', '---', '');
for (const s of ep.shots) {
  for (const l of s.lines ?? []) {
    dlg.push(`**${l.who}** — \`${l.es}\`${l.highlight ? ' ★' : ''}`);
    for (const lang of ep.langs) if (l.sub?.[lang]) dlg.push(`> ${l.sub[lang]}`);
    dlg.push('');
  }
  for (const lang of ep.langs) if (s.note?.[lang]) dlg.push(`*(해설 자막) ${s.note[lang]}*`, '');
}
writeFileSync(join(dir, 'dialogue.md'), dlg.join('\n'));

// ── subtitles.srt ───────────────────────────────────────────────────────────
const stamp = (t) => {
  const h = String(Math.floor(t / 3600)).padStart(2, '0');
  const m = String(Math.floor((t % 3600) / 60)).padStart(2, '0');
  const s = String(Math.floor(t % 60)).padStart(2, '0');
  const ms = String(Math.round((t % 1) * 1000)).padStart(3, '0');
  return `${h}:${m}:${s},${ms}`;
};
// 자막은 언어별로 따로 뽑는다. 스페인어 줄은 모든 언어가 공유하고 번역 줄만 바뀐다.
for (const lang of ep.langs) {
  const srt = [];
  let i = 1;
  for (const s of ep.shots) {
    const lines = s.lines ?? [];
    // 한 샷에 대사가 둘이면 샷 길이를 반씩 나눠 준다.
    const slot = (s.dur - 0.4) / Math.max(lines.length, 1);
    lines.forEach((l, k) => {
      const from = s.start + 0.2 + k * slot;
      srt.push(`${i++}`, `${stamp(from)} --> ${stamp(from + slot)}`,
        [l.es, l.sub?.[lang]].filter(Boolean).join('\n'), '');
    });
    if (s.note?.[lang]) {
      srt.push(`${i++}`, `${stamp(s.start + 0.2)} --> ${stamp(s.start + s.dur - 0.2)}`, s.note[lang], '');
    }
  }
  writeFileSync(join(dir, `subtitles.${lang}.srt`), srt.join('\n'));

  // captions.<lang>.srt — 번역만. 완성본에 스페인어가 이미 구워져 있으므로
  // 유튜브에 올리는 자막 트랙에 스페인어를 또 넣으면 화면에 두 번 나온다.
  // 시청자가 CC를 켜면 이 파일이 보인다.
  const cc = [];
  let j = 1;
  for (const s of ep.shots) {
    const lines = s.lines ?? [];
    const slot = (s.dur - 0.4) / Math.max(lines.length, 1);
    lines.forEach((l, k) => {
      const text = l.sub?.[lang];
      if (!text) return;
      const from = s.start + 0.2 + k * slot;
      cc.push(`${j++}`, `${stamp(from)} --> ${stamp(from + slot)}`, text, '');
    });
    if (s.note?.[lang]) {
      cc.push(`${j++}`, `${stamp(s.start + 0.2)} --> ${stamp(s.start + s.dur - 0.2)}`, s.note[lang], '');
    }
  }
  writeFileSync(join(dir, `captions.${lang}.srt`), cc.join('\n'));
}

// ── metadata.<lang>.txt ─────────────────────────────────────────────────────
for (const lang of ep.langs) {
  const m = ep.metadata[lang];
  if (!m) continue;
  writeFileSync(join(dir, `metadata.${lang}.txt`), [
    '[title]', m.title, '', '[description]', m.description, '',
    'AI-generated animation.', '',
    '[tags]', m.tags.join(', '), '', '[pinned comment]', m.pinnedComment, '',
  ].join('\n'));
}

// 포맷별 검사. 대본이 늘어나면 사람 눈으로는 못 잡는 것들만 막는다.
const lineCount = ep.shots.reduce((n, s) => n + (s.lines?.length ?? 0), 0);
let summary;

if (ep.format === 'dialogue') {
  // 대화 통편 — 스페인어 없는 샷이 하나라도 있으면 "회화를 따라간다"가 끊긴다.
  const silent = ep.shots.filter((s) => !(s.lines ?? []).length).map((s) => s.n);
  if (silent.length) throw new Error(`${ep.id}: 대사 없는 샷 ${silent.join('·')}. 모든 샷에 스페인어가 있어야 한다.`);
  const keys = ep.shots.flatMap((s) => (s.lines ?? []).filter((l) => l.highlight).map((l) => l.es));
  if (!keys.length) throw new Error(`${ep.id}: highlight 표시된 표현이 하나도 없다.`);
  summary = `핵심 표현 ${keys.length}개`;
} else {
  // 표현 편 — 목표 표현이 정확히 3번, 문자열까지 같게.
  const hits = ep.shots.flatMap((s) => (s.lines ?? []).filter((l) => l.es === ep.target.es).map(() => s.n));
  if (hits.length !== 3) {
    throw new Error(`${ep.id}: 목표 표현이 ${hits.length}번 나왔다 (샷 ${hits.join('·') || '없음'}). 3번이어야 한다.`);
  }
  summary = `목표 표현 샷 ${hits.join('·')}`;
}

console.log(`${ep.id}: 대사 ${lineCount}줄 / ${summary} / 자막·메타 (${ep.langs.join('/')}) / ${ep.budget.total} 크레딧`);
