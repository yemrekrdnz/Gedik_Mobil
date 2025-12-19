import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gedik_mobil/models/course_schedule.dart';

class ProgramPage extends StatelessWidget {
  const ProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Lütfen giriş yapın'));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        final studentNumber = userData?['studentNumber'] ?? '';

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('course_schedules')
              .where('studentNumber', isEqualTo: studentNumber)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Hata: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final courses = snapshot.data!.docs
                .map((doc) => CourseSchedule.fromFirestore(doc))
                .toList();

            if (courses.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Henüz ders programınız yok',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Günlere göre grupla
            final groupedCourses = <String, List<CourseSchedule>>{};
            for (var course in courses) {
              if (!groupedCourses.containsKey(course.day)) {
                groupedCourses[course.day] = [];
              }
              groupedCourses[course.day]!.add(course);
            }

            final days = [
              'Pazartesi',
              'Salı',
              'Çarşamba',
              'Perşembe',
              'Cuma',
              'Cumartesi',
              'Pazar'
            ];

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final dayCourses = groupedCourses[day] ?? [];

                if (dayCourses.isEmpty) {
                  return const SizedBox.shrink();
                }

                // Saate göre sırala
                dayCourses.sort((a, b) => a.startTime.compareTo(b.startTime));

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 136, 31, 96),
                          ),
                        ),
                        const Divider(),
                        ...dayCourses.map((course) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 136, 31, 96),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${course.startTime}\n${course.endTime}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.courseName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Kod: ${course.courseCode}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                          'Hoca: ${course.instructor}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                          'Sınıf: ${course.classroom}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
