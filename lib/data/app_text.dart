import '../models/idiom.dart';

class AppText {
  final StudyLanguage language;
  const AppText(this.language);

  String pick(Map<StudyLanguage, String> values) =>
      values[language] ?? values[StudyLanguage.ko] ?? '';

  String get appName => 'DELE Voca Dojo';
  String get ttsMissingVoice => pick({
    StudyLanguage.ko: '기기에 스페인어 음성이 설치되어 있지 않아 발음을 재생할 수 없습니다.',
    StudyLanguage.en:
        'No Spanish voice is installed on this device, so '
        'pronunciation cannot play.',
    StudyLanguage.ja: '端末にスペイン語の音声がインストールされていないため、発音を再生できません。',
  });
  String get ttsInstallVoice => pick({
    StudyLanguage.ko: '설치',
    StudyLanguage.en: 'Install',
    StudyLanguage.ja: 'インストール',
  });
  String get ttsDownloadVoice => pick({
    StudyLanguage.ko: '스페인어 음성 다운로드',
    StudyLanguage.en: 'Download Spanish voice',
    StudyLanguage.ja: 'スペイン語音声をダウンロード',
  });
  String get ttsInstallSteps => pick({
    StudyLanguage.ko:
        '발음을 들으려면 스페인어 음성 데이터가 필요합니다.\n\n'
        '다음 화면에서 이렇게 해주세요.\n'
        '1. 엔진을 "Google 음성 서비스"로 선택\n'
        '2. 언어 설치 (또는 음성 데이터 설치)\n'
        '3. "스페인어(스페인)" 다운로드\n\n'
        '삼성 TTS 등 다른 엔진에는 스페인어가 없을 수 있으니 반드시 Google 음성 서비스를 선택하세요.',
    StudyLanguage.en:
        'Pronunciation needs Spanish voice data.\n\n'
        'On the next screen:\n'
        '1. Choose "Google Speech Services" as the engine\n'
        '2. Open Install voice data\n'
        '3. Download "Spanish (Spain)"\n\n'
        'Other engines such as Samsung TTS may not offer Spanish, so pick '
        'Google Speech Services.',
    StudyLanguage.ja:
        '発音の再生にはスペイン語の音声データが必要です。\n\n'
        '次の画面で以下を行ってください。\n'
        '1. エンジンを「Google 音声サービス」に設定\n'
        '2. 音声データのインストールを開く\n'
        '3. 「スペイン語(スペイン)」をダウンロード\n\n'
        'Samsung TTS など他のエンジンにはスペイン語がない場合があるため、必ず Google 音声サービスを選んでください。',
  });
  String get ttsOpenInstaller => pick({
    StudyLanguage.ko: '설치 화면 열기',
    StudyLanguage.en: 'Open installer',
    StudyLanguage.ja: 'インストール画面を開く',
  });
  String get cancel => pick({
    StudyLanguage.ko: '취소',
    StudyLanguage.en: 'Cancel',
    StudyLanguage.ja: 'キャンセル',
  });
  String get ttsSettingsUnavailable => pick({
    StudyLanguage.ko: '이 기기에서는 음성 설정 화면을 열 수 없습니다.',
    StudyLanguage.en: 'Voice settings cannot be opened on this device.',
    StudyLanguage.ja: 'この端末では音声設定を開けません。',
  });
  String get chooseLanguageTitle => pick({
    StudyLanguage.ko: '학습 언어를 선택해 주세요',
    StudyLanguage.en: 'Choose your study language',
    StudyLanguage.ja: '学習言語を選択してください',
  });
  String get chooseLanguageBody => pick({
    StudyLanguage.ko: '메뉴와 문제 해석에 사용할 언어입니다.',
    StudyLanguage.en: 'This controls menus and answer translations.',
    StudyLanguage.ja: 'メニューと解説に使う言語です。',
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
    StudyLanguage.ja: '単語・意味・例文穴埋めでDELE語彙を学びます。',
  });
  String get marathon => pick({
    StudyLanguage.ko: '마라톤',
    StudyLanguage.en: 'Marathon',
    StudyLanguage.ja: 'マラソン',
  });
  String get marathonSubtitle => pick({
    StudyLanguage.ko: '50문제를 이어 풀고 기록과 단어장을 채워요.',
    StudyLanguage.en:
        'Answer 50 questions to set records and fill the wordbook.',
    StudyLanguage.ja: '50問に挑戦して記録と単語帳を増やします。',
  });
  String get fiftyQuestionQuiz => pick({
    StudyLanguage.ko: '50문제 퀴즈',
    StudyLanguage.en: '50Q Quiz',
    StudyLanguage.ja: '50問クイズ',
  });
  String get marathonFocusedSubtitle => pick({
    StudyLanguage.ko: '50문제로 스페인어 어휘를 집중 연습해요.',
    StudyLanguage.en: '50 questions for focused vocabulary practice.',
    StudyLanguage.ja: '50問でスペイン語語彙を集中練習します。',
  });
  String get randomChallengeMode => pick({
    StudyLanguage.ko: '랜덤 챌린지 모드',
    StudyLanguage.en: 'Random Challenge Mode',
    StudyLanguage.ja: 'ランダムチャレンジモード',
  });
  String get randomChallengeSubtitle => pick({
    StudyLanguage.ko: '무작위 50문제로 스페인어 어휘를 집중 점검해요.',
    StudyLanguage.en: 'Check your Spanish vocabulary with 50 random questions.',
    StudyLanguage.ja: 'ランダム50問でスペイン語語彙を確認します。',
  });
  String get wrongNote => pick({
    StudyLanguage.ko: '오답 노트',
    StudyLanguage.en: 'Wrong Notes',
    StudyLanguage.ja: '間違いノート',
  });
  String get wrongNoteSubtitle => pick({
    StudyLanguage.ko: '틀린 단어만 다시 풀고 맞히면 오답 노트에서 정리돼요.',
    StudyLanguage.en: 'Review missed words. Correct answers clear them.',
    StudyLanguage.ja: '間違えた単語を復習します。正解すると整理されます。',
  });
  String wrongNoteCount(int count) => pick({
    StudyLanguage.ko: '복습할 오답 $count개',
    StudyLanguage.en: '$count words to review',
    StudyLanguage.ja: '復習する単語 $count個',
  });
  String get startReview => pick({
    StudyLanguage.ko: '오답 다시 풀기',
    StudyLanguage.en: 'Review wrong notes',
    StudyLanguage.ja: '復習を始める',
  });
  String wrongNoteReviewLocked(int min) => pick({
    StudyLanguage.ko: '오답이 $min개 이상 모이면 복습할 수 있어요',
    StudyLanguage.en: 'Collect $min wrong notes to unlock review',
    StudyLanguage.ja: '間違いが$min個以上たまると復習できます',
  });
  String get noWrongNotes => pick({
    StudyLanguage.ko: '아직 오답이 없어요',
    StudyLanguage.en: 'No wrong notes yet',
    StudyLanguage.ja: 'まだ間違いはありません',
  });
  String get noWrongNotesBody => pick({
    StudyLanguage.ko: '퀴즈에서 틀린 단어가 생기면 여기에 자동으로 모입니다.',
    StudyLanguage.en: 'Words you miss in quizzes will appear here.',
    StudyLanguage.ja: 'クイズで間違えた単語がここに表示されます。',
  });
  String get wordbook => pick({
    StudyLanguage.ko: '단어장',
    StudyLanguage.en: 'Wordbook',
    StudyLanguage.ja: '単語帳',
  });
  String wordbookTitle(int unlocked, int total) => '$wordbook $unlocked/$total';
  String unlockHint(int threshold) => pick({
    StudyLanguage.ko: '정답을 $threshold번 이상 맞히면 단어가 수집돼요.',
    StudyLanguage.en: 'Collect: answer correctly $threshold time or more',
    StudyLanguage.ja: '$threshold回以上正解すると単語を収集できます。',
  });
  String lockedProgress(int count, int threshold) => pick({
    StudyLanguage.ko: '미수집 ($count / $threshold)',
    StudyLanguage.en: 'Uncollected ($count / $threshold)',
    StudyLanguage.ja: '未収集 ($count / $threshold)',
  });
  String lockedUnlockBody(int threshold) => pick({
    StudyLanguage.ko: '$threshold번 이상 정답을 맞히면 이 단어가 수집돼요.',
    StudyLanguage.en:
        'Answer correctly $threshold time or more to collect this word.',
    StudyLanguage.ja: '$threshold回以上正解するとこの単語を収集できます。',
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
    StudyLanguage.ko: '수집완료',
    StudyLanguage.en: 'Collected',
    StudyLanguage.ja: '収集済み',
  });
  String get locked => pick({
    StudyLanguage.ko: '미수집',
    StudyLanguage.en: 'Uncollected',
    StudyLanguage.ja: '未収集',
  });
  String get noWordsFound => pick({
    StudyLanguage.ko: '단어가 없어요',
    StudyLanguage.en: 'No words found',
    StudyLanguage.ja: '単語が見つかりません',
  });
  String noWordsMatch(String query) => pick({
    StudyLanguage.ko: '"$query"에 맞는 단어가 없어요',
    StudyLanguage.en: 'No words match "$query"',
    StudyLanguage.ja: '"$query"に一致する単語がありません',
  });
  String get backToTop => pick({
    StudyLanguage.ko: '맨 위로',
    StudyLanguage.en: 'Back to top',
    StudyLanguage.ja: '上へ',
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
    StudyLanguage.ko: '퀴즈 진행 상황, 수집 단어, 아이템, 언어 설정은 이 기기에만 저장됩니다.',
    StudyLanguage.en:
        'Quiz progress, mastered words, items, and language settings are stored only on this device.',
    StudyLanguage.ja: '学習データと言語設定はこの端末にのみ保存されます。',
  });
  String get feedback => pick({
    StudyLanguage.ko: '피드백 보내기',
    StudyLanguage.en: 'Send feedback',
    StudyLanguage.ja: 'フィードバック',
  });
  String get feedbackOpenFailed => pick({
    StudyLanguage.ko: '피드백 양식을 열 수 없어요.',
    StudyLanguage.en: 'Could not open the feedback form.',
    StudyLanguage.ja: 'フォームを開けませんでした。',
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
    StudyLanguage.ko: '발음 재생',
    StudyLanguage.en: 'Play pronunciation',
    StudyLanguage.ja: '発音を再生',
  });
  String get partOfSpeech => pick({
    StudyLanguage.ko: '품사',
    StudyLanguage.en: 'Part of speech',
    StudyLanguage.ja: '品詞',
  });

