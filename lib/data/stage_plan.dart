import 'dart:math';
import '../models/idiom.dart';

const int kQuestionsPerRound = 10;
const int kMinCorrectToClear = 4;

const List<StageTopic> kStageTopics = [
  StageTopic(
    id: 'greetings',
    titles: {
      StudyLanguage.ko: 'Hola, 첫 인사',
      StudyLanguage.en: 'Hola, First Greetings',
      StudyLanguage.ja: 'Hola、はじめての挨拶',
    },
    subtitles: {
      StudyLanguage.ko: '처음 만나고 헤어질 때 바로 쓰는 말',
      StudyLanguage.en: 'Phrases for meeting and saying goodbye',
      StudyLanguage.ja: '出会いと別れですぐ使う言葉',
    },
    levels: ['A1', 'A2'],
    keywords: {
      'hola',
      'hello',
      'buenos días',
      'buenas tardes',
      'buenas noches',
      'hasta luego',
      'hasta mañana',
      'adiós',
      'goodbye',
      'gracias',
      'thank',
      'por favor',
      'perdón',
      'disculpa',
      'sorry',
      'llamarse',
    },
  ),
  StageTopic(
    id: 'day_time',
    titles: {
      StudyLanguage.ko: '하루의 리듬',
      StudyLanguage.en: 'Rhythm of the Day',
      StudyLanguage.ja: '一日のリズム',
    },
    subtitles: {
      StudyLanguage.ko: '아침, 밤, 오늘, 어제처럼 시간을 말해요',
      StudyLanguage.en: 'Talk about time: morning, night, today, yesterday',
      StudyLanguage.ja: '朝・夜・今日・昨日など時間を話します',
    },
    levels: ['A1', 'C1'],
    keywords: {
      'mañana',
      'morning',
      'tomorrow',
      'tarde',
      'afternoon',
      'noche',
      'night',
      'día',
      'day',
      'tiempo',
      'time',
      'hoy',
      'today',
      'ayer',
      'yesterday',
      'siempre',
      'always',
      'nunca',
      'never',
      'a veces',
    },
  ),
  StageTopic(
    id: 'meals',
    titles: {
      StudyLanguage.ko: '식탁 위 스페인어',
      StudyLanguage.en: 'Spanish at the Table',
      StudyLanguage.ja: '食卓のスペイン語',
    },
    subtitles: {
      StudyLanguage.ko: '먹고 마시고 주문할 때 자주 만나는 말',
      StudyLanguage.en: 'Common words for eating, drinking, and ordering',
      StudyLanguage.ja: '食べる・飲む・注文でよく出会う言葉',
    },
    levels: ['A1', 'B1', 'B2'],
    keywords: {
      'comida',
      'food',
      'bebida',
      'drink',
      'agua',
      'water',
      'pan',
      'bread',
      'café',
      'coffee',
      'leche',
      'milk',
      'cocina',
      'kitchen',
      'mesa',
      'table',
      'plato',
      'plate',
      'desayunar',
      'breakfast',
      'comer',
      'eat',
      'cenar',
      'dinner',
      'barato',
      'cheap',
      'caro',
      'expensive',
    },
  ),
  StageTopic(
    id: 'home',
    titles: {
      StudyLanguage.ko: '우리 집 한 바퀴',
      StudyLanguage.en: 'Around the House',
      StudyLanguage.ja: 'おうちをひとまわり',
    },
    subtitles: {
      StudyLanguage.ko: '방, 문, 창문, 가구처럼 생활 공간을 익혀요',
      StudyLanguage.en: 'Rooms, doors, windows, and furniture',
      StudyLanguage.ja: '部屋・ドア・窓・家具など生活空間の言葉',
    },
    levels: ['A1', 'A2', 'B1', 'B2'],
    keywords: {
      'casa',
      'habitación',
      'mesa',
      'silla',
      'puerta',
      'ventana',
      'cocina',
      'baño',
      'abrir',
      'cerrar',
    },
  ),
  StageTopic(
    id: 'places',
    titles: {
      StudyLanguage.ko: '동네 산책',
      StudyLanguage.en: 'A Walk in Town',
      StudyLanguage.ja: '街をおさんぽ',
    },
    subtitles: {
      StudyLanguage.ko: '거리, 광장, 가게, 병원까지 동네 단어',
      StudyLanguage.en: 'Streets, squares, shops, and the hospital',
      StudyLanguage.ja: '通り・広場・お店・病院など街の単語',
    },
    levels: ['A1', 'A2', 'B1'],
    keywords: {
      'ciudad',
      'pueblo',
      'calle',
      'plaza',
      'tienda',
      'mercado',
      'banco',
      'farmacia',
      'hospital',
      'policía',
      'oficina',
    },
  ),
  StageTopic(
    id: 'travel',
    titles: {
      StudyLanguage.ko: '여행 가방 챙기기',
      StudyLanguage.en: 'Packing for a Trip',
      StudyLanguage.ja: '旅行かばんの準備',
    },
    subtitles: {
      StudyLanguage.ko: '교통, 호텔, 여권, 짐처럼 여행 필수어',
      StudyLanguage.en: 'Travel essentials: transport, hotels, passports',
      StudyLanguage.ja: '交通・ホテル・パスポートなど旅の必須語',
    },
    levels: ['A1', 'A2', 'B1'],
    keywords: {
      'coche',
      'autobús',
      'tren',
      'avión',
      'billete',
      'viaje',
      'viajar',
      'pasaporte',
      'aeropuerto',
      'estación',
      'hotel',
      'maleta',
      'playa',
      'montaña',
      'país',
    },
  ),
  StageTopic(
    id: 'directions',
    titles: {
      StudyLanguage.ko: '길 찾는 감각',
      StudyLanguage.en: 'Finding Your Way',
      StudyLanguage.ja: '道を探す感覚',
    },
    subtitles: {
      StudyLanguage.ko: '지도, 주소, 여기, 저기, 가깝고 먼 곳',
      StudyLanguage.en: 'Maps, addresses, here and there, near and far',
      StudyLanguage.ja: '地図・住所・ここ・あそこ、近くと遠く',
    },
    levels: ['A1', 'B1', 'B2', 'C1'],
    keywords: {
      'mapa',
      'dirección',
      'aquí',
      'allí',
      'cerca',
      'lejos',
      'entrar',
      'salir',
      'llegar',
      'venir',
      'ir',
    },
  ),
  StageTopic(
    id: 'school',
    titles: {
      StudyLanguage.ko: '교실에서 쓰는 말',
      StudyLanguage.en: 'Classroom Words',
      StudyLanguage.ja: '教室で使う言葉',
    },
    subtitles: {
      StudyLanguage.ko: '학교, 책, 질문, 시험, 공부에 필요한 단어',
      StudyLanguage.en: 'School, books, questions, exams, and studying',
      StudyLanguage.ja: '学校・本・質問・試験・勉強の単語',
    },
    levels: ['A1', 'A2', 'B1', 'B2'],
    keywords: {
      'escuela',
      'libro',
      'ordenador',
      'universidad',
      'clase',
      'examen',
      'nota',
      'idioma',
      'palabra',
      'pregunta',
      'respuesta',
      'estudiar',
      'aprender',
      'enseñar',
      'leer',
      'escribir',
    },
  ),
  StageTopic(
    id: 'people_body',
    titles: {
      StudyLanguage.ko: '사람과 몸',
      StudyLanguage.en: 'People and the Body',
      StudyLanguage.ja: '人とからだ',
    },
    subtitles: {
      StudyLanguage.ko: '몸, 옷, 나이와 사람 묘사를 가볍게',
      StudyLanguage.en: 'Body, clothes, age, and describing people',
      StudyLanguage.ja: '体・服・年齢、人の描写を気軽に',
    },
    levels: ['A1', 'A2', 'B1', 'C1'],
    keywords: {
      'persona',
      'salud',
      'cuerpo',
      'cabeza',
      'mano',
      'ojo',
      'ropa',
      'zapato',
      'limpio',
      'joven',
      'viejo',
      'pequeño',
      'grande',
    },
  ),
  StageTopic(
    id: 'hobbies',
    titles: {
      StudyLanguage.ko: '주말에 뭐 해?',
      StudyLanguage.en: 'What Do You Do on Weekends?',
      StudyLanguage.ja: '週末は何してる？',
    },
    subtitles: {
      StudyLanguage.ko: '음악, 영화, 운동, 파티처럼 쉬는 날 단어',
      StudyLanguage.en: 'Music, movies, sports, and party words',
      StudyLanguage.ja: '音楽・映画・スポーツ・パーティーの単語',
    },
    levels: ['A2', 'B1', 'B2'],
    keywords: {
      'música',
      'película',
      'deporte',
      'partido',
      'fiesta',
      'regalo',
      'arte',
      'jugar',
      'ganar',
      'perder',
      'caminar',
      'correr',
    },
  ),
  StageTopic(
    id: 'nature_weather',
    titles: {
      StudyLanguage.ko: '날씨와 풍경',
      StudyLanguage.en: 'Weather and Scenery',
      StudyLanguage.ja: '天気と風景',
    },
    subtitles: {
      StudyLanguage.ko: '해, 비, 바람, 산과 바다를 말해요',
      StudyLanguage.en: 'Sun, rain, wind, mountains, and the sea',
      StudyLanguage.ja: '太陽・雨・風、山と海を話します',
    },
    levels: ['A2', 'B1', 'C1'],
    keywords: {
      'naturaleza',
      'animal',
      'flor',
      'árbol',
      'sol',
      'lluvia',
      'viento',
      'frío',
      'calor',
      'playa',
      'montaña',
      'bonito',
    },
  ),
  StageTopic(
    id: 'work_money',
    titles: {
      StudyLanguage.ko: '일하고 계산하기',
      StudyLanguage.en: 'Work and Money',
      StudyLanguage.ja: '働いてお会計',
    },
    subtitles: {
      StudyLanguage.ko: '회사, 돈, 가격, 사고파는 표현',
      StudyLanguage.en: 'Companies, money, prices, buying and selling',
      StudyLanguage.ja: '会社・お金・値段、売り買いの表現',
    },
    levels: ['A1', 'A2', 'B1', 'B2', 'C1'],
    keywords: {
      'trabajo',
      'dinero',
      'precio',
      'empresa',
      'jefe',
      'cliente',
      'proyecto',
      'servicio',
      'comprar',
      'vender',
      'pagar',
      'trabajar',
      'buscar',
      'encontrar',
      'caro',
      'barato',
    },
  ),
  StageTopic(
    id: 'ideas_feelings',
    titles: {
      StudyLanguage.ko: '생각과 마음',
      StudyLanguage.en: 'Thoughts and Feelings',
      StudyLanguage.ja: '考えと気持ち',
    },
    subtitles: {
      StudyLanguage.ko: '생각, 감정, 의견을 말할 때 쓰는 단어',
      StudyLanguage.en: 'Words for thoughts, emotions, and opinions',
      StudyLanguage.ja: '考え・感情・意見を伝える単語',
    },
    levels: ['A2', 'B1', 'B2', 'C1'],
    keywords: {
      'idea',
      'vida',
      'mundo',
      'historia',
      'cultura',
      'problema',
      'pensar',
      'creer',
      'saber',
      'conocer',
      'querer',
      'preferir',
      'gustar',
      'feliz',
      'triste',
      'bueno',
      'malo',
      'importante',
      'posible',
      'necesario',
    },
  ),
  StageTopic(
    id: 'action_verbs',
    titles: {
      StudyLanguage.ko: '움직이는 동사들',
      StudyLanguage.en: 'Verbs in Motion',
      StudyLanguage.ja: '動きの動詞たち',
    },
    subtitles: {
      StudyLanguage.ko: '하다, 있다, 말하다처럼 문장을 만드는 힘',
      StudyLanguage.en: 'Core verbs that power your sentences',
      StudyLanguage.ja: 'する・いる・話すなど文を作る力',
    },
    levels: ['B1', 'B2'],
    keywords: {
      'ser',
      'estar',
      'tener',
      'hacer',
      'vivir',
      'hablar',
      'escuchar',
      'comer',
      'beber',
      'poder',
      'deber',
      'necesitar',
      'esperar',
      'ayudar',
      'cambiar',
      'empezar',
      'terminar',
    },
  ),
  StageTopic(
    id: 'connectors',
    titles: {
      StudyLanguage.ko: '말을 이어주는 조각',
      StudyLanguage.en: 'Connecting Pieces',
      StudyLanguage.ja: '言葉をつなぐピース',
    },
    subtitles: {
      StudyLanguage.ko: '하지만, 그래서, 언제처럼 문장을 연결해요',
      StudyLanguage.en: 'Link sentences with but, so, and when',
      StudyLanguage.ja: 'でも・だから・いつ、で文をつなぎます',
    },
    levels: ['A2', 'B1', 'C1'],
    keywords: {
      'aunque',
      'cuando',
      'tener que',
      'ir a',
      'porque',
      'pero',
      'también',
      'muy',
      'poco',
      'mucho',
      'más',
      'menos',
      'antes',
      'después',
      'fácil',
      'difícil',
      'rápido',
      'lento',
    },
  ),
];

