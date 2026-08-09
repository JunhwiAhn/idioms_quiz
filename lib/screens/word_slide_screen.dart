import 'dart:async';

import 'package:flutter/material.dart';

import '../data/ad_service.dart';
import '../data/app_text.dart';
import '../data/pronunciation_service.dart';
import '../data/screen_awake_service.dart';
import '../models/idiom.dart';
import '../theme/app_theme.dart';
import '../widgets/pronounce.dart';

class WordSlideScreen extends StatefulWidget {
  final List<Idiom> idioms;
  final StudyLanguage language;

  const WordSlideScreen({
    super.key,
    required this.idioms,
    required this.language,
  }) : assert(idioms.length > 0);

  @override
  State<WordSlideScreen> createState() => _WordSlideScreenState();
}

class _WordSlideScreenState extends State<WordSlideScreen>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  late List<Idiom> _idioms;
  Timer? _autoTimer;
  int _index = 0;
  bool _autoPlay = false;
  bool _autoPlayUnlocked = false;
  bool _adBusy = false;
  bool _transitionBusy = false;
  bool _autoSpeaking = false;
  int? _remainingAutoSeconds;
  int _speechRunId = 0;
  double _autoDelaySeconds = PronunciationService.defaultShadowingAutoDelay;
  double _speechRate = PronunciationService.defaultSpeechRate;

  AppText get _appText => AppText(widget.language);
  _SlideCopy get _copy => _SlideCopy(widget.language);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _idioms = List<Idiom>.of(widget.idioms);
    _pageController = PageController();
    unawaited(AdService.instance.preloadInterstitial());
    unawaited(AdService.instance.preloadRewarded());
    unawaited(_loadPlaybackSettings());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_speakCurrent());
    });
  }

  Future<void> _loadPlaybackSettings() async {
    await PronunciationService.instance.loadSettings();
    if (!mounted) return;
    setState(() {
      _autoDelaySeconds = PronunciationService.instance.shadowingAutoDelay;
      _speechRate = PronunciationService.instance.speechRate;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _stopAutoPlay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoTimer?.cancel();
    unawaited(PronunciationService.instance.stop());
    unawaited(ScreenAwakeService.setEnabled(false));
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int value) {
    _autoTimer?.cancel();
    setState(() {
      _index = value;
      _remainingAutoSeconds = null;
    });
    if (_autoPlay) {
      unawaited(_playCurrentThenCountDown());
    } else {
      unawaited(_speakCurrent());
    }
  }

  Future<void> _goTo(int index) async {
    if (index < 0 || index >= _idioms.length || !_pageController.hasClients) {
      return;
    }
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _toggleAutoPlay() async {
    if (_autoPlay) {
      _stopAutoPlay();
      return;
    }

    if (!_autoPlayUnlocked) {
      if (_adBusy) return;
      setState(() => _adBusy = true);
      await PronunciationService.instance.stop();
      final outcome = await AdService.instance.showRewardedWithOutcome();
      if (!mounted) return;
      final unlocked = outcome != RewardedAdOutcome.dismissedWithoutReward;
      setState(() {
        _adBusy = false;
        _autoPlayUnlocked = unlocked;
      });
      if (!unlocked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_copy.finishRewardAd),
            behavior: SnackBarBehavior.floating,
          ),
        );
        unawaited(_speakCurrent());
        return;
      }
    }

    await PronunciationService.instance.stop();
    if (!mounted) return;
    setState(() => _autoPlay = true);
    unawaited(ScreenAwakeService.setEnabled(true));
    unawaited(_playCurrentThenCountDown());
  }

  Future<void> _next() async {
    if (_transitionBusy) return;
    _speechRunId++;
    _autoTimer?.cancel();
    setState(() => _transitionBusy = true);

    // A manual Next tap is a clean content boundary: finish shadowing audio,
    // optionally show the ad, then start the next word only after dismissal.
    await PronunciationService.instance.stop();
    // Rewarded auto-play unlocks an ad-free session, including manual skips.
    if (!_autoPlayUnlocked) {
      await AdService.instance.maybeShowShadowingInterstitial();
    }
    if (!mounted) return;
    await _goTo(_index + 1);
    if (mounted) setState(() => _transitionBusy = false);
  }

  void _stopAutoPlay() {
    _speechRunId++;
    _autoTimer?.cancel();
    _autoTimer = null;
    unawaited(PronunciationService.instance.stop());
    unawaited(ScreenAwakeService.setEnabled(false));
    if (mounted) {
      setState(() {
        _autoPlay = false;
        _autoSpeaking = false;
        _remainingAutoSeconds = null;
      });
    }
  }

  Future<void> _playCurrentThenCountDown() async {
    final runId = ++_speechRunId;
    _autoTimer?.cancel();
    if (mounted) {
      setState(() {
        _autoSpeaking = true;
        _remainingAutoSeconds = null;
      });
    }

    await _speakCurrent();
    if (!mounted || !_autoPlay || runId != _speechRunId) return;
    if (_index >= _idioms.length - 1) {
      _stopAutoPlay();
      return;
    }

    final totalSeconds = _autoDelaySeconds.round().clamp(1, 60);
    setState(() {
      _autoSpeaking = false;
      _remainingAutoSeconds = totalSeconds;
    });
    _autoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_autoPlay || runId != _speechRunId) {
        timer.cancel();
        return;
      }
      final remaining = _remainingAutoSeconds ?? 0;
      if (remaining <= 1) {
        timer.cancel();
        _remainingAutoSeconds = null;
        unawaited(_goTo(_index + 1));
        return;
      }
      setState(() => _remainingAutoSeconds = remaining - 1);
    });
  }

  Future<void> _showPlaybackSettings() async {
    _stopAutoPlay();
    await PronunciationService.instance.loadSettings();
    if (!mounted) return;
    setState(() {
      _autoDelaySeconds = PronunciationService.instance.shadowingAutoDelay;
      _speechRate = PronunciationService.instance.speechRate;
    });
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _ShadowingSettingsSheet(
        copy: _copy,
        autoDelaySeconds: _autoDelaySeconds,
        speechRate: _speechRate,
        onAutoDelayChanged: (value) {
          if (mounted) setState(() => _autoDelaySeconds = value);
          unawaited(PronunciationService.instance.setShadowingAutoDelay(value));
        },
        onSpeechRateChanged: (value) {
          if (mounted) setState(() => _speechRate = value);
          unawaited(PronunciationService.instance.setSpeechRate(value));
        },
        onPreview: _speakCurrent,
      ),
    );
  }

  Future<void> _speakCurrent() => pronounceShadowingWithFeedback(
    context,
    spanish: _idioms[_index].idiom,
    meaning: _idioms[_index].meaningFor(widget.language),
    language: widget.language,
    appText: _appText,
  );

  void _shuffle() {
    _stopAutoPlay();
    setState(() {
      _idioms.shuffle();
      _index = 0;
    });
    if (_pageController.hasClients) _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = _idioms.length;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_copy.title),
            Text(
              '${_index + 1} / $count',
              style: notoSansJp(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _copy.settings,
            onPressed: _showPlaybackSettings,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: _copy.shuffle,
            onPressed: _shuffle,
            icon: const Icon(Icons.shuffle_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / count,
            minHeight: 4,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                key: const ValueKey('word-slide-page-view'),
                controller: _pageController,
                itemCount: count,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) => _WordSlide(
                  idiom: _idioms[index],
                  language: widget.language,
                  appText: _appText,
                ),
              ),
            ),
            _SlideControls(
              copy: _copy,
              index: _index,
              count: count,
              autoPlay: _autoPlay,
              autoPlayUnlocked: _autoPlayUnlocked,
              autoSpeaking: _autoSpeaking,
              remainingAutoSeconds: _remainingAutoSeconds,
              adBusy: _adBusy,
              onPrevious: _index == 0 ? null : () => _goTo(_index - 1),
              onAutoPlay: _toggleAutoPlay,
              onNext: _index == count - 1
                  ? () => Navigator.of(context).pop()
                  : _transitionBusy
                  ? null
                  : _next,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShadowingSettingsSheet extends StatefulWidget {
  final _SlideCopy copy;
  final double autoDelaySeconds;
  final double speechRate;
  final ValueChanged<double> onAutoDelayChanged;
  final ValueChanged<double> onSpeechRateChanged;
  final VoidCallback onPreview;

  const _ShadowingSettingsSheet({
    required this.copy,
    required this.autoDelaySeconds,
    required this.speechRate,
    required this.onAutoDelayChanged,
    required this.onSpeechRateChanged,
    required this.onPreview,
  });

  @override
  State<_ShadowingSettingsSheet> createState() =>
      _ShadowingSettingsSheetState();
}

class _ShadowingSettingsSheetState extends State<_ShadowingSettingsSheet> {
  late double _autoDelaySeconds = widget.autoDelaySeconds;
  late double _speechRate = widget.speechRate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.copy.settings,
              style: notoSerifJp(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            _SettingLabel(
              icon: Icons.skip_next_rounded,
              title: widget.copy.autoDelay,
              value: widget.copy.secondsLabel(_autoDelaySeconds),
            ),
            Slider(
              value: _autoDelaySeconds,
              min: PronunciationService.minShadowingAutoDelay,
              max: PronunciationService.maxShadowingAutoDelay,
              divisions: 9,
              label: widget.copy.secondsLabel(_autoDelaySeconds),
              onChanged: (value) {
                setState(() => _autoDelaySeconds = value);
              },
              onChangeEnd: widget.onAutoDelayChanged,
            ),
            Text(
              widget.copy.autoDelayHint,
              style: notoSansJp(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            _SettingLabel(
              icon: Icons.record_voice_over_rounded,
              title: widget.copy.pronunciationSpeed,
              value: '${_speechRate.toStringAsFixed(1)}×',
            ),
            Slider(
              value: _speechRate,
              min: PronunciationService.minSpeechRate,
              max: PronunciationService.maxSpeechRate,
              divisions: 7,
              label: '${_speechRate.toStringAsFixed(1)}×',
              onChanged: (value) {
                setState(() => _speechRate = value);
              },
              onChangeEnd: widget.onSpeechRateChanged,
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onPreview,
                icon: const Icon(Icons.volume_up_rounded),
                label: Text(widget.copy.previewPronunciation),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SettingLabel({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: notoSansJp(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          value,
          style: notoSansJp(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }
}

class _WordSlide extends StatelessWidget {
  final Idiom idiom;
  final StudyLanguage language;
  final AppText appText;

  const _WordSlide({
    required this.idiom,
    required this.language,
    required this.appText,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final copy = _SlideCopy(language);
    final hasExample = idiom.hasUsableExample;
    final exampleMeaning = idiom.exampleMeaningFor(language).trim();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 340),
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: scheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.07),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        _SlideTag(label: idiom.level),
                        _SlideTag(
                          label: appText.partOfSpeechName(idiom.partOfSpeech),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      idiom.idiom,
                      textAlign: TextAlign.center,
                      style: notoSerifJp(
                        fontSize: 44,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (idiom.reading.trim().isNotEmpty &&
                        idiom.reading.trim() != idiom.idiom.trim()) ...[
                      const SizedBox(height: 8),
                      Text(
                        idiom.reading,
                        textAlign: TextAlign.center,
                        style: notoSansJp(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    PronounceButton(
                      text: idiom.idiom,
                      appText: appText,
                      onSpeak: () => pronounceShadowingWithFeedback(
                        context,
                        spanish: idiom.idiom,
                        meaning: idiom.meaningFor(language),
                        language: language,
                        appText: appText,
                      ),
                      builder: (context, available, onPressed) =>
                          FilledButton.tonalIcon(
                            onPressed: onPressed,
                            icon: Icon(
                              available
                                  ? Icons.volume_up_rounded
                                  : Icons.download_rounded,
                            ),
                            label: Text(
                              available
                                  ? appText.playPronunciation
                                  : appText.ttsDownloadVoice,
                            ),
                          ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        idiom.meaningFor(language),
                        textAlign: TextAlign.center,
                        style: notoSansJp(
                          fontSize: 20,
                          height: 1.45,
                          fontWeight: FontWeight.w800,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasExample) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 20,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            appText.example,
                            style: notoSansJp(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        idiom.example,
                        style: notoSerifJp(
                          fontSize: 17,
                          height: 1.5,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (exampleMeaning.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          exampleMeaning,
                          style: notoSansJp(
                            fontSize: 13,
                            height: 1.45,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                copy.swipeHint,
                style: notoSansJp(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideControls extends StatelessWidget {
  final _SlideCopy copy;
  final int index;
  final int count;
  final bool autoPlay;
  final bool autoPlayUnlocked;
  final bool autoSpeaking;
  final int? remainingAutoSeconds;
  final bool adBusy;
  final VoidCallback? onPrevious;
  final VoidCallback onAutoPlay;
  final VoidCallback? onNext;

  const _SlideControls({
    required this.copy,
    required this.index,
    required this.count,
    required this.autoPlay,
    required this.autoPlayUnlocked,
    required this.autoSpeaking,
    required this.remainingAutoSeconds,
    required this.adBusy,
    required this.onPrevious,
    required this.onAutoPlay,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: adBusy ? null : onAutoPlay,
                icon: adBusy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        autoPlay
                            ? Icons.pause_rounded
                            : autoPlayUnlocked
                            ? Icons.play_arrow_rounded
                            : Icons.ondemand_video_rounded,
                      ),
                label: Text(
                  adBusy
                      ? copy.loadingAd
                      : autoPlay
                      ? autoSpeaking
                            ? copy.playingVoices
                            : remainingAutoSeconds != null
                            ? copy.nextAfterSeconds(remainingAutoSeconds!)
                            : copy.pauseAuto
                      : autoPlayUnlocked
                      ? copy.startAuto
                      : copy.watchAdForAuto,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPrevious,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: Text(copy.previous),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onNext,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.chevron_right_rounded),
                    label: Text(index == count - 1 ? copy.done : copy.next),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideTag extends StatelessWidget {
  final String label;

  const _SlideTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: notoSansJp(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SlideCopy {
  final StudyLanguage language;

  const _SlideCopy(this.language);

  String _pick(String ko, String en, String ja, String pt) =>
      switch (language) {
        StudyLanguage.ko => ko,
        StudyLanguage.en => en,
        StudyLanguage.ja => ja,
        StudyLanguage.pt => pt,
      };

  String get title => _pick('쉐도잉', 'Shadowing', 'シャドーイング', 'Shadowing');
  String get shuffle => _pick('순서 섞기', 'Shuffle', 'シャッフル', 'Embaralhar');
  String get settings => _pick(
    '쉐도잉 설정',
    'Shadowing settings',
    'シャドーイング設定',
    'Configurações de shadowing',
  );
  String get autoDelay => _pick(
    '음성 종료 후 대기 시간',
    'Wait after audio',
    '音声終了後の待ち時間',
    'Espera após o áudio',
  );
  String get autoDelayHint => _pick(
    '스페인어와 뜻 음성이 모두 끝난 뒤, 설정한 시간만큼 기다리고 다음 단어로 넘어가요.',
    'The countdown starts after both the Spanish word and its meaning finish.',
    'スペイン語と意味の音声が両方終わってからカウントダウンします。',
    'A contagem começa após o áudio em espanhol e o significado terminarem.',
  );
  String get pronunciationSpeed =>
      _pick('발음 속도', 'Pronunciation speed', '発音速度', 'Velocidade da pronúncia');
  String get previewPronunciation => _pick(
    '현재 단어로 미리 듣기',
    'Preview with current word',
    '現在の単語で試聴',
    'Ouvir com a palavra atual',
  );
  String secondsLabel(double seconds) => _pick(
    '${seconds.round()}초',
    '${seconds.round()} sec',
    '${seconds.round()}秒',
    '${seconds.round()} s',
  );
  String get swipeHint => _pick(
    '좌우로 밀어서 단어를 넘겨 보세요',
    'Swipe left or right to move between words',
    '左右にスワイプして単語を移動できます',
    'Deslize para passar entre as palavras',
  );
  String get previous => _pick('이전', 'Previous', '前へ', 'Anterior');
  String get next => _pick('다음', 'Next', '次へ', 'Próxima');
  String get done => _pick('완료', 'Done', '完了', 'Concluir');
  String get watchAdForAuto => _pick(
    '광고 보고 자동재생',
    'Watch an ad for auto-play',
    '広告を見て自動再生',
    'Assistir anúncio para reprodução automática',
  );
  String get loadingAd => _pick(
    '광고 불러오는 중...',
    'Loading ad...',
    '広告を読み込み中...',
    'Carregando anúncio...',
  );
  String get finishRewardAd => _pick(
    '광고 시청을 완료하면 자동재생을 사용할 수 있어요.',
    'Finish watching the ad to use auto-play.',
    '広告を最後まで見ると自動再生を利用できます。',
    'Conclua o anúncio para usar a reprodução automática.',
  );
  String get startAuto => _pick(
    '자동 넘김 시작',
    'Start auto-play',
    '自動送りを開始',
    'Iniciar reprodução automática',
  );
  String get pauseAuto => _pick(
    '자동 넘김 일시정지',
    'Pause auto-play',
    '自動送りを一時停止',
    'Pausar reprodução automática',
  );
  String get playingVoices => _pick(
    '음성 재생 중 · 눌러서 일시정지',
    'Playing audio · tap to pause',
    '音声再生中・タップで一時停止',
    'Reproduzindo áudio · toque para pausar',
  );
  String nextAfterSeconds(int seconds) => _pick(
    '$seconds초 후 다음 단어 · 눌러서 일시정지',
    'Next word in ${seconds}s · tap to pause',
    '$seconds秒後に次の単語・タップで一時停止',
    'Próxima palavra em ${seconds}s · toque para pausar',
  );
}
