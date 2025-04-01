import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_words/models/words_model.dart';
import 'package:my_words/models/word.dart';
import 'package:my_words/models/theme_model.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum Difficulty { easy, medium, hard }

class AnagramGameScreen extends StatefulWidget {
  @override
  _AnagramGameScreenState createState() => _AnagramGameScreenState();
}

class _AnagramGameScreenState extends State<AnagramGameScreen> {
  late Word currentWord;
  late List<String> shuffledLetters;
  late List<String?> answerLetters;
  int score = 0;
  Difficulty difficulty = Difficulty.medium;
  late Timer _timer;
  int _timeLeft = 60;
  int _hintCount = 3;
  int _consecutiveCorrect = 0;
  int _totalWords = 0;
  bool _isInitialized = false;
  String? _errorMessage;
  List<Word> _usedWords = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration.zero, () {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeGame() async {
    final wordsModel = Provider.of<WordsModel>(context, listen: false);
    await wordsModel.fetchWords();
    if (mounted) {
      _nextWord();
    }
  }

  void _nextWord() {
    final wordsModel = Provider.of<WordsModel>(context, listen: false);
    List<Word> words = [];
    int minLength = 0;
    int maxLength = 100;

    switch (difficulty) {
      case Difficulty.easy:
        minLength = 3;
        maxLength = 5;
        break;
      case Difficulty.medium:
        minLength = 6;
        maxLength = 8;
        break;
      case Difficulty.hard:
        minLength = 9;
        maxLength = 100;
        break;
    }

    words = wordsModel.words
        .where((word) =>
            word.english.length >= minLength &&
            word.english.length <= maxLength)
        .toList();

    if (words.isEmpty) {
      words = wordsModel.words;
    }

    if (words.isNotEmpty) {
      if (_usedWords.length == words.length) {
        _usedWords.clear();
      }
      Word newWord;
      do {
        newWord = words[Random().nextInt(words.length)];
      } while (_usedWords.contains(newWord));
      _usedWords.add(newWord);

      setState(() {
        currentWord = newWord;
        shuffledLetters = currentWord.english.split('')..shuffle();
        answerLetters = List.filled(currentWord.english.length, null);
        _totalWords++;
        _isInitialized = true;
        _errorMessage = null;
      });
      _resetTimer();
    } else {
      setState(() {
        _errorMessage = 'No words available. Please add some words first.';
        _isInitialized = false;
      });
    }
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _timeLeft = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _showResultDialog(false);
        }
      });
    });
  }

  void _addLetter(String letter) {
    if (mounted) {
      setState(() {
        int emptyIndex = answerLetters.indexOf(null);
        if (emptyIndex != -1) {
          answerLetters[emptyIndex] = letter;
          shuffledLetters.remove(letter);
        }
      });
      _checkAnswer();
    }
  }

  void _removeLetter(int index) {
    if (mounted) {
      setState(() {
        if (answerLetters[index] != null) {
          shuffledLetters.add(answerLetters[index]!);
          answerLetters[index] = null;
        }
      });
    }
  }

  void _checkAnswer() {
    if (!answerLetters.contains(null)) {
      String answer = answerLetters.join();
      if (answer.toLowerCase() == currentWord.english.toLowerCase()) {
        setState(() {
          score += _calculateScore();
          _consecutiveCorrect++;
        });
        _showResultDialog(true);
      } else {
        _showResultDialog(false);
      }
    }
  }

  int _calculateScore() {
    int baseScore = difficulty == Difficulty.easy
        ? 10
        : (difficulty == Difficulty.medium ? 20 : 30);
    int timeBonus = _timeLeft;
    int streakBonus = _consecutiveCorrect * 5;
    return baseScore + timeBonus + streakBonus;
  }

  void _showResultDialog(bool isCorrect) {
    _timer.cancel();
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeModel.currentTheme.dialogBackgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text(isCorrect ? 'Correct!' : 'Time\'s up!',
              style: themeModel.currentTheme.textTheme.titleLarge?.copyWith(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  isCorrect
                      ? 'You guessed it right!'
                      : 'The correct word was: ${currentWord.english}',
                  style: themeModel.currentTheme.textTheme.bodyLarge),
              SizedBox(height: 20.h),
              _buildScoreRow(
                  'Score', '${isCorrect ? "+${_calculateScore()}" : "+0"}'),
              _buildScoreRow('Total Score', '$score'),
              _buildScoreRow('Consecutive Correct', '$_consecutiveCorrect'),
              _buildScoreRow('Total Words', '$_totalWords'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Next Word',
                  style: themeModel.currentTheme.textTheme.labelLarge?.copyWith(
                    color: themeModel.currentTheme.colorScheme.primary,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
                _nextWord();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreRow(String label, String value) {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: themeModel.currentTheme.textTheme.bodyMedium),
          Text(value,
              style: themeModel.currentTheme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _useHint() {
    if (_hintCount > 0) {
      setState(() {
        _hintCount--;
        int emptyIndex = answerLetters.indexOf(null);
        if (emptyIndex != -1) {
          String correctLetter = currentWord.english[emptyIndex];
          answerLetters[emptyIndex] = correctLetter;
          shuffledLetters.remove(correctLetter);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Anagram Game',
                style: themeModel.currentTheme.appBarTheme.titleTextStyle),
            backgroundColor:
                themeModel.currentTheme.appBarTheme.backgroundColor,
            actions: [
              PopupMenuButton<Difficulty>(
                onSelected: (Difficulty result) {
                  setState(() {
                    difficulty = result;
                    _nextWord();
                  });
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<Difficulty>>[
                  PopupMenuItem<Difficulty>(
                    value: Difficulty.easy,
                    child: Text('Easy',
                        style: themeModel.currentTheme.textTheme.bodyMedium),
                  ),
                  PopupMenuItem<Difficulty>(
                    value: Difficulty.medium,
                    child: Text('Medium',
                        style: themeModel.currentTheme.textTheme.bodyMedium),
                  ),
                  PopupMenuItem<Difficulty>(
                    value: Difficulty.hard,
                    child: Text('Hard',
                        style: themeModel.currentTheme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ],
          ),
          body: !_isInitialized ? _buildLoadingScreen() : _buildGameContent(),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    final themeModel = Provider.of<ThemeModel>(context);
    return Center(
      child: _errorMessage != null
          ? Text(_errorMessage!,
              style: themeModel.currentTheme.textTheme.bodyLarge)
          : CircularProgressIndicator(
              color: themeModel.currentTheme.colorScheme.primary),
    );
  }

  Widget _buildGameContent() {
    final themeModel = Provider.of<ThemeModel>(context);
    return Container(
      color: themeModel.currentTheme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Score: $score',
                  style: themeModel.currentTheme.textTheme.headlineMedium),
              SizedBox(height: 10.h),
              _buildTimerIndicator(),
              SizedBox(height: 10.h),
              Text('Hints: $_hintCount',
                  style: themeModel.currentTheme.textTheme.titleMedium
                      ?.copyWith(color: Colors.green)),
              SizedBox(height: 20.h),
              _buildAnswerContainer(),
              SizedBox(height: 40.h),
              _buildShuffledLetters(),
              SizedBox(height: 20.h),
              _buildHintButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerIndicator() {
    return Container(
      width: double.infinity,
      height: 10.h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: FractionallySizedBox(
        widthFactor: _timeLeft / 60,
        child: Container(
          decoration: BoxDecoration(
            color: _timeLeft > 10 ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerContainer() {
    final themeModel = Provider.of<ThemeModel>(context);
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        border: Border.all(color: themeModel.currentTheme.colorScheme.primary),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 5.w,
        runSpacing: 5.h,
        children: List.generate(
          answerLetters.length,
          (index) => InkWell(
            onTap: () => _removeLetter(index),
            child: Container(
              width: 30.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: themeModel.currentTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Center(
                child: Text(
                  answerLetters[index] ?? '',
                  style: themeModel.currentTheme.textTheme.titleLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShuffledLetters() {
    final themeModel = Provider.of<ThemeModel>(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10.w,
      runSpacing: 10.h,
      children: shuffledLetters
          .map((letter) => InkWell(
                onTap: () => _addLetter(letter),
                child: Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: themeModel.currentTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: themeModel.currentTheme.textTheme.titleLarge
                          ?.copyWith(
                              color: themeModel
                                  .currentTheme.colorScheme.onPrimary),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildHintButton() {
    final themeModel = Provider.of<ThemeModel>(context);
    return ElevatedButton.icon(
      onPressed: _hintCount > 0 ? _useHint : null,
      icon: const Icon(Icons.lightbulb),
      label: const Text('Use Hint'),
      style: ElevatedButton.styleFrom(
        foregroundColor: themeModel.currentTheme.colorScheme.onSecondary,
        backgroundColor: themeModel.currentTheme.colorScheme.secondary,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
      ),
    );
  }
}
