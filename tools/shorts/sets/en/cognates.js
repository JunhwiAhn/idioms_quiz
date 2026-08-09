// EN — Spanish words you already know, 9 words.
// 단어·뜻·예문 전부 앱의 문제 은행에서 나온다. 여기서 더하는 건 음차와
// "왜 이미 아는 단어인지" 한 줄뿐.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const bankPath = path.resolve(
  here,
  '../../../../assets/data/dele_a1_a2_b1_problem_bank.enriched.json',
);

const EXTRA = [
  { term: 'hotel', pron: 'oh-TEL', tag: 'places', emoji: '🏨', tip: 'Spelled exactly the same. The h is silent, so it is oh-TEL.' },
  { term: 'hospital', pron: 'os-pee-TAL', tag: 'places', emoji: '🏥', tip: 'Silent h again, and the stress moves to the last syllable.' },
  { term: 'chocolate', pron: 'choh-koh-LAH-teh', tag: 'food', emoji: '🍫', tip: 'English borrowed it via Spanish, which is why it survived intact.' },
  { term: 'animal', pron: 'ah-nee-MAL', tag: 'animals', emoji: '🐶', tip: 'Same letters, different beat. Stress the last syllable: ah-nee-MAL.' },
  { term: 'familia', pron: 'fah-MEE-lyah', tag: 'people', emoji: '👨‍👩‍👧', tip: 'Same root as family. Words ending in -ia are usually feminine.' },
  { term: 'música', pron: 'MOO-see-kah', tag: 'hobbies', emoji: '🎵', tip: 'The accent mark tells you to stress the first syllable.' },
  { term: 'color', pron: 'koh-LOR', tag: 'basics', emoji: '🎨', tip: 'Identical spelling. Just roll the r a little at the end.' },
  { term: 'fruta', pron: 'FROO-tah', tag: 'food', emoji: '🍎', tip: 'One letter off from fruit. Spanish likes to end nouns in -a or -o.' },
  { term: 'banco', pron: 'BAHN-koh', tag: 'places', emoji: '🏦', tip: 'It is bank — but it also means bench, so context decides.' },
];

function loadItems() {
  const bank = JSON.parse(readFileSync(bankPath, 'utf8'));
  const byTerm = new Map(bank.entries.map((entry) => [entry.term.toLowerCase(), entry]));

  return EXTRA.map((extra) => {
    const entry = byTerm.get(extra.term.toLowerCase());
    if (!entry) throw new Error(`"${extra.term}" is not in the problem bank`);
    return {
      ...extra,
      term: entry.term,
      meaning: entry.meanings.en,
      example: entry.example,
      exampleTrans: entry.exampleMeanings.en,
    };
  });
}

export default {
  id: 'cognates',
  title: 'Spanish Words You Already Know',
  theme: 'known',
  thumbnailHint: 'A flat lay of instantly recognisable objects: a chocolate bar, a coffee cup, a small hotel bell.',
  cover: {
    eyebrow: 'SPANISH FOR BEGINNERS',
    line1: 'You already know',
    line2: 'these Spanish words',
    accentLine: 'all 9 of them',
    pill: 'Same spelling — only the sound changes',
  },
  caption: {
    headline: '🇪🇸 9 Spanish words you already know',
    intro: [
      'Starting Spanish feels impossible until you notice this 🥹',
      'These words are spelled almost exactly like English. Only the sound changes 👀',
    ],
    highlight: [
      'The one rule that trips everyone up is the silent h 🤫',
      'hotel is oh-TEL, hospital is os-pee-TAL. The h never makes a sound.',
    ],
    hashtags: [
      'learnspanish', 'spanishforbeginners', 'cognates', 'spanishvocabulary',
      'spanishwords', 'languagelearning', 'studyspanish', 'spanish', 'basicspanish',
      'spanishtips', 'easyspanish', 'spanishclass', 'polyglot', 'languagestudy',
      'vocabulary', 'spanishlessons', 'dele', 'languagehacks',
    ],
  },
  get items() {
    return loadItems();
  },
};