bool roundFailed({required int correct}) => correct < kMinCorrectToClear;

bool idiomMatchesTopic(Idiom entry, StageTopic topic) =>
    StagePlan._matchesTopic(entry, topic);

int starsForRound({required int correct, int total = kQuestionsPerRound}) {
  if (correct < kMinCorrectToClear) return 0;
  final wrong = total - correct;
  if (wrong <= 0) return 5;
  return (5 - ((wrong + 1) ~/ 2)).clamp(0, 5);
}

class StageTopic {
  final String id;
  final Map<StudyLanguage, String> titles;
  final Map<StudyLanguage, String> subtitles;
  final List<String> levels;
  final Set<String> keywords;

  const StageTopic({
    required this.id,
    required this.titles,
    required this.subtitles,
    required this.levels,
    required this.keywords,
  });

  String title(StudyLanguage language) =>
      titles[language] ?? titles[StudyLanguage.ko] ?? '';
  String subtitle(StudyLanguage language) =>
      subtitles[language] ?? subtitles[StudyLanguage.ko] ?? '';
}

class RoundRef {
  final int stageIndex;
  final int roundIndex;
  const RoundRef(this.stageIndex, this.roundIndex);

  String get key => 'round_${stageIndex}_$roundIndex';
}

class StageRound {
  final StageTopic topic;
  final int index;
  final List<Idiom> idioms;

