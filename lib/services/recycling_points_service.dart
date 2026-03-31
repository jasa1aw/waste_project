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
        'name': 'Эко-Пункт Астана Орталығы',
        'location': {'lat': 51.128, 'lng': 71.430},
        'acceptedTypes': ['Plastic', 'Paper', 'Glass', 'Metal'],
        'address': 'Республика даңғылы, 10, Астана',
      },
      {
        'name': 'Пластик қабылдау (Сол жағалау)',
        'location': {'lat': 51.125, 'lng': 71.410},
        'acceptedTypes': ['Plastic'],
        'address': 'Сарайшық көшесі, 5, Астана',
      },
      {
        'name': 'Paper Recycling Есіл',
        'location': {'lat': 51.100, 'lng': 71.400},
        'acceptedTypes': ['Paper'],
        'address': 'Қабанбай батыр даңғылы, 15, Астана',
      },
      {
        'name': 'Шыны ыдыс Астана',
        'location': {'lat': 51.150, 'lng': 71.450},
        'acceptedTypes': ['Glass'],
        'address': 'Абай көшесі, 25, Астана',
      },
      {
        'name': 'ЭкоОрталық Органика',
        'location': {'lat': 51.160, 'lng': 71.440},
        'acceptedTypes': ['Organic'],
        'address': 'Кенесары көшесі, 40, Астана',
      },

      // Караганда
      {
        'name': 'Эко Қарағанды Ресайклинг',
        'location': {'lat': 49.801, 'lng': 73.102},
        'acceptedTypes': ['Plastic', 'Paper', 'Glass', 'Metal', 'Organic'],
        'address': 'Бұқар жырау даңғылы, 20, Қарағанды',
      },
      {
        'name': 'Макулатура жинау Орталығы',
        'location': {'lat': 49.790, 'lng': 73.110},
        'acceptedTypes': ['Paper'],
        'address': 'Нұркен Әбдіров көшесі, 12, Қарағанды',
      },
      {
        'name': 'Металл және пластик қабылдау',
        'location': {'lat': 49.810, 'lng': 73.090},
        'acceptedTypes': ['Metal', 'Plastic'],
        'address': 'Чкалов көшесі, 8, Қарағанды',
      },
    ];

    for (final p in points) {
      batch.set(collection.doc(), p);
    }

    await batch.commit();
  }

  Future<void> deleteAndReseedPoints() async {
    final collection = _firestore.collection('recycling_points');
    final snapshots = await collection.get();
    
    // Firestore batch supports up to 500 operations
    final batch = _firestore.batch();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    
    await seedInitialPoints();
  }
}
