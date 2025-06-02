class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}