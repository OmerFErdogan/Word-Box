import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import 'package:my_words/models/words_model.dart';
import 'package:my_words/models/theme_model.dart';
import 'package:my_words/screens/add_word_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageToWordsScreen extends StatefulWidget {
  @override
  _ImageToWordsScreenState createState() => _ImageToWordsScreenState();
}

class _ImageToWordsScreenState extends State<ImageToWordsScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  List<String> _detectedWords = [];
  List<Map<String, String>> _newWordsWithDefinitions = [];
  bool _isProcessing = false;

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _processImage(ImageSource source) async {
    setState(() {
      _isProcessing = true;
      _detectedWords = [];
      _newWordsWithDefinitions = [];
    });

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final File imageFile = File(image.path);
        final InputImage inputImage = InputImage.fromFile(imageFile);
        final RecognizedText recognizedText =
            await _textRecognizer.processImage(inputImage);

        _detectedWords = recognizedText.blocks
            .expand((block) => block.lines)
            .expand((line) => line.elements)
            .map((element) => element.text.toLowerCase())
            .where((word) => word.length > 1)
            .toSet()
            .toList();

        await _filterNewWords();
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<String?> getWordDefinition(String word) async {
    try {
      final response = await http.get(
          Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['meanings'].isNotEmpty) {
          return data[0]['meanings'][0]['definitions'][0]['definition'];
        }
      }
    } catch (e) {
      print('Error getting word definition: $e');
    }
    return null;
  }

  Future<void> _filterNewWords() async {
    final wordsModel = Provider.of<WordsModel>(context, listen: false);
    List<Map<String, String>> newWords = [];

    for (String word in _detectedWords) {
      if (!wordsModel.words.any((w) => w.english.toLowerCase() == word)) {
        String? definition = await getWordDefinition(word);
        newWords.add({
          'word': word,
          'definition': definition ?? 'No definition found',
        });
      }
    }

    setState(() {
      _newWordsWithDefinitions = newWords;
    });
  }

  void _addWord(String word) async {
    final definition = _newWordsWithDefinitions
        .firstWhere((item) => item['word'] == word)['definition'];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddWordScreen(initialWord: word, initialDefinition: definition),
      ),
    );

    if (result == true) {
      setState(() {
        _newWordsWithDefinitions.removeWhere((item) => item['word'] == word);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final theme = themeModel.currentTheme;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Add Words from Image',
            style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              children: [
                _buildHeader(theme, isSmallScreen),
                SizedBox(height: screenSize.height * 0.02),
                _buildImageButtons(theme, screenSize, isSmallScreen),
                SizedBox(height: screenSize.height * 0.02),
                if (_isProcessing)
                  _buildLoadingIndicator(theme)
                else if (_newWordsWithDefinitions.isEmpty)
                  _buildEmptyState(theme)
                else
                  _buildWordList(theme, screenSize, isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isSmallScreen) {
    return Text(
      'Take a photo or choose an image to extract words',
      style: isSmallScreen
          ? theme.textTheme.bodyMedium
          : theme.textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildImageButtons(
      ThemeData theme, Size screenSize, bool isSmallScreen) {
    return Wrap(
      spacing: screenSize.width * 0.04,
      runSpacing: screenSize.height * 0.02,
      alignment: WrapAlignment.center,
      children: [
        _buildButton(
          theme,
          screenSize,
          isSmallScreen,
          Icons.camera_alt,
          'Take a Photo',
          () => _processImage(ImageSource.camera),
        ),
        _buildButton(
          theme,
          screenSize,
          isSmallScreen,
          Icons.photo_library,
          'Choose from Gallery',
          () => _processImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildButton(ThemeData theme, Size screenSize, bool isSmallScreen,
      IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isSmallScreen ? 18 : 24),
      label: Text(label, style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
      style: ElevatedButton.styleFrom(
        foregroundColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary,
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * (isSmallScreen ? 0.03 : 0.04),
          vertical: screenSize.height * (isSmallScreen ? 0.01 : 0.015),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return Column(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
        SizedBox(height: 16),
        Text(
          'Processing image...',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Text(
      'No new words detected. Try another image!',
      style: theme.textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildWordList(ThemeData theme, Size screenSize, bool isSmallScreen) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenSize.height * 0.6),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _newWordsWithDefinitions.length,
        itemBuilder: (context, index) {
          final wordData = _newWordsWithDefinitions[index];
          return Card(
            margin: EdgeInsets.symmetric(
              vertical: screenSize.height * 0.01,
              horizontal: screenSize.width * 0.02,
            ),
            color: theme.cardColor,
            child: ListTile(
              title: Text(
                wordData['word']!,
                style: isSmallScreen
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                wordData['definition']!,
                style: isSmallScreen
                    ? theme.textTheme.bodySmall
                    : theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: ElevatedButton(
                child: Text('Add',
                    style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                onPressed: () => _addWord(wordData['word']!),
                style: ElevatedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onPrimary,
                  backgroundColor: theme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenSize.width * (isSmallScreen ? 0.02 : 0.03),
                    vertical:
                        screenSize.height * (isSmallScreen ? 0.005 : 0.01),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
