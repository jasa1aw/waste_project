class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.ecoPoints,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final int ecoPoints;
  final DateTime createdAt;

  String get level {
    if (ecoPoints >= 1000) return 'Eco Hero';
    if (ecoPoints >= 400) return 'Eco Expert';
    if (ecoPoints >= 150) return 'Eco Learner';
    return 'Beginner';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'ecoPoints': ecoPoints,
      'createdAt': createdAt.toIso8601String(),
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
    );
  }
}
