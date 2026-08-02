// Reads the localized theme titles straight out of lib/data/stage_plan.dart so
// the videos and the app never drift apart. The Dart file is the single source
// of truth for ko/en/ja copy — that is what makes the EN/JA channels free.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const stagePlan = path.resolve(here, '../../lib/data/stage_plan.dart');

function parseMap(source, mapName) {
  const start = source.indexOf(`const Map<String, Map<StudyLanguage, String>> ${mapName} = {`);
  if (start < 0) throw new Error(`${mapName} not found in stage_plan.dart`);
  const body = source.slice(start);
  const end = body.indexOf('\n};');
  if (end < 0) throw new Error(`${mapName} is not terminated`);
  const block = body.slice(0, end);

  const out = {};
  const entryRe = /'([a-z_0-9]+)':\s*\{([\s\S]*?)\},/g;
  for (const [, theme, inner] of block.matchAll(entryRe)) {
    const langRe = /StudyLanguage\.(ko|en|ja):\s*'((?:[^'\\]|\\.)*)'/g;
    const langs = {};
    for (const [, lang, text] of inner.matchAll(langRe)) {
      langs[lang] = text.replaceAll("\\'", "'").replaceAll('\\\\', '\\');
    }
    if (langs.ko && langs.en && langs.ja) out[theme] = langs;
  }
  if (Object.keys(out).length === 0) throw new Error(`${mapName} parsed to nothing`);
  return out;
}

const source = readFileSync(stagePlan, 'utf8');

export const themeTitles = parseMap(source, '_themeTitles');
export const themeSubtitles = parseMap(source, '_themeSubtitles');

export function themeCopy(theme, lang) {
  const title = themeTitles[theme]?.[lang];
  const subtitle = themeSubtitles[theme]?.[lang];
  if (!title || !subtitle) {
    throw new Error(`No ${lang} copy for theme "${theme}" in stage_plan.dart`);
  }
  return { title, subtitle };
}
