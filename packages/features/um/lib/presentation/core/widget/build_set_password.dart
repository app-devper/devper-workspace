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
      title: Text("Set password for ${user.username}"),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "New password",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Password is required";
            if (value.length < 6) return "Use at least 6 characters";
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            final password = controller.text;
            Navigator.of(dialogContext).pop();
            onSubmit(password);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}