  const StageRound({
    required this.topic,
    required this.index,
    required this.idioms,
  });
}

const Map<String, Map<StudyLanguage, String>> _themeTitles = {
  'greetings': {
    StudyLanguage.ko: 'Hola, 첫 인사',
    StudyLanguage.en: 'Hola, First Greetings',
    StudyLanguage.ja: 'Hola、はじめての挨拶',
  },
  'personal_information': {
    StudyLanguage.ko: '나를 소개하는 말',
    StudyLanguage.en: 'Introducing Yourself',
    StudyLanguage.ja: '自分を紹介する言葉',
  },
  'family_people': {
    StudyLanguage.ko: '내 주변 사람들',
    StudyLanguage.en: 'People Around Me',
    StudyLanguage.ja: 'まわりの人たち',
  },
  'numbers_time': {
    StudyLanguage.ko: '시간 감각 익히기',
    StudyLanguage.en: 'Numbers and Time',
    StudyLanguage.ja: '時間の感覚をつかむ',
  },
  'home': {
    StudyLanguage.ko: '우리 집 한 바퀴',
    StudyLanguage.en: 'Around the House',
    StudyLanguage.ja: 'おうちをひとまわり',
  },
  'food_drink': {
    StudyLanguage.ko: '식탁 위 스페인어',
    StudyLanguage.en: 'Spanish at the Table',
    StudyLanguage.ja: '食卓のスペイン語',
  },
  'shopping': {
    StudyLanguage.ko: '시장과 가게',
    StudyLanguage.en: 'Markets and Shops',
    StudyLanguage.ja: '市場とお店',
  },
  'education': {
    StudyLanguage.ko: '교실에서 쓰는 말',
    StudyLanguage.en: 'Classroom Words',
    StudyLanguage.ja: '教室で使う言葉',
  },
  'travel_transport': {
    StudyLanguage.ko: '여행 가방 챙기기',
    StudyLanguage.en: 'Packing for a Trip',
    StudyLanguage.ja: '旅行かばんの準備',
  },
  'city_directions': {
    StudyLanguage.ko: '길 찾는 감각',
    StudyLanguage.en: 'Finding Your Way',
    StudyLanguage.ja: '道を探す感覚',
  },
  'weather_nature': {
    StudyLanguage.ko: '날씨와 풍경',
    StudyLanguage.en: 'Weather and Scenery',
    StudyLanguage.ja: '天気と風景',
  },
  'basic_descriptions': {
    StudyLanguage.ko: '묘사 한 스푼',
    StudyLanguage.en: 'A Spoonful of Description',
    StudyLanguage.ja: '描写ひとさじ',
  },
  'core_verbs': {
    StudyLanguage.ko: '문장을 여는 동사',
    StudyLanguage.en: 'Verbs That Open Sentences',
    StudyLanguage.ja: '文を開く動詞',
  },
  'function_words': {
    StudyLanguage.ko: '말을 이어주는 조각',
    StudyLanguage.en: 'Connecting Pieces',
    StudyLanguage.ja: '言葉をつなぐピース',
  },
  'identity_documents': {
    StudyLanguage.ko: '서류 속 내 정보',
    StudyLanguage.en: 'My Info on Paper',
    StudyLanguage.ja: '書類の中の私',
  },
  'health_body': {
    StudyLanguage.ko: '몸 상태 말하기',
    StudyLanguage.en: 'How Are You Feeling?',
    StudyLanguage.ja: '体調を伝える',
  },
  'daily_routine': {
    StudyLanguage.ko: '하루 루틴',
    StudyLanguage.en: 'Daily Routine',
    StudyLanguage.ja: '一日のルーティン',
  },
  'home_tasks': {
    StudyLanguage.ko: '집안일 표현',
    StudyLanguage.en: 'Household Chores',
    StudyLanguage.ja: '家事の表現',
  },
  'restaurants': {
    StudyLanguage.ko: '카페와 식당',
    StudyLanguage.en: 'Cafés and Restaurants',
    StudyLanguage.ja: 'カフェとレストラン',
  },
  'shopping_money': {
    StudyLanguage.ko: '계산하고 고르기',
    StudyLanguage.en: 'Paying and Choosing',
    StudyLanguage.ja: '選んでお会計',
  },
  'clothing': {
    StudyLanguage.ko: '옷장 열어보기',
    StudyLanguage.en: 'Opening the Closet',
    StudyLanguage.ja: 'クローゼットを開けて',
  },
  'work_professions': {
    StudyLanguage.ko: '일하는 하루',
    StudyLanguage.en: 'A Day at Work',
    StudyLanguage.ja: '働く一日',
  },
  'travel_hotels': {
    StudyLanguage.ko: '숙소와 여행',
    StudyLanguage.en: 'Hotels and Travel',
    StudyLanguage.ja: '宿と旅行',
  },
  'services': {
    StudyLanguage.ko: '생활 서비스',
    StudyLanguage.en: 'Everyday Services',
    StudyLanguage.ja: '生活サービス',
  },
  'public_notices': {
    StudyLanguage.ko: '표지판 읽기',
    StudyLanguage.en: 'Reading Signs',
    StudyLanguage.ja: '標識を読む',
  },
  'technology': {
    StudyLanguage.ko: '폰과 인터넷',
    StudyLanguage.en: 'Phones and the Internet',
    StudyLanguage.ja: 'スマホとネット',
  },
  'opinions_preferences': {
    StudyLanguage.ko: '좋고 싫은 것',
    StudyLanguage.en: 'Likes and Dislikes',
    StudyLanguage.ja: '好きと嫌い',
  },
  'connectors': {
    StudyLanguage.ko: '문장 연결하기',
    StudyLanguage.en: 'Linking Sentences',
    StudyLanguage.ja: '文をつなげる',
  },
  'health_services': {
    StudyLanguage.ko: '병원 가는 날',
    StudyLanguage.en: 'A Trip to the Doctor',
    StudyLanguage.ja: '病院に行く日',
  },
  'personality_feelings': {
    StudyLanguage.ko: '성격과 기분',
    StudyLanguage.en: 'Personality and Moods',
    StudyLanguage.ja: '性格と気分',
  },
  'relationships_life_events': {
    StudyLanguage.ko: '관계와 인생 이벤트',
    StudyLanguage.en: 'Relationships and Life Events',
    StudyLanguage.ja: '人間関係と人生のイベント',
  },
  'housing_neighborhood': {
    StudyLanguage.ko: '동네와 집 구하기',
    StudyLanguage.en: 'Housing and the Neighborhood',
    StudyLanguage.ja: '住まいと街さがし',
  },
  'food_cooking': {
    StudyLanguage.ko: '요리하는 스페인어',
    StudyLanguage.en: 'Cooking in Spanish',
    StudyLanguage.ja: '料理のスペイン語',
  },
  'education_exams': {
    StudyLanguage.ko: '시험과 공부',
    StudyLanguage.en: 'Exams and Studying',
    StudyLanguage.ja: '試験と勉強',
  },
  'work_business': {
    StudyLanguage.ko: '회사와 일 이야기',
    StudyLanguage.en: 'Business Talk',
    StudyLanguage.ja: '会社と仕事の話',
  },
  'travel_accommodation': {
    StudyLanguage.ko: '이동과 숙박',
    StudyLanguage.en: 'Getting Around and Staying Over',
    StudyLanguage.ja: '移動と宿泊',
  },
  'culture_media': {
    StudyLanguage.ko: '취미와 콘텐츠',
    StudyLanguage.en: 'Hobbies and Media',
    StudyLanguage.ja: '趣味とコンテンツ',
  },
  'technology_communication': {
    StudyLanguage.ko: '디지털 대화',
    StudyLanguage.en: 'Digital Conversations',
    StudyLanguage.ja: 'デジタル会話',
  },
  'money_administration': {
    StudyLanguage.ko: '돈과 행정',
    StudyLanguage.en: 'Money and Paperwork',
    StudyLanguage.ja: 'お金と行政',
  },
  'city_safety': {
    StudyLanguage.ko: '도시와 안전',
    StudyLanguage.en: 'City and Safety',
    StudyLanguage.ja: '都市と安全',
  },
  'environment': {
    StudyLanguage.ko: '자연과 환경',
    StudyLanguage.en: 'Nature and the Environment',
    StudyLanguage.ja: '自然と環境',
  },
  'society_civic_life': {
    StudyLanguage.ko: '사회 속 단어',
    StudyLanguage.en: 'Words for Society',
    StudyLanguage.ja: '社会の中の単語',
  },
  'opinions_arguments': {
    StudyLanguage.ko: '생각을 말하기',
    StudyLanguage.en: 'Making Your Point',
    StudyLanguage.ja: '考えを伝える',
  },
  'narration_verbs': {
    StudyLanguage.ko: '이야기를 움직이는 동사',
    StudyLanguage.en: 'Verbs That Drive a Story',
    StudyLanguage.ja: '物語を動かす動詞',
  },
  'pcic_general': {
    StudyLanguage.ko: '기본 핵심 어휘',
    StudyLanguage.en: 'Core Everyday Vocabulary',
    StudyLanguage.ja: '基本のコア語彙',
  },
  'pcic_specific': {
    StudyLanguage.ko: '세부 생활 어휘',
    StudyLanguage.en: 'Everyday Detail Vocabulary',
    StudyLanguage.ja: '生活の詳細語彙',
  },
  'mixed_review': {
    StudyLanguage.ko: '추가 복습',
    StudyLanguage.en: 'Extra Review',
    StudyLanguage.ja: '追加復習',
  },
};

