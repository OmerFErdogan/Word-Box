import 'package:flutter/material.dart';
import 'package:my_words/models/word.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/words_model.dart';

class AddWordScreen extends StatefulWidget {
  final Word? editWord;
  final int? editIndex;
  const AddWordScreen({this.editWord, this.editIndex});
  @override
  _AddWordScreenState createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _englishController = TextEditingController();
  final _turkishController = TextEditingController();
  final _exampleController = TextEditingController();
  final _categoryController = TextEditingController();
  
  void _saveWord() {
    final enteredCategory = _categoryController.text;
    if (_formKey.currentState!.validate()) {
      final newWord = Word(
        id: DateTime.now().millisecondsSinceEpoch,
        english: _englishController.text,
        turkish: _turkishController.text,
        example: _exampleController.text,
        createdAt: DateTime.now(),
         category: enteredCategory, 
      );
      Provider.of<WordsModel>(context, listen: false).addWord(newWord, context);
      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration({required String labelText}) {
    ThemeData themeData = Theme.of(context);
    return InputDecoration(
      labelText: labelText,
      border: const OutlineInputBorder(),
      focusedBorder:  OutlineInputBorder(
        borderSide: BorderSide(color: themeData.primaryColor, width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
           AppLocalizations.of(context)!.add_new_word,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeData.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _englishController,
                decoration: _inputDecoration(labelText: AppLocalizations.of(context)!.english),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter new value';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _turkishController,
                decoration: _inputDecoration(labelText: 'Native'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter new value';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _exampleController,
                decoration: _inputDecoration(labelText: AppLocalizations.of(context)!.example_sentence),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter new value';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.category),
                controller: _categoryController,
              ),
              const SizedBox(height: 32.0),
              SizedBox(
                
                
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveWord,
                  child:  Text(AppLocalizations.of(context)!.save),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:themeData.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
               const SizedBox(height: 32.0),
                Text(AppLocalizations.of(context)!.words_without_category)
            ],
          ),
        ),
      ),
    );
  }
}
