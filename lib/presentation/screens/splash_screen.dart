import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:surveyapp/helpers/strings.dart';
import 'package:surveyapp/cubits/auth/auth_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<AuthCubit>(context).getAuthState();

    return Material(
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthStateChanged)
            Timer(Duration(seconds: 1), () {
              Navigator.popAndPushNamed(
                  context, (state.isAuthenticated) ? HOME_ROUTE : LOGIN_ROUTE);
            });
        },
        child: Container(
          child: Center(
            child: Text(
              "The P Lab Audit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
                letterSpacing: 2,
              ),
            ),
          ),
          color: cSecondary,
        ),
      ),
    );
  }
}
