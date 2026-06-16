import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:razdelchik/core/theme/app_theme.dart';
import 'package:razdelchik/models/recycling_point.dart';
import 'package:razdelchik/services/admin/admin_recycling_service.dart';
import 'package:razdelchik/screens/admin/recycling_points/admin_recycling_form_sheet.dart';

enum _ViewMode { list, map }

class AdminRecyclingScreen extends StatefulWidget {
  const AdminRecyclingScreen({super.key});

  @override
  State<AdminRecyclingScreen> createState() => _AdminRecyclingScreenState();
}

class _AdminRecyclingScreenState extends State<AdminRecyclingScreen> {
  final _service = AdminRecyclingService();
  _ViewMode _viewMode = _ViewMode.list;

  void _openForm({RecyclingPoint? point}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AdminRecyclingFormSheet(point: point),
    );
  }

  Future<void> _confirmDelete(RecyclingPoint point) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Жою'),
        content: Text('"${point.name}" пунктін жойғыңыз келе ме?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Болдырмау'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Жою'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deletePoint(point.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пункт жойылды')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Қате: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SegmentedButton<_ViewMode>(
            segments: const [
              ButtonSegment(
                value: _ViewMode.list,
                icon: Icon(Icons.list),
                label: Text('Тізім'),
              ),
              ButtonSegment(
                value: _ViewMode.map,
                icon: Icon(Icons.map_outlined),
                label: Text('Карта'),
              ),
            ],
            selected: {_viewMode},
            onSelectionChanged: (sel) =>
                setState(() => _viewMode = sel.first),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primaryGreen;
                }
                return null;
              }),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              StreamBuilder<List<RecyclingPoint>>(
                stream: _service.watchAllPoints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Қате: ${snapshot.error}'));
                  }
                  final points = snapshot.data ?? [];

                  if (_viewMode == _ViewMode.list) {
                    return _ListBody(
                      points: points,
                      onEdit: (p) => _openForm(point: p),
                      onDelete: _confirmDelete,
                    );
                  } else {
                    return _MapBody(points: points);
                  }
                },
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () => _openForm(),
                  backgroundColor: AppTheme.primaryGreen,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// List view
// ---------------------------------------------------------------------------

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.points,
    required this.onEdit,
    required this.onDelete,
  });

  final List<RecyclingPoint> points;
  final void Function(RecyclingPoint) onEdit;
  final void Function(RecyclingPoint) onDelete;

  static String _translateMaterial(String material) {
    switch (material.toLowerCase()) {
      case 'paper':
        return 'Қағаз';
      case 'glass':
        return 'Әйнек';
      case 'plastic':
        return 'Пластик';
      case 'metal':
        return 'Металл';
      case 'cardboard':
        return 'Картон';
      case 'organic':
        return 'Органикалық';
      case 'electronics':
        return 'Электроника';
      case 'batteries':
        return 'Батарейкалар';
      case 'clothes':
        return 'Киім';
      case 'rubber':
        return 'Резеңке';
      case 'wood':
        return 'Ағаш';
      case 'textile':
        return 'Мата';
      default:
        return material.isNotEmpty
            ? '${material[0].toUpperCase()}${material.substring(1)}'
            : material;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('Пункттер жоқ'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: points.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final point = points[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        point.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: AppTheme.primaryGreen,
                      tooltip: 'Өңдеу',
                      onPressed: () => onEdit(point),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      tooltip: 'Жою',
                      onPressed: () => onDelete(point),
                    ),
                  ],
                ),
                if (point.address != null && point.address!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.textSecondaryLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          point.address!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: AppTheme.textSecondaryLight),
                        ),
                      ),
                    ],
                  ),
                ],
                if (point.acceptedTypes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: point.acceptedTypes.map((type) {
                      return Chip(
                        label: Text(
                          _translateMaterial(type),
                          style: const TextStyle(fontSize: 11),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        backgroundColor:
                            AppTheme.primaryGreen.withOpacity(0.12),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Map view
// ---------------------------------------------------------------------------

class _MapBody extends StatelessWidget {
  const _MapBody({required this.points});

  final List<RecyclingPoint> points;

  @override
  Widget build(BuildContext context) {
    // Default center: Almaty
    const defaultCenter = LatLng(43.238949, 76.889709);

    final center = points.isNotEmpty
        ? LatLng(points.first.latitude, points.first.longitude)
        : defaultCenter;

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.razdelchik.app',
        ),
        MarkerLayer(
          markers: points.map((point) {
            return Marker(
              point: LatLng(point.latitude, point.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(point.name),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Icon(
                  Icons.location_pin,
                  color: AppTheme.primaryGreen,
                  size: 40,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
