import 'package:html_unescape/html_unescape.dart';

class Question {
  final String question;
  final bool correctAnswer;
  final List<String> allAnswers;

  const Question(
      {required this.question,
      required this.correctAnswer,
      required this.allAnswers});

  factory Question.parseJson(Map<String, dynamic> jsonData) {
    var allAnswers = List<String>.from((jsonData['incorrect_answers']));
    allAnswers.add(jsonData['correct_answer']);

    return Question(
        question: HtmlUnescape().convert(jsonData['question'] as String),
        correctAnswer:
            (jsonData['correct_answer'] as String).toLowerCase() == 'true',
        allAnswers: allAnswers);
  }

  bool checkAnswer(bool answer) {
    return answer == correctAnswer;
  }

  @override
  String toString() {
    return question;
  }
}
