enum WasteType {
  plastic,
  paper,
  glass,
  metal,
  organic,
  unknown,
}

enum WasteCategory {
  recyclable,
  nonRecyclable,
}

WasteType wasteTypeFromString(String value) {
  switch (value.toLowerCase()) {
    case 'plastic':
      return WasteType.plastic;
    case 'paper':
      return WasteType.paper;
    case 'glass':
      return WasteType.glass;
    case 'metal':
      return WasteType.metal;
    case 'organic':
      return WasteType.organic;
    default:
      return WasteType.unknown;
  }
}

String wasteTypeToString(WasteType type) {
  return type.name;
}

WasteCategory wasteCategoryFromString(String value) {
  switch (value.toLowerCase()) {
    case 'recyclable':
      return WasteCategory.recyclable;
    default:
      return WasteCategory.nonRecyclable;
  }
}

String wasteCategoryToString(WasteCategory category) {
  return category == WasteCategory.recyclable ? 'recyclable' : 'non_recyclable';
}
