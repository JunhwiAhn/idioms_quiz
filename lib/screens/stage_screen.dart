import 'package:flutter/material.dart';
import '../data/score_service.dart';
import '../data/stage_plan.dart';
import '../theme/app_theme.dart';
import 'round_screen.dart';

class StageScreen extends StatefulWidget {
  final StagePlan plan;
  const StageScreen({super.key, required this.plan});

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  ScoreSnapshot? _snap;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snap = await ScoreService().snapshot();
    if (!mounted) return;
    setState(() => _snap = snap);
  }

  int _maxStarsFor(int stage) => widget.plan.roundsIn(stage) * 5;

  Future<void> _openStage(int stage) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoundScreen(
          plan: widget.plan,
          stageIndex: stage,
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final snap = _snap;
    return Scaffold(
      appBar: AppBar(title: const Text('ステージモード')),
      body: snap == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: widget.plan.stageCount,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final earned = snap.starsInStage(i);
                final max = _maxStarsFor(i);
                final prev = i == 0 ? max : snap.starsInStage(i - 1);
                final prevMax = i == 0 ? 1 : _maxStarsFor(i - 1);
                final unlocked = i == 0 || (prev / prevMax) >= 0.5;
                return _StageCard(
                  index: i,
                  earnedStars: earned,
                  maxStars: max,
                  unlocked: unlocked,
                  onTap: unlocked ? () => _openStage(i) : null,
                  scheme: scheme,
                );
              },
            ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final int index;
  final int earnedStars;
  final int maxStars;
  final bool unlocked;
  final VoidCallback? onTap;
  final ColorScheme scheme;

  const _StageCard({
    required this.index,
    required this.earnedStars,
    required this.maxStars,
    required this.unlocked,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: unlocked
          ? [
              Color.lerp(scheme.primary, scheme.tertiary, index / 4)!,
              Color.lerp(scheme.tertiary, scheme.primary, index / 4)!,
            ]
          : [
              scheme.surfaceContainerHighest,
              scheme.surfaceContainerHigh,
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final textOn = unlocked ? scheme.onPrimary : scheme.onSurfaceVariant;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    kStageTitles[index],
                    style: notoSerifJp(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textOn,
                    ),
                  ),
                  const Spacer(),
                  if (!unlocked)
                    Icon(Icons.lock_rounded, color: textOn, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                kStageSubtitles[index],
                style: notoSansJp(
                  fontSize: 12,
                  color: textOn.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                  const SizedBox(width: 4),
                  Text(
                    '$earnedStars / $maxStars',
                    style: notoSerifJp(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textOn,
                    ),
                  ),
                  const Spacer(),
                  if (unlocked)
                    Icon(Icons.chevron_right_rounded, color: textOn),
                  if (!unlocked)
                    Text(
                      '前ステージを半分以上クリアで解放',
                      style: notoSansJp(
                        fontSize: 10,
                        color: textOn.withValues(alpha: 0.85),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
