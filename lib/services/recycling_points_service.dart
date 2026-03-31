import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razdelchik/models/recycling_point.dart';

class RecyclingPointsService {
  RecyclingPointsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<RecyclingPoint>> watchPoints() {
    return _firestore.collection('recycling_points').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RecyclingPoint.fromMap(doc.id, doc.data()))
          .where((point) => point.latitude != 0 && point.longitude != 0)
          .toList();
    });
  }

  Future<void> seedInitialPoints() async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('recycling_points');

    final points = [
      // Астана
      {
        'name': 'Эко-Пункт Астана Центр',
        'location': {'lat': 51.128, 'lng': 71.430},
        'acceptedTypes': ['Plastic', 'Paper', 'Glass', 'Metal'],
        'address': 'пр. Республики, 10, Астана',
      },
      {
        'name': 'Прием пластика (Левый берег)',
        'location': {'lat': 51.125, 'lng': 71.410},
        'acceptedTypes': ['Plastic'],
        'address': 'ул. Сарайшык, 5, Астана',
      },
      {
        'name': 'Paper Recycling Есиль',
        'location': {'lat': 51.100, 'lng': 71.400},
        'acceptedTypes': ['Paper'],
        'address': 'пр. Кабанбай Батыра, 15, Астана',
      },
      {
        'name': 'Стеклотара Астана',
        'location': {'lat': 51.150, 'lng': 71.450},
        'acceptedTypes': ['Glass'],
        'address': 'ул. Абая, 25, Астана',
      },
      {
        'name': 'ЭкоЦентр Органика',
        'location': {'lat': 51.160, 'lng': 71.440},
        'acceptedTypes': ['Organic'],
        'address': 'ул. Кенесары, 40, Астана',
      },

      // Караганда
      {
        'name': 'Эко Караганда Ресайклинг',
        'location': {'lat': 49.801, 'lng': 73.102},
        'acceptedTypes': ['Plastic', 'Paper', 'Glass', 'Metal', 'Organic'],
        'address': 'пр. Бухар Жырау, 20, Караганда',
      },
      {
        'name': 'Сбор Макулатуры Центр',
        'location': {'lat': 49.790, 'lng': 73.110},
        'acceptedTypes': ['Paper'],
        'address': 'ул. Нуркена Абдирова, 12, Караганда',
      },
      {
        'name': 'Прием металла и пластика',
        'location': {'lat': 49.810, 'lng': 73.090},
        'acceptedTypes': ['Metal', 'Plastic'],
        'address': 'ул. Чкалова, 8, Караганда',
      },
    ];

    for (final p in points) {
      batch.set(collection.doc(), p);
    }

    await batch.commit();
  }
}
