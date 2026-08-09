// "여행가서 꼭 쓰는 스페인어" 카드뉴스용 데이터.
//
// false_friends.js 와 달리 이 세트는 문제 은행에서 가져오지 못한다. 인사말과
// 관용 표현(hola, gracias, por favor, ¿cuánto cuesta? …)이 은행에 없기 때문이다
// (README "알려진 제약" 참고). 그래서 뜻·예문·해설을 여기 직접 적어 둔다.
// 은행에 인사말이 추가되면 sí / no / baño / agua 처럼 겹치는 항목부터
// false_friends.js 와 같은 방식으로 은행 참조로 바꾸는 게 좋다.
//
// pron: 한글 음차. 기계 음차는 오류가 잦아 Shorts 쪽에서는 넣지 않았지만,
// 카드뉴스는 소리를 들려줄 수 없어서 직접 적은 음차를 넣는다.

/**
 * tag: 카드 우상단 배지 / tip: 카드 하단 한 줄 해설
 * image: images/travel/<image>.jpg 배경 사진. 없으면 그라데이션으로 대체된다.
 */
export const TRAVEL_PHRASES = [
  {
    term: 'Hola',
    pron: '올라',
    meaning: '안녕하세요',
    tag: '인사',
    example: '¡Hola! Buenos días.',
    exampleKo: '안녕하세요! 좋은 아침이에요.',
    image: '01-hola',
    tip: '가장 기본적인 인사. 가게에 들어갈 때 먼저 건네면 분위기가 달라집니다.',
  },
  {
    term: 'Gracias',
    pron: '그라시아스',
    meaning: '감사합니다',
    tag: '인사',
    example: 'Muchas gracias.',
    exampleKo: '정말 감사합니다.',
    image: '02-gracias',
    tip: '여행 중 가장 많이 쓰게 될 단어 1위. muchas 를 붙이면 더 정중해집니다.',
  },
  {
    term: 'Por favor',
    pron: '뽀르 파보르',
    meaning: '부탁드려요 / ~해 주세요',
    tag: '부탁',
    example: 'Un café, por favor.',
    exampleKo: '커피 한 잔 주세요.',
    image: '03-por-favor',
    tip: '주문하거나 부탁할 때 끝에 붙이기만 하면 훨씬 정중한 말이 됩니다.',
  },
  {
    term: 'Sí / No',
    pron: '씨 / 노',
    meaning: '네 / 아니요',
    tag: '대답',
    example: 'Sí, gracias. / No, gracias.',
    exampleKo: '네, 감사합니다. / 아니요, 괜찮습니다.',
    image: '04-si-no',
    tip: '간단하지만 필수. 거절할 때도 gracias 를 붙이면 부드럽게 들립니다.',
  },
  {
    term: '¿Cuánto cuesta?',
    pron: '꾸안또 꾸에스따',
    meaning: '얼마예요?',
    tag: '쇼핑',
    example: '¿Cuánto cuesta esto?',
    exampleKo: '이거 얼마예요?',
    image: '05-cuanto-cuesta',
    tip: '시장이나 상점에서 필수 질문. 물건을 가리키며 말하면 됩니다.',
  },
  {
    term: '¿Dónde está...?',
    pron: '돈데 에스따',
    meaning: '~가 어디예요?',
    tag: '길찾기',
    example: '¿Dónde está el baño?',
    exampleKo: '화장실이 어디예요?',
    image: '06-donde-esta',
    tip: '뒤에 장소만 바꿔 끼우면 되는, 가장 활용도 높은 문장 틀입니다.',
  },
  {
    term: 'Baño',
    pron: '바뇨',
    meaning: '화장실',
    tag: '장소',
    example: '¿Hay baño aquí?',
    exampleKo: '여기 화장실 있어요?',
    image: '07-bano',
    tip: '급할 때 꼭 필요한 단어. 스페인에서는 servicio 라고도 합니다.',
  },
  {
    term: 'Agua',
    pron: '아구아',
    meaning: '물',
    tag: '주문',
    example: 'Agua, por favor.',
    exampleKo: '물 주세요.',
    image: '08-agua',
    tip: '이 두 단어만으로 주문 완료. 수돗물은 agua del grifo 입니다.',
  },
  {
    term: 'Ayuda',
    pron: '아유다',
    meaning: '도움',
    tag: '긴급',
    example: '¡Ayuda, por favor!',
    exampleKo: '도와주세요!',
    image: '09-ayuda',
    tip: '도움이 필요할 때 외치는 말. 한 단어만 알아도 상황이 전달됩니다.',
  },
  {
    term: 'Lo siento / Perdón',
    pron: '로 시엔또 / 뻬르돈',
    meaning: '죄송합니다 / 실례합니다',
    tag: '사과',
    example: 'Perdón, ¿puedo pasar?',
    exampleKo: '실례합니다, 지나가도 될까요?',
    image: '10-perdon',
    tip: '사과는 lo siento, 지나가거나 말을 걸 때는 perdón 을 씁니다.',
  },
];
