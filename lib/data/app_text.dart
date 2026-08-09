import '../models/idiom.dart';

class AppText {
  final StudyLanguage language;
  const AppText(this.language);

  // English before Korean: a language missing a string should degrade to
  // something its speakers can read, not to Korean.
  String pick(Map<StudyLanguage, String> values) =>
      values[language] ??
      values[StudyLanguage.en] ??
      values[StudyLanguage.ko] ??
      '';

  String get appName => 'DELE Voca Dojo';
  String get rateApp => pick({
    StudyLanguage.ko: '앱 평가하기',
    StudyLanguage.en: 'Rate this app',
    StudyLanguage.ja: 'アプリを評価する',
    StudyLanguage.pt: 'Avaliar o app',
  });
  String get rateAppUnavailable => pick({
    StudyLanguage.ko: '스토어를 열 수 없습니다.',
    StudyLanguage.en: 'Could not open the store.',
    StudyLanguage.ja: 'ストアを開けませんでした。',
    StudyLanguage.pt: 'Não foi possível abrir a loja.',
  });
  String get cognateTitle => pick({
    StudyLanguage.ko: '이미 아는 단어가 섞여 있어요',
    StudyLanguage.en: 'Some words you may already know',
    StudyLanguage.ja: 'すでに知っている単語が含まれています',
    StudyLanguage.pt: 'Algumas palavras você já sabe',
  });
  String cognateBody(int count) => pick({
    StudyLanguage.ko:
        '스페인어 단어 $count개는 한국어 뜻과 철자가 같아 따로 외울 필요가 거의 없어요.\n\n'
        '퀴즈에서 빼면 모르는 단어에 집중할 수 있어요. 나중에 다시 켤 수 있습니다.',
    StudyLanguage.en:
        '$count of these Spanish words are spelled the same in your language, '
        'so there is little to memorise.\n\n'
        'Hiding them lets you focus on the words you do not know yet.',
    StudyLanguage.ja:
        'スペイン語の単語のうち $count 語は表記が同じで、覚える必要がほとんどありません。\n\n'
        '非表示にすると、まだ知らない単語に集中できます。',
    StudyLanguage.pt:
        '$count destas palavras em espanhol se escrevem igual em português, '
        'então há pouco a decorar.\n\n'
        'Escondê-las deixa você focar nas palavras que ainda não conhece.',
  });
  String get cognateExamplesLabel => pick({
    StudyLanguage.ko: '예를 들면',
    StudyLanguage.en: 'For example',
    StudyLanguage.ja: 'たとえば',
    StudyLanguage.pt: 'Por exemplo',
  });
  String get cognateSkip => pick({
    StudyLanguage.ko: '이미 알아요, 빼주세요',
    StudyLanguage.en: 'I know these, hide them',
    StudyLanguage.ja: '知っているので非表示に',
    StudyLanguage.pt: 'Já sei estas, esconder',
  });
  String get cognateKeep => pick({
    StudyLanguage.ko: '그대로 볼래요',
    StudyLanguage.en: 'Keep showing them',
    StudyLanguage.ja: 'そのまま表示する',
    StudyLanguage.pt: 'Continuar mostrando',
  });
  String get cognateHiddenNotice => pick({
    StudyLanguage.ko: '이미 아는 단어를 퀴즈에서 뺐어요',
    StudyLanguage.en: 'Words you already know are hidden from quizzes',
    StudyLanguage.ja: 'すでに知っている単語をクイズから除外しました',
    StudyLanguage.pt:
        'As palavras que você já sabe foram escondidas dos quizzes',
  });
  String get ttsMissingVoice => pick({
    StudyLanguage.ko: '기기에 스페인어 음성이 설치되어 있지 않아 발음을 재생할 수 없습니다.',
    StudyLanguage.en:
        'No Spanish voice is installed on this device, so '
        'pronunciation cannot play.',
    StudyLanguage.ja: '端末にスペイン語の音声がインストールされていないため、発音を再生できません。',
    StudyLanguage.pt:
        'Nenhuma voz em espanhol está instalada neste dispositivo, então a pronúncia não pode ser reproduzida.',
  });
  String get ttsInstallVoice => pick({
    StudyLanguage.ko: '설치',
    StudyLanguage.en: 'Install',
    StudyLanguage.ja: 'インストール',
    StudyLanguage.pt: 'Instalar',
  });
  String get ttsDownloadVoice => pick({
    StudyLanguage.ko: '스페인어 음성 다운로드',
    StudyLanguage.en: 'Download Spanish voice',
    StudyLanguage.ja: 'スペイン語音声をダウンロード',
    StudyLanguage.pt: 'Baixar voz em espanhol',
  });
  String get ttsStudyVoiceMissing => pick({
    StudyLanguage.ko: '한국어 음성이 설치되어 있지 않아 뜻 발음을 재생할 수 없어요.',
    StudyLanguage.en:
        'No English voice is installed, so the meaning cannot be spoken.',
    StudyLanguage.ja: '日本語音声がインストールされていないため、意味を再生できません。',
    StudyLanguage.pt:
        'Nenhuma voz em português está instalada, então o significado não pode ser reproduzido.',
  });
  String get ttsDownloadStudyVoice => pick({
    StudyLanguage.ko: '한국어 음성 다운로드',
    StudyLanguage.en: 'Download English voice',
    StudyLanguage.ja: '日本語音声をダウンロード',
    StudyLanguage.pt: 'Baixar voz em português',
  });
  String get ttsStudyInstallSteps => pick({
    StudyLanguage.ko:
        '쉐도잉에서 한국어 뜻도 들으려면 한국어 음성 데이터가 필요합니다.\n\n'
        '다음 화면에서 Google 음성 서비스를 선택하고 언어 설치에서 "한국어(대한민국)"를 다운로드해 주세요.',
    StudyLanguage.en:
        'Shadowing needs English voice data to speak the meaning.\n\n'
        'On the next screen, choose Google Speech Services and download "English (United States)" under Install voice data.',
    StudyLanguage.ja:
        'シャドーイングで日本語の意味を聞くには日本語音声データが必要です。\n\n'
        '次の画面で Google 音声サービスを選び、音声データのインストールから「日本語(日本)」をダウンロードしてください。',
    StudyLanguage.pt:
        'O shadowing precisa dos dados de voz em português para falar o significado.\n\n'
        'Na próxima tela, escolha o Google Speech Services e baixe "Português (Brasil)" em Instalar dados de voz.',
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
    StudyLanguage.pt:
        'A pronúncia precisa dos dados de voz em espanhol.\n\nNa próxima tela:\n1. Escolha "Google Speech Services" como mecanismo\n2. Abra Instalar dados de voz\n3. Baixe "Espanhol (Espanha)"\n\nOutros mecanismos, como o Samsung TTS, podem não oferecer espanhol, então escolha o Google Speech Services.',
  });
  String get ttsOpenInstaller => pick({
    StudyLanguage.ko: '설치 화면 열기',
    StudyLanguage.en: 'Open installer',
    StudyLanguage.ja: 'インストール画面を開く',
    StudyLanguage.pt: 'Abrir instalador',
  });
  String get cancel => pick({
    StudyLanguage.ko: '취소',
    StudyLanguage.en: 'Cancel',
    StudyLanguage.ja: 'キャンセル',
    StudyLanguage.pt: 'Cancelar',
  });
  String get ttsSettingsUnavailable => pick({
    StudyLanguage.ko: '이 기기에서는 음성 설정 화면을 열 수 없습니다.',
    StudyLanguage.en: 'Voice settings cannot be opened on this device.',
    StudyLanguage.ja: 'この端末では音声設定を開けません。',
    StudyLanguage.pt:
        'Não é possível abrir as configurações de voz neste dispositivo.',
  });
  String get chooseLanguageTitle => pick({
    StudyLanguage.ko: '학습 언어를 선택해 주세요',
    StudyLanguage.en: 'Choose your study language',
    StudyLanguage.ja: '学習言語を選択してください',
    StudyLanguage.pt: 'Escolha seu idioma de estudo',
  });
  String get chooseLanguageBody => pick({
    StudyLanguage.ko: '메뉴와 문제 해석에 사용할 언어입니다.',
    StudyLanguage.en: 'This controls menus and answer translations.',
    StudyLanguage.ja: 'メニューと解説に使う言語です。',
    StudyLanguage.pt: 'Isso controla os menus e as traduções das respostas.',
  });
  String get start => pick({
    StudyLanguage.ko: '시작',
    StudyLanguage.en: 'Start',
    StudyLanguage.ja: '開始',
    StudyLanguage.pt: 'Começar',
  });
  String get stage => pick({
    StudyLanguage.ko: '스테이지',
    StudyLanguage.en: 'Stages',
    StudyLanguage.ja: 'ステージ',
    StudyLanguage.pt: 'Fases',
  });
  String get stageSubtitle => pick({
    StudyLanguage.ko: '단어, 뜻, 예문 빈칸으로 DELE 어휘를 익혀요.',
    StudyLanguage.en: 'Build DELE vocabulary with words, meanings, and blanks.',
    StudyLanguage.ja: '単語・意味・例文穴埋めでDELE語彙を学びます。',
    StudyLanguage.pt:
        'Construa seu vocabulário DELE com palavras, significados e lacunas.',
  });
  String get marathon => pick({
    StudyLanguage.ko: '마라톤',
    StudyLanguage.en: 'Marathon',
    StudyLanguage.ja: 'マラソン',
    StudyLanguage.pt: 'Maratona',
  });
  String get marathonSubtitle => pick({
    StudyLanguage.ko: '50문제를 이어 풀고 기록과 단어장을 채워요.',
    StudyLanguage.en:
        'Answer 50 questions to set records and fill the wordbook.',
    StudyLanguage.ja: '50問に挑戦して記録と単語帳を増やします。',
    StudyLanguage.pt:
        'Responda 50 questões para bater recordes e preencher o Vocabulário.',
  });
  String get fiftyQuestionQuiz => pick({
    StudyLanguage.ko: '50문제 퀴즈',
    StudyLanguage.en: '50Q Quiz',
    StudyLanguage.ja: '50問クイズ',
    StudyLanguage.pt: 'Quiz de 50 questões',
  });
  String get marathonFocusedSubtitle => pick({
    StudyLanguage.ko: '50문제로 스페인어 어휘를 집중 연습해요.',
    StudyLanguage.en: '50 questions for focused vocabulary practice.',
    StudyLanguage.ja: '50問でスペイン語語彙を集中練習します。',
    StudyLanguage.pt: '50 questões para praticar vocabulário com foco.',
  });
  String get randomChallengeMode => pick({
    StudyLanguage.ko: '랜덤 챌린지 모드',
    StudyLanguage.en: 'Random Challenge Mode',
    StudyLanguage.ja: 'ランダムチャレンジモード',
    StudyLanguage.pt: 'Modo desafio aleatório',
  });
  String get randomChallengeSubtitle => pick({
    StudyLanguage.ko: '무작위 50문제로 스페인어 어휘를 집중 점검해요.',
    StudyLanguage.en: 'Check your Spanish vocabulary with 50 random questions.',
    StudyLanguage.ja: 'ランダム50問でスペイン語語彙を確認します。',
    StudyLanguage.pt:
        'Teste seu vocabulário de espanhol com 50 questões aleatórias.',
  });
  String get wrongNote => pick({
    StudyLanguage.ko: '오답 노트',
    StudyLanguage.en: 'Wrong Notes',
    StudyLanguage.ja: '間違いノート',
    StudyLanguage.pt: 'Caderno de erros',
  });
  String get wrongNoteSubtitle => pick({
    StudyLanguage.ko: '틀린 단어만 다시 풀고 맞히면 오답 노트에서 정리돼요.',
    StudyLanguage.en: 'Review missed words. Correct answers clear them.',
    StudyLanguage.ja: '間違えた単語を復習します。正解すると整理されます。',
    StudyLanguage.pt:
        'Revise as palavras que você errou. Os acertos as removem.',
  });
  String wrongNoteCount(int count) => pick({
    StudyLanguage.ko: '복습할 오답 $count개',
    StudyLanguage.en: '$count ${count == 1 ? "word" : "words"} to review',
    StudyLanguage.ja: '復習する単語 $count個',
    StudyLanguage.pt:
        '$count ${count == 1 ? "palavra" : "palavras"} para revisar',
  });
  String get startReview => pick({
    StudyLanguage.ko: '오답 다시 풀기',
    StudyLanguage.en: 'Review wrong notes',
    StudyLanguage.ja: '復習を始める',
    StudyLanguage.pt: 'Revisar caderno de erros',
  });
  String wrongNoteReviewLocked(int min) => pick({
    StudyLanguage.ko: '오답이 $min개 이상 모이면 복습할 수 있어요',
    StudyLanguage.en: 'Collect $min wrong notes to unlock review',
    StudyLanguage.ja: '間違いが$min個以上たまると復習できます',
    StudyLanguage.pt: 'Junte $min erros para liberar a revisão',
  });
  String get noWrongNotes => pick({
    StudyLanguage.ko: '아직 오답이 없어요',
    StudyLanguage.en: 'No wrong notes yet',
    StudyLanguage.ja: 'まだ間違いはありません',
    StudyLanguage.pt: 'Nenhum erro ainda',
  });
  String get noWrongNotesBody => pick({
    StudyLanguage.ko: '퀴즈에서 틀린 단어가 생기면 여기에 자동으로 모입니다.',
    StudyLanguage.en: 'Words you miss in quizzes will appear here.',
    StudyLanguage.ja: 'クイズで間違えた単語がここに表示されます。',
    StudyLanguage.pt:
        'As palavras que você errar nos quizzes vão aparecer aqui.',
  });
  String get wordbook => pick({
    StudyLanguage.ko: '단어장',
    StudyLanguage.en: 'Wordbook',
    StudyLanguage.ja: '単語帳',
    StudyLanguage.pt: 'Vocabulário',
  });
  String wordbookTitle(int unlocked, int total) => '$wordbook $unlocked/$total';
  String unlockHint(int threshold) => pick({
    StudyLanguage.ko: '정답을 $threshold번 이상 맞히면 단어가 수집돼요.',
    StudyLanguage.en: 'Collect: answer correctly $threshold time or more',
    StudyLanguage.ja: '$threshold回以上正解すると単語を収集できます。',
    StudyLanguage.pt: 'Coletar: acerte $threshold vez ou mais',
  });
  String lockedProgress(int count, int threshold) => pick({
    StudyLanguage.ko: '미수집 ($count / $threshold)',
    StudyLanguage.en: 'Uncollected ($count / $threshold)',
    StudyLanguage.ja: '未収集 ($count / $threshold)',
    StudyLanguage.pt: 'Não coletada ($count / $threshold)',
  });
  String lockedUnlockBody(int threshold) => pick({
    StudyLanguage.ko: '$threshold번 이상 정답을 맞히면 이 단어가 수집돼요.',
    StudyLanguage.en:
        'Answer correctly $threshold time or more to collect this word.',
    StudyLanguage.ja: '$threshold回以上正解するとこの単語を収集できます。',
    StudyLanguage.pt:
        'Acerte $threshold vez ou mais para coletar esta palavra.',
  });
  String get searchWordbookHint => pick({
    StudyLanguage.ko: '스페인어, 뜻, 레벨 검색',
    StudyLanguage.en: 'Search Spanish, meaning, or level',
    StudyLanguage.ja: 'スペイン語・意味・レベルを検索',
    StudyLanguage.pt: 'Buscar espanhol, significado ou nível',
  });
  String get filterAll => pick({
    StudyLanguage.ko: '전체',
    StudyLanguage.en: 'All',
    StudyLanguage.ja: 'すべて',
    StudyLanguage.pt: 'Todas',
  });
  String get unlocked => pick({
    StudyLanguage.ko: '수집완료',
    StudyLanguage.en: 'Collected',
    StudyLanguage.ja: '収集済み',
    StudyLanguage.pt: 'Coletada',
  });
  String get locked => pick({
    StudyLanguage.ko: '미수집',
    StudyLanguage.en: 'Uncollected',
    StudyLanguage.ja: '未収集',
    StudyLanguage.pt: 'Não coletada',
  });
  String get noWordsFound => pick({
    StudyLanguage.ko: '단어가 없어요',
    StudyLanguage.en: 'No words found',
    StudyLanguage.ja: '単語が見つかりません',
    StudyLanguage.pt: 'Nenhuma palavra encontrada',
  });
  String noWordsMatch(String query) => pick({
    StudyLanguage.ko: '"$query"에 맞는 단어가 없어요',
    StudyLanguage.en: 'No words match "$query"',
    StudyLanguage.ja: '"$query"に一致する単語がありません',
    StudyLanguage.pt: 'Nenhuma palavra corresponde a "$query"',
  });
  String get backToTop => pick({
    StudyLanguage.ko: '맨 위로',
    StudyLanguage.en: 'Back to top',
    StudyLanguage.ja: '上へ',
    StudyLanguage.pt: 'Voltar ao topo',
  });
  String get clear => pick({
    StudyLanguage.ko: '지우기',
    StudyLanguage.en: 'Clear',
    StudyLanguage.ja: 'クリア',
    StudyLanguage.pt: 'Limpar',
  });
  String get languageMenu => pick({
    StudyLanguage.ko: '언어',
    StudyLanguage.en: 'Language',
    StudyLanguage.ja: '言語',
    StudyLanguage.pt: 'Idioma',
  });
  String get mute => pick({
    StudyLanguage.ko: '음소거',
    StudyLanguage.en: 'Mute',
    StudyLanguage.ja: 'ミュート',
    StudyLanguage.pt: 'Silenciar',
  });
  String get unmute => pick({
    StudyLanguage.ko: '음소거 해제',
    StudyLanguage.en: 'Unmute',
    StudyLanguage.ja: 'ミュート解除',
    StudyLanguage.pt: 'Ativar som',
  });
  String get appInfo => pick({
    StudyLanguage.ko: '앱 정보',
    StudyLanguage.en: 'App info',
    StudyLanguage.ja: 'アプリ情報',
    StudyLanguage.pt: 'Sobre o app',
  });
  String get versionLabel => pick({
    StudyLanguage.ko: '버전',
    StudyLanguage.en: 'Version',
    StudyLanguage.ja: 'バージョン',
    StudyLanguage.pt: 'Versão',
  });
  String get dataStorage => pick({
    StudyLanguage.ko: '데이터 저장',
    StudyLanguage.en: 'Data storage',
    StudyLanguage.ja: 'データ保存',
    StudyLanguage.pt: 'Armazenamento de dados',
  });
  String get dataStorageBody => pick({
    StudyLanguage.ko: '퀴즈 진행 상황, 수집 단어, 아이템, 언어 설정은 이 기기에만 저장됩니다.',
    StudyLanguage.en:
        'Quiz progress, mastered words, items, and language settings are stored only on this device.',
    StudyLanguage.ja: '学習データと言語設定はこの端末にのみ保存されます。',
    StudyLanguage.pt:
        'O progresso dos quizzes, as palavras dominadas, os itens e as configurações de idioma são salvos apenas neste dispositivo.',
  });
  String get feedback => pick({
    StudyLanguage.ko: '피드백 보내기',
    StudyLanguage.en: 'Send feedback',
    StudyLanguage.ja: 'フィードバック',
    StudyLanguage.pt: 'Enviar feedback',
  });
  String get feedbackOpenFailed => pick({
    StudyLanguage.ko: '피드백 양식을 열 수 없어요.',
    StudyLanguage.en: 'Could not open the feedback form.',
    StudyLanguage.ja: 'フォームを開けませんでした。',
    StudyLanguage.pt: 'Não foi possível abrir o formulário de feedback.',
  });
  String get licenses => pick({
    StudyLanguage.ko: '라이선스',
    StudyLanguage.en: 'Licenses',
    StudyLanguage.ja: 'ライセンス',
    StudyLanguage.pt: 'Licenças',
  });
  String get openSourceLicenses => pick({
    StudyLanguage.ko: '오픈소스 라이선스',
    StudyLanguage.en: 'Open source licenses',
    StudyLanguage.ja: 'オープンソースライセンス',
    StudyLanguage.pt: 'Licenças de código aberto',
  });
  String get close => pick({
    StudyLanguage.ko: '닫기',
    StudyLanguage.en: 'Close',
    StudyLanguage.ja: '閉じる',
    StudyLanguage.pt: 'Fechar',
  });
  String get playPronunciation => pick({
    StudyLanguage.ko: '발음 재생',
    StudyLanguage.en: 'Play pronunciation',
    StudyLanguage.ja: '発音を再生',
    StudyLanguage.pt: 'Reproduzir pronúncia',
  });
  String get partOfSpeech => pick({
    StudyLanguage.ko: '품사',
    StudyLanguage.en: 'Part of speech',
    StudyLanguage.ja: '品詞',
    StudyLanguage.pt: 'Classe gramatical',
  });

