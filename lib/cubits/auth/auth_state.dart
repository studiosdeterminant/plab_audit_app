part of 'auth_cubit.dart';

@immutable
abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthStateChanged extends AuthState {
  final isAuthenticated;

  AuthStateChanged({
    this.isAuthenticated,
  });

  @override
  List<Object> get props => [isAuthenticated];
}
