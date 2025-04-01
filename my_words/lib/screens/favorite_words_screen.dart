import 'package:flutter/material.dart';
import 'package:my_words/models/words_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FavoriteWordsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.favorite_words,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeData.primaryColor,
      ),
      body: Consumer<WordsModel>(
        builder: (context, wordsModel, child) {
          final favoriteWords = wordsModel.favoriteWords;
          return ListView.builder(
            itemCount: favoriteWords.length,
            itemBuilder: (context, index) {
              final word = favoriteWords[index];
              return ListTile(
                //  tileColor: index % 2 == 0 ? Colors.purple.shade50 : Colors.white,
                title: Text(
                  '${word.english.toUpperCase()} - ${word.turkish.first.toUpperCase()}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeData.textSelectionTheme.cursorColor),
                ),
                subtitle: Text(
                  word.example,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: themeData.textSelectionTheme.cursorColor),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