  String partOfSpeechName(String value) {
    final normalized = value.toLowerCase();
    final names = <String, Map<StudyLanguage, String>>{
      'noun': {
        StudyLanguage.ko: '명사',
        StudyLanguage.en: 'Noun',
        StudyLanguage.ja: '名詞',
        StudyLanguage.pt: 'Substantivo',
      },
      'verb': {
        StudyLanguage.ko: '동사',
        StudyLanguage.en: 'Verb',
        StudyLanguage.ja: '動詞',
        StudyLanguage.pt: 'Verbo',
      },
      'adjective': {
        StudyLanguage.ko: '형용사',
        StudyLanguage.en: 'Adjective',
        StudyLanguage.ja: '形容詞',
        StudyLanguage.pt: 'Adjetivo',
      },
      'adverb': {
        StudyLanguage.ko: '부사',
        StudyLanguage.en: 'Adverb',
        StudyLanguage.ja: '副詞',
        StudyLanguage.pt: 'Advérbio',
      },
      'phrase': {
        StudyLanguage.ko: '표현',
        StudyLanguage.en: 'Phrase',
        StudyLanguage.ja: '表現',
        StudyLanguage.pt: 'Expressão',
      },
      'connector': {
        StudyLanguage.ko: '연결어',
        StudyLanguage.en: 'Connector',
        StudyLanguage.ja: '接続語',
        StudyLanguage.pt: 'Conectivo',
      },
    };
    return pick(names[normalized] ?? {StudyLanguage.ko: value});
  }

