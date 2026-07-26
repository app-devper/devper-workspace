// Dart imports:
import 'dart:async';

abstract class BaseUseCaseParam<Param, Result> {
  Future<Result> call(Param param);
}

abstract class BaseUseCase<Result> {
  Future<Result> call();
}
