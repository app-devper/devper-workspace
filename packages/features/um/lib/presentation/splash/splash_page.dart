// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/theme/theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/hooks/use_app_config.dart';
import 'package:um/hooks/use_keep_alive.dart';
import 'package:um/presentation/constants.dart';

class SplashPage extends HookWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewNode = useFocusNode();
    final config = useAppConfig();

    nextHome(System system) {
      if (system.systemCode == config.system) {
        Navigator.pushNamedAndRemoveUntil(context, config.home, (r) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, routeError, (r) => false);
      }
    }

    nextLogin() {
      Navigator.pushNamedAndRemoveUntil(context, routeLogin, (r) => false);
    }

    buildBody() {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 6,
          color: CustomColor.primary,
          strokeCap: StrokeCap.round,
        ),
      );
    }

    final keepAlive = useKeepAlive();
    getToken() {
      final result = keepAlive();
      result.then(nextHome).onError((error, _) => nextLogin());
    }

    useEffect(() {
      getToken();
      return () {};
    }, []);

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(viewNode),
      child: Scaffold(
        body: buildBody(),
      ),
    );
  }
}
