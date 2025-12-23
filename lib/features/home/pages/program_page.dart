import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gedik_mobil/services/notification_service.dart';

class ProgramPage extends StatefulWidget {
  const ProgramPage({super.key});

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Timer? _foregroundChecker;

  @override
  void initState() {
    super.initState();
    _foregroundChecker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkUpcomingPrograms(),
    );
  }

  @override
  void dispose() {
    _foregroundChecker?.cancel();
    super.dispose();
  }

  // 🔔 DIALOG
  void _showDialog(String title) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("⏰ Hatırlatma"),
        content: Text("$title 10 dakika sonra başlayacak"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  // 🔥 PROGRAM ZAMANI KONTROL (TRY–CATCH + LOG)
  Future<void> _checkUpcomingPrograms() async {
    if (!mounted || user == null) return;

    try {
      final now = DateTime.now();
      print("🕒 NOW: $now");

      final snapshot = await FirebaseFirestore.instance
          .collection('program_items')
          .where('userId', isEqualTo: user!.uid)
          .where('notified', isEqualTo: false)
          .get();

      print("📦 Kayıt sayısı: ${snapshot.docs.length}");

      for (final doc in snapshot.docs) {
        final data = doc.data();
        print("📄 RAW DATA: $data");

        final String dateStr = data['date'];
        final String timeStr = data['time'];

        print("📅 DATE RAW: $dateStr");
        print("⏰ TIME RAW: $timeStr");

        final dateParts = dateStr.split('-');
        final startTimeStr = timeStr.split(' - ')[0];
        final timeParts = startTimeStr.split(':');

        final programStart = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        print("🚀 PROGRAM START: $programStart");

        final notifyTime = programStart.subtract(const Duration(minutes: 1));
        print("🔔 NOTIFY TIME: $notifyTime");

        final diffSeconds = now.difference(notifyTime).inSeconds;
        print("⏱️ DIFF (sec): $diffSeconds");

        // 🔥 GENİŞ TOLERANS (EMULATOR DOSTU)
        if (diffSeconds >= 0 && diffSeconds <= 5) {
          print("✅ DIALOG TETİKLENİYOR");
          _showDialog(data['title']);
          await doc.reference.update({'notified': true});
        }
      }
    } catch (e, s) {
      print("❌ CHECK ERROR: $e");
      print("📌 STACK TRACE:\n$s");
    }
  }

  // ➕ PROGRAM EKLEME
  void _addProgramItem() {
    final titleCtrl = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Yeni Program Ekle",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: "Ders / Etkinlik Adı",
                      ),
                    ),

                    const SizedBox(height: 12),

                    OutlinedButton(
                      child: Text(
                        selectedDate == null
                            ? "Tarih Seç"
                            : "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}",
                      ),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2030),
                        );
                        if (d != null) setModalState(() => selectedDate = d);
                      },
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            child: Text(
                              startTime == null
                                  ? "Başlangıç"
                                  : startTime!.format(context),
                            ),
                            onPressed: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (t != null) setModalState(() => startTime = t);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            child: Text(
                              endTime == null
                                  ? "Bitiş"
                                  : endTime!.format(context),
                            ),
                            onPressed: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (t != null) setModalState(() => endTime = t);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: const Text("Ekle"),
                        onPressed: () async {
                          if (titleCtrl.text.isEmpty ||
                              selectedDate == null ||
                              startTime == null ||
                              endTime == null ||
                              user == null)
                            return;

                          final programStart = DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            startTime!.hour,
                            startTime!.minute,
                          );

                          final notifyTime = programStart.subtract(
                            const Duration(minutes: 1),
                          );

                          final doc = await FirebaseFirestore.instance
                              .collection('program_items')
                              .add({
                                'userId': user!.uid,
                                'title': titleCtrl.text,
                                'date':
                                    "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                                'time':
                                    "${startTime!.format(context)} - ${endTime!.format(context)}",
                                'createdAt': FieldValue.serverTimestamp(),
                                'notified': false,
                              });

                          await NotificationService.scheduleNotification(
                            id: doc.id.hashCode,
                            title: "⏰ Ders Yaklaşıyor",
                            body:
                                "${titleCtrl.text} 10 dakika sonra başlayacak",
                            scheduledDate: notifyTime,
                          );

                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text("Lütfen giriş yapın"));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Programım"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        onPressed: _addProgramItem,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('program_items')
            .where('userId', isEqualTo: user!.uid)
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Henüz program eklenmedi"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final notificationId = doc.id.hashCode;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                onDismissed: (_) async {
                  await NotificationService.cancelNotification(notificationId);
                  await doc.reference.delete();
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(
                      data['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${data['date']}\n${data['time']}"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
