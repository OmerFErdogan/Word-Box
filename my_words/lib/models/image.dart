class CustomImage {
  final int id;
  final String imagePath;
  final DateTime uploadedDate;
  final String description; // Resimle ilgili açıklama veya not.

  CustomImage({
    required this.id,
    required this.imagePath,
    required this.uploadedDate,
    this.description = "",
  });

  // CustomImage sınıfından bir JSON objesine dönüşüm (eğer veritabanında ya da SharedPreferences'ta saklamak için JSON kullanıyorsanız)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'uploadedDate': uploadedDate.toIso8601String(),
      'description': description,
    };
  }

  // JSON objesinden CustomImage sınıfına dönüşüm
  static CustomImage fromJson(Map<String, dynamic> json) {
    return CustomImage(
      id: json['id'],
      imagePath: json['imagePath'],
      uploadedDate: DateTime.parse(json['uploadedDate']),
      description: json['description'],
    );
  }
}
