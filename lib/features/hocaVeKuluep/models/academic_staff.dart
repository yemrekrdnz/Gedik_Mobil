class AcademicStaff {
  final String name;
  final String email;
  final String telephone;
  final String faculty;
  final String pastExperience;
  final String? imageUrl;
  final String? cvUrl;
  final String? sourceUrl;
  final String? officeNumber;
  final String? building;
  final String? department;
  final String? title;
  final String? extension;
  final String? location;

  AcademicStaff({
    required this.name,
    required this.email,
    required this.telephone,
    required this.faculty,
    required this.pastExperience,
    this.imageUrl,
    this.cvUrl,
    this.sourceUrl,
    this.officeNumber,
    this.building,
    this.department,
    this.title,
    this.extension,
    this.location,
  });

  factory AcademicStaff.fromMap(Map<String, dynamic> map) {
    return AcademicStaff(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'] ?? '',
      faculty: map['faculty'] ?? '',
      pastExperience: map['pastExperience'] ?? '',
      imageUrl: map['imageUrl'],
      cvUrl: map['cvUrl'],
      sourceUrl: map['sourceUrl'],
      officeNumber: map['officeNumber'],
      building: map['building'],
      department: map['department'],
      title: map['title'],
      extension: map['extension'],
      location: map['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'telephone': telephone,
      'faculty': faculty,
      'pastExperience': pastExperience,
      'imageUrl': imageUrl,
      'cvUrl': cvUrl,
      'sourceUrl': sourceUrl,
      'officeNumber': officeNumber,
      'building': building,
      'department': department,
      'title': title,
      'extension': extension,
      'location': location,
    };
  }
}