  String get example => pick({
    StudyLanguage.ko: '예문',
    StudyLanguage.en: 'Example',
    StudyLanguage.ja: '例文',
    StudyLanguage.pt: 'Exemplo',
  });
  String get correctCount => pick({
    StudyLanguage.ko: '정답 수',
    StudyLanguage.en: 'Correct',
    StudyLanguage.ja: '正解数',
    StudyLanguage.pt: 'Acertos',
  });
  String get recentMarathon => pick({
    StudyLanguage.ko: '최근 마라톤',
    StudyLanguage.en: 'Recent Marathon',
    StudyLanguage.ja: '最近のマラソン',
    StudyLanguage.pt: 'Maratona recente',
  });
  String get todaysWord => pick({
    StudyLanguage.ko: '오늘의 단어',
    StudyLanguage.en: 'Word of the Day',
    StudyLanguage.ja: '今日の単語',
    StudyLanguage.pt: 'Palavra do dia',
  });
  String get practiceModes => pick({
    StudyLanguage.ko: '연습 모드',
    StudyLanguage.en: 'Practice modes',
    StudyLanguage.ja: '練習モード',
    StudyLanguage.pt: 'Modos de prática',
  });
  String get recommended => pick({
    StudyLanguage.ko: '추천',
    StudyLanguage.en: 'Recommended',
    StudyLanguage.ja: 'おすすめ',
    StudyLanguage.pt: 'Recomendado',
  });
  String get deleVocabularyTraining => pick({
    StudyLanguage.ko: 'DELE 어휘 트레이닝',
    StudyLanguage.en: 'DELE vocabulary training',
    StudyLanguage.ja: 'DELE語彙トレーニング',
    StudyLanguage.pt: 'Treino de vocabulário DELE',
  });
  String get oneWordADay => pick({
    StudyLanguage.ko: '하루 한 단어',
    StudyLanguage.en: 'One word a day',
    StudyLanguage.ja: '1日1単語',
    StudyLanguage.pt: 'Uma palavra por dia',
  });
  String get rank => pick({
    StudyLanguage.ko: '랭크',
    StudyLanguage.en: 'Rank',
    StudyLanguage.ja: 'ランク',
    StudyLanguage.pt: 'Patente',
  });
  String get level => pick({
    StudyLanguage.ko: '레벨',
    StudyLanguage.en: 'Level',
    StudyLanguage.ja: 'レベル',
    StudyLanguage.pt: 'Nível',
  });
  String get studyStreak => pick({
    StudyLanguage.ko: '연속 학습',
    StudyLanguage.en: 'Study streak',
    StudyLanguage.ja: '連続学習',
    StudyLanguage.pt: 'Sequência de estudo',
  });
  String studyStreakDays(int days) => pick({
    StudyLanguage.ko: '$days일',
    StudyLanguage.en: '$days ${days == 1 ? "day" : "days"}',
    StudyLanguage.ja: '$days日',
    StudyLanguage.pt: '$days ${days == 1 ? "dia" : "dias"}',
  });
  String get stageStars => pick({
    StudyLanguage.ko: '스테이지 별',
    StudyLanguage.en: 'Stage stars',
    StudyLanguage.ja: 'ステージスター',
    StudyLanguage.pt: 'Estrelas de fase',
  });
  String get title => pick({
    StudyLanguage.ko: '칭호',
    StudyLanguage.en: 'Title',
    StudyLanguage.ja: '称号',
    StudyLanguage.pt: 'Título',
  });
  String get titles => pick({
    StudyLanguage.ko: '칭호',
    StudyLanguage.en: 'Titles',
    StudyLanguage.ja: '称号',
    StudyLanguage.pt: 'Títulos',
  });

