import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_text.dart';
import '../theme/app_theme.dart';
import '../data/ad_service.dart';
import '../data/audio_service.dart';
import '../data/crossword.dart';
import '../data/daily.dart';
import '../data/idiom_repository.dart';
import '../data/kanken_tier.dart';
import '../data/level_tier.dart';
import '../data/quiz_session.dart';
import '../data/score_service.dart';
import '../data/stage_plan.dart';
import '../models/idiom.dart';
import 'collection_screen.dart';
import 'crossword_stage_screen.dart';
import 'quiz_screen.dart';
import 'stage_screen.dart';

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
  CrosswordBank? _crossword;
  bool _muted = AudioService.instance.muted;
  StudyLanguage _language = StudyLanguage.ko;
  bool _languageDialogShown = false;

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
    if (!mounted) return;
    setState(() {
      _idioms = idioms;
      _snap = snap;
      _language = language;
      _plan = StagePlan.build(idioms);
      _crossword ??= CrosswordBank.build(idioms);
    });
    if (!hasLanguage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_languageDialogShown) _showLanguageDialog();
      });
    }
  }

  Future<void> _setLanguage(StudyLanguage language) async {
    await _scoreService.setStudyLanguage(language);
    if (!mounted) return;
    setState(() => _language = language);
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
                  onPressed: () async {
                    await _setLanguage(selected);
                    if (ctx.mounted) Navigator.of(ctx).pop();
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

  Future<void> _toggleMute() async {
    final next = !_muted;
    await AudioService.instance.setMuted(next);
    setState(() => _muted = next);
  }

  Future<void> _startQuiz(int questionCount, {bool isMarathon = false}) async {
    final idioms = _idioms;
    final snap = _snap;
    if (idioms == null || snap == null) return;
    final session = QuizSession.build(
      idioms,
      count: questionCount,
      language: _language,
    );
    AudioService.instance.playSfx(Sfx.modeStart, multiplier: 2.0);
    // Interstitial every few mode-starts (shares counter with round-end).
    await AdService.instance.maybeShowAfterRound(frequency: 3);
    // First user gesture after app start — safe to begin audio on web too.
    await AudioService.instance.playBgm(Bgm.quiz);
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
    // Returning here can fire while ResultScreen is still visible (because
    // Quiz→Result uses pushReplacement). BGM restoration is handled by the
    // back buttons on Result/Quiz so we don't flip it prematurely here.
    if (!mounted) return;
    await _bootstrap();
  }

  Future<void> _openCrossword() async {
    final bank = _crossword;
    if (bank == null) return;
    AudioService.instance.playSfx(Sfx.modeStart, multiplier: 2.0);
    await AdService.instance.maybeShowAfterRound(frequency: 3);
    await AudioService.instance.playBgm(Bgm.quiz);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CrosswordStageScreen(bank: bank, language: _language),
      ),
    );
    await AudioService.instance.stopBgm();
    if (!mounted) return;
    await _bootstrap();
  }

  Future<void> _openStageMode() async {
    final plan = _plan;
    if (plan == null) return;
    AudioService.instance.playSfx(Sfx.modeStart, multiplier: 2.0);
    await AdService.instance.maybeShowAfterRound(frequency: 3);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StageScreen(plan: plan, language: _language),
      ),
    );
    if (!mounted) return;
    await _bootstrap();
  }

  Future<void> _openFeedbackForm(BuildContext ctx) async {
    final url = Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLSdaNmb7JE8CWiS_4QUV0IawKI4-496jyDNBDXQa-ZDuoBX3Cw/viewform',
    );
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
    final idioms = _idioms;
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

  @override
  Widget build(BuildContext context) {
    final idioms = _idioms;
    final snap = _snap;
    final text = AppText(_language);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 8,
        leadingWidth: 48,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/favicon.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        title: Text(text.appName),
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
          IconButton(
            icon: Icon(
              _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            ),
            tooltip: _muted ? text.unmute : text.mute,
            onPressed: _toggleMute,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: text.appInfo,
            onPressed: _openAppInfoSheet,
          ),
          IconButton(
            icon: const Icon(Icons.collections_bookmark_rounded),
            tooltip: text.wordbook,
            onPressed: idioms == null ? null : _openCollection,
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
                          title: text.practiceModes,
                          actionLabel: text.wordbook,
                          onAction: _openCollection,
                        ),
                        const SizedBox(height: 10),
                        _PlayModeTile(
                          title: text.stage,
                          subtitle: text.stageSubtitle,
                          icon: Icons.quiz_rounded,
                          badge: text.recommended,
                          gradient: const [
                            Color(0xFF1D3557),
                            Color(0xFF2A9D8F),
                          ],
                          onTap: _openStageMode,
                        ),
                        const SizedBox(height: 12),
                        _PlayModeTile(
                          title: text.fiftyQuestionQuiz,
                          subtitle: text.marathonFocusedSubtitle,
                          icon: Icons.fact_check_rounded,
                          badge: '50 Q',
                          gradient: const [
                            Color(0xFFB23A48),
                            Color(0xFFF4A261),
                          ],
                          onTap: () => _startQuiz(50, isMarathon: true),
                        ),
                        const SizedBox(height: 12),
                        _PlayModeTile(
                          title: text.crossword,
                          subtitle: text.crosswordSubtitle,
                          icon: Icons.grid_on_rounded,
                          badge: text.puzzleBadge,
                          gradient: const [
                            Color(0xFF4A4E69),
                            Color(0xFF588157),
                          ],
                          onTap: _openCrossword,
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
  const _HomeHero({
    required this.snap,
    required this.total,
    required this.idioms,
    required this.language,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final next = snap.next;
    final toGo = next == null ? 0 : next.threshold - snap.totalCorrect;
    final today = idiomOfTheDay(idioms, DateTime.now());
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF182135), Color(0xFF1D3557), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D3557).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RankEmblem(level: snap.level),
              const SizedBox(width: 14),
              Expanded(
                child: _HeroDailyWord(
                  idiom: today,
                  language: language,
                  text: text,
                ),
              ),
              _HeroPill(
                icon: Icons.local_fire_department_rounded,
                label: '${text.level} ${snap.level}',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _HeroMetric(
                  label: text.rank,
                  value: snap.rank.name,
                  alignStart: true,
                ),
              ),
              _HeroMetric(
                label: text.wordbook,
                value: '${snap.mastered.length}/$total',
              ),
              const SizedBox(width: 14),
              _HeroMetric(
                label: text.correctCount,
                value: '${snap.totalCorrect}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: snap.levelProgress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.tertiary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                text.nextLevel(snap.remainingToNextLevel),
                style: notoSansJp(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
              const Spacer(),
              Text(
                next == null ? text.maxRank : text.nextRank(next.name, toGo),
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

class _RankEmblem extends StatelessWidget {
  final int level;

  const _RankEmblem({required this.level});

  @override
  Widget build(BuildContext context) {
    final tier = ((level - 1) ~/ 5).clamp(0, 4);
    final colors = switch (tier) {
      0 => const [Color(0xFFB23A48), Color(0xFFF4A261)],
      1 => const [Color(0xFFC1121F), Color(0xFFFFC857)],
      2 => const [Color(0xFF006D77), Color(0xFFFFD166)],
      3 => const [Color(0xFF7B2CBF), Color(0xFFFFC857)],
      _ => const [Color(0xFF9D0208), Color(0xFFFFD60A)],
    };
    final icon = switch (tier) {
      0 => Icons.military_tech_rounded,
      1 => Icons.workspace_premium_rounded,
      2 => Icons.emoji_events_rounded,
      3 => Icons.shield_rounded,
      _ => Icons.auto_awesome_rounded,
    };
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.38),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            child: Container(
              width: 26,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Icon(icon, color: Colors.white, size: 31),
          Positioned(
            bottom: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$level',
                style: notoSansJp(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
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

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool alignStart;
  const _HeroMetric({
    required this.label,
    required this.value,
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
  const _ModeSectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: notoSerifJp(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.collections_bookmark_rounded, size: 17),
          label: Text(actionLabel),
          style: TextButton.styleFrom(
            foregroundColor: scheme.primary,
            textStyle: notoSansJp(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

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
            const SizedBox(width: 8),
            Text(
              idiom.reading,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: notoSansJp(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.72),
                letterSpacing: 1,
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
                  snap.rank.name,
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
                next == null ? 'Max rank' : 'Next rank ${next.name} +$toGo',
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
          Text('×$count', style: small(onColor)),
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
        chip(
          Icons.record_voice_over_rounded,
          'Pron.',
          snap.hints[HintKind.reading] ?? 0,
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
        const SizedBox(width: 5),
        Text(
          '(${marathonPercentile(snap.bestMarathonScore, snap.bestMarathonTotal)})',
          style: notoSansJp(fontSize: 9, color: scheme.onSurfaceVariant),
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
                : '—',
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
  final List<Color> gradient;
  final VoidCallback onTap;

  const _PlayModeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onColor = scheme.onPrimary;
    final iconBg = scheme.onPrimary.withValues(alpha: 0.16);
    final iconColor = scheme.onPrimary;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
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
                    border: Border.all(color: onColor.withValues(alpha: 0.18)),
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
                          color: onColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: notoSansJp(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: onColor.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        maxLines: 1,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: notoSansJp(
                          fontSize: 12,
                          height: 1.4,
                          color: onColor.withValues(alpha: 0.85),
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
                    color: onColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 24,
                    color: onColor,
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
