// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:common/core/theme/theme.dart';

class DropdownInput<T> extends StatelessWidget {
  final String hintText;
  final List<T> options;
  final T? value;
  final String Function(T) getLabel;
  final void Function(T?) onChanged;
  final bool enable;

  const DropdownInput({super.key,
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
        isDense: false,
        enabled: enable,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: Text(hintText),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: CustomColor.textFieldBackground,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: CustomColor.textFieldBackground,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: CustomColor.textFieldBackground,
          ),
        ),
        focusColor: CustomColor.textFieldBackground,
        hoverColor: CustomColor.textFieldBackground,
        fillColor: CustomColor.textFieldBackground,
        filled: true,
        labelStyle: CustomTheme.mainTheme.textTheme.bodyMedium,
      ),
      value: value,
      items: options.map((T value) {
        return DropdownMenuItem<T>(
          alignment: Alignment.centerLeft,
          value: value,
          child: Text(
            getLabel(value),
          ),
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
