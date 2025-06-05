import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w3s/models/quiz_state.dart';
import '../models/question.dart';


class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(_initialState());

  static QuizState _initialState() {
    final questions = _getQuestions();
    return QuizState(
      questions: questions,
      userAnswers: List.filled(questions.length, null),
    );
  }

  static List<Question> _getQuestions() {
    return [
      Question(
        question: "Quel matériau peut être recyclé indéfiniment sans perdre sa qualité ?",
        options: ["Plastique", "Papier", "Verre", "Carton"],
        correctAnswerIndex: 2,
        explanation: "Le verre peut être recyclé à 100% et indéfiniment sans perdre sa qualité ni sa pureté.",
      ),
      Question(
        question: "Combien de temps faut-il pour qu'une bouteille en plastique se décompose ?",
        options: ["10 ans", "50 ans", "100 ans", "450 ans"],
        correctAnswerIndex: 3,
        explanation: "Une bouteille en plastique peut prendre jusqu'à 450 ans pour se décomposer naturellement.",
      ),
      Question(
        question: "Quel pourcentage d'énergie économise-t-on en recyclant une canette en aluminium ?",
        options: ["25%", "50%", "75%", "95%"],
        correctAnswerIndex: 3,
        explanation: "Recycler une canette en aluminium économise 95% de l'énergie nécessaire pour en produire une nouvelle.",
      ),
      Question(
        question: "Quel type de papier ne peut PAS être recyclé ?",
        options: ["Journal", "Papier ciré", "Carton", "Magazine"],
        correctAnswerIndex: 1,
        explanation: "Le papier ciré ne peut pas être recyclé car il contient un revêtement qui interfère avec le processus de recyclage.",
      ),
      Question(
        question: "Quelle couleur de bac est généralement utilisée pour le recyclage ?",
        options: ["Rouge", "Vert", "Bleu", "Jaune"],
        correctAnswerIndex: 3,
        explanation: "Le bac jaune est traditionnellement utilisé pour le recyclage dans de nombreux pays.",
      ),
      Question(
        question: "Combien de fois peut-on recycler le papier ?",
        options: ["3-5 fois", "5-7 fois", "10-12 fois", "Indéfiniment"],
        correctAnswerIndex: 1,
        explanation: "Le papier peut généralement être recyclé 5 à 7 fois avant que les fibres deviennent trop courtes.",
      ),
      Question(
        question: "Quel matériau représente le plus grand volume dans les décharges ?",
        options: ["Plastique", "Papier", "Métal", "Verre"],
        correctAnswerIndex: 1,
        explanation: "Le papier et le carton représentent environ 28% des déchets dans les décharges.",
      ),
      Question(
        question: "Que signifie le symbole de recyclage avec le chiffre 1 ?",
        options: ["PVC", "PET", "HDPE", "PP"],
        correctAnswerIndex: 1,
        explanation: "Le chiffre 1 dans le symbole de recyclage indique le PET (Polyéthylène téréphtalate), couramment utilisé pour les bouteilles d'eau.",
      ),
    ];
  }

  void selectAnswer(int answerIndex) {
    final updatedAnswers = List<int?>.from(state.userAnswers);
    updatedAnswers[state.currentQuestionIndex] = answerIndex;

    state = state.copyWith(userAnswers: updatedAnswers);
  }

  void nextQuestion() {
    if (!state.isLastQuestion) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  void completeQuiz() {
    final score = _calculateScore();
    state = state.copyWith(
      isCompleted: true,
      score: score,
    );
  }

  int _calculateScore() {
    int correctAnswers = 0;
    for (int i = 0; i < state.questions.length; i++) {
      if (state.userAnswers[i] == state.questions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }

  void resetQuiz() {
    state = _initialState();
  }

  String getScoreMessage() {
    final percentage = (state.score / state.totalQuestions * 100).round();

    if (percentage >= 80) {
      return "Excellent ! Vous êtes un expert du recyclage ! 🌟";
    } else if (percentage >= 60) {
      return "Très bien ! Vous avez de bonnes connaissances ! 👍";
    } else if (percentage >= 40) {
      return "Pas mal ! Il y a encore quelques points à améliorer. 📚";
    } else {
      return "Il faut encore apprendre ! Continuez vos efforts ! 💪";
    }
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});