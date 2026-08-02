// Ports the app's stage-topic matching to JS.
//
// The `theme` field in the problem bank is unreliable (the "greetings" theme
// contains words like `avión`), which is exactly why StagePlan._matchesTopic in
// lib/data/stage_plan.dart matches on keyword sets instead. The videos have to
// group words the same way the app does, so the keyword lists and the matching
// rules are read/ported from that file rather than re-invented here.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const stagePlan = path.resolve(here, '../../lib/data/stage_plan.dart');

function parseStageTopics(source) {
  const start = source.indexOf('const List<StageTopic> kStageTopics = [');
  if (start < 0) throw new Error('kStageTopics not found in stage_plan.dart');
  const block = source.slice(start, source.indexOf('\n];', start));

  const topics = [];
  const topicRe = /StageTopic\(([\s\S]*?)\n  \),/g;
  for (const [, body] of block.matchAll(topicRe)) {
    const id = body.match(/id:\s*'([^']+)'/)?.[1];
    if (!id) continue;

    const section = (name) => {
      const at = body.indexOf(`${name}: {`);
      if (at < 0) return {};
      const chunk = body.slice(at, body.indexOf('\n    },', at));
      const out = {};
      for (const [, lang, text] of chunk.matchAll(
        /StudyLanguage\.(ko|en|ja):\s*'((?:[^'\\]|\\.)*)'/g,
      )) {
        out[lang] = text.replaceAll("\\'", "'");
      }
      return out;
    };

    const keywordsAt = body.indexOf('keywords: {');
    const keywordChunk =
      keywordsAt < 0 ? '' : body.slice(keywordsAt, body.indexOf('\n    },', keywordsAt));
    const keywords = [...keywordChunk.matchAll(/'([^']+)'/g)].map(([, k]) => k);

    topics.push({
      id,
      titles: section('titles'),
      subtitles: section('subtitles'),
      keywords,
    });
  }
  if (!topics.length) throw new Error('kStageTopics parsed to nothing');
  return topics;
}

export const stageTopics = parseStageTopics(readFileSync(stagePlan, 'utf8'));

const ACCENTS = { á: 'a', é: 'e', í: 'i', ó: 'o', ú: 'u', ü: 'u', ñ: 'n' };

function normalize(value) {
  let result = String(value).toLowerCase().trim();
  for (const [from, to] of Object.entries(ACCENTS)) result = result.replaceAll(from, to);
  return result;
}

function tokens(value) {
  return normalize(value)
    .split(/[^a-z0-9]+/)
    .filter(Boolean);
}

function meaningHasKeyword(meaning, keyword) {
  if (keyword.length < 3) return false;
  const needle = tokens(keyword);
  const hay = tokens(meaning);
  if (!needle.length) return false;
  for (let i = 0; i <= hay.length - needle.length; i++) {
    if (needle.every((token, j) => hay[i + j] === token)) return true;
  }
  return false;
}

/** Mirror of StagePlan._matchesTopic. */
export function matchesTopic(entry, topic) {
  const keywords = topic.keywords.map(normalize);
  if (keywords.includes(normalize(entry.term))) return true;
  if (topic.id === 'greetings') return false; // greetings is exact-match only
  const english = entry.meanings?.en ?? '';
  return keywords.some((keyword) => meaningHasKeyword(english, keyword));
}

export function topicById(id) {
  const topic = stageTopics.find((candidate) => candidate.id === id);
  if (!topic) throw new Error(`Unknown stage topic "${id}"`);
  return topic;
}
