class UserAccount {
  UserAccount({
    required this.userId,
    required this.username,
    this.email,
    this.customFields = const {},
  });

  final int userId;
  final String username;
  final String? email;
  final Map<String, String> customFields;

  factory UserAccount.fromApi(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ??
        json['me'] as Map<String, dynamic>? ??
        json;
    final rawFields = user['custom_fields'];
    final fields = <String, String>{};
    if (rawFields is Map) {
      rawFields.forEach((key, value) {
        if (value != null) fields[key.toString()] = value.toString();
      });
    }
    return UserAccount(
      userId: _parseUserId(user['user_id']),
      username: user['username']?.toString() ?? '',
      email: user['email']?.toString(),
      customFields: fields,
    );
  }

  static int _parseUserId(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.parse(raw);
    throw FormatException('user_id mancante nella risposta API');
  }

  bool get needsProfileFields {
    const core = ['firstName', 'lastName'];
    for (final key in core) {
      if ((customFields[key] ?? '').trim().isEmpty) return true;
    }
    return false;
  }
}
