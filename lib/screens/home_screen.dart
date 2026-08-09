import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_text.dart';
import '../theme/app_theme.dart';
import '../data/ad_service.dart';
import '../data/audio_service.dart';
import '../data/daily.dart';
import '../data/idiom_repository.dart';
import '../data/level_tier.dart';
import '../data/quiz_session.dart';
import '../data/review_service.dart';
import '../data/score_service.dart';
import '../data/stage_plan.dart';
import '../models/idiom.dart';
import 'collection_screen.dart';
import 'quiz_screen.dart';
import 'stage_screen.dart';
import 'word_slide_screen.dart';
import 'wrong_note_screen.dart';

String _homeAppName(AppText text, StudyLanguage language) => text.appName;

String _modeSectionTitle(AppText text, StudyLanguage language) =>
    language == StudyLanguage.ko ? '모드' : text.practiceModes;

String _stageTitle(AppText text, StudyLanguage language) =>
    language == StudyLanguage.ko ? '스테이지 모드' : text.stage;

String _stageSubtitle(AppText text, StudyLanguage language) =>
    language == StudyLanguage.ko
    ? '테마별 10문제로 DELE 어휘를 차근차근 익혀요.'
    : text.stageSubtitle;

String _randomShadowingTitle(StudyLanguage language) => switch (language) {
  StudyLanguage.ko => '랜덤 쉐도잉',
  StudyLanguage.en => 'Random shadowing',
  StudyLanguage.ja => 'ランダムシャドーイング',
  StudyLanguage.pt => 'Shadowing aleatório',
};

// ignore: unused_element
String _randomChallengeTitle(AppText text, StudyLanguage language) =>
    language == StudyLanguage.ko ? '랜덤 챌린지 모드' : 'Random Challenge Mode';

// ignore: unused_element
String _randomChallengeSubtitle(AppText text, StudyLanguage language) =>
    language == StudyLanguage.ko
    ? '무작위 50문제로 스페인어 어휘를 집중 점검해요.'
    : text.marathonFocusedSubtitle;

