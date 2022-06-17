enum Difficulty {
  easy,
  medium,
  hard,
}

String getDifficultyStringValue(Difficulty difficulty) {
  switch (difficulty) {
    case Difficulty.easy:
      return 'easy';
    case Difficulty.medium:
      return 'medium';
    case Difficulty.hard:
      return 'hard';
    default:
      return 'easy';
  }
}
