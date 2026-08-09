// "영어인 줄 알았는데" 카드뉴스용 데이터.
//
// 스페인어 단어·예문·뜻은 앱의 문제 은행에서 그대로 가져오고, 여기에는 은행에
// 없는 정보 — 어떤 영어 단어와 헷갈리는지 — 만 적어 둔다. 즉 이 파일은 데이터
// 중복이 아니라 은행에 없는 축(오해의 축)을 덧붙이는 역할이다.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const bankPath = path.resolve(
  here,
  '../../assets/data/dele_a1_a2_b1_problem_bank.enriched.json',
);

/** term: 은행의 단어 / looksLike: 착각하는 영어 / looksLikeKo: 그 영어의 뜻 */
const PAIRS = [
  { term: 'embarazada', looksLike: 'embarrassed', looksLikeKo: '당황한' },
  { term: 'librería', looksLike: 'library', looksLikeKo: '도서관' },
  { term: 'sopa', looksLike: 'soap', looksLikeKo: '비누' },
  { term: 'carpeta', looksLike: 'carpet', looksLikeKo: '카펫' },
  { term: 'fábrica', looksLike: 'fabric', looksLikeKo: '천, 직물' },
  { term: 'vaso', looksLike: 'vase', looksLikeKo: '꽃병' },
  { term: 'largo', looksLike: 'large', looksLikeKo: '큰' },
];

export function loadFalseFriends() {
  const bank = JSON.parse(readFileSync(bankPath, 'utf8'));
  const byTerm = new Map(bank.entries.map((entry) => [entry.term.toLowerCase(), entry]));

  return PAIRS.map((pair) => {
    const entry = byTerm.get(pair.term.toLowerCase());
    if (!entry) throw new Error(`"${pair.term}" 이(가) 문제 은행에 없습니다`);
    return {
      ...pair,
      level: entry.level,
      meaning: entry.meanings.ko,
      example: entry.example,
      exampleMeaning: entry.exampleMeanings.ko,
    };
  });
}
