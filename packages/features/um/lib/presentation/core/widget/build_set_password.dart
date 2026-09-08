// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:um/domain/entities/user/user.dart';

/// Admin reset of another user's password. Unlike change-password this does
/// not ask for the current one, so it is gated behind the users screen.
void showSetPasswordDialog(
  BuildContext context, {
  required User user,
  required void Function(String password) onSubmit,
}) {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text("ตั้งรหัสผ่านให้ ${user.username}"),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "รหัสผ่านใหม่",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "กรุณากรอกรหัสผ่าน";
            if (value.length < 6) return "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text("ยกเลิก"),
        ),
        TextButton(
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            final password = controller.text;
            Navigator.of(dialogContext).pop();
            onSubmit(password);
          },
          child: const Text("บันทึก"),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}
