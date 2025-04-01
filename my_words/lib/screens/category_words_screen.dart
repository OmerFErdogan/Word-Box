import 'package:flutter/material.dart';
import 'package:my_words/models/word.dart';
import 'package:my_words/models/words_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_words/services/pdf_service.dart';

class CategoryWordsScreen extends StatelessWidget {
  final String category;
  const CategoryWordsScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$category ${AppLocalizations.of(context)!.word}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeData.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final wordsModel =
                  Provider.of<WordsModel>(context, listen: false);
              List<Word> words = wordsModel.getWordsByCategory(category);
              PDFService.createAndSharePDF(category, words);
            },
          ),
        ],
      ),
      body: Consumer<WordsModel>(
        builder: (context, wordsModel, child) {
          List<Word> words = wordsModel.getWordsByCategory(category);
          return words.isEmpty
              ? const Center(
                  child: Text(
                    'No words in this category yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final word = words[index];
                    return _buildWordCard(context, word, index, themeData);
                  },
                );
        },
      ),
    );
  }

  Widget _buildWordCard(
      BuildContext context, Word word, int index, ThemeData themeData) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(
          '${index + 1}. ${word.english.toUpperCase()}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeData.primaryColor,
          ),
        ),
        subtitle: Text(
          word.turkish.first.toUpperCase(),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.sentence + ':',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeData.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  word.example,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
