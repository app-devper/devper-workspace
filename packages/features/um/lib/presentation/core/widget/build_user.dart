// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/buttons.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/domain/entities/user/param.dart';
import 'package:um/domain/entities/user/user.dart';
import 'package:um/presentation/constants.dart';
import 'package:um/presentation/core/widget/build_widget.dart';

HookBuilder buildUser(User user, Function(UpdateUserParam) onClicked) {
  return HookBuilder(builder: (context) {
    final usernameEditingController = useTextEditingController();
    final firstNameEditingController = useTextEditingController();
    final lastNameEditingController = useTextEditingController();
    final emailEditingController = useTextEditingController();
    final phoneEditingController = useTextEditingController();

    final viewNode = useFocusNode();
    final usernameNode = useFocusNode();
    final firstNameNode = useFocusNode();
    final lastNameNode = useFocusNode();
    final emailNode = useFocusNode();
    final phoneNode = useFocusNode();

    setUser() {
      usernameEditingController.text = user.username;
      firstNameEditingController.text = user.firstName ?? "";
      lastNameEditingController.text = user.lastName ?? "";
      phoneEditingController.text = user.phone ?? "";
      emailEditingController.text = user.email ?? "";
    }

    useEffect(() {
      setUser();
      return () {};
    }, [user]);

    getUserParam() {
      return UpdateUserParam(
        userId: user.id,
        userParam: UserParam(
          firstName: firstNameEditingController.text,
          lastName: lastNameEditingController.text,
          phone: phoneEditingController.text,
          email: emailEditingController.text,
        ),
      );
    }

    buildUpdateButton() {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ButtonWidget(
          key: const Key("update"),
          onClicked: () {
            FocusScope.of(context).requestFocus(viewNode);
            onClicked(getUserParam());
          },
          text: "บันทึก",
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
          false,
          usernameNode,
          usernameEditingController,
          "ชื่อผู้ใช้",
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
          "ชื่อ*",
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
          "นามสกุล*",
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
        buildUpdateButton(),
      ],
    );
  });
}
