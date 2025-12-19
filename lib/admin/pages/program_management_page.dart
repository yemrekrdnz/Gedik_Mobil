import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gedik_mobil/models/course_schedule.dart';

class ProgramManagementPage extends StatefulWidget {
  const ProgramManagementPage({super.key});

  @override
  State<ProgramManagementPage> createState() => _ProgramManagementPageState();
}

class _ProgramManagementPageState extends State<ProgramManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _studentNumberController = TextEditingController();

  final List<String> days = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];

  Future<void> _showCourseDialog({CourseSchedule? course}) async {
    final studentNumberController = TextEditingController(
      text: course?.studentNumber ?? _studentNumberController.text,
    );
    final courseNameController =
        TextEditingController(text: course?.courseName ?? '');
    final courseCodeController =
        TextEditingController(text: course?.courseCode ?? '');
    final instructorController =
        TextEditingController(text: course?.instructor ?? '');
    final classroomController =
        TextEditingController(text: course?.classroom ?? '');
    final startTimeController =
        TextEditingController(text: course?.startTime ?? '');
    final endTimeController = TextEditingController(text: course?.endTime ?? '');
    String selectedDay = course?.day ?? days[0];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(course == null ? 'Yeni Ders Ekle' : 'Ders Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: studentNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Öğrenci Numarası',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ders Adı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Ders Kodu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: instructorController,
                  decoration: const InputDecoration(
                    labelText: 'Öğretim Görevlisi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'Gün',
                    border: OutlineInputBorder(),
                  ),
                  items: days.map((day) {
                    return DropdownMenuItem(value: day, child: Text(day));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedDay = value!);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Başlangıç (09:00)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: endTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Bitiş (11:00)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: classroomController,
                  decoration: const InputDecoration(
                    labelText: 'Sınıf',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (studentNumberController.text.isEmpty ||
                    courseNameController.text.isEmpty ||
                    courseCodeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen zorunlu alanları doldurun'),
                    ),
                  );
                  return;
                }

                CourseSchedule newCourse = CourseSchedule(
                  id: course?.id ?? '',
                  studentNumber: studentNumberController.text.trim(),
                  courseName: courseNameController.text.trim(),
                  courseCode: courseCodeController.text.trim(),
                  instructor: instructorController.text.trim(),
                  day: selectedDay,
                  startTime: startTimeController.text.trim(),
                  endTime: endTimeController.text.trim(),
                  classroom: classroomController.text.trim(),
                  createdAt: DateTime.now(),
                );

                if (course == null) {
                  await _firestore
                      .collection('course_schedules')
                      .add(newCourse.toFirestore());
                } else {
                  await _firestore
                      .collection('course_schedules')
                      .doc(course.id)
                      .update(newCourse.toFirestore());
                }

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                foregroundColor: Colors.white,
              ),
              child: Text(course == null ? 'Ekle' : 'Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCourse(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ders Sil'),
        content: const Text('Bu dersi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('course_schedules').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Yönetimi'),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _studentNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Öğrenci Numarası ile Ara',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _studentNumberController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _studentNumberController.text.isEmpty
                  ? _firestore
                      .collection('course_schedules')
                      .orderBy('studentNumber')
                      .snapshots()
                  : _firestore
                      .collection('course_schedules')
                      .where('studentNumber',
                          isEqualTo: _studentNumberController.text)
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
                    child: Text('Henüz ders programı yok'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          course.courseName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kod: ${course.courseCode}'),
                            Text('Öğrenci: ${course.studentNumber}'),
                            Text('Hoca: ${course.instructor}'),
                            Text(
                              '${course.day} ${course.startTime}-${course.endTime} | ${course.classroom}',
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showCourseDialog(course: course),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCourse(course.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCourseDialog(),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
