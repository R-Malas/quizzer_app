import 'package:quizzer_app/core/models/difficulty_enum.dart';

class SelectedGroup {
  late int categoryId;
  late Difficulty difficulty;

  SelectedGroup({required this.categoryId, required this.difficulty});
}
