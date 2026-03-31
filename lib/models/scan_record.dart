import 'package:razdelchik/models/waste_type.dart';

class ScanRecord {
  const ScanRecord({
    required this.id,
    required this.userId,
    required this.wasteName,
    required this.wasteType,
    required this.category,
    required this.pointsAwarded,
    required this.scannedAt,
    required this.imagePath,
    this.isFavorite = false,
  });

  final String id;
  final String userId;
  final String wasteName;
  final WasteType wasteType;
  final WasteCategory category;
  final int pointsAwarded;
  final DateTime scannedAt;
  final String imagePath;
  final bool isFavorite;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'wasteName': wasteName,
      'wasteType': wasteTypeToString(wasteType),
      'category': wasteCategoryToString(category),
      'pointsAwarded': pointsAwarded,
      'scannedAt': scannedAt.toIso8601String(),
      'imagePath': imagePath,
      'isFavorite': isFavorite,
    };
  }

  factory ScanRecord.fromMap(String id, Map<String, dynamic> map) {
    return ScanRecord(
      id: id,
      userId: map['userId'] as String? ?? '',
      wasteName: map['wasteName'] as String? ?? '',
      wasteType: wasteTypeFromString(map['wasteType'] as String? ?? 'unknown'),
      category: wasteCategoryFromString(
          map['category'] as String? ?? 'non_recyclable'),
      pointsAwarded: (map['pointsAwarded'] as num?)?.toInt() ?? 0,
      scannedAt: DateTime.tryParse(map['scannedAt'] as String? ?? '') ??
          DateTime.now(),
      imagePath: map['imagePath'] as String? ?? '',
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }
}
