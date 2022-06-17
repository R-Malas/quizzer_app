import 'package:flutter/material.dart';
import 'package:quizzer_app/core/models/category_model.dart';
import 'package:quizzer_app/core/models/question_model.dart';
import 'package:quizzer_app/screens/error_screen/error_screen.dart';
import 'package:quizzer_app/screens/get_started_screen/get_started_screen.dart';
import 'package:quizzer_app/screens/questions_screen/questions_screen.dart';
import 'package:quizzer_app/screens/splash_screen/splash_screen.dart';

class RouteManagement {
  static const String spalshScreen = '/';
  static const String getStartedScreen = '/get-started';
  static const String questionsScreen = '/questions';
  static const String error = '/error';

  RouteManagement._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    var routeName = settings.name;

    switch (routeName) {
      case spalshScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case getStartedScreen:
        if (settings.arguments != null) {
          return MaterialPageRoute(
              builder: (_) => GetStartedScreen(
                  categories: settings.arguments as List<Category>));
        }
        return MaterialPageRoute(
            builder: (_) => const ErrorScreen(
                errorMessage: 'There\'s missing data somewhere'));

      case questionsScreen:
        if (settings.arguments != null) {
          return MaterialPageRoute(
              builder: (_) => QuestionsScreen(
                    questions: settings.arguments as List<Question>,
                  ));
        }
        return MaterialPageRoute(
            builder: (_) => const ErrorScreen(
                errorMessage: 'There\'s missing data somewhere'));

      default:
        return MaterialPageRoute(
            builder: (_) => const ErrorScreen(
                errorMessage: 'Oops! looks like you took a wrong turn.'));
    }
  }
}
