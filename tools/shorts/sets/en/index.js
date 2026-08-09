// 영어판 카드 세트 목록 (10세트 × 10장).
//
// 한국어판(sets/index.js)과 세트 구성이 조금 다르다. 영어권 학습자에게는
// "이미 아는 단어"·"발음 규칙"·"자기소개"의 가치가 더 커서 앞쪽에 배치했고,
// 여행 시리즈는 사이사이에 끼워 넣어 피드가 단조로워지지 않게 했다.

import travel from './travel.js';
import restaurant from './restaurant.js';
import shopping from './shopping.js';
import transport from './transport.js';
import hotel from './hotel.js';
import falseFriends from './false_friends.js';
import cognates from './cognates.js';
import numbers from './numbers.js';
import pronunciation from './pronunciation.js';
import smalltalk from './smalltalk.js';

// 표지의 스와이프 유도 문구는 card_base 기본값이 한국어라, 영어판에서는
// 여기서 한 번에 덮어쓴다. 세트 파일마다 적어 두면 빠뜨리기 쉽다.
const SWIPE_LABEL = 'Swipe to see all';

export const SETS = [
  travel, restaurant, shopping, transport, hotel,
  falseFriends, cognates, numbers, pronunciation, smalltalk,
].map((set) => ({ ...set, swipeLabel: SWIPE_LABEL }));

/** 발행 순서 — 후킹형(false friends / cognates)과 레퍼런스형을 번갈아 둔다. */
export const RELEASE_ORDER = [
  'false-friends',
  'travel',
  'cognates',
  'restaurant',
  'pronunciation',
  'transport',
  'smalltalk',
  'shopping',
  'numbers',
  'hotel',
];
