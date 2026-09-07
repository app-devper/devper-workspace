// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/config/app_config.dart';
import 'package:common/config/network_config.dart';
import 'package:common/core/navigation/app_navigator.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:common/core/network/http_logging_interceptor.dart';
import 'package:common/core/network/unauthorized_interceptor.dart';
import 'package:common/injection.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:um/app_network_config.dart';
import 'package:um/data/datasource/local/shared_prefs_token_storage.dart';
import 'package:um/data/datasource/local/token_storage.dart';
import 'package:um/data/datasource/network/um_service.dart';
import 'package:um/data/datasource/session/app_session.dart';
import 'package:um/data/datasource/session/keep_alive_scheduler.dart';
import 'package:um/data/repositories/login_repository_impl.dart';
import 'package:um/data/repositories/user_repository_impl.dart';
import 'package:um/domain/repositories/login_repository.dart';
import 'package:um/domain/repositories/user_repository.dart';
import 'package:um/presentation/constants.dart';

final sl = getIt();

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    if (kDebugMode) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    }
  });
}

Future<void> initCore(AppConfig config) async {
  sl.registerLazySingleton(() => config);

  sl.registerLazySingleton<AppSession>(() => AppSession(sl()));

  sl.registerLazySingleton<NetworkConfig>(() => AppNetworkConfig(appSession: sl()));

  final client = CustomClient();
  client.addInterceptor(HttpLoggingInterceptor());
  sl.registerLazySingleton<CustomClient>(() => client);

  sl.registerLazySingleton<TokenStorage>(
    () => SharedPrefsTokenStorage(
      sharedPreferences: sl(),
    ),
  );

  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}

Future<void> initUm() async {
  sl.registerLazySingleton<KeepAliveScheduler>(
    () => KeepAliveScheduler(
      onTick: () => sl<LoginRepository>().keepAlive(),
    ),
  );

  sl.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(
      service: sl(),
      tokenStorage: sl(),
      appSession: sl(),
      keepAliveScheduler: sl(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      service: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => UmService(
      networkConfig: sl(),
      client: sl(),
    ),
  );

  sl<CustomClient>().addInterceptor(
    UnauthorizedInterceptor(onUnauthorized: _onUnauthorized),
  );
}

Future<void> _onUnauthorized() async {
  sl<KeepAliveScheduler>().stop();
  await sl<TokenStorage>().clear();
  sl<AppSession>().clear();
  resetToRoute(routeLogin);
}