const Map<String, Map<StudyLanguage, String>> _themeSubtitles = {
  'greetings': {
    StudyLanguage.ko: '인사와 첫 대화에 필요한 표현',
    StudyLanguage.en: 'Greetings and first conversations',
    StudyLanguage.ja: '挨拶と初対面の会話の表現',
  },
  'personal_information': {
    StudyLanguage.ko: '이름, 주소, 국적처럼 나를 설명해요',
    StudyLanguage.en: 'Name, address, nationality — describe yourself',
    StudyLanguage.ja: '名前・住所・国籍など自分のこと',
  },
  'family_people': {
    StudyLanguage.ko: '가족, 친구, 주변 사람을 말해요',
    StudyLanguage.en: 'Family, friends, and people around you',
    StudyLanguage.ja: '家族・友達・身近な人を話します',
  },
  'numbers_time': {
    StudyLanguage.ko: '숫자, 날짜, 시간 표현을 가볍게',
    StudyLanguage.en: 'Numbers, dates, and telling time',
    StudyLanguage.ja: '数字・日付・時間の表現を軽く',
  },
  'home': {
    StudyLanguage.ko: '방, 문, 가구처럼 생활 공간을 익혀요',
    StudyLanguage.en: 'Rooms, doors, and furniture',
    StudyLanguage.ja: '部屋・ドア・家具など生活空間の言葉',
  },
  'food_drink': {
    StudyLanguage.ko: '먹고 마시는 순간에 바로 쓰는 말',
    StudyLanguage.en: 'Words for eating and drinking',
    StudyLanguage.ja: '食べる・飲む場面ですぐ使う言葉',
  },
  'shopping': {
    StudyLanguage.ko: '가격, 가게, 물건을 고르는 표현',
    StudyLanguage.en: 'Prices, shops, and picking things out',
    StudyLanguage.ja: '値段・お店・品物を選ぶ表現',
  },
  'education': {
    StudyLanguage.ko: '수업, 질문, 공부에 필요한 단어',
    StudyLanguage.en: 'Lessons, questions, and studying',
    StudyLanguage.ja: '授業・質問・勉強に必要な単語',
  },
  'travel_transport': {
    StudyLanguage.ko: '교통수단과 여행 준비 단어',
    StudyLanguage.en: 'Transport and trip preparation',
    StudyLanguage.ja: '交通手段と旅の準備の単語',
  },
  'city_directions': {
    StudyLanguage.ko: '길, 위치, 방향을 찾는 표현',
    StudyLanguage.en: 'Streets, locations, and directions',
    StudyLanguage.ja: '道・位置・方向を探す表現',
  },
  'weather_nature': {
    StudyLanguage.ko: '날씨와 자연 풍경을 말해요',
    StudyLanguage.en: 'Talk about weather and nature',
    StudyLanguage.ja: '天気と自然の風景を話します',
  },
  'basic_descriptions': {
    StudyLanguage.ko: '크기, 색, 상태를 짧게 묘사해요',
    StudyLanguage.en: 'Size, color, and simple descriptions',
    StudyLanguage.ja: '大きさ・色・状態を短く描写します',
  },
  'core_verbs': {
    StudyLanguage.ko: '기본 동사로 문장을 만들어요',
    StudyLanguage.en: 'Build sentences with core verbs',
    StudyLanguage.ja: '基本動詞で文を作ります',
  },
  'function_words': {
    StudyLanguage.ko: '짧지만 문장을 이어주는 표현',
    StudyLanguage.en: 'Small words that hold sentences together',
    StudyLanguage.ja: '短くても文をつなぐ表現',
  },
  'identity_documents': {
    StudyLanguage.ko: '서류와 신분 확인에 나오는 말',
    StudyLanguage.en: 'Words for documents and ID checks',
    StudyLanguage.ja: '書類と身分確認に出る言葉',
  },
  'health_body': {
    StudyLanguage.ko: '몸과 건강 상태를 설명해요',
    StudyLanguage.en: 'Describe your body and health',
    StudyLanguage.ja: '体と健康状態を説明します',
  },
  'daily_routine': {
    StudyLanguage.ko: '매일 반복되는 행동을 말해요',
    StudyLanguage.en: 'Talk about everyday actions',
    StudyLanguage.ja: '毎日繰り返す行動を話します',
  },
  'home_tasks': {
    StudyLanguage.ko: '청소, 세탁, 정리 같은 집안일',
    StudyLanguage.en: 'Cleaning, laundry, and tidying up',
    StudyLanguage.ja: '掃除・洗濯・片付けなどの家事',
  },
  'restaurants': {
    StudyLanguage.ko: '주문하고 계산하는 식당 표현',
    StudyLanguage.en: 'Ordering and paying at restaurants',
    StudyLanguage.ja: '注文と会計のレストラン表現',
  },
  'shopping_money': {
    StudyLanguage.ko: '돈, 할인, 결제 관련 표현',
    StudyLanguage.en: 'Money, discounts, and payment',
    StudyLanguage.ja: 'お金・割引・支払いの表現',
  },
  'clothing': {
    StudyLanguage.ko: '옷과 소지품을 고르는 말',
    StudyLanguage.en: 'Clothes and personal items',
    StudyLanguage.ja: '服と持ち物を選ぶ言葉',
  },
  'work_professions': {
    StudyLanguage.ko: '직업과 일터에서 만나는 단어',
    StudyLanguage.en: 'Jobs and workplace words',
    StudyLanguage.ja: '職業と仕事場で出会う単語',
  },
  'travel_hotels': {
    StudyLanguage.ko: '예약, 숙소, 여행 상황 표현',
    StudyLanguage.en: 'Bookings, lodging, and travel situations',
    StudyLanguage.ja: '予約・宿泊・旅行の場面の表現',
  },
  'services': {
    StudyLanguage.ko: '은행, 우체국, 공공서비스 단어',
    StudyLanguage.en: 'Banks, post offices, and public services',
    StudyLanguage.ja: '銀行・郵便局・公共サービスの単語',
  },
  'public_notices': {
    StudyLanguage.ko: '표지판과 안내문을 읽어요',
    StudyLanguage.en: 'Signs and public notices',
    StudyLanguage.ja: '標識と案内文を読みます',
  },
  'technology': {
    StudyLanguage.ko: '기기와 인터넷 기본 표현',
    StudyLanguage.en: 'Devices and internet basics',
    StudyLanguage.ja: '機器とインターネットの基本表現',
  },
  'opinions_preferences': {
    StudyLanguage.ko: '좋아함, 선호, 생각을 말해요',
    StudyLanguage.en: 'Talk about likes, preferences, and thoughts',
    StudyLanguage.ja: '好み・意見を話します',
  },
  'connectors': {
    StudyLanguage.ko: '문장과 문장을 자연스럽게 이어요',
    StudyLanguage.en: 'Join sentences naturally',
    StudyLanguage.ja: '文と文を自然につなぎます',
  },
  'health_services': {
    StudyLanguage.ko: '진료, 증상, 병원 상황 표현',
    StudyLanguage.en: 'Appointments, symptoms, and hospital visits',
    StudyLanguage.ja: '診察・症状・病院の場面の表現',
  },
  'personality_feelings': {
    StudyLanguage.ko: '성격과 감정을 더 섬세하게',
    StudyLanguage.en: 'Describe personality and emotions in detail',
    StudyLanguage.ja: '性格と感情をより細やかに',
  },
  'relationships_life_events': {
    StudyLanguage.ko: '관계, 만남, 인생 이벤트',
    StudyLanguage.en: 'Relationships, meetings, and milestones',
    StudyLanguage.ja: '関係・出会い・人生の節目',
  },
  'housing_neighborhood': {
    StudyLanguage.ko: '집과 동네를 설명하는 말',
    StudyLanguage.en: 'Describe homes and neighborhoods',
    StudyLanguage.ja: '家と街を説明する言葉',
  },
  'food_cooking': {
    StudyLanguage.ko: '재료, 맛, 조리 표현',
    StudyLanguage.en: 'Ingredients, flavors, and cooking',
    StudyLanguage.ja: '材料・味・調理の表現',
  },
  'education_exams': {
    StudyLanguage.ko: '시험, 과제, 학습 표현',
    StudyLanguage.en: 'Exams, assignments, and learning',
    StudyLanguage.ja: '試験・課題・学習の表現',
  },
  'work_business': {
    StudyLanguage.ko: '회사, 업무, 거래 표현',
    StudyLanguage.en: 'Companies, tasks, and deals',
    StudyLanguage.ja: '会社・業務・取引の表現',
  },
  'travel_accommodation': {
    StudyLanguage.ko: '이동과 숙박 상황을 다뤄요',
    StudyLanguage.en: 'Transport and accommodation situations',
    StudyLanguage.ja: '移動と宿泊の場面を扱います',
  },
  'culture_media': {
    StudyLanguage.ko: '영화, 음악, 문화생활 단어',
    StudyLanguage.en: 'Movies, music, and cultural life',
    StudyLanguage.ja: '映画・音楽・文化生活の単語',
  },
  'technology_communication': {
    StudyLanguage.ko: '메시지, 앱, 온라인 표현',
    StudyLanguage.en: 'Messages, apps, and life online',
    StudyLanguage.ja: 'メッセージ・アプリ・オンラインの表現',
  },
  'money_administration': {
    StudyLanguage.ko: '계좌, 서류, 행정 처리 표현',
    StudyLanguage.en: 'Accounts, documents, and admin tasks',
    StudyLanguage.ja: '口座・書類・行政手続きの表現',
  },
  'city_safety': {
    StudyLanguage.ko: '도시 시설과 안전 관련 단어',
    StudyLanguage.en: 'City facilities and safety words',
    StudyLanguage.ja: '都市の施設と安全の単語',
  },
  'environment': {
    StudyLanguage.ko: '환경과 자연을 이야기해요',
    StudyLanguage.en: 'Talk about nature and the environment',
    StudyLanguage.ja: '環境と自然を語ります',
  },
  'society_civic_life': {
    StudyLanguage.ko: '사회 이슈와 시민 생활 단어',
    StudyLanguage.en: 'Social issues and civic life',
    StudyLanguage.ja: '社会問題と市民生活の単語',
  },
  'opinions_arguments': {
    StudyLanguage.ko: '이유와 의견을 정리해 말해요',
    StudyLanguage.en: 'Organize reasons and opinions',
    StudyLanguage.ja: '理由と意見を整理して話します',
  },
  'narration_verbs': {
    StudyLanguage.ko: '사건과 경험을 풀어내는 동사',
    StudyLanguage.en: 'Verbs for telling events and experiences',
    StudyLanguage.ja: '出来事と経験を語る動詞',
  },
  'pcic_general': {
    StudyLanguage.ko: '자주 쓰는 기본 단어를 차근차근 익혀요',
    StudyLanguage.en: 'Learn frequent basic words step by step',
    StudyLanguage.ja: 'よく使う基本単語をこつこつ学びます',
  },
  'pcic_specific': {
    StudyLanguage.ko: '상황별로 쓰이는 세부 단어를 익혀요',
    StudyLanguage.en: 'Learn words for specific situations',
    StudyLanguage.ja: '場面ごとの細かい単語を学びます',
  },
  'mixed_review': {
    StudyLanguage.ko: '작은 테마의 남은 단어를 함께 복습해요',
    StudyLanguage.en: 'Review leftover words from smaller themes',
    StudyLanguage.ja: '小さなテーマの残りの単語を復習します',
  },
};

