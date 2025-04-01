import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/words_model.dart';
import '../models/daily_task_model.dart';
import '../models/theme_model.dart';
import '../widgets/bottom_nav_bar.dart';
import 'MatchingGameScreen.dart';
import 'daily_task_screen.dart';
import 'words_screen.dart';
import 'profile_screen.dart';
import 'add_word_screen.dart';
import 'category_words_screen.dart';
import 'anagram_screen.dart';
import 'quiz_screens.dart';
import 'learning_stats_screen.dart';
import 'category_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  bool _isLearningActivityLoaded = false;
  bool _isWordlistsLoaded = false;

  @override
  Widget build(BuildContext context) {
    final wordsModel = Provider.of<WordsModel>(context);
    final taskModel = Provider.of<DailyTaskModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final theme = themeModel.currentTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Corco',
          style: TextStyle(
            color: theme.appBarTheme.titleTextStyle?.color,
            fontSize: size.width * 0.06,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return BottomNavBar(
      selectedIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      theme: theme,
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const WordsScreen();
      case 1:
        return _buildHomeContent();
      case 2:
        return ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildLazyLoadingSection(
      bool isLoaded, Widget Function() buildWidget, VoidCallback onLoad) {
    return isLoaded
        ? buildWidget()
        : FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 100), onLoad),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return buildWidget();
              }
              return const Center(child: const CircularProgressIndicator());
            },
          );
  }

  Widget _buildLearningActivity(
      WordsModel wordsModel, Size size, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.04)),
      margin: EdgeInsets.all(size.width * 0.04),
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            _buildDailyChart(wordsModel, size, theme),
            SizedBox(height: size.height * 0.01),
            Center(
              child: Text(
                'Words learned in the last 30 days',
                style: theme.textTheme.bodySmall,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            _buildLegend(size, theme),
            SizedBox(height: size.height * 0.01),
            _buildSummary(wordsModel, size, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChart(WordsModel wordsModel, Size size, ThemeData theme) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 29));

    return Wrap(
      spacing: size.width * 0.01,
      runSpacing: size.width * 0.01,
      children: List.generate(30, (index) {
        final date = thirtyDaysAgo.add(Duration(days: index));
        final count = wordsModel
                .dailyWordCounts[DateTime(date.year, date.month, date.day)] ??
            0;
        return _buildDayCell(date, count, size, theme);
      }),
    );
  }

  Widget _buildDayCell(DateTime date, int count, Size size, ThemeData theme) {
    Color cellColor;
    if (count == 0) {
      cellColor = theme.disabledColor;
    } else if (count < 3) {
      cellColor = theme.colorScheme.primary.withOpacity(0.3);
    } else if (count < 5) {
      cellColor = theme.colorScheme.primary.withOpacity(0.5);
    } else if (count < 7) {
      cellColor = theme.colorScheme.primary.withOpacity(0.7);
    } else {
      cellColor = theme.colorScheme.primary;
    }

    return Container(
      width: size.width * 0.05,
      height: size.width * 0.05,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(size.width * 0.005),
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
              fontSize: size.width * 0.02, color: theme.colorScheme.onPrimary),
        ),
      ),
    );
  }

  Widget _buildLegend(Size size, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Less', style: theme.textTheme.bodySmall),
        SizedBox(width: size.width * 0.01),
        ...List.generate(5, (index) {
          return Container(
            width: size.width * 0.035,
            height: size.width * 0.035,
            margin: EdgeInsets.symmetric(horizontal: size.width * 0.005),
            decoration: BoxDecoration(
              color: index == 0
                  ? theme.disabledColor
                  : theme.colorScheme.primary.withOpacity(0.2 * index + 0.2),
              borderRadius: BorderRadius.circular(size.width * 0.005),
            ),
          );
        }),
        SizedBox(width: size.width * 0.01),
        Text('More', style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildSummary(WordsModel wordsModel, Size size, ThemeData theme) {
    int totalWords =
        wordsModel.dailyWordCounts.values.fold(0, (sum, count) => sum + count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total words learned: $totalWords',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: size.height * 0.005),
        Text(
          _getMotivationalMessage(totalWords),
          style:
              theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  String _getMotivationalMessage(int totalWords) {
    if (totalWords == 0) return "Start learning today!";
    if (totalWords < 10) return "Great start! Keep going!";
    if (totalWords < 50) return "You're making excellent progress!";
    return "Wow! You're on fire!";
  }

  Widget _buildWordlists(WordsModel wordsModel, Size size, ThemeData theme) {
    List<String> categories = wordsModel.getCategories();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Wordlists', style: theme.textTheme.titleLarge),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CategoryListScreen()),
                  );
                },
                child: Text('See All',
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: size.width * 0.04)),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories
                .take(3)
                .map((category) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoryWordsScreen(category: category),
                          ),
                        );
                      },
                      child: Container(
                        width: size.width * 0.3,
                        height: size.width * 0.3,
                        margin: EdgeInsets.only(left: size.width * 0.04),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius:
                              BorderRadius.circular(size.width * 0.025),
                        ),
                        child: Center(
                          child: Text(category,
                              style: TextStyle(
                                  color: theme.colorScheme.onSecondary,
                                  fontSize: size.width * 0.04)),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTask(DailyTaskModel taskModel, Size size, ThemeData theme) {
    final wordsModel = Provider.of<WordsModel>(context, listen: false);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.04)),
      margin: EdgeInsets.all(size.width * 0.04),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Daily Task',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.stars,
                  color: theme.colorScheme.onPrimary,
                  size: size.width * 0.08,
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            LinearProgressIndicator(
              value: taskModel.overallProgress,
              backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.3),
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              '${(taskModel.overallProgress * 100).toInt()}% Completed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DailyTaskScreen()));
                  },
                  icon: Icon(Icons.visibility, size: size.width * 0.05),
                  label: Text('View Tasks',
                      style: TextStyle(fontSize: size.width * 0.04)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.015),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * 0.04),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Streak: ${wordsModel.currentStreak} days',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Row(
                      children: List.generate(
                        7,
                        (index) => Icon(
                          Icons.local_fire_department,
                          color: index < wordsModel.currentStreak
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onPrimary.withOpacity(0.5),
                          size: size.width * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final wordsModel = Provider.of<WordsModel>(context);
    final taskModel = Provider.of<DailyTaskModel>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: size.height * 0.05), // En alta padding eklendi
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLazyLoadingSection(
              _isLearningActivityLoaded,
              () => _buildLearningActivity(wordsModel, size, theme),
              () => setState(() => _isLearningActivityLoaded = true),
            ),
            _buildLazyLoadingSection(
              _isWordlistsLoaded,
              () => _buildWordlists(wordsModel, size, theme),
              () => setState(() => _isWordlistsLoaded = true),
            ),
            _buildDailyTask(taskModel, size, theme),
            _buildExerciseSection(size, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSection(Size size, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Text(
            'Exercise Your Mind',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Container(
          height: size.height * 0.25,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            children: [
              _buildExerciseItem(
                'Quiz Challenge',
                'Test your knowledge',
                Icons.quiz,
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const QuizScreen()));
                },
                size,
                theme,
              ),
              SizedBox(width: size.width * 0.04),
              _buildExerciseItem(
                'Matching Game',
                'Improve your memory',
                Icons.grid_on,
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MatchingGameScreen()));
                },
                size,
                theme,
              ),
              SizedBox(width: size.width * 0.04),
              _buildExerciseItem(
                'Anagram Adventure',
                'Boost your vocabulary',
                Icons.shuffle,
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AnagramGameScreen()));
                },
                size,
                theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseItem(String title, String subtitle, IconData icon,
      VoidCallback onTap, Size size, ThemeData theme) {
    // Küçük ekranlar için boyutları ayarlayalım
    double containerWidth = size.width * (size.width < 360 ? 0.7 : 0.6);
    double iconSize = size.width * (size.width < 360 ? 0.1 : 0.12);
    double titleFontSize = size.width * (size.width < 360 ? 0.04 : 0.045);
    double subtitleFontSize = size.width * (size.width < 360 ? 0.03 : 0.035);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: containerWidth,
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
          borderRadius: BorderRadius.circular(size.width * 0.05),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: theme.colorScheme.onPrimary,
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
                fontSize: subtitleFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
