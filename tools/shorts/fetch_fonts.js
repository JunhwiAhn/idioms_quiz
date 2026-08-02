// Downloads the static Noto Sans KR weights the renderer needs.
//
// The app ships NotoSansKR-VF.ttf, but resvg ignores variable-font weight axes,
// so bold headlines need real static faces. These live outside git (see
// .gitignore) because they are ~5 MB each.

import { mkdirSync, existsSync, writeFileSync, statSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.join(here, 'fonts');

const BASE =
  'https://cdn.jsdelivr.net/gh/notofonts/noto-cjk@main/Sans/SubsetOTF/KR';
const FILES = ['NotoSansKR-Bold.otf', 'NotoSansKR-Medium.otf'];

mkdirSync(outDir, { recursive: true });

for (const name of FILES) {
  const target = path.join(outDir, name);
  if (existsSync(target) && statSync(target).size > 1_000_000) {
    console.log(`ok       ${name}`);
    continue;
  }
  process.stdout.write(`fetching ${name} ... `);
  const res = await fetch(`${BASE}/${name}`);
  if (!res.ok) throw new Error(`${res.status} ${res.statusText} for ${name}`);
  const buffer = Buffer.from(await res.arrayBuffer());
  if (buffer.subarray(0, 4).toString('latin1') !== 'OTTO') {
    throw new Error(`${name} is not an OpenType font (got ${buffer.length} bytes)`);
  }
  writeFileSync(target, buffer);
  console.log(`${(buffer.length / 1e6).toFixed(1)} MB`);
}

console.log('\nFonts ready. Licensed under the SIL Open Font License 1.1.');
