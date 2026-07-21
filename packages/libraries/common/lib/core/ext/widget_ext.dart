// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/theme.dart';
import 'package:common/localizations/localizations.dart';

// Package imports:


void showLoadingDialog(BuildContext context) {
  final localizations = CommonLocalizations.of(context);
  AlertDialog alert = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          strokeWidth: 6,
          color: CustomColor.primary,
          strokeCap: StrokeCap.round,
        ),
        const Padding(padding: EdgeInsets.only(top: 10)),
        Text(
          localizations.loading,
          style: TextStyle(
            color: CustomColor.font1,
            fontSize: 16,
          ),
        ),
      ],
    ),
    contentPadding: const EdgeInsets.all(20.0),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: alert,
      );
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.pop(context);
}

void showAlertDialog(
  BuildContext context,
  String message,
  VoidCallback onConfirm,
) {
  final localizations = CommonLocalizations.of(context);
  AlertDialog alert = AlertDialog(
    title: Text(
      localizations.errorTitle,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    titlePadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
    content: Text(
      message,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
    ),
    contentPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
    actions: [
      TextButton(
        child: Text(
          localizations.okBtn,
          style: TextStyle(
            color: CustomColor.font1,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          onConfirm.call();
        },
      ),
    ],
  );
  // Show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: alert,
      );
    },
  );
}

void showConfirmDialog(
  BuildContext context,
  String message,
  VoidCallback onConfirm,
) {
  final localizations = CommonLocalizations.of(context);
  AlertDialog alert = AlertDialog(
    title: Text(
      localizations.warningTitle,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    titlePadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
    content: Text(
      message,
      style: const TextStyle(
        fontFamily: "Roboto",
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
    ),
    contentPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
    actions: [
      TextButton(
        child: Text(
          localizations.cancelBtn,
          style: TextStyle(
            color: CustomColor.font2,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      TextButton(
        child: Text(
          localizations.confirmBtn,
          style: TextStyle(
            color: CustomColor.font1,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          onConfirm.call();
        },
      ),
    ],
  );
  // Show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: alert,
      );
    },
  );
}

void fieldFocusChange(
  BuildContext context,
  FocusNode currentFocus,
  FocusNode nextFocus,
) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

Widget buildTextFormField(
  BuildContext context,
  FocusNode focusNode,
  TextEditingController controller,
  String labelText,
  TextInputType textInputType,
  FocusNode nextNode,
) {
  final Size size = MediaQuery.of(context).size;
  return SizedBox(
    width: size.width,
    height: 50,
    child: TextFormField(
      focusNode: focusNode,
      controller: controller,
      keyboardType: textInputType,
      decoration: InputDecoration(
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
        focusColor: CustomColor.hintColor,
        hoverColor: CustomColor.textFieldBackground,
        fillColor: CustomColor.textFieldBackground,
        filled: true,
        labelText: labelText,
        labelStyle: CustomTheme.mainTheme.textTheme.bodyMedium,
      ),
      cursorColor: CustomColor.hintColor,
      onFieldSubmitted: (term) {
        fieldFocusChange(context, focusNode, nextNode);
      },
    ),
  );
}

Widget buildAddressFormField(
  BuildContext context,
  FocusNode focusNode,
  TextEditingController controller,
  String labelText,
  TextInputType textInputType,
  FocusNode nextNode,
) {
  final Size size = MediaQuery.of(context).size;
  return SizedBox(
    width: size.width,
    child: TextFormField(
      minLines: 2,
      maxLines: 2,
      focusNode: focusNode,
      controller: controller,
      keyboardType: textInputType,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
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
        focusColor: CustomColor.hintColor,
        hoverColor: CustomColor.textFieldBackground,
        fillColor: CustomColor.textFieldBackground,
        filled: true,
        labelText: labelText,
        labelStyle: CustomTheme.mainTheme.textTheme.bodyMedium,
      ),
      cursorColor: CustomColor.hintColor,
      onFieldSubmitted: (term) {
        fieldFocusChange(context, focusNode, nextNode);
      },
    ),
  );
}

Widget buildTextFormFieldReadOnly(
  BuildContext context,
  FocusNode focusNode,
  TextEditingController controller,
  String labelText,
  TextInputType textInputType,
  FocusNode nextNode,
) {
  final Size size = MediaQuery.of(context).size;
  return SizedBox(
    width: size.width,
    height: 50,
    child: TextFormField(
      focusNode: focusNode,
      controller: controller,
      keyboardType: textInputType,
      readOnly: true,
      decoration: InputDecoration(
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
        focusColor: CustomColor.hintColor,
        hoverColor: CustomColor.textFieldBackground,
        fillColor: CustomColor.textFieldBackground,
        filled: true,
        labelText: labelText,
        labelStyle: CustomTheme.mainTheme.textTheme.bodyMedium,
      ),
      cursorColor: CustomColor.hintColor,
      onFieldSubmitted: (term) {
        fieldFocusChange(context, focusNode, nextNode);
      },
    ),
  );
}

extension WidgetStream<T> on Stream<T> {
  StreamBuilder<T> toWidget({required T initialData, required Widget Function(T event) widgetBuilder}) {
    return StreamBuilder(
      initialData: initialData,
      stream: this,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        return widgetBuilder(snapshot.requireData);
      },
    );
  }
}

extension WidgetFutureLoading<T> on Future<T> {
  FutureBuilder<T> toWidgetLoading({required Widget Function(T event) widgetBuilder}) {
    return FutureBuilder(
      future: this,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return Container();
        } else if (snapshot.hasData) {
          return widgetBuilder(snapshot.requireData);
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: CustomColor.primary,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
            ),
          );
        }
      },
    );
  }
}

extension WidgetErrorLoading<T> on Future<T> {
  FutureBuilder<T> toWidgetErrorLoading({required Widget Function() widgetBuilder}) {
    return FutureBuilder(
      future: this,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return widgetBuilder();
        } else if (snapshot.hasData) {
          return Container();
        } else {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: CustomColor.primary,
              strokeCap: StrokeCap.round,
            ),
          );
        }
      },
    );
  }
}
