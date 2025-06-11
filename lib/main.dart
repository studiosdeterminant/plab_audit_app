import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router/app_router.dart';

void main() {

  runApp(SurveyApp(
    router: AppRouter(),
  ));
}

class SurveyApp extends StatelessWidget {
  final AppRouter router;

  const SurveyApp({Key? key, required this.router}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: GoogleFonts.mcLarenTextTheme(Theme.of(context).textTheme)),
      onGenerateRoute: router.generateRoute,
    );
  }
}
