// Package imports:
import 'package:common/injection.dart';

// Project imports:
import 'package:sm/data/datasource/network/sm_service.dart';
import 'package:sm/data/repositories/system_repository_impl.dart';
import 'package:sm/domain/repositories/system_repository.dart';
import 'package:sm/presentation/home/main/home_view_model.dart';

final sl = getIt(); // sl is referred to as Service Locator

// Dependency injection
Future<void> initSm() async {
  // ViewModel
  sl.registerFactory(
    () => HomeViewModel(
      systemRepo: sl(),
      loginRepo: sl(),
    ),
  );

  sl.registerLazySingleton<SystemRepository>(
    () => SystemRepositoryImpl(
      service: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => SmService(
      networkConfig: sl(),
      client: sl(),
    ),
  );
}