  String rankLabel(String raw) {
    final labels = <String, Map<StudyLanguage, String>>{
      'Novato': {
        StudyLanguage.ko: '입문자',
        StudyLanguage.en: 'Beginner',
        StudyLanguage.ja: '入門者',
        StudyLanguage.pt: 'Iniciante',
      },
      'Aprendiz': {
        StudyLanguage.ko: '견습 학습자',
        StudyLanguage.en: 'Apprentice Learner',
        StudyLanguage.ja: '見習い学習者',
        StudyLanguage.pt: 'Aprendiz',
      },
      'Explorador': {
        StudyLanguage.ko: '탐험가',
        StudyLanguage.en: 'Explorer',
        StudyLanguage.ja: '探検家',
        StudyLanguage.pt: 'Explorador',
      },
      'Estudiante': {
        StudyLanguage.ko: '학생',
        StudyLanguage.en: 'Student',
        StudyLanguage.ja: '学生',
        StudyLanguage.pt: 'Estudante',
      },
      'Hablante': {
        StudyLanguage.ko: '말하는 사람',
        StudyLanguage.en: 'Speaker',
        StudyLanguage.ja: '話し手',
        StudyLanguage.pt: 'Falante',
      },
      'Viajero': {
        StudyLanguage.ko: '여행자',
        StudyLanguage.en: 'Traveler',
        StudyLanguage.ja: '旅行者',
        StudyLanguage.pt: 'Viajante',
      },
      'Conversador': {
        StudyLanguage.ko: '대화가',
        StudyLanguage.en: 'Conversationalist',
        StudyLanguage.ja: '会話上手',
        StudyLanguage.pt: 'Conversador',
      },
      'Intérprete': {
        StudyLanguage.ko: '통역가',
        StudyLanguage.en: 'Interpreter',
        StudyLanguage.ja: '通訳者',
        StudyLanguage.pt: 'Intérprete',
      },
      'Int챕rprete': {
        StudyLanguage.ko: '통역가',
        StudyLanguage.en: 'Interpreter',
        StudyLanguage.ja: '通訳者',
        StudyLanguage.pt: 'Intérprete',
      },
      'Lingüista': {
        StudyLanguage.ko: '언어 탐구자',
        StudyLanguage.en: 'Linguist',
        StudyLanguage.ja: '言語探究者',
        StudyLanguage.pt: 'Linguista',
      },
      'Ling체ista': {
        StudyLanguage.ko: '언어 탐구자',
        StudyLanguage.en: 'Linguist',
        StudyLanguage.ja: '言語探究者',
        StudyLanguage.pt: 'Linguista',
      },
      'Embajador': {
        StudyLanguage.ko: '문화 대사',
        StudyLanguage.en: 'Ambassador',
        StudyLanguage.ja: '文化大使',
        StudyLanguage.pt: 'Embaixador',
      },
      'Maestro': {
        StudyLanguage.ko: '숙련자',
        StudyLanguage.en: 'Master',
        StudyLanguage.ja: '熟練者',
        StudyLanguage.pt: 'Mestre',
      },
      'Sabio': {
        StudyLanguage.ko: '현자',
        StudyLanguage.en: 'Sage',
        StudyLanguage.ja: '賢者',
        StudyLanguage.pt: 'Sábio',
      },
      'Gran Maestro': {
        StudyLanguage.ko: '대가',
        StudyLanguage.en: 'Grand Master',
        StudyLanguage.ja: '大師範',
        StudyLanguage.pt: 'Grão-mestre',
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
      StudyLanguage.pt: 'Guardião da Sequência',
    }),
    'streak_7' => pick({
      StudyLanguage.ko: '7일 학습자',
      StudyLanguage.en: 'Seven-Day Scholar',
      StudyLanguage.ja: '7日学習者',
      StudyLanguage.pt: 'Estudante de Sete Dias',
    }),
    'star_20' => pick({
      StudyLanguage.ko: '스테이지 등반가',
      StudyLanguage.en: 'Stage Climber',
      StudyLanguage.ja: 'ステージ登山家',
      StudyLanguage.pt: 'Escalador de Fases',
    }),
    'star_40' => pick({
      StudyLanguage.ko: '스테이지 달인',
      StudyLanguage.en: 'Stage Master',
      StudyLanguage.ja: 'ステージ達人',
      StudyLanguage.pt: 'Mestre das Fases',
    }),
    'combo_10' => pick({
      StudyLanguage.ko: '콤보 메이커',
      StudyLanguage.en: 'Combo Maker',
      StudyLanguage.ja: 'コンボメーカー',
      StudyLanguage.pt: 'Criador de Combos',
    }),
    'collector_50' => pick({
      StudyLanguage.ko: '단어 수집가',
      StudyLanguage.en: 'Collector',
      StudyLanguage.ja: '単語収集家',
      StudyLanguage.pt: 'Colecionador',
    }),
    'marathon_40' => pick({
      StudyLanguage.ko: '마라톤 주자',
      StudyLanguage.en: 'Marathon Runner',
      StudyLanguage.ja: 'マラソン走者',
      StudyLanguage.pt: 'Maratonista',
    }),
    _ => fallback,
  };

