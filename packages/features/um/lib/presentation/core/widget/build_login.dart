// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/radius.dart';
import 'package:design_system/theme/spacing.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/hooks/use_app_config.dart';
import 'package:um/hooks/use_login.dart';

/// Single-column sign-in: a small brand mark, a heading, two fields and one
/// primary action, centred in a narrow column so the form reads the same on a
/// phone and on a wide monitor.
HookBuilder buildLogin(Function(System) onSuccess) {
  return HookBuilder(builder: (context) {
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();

    final usernameNode = useFocusNode();
    final passwordNode = useFocusNode();

    final obscure = useState(true);
    final config = useAppConfig();
    final login = useLogin(context, onSuccess: onSuccess);

    final textTheme = Theme.of(context).textTheme;

    void submit() {
      FocusScope.of(context).unfocus();
      login(LoginParam(
        username: usernameController.text.trim(),
        password: passwordController.text,
        system: config.system,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            width: 56,
            height: 56,
            child: Image(
              image: AssetImage(config.logo),
              // A missing brand asset should not leave a hole above the
              // heading; collapse to nothing instead.
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'ยินดีต้อนรับ',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'เข้าสู่ระบบเพื่อใช้งาน ${config.system}',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: CustomColor.font2),
        ),
        const SizedBox(height: AppSpacing.xl),
        _LoginField(
          controller: usernameController,
          focusNode: usernameNode,
          label: 'ชื่อผู้ใช้',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          onSubmitted: (_) => passwordNode.requestFocus(),
        ),
        const SizedBox(height: AppSpacing.md),
        _LoginField(
          controller: passwordController,
          focusNode: passwordNode,
          label: 'รหัสผ่าน',
          obscureText: obscure.value,
          keyboardType: TextInputType.visiblePassword,
          // Enter on the last field signs in rather than moving focus nowhere.
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => submit(),
          suffixIcon: IconButton(
            icon: Icon(
              obscure.value ? Icons.visibility_off : Icons.visibility,
              size: 20,
            ),
            color: CustomColor.font2,
            tooltip: obscure.value ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
            onPressed: () => obscure.value = !obscure.value,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          key: const Key("login"),
          style: FilledButton.styleFrom(
            backgroundColor: CustomColor.primary,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          onPressed: submit,
          child: const Text(
            'เข้าสู่ระบบ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'หากเข้าใช้งานไม่ได้ กรุณาติดต่อผู้ดูแลระบบ',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: CustomColor.font2,
            fontSize: 12,
          ),
        ),
      ],
    );
  });
}

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<String> autofillHints;
  final ValueChanged<String> onSubmitted;
  final Widget? suffixIcon;

  const _LoginField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.keyboardType,
    required this.textInputAction,
    required this.autofillHints,
    required this.onSubmitted,
    this.obscureText = false,
    this.suffixIcon,
  });

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      cursorColor: CustomColor.primary,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: CustomColor.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        enabledBorder: _border(CustomColor.divider, 1),
        border: _border(CustomColor.divider, 1),
        focusedBorder: _border(CustomColor.primary, 1.5),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
