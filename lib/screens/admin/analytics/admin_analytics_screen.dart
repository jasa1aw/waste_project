import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:razdelchik/core/theme/app_theme.dart';
import 'package:razdelchik/services/admin/admin_analytics_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final AdminAnalyticsService _service = AdminAnalyticsService();

  bool _loading = true;
  String? _error;

  int _totalUsers = 0;
  int _dailyActive = 0;
  int _totalScans = 0;
  int _totalPoints = 0;
  Map<String, int> _scansByCategory = {};
  List<Map<String, dynamic>> _leaderboard = [];
  Map<String, int> _dailyScans = {};

  static const List<Color> _categoryColors = [
    AppTheme.plastic,
    AppTheme.paper,
    AppTheme.glass,
    AppTheme.metal,
    AppTheme.organic,
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFFF97316),
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getTotalUsers(),
        _service.getDailyActiveUsers(),
        _service.getTotalScans(),
        _service.getTotalEcoPoints(),
        _service.getScansByCategory(),
        _service.getTopLeaderboard(),
        _service.getDailyScansLast30Days(),
      ]);
      if (!mounted) return;
      setState(() {
        _totalUsers = results[0] as int;
        _dailyActive = results[1] as int;
        _totalScans = results[2] as int;
        _totalPoints = results[3] as int;
        _scansByCategory = results[4] as Map<String, int>;
        _leaderboard = results[5] as List<Map<String, dynamic>>;
        _dailyScans = results[6] as Map<String, int>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Builds FlSpot list from real daily scan data for the last 30 days.
  List<FlSpot> _buildLineSpots() {
    final now = DateTime.now();
    return List.generate(30, (i) {
      final day = now.subtract(Duration(days: 29 - i));
      final key =
          '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final count = (_dailyScans[key] ?? 0).toDouble();
      return FlSpot(i.toDouble(), count);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Қате: $_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _loadAll, child: const Text('Қайталау')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildKpiRow(),
          const SizedBox(height: 24),
          _buildLineChartSection(),
          const SizedBox(height: 24),
          if (_scansByCategory.isNotEmpty) ...[
            _buildPieChartSection(),
            const SizedBox(height: 24),
          ],
          _buildLeaderboardSection(),
        ],
      ),
    );
  }

  static String _translateCategory(String key) {
    switch (key.toLowerCase()) {
      case 'recyclable':
        return 'Қайта өңделетін';
      case 'not_recyclable':
      case 'non-recyclable':
      case 'non_recyclable':
        return 'Қайта өңделмейтін';
      default:
        return key.isNotEmpty
            ? '${key[0].toUpperCase()}${key.substring(1)}'
            : key;
    }
  }

  Widget _buildKpiRow() {
    final items = [
      (_totalUsers, 'Барлық\nпайдаланушылар', Icons.people_outline),
      (_dailyActive, 'Бүгінгі\nбелсенді', Icons.today_outlined),
      (_totalScans, 'Барлық\nсканерлер', Icons.qr_code_scanner_outlined),
      (_totalPoints, 'Берілген\nбаллдар', Icons.star_outline),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 56) / 2,
          child: _KpiCard(
            value: item.$1,
            label: item.$2,
            icon: item.$3,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineChartSection() {
    final spots = _buildLineSpots();
    final maxY = spots.fold(0.0, (prev, s) => s.y > prev ? s.y : prev);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Күнделікті сканерлер',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Соңғы 30 күн',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    )),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY < 1 ? 5 : maxY * 1.2,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, _) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 7,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toInt() + 1}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.primaryGreen,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryGreen.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSection() {
    final entries = _scansByCategory.entries.toList();
    final total = entries.fold<int>(0, (s, e) => s + e.value);
    final sections = entries.indexed.map((pair) {
      final idx = pair.$1;
      final entry = pair.$2;
      final pct = total > 0 ? (entry.value / total * 100) : 0.0;
      return PieChartSectionData(
        color: _categoryColors[idx % _categoryColors.length],
        value: entry.value.toDouble(),
        title: '${pct.toStringAsFixed(0)}%',
        radius: 70,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Категория бойынша сканерлер',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: entries.indexed.map((pair) {
                final idx = pair.$1;
                final entry = pair.$2;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _categoryColors[idx % _categoryColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${_translateCategory(entry.key)} (${entry.value})',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Үздік пайдаланушылар',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_leaderboard.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('Деректер жоқ')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _leaderboard.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = _leaderboard[index];
                  final rank = index + 1;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: rank <= 3
                          ? AppTheme.primaryGreen
                          : Colors.grey.shade300,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: rank <= 3 ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      entry['displayName'] as String? ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('Сканерлер: ${entry['scanCount']}'),
                    trailing: Text(
                      '${entry['totalPoints']} ұпай',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final int value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 28),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
