/// User-facing copy for the student signup form (keeps messages consistent with API rules).
abstract final class RegistrationValidators {
  static String? fullName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) {
      return 'Please enter your name.';
    }
    if (v.length < 2) {
      return 'Name should be at least 2 characters.';
    }
    return null;
  }

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) {
      return 'Please enter your email address.';
    }
    if (!_email.hasMatch(v)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) {
      return 'Please create a password.';
    }
    if (v.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return 'Password must include at least one number.';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) {
      return 'Please enter your password.';
    }
    return null;
  }

  static String? phone(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) {
      return 'Please enter your phone number.';
    }
    if (v.length < 7) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final v = value ?? '';
    if (v.isEmpty) {
      return 'Please retype your password.';
    }
    if (v != password) {
      return 'Passwords do not match.';
    }
    return null;
  }

  /// Matches API `PasswordUpdateRequest` (min length 6).
  static String? changePasswordField(String? value, {required String emptyMessage}) {
    final v = value ?? '';
    if (v.isEmpty) {
      return emptyMessage;
    }
    if (v.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? changePasswordNew(String? value, String currentPassword) {
    final err = changePasswordField(value, emptyMessage: 'Please enter a new password.');
    if (err != null) return err;
    if (value == currentPassword) {
      return 'New password must be different from your current password.';
    }
    return null;
  }
}
