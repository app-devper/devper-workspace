// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/color.dart';
import 'package:common/localizations/localizations.dart';

/// The one loading dialog for the whole product.
///
/// Both entry points render this: [showLoadingDialog] for screens that drive
/// the dialog by hand, and `useMutationAction` for the UM hooks that own their
/// own route. Keeping the body here is what stops the two from drifting apart.
class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = CommonLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(20.0),
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
      ),
    );
  }
}
