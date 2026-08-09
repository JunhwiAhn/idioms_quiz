// 이미 아는 스페인어 9개 — 영어와 거의 같은 단어들.
//
// 단어·뜻·예문은 앱의 문제 은행에서 그대로 가져온다. 여기에는 은행에 없는
// 축, 즉 "한글 음차"와 "왜 이미 아는 단어인지"만 덧붙인다.
// (false_friends.js 와 같은 방식. 손으로 쓴 데이터가 아니라 앱 데이터다.)

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const bankPath = path.resolve(
  here,
  '../../../assets/data/dele_a1_a2_b1_problem_bank.enriched.json',
);

const PAIRS = [
  { term: 'hotel', pron: '오뗄', tag: '숙소', emoji: '🏨', tip: '철자가 영어와 완전히 같습니다. h 는 묵음이라 "오뗄"로 읽어요.' },
  { term: 'hospital', pron: '오스삐딸', tag: '장소', emoji: '🏥', tip: '역시 h 는 묵음. 급할 때 이 단어 하나면 통합니다.' },
  { term: 'chocolate', pron: '초꼴라떼', tag: '음식', emoji: '🍫', tip: '원래 스페인어를 거쳐 영어로 간 단어라 철자가 같습니다.' },
  { term: 'animal', pron: '아니말', tag: '동물', emoji: '🐶', tip: '강세만 뒤에 있습니다. "애니멀"이 아니라 "아니말".' },
  { term: 'familia', pron: '파밀리아', tag: '사람', emoji: '👨‍👩‍👧', tip: 'family 와 뿌리가 같습니다. -ia 로 끝나는 단어는 대개 여성명사예요.' },
  { term: 'música', pron: '무시까', tag: '취미', emoji: '🎵', tip: 'music 그대로. 강세 표시가 붙어 앞을 세게 읽습니다.' },
  { term: 'color', pron: '꼴로르', tag: '색', emoji: '🎨', tip: '철자가 영어와 같습니다. r 을 살짝 굴려 주세요.' },
  { term: 'fruta', pron: '프루따', tag: '음식', emoji: '🍎', tip: 'fruit 과 한 글자 차이. 스페인어는 끝을 -a 로 맞춥니다.' },
  { term: 'banco', pron: '방꼬', tag: '장소', emoji: '🏦', tip: 'bank 입니다. 다만 "벤치"라는 뜻도 있어서 문맥으로 갈립니다.' },
];

function loadItems() {
  const bank = JSON.parse(readFileSync(bankPath, 'utf8'));
  const byTerm = new Map(bank.entries.map((entry) => [entry.term.toLowerCase(), entry]));

  return PAIRS.map((pair) => {
    const entry = byTerm.get(pair.term.toLowerCase());
    if (!entry) throw new Error(`"${pair.term}" 이(가) 문제 은행에 없습니다`);
    return {
      ...pair,
      term: entry.term,
      meaning: `${entry.meanings.ko}  ·  ${entry.meanings.en}`,
      example: entry.example,
      exampleKo: entry.exampleMeanings.ko,
    };
  });
}

export default {
  id: 'known',
  title: '이미 아는 스페인어',
  theme: 'known',
  cover: {
    eyebrow: '왕초보 스페인어',
    line1: '사실 이미 알고 있는',
    line2: '스페인어 단어',
    accentLine: '9개',
    pill: '영어랑 똑같이 생겼습니다',
  },
  caption: {
    headline: '🇪🇸 사실 이미 알고 있는 스페인어 단어 9개',
    intro: [
      '스페인어 처음이라 막막하신가요? 생각보다 이미 많이 알고 계세요 🥹',
      '영어랑 철자가 거의 같은 단어들만 모아봤어요. 읽는 법만 살짝 다릅니다 👀',
    ],
    highlight: [
      '포인트는 h 가 묵음이라는 거예요 🤫',
      'hotel 은 "호텔"이 아니라 "오뗄", hospital 은 "오스삐딸"!',
    ],
    hashtags: [
      '스페인어', '스페인어공부', '왕초보스페인어', '스페인어독학', '스페인어단어',
      '스페인어회화', '스페인어초보', '어학공부', '외국어공부', '공부스타그램',
      '스페인여행', '여행스페인어', 'DELE', '델레', '스페인어시험',
      '스페인어기초', '언어공부', '독학',
    ],
  },
  get items() {
    return loadItems();
  },
};
