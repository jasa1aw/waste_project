import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:razdelchik/models/recycling_point.dart';
import 'package:razdelchik/services/recycling_points_service.dart';
import 'package:razdelchik/widgets/common/soft_card.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const LatLng _defaultCenter = LatLng(51.128, 71.430); // Астана по умолчанию

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Қабылдау пункттері'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Деректерді жаңарту',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Деректер жаңартылуда...')),
              );
              RecyclingPointsService().deleteAndReseedPoints().then((_) {
                 if(context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Дайын!')),
                   );
                 }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<RecyclingPoint>>(
        stream: RecyclingPointsService().watchPoints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Карта қатесі: ${snapshot.error}'));
          }

          final points = snapshot.data ?? const <RecyclingPoint>[];
          
          final markers = points
              .map(
                (point) => Marker(
                  point: LatLng(point.latitude, point.longitude),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _openPointSheet(context, point),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
              )
              .toList();

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: points.isNotEmpty
                      ? LatLng(points.first.latitude, points.first.longitude)
                      : _defaultCenter,
                  initialZoom: 12.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.razdelchik',
                  ),
                  MarkerLayer(
                    markers: markers,
                  ),
                ],
              ),
              if (points.isEmpty)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  child: SoftCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Қабылдау пункттері әлі қосылмаған. Астана мен Қарағандының тесттік деректерімен толтыру керек пе?',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            RecyclingPointsService().seedInitialPoints();
                          },
                          child: const Text('Нүктелерді қосу'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openPointSheet(BuildContext context, RecyclingPoint point) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: false, // Отключаем safeArea оболочку, чтобы шторка доходила до самого низа
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          // Добавляем отступ снизу вручную на размер Home Indicator'а
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.paddingOf(context).bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                point.name, 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (point.address != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        point.address!, 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: point.acceptedTypes
                    .map(
                      (type) => Chip(
                        label: Text(_translateType(type)),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  String _translateType(String type) {
    switch (type.toLowerCase()) {
      case 'plastic':
        return 'Пластик';
      case 'paper':
        return 'Қағаз';
      case 'glass':
        return 'Шыны';
      case 'metal':
        return 'Металл';
      case 'organic':
        return 'Органика';
      default:
        return type;
    }
  }
}
