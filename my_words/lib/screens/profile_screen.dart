import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/words_model.dart';
import '../models/word.dart';
import '../models/theme_model.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WordsModel>(
      builder: (context, wordsModel, child) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _buildWideLayout(context, wordsModel);
              } else {
                return _buildNarrowLayout(context, wordsModel);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(BuildContext context, WordsModel wordsModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildUserLevelSection(context, wordsModel),
                  _buildLearningGoalSection(context, wordsModel),
                  _buildThemeSelectionSection(context),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildStreakSection(context, wordsModel),
                  _buildRecentWordsSection(context, wordsModel),
                  _buildAchievementsSection(context, wordsModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, WordsModel wordsModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildUserLevelSection(context, wordsModel),
          _buildLearningGoalSection(context, wordsModel),
          _buildThemeSelectionSection(context),
          _buildStreakSection(context, wordsModel),
          _buildRecentWordsSection(context, wordsModel),
          _buildAchievementsSection(context, wordsModel),
        ],
      ),
    );
  }

  Widget _buildUserLevelSection(BuildContext context, WordsModel wordsModel) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Level ${wordsModel.currentLevel}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    value: wordsModel.currentExp / 1000,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                ),
                Text(
                  '${(wordsModel.currentExp / 10).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${wordsModel.currentExp} / 1000 XP',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningGoalSection(
      BuildContext context, WordsModel wordsModel) {
    int dailyGoal = 5;
    int todayLearned = wordsModel.todayWordCount();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Goal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: todayLearned / dailyGoal,
              backgroundColor: Colors.grey[300],
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              minHeight: 10,
            ),
            const SizedBox(height: 16),
            Text(
              '$todayLearned / $dailyGoal words learned today',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelectionSection(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme Selection', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Choose your favorite theme:',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: themeModel.availableThemes.length,
              itemBuilder: (context, index) {
                bool isSelected = themeModel.currentThemeIndex == index;
                return GestureDetector(
                  onTap: () => themeModel.changeTheme(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: themeModel.availableThemes[index].primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: theme.shadowColor, blurRadius: 5)]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Current Theme:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getThemeName(themeModel.currentThemeIndex),
                    style: theme.textTheme.titleMedium,
                  ),
                  Icon(Icons.palette, color: theme.iconTheme.color),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showThemeInfoBottomSheet(
                  context, themeModel.currentThemeIndex),
              icon: const Icon(Icons.info_outline),
              label: const Text('Theme Info'),
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context, WordsModel wordsModel) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Icon(Icons.local_fire_department,
                    size: 48, color: Colors.orange),
                const SizedBox(height: 8),
                Text(
                  'Current Streak',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${wordsModel.currentStreak} days',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
                const SizedBox(height: 8),
                Text(
                  'Best Streak',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${wordsModel.currentStreak} days', // Assume you have a bestStreak property
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWordsSection(BuildContext context, WordsModel wordsModel) {
    List<Word> recentWords = wordsModel.words.take(5).toList();
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recently Learned Words',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            ...recentWords.map((word) => _buildWordItem(context, word)),
          ],
        ),
      ),
    );
  }

  Widget _buildWordItem(BuildContext context, Word word) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(word.english,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        subtitle: Text(word.turkish.join(', ')),
        trailing: Chip(
          label: Text(word.categories.first),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(
      BuildContext context, WordsModel wordsModel) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Achievements',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            _buildAchievementItem(context, 'Beginner', 'Save 10 words',
                wordsModel.words.length >= 10),
            _buildAchievementItem(context, 'Intermediate', 'Save 50 words',
                wordsModel.words.length >= 50),
            _buildAchievementItem(context, 'Advanced', 'Save 100 words',
                wordsModel.words.length >= 100),
            _buildAchievementItem(context, 'Streak Master',
                'Maintain a 7-day streak', wordsModel.currentStreak >= 7),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(
      BuildContext context, String title, String description, bool achieved) {
    return ListTile(
      leading: Icon(
        Icons.emoji_events,
        color: achieved ? Colors.yellow : Colors.grey,
        size: 36,
      ),
      title: Text(title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
      subtitle: Text(description),
      trailing: achieved
          ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
          : null,
    );
  }

  String _getThemeName(int index) {
    List<String> themeNames = [
      'Ocean Depths',
      'Gustav\'s Green',
      'Royal Blue',
      'Corco\'s Warmth',
      'Lavender Bliss',
      'Cherry Blossom',
      'Midnight Sky',
      'Emerald Isle',
    ];
    return themeNames[index % themeNames.length];
  }

  void _showThemeInfoBottomSheet(BuildContext context, int themeIndex) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getThemeName(themeIndex),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  _getThemeDescription(themeIndex),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: const Text('Close'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          );
        });
  }

  String _getThemeDescription(int index) {
    List<String> themeStories = [
      'Ocean Depths: In the depths of the ocean, there lies a tranquility that transcends the boundaries of life and nature. This theme embraces you with the serenity of blue tones, pulling you into the embrace of the sea.',
      'Gustav\'s Green: In the heart of nature, two souls find peace among the richest shades of green. This theme invites you to rediscover nature and life with every breath. Inspred By Kani',
      'Royal Blue: A theme inspired by the grandeur of royalty, where every shade of blue speaks of elegance and majesty. It carries the dignity of a throne and the calm of an endless sky, offering you a world where every moment feels like a royal decree.',
      'Corco\'s Warmth: Inspired by Corco\'s bright orange fur, this theme opens the doors to a world filled with warmth and joy. These vibrant colors, infused with Corco\'s energy, bring liveliness to every moment and remind you of the simple pleasures of life.',
      'Lavender Bliss: The gentle breeze through fields of lavender carries you beyond your dreams. This theme envelops you in the purest form of peace and tranquility.',
      'Cherry Blossom: The first blossoms of spring bring nature back to life. The delicate beauty of cherry blossoms reminds you of the fleeting yet beautiful nature of life.',
      'Midnight Sky: Like stars shining in the dark night, this theme symbolizes the depth of the universe and eternity. It invites you to embrace the magic of the night.',
      'Emerald Isle: On emerald green islands, surrounded by the most vibrant colors of nature, lies a paradise. This theme reflects the freshness and energy of nature.',
    ];
    return themeStories[index % themeStories.length];
  }
}
