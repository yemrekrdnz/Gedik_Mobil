import 'package:cloud_firestore/cloud_firestore.dart';

class CourseSchedule {
  final String id;
  final String studentNumber;
  final String courseName;
  final String courseCode;
  final String instructor;
  final String day;
  final String startTime;
  final String endTime;
  final String classroom;
  final DateTime createdAt;

  CourseSchedule({
    required this.id,
    required this.studentNumber,
    required this.courseName,
    required this.courseCode,
    required this.instructor,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.classroom,
    required this.createdAt,
  });

  factory CourseSchedule.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CourseSchedule(
      id: doc.id,
      studentNumber: data['studentNumber'] ?? '',
      courseName: data['courseName'] ?? '',
      courseCode: data['courseCode'] ?? '',
      instructor: data['instructor'] ?? '',
      day: data['day'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      classroom: data['classroom'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentNumber': studentNumber,
      'courseName': courseName,
      'courseCode': courseCode,
      'instructor': instructor,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'classroom': classroom,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
