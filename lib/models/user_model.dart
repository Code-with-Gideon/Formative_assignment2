import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role; // 'student' or 'staff'
  final String? studentIdNumber;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.studentIdNumber,
    required this.createdAt,
  });

  // Automatically treat @alueducation.com accounts as staff
  bool get isStaff => role == 'staff' || email.trim().toLowerCase().endsWith('@alueducation.com');
  bool get isStudent => !isStaff;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': isStaff ? 'staff' : 'student',
      'studentIdNumber': studentIdNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final email = (data['email'] as String? ?? '').trim().toLowerCase();
    final defaultRole = email.endsWith('@alueducation.com') ? 'staff' : 'student';

    return UserModel(
      uid: doc.id,
      email: email,
      fullName: data['fullName'] ?? '',
      role: data['role'] ?? defaultRole,
      studentIdNumber: data['studentIdNumber'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    final email = (map['email'] as String? ?? '').trim().toLowerCase();
    final defaultRole = email.endsWith('@alueducation.com') ? 'staff' : 'student';

    return UserModel(
      uid: id,
      email: email,
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? defaultRole,
      studentIdNumber: map['studentIdNumber'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
