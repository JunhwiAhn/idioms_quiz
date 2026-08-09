// A1 필수 동사 9개.
//
// 이 세트는 손으로 쓴 데이터가 하나도 없다. 단어·레벨·뜻·예문 전부 앱의
// 문제 은행에서 나오고, 여기서 더하는 건 한글 음차와 활용 팁뿐이다.
// 은행이 바뀌면 카드도 같이 바뀐다.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const bankPath = path.resolve(
  here,
  '../../../assets/data/dele_a1_a2_b1_problem_bank.enriched.json',
);

const EXTRA = [
  { term: 'tener', pron: '떼네르', tag: '소유', emoji: '🤲', tip: 'yo tengo = 나는 가지고 있다. 나이도 tener 로 말합니다 (Tengo 30 años).' },
  { term: 'ir', pron: '이르', tag: '이동', emoji: '🚶', tip: 'voy a + 동사 = ~할 거예요. 미래를 말하는 가장 쉬운 방법입니다.' },
  { term: 'comer', pron: '꼬메르', tag: '식사', emoji: '🍽️', tip: '-er 동사의 대표. yo como, tú comes 로 규칙적으로 바뀝니다.' },
  { term: 'beber', pron: '베베르', tag: '식사', emoji: '🥤', tip: 'comer 와 활용이 똑같습니다. 하나 외우면 둘이 따라옵니다.' },
  { term: 'vivir', pron: '비비르', tag: '생활', emoji: '🏠', tip: '-ir 동사. Vivo en Seúl = 서울에 살아요. 자기소개 필수 문장이에요.' },
  { term: 'hablar', pron: '아블라르', tag: '대화', emoji: '💬', tip: 'h 는 묵음이라 "하블라르"가 아니라 "아블라르"입니다.' },
  { term: 'comprar', pron: '꼼쁘라르', tag: '쇼핑', emoji: '🛍️', tip: '-ar 동사. Quiero comprar... = ~를 사고 싶어요. 쇼핑에서 바로 씁니다.' },
  { term: 'ver', pron: '베르', tag: '감각', emoji: '👀', tip: 'v 는 영어 v 보다 ㅂ 에 가깝게 소리납니다.' },
  { term: 'gustar', pron: '구스따르', tag: '취향', emoji: '💛', tip: '주어가 뒤집힙니다. Me gusta el café = 커피가 나를 기쁘게 한다 → 커피 좋아해요.' },
];

function loadItems() {
  const bank = JSON.parse(readFileSync(bankPath, 'utf8'));
  const byTerm = new Map(bank.entries.map((entry) => [entry.term.toLowerCase(), entry]));

  return EXTRA.map((extra) => {
    const entry = byTerm.get(extra.term.toLowerCase());
    if (!entry) throw new Error(`"${extra.term}" 이(가) 문제 은행에 없습니다`);
    if (entry.level !== 'A1') throw new Error(`"${extra.term}" 은(는) A1 이 아닙니다 (${entry.level})`);
    return {
      ...extra,
      term: entry.term,
      meaning: entry.meanings.ko,
      example: entry.example,
      exampleKo: entry.exampleMeanings.ko,
    };
  });
}

export default {
  id: 'verbs',
  title: 'A1 필수 동사',
  theme: 'verbs',
  cover: {
    eyebrow: '왕초보 스페인어',
    line1: '이것부터 외우면',
    line2: '문장이 만들어지는',
    accentLine: 'A1 동사 9개',
    pill: 'DELE A1 단어장에서 그대로',
  },
  caption: {
    headline: '📚 이것부터 외우면 문장이 되는 A1 동사 9개',
    intro: [
      '단어를 아무리 외워도 문장이 안 되는 건 동사가 없어서예요 🥲',
      'DELE A1 수준에서 가장 많이 쓰이는 동사만 9개 골랐어요 ✍️',
    ],
    highlight: [
      '제일 먼저 챙길 건 ir 예요 🚶',
      'voy a + 동사 하나면 "~할 거예요"가 전부 해결돼요. 미래시제 안 배워도 됩니다!',
    ],
    hashtags: [
      '스페인어', '스페인어공부', '왕초보스페인어', '스페인어독학', '스페인어단어',
      '스페인어문법', '스페인어동사', '스페인어회화', '어학공부', '외국어공부',
      '공부스타그램', 'DELE', '델레', '스페인어시험', 'DELEA1',
      '스페인어초보', '언어공부', '스페인어기초',
    ],
  },
  get items() {
    return loadItems();
  },
};
