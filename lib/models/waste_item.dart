import 'package:razdelchik/models/waste_type.dart';

class WasteItem {
  const WasteItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.binColor,
    required this.explanation,
    this.isFavorite = false,
    this.aiConfidence,
    this.aiSuggestion,
  });

  final String id;
  final String name;
  final WasteType type;
  final WasteCategory category;
  final String binColor;
  final String explanation;
  final bool isFavorite;
  final double? aiConfidence;
  final String? aiSuggestion;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': wasteTypeToString(type),
      'category': wasteCategoryToString(category),
      'binColor': binColor,
      'explanation': explanation,
      'isFavorite': isFavorite,
      'aiConfidence': aiConfidence,
      'aiSuggestion': aiSuggestion,
    };
  }

  factory WasteItem.fromMap(String id, Map<String, dynamic> map) {
    return WasteItem(
      id: id,
      name: map['name'] as String? ?? '',
      type: wasteTypeFromString(map['type'] as String? ?? 'unknown'),
      category: wasteCategoryFromString(
          map['category'] as String? ?? 'non_recyclable'),
      binColor: map['binColor'] as String? ?? 'red',
      explanation: map['explanation'] as String? ?? '',
      isFavorite: map['isFavorite'] as bool? ?? false,
      aiConfidence: (map['aiConfidence'] as num?)?.toDouble(),
      aiSuggestion: map['aiSuggestion'] as String?,
    );
  }
}
