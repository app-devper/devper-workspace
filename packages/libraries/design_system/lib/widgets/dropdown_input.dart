// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/app_colors.dart';

class DropdownInput<T> extends StatelessWidget {
  final String hintText;
  final List<T> options;
  final T? value;
  final String Function(T) getLabel;
  final void Function(T?) onChanged;
  final bool enable;

  const DropdownInput({
    super.key,
    this.hintText = '',
    this.options = const [],
    required this.getLabel,
    required this.value,
    required this.onChanged,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isDense: false,
      isExpanded: true,
      elevation: 1,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: InputDecoration(
        enabled: enable,
        labelText: hintText,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.of(context).textSecondary,
        ),
      ),
      dropdownColor: AppColors.of(context).surfaceRaised,
      borderRadius: BorderRadius.circular(16),
      initialValue: value,
      items: options.map((T value) {
        return DropdownMenuItem<T>(
          alignment: Alignment.centerLeft,
          value: value,
          child: Text(getLabel(value)),
        );
      }).toList(),
      onChanged: (value) {
        if (enable) {
          onChanged.call(value);
        }
      },
    );
  }
}
