import 'package:flutter/material.dart';
import '../models/word.dart';
import '../screens/edit_word_screen.dart';
import '../screens/word_detail.dart';
import 'package:provider/provider.dart';
import '../models/words_model.dart';
import '../models/theme_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'shared_flashcard.dart';

class WordCard extends StatelessWidget {
  final Word word;
  final int index;
  final Function(bool) onFavoriteChanged;

  const WordCard({
    Key? key,
    required this.word,
    required this.index,
    required this.onFavoriteChanged,
  }) : super(key: key);

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Word"),
          content: const Text("Are you sure you want to delete this word?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Provider.of<WordsModel>(context, listen: false)
                    .removeWord(word);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToWordDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WordDetailPage(word: word)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final theme = themeModel.currentTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    word.english.toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$index.',
                    style: TextStyle(
                        color: theme.colorScheme.onSurface, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                word.turkish is List
                    ? (word.turkish as List).join(", ")
                    : word.turkish.toString(),
                style:
                    TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                word.example,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  Icons.share,
                  () => shareToInstagramStory(context, word),
                  theme.iconTheme.color,
                ),
                _buildActionButton(
                  context,
                  word.isFavorite ? Icons.favorite : Icons.favorite_border,
                  () => onFavoriteChanged(!word.isFavorite),
                  word.isFavorite ? Colors.red : theme.iconTheme.color,
                ),
                _buildActionButton(
                  context,
                  Icons.edit,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditWordScreen(word: word),
                    ),
                  ),
                  theme.iconTheme.color,
                ),
                _buildActionButton(
                  context,
                  Icons.delete,
                  () => _showDeleteConfirmation(context),
                  theme.iconTheme.color,
                ),
                _buildActionButton(
                  context,
                  Icons.more_vert,
                  () => _navigateToWordDetail(context),
                  theme.iconTheme.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
    Color? color,
  ) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 20,
    );
  }
}

Future<void> shareToInstagramStory(BuildContext context, Word word) async {
  final controller = ScreenshotController();

  final bytes = await controller.captureFromWidget(
    ShareableWordCard(
      word: word.english.toUpperCase(),
      meaning: word.turkish is List
          ? (word.turkish as List).join("\n")
          : word.turkish.toString().toUpperCase(),
      example: word.example,
    ),
    delay: const Duration(milliseconds: 10),
    targetSize: const Size(1080, 1920),
  );

  final directory = await getApplicationDocumentsDirectory();
  final image = File('${directory.path}/word_card.png');
  image.writeAsBytesSync(bytes);

  try {
    final result = await Share.shareXFiles(
      [XFile(image.path)],
      text: 'Check out this word I learned with CORCO!',
      subject: 'CORCO Word Card',
    );

    if (result.status == ShareResultStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shared successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing failed')),
      );
    }
  } catch (e) {
    print('Error sharing: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to share. An error occurred.')),
    );
  }
}
