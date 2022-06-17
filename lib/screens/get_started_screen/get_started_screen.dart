import 'package:flutter/material.dart';
import 'package:quizzer_app/core/models/category_model.dart';
import 'package:quizzer_app/core/models/difficulty_enum.dart';
import 'package:quizzer_app/core/models/selected_category_model.dart';
import 'package:quizzer_app/core/services/questions_service.dart';
import 'package:quizzer_app/router_management.dart';
import 'package:quizzer_app/screens/get_started_screen/widgets/criteria_dropdown_field.dart';

class GetStartedScreen extends StatefulWidget {
  final List<Category> categories;

  const GetStartedScreen({Key? key, required this.categories})
      : super(key: key);

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  var formKey = GlobalKey<FormState>();
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  SelectedGroup getData =
      SelectedGroup(categoryId: 0, difficulty: Difficulty.easy);

  QuestionsService questionService = const QuestionsService();

  @override
  void dispose() {
    isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var heightPadding = 0.009 * screenHeight;
    var widthPadding = 0.02 * screenWidth;

    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CriteriaDropdownField(
                  labelText: 'Category',
                  padding: EdgeInsets.symmetric(
                      vertical: heightPadding, horizontal: widthPadding),
                  hintText: 'Questions Category',
                  items: List<DropdownMenuItem<int>>.from(
                      widget.categories.map((item) => DropdownMenuItem<int>(
                            child: Text(item.name,
                                style: const TextStyle(color: Colors.black)),
                            value: item.id,
                          ))),
                  onChange: (value) {
                    if (value != null && !isLoading.value) {
                      setState(() {
                        getData.categoryId = value as int;
                      });
                    }
                  },
                  onSave: (value) {
                    getData.categoryId = value as int;
                  },
                ),
                CriteriaDropdownField(
                  labelText: 'Difficulty',
                  padding: EdgeInsets.symmetric(
                      vertical: heightPadding, horizontal: widthPadding),
                  hintText: 'Questions difficulty',
                  items: List<DropdownMenuItem<Difficulty>>.from(Difficulty
                      .values
                      .map((item) => DropdownMenuItem<Difficulty>(
                            child: Text(item.name,
                                style: const TextStyle(color: Colors.black)),
                            value: item,
                          ))),
                  onChange: (value) {
                    if (value != null) {
                      setState(() {
                        getData.difficulty = value as Difficulty;
                      });
                    }
                  },
                  onSave: (value) {
                    getData.difficulty = value as Difficulty;
                  },
                ),
                SizedBox(
                  height: 90,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: heightPadding, horizontal: widthPadding),
                    child: ValueListenableBuilder(
                      valueListenable: isLoading,
                      builder: (BuildContext context, bool isLoadingValue,
                              Widget? child) =>
                          ElevatedButton(
                        child: const Text('Start'),
                        style: ButtonStyle(backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey;
                            }
                            return null;
                          },
                        )),
                        onPressed: !isLoadingValue ? _onFormSubmit : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: heightPadding, horizontal: widthPadding),
                    child: ValueListenableBuilder(
                        valueListenable: isLoading,
                        builder: (BuildContext context, bool isLoadingValue,
                                Widget? child) =>
                            ElevatedButton(
                              style: ButtonStyle(backgroundColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                (states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.grey;
                                  }
                                  return Colors.pinkAccent;
                                },
                              )),
                              child: const Text('Reset Session'),
                              onPressed: !isLoadingValue ? _resetToken : null,
                            )),
                  ),
                )
              ],
            )),
      ),
    ));
  }

  _onFormSubmit() async {
    if (formKey.currentState != null) {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        isLoading.value = true;

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Please wait ...')));
        // start new session and get questions from API then pass them to Questions Screen
        try {
          var isTokenValid = await questionService.getSessionToken();
          if (!isTokenValid) {
            isLoading.value = false;
            ScaffoldMessenger.of(context).clearSnackBars();
            return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              duration: Duration(seconds: 3),
              content: Text('Couldn\'t start new session!'),
              backgroundColor: Colors.redAccent,
            ));
          }

          var getQuestions = await questionService.getQuestions(
              getData.categoryId.toString(),
              getDifficultyStringValue(getData.difficulty));
          if (getQuestions.isNotEmpty) {
            ScaffoldMessenger.of(context).clearSnackBars();
            return Navigator.of(context).pushReplacementNamed(
                RouteManagement.questionsScreen,
                arguments: getQuestions);
          }
        } catch (error) {
          isLoading.value = false;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(error.toString()),
            backgroundColor: Colors.redAccent,
          ));
        }
      }
    }
  }

  _resetToken() async {
    if (!questionService.hasSessionToken()) {
      ScaffoldMessenger.of(context).clearSnackBars();
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 3),
        content: Text('No open sessions found!'),
        backgroundColor: Colors.blue,
      ));
    }
    try {
      var res = await questionService.closeSession();
      if (res) {
        ScaffoldMessenger.of(context).clearSnackBars();
        return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 3),
          content: Text('Token was reset!'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 3),
        content: Text('something went wrong: $error'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }
}