enum _HomeMenuAction { toggleMute, rateApp, appInfo }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = IdiomRepository();
  final _scoreService = ScoreService();

  List<Idiom>? _idioms;
  ScoreSnapshot? _snap;
  StagePlan? _plan;
  bool _muted = AudioService.instance.muted;
  StudyLanguage _language = StudyLanguage.ko;
  bool _languageDialogShown = false;
  bool _cognateDialogShown = false;
  bool _skipCognates = false;
  bool _startingRandomChallenge = false;

  /// All words minus the ones the learner opted out of. The stage plan is
  /// built from this too, so the round sizes shown always match what is asked.
  List<Idiom> get _activeIdioms {
    final all = _idioms ?? const <Idiom>[];
    if (!_skipCognates) return all;
    return all
        .where((idiom) => !idiom.isCognateFor(_language))
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
    // Fire-and-forget preload; safe-no-op on web.
    AdService.instance.preloadInterstitial();
  }

  Future<void> _bootstrap() async {
    await _scoreService.grantStarterPackOnce();
    final idioms = await _repo.loadAll();
    final snap = await _scoreService.snapshot();
    final language = await _scoreService.studyLanguage();
    final hasLanguage = await _scoreService.hasStudyLanguage();
    final skip = await _scoreService.skipCognates();
    if (!mounted) return;
    setState(() {
      _idioms = idioms;
      _snap = snap;
      _language = language;
      _skipCognates = skip ?? false;
      _plan = StagePlan.build(_activeIdioms);
    });
    if (!hasLanguage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_languageDialogShown) _showLanguageDialog();
      });
    } else {
      // Covers the locale-detected case: the learner never opened the picker,
      // so the offer has to come from here.
      _maybeOfferCognateSkip();
    }
  }

  /// Offered once, to learners whose language shares spelling with Spanish.
  Future<void> _maybeOfferCognateSkip() async {
    if (_cognateDialogShown) return;
    final idioms = _idioms;
    if (idioms == null) return;
    if (await _scoreService.skipCognates() != null) return;
    final cognates = idioms
        .where((idiom) => idiom.isCognateFor(_language))
        .toList(growable: false);
    // Not worth interrupting anyone for a handful of words.
    if (cognates.length < 50) return;
    if (!mounted) return;
    _cognateDialogShown = true;

    final text = AppText(_language);
    final samples = cognates.take(6).map((i) => i.spanish).join(' · ');
    final choice = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(text.cognateTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text.cognateBody(cognates.length)),
              const SizedBox(height: 14),
              Text(
                text.cognateExamplesLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(samples),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(text.cognateKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(text.cognateSkip),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    await _scoreService.setSkipCognates(choice);
    if (!mounted) return;
    setState(() {
      _skipCognates = choice;
      _plan = StagePlan.build(_activeIdioms);
    });
    if (choice) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(text.cognateHiddenNotice)));
    }
  }

  Future<void> _refreshSnapshot() async {
    final snap = await _scoreService.snapshot();
    final language = await _scoreService.studyLanguage();
    if (!mounted) return;
    setState(() {
      _snap = snap;
      _language = language;
    });
  }

  Future<void> _setLanguage(StudyLanguage language) async {
    await _scoreService.setStudyLanguage(language);
    if (!mounted) return;
    setState(() {
      _language = language;
      // Which words count as cognates depends on the language, so the plan has
      // to be rebuilt whenever it changes.
      _plan = StagePlan.build(_activeIdioms);
    });
    await _maybeOfferCognateSkip();
  }

  Future<void> _showLanguageDialog() async {
    _languageDialogShown = true;
    var selected = _language;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final text = AppText(selected);
            return AlertDialog(
              title: Text(text.chooseLanguageTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text.chooseLanguageBody),
                  const SizedBox(height: 12),
                  for (final language in StudyLanguage.values)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        selected == language
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                      ),
                      title: Text(language.label),
                      onTap: () {
                        setDialogState(() => selected = language);
                      },
                    ),
                ],
              ),
              actions: [
                FilledButton(
                  // Close this dialog before _setLanguage runs: it may open the
                  // cognate offer, which must not stack on top of the picker.
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _setLanguage(selected);
                  },
                  child: Text(text.start),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Sends the learner straight to the listing to rate. The automatic prompt
  /// is throttled by Play and capped by us, so this is the only path someone
  /// who *wants* to leave a rating can rely on.
  Future<void> _openStoreListing() async {
    final text = AppText(_language);
    final opened = await ReviewService.instance.openStoreListing();
    if (!mounted || opened) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text.rateAppUnavailable)));
  }

  Future<void> _toggleMute() async {
    final next = !_muted;
    await AudioService.instance.setMuted(next);
    setState(() => _muted = next);
  }

  Future<void> _startQuiz(int questionCount, {bool isMarathon = false}) async {
    final idioms = _idioms == null ? null : _activeIdioms;
    final snap = _snap;
    if (idioms == null || snap == null || _startingRandomChallenge) return;

    setState(() => _startingRandomChallenge = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    late final QuizSession session;
    try {
      session = QuizSession.build(
        idioms,
        count: questionCount,
        language: _language,
      );
    } finally {
      if (mounted) setState(() => _startingRandomChallenge = false);
    }

    if (session.questions.isEmpty) return;
    AudioService.instance.playSfx(Sfx.modeStart, multiplier: 2.0);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          session: session,
          initialHints: snap.hints,
          isMarathon: isMarathon,
        ),
      ),
    );
    if (!mounted) return;
    await _refreshSnapshot();
  }

  Future<void> _openStageMode() async {
    final plan = _plan;
    if (plan == null) return;
    AudioService.instance.playSfx(Sfx.modeStart, multiplier: 2.0);
    if (!mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StageScreen(plan: plan, language: _language),
      ),
    );
    if (!mounted) return;
    // The result screen's home button pops with popUntil, which bypasses the
    // PopScope result chain — refresh unconditionally so stage runs always
    // land in the home snapshot (wordbook, stats).
    await _refreshSnapshot();
  }

  Future<void> _openFeedbackForm(BuildContext ctx) async {
    final feedbackFormUrl = switch (_language) {
      StudyLanguage.ko =>
        'https://docs.google.com/forms/d/e/1FAIpQLSehoUqeNblgLA3I1d_Plms7H8YBaL9HHaD7f9R1PofrdaNXnw/viewform?usp=header',
      StudyLanguage.en =>
        'https://docs.google.com/forms/d/e/1FAIpQLScgJzVmSDcO1WtiZOVQRkBlHccUBCkzQ5jXOgdFltfYxzZJoA/viewform?usp=header',
      StudyLanguage.ja =>
        'https://docs.google.com/forms/d/e/1FAIpQLSdaNmb7JE8CWiS_4QUV0IawKI4-496jyDNBDXQa-ZDuoBX3Cw/viewform',
      // No Portuguese form exists yet; the English one is the closest fit.
      StudyLanguage.pt =>
        'https://docs.google.com/forms/d/e/1FAIpQLScgJzVmSDcO1WtiZOVQRkBlHccUBCkzQ5jXOgdFltfYxzZJoA/viewform?usp=header',
    };
    final url = Uri.parse(feedbackFormUrl);
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(AppText(_language).feedbackOpenFailed)),
      );
    }
  }

  void _openAppInfoSheet() {
    final scheme = Theme.of(context).colorScheme;
    final text = AppText(_language);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final s = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text.appName,
                    style: notoSerifJp(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: s.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${text.versionLabel}: 1.0.0',
                    style: notoSansJp(fontSize: 11, color: s.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: s.outlineVariant),
                  const SizedBox(height: 12),
                  Text(
                    text.dataStorage,
                    style: notoSerifJp(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: s.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text.dataStorageBody,
                    style: notoSansJp(
                      fontSize: 12,
                      height: 1.5,
                      color: s.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: s.outlineVariant),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _openFeedbackForm(ctx),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.feedback_outlined,
                            size: 18,
                            color: s.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              text.feedback,
                              style: notoSerifJp(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: s.primary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 14,
                            color: s.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Divider(color: s.outlineVariant),
                  const SizedBox(height: 12),
                  Text(
                    text.licenses,
                    style: notoSerifJp(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: s.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        showLicensePage(
                          context: context,
                          applicationName: text.appName,
                          applicationVersion: '1.0.0',
                        );
                      },
                      icon: Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: s.primary,
                      ),
                      label: Text(
                        text.openSourceLicenses,
                        style: notoSansJp(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: s.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        text.close,
                        style: notoSerifJp(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCollection() async {
    // Re-read storage so the wordbook reflects runs committed since the home
    // snapshot was taken, whatever navigation path led back here.
    await _refreshSnapshot();
    if (!mounted) return;
    final idioms = _idioms == null ? null : _activeIdioms;
    final snap = _snap;
    if (idioms == null || snap == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectionScreen(
          idioms: idioms,
          language: _language,
          mastered: snap.mastered,
          correctCounts: snap.correctCounts,
        ),
      ),
    );
  }

  Future<void> _openRandomShadowing() async {
    await _refreshSnapshot();
    if (!mounted || _idioms == null) return;
    final idioms = List<Idiom>.of(_activeIdioms)..shuffle();
    if (idioms.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WordSlideScreen(idioms: idioms, language: _language),
      ),
    );
  }

  Future<void> _openWrongNote() async {
    await _refreshSnapshot();
    if (!mounted) return;
    final idioms = _idioms == null ? null : _activeIdioms;
    final snap = _snap;
    if (idioms == null || snap == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            WrongNoteScreen(idioms: idioms, language: _language, snap: snap),
      ),
    );
  }

  // ignore: unused_element
  Future<void> _openTitleSheet() async {
    final snap = _snap;
    if (snap == null) return;
    final text = AppText(_language);
    final titles = _scoreService.availableTitles(snap);
    final current = _scoreService.equippedTitleFor(snap);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            itemCount: titles.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) {
              if (index == 0) {
                return Text(
                  text.titles,
                  style: notoSerifJp(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                );
              }
              final title = titles[index - 1];
              final selected = title.id == current.id;
              return Material(
                color: selected
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.workspace_premium_outlined,
                    color: selected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                  title: Text(
                    text.titleLabel(title.id, title.label),
                    style: notoSerifJp(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    text.titleDescription(title.id, title.description),
                    style: notoSansJp(
                      fontSize: 11,
                      color: selected
                          ? scheme.onPrimaryContainer.withValues(alpha: 0.75)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () async {
                    await _scoreService.equipTitle(title.id);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    await _bootstrap();
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final idioms = _idioms == null ? null : _activeIdioms;
    final snap = _snap;
    final text = AppText(_language);
    final scheme = Theme.of(context).colorScheme;
    final compactAppBar = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/home_brand_icon.png',
              width: 40,
              height: 40,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                compactAppBar ? 'DELE Voca' : _homeAppName(text, _language),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<StudyLanguage>(
            tooltip: text.languageMenu,
            icon: const Icon(Icons.language_rounded),
            initialValue: _language,
            onSelected: _setLanguage,
            itemBuilder: (context) => [
              for (final language in StudyLanguage.values)
                PopupMenuItem(value: language, child: Text(language.label)),
            ],
          ),
          PopupMenuButton<_HomeMenuAction>(
            tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (action) {
              switch (action) {
                case _HomeMenuAction.toggleMute:
                  _toggleMute();
                case _HomeMenuAction.rateApp:
                  _openStoreListing();
                case _HomeMenuAction.appInfo:
                  _openAppInfoSheet();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _HomeMenuAction.toggleMute,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  ),
                  title: Text(_muted ? text.unmute : text.mute),
                ),
              ),
              PopupMenuItem(
                value: _HomeMenuAction.rateApp,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.star_rate_rounded),
                  title: Text(text.rateApp),
                ),
              ),
              PopupMenuItem(
                value: _HomeMenuAction.appInfo,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(text.appInfo),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: (idioms == null || snap == null)
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HomeHero(
                              snap: snap,
                              total: idioms.length,
                              idioms: idioms,
                              language: _language,
                              text: text,
                              equippedTitle: _scoreService.equippedTitleFor(
                                snap,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 420.ms)
                            .slideY(
                              begin: -0.05,
                              end: 0,
                              duration: 420.ms,
                              curve: Curves.easeOut,
                            ),
                        const SizedBox(height: 20),
                        _ModeSectionHeader(
                          title: _modeSectionTitle(text, _language),
                          actionLabel: text.wordbook,
                          onAction: _openCollection,
                          secondaryActionLabel: _randomShadowingTitle(
                            _language,
                          ),
                          onSecondaryAction: _openRandomShadowing,
                        ),
                        const SizedBox(height: 10),
                        _PlayModeTile(
                          title: _stageTitle(text, _language),
                          subtitle: _stageSubtitle(text, _language),
                          icon: Icons.quiz_rounded,
                          badge: text.recommended,
                          accentColor: scheme.primary,
                          emphasized: true,
                          onTap: _openStageMode,
                        ),
                        const SizedBox(height: 12),
                        _PlayModeTile(
                          title: text.randomChallengeMode,
                          subtitle: text.randomChallengeSubtitle,
                          icon: Icons.fact_check_rounded,
                          badge: '50 Q',
                          accentColor: const Color(0xFFC1121F),
                          loading: _startingRandomChallenge,
                          onTap: () => _startQuiz(50, isMarathon: true),
                        ),
                        const SizedBox(height: 12),
                        _PlayModeTile(
                          title: text.wrongNote,
                          subtitle: text.wrongNoteSubtitle,
                          icon: Icons.edit_note_rounded,
                          badge: '${snap.wrongIdioms.length}',
                          accentColor: const Color(0xFF008C9E),
                          onTap: _openWrongNote,
                        ),
                        const SizedBox(height: 20),
                        Center(child: AdService.instance.buildBanner()),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  final ScoreSnapshot snap;
  final int total;
  final List<Idiom> idioms;
  final StudyLanguage language;
  final AppText text;
  final EquippedTitle equippedTitle;
  const _HomeHero({
    required this.snap,
    required this.total,
    required this.idioms,
    required this.language,
    required this.text,
    required this.equippedTitle,
  });

  @override
  Widget build(BuildContext context) {
    final next = snap.next;
    final toGo = next == null ? 0 : next.threshold - snap.totalCorrect;
    final today = idiomOfTheDay(idioms, DateTime.now());
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF7A2508), Color(0xFFD9480F), Color(0xFFFF8A3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFFFE1D5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD9480F).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _HeroPill(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Lv ${snap.level}',
                        ),
                        _HeroPill(
                          icon: Icons.workspace_premium_rounded,
                          label: text.titleLabel(
                            equippedTitle.id,
                            equippedTitle.label,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      next == null
                          ? text.maxRank
                          : text.nextRank(text.rankLabel(next.name), toGo),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: notoSansJp(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${snap.mastered.length}/$total',
                style: notoSerifJp(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 12,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.black.withValues(alpha: 0.24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: snap.levelProgress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFF3C4),
                        Color(0xFFFFD54F),
                        Color(0xFFFFB300),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.55),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.74),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${text.todaysWord}: ${today.idiom} - ${today.meaningFor(language)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: notoSansJp(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                text.nextLevel(snap.remainingToNextLevel),
                maxLines: 1,
                style: notoSansJp(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
// ignore: unused_element
class _RankCultureCopy extends StatelessWidget {
  final String rankName;
  final int level;
  final String title;
  final String description;

  const _RankCultureCopy({
    required this.rankName,
    required this.level,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _HeroPill(
              icon: Icons.local_fire_department_rounded,
              label: 'Level $level',
            ),
            _HeroPill(icon: Icons.military_tech_rounded, label: rankName),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: notoSerifJp(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: notoSansJp(
            fontSize: 12,
            height: 1.42,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
// ignore: unused_element
class _GamificationStrip extends StatelessWidget {
  final ScoreSnapshot snap;
  final EquippedTitle title;
  final AppText text;
  final VoidCallback onTitleTap;

  const _GamificationStrip({
    required this.snap,
    required this.title,
    required this.text,
    required this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _MiniProgressCard(
            icon: Icons.local_fire_department_rounded,
            label: text.studyStreak,
            value: text.studyStreakDays(snap.studyStreakDays),
            color: const Color(0xFFC1121F),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniProgressCard(
            icon: Icons.star_rounded,
            label: text.stageStars,
            value: '${snap.totalStars}',
            color: const Color(0xFFE6A817),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTitleTap,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      size: 18,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: notoSansJp(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      text.titleLabel(title.id, title.label),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: notoSerifJp(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalMilestone {
  final int current;
  final int target;

  const _GoalMilestone({required this.current, required this.target});

  bool get isComplete => current >= target;
  double get progress => target == 0 ? 1 : (current / target).clamp(0, 1);
}

class _MotivationGoalData {
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;
  final _GoalMilestone milestone;

  const _MotivationGoalData({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
    required this.milestone,
  });
}

// ignore: unused_element
class _MotivationGoals extends StatelessWidget {
  final ScoreSnapshot snap;
  final int totalWords;
  final StudyLanguage language;

  const _MotivationGoals({
    required this.snap,
    required this.totalWords,
    required this.language,
  });

  static const _streakMilestones = [1, 3, 7, 14, 30, 60, 100];
  static const _answeredMilestones = [10, 30, 50, 100, 300, 500, 1000, 1500];
  static const _wordMilestones = [10, 30, 50, 100, 300, 500, 1000, 1500];

  @override
  Widget build(BuildContext context) {
    final goals = [
      _MotivationGoalData(
        icon: Icons.local_fire_department_rounded,
        label: _label('streak'),
        value: _streakValue(snap.studyStreakDays),
        detail: _goalDetail(
          _nextMilestone(snap.studyStreakDays, _streakMilestones),
          'days',
        ),
        color: const Color(0xFFC1121F),
        milestone: _nextMilestone(snap.studyStreakDays, _streakMilestones),
      ),
      _MotivationGoalData(
        icon: Icons.task_alt_rounded,
        label: _label('answered'),
        value: _answeredValue(snap.totalAnswered),
        detail: _goalDetail(
          _nextMilestone(snap.totalAnswered, _answeredMilestones),
          'questions',
        ),
        color: const Color(0xFF008C9E),
        milestone: _nextMilestone(snap.totalAnswered, _answeredMilestones),
      ),
      _MotivationGoalData(
        icon: Icons.collections_bookmark_rounded,
        label: _label('words'),
        value: _wordValue(snap.mastered.length),
        detail: _goalDetail(
          _nextMilestone(
            snap.mastered.length,
            _wordMilestones.where((m) => m <= totalWords).toList(),
          ),
          'words',
        ),
        color: const Color(0xFFE6A817),
        milestone: _nextMilestone(
          snap.mastered.length,
          _wordMilestones.where((m) => m <= totalWords).toList(),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        if (isNarrow) {
          return Column(
            children: [
              for (var i = 0; i < goals.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _MotivationGoalCard(goal: goals[i]),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < goals.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _MotivationGoalCard(goal: goals[i])),
            ],
          ],
        );
      },
    );
  }

  _GoalMilestone _nextMilestone(int current, List<int> milestones) {
    final fallback = milestones.isEmpty
        ? (current == 0 ? 1 : current)
        : milestones.last;
    final target = milestones.firstWhere(
      (value) => current < value,
      orElse: () => fallback,
    );
    return _GoalMilestone(current: current, target: target);
  }

  String _label(String key) {
    return switch (language) {
      StudyLanguage.ko => switch (key) {
        'streak' => '연속 학습',
        'answered' => '문제 풀기',
        'words' => '단어 수집',
        _ => key,
      },
      StudyLanguage.ja => switch (key) {
        'streak' => '連続学習',
        'answered' => '問題達成',
        'words' => '単語収集',
        _ => key,
      },
      _ => switch (key) {
        'streak' => 'Study streak',
        'answered' => 'Problems solved',
        'words' => 'Words collected',
        _ => key,
      },
    };
  }

  String _streakValue(int days) {
    return switch (language) {
      StudyLanguage.ko => '$days일 연속 학습',
      StudyLanguage.ja => '$days日連続',
      _ => '$days day streak',
    };
  }

  String _answeredValue(int count) {
    return switch (language) {
      StudyLanguage.ko => '$count문제 풀기 달성',
      StudyLanguage.ja => '$count問達成',
      _ => '$count solved',
    };
  }

  String _wordValue(int count) {
    return switch (language) {
      StudyLanguage.ko => '$count개 단어 달성',
      StudyLanguage.ja => '$count語達成',
      _ => '$count words',
    };
  }

  String _goalDetail(_GoalMilestone milestone, String unit) {
    if (milestone.isComplete) {
      return switch (language) {
        StudyLanguage.ko => '달성',
        StudyLanguage.ja => '達成',
        _ => 'Complete',
      };
    }
    final targetText = switch ((language, unit)) {
      (StudyLanguage.ko, 'days') => '${milestone.target}일',
      (StudyLanguage.ko, 'questions') => '${milestone.target}문제',
      (StudyLanguage.ko, 'words') => '${milestone.target}개',
      (StudyLanguage.ja, 'days') => '${milestone.target}日',
      (StudyLanguage.ja, 'questions') => '${milestone.target}問',
      (StudyLanguage.ja, 'words') => '${milestone.target}語',
      (_, 'days') => '${milestone.target} days',
      (_, 'questions') => '${milestone.target} questions',
      _ => '${milestone.target} words',
    };
    return switch (language) {
      StudyLanguage.ko => '다음 목표 $targetText',
      StudyLanguage.ja => '次の目標 $targetText',
      _ => 'Next goal $targetText',
    };
  }
}

class _MotivationGoalCard extends StatelessWidget {
  final _MotivationGoalData goal;

  const _MotivationGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(goal.icon, size: 18, color: goal.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  goal.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: notoSansJp(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            goal.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: notoSerifJp(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: goal.milestone.progress,
              minHeight: 5,
              color: goal.color,
              backgroundColor: goal.color.withValues(alpha: 0.14),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: notoSansJp(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${goal.milestone.current}/${goal.milestone.target}',
                maxLines: 1,
                style: notoSansJp(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: goal.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniProgressCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniProgressCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: notoSansJp(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: notoSerifJp(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFFD166)),
          const SizedBox(width: 4),
          Text(
            label,
            style: notoSansJp(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
// ignore: unused_element
class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool alignStart;
  const _HeroMetric({
    required this.label,
    required this.value,
    // ignore: unused_element_parameter
    this.alignStart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignStart
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: notoSansJp(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.58),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: notoSerifJp(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ModeSectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final String secondaryActionLabel;
  final VoidCallback onSecondaryAction;
  const _ModeSectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.secondaryActionLabel,
    required this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: notoSerifJp(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.collections_bookmark_rounded, size: 18),
                label: Text(actionLabel, maxLines: 1),
                style: OutlinedButton.styleFrom(
                  textStyle: notoSansJp(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: onSecondaryAction,
                icon: const Icon(Icons.shuffle_rounded, size: 18),
                label: Text(
                  secondaryActionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  textStyle: notoSansJp(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ignore: unused_element
// ignore: unused_element
class _HeroDailyWord extends StatelessWidget {
  final Idiom idiom;
  final StudyLanguage language;
  final AppText text;

  const _HeroDailyWord({
    required this.idiom,
    required this.language,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text.todaysWord,
          style: notoSansJp(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFFD166),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                idiom.idiom,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: notoSerifJp(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          idiom.meaningFor(language),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: notoSerifJp(
            fontSize: 12,
            height: 1.4,
            color: Colors.white.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _RankCard extends StatelessWidget {
  final ScoreSnapshot snap;
  const _RankCard({required this.snap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final next = snap.next;
    final toGo = next == null ? 0 : next.threshold - snap.totalCorrect;
    final onP = scheme.onSurface;
    final text = AppText(StudyLanguage.ko);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _LevelBadge(level: snap.level),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  text.rankLabel(snap.rank.name),
                  style: notoSerifJp(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InlineHintsCompact(snap: snap, onColor: onP),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: snap.levelProgress,
              minHeight: 3,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                scheme.primary.withValues(alpha: 0.65),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                'Next level +${snap.remainingToNextLevel}',
                style: notoSansJp(fontSize: 9, color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              Text(
                next == null
                    ? text.maxRank
                    : text.nextRank(text.rankLabel(next.name), toGo),
                style: notoSansJp(fontSize: 9, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          if (snap.hasMarathonRecord) ...[
            const SizedBox(height: 6),
            _InlineMarathonLine(snap: snap, onColor: onP),
          ],
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final tier = levelTierFor(level);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Level',
          style: notoSansJp(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: tier.text.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '$level',
          style: notoSerifJp(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1,
            color: tier.text,
          ),
        ),
      ],
    );
  }
}

class _InlineHintsCompact extends StatelessWidget {
  final ScoreSnapshot snap;
  final Color onColor;
  const _InlineHintsCompact({required this.snap, required this.onColor});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    TextStyle small(Color c) =>
        notoSansJp(fontSize: 10, fontWeight: FontWeight.w700, color: c);
    Widget chip(IconData icon, String label, int count) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.onSurfaceVariant),
          const SizedBox(width: 2),
          Text(label, style: small(scheme.onSurfaceVariant)),
          Text('x$count', style: small(onColor)),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        chip(
          Icons.filter_alt_rounded,
          '50:50',
          snap.hints[HintKind.fiftyFifty] ?? 0,
        ),
        chip(Icons.more_time_rounded, 'Time+', snap.hints[HintKind.time] ?? 0),
      ],
    );
  }
}

class _InlineMarathonLine extends StatelessWidget {
  final ScoreSnapshot snap;
  final Color onColor;
  const _InlineMarathonLine({required this.snap, required this.onColor});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          Icons.emoji_events_outlined,
          size: 13,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 5),
        Text(
          'Marathon best',
          style: notoSansJp(fontSize: 10, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 6),
        Text(
          '${snap.bestMarathonScore} / ${snap.bestMarathonTotal}',
          style: notoSerifJp(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: onColor,
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _StatsRow extends StatelessWidget {
  final ScoreSnapshot snap;
  final int total;
  final AppText text;
  const _StatsRow({
    required this.snap,
    required this.total,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final hasMarathon = snap.lastMarathonTotal > 0;
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: text.correctCount,
            value: '${snap.totalCorrect}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: text.recentMarathon,
            value: hasMarathon
                ? '${snap.lastMarathonScore}/${snap.lastMarathonTotal}'
                : '-',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: text.wordbook,
            value: '${snap.mastered.length}/$total',
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: notoSansJp(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: notoSerifJp(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayModeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;
  final Color accentColor;
  final bool emphasized;
  final bool loading;
  final VoidCallback onTap;

  const _PlayModeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
    required this.accentColor,
    this.emphasized = false,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onColor = emphasized ? scheme.onPrimary : scheme.onSurface;
    final supportingColor = emphasized
        ? scheme.onPrimary.withValues(alpha: 0.85)
        : scheme.onSurfaceVariant;
    final iconBg = emphasized
        ? scheme.onPrimary.withValues(alpha: 0.16)
        : accentColor.withValues(alpha: 0.12);
    final iconColor = emphasized ? scheme.onPrimary : accentColor;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: loading ? null : onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: emphasized ? null : scheme.surface,
            gradient: emphasized
                ? LinearGradient(
                    colors: [scheme.primary, const Color(0xFF9E3418)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: emphasized
                ? null
                : Border.all(color: scheme.outlineVariant),
            boxShadow: emphasized
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: emphasized
                          ? onColor.withValues(alpha: 0.18)
                          : accentColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: emphasized
                              ? onColor.withValues(alpha: 0.18)
                              : accentColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: notoSansJp(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: emphasized ? onColor : accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Two lines each: Portuguese runs 15-25% longer than the
                      // English these sizes were tuned for, and a single line
                      // clipped titles like "Modo desafio aleatório".
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: notoSerifJp(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: onColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: notoSansJp(
                          fontSize: 12,
                          height: 1.4,
                          color: supportingColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: emphasized
                        ? onColor.withValues(alpha: 0.18)
                        : accentColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: loading
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: emphasized ? onColor : accentColor,
                          ),
                        )
                      : Icon(
                          Icons.play_arrow_rounded,
                          size: 24,
                          color: emphasized ? onColor : accentColor,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
