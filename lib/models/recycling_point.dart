class RecyclingPoint {
  const RecyclingPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.acceptedTypes,
    this.address,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> acceptedTypes;
  final String? address;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': {
        'lat': latitude,
        'lng': longitude,
      },
      'acceptedTypes': acceptedTypes,
      'address': address,
    };
  }

  factory RecyclingPoint.fromMap(String id, Map<String, dynamic> map) {
    final location = map['location'] as Map<String, dynamic>? ?? const {};

    return RecyclingPoint(
      id: id,
      name: map['name'] as String? ?? '',
      latitude: (location['lat'] as num?)?.toDouble() ?? 0,
      longitude: (location['lng'] as num?)?.toDouble() ?? 0,
      acceptedTypes:
          (map['acceptedTypes'] as List<dynamic>? ?? const <dynamic>[])
              .map((type) => type.toString())
              .toList(),
      address: map['address'] as String?,
    );
  }
}
