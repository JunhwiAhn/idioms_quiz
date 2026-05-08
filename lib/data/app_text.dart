import '../models/idiom.dart';

class AppText {
  final StudyLanguage language;
  const AppText(this.language);

  String pick(Map<StudyLanguage, String> values) =>
      values[language] ?? values[StudyLanguage.ko] ?? '';

  String get appName => 'Español Dojo';
  String get chooseLanguageTitle => pick({
        StudyLanguage.ko: '학습 언어를 선택해 주세요',
        StudyLanguage.en: 'Choose your study language',
        StudyLanguage.ja: '学習言語を選んでください',
      });
  String get chooseLanguageBody => pick({
        StudyLanguage.ko: '메뉴와 문제 해석에 사용할 언어입니다.',
        StudyLanguage.en: 'This controls menus and answer translations.',
        StudyLanguage.ja: 'メニューと問題の訳に使う言語です。',
      });
  String get start => pick({
        StudyLanguage.ko: '시작',
        StudyLanguage.en: 'Start',
        StudyLanguage.ja: '開始',
      });
  String get stage => pick({
        StudyLanguage.ko: '스테이지',
        StudyLanguage.en: 'Stages',
        StudyLanguage.ja: 'ステージ',
      });
  String get stageSubtitle => pick({
        StudyLanguage.ko: '단어, 뜻, 예문 빈칸으로 DELE 어휘를 익혀요.',
        StudyLanguage.en: 'Build DELE vocabulary with words, meanings, and blanks.',
        StudyLanguage.ja: '単語・訳・例文穴埋めでDELE語彙を固める。',
      });
  String get marathon => pick({
        StudyLanguage.ko: '마라톤',
        StudyLanguage.en: 'Marathon',
        StudyLanguage.ja: 'Maratón',
      });
  String get marathonSubtitle => pick({
        StudyLanguage.ko: '50문제를 연속으로 풀고 기록과 단어장을 채워요.',
        StudyLanguage.en: 'Answer 50 questions to set records and fill the wordbook.',
        StudyLanguage.ja: '50問連続で記録更新と単語帳コンプリートを狙う。',
      });
  String get crossword => pick({
        StudyLanguage.ko: '크로스워드',
        StudyLanguage.en: 'Crossword',
        StudyLanguage.ja: 'クロスワード',
      });
  String get crosswordSubtitle => pick({
        StudyLanguage.ko: '스페인어 단어가 교차하는 퍼즐에 도전해요.',
        StudyLanguage.en: 'Solve intersecting Spanish word puzzles.',
        StudyLanguage.ja: 'スペイン語単語で交差パズルに挑戦。',
      });
  String get wordbook => pick({
        StudyLanguage.ko: '단어장',
        StudyLanguage.en: 'Wordbook',
        StudyLanguage.ja: '単語帳',
      });
  String get correctCount => pick({
        StudyLanguage.ko: '정답 수',
        StudyLanguage.en: 'Correct',
        StudyLanguage.ja: '正解数',
      });
  String get recentMarathon => pick({
        StudyLanguage.ko: '최근 마라톤',
        StudyLanguage.en: 'Recent Marathon',
        StudyLanguage.ja: '直近Maratón',
      });
  String get todaysWord => pick({
        StudyLanguage.ko: '오늘의 단어',
        StudyLanguage.en: 'Word of the Day',
        StudyLanguage.ja: 'PALABRA DEL DÍA',
      });
  String questionCounter(int current, int total) => pick({
        StudyLanguage.ko: '문제 $current / $total',
        StudyLanguage.en: 'Question $current / $total',
        StudyLanguage.ja: '問題 $current / $total',
      });
  String crosswordCounter(int current, int total) => pick({
        StudyLanguage.ko: '크로스워드 $current / $total',
        StudyLanguage.en: 'Crossword $current / $total',
        StudyLanguage.ja: 'クロスワード $current / $total',
      });
  String get horizontal => pick({
        StudyLanguage.ko: '가로',
        StudyLanguage.en: 'Horizontal',
        StudyLanguage.ja: 'よこ',
      });
  String get vertical => pick({
        StudyLanguage.ko: '세로',
        StudyLanguage.en: 'Vertical',
        StudyLanguage.ja: 'たて',
      });
  String get dragLetters => pick({
        StudyLanguage.ko: '아래 글자를 빈칸으로 드래그하세요. 공유 글자는 힌트로 고정됩니다.',
        StudyLanguage.en: 'Drag the letters into the blanks. The shared letter is fixed as a hint.',
        StudyLanguage.ja: '下の文字を空きマスへドラッグ。共有文字はヒントとして固定されます。',
      });
  String get finish => pick({
        StudyLanguage.ko: '종료',
        StudyLanguage.en: 'Finish',
        StudyLanguage.ja: '終了',
      });
  String get next => pick({
        StudyLanguage.ko: '다음',
        StudyLanguage.en: 'Next',
        StudyLanguage.ja: '次へ',
      });
  String get checkAnswer => pick({
        StudyLanguage.ko: '정답 확인',
        StudyLanguage.en: 'Check Answer',
        StudyLanguage.ja: '答え合わせ',
      });
  String get fillAll => pick({
        StudyLanguage.ko: '모든 칸을 채워 주세요',
        StudyLanguage.en: 'Fill every blank',
        StudyLanguage.ja: 'すべて埋めよう',
      });
  String get correct => pick({
        StudyLanguage.ko: '정답!',
        StudyLanguage.en: 'Correct!',
        StudyLanguage.ja: '正解!',
      });
  String get incorrect => pick({
        StudyLanguage.ko: '오답',
        StudyLanguage.en: 'Incorrect',
        StudyLanguage.ja: '不正解',
      });
  String get wordToMeaning => pick({
        StudyLanguage.ko: '스페인어 단어의 뜻은?',
        StudyLanguage.en: 'What does this Spanish word mean?',
        StudyLanguage.ja: 'スペイン語の意味は?',
      });
  String get meaningToWord => pick({
        StudyLanguage.ko: '이 뜻에 맞는 스페인어는?',
        StudyLanguage.en: 'Which Spanish word matches this meaning?',
        StudyLanguage.ja: '訳に合うスペイン語は?',
      });
  String get blankQuestion => pick({
        StudyLanguage.ko: '예문의 빈칸에 들어갈 단어는?',
        StudyLanguage.en: 'Which word fills the blank?',
        StudyLanguage.ja: '例文の空欄に入る語は?',
      });
  String levelLabel(String level) => 'DELE $level';
}
