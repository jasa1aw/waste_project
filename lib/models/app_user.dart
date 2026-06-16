class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.ecoPoints,
    required this.createdAt,
    this.isBlocked = false,
    this.role = 'user',
  });

  final String id;
  final String name;
  final String email;
  final int ecoPoints;
  final DateTime createdAt;
  final bool isBlocked;
  final String role;

  bool get isAdmin => role == 'admin';

  String get level {
    if (ecoPoints >= 1000) return 'Эко батыр';
    if (ecoPoints >= 400) return 'Эко сарапшы';
    if (ecoPoints >= 150) return 'Эко үйренуші';
    return 'Бастаушы';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'ecoPoints': ecoPoints,
      'createdAt': createdAt.toIso8601String(),
      'isBlocked': isBlocked,
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      ecoPoints: (map['ecoPoints'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isBlocked: map['isBlocked'] as bool? ?? false,
      role: map['role'] as String? ?? 'user',
    );
  }
}
