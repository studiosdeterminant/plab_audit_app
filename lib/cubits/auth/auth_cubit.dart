import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:surveyapp/data/repositories/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final UserRepository repository;

  AuthCubit({required this.repository})
      : super(AuthInitial());

  void getAuthState() {
    repository
        .isLoggedIn()
        .then((value) => {emit(AuthStateChanged(isAuthenticated: value))});
  }
}