const Map<StudyLanguage, String> _extraWordsTitles = {
  StudyLanguage.ko: '추가 단어',
  StudyLanguage.en: 'Extra Words',
  StudyLanguage.ja: '追加単語',
};

const Map<StudyLanguage, String> _fallbackThemeSubtitles = {
  StudyLanguage.ko: '짧게 풀고 바로 다음 테마로 넘어가요',
  StudyLanguage.en: 'A quick set before the next theme',
  StudyLanguage.ja: '短く解いて次のテーマへ進みましょう',
};

class StagePlan {
  final List<List<StageRound>> stageRounds;

  const StagePlan(this.stageRounds);

  int get stageCount => stageRounds.length;
  int roundsIn(int stage) => stageRounds[stage].length;
  StageTopic topicFor(int stage) => stageRounds[stage].first.topic;
  StageRound roundFor(RoundRef r) => stageRounds[r.stageIndex][r.roundIndex];
  List<Idiom> idiomsFor(RoundRef r) => roundFor(r).idioms;

  static StagePlan build(List<Idiom> pool) {
    final used = <String>{};
    final stages = <List<StageRound>>[];

    for (var s = 0; s < kStageTopics.length; s++) {
      final topic = kStageTopics[s];
      final themed = pool.where((entry) => _matchesTopic(entry, topic)).toList()
        ..sort(_byLevelDifficultyWord);
      final remainingThemed = [
        for (final entry in themed)
          if (!used.contains(entry.idiom)) entry,
      ];

      for (var r = 0; r < remainingThemed.length; r += kQuestionsPerRound) {
        final chunk = remainingThemed
            .sublist(r, min(r + kQuestionsPerRound, remainingThemed.length))
            .toList(growable: false);
        if (chunk.length < 4) continue;
        for (final entry in chunk) {
          used.add(entry.idiom);
        }
        final part = (r ~/ kQuestionsPerRound) + 1;
        chunk.shuffle(Random(2000 + s + part));
        final stageTopic = part == 1
            ? topic
            : StageTopic(
                id: '${topic.id}_$part',
                titles: {
                  for (final entry in topic.titles.entries)
                    entry.key: '${entry.value} $part',
                },
                subtitles: topic.subtitles,
                levels: topic.levels,
                keywords: topic.keywords,
              );
        stages.add([StageRound(topic: stageTopic, index: 0, idioms: chunk)]);
      }
    }

    final unassignedByTheme = <String, List<Idiom>>{};
    for (final entry in pool) {
      if (!used.add(entry.idiom)) continue;
      final theme = entry.theme.trim().isEmpty ? 'mixed_review' : entry.theme;
      unassignedByTheme.putIfAbsent(theme, () => <Idiom>[]).add(entry);
    }

    final mixed = <Idiom>[];
    for (final theme in _orderedThemes(unassignedByTheme.keys)) {
      final entries = unassignedByTheme[theme]!..sort(_byLevelDifficultyWord);
      for (var r = 0; r < entries.length; r += kQuestionsPerRound) {
        final chunk = entries
            .sublist(r, min(r + kQuestionsPerRound, entries.length))
            .toList(growable: false);
        if (chunk.length < 4) {
          mixed.addAll(chunk);
          continue;
        }
        final part = (r ~/ kQuestionsPerRound) + 1;
        final topic = _topicFromTheme(theme, part);
        stages.add([StageRound(topic: topic, index: 0, idioms: chunk)]);
      }
    }

    mixed.sort(_byLevelDifficultyWord);
    for (var r = 0; r < mixed.length; r += kQuestionsPerRound) {
      final chunk = mixed
          .sublist(r, min(r + kQuestionsPerRound, mixed.length))
          .toList(growable: false);
      if (chunk.length < 4) {
        if (stages.isNotEmpty) {
          final last = stages.last.first;
          stages.last[0] = StageRound(
            topic: last.topic,
            index: last.index,
            idioms: [...last.idioms, ...chunk],
          );
        }
        continue;
      }
      final part = (r ~/ kQuestionsPerRound) + 1;
      stages.add([
        StageRound(
          topic: StageTopic(
            id: 'mixed_review_$part',
            titles: {
              for (final entry in _extraWordsTitles.entries)
                entry.key: '${entry.value} $part',
            },
            subtitles: _themeSubtitles['mixed_review']!,
            levels: const [],
            keywords: const {},
          ),
          index: 0,
          idioms: chunk,
        ),
      ]);
    }

    return StagePlan(stages);
  }

