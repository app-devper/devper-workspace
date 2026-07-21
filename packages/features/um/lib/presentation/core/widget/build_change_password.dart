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

buildChangePassword() {
  return HookBuilder(builder: (context) {
    final snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    final oldPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final oldPasswordNode = useFocusNode();
    final newPasswordNode = useFocusNode();
    final confirmPasswordNode = useFocusNode();
    final viewNode = useFocusNode();

    success(bool success){
      Navigator.pop(context);
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
          snackBar.showErrorSnackBar("Passwords do not match");
        }
      } else {
        snackBar.hideAll();
        snackBar.showErrorSnackBar("Fields can't be empty");
      }
    }

    buildChangePasswordButton() {
      return ButtonWidget(
        key: const Key("changePassword"),
        onClicked: () {
          validate();
        },
        text: "Change Password",
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
          "Old Password*",
          newPasswordNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildPasswordField(
          context,
          newPasswordNode,
          newPasswordController,
          "New Password*",
          confirmPasswordNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildPasswordField(
          context,
          confirmPasswordNode,
          confirmPasswordController,
          "Confirm Password*",
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
