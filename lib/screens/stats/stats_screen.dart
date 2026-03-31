import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:razdelchik/widgets/common/soft_card.dart';
import 'package:razdelchik/models/waste_type.dart';
import 'package:razdelchik/services/stats/scan_history_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Войдите, чтобы увидеть статистику'),
        ),
      );
    }

    final statsService = ScanHistoryService();

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: StreamBuilder<StatsSummary>(
        stream: statsService.watchStatsSummary(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final stats = snapshot.data;
          if (stats == null) {
            return const Center(child: Text('Нет данных'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SoftCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Всего отсортировано',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.totalItems} предметов',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const Icon(Icons.insights_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                child: _BasicReports(stats: stats),
              ),
              const SizedBox(height: 12),
              SoftCard(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _buildTypeSections(stats.byType),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 24),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const labels = [
                                  'Пн',
                                  'Вт',
                                  'Ср',
                                  'Чт',
                                  'Пт',
                                  'Сб',
                                  'Вс'
                                ];
                                final index = value.toInt();
                                if (index < 0 || index > 6) {
                                  return const SizedBox.shrink();
                                }
                                return Text(labels[index]);
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(7, (index) {
                          final count = stats.weeklyActivity[index + 1] ?? 0;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(toY: count.toDouble()),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildTypeSections(Map<WasteType, int> byType) {
    final data = <MapEntry<WasteType, int>>[
      MapEntry(WasteType.plastic, byType[WasteType.plastic] ?? 0),
      MapEntry(WasteType.paper, byType[WasteType.paper] ?? 0),
      MapEntry(WasteType.glass, byType[WasteType.glass] ?? 0),
      MapEntry(WasteType.metal, byType[WasteType.metal] ?? 0),
      MapEntry(WasteType.organic, byType[WasteType.organic] ?? 0),
    ];

    return data
        .where((entry) => entry.value > 0)
        .map(
          (entry) => PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${entry.key.name}: ${entry.value}',
            radius: 70,
            color: _colorForType(entry.key),
          ),
        )
        .toList();
  }

  Color _colorForType(WasteType type) {
    switch (type) {
      case WasteType.plastic:
        return Colors.orange;
      case WasteType.paper:
        return Colors.blue;
      case WasteType.glass:
        return Colors.green;
      case WasteType.metal:
        return Colors.grey;
      case WasteType.organic:
        return Colors.brown;
      case WasteType.unknown:
        return Colors.black54;
    }
  }
}

class _BasicReports extends StatelessWidget {
  const _BasicReports({required this.stats});

  final StatsSummary stats;

  @override
  Widget build(BuildContext context) {
    final recyclable = (stats.byType[WasteType.plastic] ?? 0) +
        (stats.byType[WasteType.paper] ?? 0) +
        (stats.byType[WasteType.glass] ?? 0) +
        (stats.byType[WasteType.metal] ?? 0);
    final total = stats.totalItems == 0 ? 1 : stats.totalItems;
    final recyclableShare = ((recyclable / total) * 100).round();
    final topType = _topType(stats.byType);
    final ecoImpactKg = (recyclable * 0.18).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Базовый отчет', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Лидер по типу отхода: $topType'),
        const SizedBox(height: 4),
        Text('Доля перерабатываемых: $recyclableShare%'),
        const SizedBox(height: 4),
        Text('Оценка эко-вклада: ~ $ecoImpactKg кг сохраненных ресурсов'),
      ],
    );
  }

  String _topType(Map<WasteType, int> byType) {
    final filtered = Map<WasteType, int>.from(byType)
      ..remove(WasteType.unknown);
    if (filtered.isEmpty) {
      return 'нет данных';
    }
    final entry = filtered.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return switch (entry.key) {
      WasteType.plastic => 'Plastic',
      WasteType.paper => 'Paper',
      WasteType.glass => 'Glass',
      WasteType.metal => 'Metal',
      WasteType.organic => 'Organic',
      WasteType.unknown => 'Unknown',
    };
  }
}
