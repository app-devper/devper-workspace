// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/spacing.dart';

/// Shown when a load fails. Distinct from [EmptyState]: an empty list means
/// there is nothing yet, this means we could not find out.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: CustomColor.disabled),
            const SizedBox(height: AppSpacing.md),
            Text(
              'โหลดข้อมูลไม่สำเร็จ',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: textTheme.bodySmall?.copyWith(color: CustomColor.font2),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('ลองใหม่'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
