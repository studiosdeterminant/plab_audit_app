import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:surveyapp/helpers/strings.dart';
import 'package:surveyapp/cubits/user/user_cubit.dart';

import 'package:surveyapp/presentation/components/rounded_button.dart';
import 'package:surveyapp/presentation/components/rounded_input_field.dart';
import 'package:surveyapp/presentation/components/rounded_password_field.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: cWhite,
        width: size.width,
        height: size.height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                "assets/images/main_top.png",
                width: size.width * 0.35,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset(
                "assets/images/login_bottom.png",
                width: size.width * 0.4,
              ),
            ),
            Login(),
          ],
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String username = "", password = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        "LOGIN",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
      SizedBox(height: size.height * 0.03),
      Image.asset(
        "assets/icons/logo.jpg",
        height: size.height * 0.35,
      ),
      SizedBox(height: size.height * 0.03),
      RoundedInputField(
        hintText: "Username",
        inputValidator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please Provide Username';
          }
          return null;
        },
        onChanged: (value) => {
          setState(() => username = value),
        },
      ),
      RoundedPasswordField(
          inputValidator: (value) {
            // RegExp regExp = new RegExp(
            //   r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[-!()_|~`:;'<>?,/{}@#$%^&*+.=\\\\\\]\\[]).{4,}$",
            //   caseSensitive: false,
            //   multiLine: false,
            // );
            //
            // if(!regExp.hasMatch(value))
            //   return "Weak Password !!";

            if (value == null || value.isEmpty) {
              return 'Password in mandatory';
            }
            return null;
          },
          onChanged: (value) => setState(() => password = value)),
      BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is LoggedIn) {
            try {
              Navigator.popAndPushNamed(context, HOME_ROUTE);
            } catch (e, stack) {
              debugPrint("Navigation Error: $e");
              debugPrint("$stack");
            }
          } else if (state is LogInError) {
            Fluttertoast.showToast(
                msg: state.error,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM);
          }
        },
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            return RoundedButton(
              child: (state is LoggingIn)
                  ? SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: cWhiteSecondary,
                        strokeWidth: 5.0,
                      ),
                    )
                  : Text(
                      "LOGIN",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
              press: () => {
                if (_formKey.currentState!.validate())
                  {
                    BlocProvider.of<UserCubit>(context)
                    // .logInUser("Y81DEEW","r6BPgGM4\$d")
                        .logInUser(username, password)
                  }
              },
            );
          },
        ),
      )
    ],
      ),
      ),
    );
  }
}
