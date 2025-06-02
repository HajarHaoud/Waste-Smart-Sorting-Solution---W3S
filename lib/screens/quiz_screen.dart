import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final quizNotifier = ref.read(quizProvider.notifier);

    if (quizState.isCompleted) {
      return _buildResultScreen(context, quizState, quizNotifier);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Quiz Recyclage',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgressBar(quizState),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _buildQuestionCard(context, quizState, quizNotifier),
            ),
          ),
          _buildNavigationButtons(quizState, quizNotifier),
        ],
      ),
    );
  }

  Widget _buildProgressBar(QuizState quizState) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${quizState.currentQuestionIndex + 1}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
              ),
              Text(
                '${quizState.currentQuestionIndex + 1}/${quizState.totalQuestions}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: quizState.progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuizState quizState, QuizNotifier quizNotifier) {
    final question = quizState.currentQuestion;
    final selectedAnswer = quizState.userAnswers[quizState.currentQuestionIndex];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            SizedBox(height: 16),
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedAnswer == index;

              return Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => quizNotifier.selectAnswer(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey[300]!,
                          width: 2,
                        ),
                        color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? Colors.green : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? Colors.green : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(Icons.check, color: Colors.white, size: 14)
                                : null,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? Colors.green[700] : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(QuizState quizState, QuizNotifier quizNotifier) {
    final canGoNext = quizState.userAnswers[quizState.currentQuestionIndex] != null;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          if (quizState.currentQuestionIndex > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: quizNotifier.previousQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[700],
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Précédent', style: TextStyle(fontSize: 14)),
              ),
            ),
          if (quizState.currentQuestionIndex > 0) SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canGoNext
                  ? () {
                if (quizState.isLastQuestion) {
                  quizNotifier.completeQuiz();
                } else {
                  quizNotifier.nextQuestion();
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canGoNext ? Colors.green : Colors.grey[300],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                quizState.isLastQuestion ? 'Terminer' : 'Suivant',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, QuizState quizState, QuizNotifier quizNotifier) {
    final percentage = (quizState.score / quizState.totalQuestions * 100).round();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getScoreColor(percentage).withOpacity(0.2),
                ),
                child: Icon(_getScoreIcon(percentage), size: 48, color: _getScoreColor(percentage)),
              ),
              SizedBox(height: 20),
              Text('Quiz Terminé !', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Score : ${quizState.score}/${quizState.totalQuestions}', style: TextStyle(fontSize: 18)),
              Text('$percentage%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getScoreColor(percentage))),
              SizedBox(height: 20),
              Text(
                quizNotifier.getScoreMessage(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: quizNotifier.resetQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.grey[700],
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Recommencer', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Terminer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(int percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 60) return Icons.thumb_up;
    if (percentage >= 40) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }
}
