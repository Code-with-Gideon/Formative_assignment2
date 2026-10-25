import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class TimelineEventModel {
  final String id;
  final String title;
  final String? note;
  final IncidentStatus status;
  final String authorName;
  final String authorRole;
  final DateTime timestamp;

  TimelineEventModel({
    required this.id,
    required this.title,
    this.note,
    required this.status,
    required this.authorName,
    required this.authorRole,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'note': note,
      'status': status.name,
      'authorName': authorName,
      'authorRole': authorRole,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory TimelineEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TimelineEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      note: data['note'],
      status: IncidentStatus.fromString(data['status']),
      authorName: data['authorName'] ?? 'Staff',
      authorRole: data['authorRole'] ?? 'staff',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