  String titleDescription(String id, String fallback) => switch (id) {
    'rank' => pick({
      StudyLanguage.ko: '현재 랭크',
      StudyLanguage.en: 'Current rank',
      StudyLanguage.ja: '現在のランク',
      StudyLanguage.pt: 'Patente atual',
    }),
    'streak_3' => pick({
      StudyLanguage.ko: '3일 연속 학습',
      StudyLanguage.en: 'Study 3 days in a row',
      StudyLanguage.ja: '3日連続学習',
      StudyLanguage.pt: 'Estude 3 dias seguidos',
    }),
    'streak_7' => pick({
      StudyLanguage.ko: '7일 연속 학습',
      StudyLanguage.en: 'Study 7 days in a row',
      StudyLanguage.ja: '7日連続学習',
      StudyLanguage.pt: 'Estude 7 dias seguidos',
    }),
    'star_20' => pick({
      StudyLanguage.ko: '스테이지 별 20개 획득',
      StudyLanguage.en: 'Earn 20 stage stars',
      StudyLanguage.ja: 'ステージスター20個獲得',
      StudyLanguage.pt: 'Ganhe 20 estrelas de fase',
    }),
    'star_40' => pick({
      StudyLanguage.ko: '스테이지 별 40개 획득',
      StudyLanguage.en: 'Earn 40 stage stars',
      StudyLanguage.ja: 'ステージスター40個獲得',
      StudyLanguage.pt: 'Ganhe 40 estrelas de fase',
    }),
    'combo_10' => pick({
      StudyLanguage.ko: '10연속 정답 달성',
      StudyLanguage.en: 'Reach a 10-answer streak',
      StudyLanguage.ja: '10連続正解',
      StudyLanguage.pt: 'Alcance uma sequência de 10 acertos',
    }),
    'collector_50' => pick({
      StudyLanguage.ko: '단어 50개 수집',
      StudyLanguage.en: 'Master 50 words',
      StudyLanguage.ja: '単語50個を収集',
      StudyLanguage.pt: 'Domine 50 palavras',
    }),
    'marathon_40' => pick({
      StudyLanguage.ko: '마라톤 40점 이상',
      StudyLanguage.en: 'Score 40+ in Marathon',
      StudyLanguage.ja: 'マラソン40点以上',
      StudyLanguage.pt: 'Faça 40+ pontos na Maratona',
    }),
    _ => fallback,
  };

