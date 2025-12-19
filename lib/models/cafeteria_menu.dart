import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String name;
  final String? calories;

  MenuItem({
    required this.name,
    this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      name: map['name'] ?? '',
      calories: map['calories'],
    );
  }
}

class CafeteriaMenu {
  final String id;
  final DateTime date;
  final List<MenuItem> breakfast;
  final List<MenuItem> lunch;
  final List<MenuItem> dinner;
  final DateTime createdAt;
  final String createdBy;

  CafeteriaMenu({
    required this.id,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.createdAt,
    required this.createdBy,
  });

  factory CafeteriaMenu.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CafeteriaMenu(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      breakfast: (data['breakfast'] as List)
          .map((item) => MenuItem.fromMap(item))
          .toList(),
      lunch: (data['lunch'] as List)
          .map((item) => MenuItem.fromMap(item))
          .toList(),
      dinner: (data['dinner'] as List)
          .map((item) => MenuItem.fromMap(item))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'breakfast': breakfast.map((item) => item.toMap()).toList(),
      'lunch': lunch.map((item) => item.toMap()).toList(),
      'dinner': dinner.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }
}
