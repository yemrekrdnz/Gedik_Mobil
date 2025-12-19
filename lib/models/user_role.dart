enum UserRole {
  student,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Öğrenci';
      case UserRole.admin:
        return 'Yönetici';
    }
  }

  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}