  String nextLevel(int remaining) => pick({
    StudyLanguage.ko: '다음 레벨까지 $remaining',
    StudyLanguage.en: 'Next level +$remaining',
    StudyLanguage.ja: '次のレベルまで $remaining',
    StudyLanguage.pt: 'Próximo nível +$remaining',
  });
  String nextRank(String name, int remaining) => pick({
    StudyLanguage.ko: '다음 랭크 $name까지 $remaining',
    StudyLanguage.en: 'Next rank $name +$remaining',
    StudyLanguage.ja: '次のランク $name まで $remaining',
    StudyLanguage.pt: 'Próxima patente $name +$remaining',
  });
  String get maxRank => pick({
    StudyLanguage.ko: '최고 랭크',
    StudyLanguage.en: 'Max rank',
    StudyLanguage.ja: '最高ランク',
    StudyLanguage.pt: 'Patente máxima',
  });
  String get totalStars => pick({
    StudyLanguage.ko: '총 별',
    StudyLanguage.en: 'Total stars',
    StudyLanguage.ja: '合計スター',
    StudyLanguage.pt: 'Total de estrelas',
  });
  String get clearHalfPreviousStage => pick({
    StudyLanguage.ko: '이전 스테이지 별 절반 이상 필요',
    StudyLanguage.en: 'Clear half of previous stage',
    StudyLanguage.ja: '前のステージを半分以上クリア',
    StudyLanguage.pt: 'Complete metade da fase anterior',
  });
  String get clearPreviousRound => pick({
    StudyLanguage.ko: '이전 라운드 클리어 필요',
    StudyLanguage.en: 'Clear previous round',
    StudyLanguage.ja: '前のラウンドをクリア',
    StudyLanguage.pt: 'Complete a rodada anterior',
  });
  String roundLabel(int number) => pick({
    StudyLanguage.ko: '라운드 $number',
    StudyLanguage.en: 'Round $number',
    StudyLanguage.ja: 'ラウンド $number',
    StudyLanguage.pt: 'Rodada $number',
  });
  String get stageMode => pick({
    StudyLanguage.ko: '스테이지 모드',
    StudyLanguage.en: 'Stage Mode',
    StudyLanguage.ja: 'ステージモード',
    StudyLanguage.pt: 'Modo Fases',
  });
  String get stageRewards => pick({
    StudyLanguage.ko: '스테이지 보상',
    StudyLanguage.en: 'Stage rewards',
    StudyLanguage.ja: 'ステージ報酬',
    StudyLanguage.pt: 'Recompensas das fases',
  });
  String stageRange(int start, int end) => pick({
    StudyLanguage.ko: '스테이지 $start-$end',
    StudyLanguage.en: 'Stage $start-$end',
    StudyLanguage.ja: 'ステージ $start-$end',
    StudyLanguage.pt: 'Fase $start-$end',
  });
  String stageGroupProgress(int current, int count, int total) => pick({
    StudyLanguage.ko: '$current/$count 그룹 · 총 $total개 스테이지',
    StudyLanguage.en: '$current/$count group · $total stages',
    StudyLanguage.ja: '$current/$count グループ · 全$totalステージ',
    StudyLanguage.pt: 'Grupo $current/$count · $total fases',
  });
  String stageStarCount(int stars) => pick({
    StudyLanguage.ko: '별 $stars개',
    StudyLanguage.en: '$stars ${stars == 1 ? "star" : "stars"}',
    StudyLanguage.ja: 'スター$stars個',
    StudyLanguage.pt: '$stars ${stars == 1 ? "estrela" : "estrelas"}',
  });
  String get words => pick({
    StudyLanguage.ko: '단어',
    StudyLanguage.en: 'Words',
    StudyLanguage.ja: '単語',
    StudyLanguage.pt: 'Palavras',
  });
  String get seeResult => pick({
    StudyLanguage.ko: '결과 보기',
    StudyLanguage.en: 'See result',
    StudyLanguage.ja: '結果を見る',
    StudyLanguage.pt: 'Ver resultado',
  });
  String get nextQuestion => pick({
    StudyLanguage.ko: '다음 문제',
    StudyLanguage.en: 'Next question',
    StudyLanguage.ja: '次の問題',
    StudyLanguage.pt: 'Próxima questão',
  });
  String get itemGained => pick({
    StudyLanguage.ko: '아이템 획득',
    StudyLanguage.en: 'Item gained',
    StudyLanguage.ja: 'アイテム獲得',
    StudyLanguage.pt: 'Item obtido',
  });
  String itemGainedWithLabel(String label) => pick({
    StudyLanguage.ko: '아이템 획득: $label',
    StudyLanguage.en: 'Item gained: $label',
    StudyLanguage.ja: 'アイテム獲得: $label',
    StudyLanguage.pt: 'Item obtido: $label',
  });
  String get hintNoneLeft => pick({
    StudyLanguage.ko: '보유한 힌트가 없어요',
    StudyLanguage.en: 'No hints left',
    StudyLanguage.ja: 'ヒントがありません',
    StudyLanguage.pt: 'Sem dicas restantes',
  });
  String get hintAfterReveal => pick({
    StudyLanguage.ko: '정답 공개 후에는 힌트를 쓸 수 없어요',
    StudyLanguage.en: 'Hints can\'t be used after the answer is revealed',
    StudyLanguage.ja: '正解表示後はヒントを使えません',
    StudyLanguage.pt:
        'As dicas não podem ser usadas depois que a resposta é revelada',
  });
  String get hintAlreadyUsed => pick({
    StudyLanguage.ko: '이 문제에는 이미 사용했어요',
    StudyLanguage.en: 'Already used on this question',
    StudyLanguage.ja: 'この問題ではすでに使用済みです',
    StudyLanguage.pt: 'Já usada nesta questão',
  });
  String get hintTimerFull => pick({
    StudyLanguage.ko: '타이머가 이미 가득 차 있어요',
    StudyLanguage.en: 'The timer is already full',
    StudyLanguage.ja: 'タイマーはすでに満タンです',
    StudyLanguage.pt: 'O cronômetro já está cheio',
  });
  String get result => pick({
    StudyLanguage.ko: '결과',
    StudyLanguage.en: 'Result',
    StudyLanguage.ja: '結果',
    StudyLanguage.pt: 'Resultado',
  });