  String partOfSpeechName(String value) {
    final normalized = value.toLowerCase();
    final names = <String, Map<StudyLanguage, String>>{
      'noun': {
        StudyLanguage.ko: '명사',
        StudyLanguage.en: 'Noun',
        StudyLanguage.ja: '名詞',
      },
      'verb': {
        StudyLanguage.ko: '동사',
        StudyLanguage.en: 'Verb',
        StudyLanguage.ja: '動詞',
      },
      'adjective': {
        StudyLanguage.ko: '형용사',
        StudyLanguage.en: 'Adjective',
        StudyLanguage.ja: '形容詞',
      },
      'adverb': {
        StudyLanguage.ko: '부사',
        StudyLanguage.en: 'Adverb',
        StudyLanguage.ja: '副詞',
      },
      'phrase': {
        StudyLanguage.ko: '표현',
        StudyLanguage.en: 'Phrase',
        StudyLanguage.ja: '表現',
      },
      'connector': {
        StudyLanguage.ko: '연결어',
        StudyLanguage.en: 'Connector',
        StudyLanguage.ja: '接続語',
      },
    };
    return pick(names[normalized] ?? {StudyLanguage.ko: value});
  }

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
    StudyLanguage.ja: '最近のマラソン',
  });
  String get todaysWord => pick({
    StudyLanguage.ko: '오늘의 단어',
    StudyLanguage.en: 'Word of the Day',
    StudyLanguage.ja: '今日の単語',
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
  String get deleVocabularyTraining => pick({
    StudyLanguage.ko: 'DELE 어휘 트레이닝',
    StudyLanguage.en: 'DELE vocabulary training',
    StudyLanguage.ja: 'DELE語彙トレーニング',
  });
  String get oneWordADay => pick({
    StudyLanguage.ko: '하루 한 단어',
    StudyLanguage.en: 'One word a day',
    StudyLanguage.ja: '1日1単語',
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
  String get studyStreak => pick({
    StudyLanguage.ko: '연속 학습',
    StudyLanguage.en: 'Study streak',
    StudyLanguage.ja: '連続学習',
  });
  String studyStreakDays(int days) => pick({
    StudyLanguage.ko: '$days일',
    StudyLanguage.en: '$days days',
    StudyLanguage.ja: '$days日',
  });
  String get stageStars => pick({
    StudyLanguage.ko: '스테이지 별',
    StudyLanguage.en: 'Stage stars',
    StudyLanguage.ja: 'ステージスター',
  });
  String get title => pick({
    StudyLanguage.ko: '칭호',
    StudyLanguage.en: 'Title',
    StudyLanguage.ja: '称号',
  });
  String get titles => pick({
    StudyLanguage.ko: '칭호',
    StudyLanguage.en: 'Titles',
    StudyLanguage.ja: '称号',
  });

  String rankLabel(String raw) {
    final labels = <String, Map<StudyLanguage, String>>{
      'Novato': {
        StudyLanguage.ko: '입문자',
        StudyLanguage.en: 'Beginner',
        StudyLanguage.ja: '入門者',
      },
      'Aprendiz': {
        StudyLanguage.ko: '견습 학습자',
        StudyLanguage.en: 'Apprentice Learner',
        StudyLanguage.ja: '見習い学習者',
      },
      'Explorador': {
        StudyLanguage.ko: '탐험가',
        StudyLanguage.en: 'Explorer',
        StudyLanguage.ja: '探検家',
      },
      'Estudiante': {
        StudyLanguage.ko: '학생',
        StudyLanguage.en: 'Student',
        StudyLanguage.ja: '学生',
      },
      'Hablante': {
        StudyLanguage.ko: '말하는 사람',
        StudyLanguage.en: 'Speaker',
        StudyLanguage.ja: '話し手',
      },
      'Viajero': {
        StudyLanguage.ko: '여행자',
        StudyLanguage.en: 'Traveler',
        StudyLanguage.ja: '旅行者',
      },
      'Conversador': {
        StudyLanguage.ko: '대화가',
        StudyLanguage.en: 'Conversationalist',
        StudyLanguage.ja: '会話上手',
      },
      'Intérprete': {
        StudyLanguage.ko: '통역가',
        StudyLanguage.en: 'Interpreter',
        StudyLanguage.ja: '通訳者',
      },
      'Int챕rprete': {
        StudyLanguage.ko: '통역가',
        StudyLanguage.en: 'Interpreter',
        StudyLanguage.ja: '通訳者',
      },
      'Lingüista': {
        StudyLanguage.ko: '언어 탐구자',
        StudyLanguage.en: 'Linguist',
        StudyLanguage.ja: '言語探究者',
      },
      'Ling체ista': {
        StudyLanguage.ko: '언어 탐구자',
        StudyLanguage.en: 'Linguist',
        StudyLanguage.ja: '言語探究者',
      },
      'Embajador': {
        StudyLanguage.ko: '문화 대사',
        StudyLanguage.en: 'Ambassador',
        StudyLanguage.ja: '文化大使',
      },
      'Maestro': {
        StudyLanguage.ko: '숙련자',
        StudyLanguage.en: 'Master',
        StudyLanguage.ja: '熟練者',
      },
      'Sabio': {
        StudyLanguage.ko: '현자',
        StudyLanguage.en: 'Sage',
        StudyLanguage.ja: '賢者',
      },
      'Gran Maestro': {
        StudyLanguage.ko: '대가',
        StudyLanguage.en: 'Grand Master',
        StudyLanguage.ja: '大師範',
      },
    };
    return pick(labels[raw] ?? {StudyLanguage.ko: raw});
  }

  String titleLabel(String id, String fallback) => switch (id) {
    'rank' => rankLabel(fallback),
    'streak_3' => pick({
      StudyLanguage.ko: '꾸준한 학습자',
      StudyLanguage.en: 'Streak Keeper',
      StudyLanguage.ja: '継続学習者',
    }),
    'streak_7' => pick({
      StudyLanguage.ko: '7일 학습자',
      StudyLanguage.en: 'Seven-Day Scholar',
      StudyLanguage.ja: '7日学習者',
    }),
    'star_20' => pick({
      StudyLanguage.ko: '스테이지 등반가',
      StudyLanguage.en: 'Stage Climber',
      StudyLanguage.ja: 'ステージ登山家',
    }),
    'star_40' => pick({
      StudyLanguage.ko: '스테이지 달인',
      StudyLanguage.en: 'Stage Master',
      StudyLanguage.ja: 'ステージ達人',
    }),
    'combo_10' => pick({
      StudyLanguage.ko: '콤보 메이커',
      StudyLanguage.en: 'Combo Maker',
      StudyLanguage.ja: 'コンボメーカー',
    }),
    'collector_50' => pick({
      StudyLanguage.ko: '단어 수집가',
      StudyLanguage.en: 'Collector',
      StudyLanguage.ja: '単語収集家',
    }),
    'marathon_40' => pick({
      StudyLanguage.ko: '마라톤 주자',
      StudyLanguage.en: 'Marathon Runner',
      StudyLanguage.ja: 'マラソン走者',
    }),
    _ => fallback,
  };

  String titleDescription(String id, String fallback) => switch (id) {
    'rank' => pick({
      StudyLanguage.ko: '현재 랭크',
      StudyLanguage.en: 'Current rank',
      StudyLanguage.ja: '現在のランク',
    }),
    'streak_3' => pick({
      StudyLanguage.ko: '3일 연속 학습',
      StudyLanguage.en: 'Study 3 days in a row',
      StudyLanguage.ja: '3日連続学習',
    }),
    'streak_7' => pick({
      StudyLanguage.ko: '7일 연속 학습',
      StudyLanguage.en: 'Study 7 days in a row',
      StudyLanguage.ja: '7日連続学習',
    }),
    'star_20' => pick({
      StudyLanguage.ko: '스테이지 별 20개 획득',
      StudyLanguage.en: 'Earn 20 stage stars',
      StudyLanguage.ja: 'ステージスター20個獲得',
    }),
    'star_40' => pick({
      StudyLanguage.ko: '스테이지 별 40개 획득',
      StudyLanguage.en: 'Earn 40 stage stars',
      StudyLanguage.ja: 'ステージスター40個獲得',
    }),
    'combo_10' => pick({
      StudyLanguage.ko: '10연속 정답 달성',
      StudyLanguage.en: 'Reach a 10-answer streak',
      StudyLanguage.ja: '10連続正解',
    }),
    'collector_50' => pick({
      StudyLanguage.ko: '단어 50개 수집',
      StudyLanguage.en: 'Master 50 words',
      StudyLanguage.ja: '単語50個を収集',
    }),
    'marathon_40' => pick({
      StudyLanguage.ko: '마라톤 40점 이상',
      StudyLanguage.en: 'Score 40+ in Marathon',
      StudyLanguage.ja: 'マラソン40点以上',
    }),
    _ => fallback,
  };

  String nextLevel(int remaining) => pick({
    StudyLanguage.ko: '다음 레벨까지 $remaining',
    StudyLanguage.en: 'Next level +$remaining',
    StudyLanguage.ja: '次のレベルまで $remaining',
  });
  String nextRank(String name, int remaining) => pick({
    StudyLanguage.ko: '다음 랭크 $name까지 $remaining',
    StudyLanguage.en: 'Next rank $name +$remaining',
    StudyLanguage.ja: '次のランク $name まで $remaining',
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
    StudyLanguage.ja: '前のステージを半分以上クリア',
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
  String get stageRewards => pick({
    StudyLanguage.ko: '스테이지 보상',
    StudyLanguage.en: 'Stage rewards',
    StudyLanguage.ja: 'ステージ報酬',
  });
  String stageRange(int start, int end) => pick({
    StudyLanguage.ko: '스테이지 $start-$end',
    StudyLanguage.en: 'Stage $start-$end',
    StudyLanguage.ja: 'ステージ $start-$end',
  });
  String stageGroupProgress(int current, int count, int total) => pick({
    StudyLanguage.ko: '$current/$count 그룹 · 총 $total개 스테이지',
    StudyLanguage.en: '$current/$count group · $total stages',
    StudyLanguage.ja: '$current/$count グループ · 全$totalステージ',
  });
  String stageStarCount(int stars) => pick({
    StudyLanguage.ko: '별 $stars개',
    StudyLanguage.en: '$stars stars',
    StudyLanguage.ja: 'スター$stars個',
  });
  String get words => pick({
    StudyLanguage.ko: '단어',
    StudyLanguage.en: 'Words',
    StudyLanguage.ja: '単語',
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
    StudyLanguage.ko: '아이템 획득',
    StudyLanguage.en: 'Item gained',
    StudyLanguage.ja: 'アイテム獲得',
  });
  String itemGainedWithLabel(String label) => pick({
    StudyLanguage.ko: '아이템 획득: $label',
    StudyLanguage.en: 'Item gained: $label',
    StudyLanguage.ja: 'アイテム獲得: $label',
  });
  String get hintNoneLeft => pick({
    StudyLanguage.ko: '보유한 힌트가 없어요',
    StudyLanguage.en: 'No hints left',
    StudyLanguage.ja: 'ヒントがありません',
  });
  String get hintAfterReveal => pick({
    StudyLanguage.ko: '정답 공개 후에는 힌트를 쓸 수 없어요',
    StudyLanguage.en: 'Hints can\'t be used after the answer is revealed',
    StudyLanguage.ja: '正解表示後はヒントを使えません',
  });
  String get hintAlreadyUsed => pick({
    StudyLanguage.ko: '이 문제에는 이미 사용했어요',
    StudyLanguage.en: 'Already used on this question',
    StudyLanguage.ja: 'この問題ではすでに使用済みです',
  });
  String get hintTimerFull => pick({
    StudyLanguage.ko: '타이머가 이미 가득 차 있어요',
    StudyLanguage.en: 'The timer is already full',
    StudyLanguage.ja: 'タイマーはすでに満タンです',
  });
  String get result => pick({
    StudyLanguage.ko: '결과',
    StudyLanguage.en: 'Result',
    StudyLanguage.ja: '結果',
  });

  String resultTitle(double rate) {
    if (rate >= 0.9) {
      return pick({
        StudyLanguage.ko: '완벽에 가까워요',
        StudyLanguage.en: 'Almost perfect',
        StudyLanguage.ja: 'ほぼ完璧です',
      });
    }
    if (rate >= 0.7) {
      return pick({
        StudyLanguage.ko: '좋은 흐름이에요',
        StudyLanguage.en: 'Good run',
        StudyLanguage.ja: '良い流れです',
      });
    }
    return pick({
      StudyLanguage.ko: '다시 익혀볼까요',
      StudyLanguage.en: 'Keep practicing',
      StudyLanguage.ja: 'もう一度練習しましょう',
    });
  }

  String get bestStreak => pick({
    StudyLanguage.ko: '최고 콤보',
    StudyLanguage.en: 'Best streak',
    StudyLanguage.ja: '最高コンボ',
  });
  String get runPoints => pick({
    StudyLanguage.ko: '이번 점수',
    StudyLanguage.en: 'Run points',
    StudyLanguage.ja: '今回の点数',
  });
  String get totalPoints => pick({
    StudyLanguage.ko: '총 점수',
    StudyLanguage.en: 'Total points',
    StudyLanguage.ja: '合計点',
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
    StudyLanguage.ko: '아이템 $count개 획득',
    StudyLanguage.en: '$count items gained',
    StudyLanguage.ja: 'アイテム$count個獲得',
  });
  String get levelUp => pick({
    StudyLanguage.ko: '레벨 업',
    StudyLanguage.en: 'Level up',
    StudyLanguage.ja: 'レベルアップ',
  });
  String get rankUp => pick({
    StudyLanguage.ko: '랭크 업',
    StudyLanguage.en: 'Rank up',
    StudyLanguage.ja: 'ランクアップ',
  });
  String get roundFailed => pick({
    StudyLanguage.ko: '라운드 실패',
    StudyLanguage.en: 'Round failed',
    StudyLanguage.ja: 'ラウンド失敗',
  });
  String roundFailedBody(int minCorrect, int correct, int total) => pick({
    StudyLanguage.ko:
        '$total문제 중 $correct개 정답입니다. 클리어에는 $minCorrect개 이상이 필요해요.',
    StudyLanguage.en:
        '$correct/$total correct. You need at least $minCorrect to clear.',
    StudyLanguage.ja: '$total問中$correct問正解。クリアには$minCorrect問以上必要です。',
  });
  String get cleared => pick({
    StudyLanguage.ko: '클리어',
    StudyLanguage.en: 'Cleared',
    StudyLanguage.ja: 'クリア',
  });
  String get bestUpdated => pick({
    StudyLanguage.ko: '기록 갱신',
    StudyLanguage.en: 'Best updated',
    StudyLanguage.ja: '記録更新',
  });
  String thisRunStars(int stars) => pick({
    StudyLanguage.ko: '이번 별 $stars개',
    StudyLanguage.en: 'This run: $stars stars',
    StudyLanguage.ja: '今回のスター $stars個',
  });
  String bestStars(int stars) => pick({
    StudyLanguage.ko: '최고 별 $stars개',
    StudyLanguage.en: 'Best: $stars stars',
    StudyLanguage.ja: '最高スター $stars個',
  });
  String get marathonBestUpdated => pick({
    StudyLanguage.ko: '마라톤 기록 갱신',
    StudyLanguage.en: 'Marathon best updated',
    StudyLanguage.ja: 'マラソン記録更新',
  });
  String get marathonRecord => pick({
    StudyLanguage.ko: '마라톤 기록',
    StudyLanguage.en: 'Marathon record',
    StudyLanguage.ja: 'マラソン記録',
  });
  String bestScore(int score, int total) => pick({
    StudyLanguage.ko: '최고 $score/$total',
    StudyLanguage.en: 'Best $score/$total',
    StudyLanguage.ja: '最高 $score/$total',
  });
  String previousBest(int score, int total) => pick({
    StudyLanguage.ko: '이전 최고 $score/$total',
    StudyLanguage.en: 'Previous best $score/$total',
    StudyLanguage.ja: '以前の最高 $score/$total',
  });
  String get vocabularyTier => pick({
    StudyLanguage.ko: '어휘 티어',
    StudyLanguage.en: 'Vocabulary tier',
    StudyLanguage.ja: '語彙ティア',
  });

  String tierLabel(String raw) => pick({
    StudyLanguage.ko: raw,
    StudyLanguage.en: raw,
    StudyLanguage.ja: raw,
  });

  String tierSubtitle(String raw) => pick({
    StudyLanguage.ko: raw,
    StudyLanguage.en: raw,
    StudyLanguage.ja: raw,
  });

  String masteredTopTier(int count) => pick({
    StudyLanguage.ko: '$count개 수집 · 최고 티어',
    StudyLanguage.en: '$count mastered · top tier reached',
    StudyLanguage.ja: '$count個収集 · 最高ティア',
  });
  String masteredToNext(int count, int remaining, String nextLabel) => pick({
    StudyLanguage.ko: '$count개 수집 · $nextLabel까지 $remaining개',
    StudyLanguage.en: '$count mastered · $remaining to $nextLabel',
    StudyLanguage.ja: '$count個収集 · $nextLabelまで$remaining個',
  });
  String get newLevelReached => pick({
    StudyLanguage.ko: '새 레벨에 도달했어요',
    StudyLanguage.en: 'New level reached!',
    StudyLanguage.ja: '新しいレベルに到達しました',
  });
  String get continueLabel => pick({
    StudyLanguage.ko: '계속',
    StudyLanguage.en: 'Continue',
    StudyLanguage.ja: '続ける',
  });
  String get adLoadFailed => pick({
    StudyLanguage.ko: '광고를 불러올 수 없어요. 잠시 후 다시 시도해 주세요.',
    StudyLanguage.en: 'Could not load the ad. Please try again later.',
    StudyLanguage.ja: '広告を読み込めませんでした。後でもう一度お試しください。',
  });
  String get loadingAd => pick({
    StudyLanguage.ko: '광고 불러오는 중...',
    StudyLanguage.en: 'Loading ad...',
    StudyLanguage.ja: '広告を読み込み中...',
  });
  String get watchVideoForItem => pick({
    StudyLanguage.ko: '영상 보고 아이템 +1',
    StudyLanguage.en: 'Watch video for item +1',
    StudyLanguage.ja: '動画を見てアイテム +1',
  });
  String questionCounter(int current, int total) => pick({
    StudyLanguage.ko: '문제 $current / $total',
    StudyLanguage.en: 'Question $current / $total',
    StudyLanguage.ja: '問題 $current / $total',
  });
  String get exitQuizTitle => pick({
    StudyLanguage.ko: '퀴즈를 종료할까요?',
    StudyLanguage.en: 'Exit the quiz?',
    StudyLanguage.ja: 'クイズを終了しますか？',
  });
  String get exitQuizBody => pick({
    StudyLanguage.ko: '현재 퀴즈 진행 내용은 저장되지 않아요.',
    StudyLanguage.en: 'Your progress in this quiz will not be saved.',
    StudyLanguage.ja: 'このクイズの進行状況は保存されません。',
  });
  String get keepPlaying => pick({
    StudyLanguage.ko: '계속 풀기',
    StudyLanguage.en: 'Keep playing',
    StudyLanguage.ja: '続ける',
  });
  String get exitQuiz => pick({
    StudyLanguage.ko: '퀴즈 종료',
    StudyLanguage.en: 'Exit quiz',
    StudyLanguage.ja: 'クイズを終了',
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
  String hintCount(int used, int total) => pick({
    StudyLanguage.ko: '힌트 $used/$total',
    StudyLanguage.en: 'Hint $used/$total',
    StudyLanguage.ja: 'ヒント $used/$total',
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
    StudyLanguage.ko: '이 스페인어 단어의 뜻은?',
    StudyLanguage.en: 'What does this Spanish word mean?',
    StudyLanguage.ja: 'このスペイン語の意味は？',
  });
  String get meaningToWord => pick({
    StudyLanguage.ko: '이 뜻에 맞는 스페인어는?',
    StudyLanguage.en: 'Which Spanish word matches this meaning?',
    StudyLanguage.ja: 'この意味に合うスペイン語は？',
  });
  String get blankQuestion => pick({
    StudyLanguage.ko: '예문 빈칸에 들어갈 단어는?',
    StudyLanguage.en: 'Which word fills the blank?',
    StudyLanguage.ja: '例文の空欄に入る単語は？',
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
          StudyLanguage.ja: '空欄',
        });
    }
    return modeName;
  }

  String levelLabel(String level) => 'DELE $level';
}
