import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word.dart';
import '../models/words_model.dart';
import '../models/theme_model.dart';

class EditWordScreen extends StatefulWidget {
  final Word word;

  const EditWordScreen({Key? key, required this.word}) : super(key: key);

  @override
  _EditWordScreenState createState() => _EditWordScreenState();
}

class _EditWordScreenState extends State<EditWordScreen> {
  late TextEditingController _englishController;
  late TextEditingController _turkishController;
  late TextEditingController _exampleController;
  late TextEditingController _definitionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _englishController = TextEditingController(text: widget.word.english);
    _turkishController =
        TextEditingController(text: _formatTurkishText(widget.word.turkish));
    _exampleController = TextEditingController(text: widget.word.example);
    _definitionController = TextEditingController(text: widget.word.definition);
  }

  String _formatTurkishText(dynamic turkish) {
    if (turkish is List) {
      return turkish.join(", ");
    } else if (turkish is String) {
      return turkish;
    } else {
      return turkish.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final theme = themeModel.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Word', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: _englishController,
                    label: 'Word',
                    icon: Icons.language,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _turkishController,
                    label: 'Mean',
                    icon: Icons.translate,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _definitionController,
                    label: 'Definition (Optional)',
                    icon: Icons.description,
                    maxLines: 3,
                    theme: theme,
                    isRequired: false,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _exampleController,
                    label: 'Example',
                    icon: Icons.format_quote,
                    maxLines: 3,
                    theme: theme,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSecondary,
                      backgroundColor: theme.colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _saveChanges,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    required ThemeData theme,
    bool isRequired = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
          prefixIcon: Icon(icon, color: theme.iconTheme.color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        maxLines: maxLines,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedWord = Word(
        id: widget.word.id,
        english: _englishController.text,
        turkish: _turkishController.text.split(", "),
        example: _exampleController.text,
        createdAt: widget.word.createdAt,
        isFavorite: widget.word.isFavorite,
        categories: widget.word.categories,
        image: widget.word.image,
        definition: _definitionController.text.isNotEmpty
            ? _definitionController.text
            : null,
      );

      final wordsModel = Provider.of<WordsModel>(context, listen: false);
      int index = wordsModel.words.indexWhere((w) => w.id == widget.word.id);
      if (index != -1) {
        wordsModel.updateWord(updatedWord, index);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Word updated successfully'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _englishController.dispose();
    _turkishController.dispose();
    _exampleController.dispose();
    _definitionController.dispose();
    super.dispose();
  }
}
