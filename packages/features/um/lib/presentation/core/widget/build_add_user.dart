// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/buttons.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/domain/entities/user/param.dart';
import 'package:um/domain/entities/user/user.dart';
import 'package:um/hooks/use_add_user.dart';
import 'package:um/hooks/use_client_id.dart';
import 'package:um/presentation/constants.dart';
import 'package:um/presentation/core/widget/build_widget.dart';

HookBuilder buildAddUser(Function(User) onAdded) {
  return HookBuilder(builder: (context) {
    final usernameEditingController = useTextEditingController();
    final passwordEditingController = useTextEditingController();
    final firstNameEditingController = useTextEditingController();
    final lastNameEditingController = useTextEditingController();
    final emailEditingController = useTextEditingController();
    final phoneEditingController = useTextEditingController();

    final viewNode = useFocusNode();
    final usernameNode = useFocusNode();
    final passwordNode = useFocusNode();
    final firstNameNode = useFocusNode();
    final lastNameNode = useFocusNode();
    final emailNode = useFocusNode();
    final phoneNode = useFocusNode();
    final clientId = useClientId();

    final snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);

    clear() {
      usernameEditingController.text = "";
      passwordEditingController.text = "";
      firstNameEditingController.text = "";
      lastNameEditingController.text = "";
      phoneEditingController.text = "";
      emailEditingController.text = "";
    }

    success(User user) {
      snackBar.hideAll();
      snackBar.showSnackBar(text: "เพิ่ม ${user.username} สำเร็จ");
      clear();
      onAdded(user);
    }

    final add = useAddUser(context, onSuccess: success);

    getCreateParam() {
      return CreateParam(
        username: usernameEditingController.text,
        password: passwordEditingController.text,
        clientId: clientId,
        firstName: firstNameEditingController.text,
        lastName: lastNameEditingController.text,
        phone: phoneEditingController.text,
        email: emailEditingController.text,
      );
    }

    buildAddButton() {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ButtonWidget(
          key: const Key("add"),
          onClicked: () {
            FocusScope.of(context).requestFocus(viewNode);
            add(getCreateParam());
          },
          text: "เพิ่มผู้ใช้",
        ),
      );
    }

    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          true,
          usernameNode,
          usernameEditingController,
          "ชื่อผู้ใช้*",
          TextInputType.text,
          passwordNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          true,
          passwordNode,
          passwordEditingController,
          "รหัสผ่าน*",
          TextInputType.text,
          firstNameNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          true,
          firstNameNode,
          firstNameEditingController,
          "ชื่อ",
          TextInputType.text,
          lastNameNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          true,
          lastNameNode,
          lastNameEditingController,
          "นามสกุล",
          TextInputType.text,
          phoneNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          true,
          phoneNode,
          phoneEditingController,
          "เบอร์โทรศัพท์",
          TextInputType.phone,
          emailNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          true,
          emailNode,
          emailEditingController,
          "อีเมล",
          TextInputType.emailAddress,
          viewNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: defaultPagePadding),
        ),
        buildAddButton(),
      ],
    );
  });
}
