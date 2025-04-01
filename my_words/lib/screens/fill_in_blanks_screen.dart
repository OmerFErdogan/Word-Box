import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_words/models/words_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/theme_model.dart';

class FillInTheBlanksGame extends StatefulWidget {
  @override
  _FillInTheBlanksGameState createState() => _FillInTheBlanksGameState();
}

class _FillInTheBlanksGameState extends State<FillInTheBlanksGame>
    with SingleTickerProviderStateMixin {
  String _currentWord = '';
  String _currentHint = '';
  int _score = 0;
  int _currentIndex = -1;
  int _previousIndex = -1;
  TextEditingController _textController = TextEditingController();
  int _remainingTime = 30;
  Timer? _timer;
  int _streak = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _motivationMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateWord();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingTime = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
          _showFeedback(false);
        }
      });
    });
  }

  void _generateWord() {
    final wordsModel = Provider.of<WordsModel>(context, listen: false);
    final random = Random();

    if (wordsModel.words.isNotEmpty) {
      int newIndex;
      do {
        newIndex = random.nextInt(wordsModel.words.length);
      } while (newIndex == _currentIndex || newIndex == _previousIndex);

      _previousIndex = _currentIndex;
      _currentIndex = newIndex;

      final word = wordsModel.words[_currentIndex].english;
      final hint = _generateHint(word);

      setState(() {
        _currentWord = word;
        _currentHint = hint;
        _motivationMessage = '';
      });
      _animationController.forward(from: 0.0);

      _startTimer();
    }
  }

  String _generateHint(String word) {
    final random = Random();
    final List<String> chars = word.split('');
    for (int i = 0; i < chars.length ~/ 2; i++) {
      final index = random.nextInt(chars.length);
      chars[index] = '_';
    }
    return chars.join('');
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final theme = themeModel.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.fill_in_the_blank_game),
        backgroundColor: theme.primaryColor,
      ),
      body: _currentWord.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildScoreCard(theme),
                    const SizedBox(height: 24),
                    _buildWordCard(theme),
                    const SizedBox(height: 24),
                    _buildAnswerInput(theme),
                    const SizedBox(height: 24),
                    _buildSubmitButton(theme),
                    const SizedBox(height: 16),
                    _buildMotivationMessage(theme),
                    const Spacer(),
                    _buildTimerBar(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildScoreCard(ThemeData theme) {
    return Card(
      elevation: 4,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.score,
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  'Streak: $_streak',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            Text(
              '$_score',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard(ThemeData theme) {
    return ScaleTransition(
      scale: _animation,
      child: Card(
        elevation: 4,
        color: theme.colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _currentHint,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSecondary,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerInput(ThemeData theme) {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.write_your_answer_here,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      style: theme.textTheme.titleLarge,
      textAlign: TextAlign.center,
      onSubmitted: (_) => _checkAnswer(),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _checkAnswer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          AppLocalizations.of(context)!.your_answer,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildMotivationMessage(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _motivationMessage.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Text(
        _motivationMessage,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimerBar(ThemeData theme) {
    return Column(
      children: [
        Text(
          '${_remainingTime}s',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _remainingTime / 30,
          backgroundColor: theme.colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(
            _remainingTime > 10 ? theme.colorScheme.primary : Colors.red,
          ),
        ),
      ],
    );
  }

  void _checkAnswer() {
    if (_textController.text.trim().toLowerCase() ==
        _currentWord.toLowerCase()) {
      setState(() {
        _score += _calculateScore();
        _streak++;
        _motivationMessage = _getRandomMotivationMessage();
      });
      _textController.clear();
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          _motivationMessage = '';
        });
        _generateWord();
      });
    } else {
      _showFeedback(false);
    }
    _textController.clear();
  }

  int _calculateScore() {
    int baseScore = 10;
    int timeBonus = _remainingTime;
    int streakBonus = _streak * 5;
    return baseScore + timeBonus + streakBonus;
  }

  String _getRandomMotivationMessage() {
    final messages = [
      'Mamma mia!',
      'Harika!',
      'Müthiş!',
      'Süpersin!',
      'Devam et!',
      'Çok iyisin!',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  void _showFeedback(bool isCorrect) {
    _timer?.cancel();
    _textController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Doğru!' : 'Yanlış'),
          content:
              Text(isCorrect ? 'Tebrikler!' : 'Doğru cevap: $_currentWord'),
          actions: <Widget>[
            TextButton(
              child: const Text('Devam Et'),
              onPressed: () {
                Navigator.of(context).pop();
                _generateWord();
              },
            ),
          ],
        );
      },
    );
  }
}
