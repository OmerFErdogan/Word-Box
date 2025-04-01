import 'dart:math';
import '../models/word.dart';

class QuizState {
  List<Word> words = [];
  Word? currentQuestion;
  List<String> options = [];
  int currentIndex = -1;
  int previousIndex = -1;
  int score = 0;
  String? selectedCategory;

  int uniqueRandomInt(int max, int? previous, {int retries = 3}) {
    final rng = Random();
    int newNumber = rng.nextInt(max);
    for (int i = 0; i < retries && newNumber == previous; i++) {
      newNumber = rng.nextInt(max);
    }
    return newNumber;
  }

  void setCategory(String category) {
    selectedCategory = category;
    words.clear();
    currentQuestion = null;
    options.clear();
    score = 0;
    currentIndex = -1;
    previousIndex = -1;
  }

  void generateNewQuestion() {
    if (words.isNotEmpty) {
      int newIndex;
      do {
        newIndex = uniqueRandomInt(words.length, previousIndex);
      } while (newIndex == currentIndex);

      previousIndex = currentIndex;
      currentIndex = newIndex;
      currentQuestion = words[currentIndex];

      // Generate options
      options.clear();
      options.add(currentQuestion!.turkish.first);

      while (options.length < 4) {
        // 4 seçenek için değiştirildi
        int optionIndex = uniqueRandomInt(words.length, null);
        String randomTurkishWord = words[optionIndex].turkish.first;
        if (!options.contains(randomTurkishWord)) {
          options.add(randomTurkishWord);
        }
      }
      options.shuffle();
    } else {
      // Eğer kelimeler boşsa, yeni kelimeler yüklenene kadar bekle
      currentQuestion = null;
      options.clear();
    }
  }

  bool checkAnswer(String answer) {
    return currentQuestion?.turkish.contains(answer.toLowerCase()) ?? false;
  }

  void incrementScore() {
    score += 1;
  }

  void resetQuiz() {
    score = 0;
    currentIndex = -1;
    previousIndex = -1;
    currentQuestion = null;
    options.clear();
  }

  bool hasMoreQuestions() {
    return words.isNotEmpty && currentIndex < words.length - 1;
  }
}
