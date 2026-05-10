import '../models/idiom.dart';

class AppText {
  final StudyLanguage language;
  const AppText(this.language);

  String pick(Map<StudyLanguage, String> values) =>
      values[language] ?? values[StudyLanguage.ko] ?? '';

  String get appName => pick({
    StudyLanguage.ko: '단어도장깨기:스페인어(DELE)',
    StudyLanguage.en: 'Vocab Dojo: Spanish(DELE)',
    StudyLanguage.ja: '単語道場:スペイン語(DELE)',
  });
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
    StudyLanguage.en:
        'Answer 50 questions to set records and fill the wordbook.',
    StudyLanguage.ja: '50問連続で記録更新と単語帳コンプリートを狙う。',
  });
  String get fiftyQuestionQuiz => pick({
    StudyLanguage.ko: '50문제 퀴즈',
    StudyLanguage.en: '50Q Quiz',
    StudyLanguage.ja: '50問クイズ',
  });
  String get marathonFocusedSubtitle => pick({
    StudyLanguage.ko: '50문제로 스페인어 어휘를 집중 연습해요.',
    StudyLanguage.en: '50 questions for focused vocabulary practice.',
    StudyLanguage.ja: '50問でスペイン語語彙を集中トレーニング。',
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
  String wordbookTitle(int unlocked, int total) => '$wordbook $unlocked/$total';
  String unlockHint(int threshold) => pick({
    StudyLanguage.ko: '$threshold회 이상 정답을 맞히면 단어가 해금됩니다',
    StudyLanguage.en: 'Unlock: answer correctly $threshold time or more',
    StudyLanguage.ja: '$threshold回以上正解すると単語が解放されます',
  });
  String lockedProgress(int count, int threshold) => pick({
    StudyLanguage.ko: '잠김 ($count / $threshold)',
    StudyLanguage.en: 'Locked ($count / $threshold)',
    StudyLanguage.ja: '未解放 ($count / $threshold)',
  });
  String lockedUnlockBody(int threshold) => pick({
    StudyLanguage.ko: '$threshold회 이상 정답을 맞히면 이 단어가 해금됩니다.',
    StudyLanguage.en:
        'Answer correctly $threshold time or more to unlock this word.',
    StudyLanguage.ja: '$threshold回以上正解するとこの単語が解放されます。',
  });
  String get searchWordbookHint => pick({
    StudyLanguage.ko: '스페인어, 뜻, 레벨 검색',
    StudyLanguage.en: 'Search Spanish, meaning, or level',
    StudyLanguage.ja: 'スペイン語・意味・レベルを検索',
  });
  String get filterAll => pick({
    StudyLanguage.ko: '전체',
    StudyLanguage.en: 'All',
    StudyLanguage.ja: 'すべて',
  });
  String get unlocked => pick({
    StudyLanguage.ko: '해금됨',
    StudyLanguage.en: 'Unlocked',
    StudyLanguage.ja: '解放済み',
  });
  String get locked => pick({
    StudyLanguage.ko: '잠김',
    StudyLanguage.en: 'Locked',
    StudyLanguage.ja: '未解放',
  });
  String get noWordsFound => pick({
    StudyLanguage.ko: '단어가 없습니다',
    StudyLanguage.en: 'No words found',
    StudyLanguage.ja: '単語が見つかりません',
  });
  String noWordsMatch(String query) => pick({
    StudyLanguage.ko: '"$query"와 일치하는 단어가 없습니다',
    StudyLanguage.en: 'No words match "$query"',
    StudyLanguage.ja: '"$query" に一致する単語がありません',
  });
  String get backToTop => pick({
    StudyLanguage.ko: '맨 위로',
    StudyLanguage.en: 'Back to top',
    StudyLanguage.ja: '上へ戻る',
  });
  String get clear => pick({
    StudyLanguage.ko: '지우기',
    StudyLanguage.en: 'Clear',
    StudyLanguage.ja: 'クリア',
  });
  String get languageMenu => pick({
    StudyLanguage.ko: '언어',
    StudyLanguage.en: 'Language',
    StudyLanguage.ja: '言語',
  });
  String get mute => pick({
    StudyLanguage.ko: '음소거',
    StudyLanguage.en: 'Mute',
    StudyLanguage.ja: 'ミュート',
  });
  String get unmute => pick({
    StudyLanguage.ko: '음소거 해제',
    StudyLanguage.en: 'Unmute',
    StudyLanguage.ja: 'ミュート解除',
  });
  String get appInfo => pick({
    StudyLanguage.ko: '앱 정보',
    StudyLanguage.en: 'App info',
    StudyLanguage.ja: 'アプリ情報',
  });
  String get versionLabel => pick({
    StudyLanguage.ko: '버전',
    StudyLanguage.en: 'Version',
    StudyLanguage.ja: 'バージョン',
  });
  String get dataStorage => pick({
    StudyLanguage.ko: '데이터 저장',
    StudyLanguage.en: 'Data storage',
    StudyLanguage.ja: 'データ保存',
  });
  String get dataStorageBody => pick({
    StudyLanguage.ko:
        '퀴즈 진행도, 해금된 단어, 아이템, 언어 설정은 이 기기에만 저장됩니다. 학습 데이터는 외부 서버로 전송되지 않으며, 앱을 삭제하면 로컬 데이터도 삭제됩니다.',
    StudyLanguage.en:
        'Quiz progress, mastered words, items, and language settings are stored only on this device. No study data is sent to an external server. Uninstalling the app deletes the local data.',
    StudyLanguage.ja:
        'クイズの進行状況、解放済み単語、アイテム、言語設定はこの端末にのみ保存されます。学習データは外部サーバーへ送信されず、アプリを削除するとローカルデータも削除されます。',
  });
  String get feedback => pick({
    StudyLanguage.ko: '피드백',
    StudyLanguage.en: 'Feedback',
    StudyLanguage.ja: 'フィードバック',
  });
  String get feedbackOpenFailed => pick({
    StudyLanguage.ko: '피드백 양식을 열 수 없습니다.',
    StudyLanguage.en: 'Could not open the feedback form.',
    StudyLanguage.ja: 'フィードバックフォームを開けませんでした。',
  });
  String get licenses => pick({
    StudyLanguage.ko: '라이선스',
    StudyLanguage.en: 'Licenses',
    StudyLanguage.ja: 'ライセンス',
  });
  String get openSourceLicenses => pick({
    StudyLanguage.ko: '오픈소스 라이선스',
    StudyLanguage.en: 'Open source licenses',
    StudyLanguage.ja: 'オープンソースライセンス',
  });
  String get close => pick({
    StudyLanguage.ko: '닫기',
    StudyLanguage.en: 'Close',
    StudyLanguage.ja: '閉じる',
  });
  String get playPronunciation => pick({
    StudyLanguage.ko: '발음 듣기',
    StudyLanguage.en: 'Play pronunciation',
    StudyLanguage.ja: '発音を聞く',
  });
  String get partOfSpeech => pick({
    StudyLanguage.ko: '품사',
    StudyLanguage.en: 'Type',
    StudyLanguage.ja: '品詞',
  });
  String get example => pick({
    StudyLanguage.ko: '예문',
    StudyLanguage.en: 'Example',
    StudyLanguage.ja: '例文',
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
  String get practiceModes => pick({
    StudyLanguage.ko: '연습 모드',
    StudyLanguage.en: 'Practice modes',
    StudyLanguage.ja: '練習モード',
  });
  String get recommended => pick({
    StudyLanguage.ko: '추천',
    StudyLanguage.en: 'Recommended',
    StudyLanguage.ja: 'おすすめ',
  });
  String get puzzleBadge => pick({
    StudyLanguage.ko: '퍼즐',
    StudyLanguage.en: 'Puzzle',
    StudyLanguage.ja: 'パズル',
  });
  String get deleVocabularyTraining => pick({
    StudyLanguage.ko: 'DELE 어휘 트레이닝',
    StudyLanguage.en: 'DELE vocabulary training',
    StudyLanguage.ja: 'DELE語彙トレーニング',
  });
  String get oneWordADay => pick({
    StudyLanguage.ko: '하루 한 단어',
    StudyLanguage.en: 'One word a day',
    StudyLanguage.ja: '1日1語',
  });
  String get rank => pick({
    StudyLanguage.ko: '랭크',
    StudyLanguage.en: 'Rank',
    StudyLanguage.ja: 'ランク',
  });
  String get level => pick({
    StudyLanguage.ko: '레벨',
    StudyLanguage.en: 'Level',
    StudyLanguage.ja: 'レベル',
  });
  String nextLevel(int remaining) => pick({
    StudyLanguage.ko: '다음 레벨까지 +$remaining',
    StudyLanguage.en: 'Next level +$remaining',
    StudyLanguage.ja: '次のレベルまで +$remaining',
  });
  String nextRank(String name, int remaining) => pick({
    StudyLanguage.ko: '다음 랭크 $name +$remaining',
    StudyLanguage.en: 'Next rank $name +$remaining',
    StudyLanguage.ja: '次のランク $name +$remaining',
  });
  String get maxRank => pick({
    StudyLanguage.ko: '최고 랭크',
    StudyLanguage.en: 'Max rank',
    StudyLanguage.ja: '最高ランク',
  });
  String get totalStars => pick({
    StudyLanguage.ko: '총 별',
    StudyLanguage.en: 'Total stars',
    StudyLanguage.ja: '合計スター',
  });
  String get clearHalfPreviousStage => pick({
    StudyLanguage.ko: '이전 스테이지 별 절반 이상 필요',
    StudyLanguage.en: 'Clear half of previous stage',
    StudyLanguage.ja: '前ステージの半分以上をクリア',
  });
  String get clearPreviousRound => pick({
    StudyLanguage.ko: '이전 라운드 클리어 필요',
    StudyLanguage.en: 'Clear previous round',
    StudyLanguage.ja: '前のラウンドをクリア',
  });
  String roundLabel(int number) => pick({
    StudyLanguage.ko: '라운드 $number',
    StudyLanguage.en: 'Round $number',
    StudyLanguage.ja: 'ラウンド $number',
  });
  String get stageMode => pick({
    StudyLanguage.ko: '스테이지 모드',
    StudyLanguage.en: 'Stage Mode',
    StudyLanguage.ja: 'ステージモード',
  });
  String get crosswordStages => pick({
    StudyLanguage.ko: '크로스워드 스테이지',
    StudyLanguage.en: 'Crossword Stages',
    StudyLanguage.ja: 'クロスワードステージ',
  });
  String get crosswordStage => pick({
    StudyLanguage.ko: '크로스워드 스테이지',
    StudyLanguage.en: 'Crossword stage',
    StudyLanguage.ja: 'クロスワードステージ',
  });
  String get words => pick({
    StudyLanguage.ko: '단어',
    StudyLanguage.en: 'Words',
    StudyLanguage.ja: '単語',
  });
  String get puzzles => pick({
    StudyLanguage.ko: '퍼즐',
    StudyLanguage.en: 'Puzzles',
    StudyLanguage.ja: 'パズル',
  });
  String crosswordStageDescription(int words) => pick({
    StudyLanguage.ko:
        '한 보드에 $words개 단어가 모두 등장합니다. 뒤 스테이지일수록 더 어려운 단어 조합이 나옵니다.',
    StudyLanguage.en:
        'All $words words appear in one board. Later stages use higher difficulty word pairs.',
    StudyLanguage.ja: '1つのボードに$words語すべてが登場します。後半ステージほど難しい単語ペアになります。',
  });
  String crosswordStageSummary(String level, int words, int puzzles) => pick({
    StudyLanguage.ko: '$level · $words개 단어 · $puzzles개 퍼즐',
    StudyLanguage.en: '$level · $words words · $puzzles puzzles',
    StudyLanguage.ja: '$level · $words語 · $puzzlesパズル',
  });
  String get seeResult => pick({
    StudyLanguage.ko: '결과 보기',
    StudyLanguage.en: 'See result',
    StudyLanguage.ja: '結果を見る',
  });
  String get nextQuestion => pick({
    StudyLanguage.ko: '다음 문제',
    StudyLanguage.en: 'Next question',
    StudyLanguage.ja: '次の問題',
  });
  String get itemGained => pick({
    StudyLanguage.ko: '아이템 획득!',
    StudyLanguage.en: 'Item gained!',
    StudyLanguage.ja: 'アイテム獲得!',
  });
  String itemGainedWithLabel(String label) => pick({
    StudyLanguage.ko: '아이템 획득: $label',
    StudyLanguage.en: 'Item gained: $label',
    StudyLanguage.ja: 'アイテム獲得: $label',
  });
  String get result => pick({
    StudyLanguage.ko: '결과',
    StudyLanguage.en: 'Result',
    StudyLanguage.ja: '結果',
  });
  String resultTitle(double rate) {
    if (rate == 1.0) {
      return pick({
        StudyLanguage.ko: '완벽해요!',
        StudyLanguage.en: 'Perfect!',
        StudyLanguage.ja: 'パーフェクト!',
      });
    }
    if (rate >= 0.8) {
      return pick({
        StudyLanguage.ko: '잘했어요!',
        StudyLanguage.en: 'Great work!',
        StudyLanguage.ja: 'よくできました!',
      });
    }
    if (rate >= 0.5) {
      return pick({
        StudyLanguage.ko: '계속 해봐요!',
        StudyLanguage.en: 'Keep going!',
        StudyLanguage.ja: 'この調子!',
      });
    }
    return pick({
      StudyLanguage.ko: '다음 도전을 해봐요.',
      StudyLanguage.en: 'Try the next run.',
      StudyLanguage.ja: '次の挑戦へ進みましょう。',
    });
  }

  String get bestStreak => pick({
    StudyLanguage.ko: '최고 연속 정답',
    StudyLanguage.en: 'Best streak',
    StudyLanguage.ja: '最高連続正解',
  });
  String get runPoints => pick({
    StudyLanguage.ko: '이번 점수',
    StudyLanguage.en: 'Run points',
    StudyLanguage.ja: '今回のポイント',
  });
  String get totalPoints => pick({
    StudyLanguage.ko: '총 점수',
    StudyLanguage.en: 'Total points',
    StudyLanguage.ja: '合計ポイント',
  });
  String get currentRank => pick({
    StudyLanguage.ko: '현재 랭크',
    StudyLanguage.en: 'Current rank',
    StudyLanguage.ja: '現在のランク',
  });
  String get backHome => pick({
    StudyLanguage.ko: '홈으로',
    StudyLanguage.en: 'Back home',
    StudyLanguage.ja: 'ホームへ',
  });
  String itemsGained(int count) => pick({
    StudyLanguage.ko: '아이템 획득 ×$count',
    StudyLanguage.en: 'Items gained ×$count',
    StudyLanguage.ja: 'アイテム獲得 ×$count',
  });
  String get levelUp => pick({
    StudyLanguage.ko: '레벨 업!',
    StudyLanguage.en: 'Level up!',
    StudyLanguage.ja: 'レベルアップ!',
  });
  String get rankUp => pick({
    StudyLanguage.ko: '랭크 업!',
    StudyLanguage.en: 'Rank up!',
    StudyLanguage.ja: 'ランクアップ!',
  });
  String get roundFailed => pick({
    StudyLanguage.ko: '라운드 실패',
    StudyLanguage.en: 'Round failed',
    StudyLanguage.ja: 'ラウンド失敗',
  });
  String roundFailedBody(int minCorrect, int correct, int total) => pick({
    StudyLanguage.ko:
        '이 라운드를 클리어하려면 최소 $minCorrect개 이상 맞혀야 합니다 ($correct / $total).',
    StudyLanguage.en:
        'You need at least $minCorrect correct answers to clear this round ($correct / $total).',
    StudyLanguage.ja:
        'このラウンドをクリアするには最低$minCorrect問正解が必要です ($correct / $total)。',
  });
  String get cleared => pick({
    StudyLanguage.ko: '클리어!',
    StudyLanguage.en: 'Cleared!',
    StudyLanguage.ja: 'クリア!',
  });
  String get bestUpdated => pick({
    StudyLanguage.ko: '최고 기록 갱신!',
    StudyLanguage.en: 'Best updated!',
    StudyLanguage.ja: 'ベスト更新!',
  });
  String thisRunStars(int stars) => pick({
    StudyLanguage.ko: '이번 결과: ☆ $stars',
    StudyLanguage.en: 'This run: ☆ $stars',
    StudyLanguage.ja: '今回: ☆ $stars',
  });
  String bestStars(int stars) => pick({
    StudyLanguage.ko: '최고 ☆ $stars',
    StudyLanguage.en: 'Best ☆ $stars',
    StudyLanguage.ja: 'ベスト ☆ $stars',
  });
  String get marathonBestUpdated => pick({
    StudyLanguage.ko: '마라톤 최고 기록 갱신!',
    StudyLanguage.en: 'Marathon best updated!',
    StudyLanguage.ja: 'マラソンベスト更新!',
  });
  String get marathonRecord => pick({
    StudyLanguage.ko: '마라톤 기록',
    StudyLanguage.en: 'Marathon record',
    StudyLanguage.ja: 'マラソン記録',
  });
  String bestScore(int score, int total, String percentile) => pick({
    StudyLanguage.ko: '최고: $score / $total ($percentile)',
    StudyLanguage.en: 'Best: $score / $total ($percentile)',
    StudyLanguage.ja: 'ベスト: $score / $total ($percentile)',
  });
  String previousBest(int score, int total) => pick({
    StudyLanguage.ko: '이전 최고: $score / $total',
    StudyLanguage.en: 'Previous best: $score / $total',
    StudyLanguage.ja: '前回ベスト: $score / $total',
  });
  String get vocabularyTier => pick({
    StudyLanguage.ko: '어휘 티어',
    StudyLanguage.en: 'Vocabulary tier',
    StudyLanguage.ja: '語彙ティア',
  });
  String percentileLabel(String raw) {
    final percent = RegExp(r'\d+').firstMatch(raw)?.group(0) ?? '';
    if (percent.isEmpty) return raw;
    return pick({
      StudyLanguage.ko: '상위 $percent% 추정',
      StudyLanguage.en: raw,
      StudyLanguage.ja: '上位$percent%推定',
    });
  }

  String tierLabel(String raw) => pick({
    StudyLanguage.ko: raw
        .replaceAll('Starter', '입문')
        .replaceAll('Explorer', '탐색')
        .replaceAll('Builder', '빌더')
        .replaceAll('Speaker', '스피커')
        .replaceAll('Analyst', '분석')
        .replaceAll('Pro', '프로')
        .replaceAll('Master', '마스터'),
    StudyLanguage.en: raw,
    StudyLanguage.ja: raw
        .replaceAll('Starter', '入門')
        .replaceAll('Explorer', '探索')
        .replaceAll('Builder', 'ビルダー')
        .replaceAll('Speaker', 'スピーカー')
        .replaceAll('Analyst', '分析')
        .replaceAll('Pro', 'プロ')
        .replaceAll('Master', 'マスター'),
  });
  String tierSubtitle(String raw) => pick({
    StudyLanguage.ko: switch (raw) {
      'Core survival words' => '기초 생존 단어',
      'Daily-life vocabulary' => '일상생활 어휘',
      'Travel and routine words' => '여행과 일상 단어',
      'Opinions and experiences' => '의견과 경험 표현',
      'Abstract and news vocabulary' => '추상/뉴스 어휘',
      'Exam-ready vocabulary' => '시험 대비 어휘',
      'Complete mastery track' => '완성형 마스터 코스',
      _ => raw,
    },
    StudyLanguage.en: raw,
    StudyLanguage.ja: switch (raw) {
      'Core survival words' => '基礎サバイバル単語',
      'Daily-life vocabulary' => '日常生活語彙',
      'Travel and routine words' => '旅行と日常の単語',
      'Opinions and experiences' => '意見と経験の表現',
      'Abstract and news vocabulary' => '抽象・ニュース語彙',
      'Exam-ready vocabulary' => '試験対策語彙',
      'Complete mastery track' => '完全マスターコース',
      _ => raw,
    },
  });
  String masteredTopTier(int count) => pick({
    StudyLanguage.ko: '$count개 마스터 · 최고 티어 도달',
    StudyLanguage.en: '$count mastered · top tier reached',
    StudyLanguage.ja: '$count語マスター · 最高ティア到達',
  });
  String masteredToNext(int count, int remaining, String nextLabel) => pick({
    StudyLanguage.ko: '$count개 마스터 · $nextLabel까지 $remaining개',
    StudyLanguage.en: '$count mastered · $remaining to $nextLabel',
    StudyLanguage.ja: '$count語マスター · $nextLabelまで$remaining語',
  });
  String get newLevelReached => pick({
    StudyLanguage.ko: '새 레벨에 도달했어요!',
    StudyLanguage.en: 'New level reached!',
    StudyLanguage.ja: '新しいレベルに到達しました!',
  });
  String get continueLabel => pick({
    StudyLanguage.ko: '계속',
    StudyLanguage.en: 'Continue',
    StudyLanguage.ja: '続ける',
  });
  String get adLoadFailed => pick({
    StudyLanguage.ko: '광고를 불러올 수 없습니다. 잠시 후 다시 시도해 주세요.',
    StudyLanguage.en: 'Could not load the ad. Please try again later.',
    StudyLanguage.ja: '広告を読み込めませんでした。しばらくしてからもう一度お試しください。',
  });
  String get loadingAd => pick({
    StudyLanguage.ko: '광고 불러오는 중...',
    StudyLanguage.en: 'Loading ad...',
    StudyLanguage.ja: '広告を読み込み中...',
  });
  String get watchVideoForItem => pick({
    StudyLanguage.ko: '동영상 보고 아이템 +1',
    StudyLanguage.en: 'Watch video for item +1',
    StudyLanguage.ja: '動画視聴でアイテム +1',
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
    StudyLanguage.en:
        'Drag the letters into the blanks. The shared letter is fixed as a hint.',
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
  String get done => pick({
    StudyLanguage.ko: '완료',
    StudyLanguage.en: 'Done',
    StudyLanguage.ja: '完了',
  });
  String get saving => pick({
    StudyLanguage.ko: '저장 중...',
    StudyLanguage.en: 'Saving...',
    StudyLanguage.ja: '保存中...',
  });
  String get score => pick({
    StudyLanguage.ko: '점수',
    StudyLanguage.en: 'Score',
    StudyLanguage.ja: 'スコア',
  });
  String get combo => pick({
    StudyLanguage.ko: '콤보',
    StudyLanguage.en: 'Combo',
    StudyLanguage.ja: 'コンボ',
  });
  String get thisPuzzle => pick({
    StudyLanguage.ko: '이번',
    StudyLanguage.en: 'This',
    StudyLanguage.ja: '今回',
  });
  String hintCount(int used, int total) => pick({
    StudyLanguage.ko: '힌트 $used/$total',
    StudyLanguage.en: 'Hint $used/$total',
    StudyLanguage.ja: 'ヒント $used/$total',
  });
  String get solved => pick({
    StudyLanguage.ko: '해결',
    StudyLanguage.en: 'Solved',
    StudyLanguage.ja: '解答',
  });
  String get best => pick({
    StudyLanguage.ko: '최고',
    StudyLanguage.en: 'Best',
    StudyLanguage.ja: 'ベスト',
  });
  String get crosswordClear => pick({
    StudyLanguage.ko: '크로스워드 클리어',
    StudyLanguage.en: 'Crossword clear',
    StudyLanguage.ja: 'クロスワードクリア',
  });
  String stageBoardWords(int words) => pick({
    StudyLanguage.ko: '$words개 단어 한 보드',
    StudyLanguage.en: '$words words in one board',
    StudyLanguage.ja: '$words語を1つのボードで',
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
  String quizModeLabel(String modeName) {
    switch (modeName) {
      case 'translationLookup':
        return pick({
          StudyLanguage.ko: '뜻',
          StudyLanguage.en: 'Meaning',
          StudyLanguage.ja: '意味',
        });
      case 'wordLookup':
        return pick({
          StudyLanguage.ko: '단어',
          StudyLanguage.en: 'Word',
          StudyLanguage.ja: '単語',
        });
      case 'sentenceBlank':
        return pick({
          StudyLanguage.ko: '빈칸',
          StudyLanguage.en: 'Blank',
          StudyLanguage.ja: '穴埋め',
        });
    }
    return modeName;
  }

  String levelLabel(String level) => 'DELE $level';
}
