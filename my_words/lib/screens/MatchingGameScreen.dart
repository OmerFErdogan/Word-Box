import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_words/models/words_model.dart';
import 'package:my_words/models/word.dart';
import 'package:my_words/models/theme_model.dart';
import 'dart:async';

class MatchingGameScreen extends StatefulWidget {
  @override
  _MatchingGameScreenState createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  List<Word> gameWords = [];
  List<String> allWords = [];
  String? selectedWord;
  Map<String, String> matchedPairs = {};
  bool isGameOver = false;
  int score = 0;
  int attempts = 0;
  int remainingTime = 60; // 60 saniye
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startNewGame();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startNewGame() {
    final wordsModel = Provider.of<WordsModel>(context, listen: false);
    gameWords = wordsModel.getRandomWords(6);
    allWords = [
      ...gameWords.map((w) => w.english),
      ...gameWords.map((w) => w.turkish.first)
    ];
    allWords.shuffle();
    selectedWord = null;
    matchedPairs.clear();
    isGameOver = false;
    score = 0;
    attempts = 0;
    remainingTime = 60;
    setState(() {});
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          endGame();
        }
      });
    });
  }

  void selectWord(String word) {
    if (selectedWord == null) {
      setState(() {
        selectedWord = word;
      });
    } else {
      checkPair(selectedWord!, word);
      setState(() {
        selectedWord = null;
      });
    }
  }

  void checkPair(String word1, String word2) {
    attempts++;
    Word? matchedWord;
    for (var word in gameWords) {
      if ((word.english == word1 && word.turkish.contains(word2)) ||
          (word.english == word2 && word.turkish.contains(word1))) {
        matchedWord = word;
        break;
      }
    }

    if (matchedWord != null) {
      // Doğru eşleşme
      setState(() {
        score++;
        matchedPairs[word1] = word2;
        matchedPairs[word2] = word1;
      });
      _showFeedback(true);
    } else {
      // Yanlış eşleşme
      _showFeedback(false);
    }

    if (score == gameWords.length) {
      endGame();
    }
  }

  void endGame() {
    _timer?.cancel();
    setState(() {
      isGameOver = true;
    });
    if (score == gameWords.length) {}
  }

  void _showFeedback(bool isCorrect) {
    final theme = Provider.of<ThemeModel>(context, listen: false).currentTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? 'Doğru eşleştirme!'
              : 'Yanlış eşleştirme. Tekrar deneyin.',
          style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context).currentTheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title:
            Text('Eşleştirme Oyunu', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon:
                Icon(Icons.refresh, color: theme.appBarTheme.iconTheme?.color),
            onPressed: startNewGame,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Skor: $score / ${gameWords.length}',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Süre: $remainingTime',
                        style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
              LinearProgressIndicator(
                value: score / gameWords.length,
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
              ),
              Expanded(
                child: isGameOver ? _buildGameOverScreen() : _buildGameScreen(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    final theme = Provider.of<ThemeModel>(context).currentTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: allWords.length,
          itemBuilder: (context, index) {
            String word = allWords[index];
            bool isMatched = matchedPairs.containsKey(word);
            bool isSelected = word == selectedWord;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: isMatched
                    ? theme.colorScheme.secondary.withOpacity(0.3)
                    : isSelected
                        ? theme.colorScheme.primary.withOpacity(0.3)
                        : theme.cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isMatched ? null : () => selectWord(word),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: isSelected ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: isMatched
                            ? theme.colorScheme.secondary
                            : theme.textTheme.bodyLarge?.color,
                      ),
                      child: Text(
                        word,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGameOverScreen() {
    final theme = Provider.of<ThemeModel>(context).currentTheme;
    final isWin = score == gameWords.length;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isWin ? 'Tebrikler!' : 'Oyun Bitti!',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isWin
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Icon(
              isWin ? Icons.emoji_events : Icons.access_time,
              size: 80,
              color: isWin ? Colors.amber : theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              isWin ? 'Tüm eşleştirmeleri tamamladınız!' : 'Süre doldu!',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildScoreCard(theme),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
              label: Text('Yeni Oyun',
                  style: TextStyle(
                      fontSize: 18, color: theme.colorScheme.onPrimary)),
              onPressed: startNewGame,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildScoreRow(theme, 'Skor', '$score / ${gameWords.length}'),
            const Divider(),
            _buildScoreRow(theme, 'Toplam Deneme', '$attempts'),
            const Divider(),
            _buildScoreRow(theme, 'Kalan Süre', '$remainingTime saniye'),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          Text(value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
