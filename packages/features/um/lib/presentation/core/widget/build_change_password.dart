// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/buttons.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/domain/entities/user/param.dart';
import 'package:um/hooks/use_change_password.dart';
import 'package:um/presentation/core/widget/build_widget.dart';

/// [onSuccess] decides what happens after the password changes. On its own
/// page that means popping; embedded in the profile it means clearing the
/// fields and saying so, since there is nothing to pop.
HookBuilder buildChangePassword({VoidCallback? onSuccess}) {
  return HookBuilder(builder: (context) {
    final snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    final oldPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final oldPasswordNode = useFocusNode();
    final newPasswordNode = useFocusNode();
    final confirmPasswordNode = useFocusNode();
    final viewNode = useFocusNode();

    void success(bool changed) {
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      if (onSuccess != null) {
        onSuccess();
      } else {
        Navigator.pop(context);
      }
    }

    getChangePasswordParam() {
      return ChangePasswordParam(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
      );
    }

    final changePassword = useChangePassword(context, onSuccess: success);

    validate() {
      if (oldPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty) {
        if (newPasswordController.text == confirmPasswordController.text) {
          changePassword(getChangePasswordParam());
        } else {
          snackBar.hideAll();
          snackBar.showErrorSnackBar("รหัสผ่านใหม่ไม่ตรงกัน");
        }
      } else {
        snackBar.hideAll();
        snackBar.showErrorSnackBar("กรุณากรอกข้อมูลให้ครบ");
      }
    }

    buildChangePasswordButton() {
      return ButtonWidget(
        key: const Key("changePassword"),
        onClicked: () {
          validate();
        },
        text: "เปลี่ยนรหัสผ่าน",
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildPasswordField(
          context,
          oldPasswordNode,
          oldPasswordController,
          "รหัสผ่านเดิม*",
          newPasswordNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildPasswordField(
          context,
          newPasswordNode,
          newPasswordController,
          "รหัสผ่านใหม่*",
          confirmPasswordNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildPasswordField(
          context,
          confirmPasswordNode,
          confirmPasswordController,
          "ยืนยันรหัสผ่านใหม่*",
          viewNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 14),
        ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: buildChangePasswordButton(),
        ),
      ],
    );
  });
}
