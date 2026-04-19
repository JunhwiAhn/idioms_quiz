import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
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
import 'crossword_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _scoreService.grantStarterPackOnce();
    final idioms = await _repo.loadAll();
    final snap = await _scoreService.snapshot();
    if (!mounted) return;
    setState(() {
      _idioms = idioms;
      _snap = snap;
      _plan = StagePlan.build(idioms);
      _crossword ??= CrosswordBank.build(idioms);
    });
  }

  Future<void> _toggleMute() async {
    final next = !_muted;
    await AudioService.instance.setMuted(next);
    setState(() => _muted = next);
  }

  Future<void> _startQuiz(int questionCount,
      {bool isMarathon = false}) async {
    final idioms = _idioms;
    final snap = _snap;
    if (idioms == null || snap == null) return;
    final session = QuizSession.build(idioms, count: questionCount);
    AudioService.instance.playSfx(Sfx.modeStart, multiplier: 2.0);
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
    await AudioService.instance.playBgm(Bgm.quiz);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CrosswordScreen(bank: bank),
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
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StageScreen(plan: plan),
      ),
    );
    if (!mounted) return;
    await _bootstrap();
  }

  Future<void> _openCollection() async {
    final idioms = _idioms;
    final snap = _snap;
    if (idioms == null || snap == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectionScreen(
          idioms: idioms,
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

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 56,
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
        title: const Text('四字熟語クイズ'),
        actions: [
          IconButton(
            icon: Icon(_muted
                ? Icons.volume_off_rounded
                : Icons.volume_up_rounded),
            tooltip: _muted ? 'ミュート解除' : 'ミュート',
            onPressed: _toggleMute,
          ),
          IconButton(
            icon: const Icon(Icons.collections_bookmark_rounded),
            tooltip: '図鑑',
            onPressed: idioms == null ? null : _openCollection,
          ),
        ],
      ),
      body: SafeArea(
        child: (idioms == null || snap == null)
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DailyStrip(idioms: idioms),
                    const SizedBox(height: 12),
                    _RankCard(snap: snap)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(
                          begin: -0.1,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 18),
                    _PlayModeTile(
                      title: 'ステージモード',
                      subtitle: '5 ステージ × 8 ラウンド。星を集めよう。',
                      icon: Icons.stars_rounded,
                      gradient: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                      onTap: _openStageMode,
                    ),
                    const SizedBox(height: 12),
                    _PlayModeTile(
                      title: 'マラソンモード',
                      subtitle:
                          '50問解いて貴方の実力が上位○%(目安)に該当するかを確認しよう。',
                      icon: Icons.emoji_events_rounded,
                      gradient: [
                        const Color(0xFFC46A2E),
                        const Color(0xFFE6A817),
                      ],
                      onTap: () => _startQuiz(50, isMarathon: true),
                    ),
                    const SizedBox(height: 12),
                    _PlayModeTile(
                      title: 'クロスワード',
                      subtitle: '2つの熟語が漢字を共有。空きマスを埋めよう。',
                      icon: Icons.grid_on_rounded,
                      gradient: [
                        const Color(0xFF4A6FA5),
                        const Color(0xFF8CB369),
                      ],
                      onTap: _openCrossword,
                    ),
                    const SizedBox(height: 24),
                    _StatsRow(snap: snap, total: idioms.length),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DailyStrip extends StatelessWidget {
  final List<Idiom> idioms;
  const _DailyStrip({required this.idioms});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final idiom = idiomOfTheDay(idioms, now);
    final greeting = greetingFor(now);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
              Text(
                '本日の四字熟語',
                style: notoSansJp(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                idiom.idiom,
                style: notoSerifJp(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                idiom.reading,
                style: notoSansJp(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            idiom.meaning,
            style: notoSerifJp(
              fontSize: 12,
              height: 1.5,
              color: scheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '— $greeting',
            style: notoSansJp(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

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
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
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
                '次Lv +${snap.remainingToNextLevel}問',
                style: notoSansJp(
                  fontSize: 9,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                next == null
                    ? '最高段位'
                    : '次段位 ${next.name} +$toGo問',
                style: notoSansJp(
                  fontSize: 9,
                  color: scheme.onSurfaceVariant,
                ),
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
          'Lv.',
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
  const _InlineHintsCompact(
      {required this.snap, required this.onColor});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    TextStyle small(Color c) => notoSansJp(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: c,
        );
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
        chip(Icons.filter_alt_rounded, '50:50',
            snap.hints[HintKind.fiftyFifty] ?? 0),
        chip(Icons.record_voice_over_rounded, '読み',
            snap.hints[HintKind.reading] ?? 0),
        chip(Icons.more_time_rounded, '時間+',
            snap.hints[HintKind.time] ?? 0),
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
        Icon(Icons.emoji_events_outlined,
            size: 13, color: scheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(
          'マラソン自己ベスト',
          style: notoSansJp(
            fontSize: 10,
            color: scheme.onSurfaceVariant,
          ),
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
          style: notoSansJp(
            fontSize: 9,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ScoreSnapshot snap;
  final int total;
  const _StatsRow({required this.snap, required this.total});

  @override
  Widget build(BuildContext context) {
    final hasMarathon = snap.lastMarathonTotal > 0;
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: '正解数',
            value: '${snap.totalCorrect}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: '直近マラソン',
            value: hasMarathon
                ? '${snap.lastMarathonScore}/${snap.lastMarathonTotal}'
                : '—',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: '図鑑',
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
            style: notoSansJp(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
            ),
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
  final List<Color> gradient;
  final VoidCallback onTap;

  const _PlayModeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onColor = scheme.onPrimary;
    final iconBg = scheme.onPrimary.withValues(alpha: 0.2);
    final iconColor = scheme.onPrimary;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: notoSerifJp(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: onColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: onColor.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded,
                          size: 16, color: onColor),
                      const SizedBox(width: 2),
                      Text(
                        'スタート',
                        style: notoSerifJp(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: onColor,
                        ),
                      ),
                    ],
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

