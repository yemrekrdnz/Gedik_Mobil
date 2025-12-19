import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gedik_mobil/models/request_suggestion.dart';
import 'package:gedik_mobil/services/auth_service.dart';
import 'package:gedik_mobil/models/app_user.dart';

class RequestSuggestionPage extends StatefulWidget {
  const RequestSuggestionPage({super.key});

  @override
  State<RequestSuggestionPage> createState() => _RequestSuggestionPageState();
}

class _RequestSuggestionPageState extends State<RequestSuggestionPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showCreateDialog(bool isRequest) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRequest ? 'Yeni İstek' : 'Yeni Öneri'),
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
                  labelText: 'Açıklama',
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
              if (titleController.text.isEmpty ||
                  contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen tüm alanları doldurun'),
                  ),
                );
                return;
              }

              final user = _authService.currentUser;
              if (user == null) return;

              AppUser? userData = await _authService.getUserData(user.uid);

              RequestSuggestion newItem = RequestSuggestion(
                id: '',
                userId: user.uid,
                userName: userData?.name ?? 'Kullanıcı',
                studentNumber: userData?.studentNumber ?? '',
                title: titleController.text.trim(),
                content: contentController.text.trim(),
                status: RequestStatus.pending,
                createdAt: DateTime.now(),
                isRequest: isRequest,
              );

              await _firestore
                  .collection('requests_suggestions')
                  .add(newItem.toFirestore());

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${isRequest ? "İstek" : "Öneri"} gönderildi',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 136, 31, 96),
              foregroundColor: Colors.white,
            ),
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isRequest) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Lütfen giriş yapın'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('requests_suggestions')
          .where('userId', isEqualTo: user.uid)
          .where('isRequest', isEqualTo: isRequest)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs
            .map((doc) => RequestSuggestion.fromFirestore(doc))
            .toList();

        return Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isRequest ? Icons.question_answer : Icons.lightbulb,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz ${isRequest ? "istek" : "öneri"} yok',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ExpansionTile(
                            leading: _getStatusIcon(item.status),
                            title: Text(
                              item.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  item.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Durum: ${item.status.displayName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(item.status),
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.content),
                                    if (item.adminResponse != null) ...[
                                      const SizedBox(height: 16),
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Admin Yanıtı:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 136, 31, 96),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(item.adminResponse!),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yanıtlayan: ${item.respondedBy}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateDialog(isRequest),
                  icon: const Icon(Icons.add),
                  label: Text(isRequest ? 'Yeni İstek' : 'Yeni Öneri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Icon _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case RequestStatus.reviewing:
        return const Icon(Icons.visibility, color: Colors.blue);
      case RequestStatus.approved:
        return const Icon(Icons.check_circle, color: Colors.green);
      case RequestStatus.rejected:
        return const Icon(Icons.cancel, color: Colors.red);
    }
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.reviewing:
        return Colors.blue;
      case RequestStatus.approved:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstek & Öneri'),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'İsteklerim'),
            Tab(text: 'Önerilerim'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(true),
          _buildList(false),
        ],
      ),
    );
  }
}
