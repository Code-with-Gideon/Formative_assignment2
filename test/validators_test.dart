import 'package:flutter_test/flutter_test.dart';
import 'package:campus_care/core/utils/validators.dart';

void main() {
  group('Validators Test Suite', () {
    test('validates student ALU email correctly', () {
      final valid = Validators.validateEmail('a.hassan@alustudent.com');
      expect(valid, isNull);
    });

    test('validates staff ALU email correctly', () {
      final valid = Validators.validateEmail('facilities@alueducation.com');
      expect(valid, isNull);
    });

    test('rejects non-ALU generic email address', () {
      final invalid = Validators.validateEmail('john.doe@gmail.com');
      expect(invalid, isNotNull);
      expect(invalid, contains('Only ALU emails'));
    });

    test('rejects empty email', () {
      final empty = Validators.validateEmail('');
      expect(empty, isNotNull);
    });

    test('validates password length correctly', () {
      expect(Validators.validatePassword('12345'), isNotNull);
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('validates required fields correctly', () {
      expect(Validators.validateRequired('', 'title'), isNotNull);
      expect(Validators.validateRequired('Water leak in Block B', 'title'), isNull);
    });
  });
}
