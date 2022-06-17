import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quizzer_app/core/models/question_model.dart';
import 'package:quizzer_app/core/services/questions_service.dart';
import 'package:quizzer_app/core/utils/questions_bank.dart';
import 'package:quizzer_app/router_management.dart';
import 'package:quizzer_app/screens/questions_screen/widgets/answer_btn.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

const timeoutDuration = 30;

class QuestionsScreen extends StatefulWidget {
  final List<Question> questions;

  const QuestionsScreen({Key? key, required this.questions}) : super(key: key);

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  QuestionsService questionService = const QuestionsService();
  late QuestionBank questionBank;

  List<Icon> answers = [];
  int correctAnswers = 0;
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  // Timer
  ValueNotifier<int> timeRemaining = ValueNotifier(timeoutDuration);
  ValueNotifier<bool> cancelTimer = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    // fill question bank with question retrieved from API
    questionBank = QuestionBank(widget.questions);
    if (questionBank.questions.isNotEmpty) {
      startTimer();
    }
  }

  @override
  void dispose() {
    isLoading.dispose();
    cancelTimer.dispose();
    timeRemaining.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: questionBank.isEndOfQuestion()
              ? []
              : [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Correct Answers',
                        style: TextStyle(color: Colors.white)),
                  ),
                  LinearProgressIndicator(
                    color: Colors.lightGreen,
                    value: correctAnswers / questionBank.questions.length,
                    backgroundColor: Colors.white70,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ValueListenableBuilder(
                        valueListenable: timeRemaining,
                        builder: (BuildContext context, int timeRemainingVal,
                                Widget? child) =>
                            Text(
                          'Time remaining: ${timeRemainingVal.toString()} sec',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                  Expanded(
                      flex: 5,
                      child: Center(
                          child: Text(
                        questionBank.getCurrentQuestion().question,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                      ))),
                  ValueListenableBuilder(
                    valueListenable: isLoading,
                    builder: (BuildContext context, bool isLoadingValue,
                            Widget? child) =>
                        AnswerButton(
                            label: 'Yes',
                            color: Colors.green,
                            onPress: !isLoadingValue
                                ? () => _checkUserAnswer(true)
                                : null),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder(
                    valueListenable: isLoading,
                    builder: (BuildContext context, bool isLoadingValue,
                            Widget? child) =>
                        AnswerButton(
                            label: 'No',
                            color: Colors.redAccent,
                            onPress: !isLoadingValue
                                ? () => _checkUserAnswer(false)
                                : null),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: answers,
                      ),
                    ),
                  )
                ],
        ),
      ),
    ));
  }

  void _checkUserAnswer(bool userAnswer) {
    isLoading.value = true;

    bool isCorrectAnswer =
        questionBank.getCurrentQuestion().checkAnswer(userAnswer);

    // set answers indicator based on user's answer.
    _registerAnswer(isCorrectAnswer, true);

    // go to next question
    Timer(const Duration(seconds: 1), _goToNextQuestion);
  }

  void _registerAnswer(bool isCorrectAnswer, bool isAnswered) {
    Icon icon;
    if (isAnswered) {
      icon = Icon(isCorrectAnswer ? Icons.done : Icons.close,
          color: isCorrectAnswer ? Colors.green : Colors.redAccent);
    } else {
      icon = const Icon(Icons.remove, color: Colors.grey);
    }
    cancelTimer.value = true;

    setState(() {
      answers.add(icon);
      if (isCorrectAnswer) {
        correctAnswers++;
      }
    });
  }

  void _goToNextQuestion() {
    cancelTimer.value = false;
    timeRemaining.value = timeoutDuration;
    var correctPercent = correctAnswers * 100 / questionBank.questions.length;
    var wrongPercent =
        (answers.length - correctAnswers) * 100 / questionBank.questions.length;
    setState(() {
      questionBank.goToNextQuestion();
    });

    if (wrongPercent > 40) {
      cancelTimer.value = true;
      _showResultDialog(title: 'Sorry you lost', content: [
        Text(
          'Your wrong answers are ${wrongPercent.toStringAsFixed(0)}% of total questions.',
          softWrap: true,
        ),
        const Text(
          'This is more than 40% of total questions. better luck next time',
          softWrap: true,
        )
      ]);
    } else if (questionBank.isEndOfQuestion()) {
      cancelTimer.value = true;
      _showResultDialog(title: 'Your Results', content: [
        Text(
          'You Answered ${correctPercent.toStringAsFixed(0)}% of all questions',
          softWrap: true,
        ),
        Text(
          'Total Answered questions ${answers.length} of ${questionBank.questions.length}',
          softWrap: true,
        )
      ]);
    } else {
      isLoading.value = false;
      startTimer();
    }
  }

  void _showResultDialog(
      {required String title, required List<Widget> content}) {
    Alert(
        context: context,
        title: title,
        padding: const EdgeInsets.all(16.0),
        style: const AlertStyle(
          isCloseButton: false,
          isOverlayTapDismiss: false,
        ),
        content: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: content),
        buttons: [
          DialogButton(
              child: const Text('Continue playing',
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                answers.clear();
                correctAnswers = 0;
                ScaffoldMessenger.of(context).clearSnackBars();
                Navigator.of(context)
                    .pushReplacementNamed(RouteManagement.spalshScreen);
              }),
          DialogButton(
              child:
                  const Text('End Game', style: TextStyle(color: Colors.white)),
              color: Colors.red,
              onPressed: () {
                answers.clear();
                correctAnswers = 0;
                questionService.closeSession().then((value) {
                  if (value) {
                    return Navigator.of(context)
                        .pushReplacementNamed(RouteManagement.spalshScreen);
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    return ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(
                      backgroundColor: Colors.orangeAccent,
                      content: Text('Something went wrong, please try again'),
                      duration: Duration(seconds: 3),
                    ));
                  }
                }).catchError((error) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(error.toString()),
                    backgroundColor: Colors.redAccent,
                  ));
                });
              })
        ]).show();
  }

  void startTimer() async {
    const duration = Duration(seconds: 1);
    Timer.periodic(duration, (Timer t) {
      if (timeRemaining.value < 1) {
        isLoading.value = true;
        t.cancel();
        _registerAnswer(false, false);

        // go to next question
        Timer(const Duration(seconds: 1), _goToNextQuestion);
      } else if (cancelTimer.value == true) {
        t.cancel();
      } else {
        timeRemaining.value--;
      }
    });
  }
}
