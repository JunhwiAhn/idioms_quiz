// EN — False friends, 9 words.
//
// 뜻·예문은 앱의 문제 은행에서 그대로 가져온다 (meanings.en / exampleMeanings.en).
// 여기서 더하는 건 은행에 없는 축 — 어떤 영어 단어와 헷갈리는지 — 뿐이다.
// 한국어판(cards.js)은 오해/실제 대비 전용 레이아웃을 쓰지만, 영어판은
// 다른 세트와 같은 레이아웃을 쓴다. 시리즈 전체가 한 포맷으로 보이는 편이 낫다.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const bankPath = path.resolve(
  here,
  '../../../../assets/data/dele_a1_a2_b1_problem_bank.enriched.json',
);

const PAIRS = [
  { term: 'embarazada', pron: 'em-bah-rah-SAH-dah', looksLike: 'embarrassed', emoji: '😳', tip: 'The classic trap. Estoy embarazada means "I am pregnant", not "I am embarrassed".' },
  { term: 'librería', pron: 'lee-breh-REE-ah', looksLike: 'library', emoji: '📚', tip: 'A library is una biblioteca. A librería sells books.' },
  { term: 'sopa', pron: 'SOH-pah', looksLike: 'soap', emoji: '🍲', tip: 'Soap is jabón. Ordering sopa gets you dinner, not a shower.' },
  { term: 'carpeta', pron: 'kar-PEH-tah', looksLike: 'carpet', emoji: '📁', tip: 'A carpet is una alfombra. carpeta is the folder on your desk.' },
  { term: 'fábrica', pron: 'FAH-bree-kah', looksLike: 'fabric', emoji: '🏭', tip: 'Fabric is tela. A fábrica is where things get made.' },
  { term: 'vaso', pron: 'BAH-soh', looksLike: 'vase', emoji: '🥛', tip: 'A vase is un jarrón. Ask for un vaso de agua and you get a glass.' },
  { term: 'largo', pron: 'LAR-goh', looksLike: 'large', emoji: '📏', tip: 'Large is grande. largo is about length, not size.' },
  { term: 'asistir', pron: 'ah-sees-TEER', looksLike: 'assist', emoji: '🙋', tip: 'To assist is ayudar. asistir means to show up.' },
  { term: 'pie', pron: 'pyeh', looksLike: 'pie', emoji: '🦶', tip: 'A pie is una tarta. In Spanish, pie is the thing in your shoe.' },
];

function loadItems() {
  const bank = JSON.parse(readFileSync(bankPath, 'utf8'));
  const byTerm = new Map(bank.entries.map((entry) => [entry.term.toLowerCase(), entry]));

  return PAIRS.map((pair) => {
    const entry = byTerm.get(pair.term.toLowerCase());
    if (!entry) throw new Error(`"${pair.term}" is not in the problem bank`);
    return {
      ...pair,
      term: entry.term,
      meaning: entry.meanings.en,
      tag: `not "${pair.looksLike}"`,
      example: entry.example,
      exampleTrans: entry.exampleMeanings.en,
    };
  });
}

export default {
  id: 'false-friends',
  title: 'Spanish False Friends',
  theme: 'falseFriends',
  thumbnailHint: 'A split frame with the two confusable objects side by side — a bar of soap and a bowl of soup.',
  cover: {
    eyebrow: 'SPANISH FOR BEGINNERS',
    line1: 'Looks like English',
    line2: 'means something',
    accentLine: 'completely else',
    pill: 'embarazada does NOT mean embarrassed',
  },
  caption: {
    headline: '🇪🇸 9 Spanish words that look English but are not',
    intro: [
      'When you start Spanish, the familiar-looking words jump out first 👀',
      'A few of them mean something completely different. These are the risky ones 🥲',
    ],
    highlight: [
      'Number 1 is the one that will get you 😳',
      'Say Estoy embarazada thinking "I am embarrassed" and you just announced a pregnancy 🙈',
    ],
    hashtags: [
      'learnspanish', 'spanishforbeginners', 'falsefriends', 'spanishvocabulary',
      'spanishwords', 'languagelearning', 'studyspanish', 'spanish', 'basicspanish',
      'spanishtips', 'languagelearningtips', 'spanishclass', 'polyglot',
      'languagestudy', 'spainTravel', 'travelspanish', 'dele', 'vocabulary',
    ],
  },
  get items() {
    return loadItems();
  },
};
