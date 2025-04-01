import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_words/main.dart';
import 'package:my_words/models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daily_task_model.dart';
import 'word.dart';

class WordsModel extends ChangeNotifier {
  List<Word> _words = [];
  List<Category> _categories = [];
  List<Word> get words => _words;
  Set<String> _achievements = {};
  int _currentExp = 0;
  int _currentLevel = 1;

  int _currentStreak = 0;
  DateTime? _lastActivityDate;

  int get currentStreak => _currentStreak;
  int get currentExp => _currentExp;
  int get currentLevel => _currentLevel;

  Map<DateTime, int> _learningStats = {};
  Map<DateTime, int> get learningStats => _learningStats;

  Map<DateTime, int> _dailyWordCounts = {};
  Map<DateTime, int> get dailyWordCounts => _dailyWordCounts;

  WordsModel() {
    fetchWords();
    _loadExpAndLevel();
    _loadLearningStats();
    _loadDailyWordCounts();
  }

  DailyTaskModel? _dailyTaskModel;

  void setDailyTaskModel(DailyTaskModel dailyTaskModel) {
    _dailyTaskModel = dailyTaskModel;
  }

  Future<void> _saveExpAndLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentExp', _currentExp);
    await prefs.setInt('currentLevel', _currentLevel);
  }

  Future<void> _loadExpAndLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentExp = prefs.getInt('currentExp') ?? 0;
    _currentLevel = prefs.getInt('currentLevel') ?? 1;
    notifyListeners();
  }

  void _addExp(int exp) {
    _currentExp += exp;
    _checkLevelUp();
    _saveExpAndLevel();
    notifyListeners();
  }

  void _checkLevelUp() {
    const expThresholds = [
      300,
      480,
      756,
      1134,
      1701,
      2551,
      3827,
      5740,
      8610,
      12915,
      19372,
      29058,
      43587,
      65380,
      98070,
      147105,
      220658,
      331012,
      496518,
      744777,
      982839,
      1312233,
      1758449,
      2343737,
      3125769,
      4170725,
      5563931,
      7421274,
      9900066,
      13260087,
      17756114,
      23799032,
      31894722,
      42740199,
      57218661,
      76668893,
      102425919,
      136901010,
      183329343,
      245195973
    ];

    while (_currentLevel <= expThresholds.length &&
        _currentExp >= expThresholds[_currentLevel - 1]) {
      _currentLevel++;
      showMotivationMessage('Level Up! You reached level $_currentLevel!');
    }
  }

  Word getRandomWord() {
    final random = Random();
    return _words[random.nextInt(_words.length)];
  }

  Future<void> _saveWords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> wordsJson =
        _words.map((word) => jsonEncode(word.toJson())).toList();
    await prefs.setStringList('wordsData', wordsJson);
  }

  Future<void> fetchWords() async {
    final prefs = await SharedPreferences.getInstance();
    final wordsData = prefs.getStringList('wordsData') ?? [];
    _words = wordsData
        .map((wordJson) => Word.fromJson(jsonDecode(wordJson)))
        .toList();
    notifyListeners();
  }

  DateTime _getTodayDate() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void addWord(Word newWord, BuildContext context) {
    if (newWord.categories.isEmpty) {
      newWord = Word(
        id: newWord.id,
        english: newWord.english,
        turkish: newWord.turkish,
        example: newWord.example,
        createdAt: DateTime.now(),
        isFavorite: newWord.isFavorite,
        categories: ['General'],
        image: newWord.image,
        definition: newWord.definition,
      );
    }
    _words.add(newWord);

    final dateKey = DateTime(
        newWord.createdAt.year, newWord.createdAt.month, newWord.createdAt.day);
    _dailyWordCounts[dateKey] = (_dailyWordCounts[dateKey] ?? 0) + 1;

    _saveWords();
    _saveDailyWordCounts();

    print(
        "Word added: ${newWord.english}, Date: ${newWord.createdAt}, Count: ${_dailyWordCounts[dateKey]}");

    checkAchievements();
    _dailyTaskModel?.updateTaskProgress('Learn new words', 1);
    _addExp(50);
    recordDailyActivity();

    notifyListeners();
  }

  void updateWord(Word updatedWord, int index) {
    _words[index] = updatedWord;
    _saveWords();
    notifyListeners();
  }

  Future<void> removeWord(Word wordToRemove) async {
    int index = _words.indexWhere((word) => word.id == wordToRemove.id);
    if (index != -1) {
      Word removedWord = _words[index];
      _words.removeAt(index);

      final dateKey = DateTime(removedWord.createdAt.year,
          removedWord.createdAt.month, removedWord.createdAt.day);
      if (_dailyWordCounts.containsKey(dateKey)) {
        _dailyWordCounts[dateKey] =
            (_dailyWordCounts[dateKey]! - 1).clamp(0, double.infinity).toInt();
        if (_dailyWordCounts[dateKey] == 0) {
          _dailyWordCounts.remove(dateKey);
        }
      }

      if (_learningStats.containsKey(dateKey)) {
        _learningStats[dateKey] =
            (_learningStats[dateKey]! - 1).clamp(0, double.infinity).toInt();
        if (_learningStats[dateKey] == 0) {
          _learningStats.remove(dateKey);
        }
      }

      await _saveWords();
      await _saveDailyWordCounts();
      await _saveLearningStats();

      notifyListeners();
    }
  }

  int getTodayAddedWordsCount() {
    final today = DateTime.now();
    return _words.where((word) {
      final wordDate = word.createdAt;
      return wordDate.year == today.year &&
          wordDate.month == today.month &&
          wordDate.day == today.day;
    }).length;
  }

  int todayWordCount() {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    DateTime todayEnd = todayStart.add(const Duration(days: 1));

    return words
        .where((word) =>
            word.createdAt.isAfter(todayStart) &&
            word.createdAt.isBefore(todayEnd))
        .length;
  }

  List<Word> get favoriteWords {
    return _words.where((word) => word.isFavorite).toList();
  }

  void toggleFavorite(Word word) {
    int index = _words.indexWhere((element) => element.id == word.id);
    if (index != -1) {
      _words[index].isFavorite = !_words[index].isFavorite;
      _saveWords();
      _saveFavorites();
      _dailyTaskModel?.updateTaskProgress('Review words', 1);
      notifyListeners();
    }
  }

  void completeQuiz() {
    _dailyTaskModel?.updateTaskProgress('Complete quizzes', 1);
  }

  Future<void> _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = _words
        .where((word) => word.isFavorite)
        .map((word) => word.id.toString())
        .toList();
    await prefs.setStringList('favoriteWords', favoriteIds);
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = prefs.getStringList('favoriteWords') ?? [];
    _words.forEach((word) {
      if (favoriteIds.contains(word.id.toString())) {
        word.isFavorite = true;
      }
    });
  }

  Future<void> _loadWords() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? wordsData = prefs.getStringList('wordsData');

      if (wordsData != null) {
        List<dynamic> wordsJson = wordsData.map(jsonDecode).toList();
        _words = wordsJson.map((json) => Word.fromJson(json)).toList();
      } else {
        _words = [];
      }
    } catch (e) {
      print('Error loading words: $e');
      _words = [];
    }
  }

  Future<void> _saveLearningStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, int> serializableMap = {};
    _learningStats.forEach((key, value) {
      serializableMap[key.toIso8601String()] = value;
    });
    await prefs.setString('learningStats', jsonEncode(serializableMap));
  }

  Future<void> _loadLearningStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic learningStatsData = prefs.get('learningStats');

    if (learningStatsData != null) {
      try {
        if (learningStatsData is String) {
          Map<String, dynamic> serializableMap = jsonDecode(learningStatsData);
          _learningStats = serializableMap
              .map((key, value) => MapEntry(DateTime.parse(key), value as int));
        } else if (learningStatsData is List) {
          _learningStats.clear();
        } else {
          print(
              "Unexpected data type for learningStats: ${learningStatsData.runtimeType}");
          _learningStats.clear();
        }
      } catch (e) {
        print("Error loading learning stats: $e");
        _learningStats.clear();
      }
    } else {
      _learningStats.clear();
    }

    notifyListeners();
  }

  Future<void> _loadDailyWordCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dailyCountsJson = prefs.getString('dailyWordCounts');
    if (dailyCountsJson != null) {
      Map<String, dynamic> loadedCounts = jsonDecode(dailyCountsJson);
      _dailyWordCounts = loadedCounts
          .map((key, value) => MapEntry(DateTime.parse(key), value as int));
    }
    notifyListeners();
  }

  Future<void> _saveDailyWordCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, int> serializableCounts = _dailyWordCounts
        .map((key, value) => MapEntry(key.toIso8601String(), value));
    await prefs.setString('dailyWordCounts', jsonEncode(serializableCounts));
  }

  List<String> getAllCategories() {
    Set<String> categories = {};
    for (var word in _words) {
      categories.addAll(word.categories);
    }
    return categories.toList();
  }

  void checkAchievements() {
    int wordCount = _words.length;
    if (15 > wordCount &&
        wordCount >= 10 &&
        !_achievements.contains('Beginner')) {
      _achievements.add('Beginner');
      showMotivationMessage('Congratulations You Saved 10 Words!');
    } else if (wordCount >= 50 && !_achievements.contains('Intermediate')) {
      _achievements.add('Intermediate');
      showMotivationMessage('Congratulations You Saved 50 Words!');
    }
  }

  List<Word> getRandomWords(int count) {
    final random = Random();
    final List<Word> randomWords = [];
    final List<Word> availableWords = List.from(_words);

    while (randomWords.length < count && availableWords.isNotEmpty) {
      final index = random.nextInt(availableWords.length);
      randomWords.add(availableWords.removeAt(index));
    }

    return randomWords;
  }

  void showMotivationMessage(String message) {
    final overlayState = navigatorKey.currentState!.overlay!;

    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                size: 48,
                color: Colors.purple,
              ),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3)).then((value) {
      overlayEntry.remove();
    });
  }

  List<String> getCategories() {
    Set<String> categories = Set<String>();
    for (var word in _words) {
      categories.addAll(word.categories);
    }
    return categories.toList();
  }

  List<Word> getWordsByCategory(String category) {
    return _words.where((word) => word.categories.contains(category)).toList();
  }

  List<Word> get allWords {
    return _words;
  }

  void addUncategorizedWord(Word word) {
    if (word.categories.isEmpty) {
      word.categories.add('General');
    }
    _words.add(word);
    notifyListeners();
  }

  Future<void> init() async {
    await _loadWords();
    await _loadFavorites();
    await _loadLearningStats();
    await _loadDailyWordCounts();
    _dailyTaskModel?.resetTasks();
    notifyListeners();
  }

  Future<void> loadStreak() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    String? lastActivityString = prefs.getString('lastActivityDate');
    if (lastActivityString != null) {
      _lastActivityDate = DateTime.parse(lastActivityString);
    }
    _updateStreak();
  }

  Future<void> _updateStreak() async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (_lastActivityDate == null) {
      _currentStreak = 1;
      _lastActivityDate = today;
    } else {
      DateTime lastActivity = DateTime(_lastActivityDate!.year,
          _lastActivityDate!.month, _lastActivityDate!.day);

      if (today == lastActivity) {
        // Activity already done today, no need to do anything
      } else if (today.difference(lastActivity).inDays == 1) {
        // Activity done yesterday, increase streak
        _currentStreak++;
      } else {
        // More than one day gap, reset streak
        _currentStreak = 1;
      }
      _lastActivityDate = today;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setString(
        'lastActivityDate', _lastActivityDate!.toIso8601String());

    notifyListeners();
  }

  Future<void> recordDailyActivity() async {
    await _updateStreak();
  }

  void updateDailyWordCounts() {
    _dailyWordCounts.clear();
    for (var word in _words) {
      final dateKey = DateTime(
          word.createdAt.year, word.createdAt.month, word.createdAt.day);
      _dailyWordCounts[dateKey] = (_dailyWordCounts[dateKey] ?? 0) + 1;
    }
    _saveDailyWordCounts();
    notifyListeners();
  }

  void resetLearningStats() {
    _learningStats.clear();
    _dailyWordCounts.clear();
    _saveLearningStats();
    _saveDailyWordCounts();
    notifyListeners();
  }

  Future<List<Word>> getPagedWords(int page, int pageSize) async {
    final startIndex = page * pageSize;
    final endIndex = (page + 1) * pageSize;

    if (startIndex >= allWords.length) {
      return [];
    }
    await Future.delayed(const Duration(milliseconds: 500));

    return allWords.sublist(startIndex, endIndex.clamp(0, allWords.length));
  }
}
