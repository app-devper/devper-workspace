import 'package:flutter/material.dart';
import 'package:design_system/theme/app_colors.dart';
import 'package:design_system/theme/radius.dart';

/// Search fields keep the same silhouette when focus or validation changes.
InputDecoration buildSearchDecoration(
  BuildContext context, {
  required String hintText,
  Widget? suffixIcon,
}) {
  final colors = AppColors.of(context);
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.search),
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    hintText: hintText,
    prefixIcon: const Icon(Icons.search),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: colors.surfaceSunken,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: border,
    enabledBorder: border,
    disabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: colors.textSecondary),
    ),
    errorBorder: border.copyWith(
      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 2,
      ),
    ),
  );
}
