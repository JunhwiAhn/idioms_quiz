// All on-screen and metadata copy, in the three languages the app supports.
//
// Everything here is template-level: the per-word content (meanings, examples,
// topic titles) comes from the app's own localized data, so adding a language
// never means writing vocabulary copy by hand.

export const LANG_META = {
  ko: { name: '한국어', locale: 'ko-KR' },
  en: { name: 'English', locale: 'en-US' },
  ja: { name: '日本語', locale: 'ja-JP' },
};

export const UI = {
  ko: {
    series: '스페인어 첫걸음',
    day: (n) => `DAY ${n}`,
    wordsToday: (n) => `오늘의 단어 ${n}개`,
    prompt: '무슨 뜻일까요?',
    example: '예문',
    recap: (n) => `오늘의 ${n}단어`,
    ctaHeadline: '단어 1,250개 더',
    ctaLine: 'Play 스토어에서 검색',
    ctaSub: '스테이지 · 마라톤 · 오답노트',
    listen: '들어보세요',
  },
  en: {
    series: 'Spanish from Zero',
    day: (n) => `DAY ${n}`,
    wordsToday: (n) => `${n} words today`,
    prompt: 'What does it mean?',
    example: 'Example',
    recap: (n) => `Today's ${n} words`,
    ctaHeadline: '1,250+ more words',
    ctaLine: 'Search on Google Play',
    ctaSub: 'Stages · Marathon · Mistake notes',
    listen: 'Listen',
  },
  ja: {
    series: 'ゼロからスペイン語',
    day: (n) => `DAY ${n}`,
    wordsToday: (n) => `今日の単語${n}個`,
    prompt: 'どんな意味？',
    example: '例文',
    recap: (n) => `今日の${n}単語`,
    ctaHeadline: 'あと1,250語以上',
    ctaLine: 'Google Play で検索',
    ctaSub: 'ステージ・マラソン・復習ノート',
    listen: '聞いてみよう',
  },
};

const APP_NAME = 'DELE Voca Dojo';

export function videoTitle({ lang, day, topicTitle }) {
  const ui = UI[lang];
  switch (lang) {
    case 'ko':
      return `왕초보 스페인어 단어 5개 | ${ui.series} DAY ${day} · ${topicTitle}`;
    case 'ja':
      return `初心者スペイン語 単語5つ｜${ui.series} DAY ${day} · ${topicTitle}`;
    default:
      return `5 Spanish Words for Beginners | ${ui.series} DAY ${day} · ${topicTitle}`;
  }
}

/**
 * Rotating blurbs. Twenty episodes carrying a byte-identical description reads
 * as templated bulk upload, so the middle paragraph and the closing line move
 * with the day number.
 */
const BLURBS = {
  ko: [
    ['스페인어를 처음 시작하는 분을 위한 DELE A1~A2 필수 단어 시리즈입니다.', '하루 5단어씩, 20일이면 100단어를 익힐 수 있어요.'],
    ['오늘 나온 단어는 DELE A1~A2 범위에서 가장 자주 쓰이는 것들만 골랐습니다.', '예문까지 같이 들으면 훨씬 오래 남아요.'],
    ['단어만 외우면 금방 잊어버립니다. 예문 안에서 한 번 더 들어보세요.', '이 시리즈는 매일 5단어씩 20일 과정입니다.'],
    ['DELE A1~A2에서 실제로 출제되는 어휘 위주로 구성했습니다.', '발음은 두 번씩 들려드리니 소리 내어 따라 해보세요.'],
    ['왕초보 기준으로 쉬운 단어부터 순서대로 나갑니다.', '앞 회차를 안 보셨다면 DAY 1부터 보시는 걸 추천드려요.'],
  ],
  en: [
    ['Essential DELE A1–A2 vocabulary for absolute beginners.', '5 words a day — 100 words in 20 days.'],
    ['Every word here is picked from the most frequent DELE A1–A2 range.', 'Hearing the example sentence makes it stick much longer.'],
    ['Words alone fade fast. Listen for each one inside a real sentence.', 'This series runs 5 words a day for 20 days.'],
    ['Built around the vocabulary that actually shows up in DELE A1–A2.', 'Each word is read twice — say it out loud with the audio.'],
    ['Ordered from easiest to hardest for complete beginners.', 'New here? Start from DAY 1.'],
  ],
  ja: [
    ['スペイン語がまったく初めての方向けの DELE A1〜A2 必須単語シリーズです。', '1日5単語、20日で100単語。'],
    ['DELE A1〜A2 の中でも使用頻度の高い単語だけを選びました。', '例文と一緒に聞くと記憶に残りやすくなります。'],
    ['単語だけでは忘れてしまいます。文の中でもう一度聞いてみてください。', 'この シリーズは1日5単語×20日間です。'],
    ['DELE A1〜A2 で実際に出る語彙を中心に構成しています。', '発音は2回流れます。声に出して真似してみましょう。'],
    ['初心者向けに、やさしい単語から順番に進みます。', '初めての方は DAY 1 からどうぞ。'],
  ],
};

