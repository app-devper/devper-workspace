// Package imports:
import 'package:common/injection.dart';

// Project imports:
import 'package:sm/data/datasource/network/sm_service.dart';
import 'package:sm/data/repositories/system_repository_impl.dart';
import 'package:sm/domain/repositories/system_repository.dart';
import 'package:sm/domain/usecase/system/create_system_use_case.dart';
import 'package:sm/domain/usecase/system/get_systems_use_case.dart';
import 'package:sm/domain/usecase/system/remove_system_by_id_use_case.dart';
import 'package:sm/domain/usecase/system/update_system_by_id_use_case.dart';
import 'package:sm/presentation/home/main/home_view_model.dart';

final sl = getIt(); // sl is referred to as Service Locator

// Dependency injection
Future<void> initSm() async {
  // ViewModel
  sl.registerFactory(
    () => HomeViewModel(
      getSystemsUseCase: sl(),
      createSystemUseCase: sl(),
      updateSystemByIdUseCase: sl(),
      removeSystemByIdUseCase: sl(),
      loginRepo: sl(),
    ),
  );

  // UseCase
  sl.registerLazySingleton(() => GetSystemsUseCase(systemRepo: sl()));
  sl.registerLazySingleton(() => CreateSystemUseCase(systemRepo: sl()));
  sl.registerLazySingleton(() => UpdateSystemByIdUseCase(systemRepo: sl()));
  sl.registerLazySingleton(() => RemoveSystemByIdUseCase(systemRepo: sl()));

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
