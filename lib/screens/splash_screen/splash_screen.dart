import 'package:flutter/material.dart';
import 'package:quizzer_app/core/models/category_model.dart';
import 'package:quizzer_app/core/services/questions_service.dart';
import 'package:quizzer_app/screens/error_screen/error_screen.dart';
import 'package:quizzer_app/screens/get_started_screen/get_started_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  QuestionsService questionService = const QuestionsService();
  late final Future getCategories;

  @override
  void initState() {
    super.initState();
    // set future request here to prevent multiple requests on each setState call across the app
    getCategories = questionService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: getCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Image.asset(
                            'assets/img/quiz.png',
                            width: 200,
                          ),
                        ),
                        const CircularProgressIndicator(
                          color: Colors.limeAccent,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Text('Powered by',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Image.asset(
                          'assets/img/trivia_logo.png',
                          width: 90,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return ErrorScreen(errorMessage: snapshot.error.toString());
          } else if (snapshot.hasData) {
            return GetStartedScreen(
                categories: snapshot.data as List<Category>);
          } else {
            return const ErrorScreen(errorMessage: 'Something went wrong!');
          }
        },
      ),
    ));
  }
}
