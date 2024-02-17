abstract class HomeState {}

class LoadingState extends HomeState {}

class LoggedState extends HomeState {
  final bool isAdmin;

  LoggedState(this.isAdmin);
}

class SystemState extends HomeState {

}

class ErrorState extends HomeState {
  final String message;

  ErrorState(this.message);
}

class LogoutState extends HomeState {}
