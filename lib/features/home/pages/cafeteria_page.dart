import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gedik_mobil/models/cafeteria_menu.dart';

class CafeteriaPage extends StatelessWidget {
  const CafeteriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cafeteria_menus')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .orderBy('date')
          .limit(7)
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Henüz menü yok',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: menus.length,
          itemBuilder: (context, index) {
            final menu = menus[index];
            final isToday = _isSameDay(menu.date, today);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: isToday ? 5 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isToday
                    ? const BorderSide(
                        color: Color.fromARGB(255, 136, 31, 96),
                        width: 2,
                      )
                    : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(menu.date),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? const Color.fromARGB(255, 136, 31, 96)
                                : Colors.black,
                          ),
                        ),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 136, 31, 96),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'BUGÜN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (menu.breakfast.isNotEmpty)
                      _buildMealSection('Kahvaltı', menu.breakfast, Icons.free_breakfast),
                    if (menu.lunch.isNotEmpty)
                      _buildMealSection('Öğle Yemeği', menu.lunch, Icons.lunch_dining),
                    if (menu.dinner.isNotEmpty)
                      _buildMealSection('Akşam Yemeği', menu.dinner, Icons.dinner_dining),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMealSection(String title, List<MenuItem> items, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color.fromARGB(255, 136, 31, 96)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 136, 31, 96),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 28, bottom: 4),
                child: Text('• ${item.name}'),
              )),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return '${date.day}/${date.month}/${date.year} - ${days[date.weekday - 1]}';
  }
}
