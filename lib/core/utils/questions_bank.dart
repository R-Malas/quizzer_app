import '../models/question_model.dart';

/// Questions from API
class QuestionBank {
  int currentIndex = 0; // track current question index
  late List<Question> questions;

  QuestionBank(this.questions);

  bool isEndOfQuestion() {
    return currentIndex == questions.length;
  }

  void goToNextQuestion() {
    if (!isEndOfQuestion()) {
      currentIndex++;
    }
  }

  Question getCurrentQuestion() {
    return questions[currentIndex];
  }
}

/// if questions are hardcoded, use this class
// class InternalQuestionBank {
//   int currentIndex = 0;
//
//   List<Question> questions = [];
//
//   bool isEndOfQuestion() {
//     if (currentIndex >= questions.length - 1) {
//       currentIndex = 0;
//       questions.shuffle();
//       return true;
//     }
//     return false;
//   }
//
//   void goToNextQuestion() {
//     if (!isEndOfQuestion()) {
//       currentIndex++;
//     }
//   }
//
//   String getQuestionText() {
//     return questions[currentIndex].text;
//   }
//
//   bool getQuestionAnswer() {
//     return questions[currentIndex].correctAnswer;
//   }
// }
