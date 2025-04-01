import 'package:flutter/material.dart';
import 'package:my_words/widgets/drawer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../LazyLoadingWordList.dart';
import 'add_word_screen.dart';
import 'image_to_words.dart';
import '../models/words_model.dart';
import '../models/theme_model.dart';

class WordsScreen extends StatefulWidget {
  static const int dailyTarget = 20;
  const WordsScreen({Key? key}) : super(key: key);

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  Widget _buildBodyContent(WordsModel wordsModel, ThemeData themeData) {
    if (wordsModel.allWords.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.press_plus +
              "\n" +
              AppLocalizations.of(context)!.try_adding_words,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: themeData.textTheme.bodyLarge?.color,
          ),
        ),
      );
    } else {
      return LazyLoadingWordList(
        wordsModel: wordsModel,
        pageSize: 4, // Bir seferde yüklenecek kelime sayısı
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final themeData = themeModel.currentTheme;
    return Scaffold(
      body: Consumer<WordsModel>(
        builder: (context, wordsModel, child) =>
            _buildBodyContent(wordsModel, themeData),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageToWordsScreen()),
              );
            },
            child: const Icon(Icons.camera_alt, color: Colors.white),
            backgroundColor:
                themeData.floatingActionButtonTheme.backgroundColor,
            heroTag: 'camera',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWordScreen()),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
            backgroundColor:
                themeData.floatingActionButtonTheme.backgroundColor,
            heroTag: 'add',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
