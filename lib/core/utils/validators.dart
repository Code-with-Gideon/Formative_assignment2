class Validators {
  // Validate email and ensure it matches ALU student or staff domains
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address.';
    }
    final email = value.trim().toLowerCase();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    // ALU specific domain rule per assignment specification
    final isAluStudent = email.endsWith('@alustudent.com');
    final isAluStaff = email.endsWith('@alueducation.com');
    if (!isAluStudent && !isAluStaff) {
      return 'Only ALU emails (@alustudent.com or @alueducation.com) are allowed.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please provide $fieldName.';
    }
    return null;
  }
}
