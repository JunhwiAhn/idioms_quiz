import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/idiom.dart';

class CollectionScreen extends StatelessWidget {
  final List<Idiom> idioms;
  final Set<String> mastered;

  const CollectionScreen({
    super.key,
    required this.idioms,
    required this.mastered,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = [...idioms]
      ..sort((a, b) {
        final am = mastered.contains(a.idiom);
        final bm = mastered.contains(b.idiom);
        if (am != bm) return am ? -1 : 1;
        return a.reading.compareTo(b.reading);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text('図鑑 ${mastered.length}/${idioms.length}'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 130,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: sorted.length,
        itemBuilder: (context, i) {
          final idiom = sorted[i];
          final isMastered = mastered.contains(idiom.idiom);
          return _CollectionCard(
            idiom: idiom,
            mastered: isMastered,
            onTap: isMastered
                ? () => showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      backgroundColor: scheme.surface,
                      builder: (_) => _IdiomSheet(idiom: idiom),
                    )
                : null,
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final Idiom idiom;
  final bool mastered;
  final VoidCallback? onTap;

  const _CollectionCard({
    required this.idiom,
    required this.mastered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: mastered ? scheme.surface : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: mastered ? scheme.primary : scheme.outlineVariant,
              width: mastered ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mastered ? idiom.idiom : '???',
                style: GoogleFonts.notoSerifJp(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: mastered
                      ? scheme.onSurface
                      : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mastered ? idiom.reading : '未獲得',
                style: GoogleFonts.notoSansJp(
                  fontSize: 12,
                  color: mastered
                      ? scheme.onSurfaceVariant
                      : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  letterSpacing: 1,
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
  const _IdiomSheet({required this.idiom});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              idiom.idiom,
              style: GoogleFonts.notoSerifJp(
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
              style: GoogleFonts.notoSansJp(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              idiom.meaning,
              style: GoogleFonts.notoSerifJp(
                fontSize: 15,
                height: 1.6,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
