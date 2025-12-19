import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gedik_mobil/models/cafeteria_menu.dart';
import 'package:gedik_mobil/services/auth_service.dart';

class CafeteriaManagementPage extends StatefulWidget {
  const CafeteriaManagementPage({super.key});

  @override
  State<CafeteriaManagementPage> createState() =>
      _CafeteriaManagementPageState();
}

class _CafeteriaManagementPageState extends State<CafeteriaManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  DateTime selectedDate = DateTime.now();

  Future<void> _showMenuDialog({CafeteriaMenu? menu}) async {
    List<TextEditingController> breakfastControllers = menu != null
        ? menu.breakfast.map((item) => TextEditingController(text: item.name)).toList()
        : [TextEditingController()];
    List<TextEditingController> lunchControllers = menu != null
        ? menu.lunch.map((item) => TextEditingController(text: item.name)).toList()
        : [TextEditingController()];
    List<TextEditingController> dinnerControllers = menu != null
        ? menu.dinner.map((item) => TextEditingController(text: item.name)).toList()
        : [TextEditingController()];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(menu == null ? 'Yeni Menü' : 'Menü Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarih Seçici
                ListTile(
                  title: const Text('Tarih'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                const Divider(),
                
                // Kahvaltı
                _buildMealSection(
                  'Kahvaltı',
                  breakfastControllers,
                  setDialogState,
                ),
                const Divider(),
                
                // Öğle Yemeği
                _buildMealSection(
                  'Öğle Yemeği',
                  lunchControllers,
                  setDialogState,
                ),
                const Divider(),
                
                // Akşam Yemeği
                _buildMealSection(
                  'Akşam Yemeği',
                  dinnerControllers,
                  setDialogState,
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
                List<MenuItem> breakfast = breakfastControllers
                    .where((c) => c.text.isNotEmpty)
                    .map((c) => MenuItem(name: c.text.trim()))
                    .toList();
                List<MenuItem> lunch = lunchControllers
                    .where((c) => c.text.isNotEmpty)
                    .map((c) => MenuItem(name: c.text.trim()))
                    .toList();
                List<MenuItem> dinner = dinnerControllers
                    .where((c) => c.text.isNotEmpty)
                    .map((c) => MenuItem(name: c.text.trim()))
                    .toList();

                if (breakfast.isEmpty && lunch.isEmpty && dinner.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('En az bir öğün eklenmelidir'),
                    ),
                  );
                  return;
                }

                CafeteriaMenu newMenu = CafeteriaMenu(
                  id: menu?.id ?? '',
                  date: selectedDate,
                  breakfast: breakfast,
                  lunch: lunch,
                  dinner: dinner,
                  createdAt: DateTime.now(),
                  createdBy: _authService.currentUser!.uid,
                );

                if (menu == null) {
                  await _firestore
                      .collection('cafeteria_menus')
                      .add(newMenu.toFirestore());
                } else {
                  await _firestore
                      .collection('cafeteria_menus')
                      .doc(menu.id)
                      .update(newMenu.toFirestore());
                }

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                foregroundColor: Colors.white,
              ),
              child: Text(menu == null ? 'Oluştur' : 'Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(
    String title,
    List<TextEditingController> controllers,
    StateSetter setDialogState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                setDialogState(() {
                  controllers.add(TextEditingController());
                });
              },
            ),
          ],
        ),
        ...controllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Yemek ${index + 1}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                if (controllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setDialogState(() {
                        controllers.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Future<void> _deleteMenu(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Menü Sil'),
        content: const Text('Bu menüyü silmek istediğinizden emin misiniz?'),
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
      await _firestore.collection('cafeteria_menus').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yemekhane Menüsü Yönetimi'),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('cafeteria_menus')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final menus = snapshot.data!.docs
              .map((doc) => CafeteriaMenu.fromFirestore(doc))
              .toList();

          if (menus.isEmpty) {
            return const Center(
              child: Text('Henüz menü yok'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final menu = menus[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ExpansionTile(
                  title: Text(
                    '${menu.date.day}/${menu.date.month}/${menu.date.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          selectedDate = menu.date;
                          _showMenuDialog(menu: menu);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMenu(menu.id),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (menu.breakfast.isNotEmpty) ...[
                            const Text(
                              'Kahvaltı:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...menu.breakfast
                                .map((item) => Text('• ${item.name}')),
                            const SizedBox(height: 8),
                          ],
                          if (menu.lunch.isNotEmpty) ...[
                            const Text(
                              'Öğle Yemeği:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...menu.lunch.map((item) => Text('• ${item.name}')),
                            const SizedBox(height: 8),
                          ],
                          if (menu.dinner.isNotEmpty) ...[
                            const Text(
                              'Akşam Yemeği:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...menu.dinner.map((item) => Text('• ${item.name}')),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          selectedDate = DateTime.now();
          _showMenuDialog();
        },
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
