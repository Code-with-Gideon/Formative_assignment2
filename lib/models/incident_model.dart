import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class IncidentModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String? imageUrl;
  final IncidentStatus status;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? staffNotes;
  final String? assignedStaffName;

  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.imageUrl,
    required this.status,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.createdAt,
    required this.updatedAt,
    this.staffNotes,
    this.assignedStaffName,
  });

  IncidentCategory get categoryInfo => IncidentCategory.findById(category);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      'status': status.name,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'staffNotes': staffNotes,
      'assignedStaffName': assignedStaffName,
    };
  }

  factory IncidentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return IncidentModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'facilities',
      location: data['location'] ?? 'Campus',
      imageUrl: data['imageUrl'],
      status: IncidentStatus.fromString(data['status']),
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? 'Anonymous Student',
      studentEmail: data['studentEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      staffNotes: data['staffNotes'],
      assignedStaffName: data['assignedStaffName'],
    );
  }

  IncidentModel copyWith({
    String? title,
    String? description,
    String? category,
    String? location,
    String? imageUrl,
    IncidentStatus? status,
    DateTime? updatedAt,
    String? staffNotes,
    String? assignedStaffName,
  }) {
    return IncidentModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      staffNotes: staffNotes ?? this.staffNotes,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
    );
  }
}
