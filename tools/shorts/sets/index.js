// 카드 세트 목록 + 발행 순서.
//
// 순서는 의도적으로 섞었다. 여행 시리즈(식당·쇼핑·교통·호텔)가 연달아 나가면
// 피드가 단조로워지고, 반대로 학습형(발음·동사)만 이어지면 도달이 떨어진다.
// 그래서 여행형과 학습형을 번갈아 배치했다.

import restaurant from './restaurant.js';
import shopping from './shopping.js';
import transport from './transport.js';
import hotel from './hotel.js';
import known from './known.js';
import numbers from './numbers.js';
import pronunciation from './pronunciation.js';
import verbs from './verbs.js';

/** build_sets.js 가 렌더링하는 세트들 (표지 + 항목 9 = 10장). */
export const SETS = [restaurant, shopping, transport, hotel, known, numbers, pronunciation, verbs];

/**
 * 발행 순서. `falseFriends` 는 레이아웃이 달라 build_cards.js 가 따로 굽는다
 * (표지 + 단어 7 + CTA = 9장). 순서에만 자리를 잡아 둔다.
 */
export const RELEASE_ORDER = [
  { id: 'falseFriends', built: 'build_cards.js', out: 'out/cards' },
  { id: 'restaurant' },
  { id: 'known' },
  { id: 'shopping' },
  { id: 'pronunciation' },
  { id: 'transport' },
  { id: 'numbers' },
  { id: 'hotel' },
  { id: 'verbs' },
];
