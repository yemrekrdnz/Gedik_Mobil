import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gedik_mobil/models/announcement.dart';
import 'package:gedik_mobil/services/auth_service.dart';
import 'package:gedik_mobil/models/app_user.dart';

class AnnouncementManagementPage extends StatefulWidget {
  const AnnouncementManagementPage({super.key});

  @override
  State<AnnouncementManagementPage> createState() =>
      _AnnouncementManagementPageState();
}

class _AnnouncementManagementPageState
    extends State<AnnouncementManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> _showAnnouncementDialog({Announcement? announcement}) async {
    final titleController =
        TextEditingController(text: announcement?.title ?? '');
    final contentController =
        TextEditingController(text: announcement?.content ?? '');
    final tagsController =
        TextEditingController(text: announcement?.tags.join(', ') ?? '');
    bool isActive = announcement?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            announcement == null ? 'Yeni Duyuru' : 'Duyuru Düzenle',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Başlık',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'İçerik',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Etiketler (virgülle ayırın)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Aktif'),
                  value: isActive,
                  onChanged: (value) {
                    setDialogState(() {
                      isActive = value ?? true;
                    });
                  },
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
                if (titleController.text.isEmpty ||
                    contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen tüm alanları doldurun'),
                    ),
                  );
                  return;
                }

                AppUser? user =
                    await _authService.getUserData(_authService.currentUser!.uid);

                List<String> tags = tagsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                if (announcement == null) {
                  // Yeni duyuru oluştur
                  Announcement newAnnouncement = Announcement(
                    id: '',
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    authorId: _authService.currentUser!.uid,
                    authorName: user?.name ?? 'Admin',
                    createdAt: DateTime.now(),
                    isActive: isActive,
                    tags: tags,
                  );

                  await _firestore
                      .collection('announcements')
                      .add(newAnnouncement.toFirestore());
                } else {
                  // Duyuru güncelle
                  Announcement updatedAnnouncement = Announcement(
                    id: announcement.id,
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    authorId: announcement.authorId,
                    authorName: announcement.authorName,
                    createdAt: announcement.createdAt,
                    updatedAt: DateTime.now(),
                    isActive: isActive,
                    tags: tags,
                  );

                  await _firestore
                      .collection('announcements')
                      .doc(announcement.id)
                      .update(updatedAnnouncement.toFirestore());
                }

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                foregroundColor: Colors.white,
              ),
              child: Text(announcement == null ? 'Oluştur' : 'Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAnnouncement(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyuru Sil'),
        content: const Text('Bu duyuruyu silmek istediğinizden emin misiniz?'),
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
      await _firestore.collection('announcements').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyuru Yönetimi'),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('announcements')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final announcements = snapshot.data!.docs
              .map((doc) => Announcement.fromFirestore(doc))
              .toList();

          if (announcements.isEmpty) {
            return const Center(
              child: Text('Henüz duyuru yok'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    announcement.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        announcement.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Yazar: ${announcement.authorName} • ${_formatDate(announcement.createdAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (announcement.tags.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: announcement.tags
                              .map((tag) => Chip(
                                    label: Text(tag),
                                    labelStyle: const TextStyle(fontSize: 10),
                                    padding: EdgeInsets.zero,
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        announcement.isActive
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: announcement.isActive ? Colors.green : Colors.red,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showAnnouncementDialog(announcement: announcement),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAnnouncement(announcement.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAnnouncementDialog(),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
