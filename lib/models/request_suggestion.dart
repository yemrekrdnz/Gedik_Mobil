import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus {
  pending,
  reviewing,
  approved,
  rejected,
}

extension RequestStatusExtension on RequestStatus {
  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Beklemede';
      case RequestStatus.reviewing:
        return 'İnceleniyor';
      case RequestStatus.approved:
        return 'Onaylandı';
      case RequestStatus.rejected:
        return 'Reddedildi';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static RequestStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'reviewing':
        return RequestStatus.reviewing;
      case 'approved':
        return RequestStatus.approved;
      case 'rejected':
        return RequestStatus.rejected;
      default:
        return RequestStatus.pending;
    }
  }
}

class RequestSuggestion {
  final String id;
  final String userId;
  final String userName;
  final String studentNumber;
  final String title;
  final String content;
  final RequestStatus status;
  final DateTime createdAt;
  final String? adminResponse;
  final String? respondedBy;
  final DateTime? respondedAt;
  final bool isRequest; // true = istek, false = öneri

  RequestSuggestion({
    required this.id,
    required this.userId,
    required this.userName,
    required this.studentNumber,
    required this.title,
    required this.content,
    required this.status,
    required this.createdAt,
    this.adminResponse,
    this.respondedBy,
    this.respondedAt,
    this.isRequest = true,
  });

  factory RequestSuggestion.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RequestSuggestion(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      studentNumber: data['studentNumber'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      status: RequestStatusExtension.fromString(data['status'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      adminResponse: data['adminResponse'],
      respondedBy: data['respondedBy'],
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      isRequest: data['isRequest'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'studentNumber': studentNumber,
      'title': title,
      'content': content,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'adminResponse': adminResponse,
      'respondedBy': respondedBy,
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'isRequest': isRequest,
    };
  }
}
