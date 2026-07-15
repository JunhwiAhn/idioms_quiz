import 'package:flutter/material.dart';

/// Small, screen-local design system for the stage learning flow.
abstract final class AppUi {
  static const double cardRadius = 16;
  static const double stageMaxWidth = 900;
  static const double focusedMaxWidth = 720;
}

class AppContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  const AppContent({
    super.key,
    required this.child,
    this.maxWidth = AppUi.focusedMaxWidth,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.radius = AppUi.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class AppStarRating extends StatelessWidget {
  final int value;
  final int count;
  final double size;
  final Color? filledColor;
  final Color? emptyColor;
  final MainAxisAlignment mainAxisAlignment;

  const AppStarRating({
    super.key,
    required this.value,
    this.count = 5,
    this.size = 18,
    this.filledColor,
    this.emptyColor,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final safeValue = value.clamp(0, count);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: EdgeInsets.only(right: i == count - 1 ? 0 : size * 0.08),
            child: Icon(
              i < safeValue ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: i < safeValue
                  ? filledColor ?? const Color(0xFFF4B740)
                  : emptyColor ??
                        scheme.onSurfaceVariant.withValues(alpha: 0.34),
            ),
          ),
      ],
    );
  }
}
