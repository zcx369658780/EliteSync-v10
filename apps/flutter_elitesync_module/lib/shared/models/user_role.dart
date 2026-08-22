class UserRole {
  const UserRole._();

  static String normalizeValue(Object? value) {
    final candidate = value?.toString().trim().toLowerCase() ?? '';
    return candidate == 'admin' ? 'admin' : 'user';
  }

  static String fromJson(Map<String, dynamic> json) {
    for (final key in const ['role', 'group', 'user_group', 'account_group']) {
      final normalized = normalizeValue(json[key]);
      if (normalized == 'admin') return 'admin';
    }
    return 'user';
  }

  static bool isAdmin(String? role) => normalizeValue(role) == 'admin';
}
