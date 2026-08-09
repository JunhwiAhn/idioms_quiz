// EN — Essential A1 verbs, 9 verbs.
// 단어·레벨·뜻·예문 전부 문제 은행에서 나온다. 손으로 쓴 건 음차와 활용 팁뿐이고,
// A1 이 아닌 단어가 섞이면 빌드가 실패한다.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const bankPath = path.resolve(
  here,
  '../../../../assets/data/dele_a1_a2_b1_problem_bank.enriched.json',
);

const EXTRA = [
  { term: 'tener', pron: 'teh-NEHR', tag: 'having', emoji: '🤲', tip: 'yo tengo = I have. Spanish also uses it for age: Tengo 30 años.' },
  { term: 'ir', pron: 'eer', tag: 'moving', emoji: '🚶', tip: 'voy a + verb = I am going to. That is the easy future tense.' },
  { term: 'comer', pron: 'koh-MEHR', tag: 'eating', emoji: '🍽️', tip: 'The model -er verb: yo como, tú comes, él come.' },
  { term: 'beber', pron: 'beh-BEHR', tag: 'drinking', emoji: '🥤', tip: 'Conjugates exactly like comer. Learn one, get the other free.' },
  { term: 'vivir', pron: 'bee-BEER', tag: 'living', emoji: '🏠', tip: 'The model -ir verb. Vivo en Seúl = I live in Seoul.' },
  { term: 'hablar', pron: 'ah-BLAR', tag: 'speaking', emoji: '💬', tip: 'Silent h, so it is ah-BLAR. ¿Hablas inglés? = Do you speak English?' },
  { term: 'comprar', pron: 'kohm-PRAR', tag: 'shopping', emoji: '🛍️', tip: 'The model -ar verb. Quiero comprar... = I want to buy...' },
  { term: 'ver', pron: 'behr', tag: 'seeing', emoji: '👀', tip: 'Spanish v sounds closer to an English b. behr, not vehr.' },
  { term: 'gustar', pron: 'goos-TAR', tag: 'liking', emoji: '💛', tip: 'It flips the subject. Me gusta el café = coffee pleases me = I like coffee.' },
];

function loadItems() {
  const bank = JSON.parse(readFileSync(bankPath, 'utf8'));
  const byTerm = new Map(bank.entries.map((entry) => [entry.term.toLowerCase(), entry]));

  return EXTRA.map((extra) => {
    const entry = byTerm.get(extra.term.toLowerCase());
    if (!entry) throw new Error(`"${extra.term}" is not in the problem bank`);
    if (entry.level !== 'A1') throw new Error(`"${extra.term}" is ${entry.level}, not A1`);
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
  id: 'verbs',
  title: 'Essential A1 Verbs',
  theme: 'verbs',
  cover: {
    eyebrow: 'SPANISH FOR BEGINNERS',
    line1: 'Learn these first',
    line2: 'and you can build',
    accentLine: 'real sentences',
    pill: '9 verbs straight from the DELE A1 list',
  },
  caption: {
    headline: '📚 The 9 Spanish verbs to learn first',
    intro: [
      'Memorising nouns never turns into sentences. Verbs do 🥲',
      'These nine are the most-used verbs at DELE A1 level ✍️',
    ],
    highlight: [
      'Start with ir 🚶',
      'voy a + any verb gives you the future tense. You can skip a whole grammar chapter.',
    ],
    hashtags: [
      'learnspanish', 'spanishforbeginners', 'spanishverbs', 'spanishgrammar',
      'spanishvocabulary', 'languagelearning', 'studyspanish', 'spanish',
      'basicspanish', 'dele', 'delea1', 'spanishclass', 'spanishlessons',
      'polyglot', 'languagestudy', 'spanishtips', 'vocabulary', 'conjugation',
    ],
  },
  get items() {
    return loadItems();
  },
};