  // ignore: unused_element
  static List<String> _orderedThemes(Iterable<String> themes) {
    const preferred = [
      'greetings',
      'personal_information',
      'family_people',
      'numbers_time',
      'home',
      'food_drink',
      'shopping',
      'education',
      'travel_transport',
      'city_directions',
      'weather_nature',
      'basic_descriptions',
      'core_verbs',
      'function_words',
      'identity_documents',
      'health_body',
      'daily_routine',
      'home_tasks',
      'restaurants',
      'shopping_money',
      'clothing',
      'work_professions',
      'travel_hotels',
      'services',
      'public_notices',
      'technology',
      'opinions_preferences',
      'connectors',
      'health_services',
      'personality_feelings',
      'relationships_life_events',
      'housing_neighborhood',
      'food_cooking',
      'education_exams',
      'work_business',
      'travel_accommodation',
      'culture_media',
      'technology_communication',
      'money_administration',
      'city_safety',
      'environment',
      'society_civic_life',
      'opinions_arguments',
      'narration_verbs',
    ];
    final set = themes.toSet();
    return [
      for (final theme in preferred)
        if (set.remove(theme)) theme,
      ...set.toList()..sort(),
    ];
  }

  // ignore: unused_element
  static StageTopic _topicFromTheme(String theme, int part) {
    final titles = _themeTitles[theme];
    final fallbackTitle = _humanizeTheme(theme);
    return StageTopic(
      id: '${theme}_$part',
      titles: {
        for (final language in StudyLanguage.values)
          language: '${titles?[language] ?? fallbackTitle} $part',
      },
      subtitles: _themeSubtitles[theme] ?? _fallbackThemeSubtitles,
      levels: const [],
      keywords: const {},
    );
  }

