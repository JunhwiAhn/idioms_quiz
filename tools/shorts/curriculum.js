// Picks the words for the 20-episode beginner series out of the app's problem
// bank. Selection is deterministic: the same bank always yields the same
// episodes, so re-rendering one episode never reshuffles the others.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { stageTopics, matchesTopic } from './topics.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const bankPath = path.resolve(
  here,
  '../../assets/data/dele_a1_a2_b1_problem_bank.enriched.json',
);

export const WORDS_PER_EPISODE = 5;
export const LANGS = ['ko', 'en', 'ja'];
export const LEVELS = ['A1', 'A2'];

/**
 * Day-by-day plan for someone who has never touched Spanish: concrete nouns
 * they can point at first, core verbs once there is something to talk about,
 * then situations, and abstract/linking words last.
 *
 * The `greetings` topic is deliberately absent — the problem bank has no
 * greeting words at all (see README), so it cannot fill an episode yet.
 */
const PLAN = [
  'meals',
  'meals',
  'home',
  'day_time',
  'action_verbs',
  'action_verbs',
  'people_body',
  'places',
  'places',
  'directions',
  'travel',
  'travel',
  'school',
  'school',
  'work_money',
  'work_money',
  'nature_weather',
  'connectors',
  'connectors',
  'ideas_feelings',
];

const LEVEL_RANK = { A1: 1, A2: 2, B1: 3, B2: 4, C1: 5 };

function isComplete(entry) {
  const meanings = entry.meanings ?? {};
  const exampleMeanings = entry.exampleMeanings ?? {};
  return (
    entry.term &&
    entry.example &&
    LANGS.every((lang) => meanings[lang] && exampleMeanings[lang])
  );
}

/**
 * Beginner-friendly first: easiest level, then lowest difficulty, then the
 * shortest example sentence (fewer unknown words surrounding the target), then
 * alphabetical so ties never depend on bank ordering.
 */
function beginnerOrder(a, b) {
  return (
    (LEVEL_RANK[a.level] ?? 9) - (LEVEL_RANK[b.level] ?? 9) ||
    (a.difficulty ?? 9) - (b.difficulty ?? 9) ||
    a.example.length - b.example.length ||
    a.term.localeCompare(b.term, 'es')
  );
}

export function loadBank() {
  const bank = JSON.parse(readFileSync(bankPath, 'utf8'));
  return bank.entries.filter(
    (entry) => LEVELS.includes(entry.level) && isComplete(entry),
  );
}

/** Assign each word to the first topic that claims it, exactly like StagePlan. */
export function wordsByTopic(pool) {
  const claimed = new Set();
  const byTopic = new Map();
  for (const topic of stageTopics) {
    const matched = pool.filter(
      (entry) => !claimed.has(entry.term) && matchesTopic(entry, topic),
    );
    matched.forEach((entry) => claimed.add(entry.term));
    matched.sort(beginnerOrder);
    byTopic.set(topic.id, matched);
  }
  return byTopic;
}

export function buildSeries() {
  const byTopic = wordsByTopic(loadBank());
  const taken = new Map();
  const partCount = new Map();

  return PLAN.map((topicId, index) => {
    const entries = byTopic.get(topicId) ?? [];
    const offset = taken.get(topicId) ?? 0;
    const words = entries.slice(offset, offset + WORDS_PER_EPISODE);
    if (words.length < WORDS_PER_EPISODE) {
      throw new Error(
        `Topic "${topicId}" has only ${words.length} words left for day ${index + 1}`,
      );
    }
    taken.set(topicId, offset + WORDS_PER_EPISODE);
    const part = (partCount.get(topicId) ?? 0) + 1;
    partCount.set(topicId, part);

    return {
      day: index + 1,
      id: `ep${String(index + 1).padStart(2, '0')}`,
      topicId,
      part,
      totalParts: PLAN.filter((id) => id === topicId).length,
      words,
    };
  });
}
