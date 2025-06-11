part of 'user_cubit.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class LoggingIn extends UserState {}
class LoggedIn extends UserState {}
class LogInError extends UserState {
  final String error;
  LogInError({required this.error});
}

class LoggingOut extends UserState {}
class LoggedOut extends UserState {}
class LoggedOutError extends UserState {
  final String error;
  LoggedOutError({required this.error});
}

class UserDataLoading extends UserState {}
class UserDataLoaded extends UserState {
  final User user;
  UserDataLoaded({
    required this.user,
  });
}
class UserDataLoadError extends UserState {
  final String error;
  UserDataLoadError({required this.error});
}