  static String _humanizeTheme(String theme) => theme
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');

  static int _byLevelDifficultyWord(Idiom a, Idiom b) {
    final level = _levelRank(a.level).compareTo(_levelRank(b.level));
    if (level != 0) return level;
    final difficulty = a.difficulty.compareTo(b.difficulty);
    if (difficulty != 0) return difficulty;
    return a.idiom.compareTo(b.idiom);
  }

  static int _levelRank(String level) =>
      switch (level.split('/').first.toUpperCase()) {
        'A1' => 1,
        'A2' => 2,
        'B1' => 3,
        'B2' => 4,
        'C1' => 5,
        _ => 99,
      };

  static bool _matchesTopic(Idiom entry, StageTopic topic) {
    final normalized = _normalize(entry.idiom);
    final keywords = topic.keywords.map(_normalize).toSet();
    if (keywords.contains(normalized)) return true;
    if (topic.id == 'greetings') return false;

    final englishMeaning = _normalize(entry.meanings[StudyLanguage.en] ?? '');
    return keywords.any(
      (keyword) => _containsMeaningToken(englishMeaning, keyword),
    );
  }

  static bool _containsMeaningToken(String meaning, String keyword) {
    if (keyword.length < 3) return false;
    final meaningTokens = meaning
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.isNotEmpty);
    final keywordTokens = keyword
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.isNotEmpty);
    final keywordList = keywordTokens.toList(growable: false);
    if (keywordList.isEmpty) return false;
    final meaningList = meaningTokens.toList(growable: false);
    if (keywordList.length == 1) return meaningList.contains(keywordList.first);
    for (var i = 0; i <= meaningList.length - keywordList.length; i++) {
      var matches = true;
      for (var j = 0; j < keywordList.length; j++) {
        if (meaningList[i + j] != keywordList[j]) {
          matches = false;
          break;
        }
      }
      if (matches) return true;
    }
    return false;
  }

  static String _normalize(String value) {
    const from = 'áéíóúüñÁÉÍÓÚÜÑ';
    const to = 'aeiouunAEIOUUN';
    var result = value.toLowerCase().trim();
    for (var i = 0; i < from.length; i++) {
      result = result.replaceAll(from[i], to[i]);
    }
    const accents = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    for (final entry in accents.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }
}
