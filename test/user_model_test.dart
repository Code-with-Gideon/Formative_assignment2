import 'package:flutter_test/flutter_test.dart';
import 'package:campus_care/models/user_model.dart';

void main() {
  group('UserModel Domain-Based Role Detection Tests', () {
    test('identifies @alueducation.com as staff role', () {
      final staffUser = UserModel(
        uid: 'staff_123',
        email: 'facilities@alueducation.com',
        fullName: 'Jane Smith',
        role: 'staff',
        createdAt: DateTime.now(),
      );

      expect(staffUser.isStaff, isTrue);
      expect(staffUser.isStudent, isFalse);
    });

    test('automatically treats @alueducation.com as staff even if role field says student', () {
      final staffUser = UserModel(
        uid: 'staff_456',
        email: 'dean.office@alueducation.com',
        fullName: 'Dr. Dean',
        role: 'student', // accidental misconfiguration in doc
        createdAt: DateTime.now(),
      );

      expect(staffUser.isStaff, isTrue);
      expect(staffUser.isStudent, isFalse);
    });

    test('identifies @alustudent.com as student role', () {
      final studentUser = UserModel(
        uid: 'student_789',
        email: 'e.olowoyo@alustudent.com',
        fullName: 'Erioluwa Olowoyo',
        role: 'student',
        studentIdNumber: 'ALU-2024-001',
        createdAt: DateTime.now(),
      );

      expect(studentUser.isStudent, isTrue);
      expect(studentUser.isStaff, isFalse);
    });
  });
}