const CLOSERS = {
  ko: [
    '다음 회차도 놓치지 않으시려면 구독을 눌러주세요.',
    '어떤 주제를 더 다뤘으면 좋을지 댓글로 알려주세요.',
    '오늘 배운 단어, 소리 내어 한 번만 더 읽어보세요.',
    '내일도 5단어로 찾아오겠습니다.',
  ],
  en: [
    'Subscribe so you do not miss the next one.',
    'Which topic should come next? Tell me in the comments.',
    'Say today’s words out loud one more time before you go.',
    'Back tomorrow with five more.',
  ],
  ja: [
    '次回も見逃さないようにチャンネル登録をどうぞ。',
    '次に扱ってほしいテーマをコメントで教えてください。',
    '今日の単語、もう一度声に出して読んでみましょう。',
    '明日もまた5単語でお会いしましょう。',
  ],
};

const HASHTAGS = {
  ko: '#스페인어 #스페인어단어 #DELE #스페인어공부 #왕초보스페인어',
  en: '#spanish #learnspanish #spanishvocabulary #DELE #spanishforbeginners',
  ja: '#スペイン語 #スペイン語単語 #DELE #スペイン語勉強 #初心者スペイン語',
};

const APP_PITCH = {
  ko: (url) => [`단어 1,250개를 게임처럼 반복 학습하려면 — 앱 「${APP_NAME}」`, url],
  en: (url) => [`Want all 1,250 words as a quiz game? Get the app "${APP_NAME}"`, url],
  ja: (url) => [`1,250語をゲーム感覚で復習するなら — アプリ「${APP_NAME}」`, url],
};

const WORD_HEADING = { ko: '오늘의 단어', en: "Today's words", ja: '今日の単語' };

/** Deterministic rotation so re-running the generator never reshuffles copy. */
function pick(list, day) {
  return list[(day - 1) % list.length];
}

const TIP_HEADING = { ko: '오늘의 포인트', en: "Today's point", ja: '今日のポイント' };

export function videoDescription({ lang, day, topicTitle, topicSubtitle, words, tip, storeUrl }) {
  const list = words.map((word) => `· ${word.term} — ${word.meanings[lang]}`).join('\n');
  return [
    `${UI[lang].series} DAY ${day} — ${topicTitle}`,
    topicSubtitle,
    '',
    WORD_HEADING[lang],
    list,
    '',
    `${TIP_HEADING[lang]} — ${tip.headline}`,
    tip.body,
    '',
    ...pick(BLURBS[lang], day),
    '',
    ...APP_PITCH[lang](storeUrl),
    '',
    pick(CLOSERS[lang], day),
    '',
    HASHTAGS[lang],
  ].join('\n');
}

export function videoTags({ lang, words }) {
  const terms = words.map((word) => word.term);
  const base = {
    ko: ['스페인어', '스페인어 단어', '스페인어 공부', '왕초보 스페인어', 'DELE', 'DELE A1', '스페인어 회화', '스페인어 독학'],
    en: ['spanish', 'learn spanish', 'spanish vocabulary', 'spanish for beginners', 'DELE', 'DELE A1', 'spanish words'],
    ja: ['スペイン語', 'スペイン語単語', 'スペイン語勉強', '初心者スペイン語', 'DELE', 'DELE A1', 'スペイン語独学'],
  };
  return [...base[lang], ...terms];
}

/**
 * One pinned comment per episode, built from that day's topic and words.
 * Posting the same sentence plus the same link under twenty videos is the
 * clearest link-spam signal there is, so nothing here is reused verbatim.
 */
export function pinnedComment({ lang, day, topicTitle, words, storeUrl }) {
  const first = words[0].term;
  const last = words[words.length - 1].term;
  const running = day * words.length;

  const variants = {
    ko: [
      `「${topicTitle}」 단어 ${words.length}개, 이제 직접 풀어볼 차례입니다 👉 ${storeUrl}`,
      `${first} 발음, 한 번에 따라 하셨나요? 앱에서는 발음 듣기와 오답노트로 복습할 수 있어요 👉 ${storeUrl}`,
      `DAY ${day}까지 오셨다면 벌써 ${running}단어입니다 👏 이어서 연습하기 👉 ${storeUrl}`,
      `오늘 단어 중 가장 헷갈린 건 뭐였나요? 저는 ${last}이(가) 제일 어려웠습니다. 댓글로 알려주세요!`,
      `「${topicTitle}」를 더 파고들고 싶다면 같은 주제 단어가 앱에 더 있습니다 👉 ${storeUrl}`,
    ],
    en: [
      `${words.length} words from "${topicTitle}" — your turn to try them 👉 ${storeUrl}`,
      `Did you catch the pronunciation of ${first}? The app has audio plus a mistake list for review 👉 ${storeUrl}`,
      `You have reached DAY ${day} — that is ${running} words already 👏 Keep going 👉 ${storeUrl}`,
      `Which one tripped you up most today? ${last} is the one I always forget. Tell me below!`,
      `Want more from "${topicTitle}"? There are more words on this topic in the app 👉 ${storeUrl}`,
    ],
    ja: [
      `「${topicTitle}」の${words.length}単語、今度は自分で解いてみましょう 👉 ${storeUrl}`,
      `${first} の発音、うまく言えましたか？アプリなら音声と復習ノートで確認できます 👉 ${storeUrl}`,
      `DAY ${day} まで来たら、もう${running}単語です 👏 続きはこちら 👉 ${storeUrl}`,
      `今日いちばん難しかった単語はどれでしたか？私は ${last} でした。コメントで教えてください！`,
      `「${topicTitle}」をもっと学びたい方へ。同じテーマの単語がアプリにもあります 👉 ${storeUrl}`,
    ],
  };

  return pick(variants[lang], day);
}
