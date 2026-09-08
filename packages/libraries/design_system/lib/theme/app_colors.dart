// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/color.dart';

/// Semantic colours that differ between light and dark.
///
/// [CustomColor] stays the home of brand and status colours, which read the
/// same either way. Anything that depends on the surface underneath it —
/// backgrounds, text, borders — belongs here so widgets resolve it from the
/// theme instead of hardcoding a light value.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Page background, behind everything else.
  final Color surface;

  /// Cards, sheets and bars that sit on top of [surface].
  final Color surfaceRaised;

  /// Fill for inputs and other sunken areas.
  final Color surfaceSunken;

  /// Hairlines and outlines.
  final Color border;

  /// Body copy and headings.
  final Color textPrimary;

  /// Supporting copy: subtitles, metadata, disabled labels.
  final Color textSecondary;

  /// Placeholder text inside empty inputs.
  final Color textHint;

  const AppColors({
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
  });

  static const light = AppColors(
    surface: Color(0xFFF5F9F9),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0x1E000000),
    border: Color(0xFFE0E0E0),
    textPrimary: Color(0xDE000000),
    textSecondary: Color(0xFF979797),
    textHint: Color(0x99000000),
  );

  static const dark = AppColors(
    surface: Color(0xFF121417),
    surfaceRaised: Color(0xFF1C1F24),
    surfaceSunken: Color(0x1FFFFFFF),
    border: Color(0xFF2E3238),
    textPrimary: Color(0xFFECEDEE),
    textSecondary: Color(0xFF9BA1A6),
    textHint: Color(0x99FFFFFF),
  );

  /// Falls back to the light set so a widget still renders if a host forgot
  /// to register the extension.
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith({
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
  }) {
    return AppColors(
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
    );
  }
}

/// Brand and status colours, unchanged between the two themes.
extension AppStatusColors on AppColors {
  Color get primary => CustomColor.primary;
  Color get success => CustomColor.success;
  Color get warning => CustomColor.warning;
  Color get error => CustomColor.error;
  Color get info => CustomColor.info;
}
