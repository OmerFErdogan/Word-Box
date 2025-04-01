import 'package:flutter/material.dart';

class ManageCategoriesScreen extends StatefulWidget {
  final List<String> categories;

  ManageCategoriesScreen({required this.categories});

  @override
  _ManageCategoriesScreenState createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
  }

  void _removeCategory(String category) {
    setState(() {
      _categories.remove(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D3A),
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: const Color(0xFF2D2D3A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _categories);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ListTile(
            title: Text(category, style: const TextStyle(color: Colors.white)),
            trailing: category != 'General'
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeCategory(category),
                  )
                : null,
          );
        },
      ),
    );
  }
}