  String resultTitle(double rate) {
    if (rate >= 0.9) {
      return pick({
        StudyLanguage.ko: '완벽에 가까워요',
        StudyLanguage.en: 'Almost perfect',
        StudyLanguage.ja: 'ほぼ完璧です',
        StudyLanguage.pt: 'Quase perfeito',
      });
    }
    if (rate >= 0.7) {
      return pick({
        StudyLanguage.ko: '좋은 흐름이에요',
        StudyLanguage.en: 'Good run',
        StudyLanguage.ja: '良い流れです',
        StudyLanguage.pt: 'Bom desempenho',
      });
    }
    return pick({
      StudyLanguage.ko: '다시 익혀볼까요',
      StudyLanguage.en: 'Keep practicing',
      StudyLanguage.ja: 'もう一度練習しましょう',
      StudyLanguage.pt: 'Continue praticando',
    });
  }

  String get bestStreak => pick({
    StudyLanguage.ko: '최고 콤보',
    StudyLanguage.en: 'Best streak',
    StudyLanguage.ja: '最高コンボ',
    StudyLanguage.pt: 'Melhor combo',
  });
  String get runPoints => pick({
    StudyLanguage.ko: '이번 점수',
    StudyLanguage.en: 'Run points',
    StudyLanguage.ja: '今回の点数',
    StudyLanguage.pt: 'Pontos desta partida',
  });
  String get totalPoints => pick({
    StudyLanguage.ko: '총 점수',
    StudyLanguage.en: 'Total points',
    StudyLanguage.ja: '合計点',
    StudyLanguage.pt: 'Pontos totais',
  });
  String get currentRank => pick({
    StudyLanguage.ko: '현재 랭크',
    StudyLanguage.en: 'Current rank',
    StudyLanguage.ja: '現在のランク',
    StudyLanguage.pt: 'Patente atual',
  });
  String get backHome => pick({
    StudyLanguage.ko: '홈으로',
    StudyLanguage.en: 'Back home',
    StudyLanguage.ja: 'ホームへ',
    StudyLanguage.pt: 'Voltar ao início',
  });
  String itemsGained(int count) => pick({
    StudyLanguage.ko: '아이템 $count개 획득',
    StudyLanguage.en: '$count ${count == 1 ? "item" : "items"} gained',
    StudyLanguage.ja: 'アイテム$count個獲得',
    StudyLanguage.pt: '$count ${count == 1 ? "item obtido" : "itens obtidos"}',
  });
  String get levelUp => pick({
    StudyLanguage.ko: '레벨 업',
    StudyLanguage.en: 'Level up',
    StudyLanguage.ja: 'レベルアップ',
    StudyLanguage.pt: 'Subiu de nível',
  });
  String get rankUp => pick({
    StudyLanguage.ko: '랭크 업',
    StudyLanguage.en: 'Rank up',
    StudyLanguage.ja: 'ランクアップ',
    StudyLanguage.pt: 'Subiu de patente',
  });
  String get roundFailed => pick({
    StudyLanguage.ko: '라운드 실패',
    StudyLanguage.en: 'Round failed',
    StudyLanguage.ja: 'ラウンド失敗',
    StudyLanguage.pt: 'Rodada não concluída',
  });
  String roundFailedBody(int minCorrect, int correct, int total) => pick({
    StudyLanguage.ko:
        '$total문제 중 $correct개 정답입니다. 클리어에는 $minCorrect개 이상이 필요해요.',
    StudyLanguage.en:
        '$correct/$total correct. You need at least $minCorrect to clear.',
    StudyLanguage.ja: '$total問中$correct問正解。クリアには$minCorrect問以上必要です。',
    StudyLanguage.pt:
        '$correct/$total corretas. Você precisa de pelo menos $minCorrect para passar.',
  });
  String get cleared => pick({
    StudyLanguage.ko: '클리어',
    StudyLanguage.en: 'Cleared',
    StudyLanguage.ja: 'クリア',
    StudyLanguage.pt: 'Concluída',
  });
  String get bestUpdated => pick({
    StudyLanguage.ko: '기록 갱신',
    StudyLanguage.en: 'Best updated',
    StudyLanguage.ja: '記録更新',
    StudyLanguage.pt: 'Recorde atualizado',
  });
  String thisRunStars(int stars) => pick({
    StudyLanguage.ko: '이번 별 $stars개',
    StudyLanguage.en: 'This run: $stars ${stars == 1 ? "star" : "stars"}',
    StudyLanguage.ja: '今回のスター $stars個',
    StudyLanguage.pt:
        'Nesta partida: $stars ${stars == 1 ? "estrela" : "estrelas"}',
  });
  String bestStars(int stars) => pick({
    StudyLanguage.ko: '최고 별 $stars개',
    StudyLanguage.en: 'Best: $stars ${stars == 1 ? "star" : "stars"}',
    StudyLanguage.ja: '最高スター $stars個',
    StudyLanguage.pt: 'Melhor: $stars ${stars == 1 ? "estrela" : "estrelas"}',
  });
  String get marathonBestUpdated => pick({
    StudyLanguage.ko: '마라톤 기록 갱신',
    StudyLanguage.en: 'Marathon best updated',
    StudyLanguage.ja: 'マラソン記録更新',
    StudyLanguage.pt: 'Recorde da Maratona atualizado',
  });
  String get marathonRecord => pick({
    StudyLanguage.ko: '마라톤 기록',
    StudyLanguage.en: 'Marathon record',
    StudyLanguage.ja: 'マラソン記録',
    StudyLanguage.pt: 'Recorde da Maratona',
  });
  String bestScore(int score, int total) => pick({
    StudyLanguage.ko: '최고 $score/$total',
    StudyLanguage.en: 'Best $score/$total',
    StudyLanguage.ja: '最高 $score/$total',
    StudyLanguage.pt: 'Melhor $score/$total',
  });
  String previousBest(int score, int total) => pick({
    StudyLanguage.ko: '이전 최고 $score/$total',
    StudyLanguage.en: 'Previous best $score/$total',
    StudyLanguage.ja: '以前の最高 $score/$total',
    StudyLanguage.pt: 'Recorde anterior $score/$total',
  });
  String get vocabularyTier => pick({
    StudyLanguage.ko: '어휘 티어',
    StudyLanguage.en: 'Vocabulary tier',
    StudyLanguage.ja: '語彙ティア',
    StudyLanguage.pt: 'Faixa de vocabulário',
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
    StudyLanguage.pt:
        '$count ${count == 1 ? "coletada" : "coletadas"} · faixa máxima atingida',
  });
  String masteredToNext(int count, int remaining, String nextLabel) => pick({
    StudyLanguage.ko: '$count개 수집 · $nextLabel까지 $remaining개',
    StudyLanguage.en: '$count mastered · $remaining to $nextLabel',
    StudyLanguage.ja: '$count個収集 · $nextLabelまで$remaining個',
    StudyLanguage.pt:
        '$count ${count == 1 ? "coletada" : "coletadas"} · $remaining para $nextLabel',
  });
  String get newLevelReached => pick({
    StudyLanguage.ko: '새 레벨에 도달했어요',
    StudyLanguage.en: 'New level reached!',
    StudyLanguage.ja: '新しいレベルに到達しました',
    StudyLanguage.pt: 'Novo nível alcançado!',
  });
  String get continueLabel => pick({
    StudyLanguage.ko: '계속',
    StudyLanguage.en: 'Continue',
    StudyLanguage.ja: '続ける',
    StudyLanguage.pt: 'Continuar',
  });
  String get adLoadFailed => pick({
    StudyLanguage.ko: '광고를 불러올 수 없어요. 잠시 후 다시 시도해 주세요.',
    StudyLanguage.en: 'Could not load the ad. Please try again later.',
    StudyLanguage.ja: '広告を読み込めませんでした。後でもう一度お試しください。',
    StudyLanguage.pt:
        'Não foi possível carregar o anúncio. Tente novamente mais tarde.',
  });
  String get loadingAd => pick({
    StudyLanguage.ko: '광고 불러오는 중...',
    StudyLanguage.en: 'Loading ad...',
    StudyLanguage.ja: '広告を読み込み中...',
    StudyLanguage.pt: 'Carregando anúncio...',
  });
  String get watchVideoForItem => pick({
    StudyLanguage.ko: '영상 보고 아이템 +1',
    StudyLanguage.en: 'Watch video for item +1',
    StudyLanguage.ja: '動画を見てアイテム +1',
    StudyLanguage.pt: 'Assistir vídeo para item +1',
  });
  String questionCounter(int current, int total) => pick({
    StudyLanguage.ko: '문제 $current / $total',
    StudyLanguage.en: 'Question $current / $total',
    StudyLanguage.ja: '問題 $current / $total',
    StudyLanguage.pt: 'Questão $current / $total',
  });
  String get exitQuizTitle => pick({
    StudyLanguage.ko: '퀴즈를 종료할까요?',
    StudyLanguage.en: 'Exit the quiz?',
    StudyLanguage.ja: 'クイズを終了しますか？',
    StudyLanguage.pt: 'Sair do quiz?',
  });
  String get exitQuizBody => pick({
    StudyLanguage.ko: '현재 퀴즈 진행 내용은 저장되지 않아요.',
    StudyLanguage.en: 'Your progress in this quiz will not be saved.',
    StudyLanguage.ja: 'このクイズの進行状況は保存されません。',
    StudyLanguage.pt: 'Seu progresso neste quiz não será salvo.',
  });
  String get keepPlaying => pick({
    StudyLanguage.ko: '계속 풀기',
    StudyLanguage.en: 'Keep playing',
    StudyLanguage.ja: '続ける',
    StudyLanguage.pt: 'Continuar jogando',
  });
  String get exitQuiz => pick({
    StudyLanguage.ko: '퀴즈 종료',
    StudyLanguage.en: 'Exit quiz',
    StudyLanguage.ja: 'クイズを終了',
    StudyLanguage.pt: 'Sair do quiz',
  });
  String get finish => pick({
    StudyLanguage.ko: '종료',
    StudyLanguage.en: 'Finish',
    StudyLanguage.ja: '終了',
    StudyLanguage.pt: 'Finalizar',
  });
  String get next => pick({
    StudyLanguage.ko: '다음',
    StudyLanguage.en: 'Next',
    StudyLanguage.ja: '次へ',
    StudyLanguage.pt: 'Próximo',
  });
  String get done => pick({
    StudyLanguage.ko: '완료',
    StudyLanguage.en: 'Done',
    StudyLanguage.ja: '完了',
    StudyLanguage.pt: 'Concluído',
  });
  String get saving => pick({
    StudyLanguage.ko: '저장 중...',
    StudyLanguage.en: 'Saving...',
    StudyLanguage.ja: '保存中...',
    StudyLanguage.pt: 'Salvando...',
  });
  String get score => pick({
    StudyLanguage.ko: '점수',
    StudyLanguage.en: 'Score',
    StudyLanguage.ja: 'スコア',
    StudyLanguage.pt: 'Pontuação',
  });
  String get combo => pick({
    StudyLanguage.ko: '콤보',
    StudyLanguage.en: 'Combo',
    StudyLanguage.ja: 'コンボ',
    StudyLanguage.pt: 'Combo',
  });
  String hintCount(int used, int total) => pick({
    StudyLanguage.ko: '힌트 $used/$total',
    StudyLanguage.en: 'Hint $used/$total',
    StudyLanguage.ja: 'ヒント $used/$total',
    StudyLanguage.pt: 'Dica $used/$total',
  });
  String get correct => pick({
    StudyLanguage.ko: '정답!',
    StudyLanguage.en: 'Correct!',
    StudyLanguage.ja: '正解!',
    StudyLanguage.pt: 'Correto!',
  });
  String get incorrect => pick({
    StudyLanguage.ko: '오답',
    StudyLanguage.en: 'Incorrect',
    StudyLanguage.ja: '不正解',
    StudyLanguage.pt: 'Incorreto',
  });
  String get wordToMeaning => pick({
    StudyLanguage.ko: '이 스페인어 단어의 뜻은?',
    StudyLanguage.en: 'What does this Spanish word mean?',
    StudyLanguage.ja: 'このスペイン語の意味は？',
    StudyLanguage.pt: 'O que esta palavra em espanhol significa?',
  });
  String get meaningToWord => pick({
    StudyLanguage.ko: '이 뜻에 맞는 스페인어는?',
    StudyLanguage.en: 'Which Spanish word matches this meaning?',
    StudyLanguage.ja: 'この意味に合うスペイン語は？',
    StudyLanguage.pt:
        'Qual palavra em espanhol corresponde a este significado?',
  });
  String get blankQuestion => pick({
    StudyLanguage.ko: '예문 빈칸에 들어갈 단어는?',
    StudyLanguage.en: 'Which word fills the blank?',
    StudyLanguage.ja: '例文の空欄に入る単語は？',
    StudyLanguage.pt: 'Qual palavra preenche a lacuna?',
  });

  String quizModeLabel(String modeName) {
    switch (modeName) {
      case 'translationLookup':
        return pick({
          StudyLanguage.ko: '뜻',
          StudyLanguage.en: 'Meaning',
          StudyLanguage.ja: '意味',
          StudyLanguage.pt: 'Significado',
        });
      case 'wordLookup':
        return pick({
          StudyLanguage.ko: '단어',
          StudyLanguage.en: 'Word',
          StudyLanguage.ja: '単語',
          StudyLanguage.pt: 'Palavra',
        });
      case 'sentenceBlank':
        return pick({
          StudyLanguage.ko: '빈칸',
          StudyLanguage.en: 'Blank',
          StudyLanguage.ja: '空欄',
          StudyLanguage.pt: 'Lacuna',
        });
    }
    return modeName;
  }

  String levelLabel(String level) => 'DELE $level';
}
