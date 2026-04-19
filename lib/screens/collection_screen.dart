import 'package:flutter/material.dart';
import '../data/idiom_images.dart';
import '../data/score_service.dart' show kMasteryThreshold;
import '../theme/app_theme.dart';
import '../models/idiom.dart';

class CollectionScreen extends StatelessWidget {
  final List<Idiom> idioms;
  final Set<String> mastered;
  final Map<String, int> correctCounts;

  const CollectionScreen({
    super.key,
    required this.idioms,
    required this.mastered,
    required this.correctCounts,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = [...idioms]
      ..sort((a, b) {
        final am = mastered.contains(a.idiom);
        final bm = mastered.contains(b.idiom);
        if (am != bm) return am ? -1 : 1;
        final d = a.difficulty.compareTo(b.difficulty);
        if (d != 0) return d;
        return a.reading.compareTo(b.reading);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text('図鑑 ${mastered.length}/${idioms.length}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: scheme.onSecondaryContainer),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '獲得条件: クイズで $kMasteryThreshold 回以上正解',
                      style: notoSansJp(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 140,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: sorted.length,
              itemBuilder: (context, i) {
                final idiom = sorted[i];
                final isMastered = mastered.contains(idiom.idiom);
                final count = correctCounts[idiom.idiom] ?? 0;
                return _CollectionCard(
                  idiom: idiom,
                  mastered: isMastered,
                  correctCount: count,
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    backgroundColor: scheme.surface,
                    builder: (_) => _IdiomSheet(
                      idiom: idiom,
                      mastered: isMastered,
                      correctCount: count,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final Idiom idiom;
  final bool mastered;
  final int correctCount;
  final VoidCallback? onTap;

  const _CollectionCard({
    required this.idiom,
    required this.mastered,
    required this.correctCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: mastered
                ? LinearGradient(
                    colors: [scheme.primary, scheme.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: mastered ? null : scheme.surface,
            border: mastered
                ? null
                : Border.all(
                    color: scheme.outlineVariant,
                    width: 1,
                  ),
            boxShadow: mastered
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      idiom.idiom,
                      style: notoSerifJp(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: mastered
                            ? scheme.onPrimary
                            : scheme.onSurface
                                .withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      idiom.reading,
                      style: notoSansJp(
                        fontSize: 12,
                        color: mastered
                            ? scheme.onPrimary.withValues(alpha: 0.85)
                            : scheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              if (mastered)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.onPrimary.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded,
                            size: 12, color: scheme.onPrimary),
                        const SizedBox(width: 2),
                        Text(
                          '獲得済み',
                          style: notoSansJp(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$correctCount / $kMasteryThreshold',
                      style: notoSansJp(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 6,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (mastered ? scheme.onPrimary : scheme.primary)
                        .withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Lv${idiom.difficulty}',
                    style: notoSansJp(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: mastered ? scheme.onPrimary : scheme.primary,
                    ),
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

class _IdiomSheet extends StatelessWidget {
  final Idiom idiom;
  final bool mastered;
  final int correctCount;
  const _IdiomSheet({
    required this.idiom,
    required this.mastered,
    required this.correctCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mastered)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded,
                        size: 14, color: scheme.onPrimaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      '獲得済み',
                      style: notoSansJp(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '未獲得 ($correctCount / $kMasteryThreshold)',
                      style: notoSansJp(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              idiom.idiom,
              style: notoSerifJp(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: 6,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              idiom.reading,
              style: notoSansJp(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
          ),
          if (IdiomImageRegistry.instance.has(idiom.idiom)) ...[
            const SizedBox(height: 14),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Image.asset(
                    IdiomImageRegistry.instance.pathFor(idiom.idiom)!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: mastered
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              idiom.meaning,
              style: notoSerifJp(
                fontSize: 15,
                height: 1.6,
                color: mastered
                    ? scheme.onPrimaryContainer
                    : scheme.onSurface,
              ),
            ),
          ),
          if (!mastered) ...[
            const SizedBox(height: 10),
            Text(
              'クイズで $kMasteryThreshold 回正解すると「獲得済み」になります。',
              style: notoSansJp(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
