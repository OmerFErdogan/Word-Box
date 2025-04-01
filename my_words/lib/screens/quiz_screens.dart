import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../models/theme_model.dart';
import '../models/words_model.dart';
import '../models/daily_task_model.dart';
import '../states/quiz_state.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late QuizState _quizState;
  int _timeLeft = 9;
  Timer? _timer;
  bool _gameOver = false;
  String _gameOverReason = '';
  bool _isScoreAnimating = false;
  String? _selectedCategory;
  static const int _targetScore = 10;
  bool _dailyTaskCompleted = false;

  @override
  void initState() {
    super.initState();
    _quizState = QuizState();
  }

  @override
  void dispose() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer!.cancel();
        _endGame('Time\'s up!');
      }
    });
  }

  void _endGame(String reason) {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    setState(() {
      _gameOver = true;
      _gameOverReason = reason;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _gameOver = true;
      });
      Provider.of<DailyTaskModel>(context, listen: false)
          .updateTaskProgress('Complete quizzes', 1);
    });
  }

  void _restartGame() {
    setState(() {
      _quizState.resetQuiz();
      _timeLeft = 9;
      _gameOver = false;
      _gameOverReason = '';
    });
    _quizState.generateNewQuestion();
    _startTimer();
  }

  void _animateScore() {
    setState(() {
      _isScoreAnimating = true;
    });
    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _isScoreAnimating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    ThemeData themeData = themeModel.currentTheme;
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return WillPopScope(
      onWillPop: () async {
        if (!_gameOver) {
          _endGame('Quiz aborted');
        }
        if (_timer != null && _timer!.isActive) {
          _timer!.cancel();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: themeData.scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: themeData.iconTheme.color),
            onPressed: () {
              if (!_gameOver) {
                _endGame('Quiz aborted');
              }
              Navigator.of(context).pop();
            },
          ),
          title: Text('QUIZ',
              style: TextStyle(
                  color: themeData.textTheme.titleLarge?.color,
                  fontSize: isSmallScreen ? 28 : 36)),
        ),
        body: Consumer2<WordsModel, DailyTaskModel>(
          builder: (context, wordsModel, dailyTaskModel, child) {
            if (wordsModel.words.isEmpty) {
              return Center(
                  child:
                      CircularProgressIndicator(color: themeData.primaryColor));
            }

            return SafeArea(
              child: _gameOver
                  ? _buildGameOverScreen(
                      wordsModel, dailyTaskModel, themeData, screenSize)
                  : (_selectedCategory == null
                      ? _buildCategorySelectionScreen(
                          wordsModel, themeData, screenSize)
                      : _buildQuizScreen(
                          wordsModel, dailyTaskModel, themeData, screenSize)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelectionScreen(
      WordsModel wordsModel, ThemeData themeData, Size screenSize) {
    List<String> categories = wordsModel.getAllCategories();
    final bool isSmallScreen = screenSize.width < 360;

    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select a Category',
            style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                color: themeData.textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenSize.height * 0.02),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String category = categories[index];
                int wordCount = wordsModel.getWordsByCategory(category).length;
                bool isEnoughWords = wordCount >= 4;

                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
                  child: ElevatedButton(
                    child: Text(
                      '$category (${wordCount} words)',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 18,
                          color: isEnoughWords
                              ? themeData.textTheme.labelLarge?.color
                              : Colors.grey),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: themeData.colorScheme.onPrimary,
                      backgroundColor: themeData.colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                          vertical: screenSize.height * 0.02),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: isEnoughWords
                        ? () {
                            setState(() {
                              _selectedCategory = category;
                              _quizState.setCategory(category);
                              _quizState.words =
                                  wordsModel.getWordsByCategory(category);
                              _quizState.generateNewQuestion();
                              _startTimer();
                            });
                          }
                        : () {
                            _showNotEnoughWordsDialog(
                                category, wordCount, themeData);
                          },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNotEnoughWordsDialog(
      String category, int wordCount, ThemeData themeData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeData.dialogBackgroundColor,
          title: Text('Not Enough Words',
              style: TextStyle(color: themeData.textTheme.titleLarge?.color)),
          content: Text(
            'The category "$category" has only $wordCount word(s). You need at least 4 words to start a quiz.',
            style: TextStyle(color: themeData.textTheme.bodyMedium?.color),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK',
                  style: TextStyle(color: themeData.colorScheme.primary)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameOverScreen(WordsModel wordsModel,
      DailyTaskModel dailyTaskModel, ThemeData themeData, Size screenSize) {
    final bool isSmallScreen = screenSize.width < 360;

    return SingleChildScrollView(
      child: Container(
        height: screenSize.height,
        width: screenSize.width,
        color: themeData.scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Game Over',
                      style: TextStyle(
                          color: themeData.textTheme.titleLarge?.color,
                          fontSize: isSmallScreen ? 28 : 32,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Container(
                      width: double.infinity,
                      height: screenSize.height * 0.25,
                      child: Image.asset(
                        'assets/images/gameoverCat.png',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.05),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _gameOverReason.startsWith('WRONG')
                                ? 'WRONG!\n\n'
                                : '',
                            style: TextStyle(
                              color: themeData.colorScheme.error,
                              fontSize: isSmallScreen ? 32 : 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: _gameOverReason.startsWith('WRONG')
                                ? _gameOverReason.substring(
                                    _gameOverReason.indexOf('\n') + 1)
                                : _gameOverReason,
                            style: TextStyle(
                              color: themeData.textTheme.bodyLarge?.color,
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      'SCORE: ${_quizState.score}',
                      style: TextStyle(
                          color: themeData.textTheme.titleLarge?.color,
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      'Category: $_selectedCategory',
                      style: TextStyle(
                          color: themeData.textTheme.titleMedium?.color,
                          fontSize: isSmallScreen ? 16 : 20),
                    ),
                    SizedBox(height: screenSize.height * 0.04),
                    ElevatedButton(
                      child: Text(
                        'Play Again',
                        style: TextStyle(
                            color: themeData.colorScheme.onPrimary,
                            fontSize: isSmallScreen ? 16 : 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeData.colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.1,
                            vertical: screenSize.height * 0.02),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        _restartGame();
                        wordsModel.completeQuiz();
                        dailyTaskModel.updateTaskProgress(
                            'Complete quizzes', 1);
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    TextButton(
                      child: Text(
                        'Change Category',
                        style: TextStyle(
                            color: themeData.colorScheme.secondary,
                            fontSize: isSmallScreen ? 14 : 16),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = null;
                          _quizState = QuizState();
                          _gameOver = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizScreen(WordsModel wordsModel, DailyTaskModel dailyTaskModel,
      ThemeData themeData, Size screenSize) {
    if (_quizState.words.isEmpty) {
      return Center(
          child: Text('No words in this category',
              style: TextStyle(color: themeData.textTheme.bodyLarge?.color)));
    }

    final bool isSmallScreen = screenSize.width < 360;

    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isScoreAnimating ? 60 : 50,
                width: _isScoreAnimating ? 60 : 50,
                decoration: BoxDecoration(
                  color: themeData.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${_quizState.score}',
                    style: TextStyle(
                      color: themeData.colorScheme.onSecondary,
                      fontSize: _isScoreAnimating ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  9,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.01),
                    child: CircleAvatar(
                      radius: isSmallScreen ? 4 : 5,
                      backgroundColor: index < _timeLeft
                          ? themeData.colorScheme.primary
                          : themeData.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.04),
          Text(
            _quizState.currentQuestion?.english.toUpperCase() ?? '',
            style: TextStyle(
                color: themeData.textTheme.titleLarge?.color,
                fontSize: isSmallScreen ? 28 : 32,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenSize.height * 0.04),
          Expanded(
            child: ListView(
              children: _quizState.options
                  .map((option) => Padding(
                        padding:
                            EdgeInsets.only(bottom: screenSize.height * 0.02),
                        child: ElevatedButton(
                          child: Text(option,
                              style: TextStyle(
                                  color: themeData.colorScheme.onPrimary,
                                  fontSize: isSmallScreen ? 14 : 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeData.colorScheme.primary,
                            padding: EdgeInsets.symmetric(
                                vertical: screenSize.height * 0.02),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () =>
                              _checkAnswer(option, wordsModel, dailyTaskModel),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _checkAnswer(
      String answer, WordsModel wordsModel, DailyTaskModel dailyTaskModel) {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    if (_quizState.checkAnswer(answer)) {
      _showSnackbar(true);
      setState(() {
        _quizState.incrementScore();
        _animateScore();

        if (_quizState.score == _targetScore && !_dailyTaskCompleted) {
          _dailyTaskCompleted = true;
          wordsModel.completeQuiz();
          dailyTaskModel.updateTaskProgress('Complete quizzes', 1);
          _showDailyTaskCompletedNotification();
        }

        _quizState.generateNewQuestion();
        _timeLeft = min(_timeLeft + 1, 9);
        _startTimer();
      });
    } else {
      _showSnackbar(false);
      _endGame(
          'WRONG!\nCorrect Answer Was \n ${_quizState.currentQuestion!.turkish.first.toUpperCase()}');
    }
  }

  void _showDailyTaskCompletedNotification() {
    final themeData = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Daily quiz task completed!',
            style: TextStyle(color: themeData.colorScheme.onSecondary)),
        duration: const Duration(seconds: 2),
        backgroundColor: themeData.colorScheme.secondary,
      ),
    );
  }

  void _showSnackbar(bool isCorrect) {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    ThemeData themeData = themeModel.currentTheme;
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.error,
              color: isCorrect
                  ? themeData.colorScheme.onSecondary
                  : themeData.colorScheme.onError,
              size: isSmallScreen ? 20 : 24,
            ),
            SizedBox(width: screenSize.width * 0.02),
            Text(
              isCorrect ? 'Doğru!' : 'Yanlış :(',
              style: TextStyle(
                color: isCorrect
                    ? themeData.colorScheme.onSecondary
                    : themeData.colorScheme.onError,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: isCorrect
            ? themeData.colorScheme.secondary
            : themeData.colorScheme.error,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
