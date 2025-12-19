import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gedik_mobil/models/request_suggestion.dart';
import 'package:gedik_mobil/services/auth_service.dart';
import 'package:gedik_mobil/models/app_user.dart';

class RequestSuggestionManagementPage extends StatefulWidget {
  const RequestSuggestionManagementPage({super.key});

  @override
  State<RequestSuggestionManagementPage> createState() =>
      _RequestSuggestionManagementPageState();
}

class _RequestSuggestionManagementPageState
    extends State<RequestSuggestionManagementPage>
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

  Future<void> _showResponseDialog(RequestSuggestion item) async {
    final responseController =
        TextEditingController(text: item.adminResponse ?? '');
    RequestStatus selectedStatus = item.status;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${item.isRequest ? "İstek" : "Öneri"} Yanıtla'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Başlık: ${item.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('İçerik: ${item.content}'),
                const SizedBox(height: 8),
                Text('Gönderen: ${item.userName} (${item.studentNumber})'),
                const SizedBox(height: 16),
                DropdownButtonFormField<RequestStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Durum',
                    border: OutlineInputBorder(),
                  ),
                  items: RequestStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedStatus = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: responseController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Yanıt',
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
                AppUser? admin = await _authService
                    .getUserData(_authService.currentUser!.uid);

                await _firestore
                    .collection('requests_suggestions')
                    .doc(item.id)
                    .update({
                  'status': selectedStatus.value,
                  'adminResponse': responseController.text.trim(),
                  'respondedBy': admin?.name ?? 'Admin',
                  'respondedAt': Timestamp.fromDate(DateTime.now()),
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                foregroundColor: Colors.white,
              ),
              child: const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(bool isRequest) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('requests_suggestions')
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

        if (items.isEmpty) {
          return Center(
            child: Text('Henüz ${isRequest ? "istek" : "öneri"} yok'),
          );
        }

        return ListView.builder(
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.userName} (${item.studentNumber}) • ${_formatDate(item.createdAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
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
                trailing: IconButton(
                  icon: const Icon(Icons.reply),
                  onPressed: () => _showResponseDialog(item),
                ),
                children: [
                  if (item.adminResponse != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Yanıtı:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(item.adminResponse!),
                          const SizedBox(height: 8),
                          Text(
                            'Yanıtlayan: ${item.respondedBy} • ${item.respondedAt != null ? _formatDate(item.respondedAt!) : ""}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstek & Öneri Yönetimi'),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'İstekler'),
            Tab(text: 'Öneriler'),
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
