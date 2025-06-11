import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:surveyapp/data/models/user.dart';
import 'package:surveyapp/data/repositories/user.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository userRepository;

  UserCubit({required this.userRepository}) : super(UserInitial());

  Future<void> getUserInfo() async {
    emit(UserDataLoading());
    await Future.delayed(Duration(milliseconds: 50));
    userRepository.getUserData().then(
          (value) => emit(
            value is User
                ? UserDataLoaded(user: value)
                : UserDataLoadError(error: value['error']),
          ),
        );
  }

  Future<void> logInUser(String username, String password) async {
    emit(LoggingIn());
    await Future.delayed(Duration(milliseconds: 50));
    userRepository.loginUser(username, password).then(
          (value) => {
            if (value['success'])
              {
                userRepository.setLoggedIn(true), emit(LoggedIn())}
            else
              // emit(LoggedIn())
            emit(LogInError(error: value["error"]))
          },
        );
  }

  Future<void> logoutUser() async {
    emit(LoggingOut());
    await Future.delayed(Duration(milliseconds: 50));
    userRepository.logoutUser();
    userRepository.setLoggedIn(false);
    emit(LoggedOut());
  }
}
