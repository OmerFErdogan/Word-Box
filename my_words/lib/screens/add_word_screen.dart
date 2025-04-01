import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_words/models/word.dart';
import 'package:provider/provider.dart';
import '../models/words_model.dart';
import '../models/theme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ManageCategoriesScreen.dart';
import 'package:http/http.dart' as http;

class AddWordScreen extends StatefulWidget {
  final Word? editWord;
  final int? editIndex;
  final String? initialWord;
  final String? initialDefinition;

  const AddWordScreen({
    Key? key,
    this.editWord,
    this.editIndex,
    this.initialWord,
    this.initialDefinition,
  }) : super(key: key);

  @override
  _AddWordScreenState createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _englishController;
  List<TextEditingController> _turkishControllers = [TextEditingController()];
  final _exampleController = TextEditingController();
  final _definitionController = TextEditingController();
  final _newCategoryController = TextEditingController();
  List<String> _selectedCategories = ['General'];
  List<String> _categories = ['General'];

  @override
  void initState() {
    super.initState();
    _englishController = TextEditingController(text: widget.initialWord);
    _englishController.addListener(_onEnglishWordChanged);
    if (widget.initialDefinition != null &&
        widget.initialDefinition!.isNotEmpty) {
      _definitionController.text = widget.initialDefinition!;
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _englishController.removeListener(_onEnglishWordChanged);
    _englishController.dispose();
    for (var controller in _turkishControllers) {
      controller.dispose();
    }
    _exampleController.dispose();
    _definitionController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _onEnglishWordChanged() async {
    if (_englishController.text.isNotEmpty) {
      var wordInfo = await getWordInfo(_englishController.text);
      if (wordInfo != null) {
        setState(() {
          _definitionController.text = wordInfo['definition'] ?? '';
          if (wordInfo['example'] != null && wordInfo['example']!.isNotEmpty) {
            _exampleController.text = wordInfo['example']!;
          }
        });
      }
    }
  }

  Future<Map<String, String?>> getWordInfo(String word) async {
    try {
      final response = await http.get(
          Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['meanings'].isNotEmpty) {
          var firstMeaning = data[0]['meanings'][0];
          var firstDefinition = firstMeaning['definitions'][0];
          return {
            'definition': firstDefinition['definition'],
            'example': firstDefinition['example'],
          };
        }
      }
    } catch (e) {
      print('Error getting word info: $e');
    }
    return {'definition': null, 'example': null};
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _categories = prefs.getStringList('categories') ?? ['General'];
      if (!_categories.contains('General')) {
        _categories.insert(0, 'General');
      }
    });
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categories', _categories);
  }

  void _addTurkishMeaningField() {
    setState(() {
      if (_turkishControllers.length < 3) {
        _turkishControllers.add(TextEditingController());
      }
    });
  }

  void _removeTurkishMeaningField(int index) {
    setState(() {
      if (_turkishControllers.length > 1) {
        _turkishControllers.removeAt(index);
      }
    });
  }

  void _addNewCategory() {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeModel.currentTheme.dialogBackgroundColor,
          title: Text('Add New Category',
              style: themeModel.currentTheme.textTheme.titleLarge),
          content: TextField(
            controller: _newCategoryController,
            style: themeModel.currentTheme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Enter new category name',
              hintStyle: themeModel.currentTheme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey[400]),
              filled: true,
              fillColor: themeModel.currentTheme.inputDecorationTheme.fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: themeModel.currentTheme.textTheme.labelLarge),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add',
                  style: themeModel.currentTheme.textTheme.labelLarge),
              onPressed: () {
                String newCategory = _newCategoryController.text.trim();
                if (newCategory.isNotEmpty &&
                    !_categories.contains(newCategory)) {
                  setState(() {
                    _categories.add(newCategory);
                    _selectedCategories.add(newCategory);
                  });
                  _saveCategories();
                  _newCategoryController.clear();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _manageCategoriesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ManageCategoriesScreen(categories: _categories)),
    ).then((updatedCategories) {
      if (updatedCategories != null) {
        setState(() {
          _categories = updatedCategories;
          _selectedCategories = _selectedCategories
              .where((cat) => _categories.contains(cat))
              .toList();
          if (!_selectedCategories.contains('General')) {
            _selectedCategories.insert(0, 'General');
          }
        });
        _saveCategories();
      }
    });
  }

  void _saveWord() {
    if (_formKey.currentState!.validate()) {
      List<String> turkishMeanings = _turkishControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final newWord = Word(
        id: DateTime.now().millisecondsSinceEpoch,
        english: _englishController.text,
        turkish: turkishMeanings,
        example: _exampleController.text,
        createdAt: DateTime.now(),
        categories: _selectedCategories,
        definition: _definitionController.text.isNotEmpty
            ? _definitionController.text
            : null,
      );
      Provider.of<WordsModel>(context, listen: false).addWord(newWord, context);
      Navigator.pop(context, true);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    bool isRequired = true,
    VoidCallback? onRemove,
    int? maxLength,
  }) {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: themeModel.currentTheme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[400]),
                filled: true,
                fillColor:
                    themeModel.currentTheme.inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                counterText: '',
              ),
              style: themeModel.currentTheme.textTheme.bodyMedium,
              maxLines: maxLines,
              maxLength: maxLength,
              validator: (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'This field cannot be empty';
                }
                if (maxLength != null && value!.length > maxLength) {
                  return 'Maximum $maxLength characters allowed';
                }
                return null;
              },
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: Icon(Icons.remove_circle_outline,
                  color: themeModel.currentTheme.iconTheme.color),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    return Scaffold(
      backgroundColor: themeModel.currentTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: themeModel.currentTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: themeModel.currentTheme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.initialWord != null ? 'Edit Word' : 'Add Word',
          style: themeModel.currentTheme.appBarTheme.titleTextStyle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _englishController,
                hintText: 'Enter the word',
                maxLength: 50,
              ),
              ..._turkishControllers
                  .asMap()
                  .entries
                  .map((entry) => _buildTextField(
                        controller: entry.value,
                        hintText: 'What mean is that? Meow?',
                        onRemove: _turkishControllers.length > 1
                            ? () => _removeTurkishMeaningField(entry.key)
                            : null,
                        maxLength: 50,
                      ))
                  .toList(),
              if (_turkishControllers.length < 3)
                ElevatedButton(
                  onPressed: _addTurkishMeaningField,
                  child: const Text('Add another mean'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        themeModel.currentTheme.colorScheme.onPrimary,
                    backgroundColor:
                        themeModel.currentTheme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _exampleController,
                hintText: 'Example Sentence',
                maxLines: 3,
                isRequired: false,
                maxLength: 255,
              ),
              _buildTextField(
                controller: _definitionController,
                hintText: 'Enter definition (optional)',
                maxLines: 3,
                isRequired: false,
                maxLength: 255,
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: themeModel.currentTheme.cardColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    ..._categories.map((category) => CheckboxListTile(
                          title: Text(category,
                              style:
                                  themeModel.currentTheme.textTheme.bodyMedium),
                          value: _selectedCategories.contains(category),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                if (!_selectedCategories.contains(category)) {
                                  _selectedCategories.add(category);
                                }
                              } else {
                                if (category != 'General') {
                                  _selectedCategories.remove(category);
                                }
                              }
                            });
                          },
                          activeColor:
                              themeModel.currentTheme.colorScheme.primary,
                          checkColor:
                              themeModel.currentTheme.colorScheme.onPrimary,
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add,
                              color: themeModel.currentTheme.iconTheme.color),
                          onPressed: _addNewCategory,
                        ),
                        IconButton(
                          icon: Icon(Icons.settings,
                              color: themeModel.currentTheme.iconTheme.color),
                          onPressed: _manageCategoriesScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveWord,
                child: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  foregroundColor:
                      themeModel.currentTheme.colorScheme.onPrimary,
                  backgroundColor: themeModel.currentTheme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
