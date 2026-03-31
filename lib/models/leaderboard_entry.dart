class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.ecoPoints,
    required this.scansCount,
    required this.streakDays,
    required this.lastActiveAt,
  });

  final String userId;
  final String displayName;
  final int ecoPoints;
  final int scansCount;
  final int streakDays;
  final DateTime? lastActiveAt;

  factory LeaderboardEntry.fromMap(String id, Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: id,
      displayName: map['displayName'] as String? ?? 'Eco User',
      ecoPoints: (map['ecoPoints'] as num?)?.toInt() ?? 0,
      scansCount: (map['scansCount'] as num?)?.toInt() ?? 0,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      lastActiveAt: DateTime.tryParse(map['lastActiveAt'] as String? ?? ''),
    );
  }
}
