// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/spacing.dart';

/// Centres page content and caps its width so list and form screens stay
/// readable on desktop instead of stretching edge to edge.
class PageContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = 880,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
