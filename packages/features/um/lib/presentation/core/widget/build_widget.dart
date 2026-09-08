// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/app_colors.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void fieldFocusChange(
  BuildContext context,
  FocusNode currentFocus,
  FocusNode nextFocus,
) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

InputDecoration buildInputDecoration(
  BuildContext context,
  String labelText, {
  Widget? suffixIcon,
}) {
  final colors = AppColors.of(context);
  return InputDecoration(
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide(
        color: colors.surfaceSunken,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide(
        color: colors.surfaceSunken,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide(
        color: colors.surfaceSunken,
      ),
    ),
    focusColor: colors.textHint,
    hoverColor: colors.surfaceSunken,
    fillColor: colors.surfaceSunken,
    filled: true,
    labelText: labelText,
    labelStyle: Theme.of(context).textTheme.bodyMedium,
    suffixIcon: suffixIcon,
  );
}

SizedBox buildPasswordField(
  BuildContext context,
  FocusNode focusNode,
  TextEditingController controller,
  String labelText,
  FocusNode nextNode,
) {
  Size size = MediaQuery.of(context).size;
  final colors = AppColors.of(context);
  final state = useState(true);
  return SizedBox(
    width: size.width,
    height: 50,
    child: TextFormField(
      focusNode: focusNode,
      controller: controller,
      obscureText: state.value,
      keyboardType: TextInputType.visiblePassword,
      decoration: buildInputDecoration(
        context,
        labelText,
        suffixIcon: IconButton(
          icon: state.value ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
          color: colors.textHint,
          onPressed: () {
            state.value = !state.value;
          },
        ),
      ),
      cursorColor: colors.textHint,
      onFieldSubmitted: (term) {
        fieldFocusChange(context, focusNode, nextNode);
      },
    ),
  );
}

SizedBox buildTextFormField(
  BuildContext context,
  bool enabled,
  FocusNode focusNode,
  TextEditingController controller,
  String labelText,
  TextInputType textInputType,
  FocusNode nextNode,
) {
  final Size size = MediaQuery.of(context).size;
  final colors = AppColors.of(context);
  return SizedBox(
    width: size.width,
    height: 50,
    child: TextFormField(
      enabled: enabled,
      focusNode: focusNode,
      controller: controller,
      keyboardType: textInputType,
      decoration: buildInputDecoration(context, labelText),
      cursorColor: colors.textHint,
      onFieldSubmitted: (term) {
        fieldFocusChange(context, focusNode, nextNode);
      },
    ),
  );
}
