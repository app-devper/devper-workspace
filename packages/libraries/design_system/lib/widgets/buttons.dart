// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/radius.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: CustomColor.primary,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      onPressed: onClicked,
      child: FittedBox(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}

class ButtonIconWidget extends StatelessWidget {
  final Icon icon;
  final VoidCallback onClicked;

  const ButtonIconWidget({
    super.key,
    required this.icon,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: CustomColor.primary,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      onPressed: onClicked,
      child: FittedBox(
        child: icon,
      ),
    );
  }
}

class ButtonPrimary extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonPrimary({
    super.key,
    required this.text,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: CustomColor.primary,
        minimumSize: const Size.fromHeight(40),
        splashFactory: NoSplash.splashFactory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      onPressed: onClicked,
      child: FittedBox(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: CustomColor.buttonPrimary1Font,
          ),
        ),
      ),
    );
  }
}

class ButtonSecondary extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonSecondary({
    super.key,
    required this.text,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        splashFactory: NoSplash.splashFactory,
        minimumSize: const Size.fromHeight(40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      onPressed: onClicked,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: CustomColor.buttonSecondary1Font,
        ),
      ),
    );
  }
}
