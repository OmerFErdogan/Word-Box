import 'image.dart';

class Word {
  final int id;
  final String english;
  List<String> turkish;
  final String example;
  final DateTime createdAt;
  bool isFavorite;
  List<String> categories;
  CustomImage? image;
  String? definition; // Burayı String? olarak değiştirin

  Word({
    required this.id,
    required this.english,
    required this.turkish,
    required this.example,
    required this.createdAt,
    this.isFavorite = false,
    required this.categories,
    this.image,
    this.definition, // Burada required kaldırıldı
  });

  // fromJson ve toJson metodlarını da güncellemeyi unutmayın
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      english: json['english'],
      turkish: List<String>.from(json['turkish']),
      example: json['example'],
      createdAt: DateTime.parse(json['createdAt']),
      isFavorite: json['isFavorite'] ?? false,
      categories: List<String>.from(json['categories'] ?? ['General']),
      image: json['image'] == null ? null : CustomImage.fromJson(json['image']),
      definition: json['definition'], // Burada as String? kaldırıldı
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'english': english,
      'turkish': turkish,
      'example': example,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
      'categories': categories,
      'image': image?.toJson(),
      'definition': definition,
    };
  }
}
