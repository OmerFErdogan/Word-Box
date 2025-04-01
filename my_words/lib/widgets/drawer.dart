import 'package:flutter/material.dart';
import 'package:my_words/models/theme_model.dart';
import 'package:my_words/screens/MatchingGameScreen.dart';
import 'package:my_words/screens/anagram_screen.dart';
import 'package:my_words/screens/category_list_screen.dart';
import 'package:my_words/screens/daily_task_screen.dart';
import 'package:my_words/screens/favorite_words_screen.dart';
import 'package:my_words/screens/fill_in_blanks_screen.dart';
import 'package:my_words/screens/quiz_screens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:my_words/models/words_model.dart';

import '../screens/image_to_words.dart';
import '../screens/learning_stats_screen.dart';

void _showThemeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final themeModel = Provider.of<ThemeModel>(context, listen: false);

      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.select_theme),
        content: SingleChildScrollView(
          child: Column(
            children: [
              for (int themeIndex = 0;
                  themeIndex < themeModel.availableThemes.length;
                  themeIndex++)
                ListTile(
                  title: Text(_getThemeName(themeIndex)),
                  trailing: Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeModel
                                  .availableThemes[themeIndex].primaryColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(3),
                                bottomLeft: Radius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        Container(width: 1, color: Colors.grey[300]),
                        Expanded(
                          child: Container(
                            color: themeModel.availableThemes[themeIndex]
                                .colorScheme.secondary,
                          ),
                        ),
                        Container(width: 1, color: Colors.grey[300]),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeModel.availableThemes[themeIndex]
                                  .colorScheme.tertiary,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(3),
                                bottomRight: Radius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    _showThemeStory(context, themeIndex);
                  },
                ),
            ],
          ),
        ),
      );
    },
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

String _getThemeStory(int index) {
  List<String> themeStories = [
    'Ocean Depths: In the depths of the ocean, there lies a tranquility that transcends the boundaries of life and nature. This theme embraces you with the serenity of blue tones, pulling you into the embrace of the sea.',
    'Gustav\'s Green: In the heart of nature, two souls find peace among the richest shades of green. This theme invites you to rediscover nature and life with every breath. Inspred By Kani',
    'Royal Blue: A theme inspired by the grandeur of royalty, where every shade of blue speaks of elegance and majesty. It carries the dignity of a throne and the calm of an endless sky, offering you a world where every moment feels like a royal decree.',
    'Corco\'s Warmth: Inspired by Corco’s bright orange fur, this theme opens the doors to a world filled with warmth and joy. These vibrant colors, infused with Corco’s energy, bring liveliness to every moment and remind you of the simple pleasures of life.',
    'Lavender Bliss: The gentle breeze through fields of lavender carries you beyond your dreams. This theme envelops you in the purest form of peace and tranquility.',
    'Cherry Blossom: The first blossoms of spring bring nature back to life. The delicate beauty of cherry blossoms reminds you of the fleeting yet beautiful nature of life.',
    'Midnight Sky: Like stars shining in the dark night, this theme symbolizes the depth of the universe and eternity. It invites you to embrace the magic of the night.',
    'Emerald Isle: On emerald green islands, surrounded by the most vibrant colors of nature, lies a paradise. This theme reflects the freshness and energy of nature.',
  ];
  return themeStories[index % themeStories.length];
}

void _showThemeStory(BuildContext context, int themeIndex) {
  final themeModel = Provider.of<ThemeModel>(context, listen: false);

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getThemeName(themeIndex),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getThemeStory(themeIndex),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    themeModel.changeTheme(themeIndex);
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                  child: const Text('Onayla'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                  child: const Text('İptal'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void _showWarningDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          AppLocalizations.of(context)!.alert,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: AppLocalizations.of(context)!.before_games),
                    TextSpan(
                      text: AppLocalizations.of(context)!.must_add_words,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'OKEY',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget buildDrawer(BuildContext context) {
  ThemeData themeData = Theme.of(context);
  int wordCount = Provider.of<WordsModel>(context).words.length;

  return Drawer(
    child: Container(
      color: themeData.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: themeData.scaffoldBackgroundColor,
            ),
            child: Text(
              AppLocalizations.of(context)!.menu,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeData.colorScheme.onSurface,
              ),
            ),
          ),
          buildDrawerItem(
            context: context,
            icon: Icons.favorite,
            text: AppLocalizations.of(context)!.favorite_words,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => FavoriteWordsScreen())),
          ),
          buildDrawerItem(
            context: context,
            icon: Icons.gamepad,
            text: AppLocalizations.of(context)!.anagram_game,
            onTap: wordCount < 3
                ? () => _showWarningDialog(context)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AnagramGameScreen())),
          ),
          buildDrawerItem(
            context: context,
            icon: Icons.quiz,
            text: AppLocalizations.of(context)!.quiz,
            onTap: wordCount < 3
                ? () => _showWarningDialog(context)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuizScreen())),
          ),
          buildDrawerItem(
            context: context,
            icon: Icons.create,
            text: AppLocalizations.of(context)!.fill_in_the_blank_game,
            onTap: wordCount < 3
                ? () => _showWarningDialog(context)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FillInTheBlanksGame())),
          ),
          buildDrawerItem(
            context: context,
            icon: Icons.category,
            text: AppLocalizations.of(context)!.word_categories,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => CategoryListScreen())),
          ),
          buildDrawerItem(
            context: context,
            icon: Icons.color_lens,
            text: AppLocalizations.of(context)!.select_theme,
            onTap: () => _showThemeDialog(context),
          ),
          buildDrawerItem(
            context: context,
            icon: Icons.align_horizontal_center_rounded,
            text: "Matching Game",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => MatchingGameScreen())),
          ),
          buildDrawerItem(
            context: context,
            icon: Icons.task,
            text: "Daily Task",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => DailyTaskScreen())),
          ),
          buildDrawerItem(
            context: context,
            icon: Icons.task,
            text: "STATS",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => StatisticsPage())),
          ),
          buildDrawerItem(
            context: context,
            icon: Icons.task,
            text: "IMAGE TO TEXT",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ImageToWordsScreen())),
          ),
        ],
      ),
    ),
  );
}

Widget buildDrawerItem({
  required BuildContext context,
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
  ThemeData themeData = Theme.of(context);
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: themeData.primaryColor.withOpacity(0.1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: ListTile(
          leading: Icon(icon, color: themeData.primaryColor),
          title: Text(
            text,
            style: TextStyle(
              color: themeData.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onTap: onTap,
        ),
      ),
      const Divider(),
    ],
  );
}
