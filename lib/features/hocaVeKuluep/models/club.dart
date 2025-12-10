class Club {
  final String name;
  final String description;
  final String? imageUrl;
  final String? contactInfo;

  Club({
    required this.name,
    required this.description,
    this.imageUrl,
    this.contactInfo,
  });

  factory Club.fromMap(Map<String, dynamic> map) {
    return Club(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      contactInfo: map['contactInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'contactInfo': contactInfo,
    };
  }
}
