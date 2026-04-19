import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../data/audio_service.dart';
import '../data/idiom_repository.dart';
import '../data/quiz_session.dart';
import '../data/score_service.dart';
import '../models/idiom.dart';
import 'collection_screen.dart';
import 'quiz_screen.dart';

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
  bool _muted = AudioService.instance.muted;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    AudioService.instance.playBgm(Bgm.home);
  }

  Future<void> _bootstrap() async {
    await _scoreService.grantStarterPackOnce();
    final idioms = await _repo.loadAll();
    final snap = await _scoreService.snapshot();
    if (!mounted) return;
    setState(() {
      _idioms = idioms;
      _snap = snap;
    });
  }

  Future<void> _toggleMute() async {
    final next = !_muted;
    await AudioService.instance.setMuted(next);
    // Kick BGM if it wasn't running (e.g. blocked by web autoplay policy).
    if (!next) await AudioService.instance.playBgm(Bgm.home);
    setState(() => _muted = next);
  }

  Future<void> _startQuiz(int questionCount) async {
    final idioms = _idioms;
    final snap = _snap;
    if (idioms == null || snap == null) return;
    final session = QuizSession.build(idioms, count: questionCount);
    // First user gesture after app start — safe to begin audio on web too.
    await AudioService.instance.playBgm(Bgm.quiz);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          session: session,
          initialHints: snap.hints,
        ),
      ),
    );
    // Returning here can fire while ResultScreen is still visible (because
    // Quiz→Result uses pushReplacement). BGM restoration is handled by the
    // back buttons on Result/Quiz so we don't flip it prematurely here.
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final idioms = _idioms;
    final snap = _snap;

    return Scaffold(
      appBar: AppBar(
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
                    _RankCard(snap: snap)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(
                          begin: -0.1,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 16),
                    _StatsRow(snap: snap, total: idioms.length),
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'クイズを始める'),
                    const SizedBox(height: 10),
                    _CountTile(
                      title: '10問チャレンジ',
                      subtitle: 'さくっと腕試し。',
                      icon: Icons.bolt_rounded,
                      onTap: () => _startQuiz(10),
                    ),
                    const SizedBox(height: 10),
                    _CountTile(
                      title: '20問じっくり',
                      subtitle: 'じっくり段位を狙う。',
                      icon: Icons.menu_book_rounded,
                      onTap: () => _startQuiz(20),
                    ),
                    const SizedBox(height: 10),
                    _CountTile(
                      title: '全${idioms.length}問マラソン',
                      subtitle: '収録をすべて出題。',
                      icon: Icons.emoji_events_rounded,
                      onTap: () => _startQuiz(idioms.length),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'ヒントアイテム'),
                    const SizedBox(height: 10),
                    _HintInventory(snap: snap),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        '正解するとまれにヒントがドロップします。',
                        style: notoSansJp(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: notoSerifJp(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
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

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.military_tech_rounded,
                  color: scheme.onPrimary, size: 22),
              const SizedBox(width: 8),
              Text(
                '段位',
                style: notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              Text(
                '${snap.points} pt',
                style: notoSerifJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            snap.rank.name,
            style: notoSerifJp(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: scheme.onPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: snap.progress,
              minHeight: 8,
              backgroundColor: scheme.onPrimary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                scheme.onPrimary.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            next == null
                ? '最高位に到達!'
                : '次は ${next.name} まであと $toGo 問正解',
            style: notoSansJp(
              fontSize: 12,
              color: scheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ScoreSnapshot snap;
  final int total;
  const _StatsRow({required this.snap, required this.total});

  @override
  Widget build(BuildContext context) {
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
            label: '最高連続',
            value: '${snap.bestStreak}',
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


class _CountTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _CountTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: notoSerifJp(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: notoSansJp(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintInventory extends StatelessWidget {
  final ScoreSnapshot snap;
  const _HintInventory({required this.snap});

  @override
  Widget build(BuildContext context) {
    final entries = <(HintKind, IconData, String)>[
      (HintKind.fiftyFifty, Icons.filter_alt_rounded, '50:50'),
      (HintKind.reading, Icons.record_voice_over_rounded, 'ふりがな'),
      (HintKind.kanji, Icons.visibility_rounded, '漢字一字'),
    ];
    return Row(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _HintBox(
              icon: entries[i].$2,
              label: entries[i].$3,
              count: snap.hints[entries[i].$1] ?? 0,
            ),
          ),
        ],
      ],
    );
  }
}

class _HintBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  const _HintBox({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: scheme.onSecondaryContainer),
          const SizedBox(height: 4),
          Text(
            label,
            style: notoSansJp(
              fontSize: 11,
              color: scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '×$count',
            style: notoSerifJp(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: scheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
