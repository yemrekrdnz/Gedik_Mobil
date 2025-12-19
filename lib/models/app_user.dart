import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String studentNumber;
  final UserRole role;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.studentNumber,
    required this.role,
    required this.createdAt,
  });

  // Firestore'dan veri çekme
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      studentNumber: data['studentNumber'] ?? '',
      role: UserRoleExtension.fromString(data['role'] ?? 'student'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'studentNumber': studentNumber,
      'role': role.value,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isStudent => role == UserRole.student;
}
