import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surveyapp/cubits/retrySub/retry_sub_cubit.dart';
import 'package:surveyapp/cubits/search/search_cubit.dart';
import 'package:surveyapp/data/models/store.dart';
import 'package:surveyapp/helpers/strings.dart';
import 'package:surveyapp/cubits/auth/auth_cubit.dart';
import 'package:surveyapp/cubits/stores/stores_cubit.dart';
import 'package:surveyapp/cubits/user/user_cubit.dart';
import 'package:surveyapp/cubits/form/form_cubit.dart';
import 'package:surveyapp/data/network_services/form.dart';
import 'package:surveyapp/data/network_services/store.dart';
import 'package:surveyapp/data/network_services/user.dart';
import 'package:surveyapp/data/repositories/form.dart';
import 'package:surveyapp/data/repositories/store.dart';
import 'package:surveyapp/data/repositories/user.dart';
import 'package:surveyapp/presentation/screens/form_screen.dart';
import 'package:surveyapp/presentation/screens/home_screen.dart';
import 'package:surveyapp/presentation/screens/login_screen.dart';
import 'package:surveyapp/presentation/screens/search_filter_dialog.dart';
import 'package:surveyapp/presentation/screens/splash_screen.dart';
import 'package:surveyapp/presentation/screens/add_store_screen.dart';

import '../presentation/screens/add_store_screen.dart';

class AppRouter {
  late final UserRepository userRepository;
  late final StoreRepository storeRepository;
  late final FormRepository formRepository;

  late final AuthCubit authCubit;
  late final StoresCubit storesCubit;
  late final UserCubit userCubit;
  late final StoreFormCubit formCubit;
  late final RetrySubCubit retrySubCubit;

  late final HomeScreen _homeScreen;
  late final SplashScreen _splashScreen;
  late final LoginScreen _loginScreen;

  AppRouter() {
    userRepository = UserRepository(userNetworkService: UserNetworkService());
    storeRepository = StoreRepository(networkService: StoreNetworkService());
    formRepository = FormRepository(formNetworkService: FormNetworkService());

    authCubit = AuthCubit(repository: userRepository);
    storesCubit = StoresCubit(storeRepository: storeRepository);
    userCubit = UserCubit(userRepository: userRepository);
    formCubit = StoreFormCubit(formRepository: formRepository);
    retrySubCubit = RetrySubCubit(formRepository: formRepository);

    _homeScreen = HomeScreen();
    _splashScreen = SplashScreen();
    _loginScreen = LoginScreen();
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HOME_ROUTE:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: userCubit),
              BlocProvider.value(value: storesCubit),
              BlocProvider.value(value: retrySubCubit),
            ],
            child: _homeScreen,
          ),
        );
      case LOGIN_ROUTE:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: userCubit),
              BlocProvider.value(value: authCubit)
            ],
            child: _loginScreen,
          ),
        );
      case SPLASH_ROUTE:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [BlocProvider.value(value: authCubit)],
            child: _splashScreen,
          ),
        );
      case FORM_ROUTE:
        final Map data = settings.arguments as Map;
        final String sid = data['storeId'];
        final String storeName = data['storeName'];

        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider(
                          create: (context) =>
                              StoreFormCubit(formRepository: formRepository)),
                    ],
                    child: FormScreen(
                      sid: sid,
                      storeName: storeName,
                    )));
      case SEARCH_DIALOG:
        final List<Store> stores = settings.arguments as List<Store>;
        return MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: storesCubit),
                    BlocProvider.value(
                      value: SearchCubit(stores: stores),
                    ),
                  ],
                  child: SearchFilter(),
                ),
        );
      case ADD_STORE_ROUTE:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: storesCubit,
            child: AddStoreScreen(),
          ),
        );

      default:
        return null;
    }
  }
}
