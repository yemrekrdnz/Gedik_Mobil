import 'package:cloud_firestore/cloud_firestore.dart';

class CareerPlan {
  final String id;
  final String userId;
  final String careerAdvice;
  final List<String> careerPaths;
  final List<String> skillsToDevelop;
  final Map<String, String> goals; // short, medium, long
  final DateTime createdAt;
  final String userDataSummary; // Summary of user's courses, plans, and preferences

  CareerPlan({
    required this.id,
    required this.userId,
    required this.careerAdvice,
    required this.careerPaths,
    required this.skillsToDevelop,
    required this.goals,
    required this.createdAt,
    required this.userDataSummary,
  });

  factory CareerPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CareerPlan(
      id: doc.id,
      userId: data['userId'] ?? '',
      careerAdvice: data['careerAdvice'] ?? '',
      careerPaths: List<String>.from(data['careerPaths'] ?? []),
      skillsToDevelop: List<String>.from(data['skillsToDevelop'] ?? []),
      goals: Map<String, String>.from(data['goals'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userDataSummary: data['userDataSummary'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'careerAdvice': careerAdvice,
      'careerPaths': careerPaths,
      'skillsToDevelop': skillsToDevelop,
      'goals': goals,
      'createdAt': Timestamp.fromDate(createdAt),
      'userDataSummary': userDataSummary,
    };
  }
}
