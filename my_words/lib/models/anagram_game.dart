import 'dart:math';
import 'package:my_words/models/word.dart';

class AnagramGame {
  final List<Word> words;

  AnagramGame(this.words);

  Word getRandomWord() {
    final random = Random();
    return words[random.nextInt(words.length)];
  }

  String shuffleWord(String word) {
    final List<String> characters = word.split('');
    characters.shuffle();
    return characters.join('');
  }

  bool checkAnagram(String originalWord, String userWord) {
    final originalSorted = originalWord.split('')..sort();
    final userSorted = userWord.split('')..sort();
    return originalSorted.join('') == userSorted.join('');
  }
}
