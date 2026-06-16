import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:razdelchik/core/theme/app_theme.dart';
import 'package:razdelchik/models/scan_record.dart';
import 'package:razdelchik/models/waste_type.dart';
import 'package:razdelchik/services/admin/admin_scan_service.dart';

class AdminScansScreen extends StatefulWidget {
  const AdminScansScreen({super.key});

  @override
  State<AdminScansScreen> createState() => _AdminScansScreenState();
}

class _AdminScansScreenState extends State<AdminScansScreen> {
  final AdminScanService _service = AdminScanService();

  WasteCategory? _selectedCategory; // null means "Барлығы"
  DateTimeRange? _selectedDateRange;
  Map<String, int> _dailyCounts = {};
  Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _loadDailyData();
  }

  Future<void> _loadDailyData() async {
    final results = await Future.wait([
      _service.getDailyScansLast30Days(),
      _service.getUserDisplayNames(),
    ]);
    if (mounted) {
      setState(() {
        _dailyCounts = results[0] as Map<String, int>;
        _userNames = results[1] as Map<String, String>;
      });
    }
  }

  String _userName(String uid) => _userNames[uid] ?? uid;

  List<ScanRecord> _applyFilters(List<ScanRecord> all) {
    return all.where((r) {
      if (_selectedCategory != null && r.category != _selectedCategory) {
        return false;
      }
      if (_selectedDateRange != null) {
        final date = r.scannedAt;
        if (date.isBefore(_selectedDateRange!.start) ||
            date.isAfter(
                _selectedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // ── Stats helpers ──────────────────────────────────────────────────
  int _todayCount(List<ScanRecord> records) {
    final now = DateTime.now();
    return records
        .where((r) =>
            r.scannedAt.year == now.year &&
            r.scannedAt.month == now.month &&
            r.scannedAt.day == now.day)
        .length;
  }

  String _topWaste(List<ScanRecord> records) {
    if (records.isEmpty) return '—';
    final freq = <String, int>{};
    for (final r in records) {
      freq[r.wasteName] = (freq[r.wasteName] ?? 0) + 1;
    }
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _mostActiveUser(List<ScanRecord> records) {
    if (records.isEmpty) return '—';
    final freq = <String, int>{};
    for (final r in records) {
      freq[r.userId] = (freq[r.userId] ?? 0) + 1;
    }
    final uid = freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final label = _userName(uid);
    return label.length > 12 ? '${label.substring(0, 12)}…' : label;
  }

  // ── Category color ─────────────────────────────────────────────────
  Color _categoryColor(WasteCategory cat) =>
      cat == WasteCategory.recyclable ? AppTheme.glass : AppTheme.metal;

  Color _wasteTypeColor(WasteType type) {
    switch (type) {
      case WasteType.plastic:
        return AppTheme.plastic;
      case WasteType.paper:
        return AppTheme.paper;
      case WasteType.glass:
        return AppTheme.glass;
      case WasteType.metal:
        return AppTheme.metal;
      case WasteType.organic:
        return AppTheme.organic;
      default:
        return AppTheme.textSecondaryLight;
    }
  }

  // ── Date picker ────────────────────────────────────────────────────
  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  // ── Delete confirm ─────────────────────────────────────────────────
  Future<void> _confirmDelete(ScanRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Жазбаны жою'),
        content: Text('«${record.wasteName}» жазбасын жойғыңыз келе ме?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Бас тарту'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Жою'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final adminEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'admin';
    try {
      await _service.deleteScan(adminEmail, record.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Жазба жойылды')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Жою қатесі: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Bar chart ──────────────────────────────────────────────────────
  Widget _buildBarChart() {
    if (_dailyCounts.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final now = DateTime.now();
    final List<BarChartGroupData> groups = [];

    for (int i = 29; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key =
          '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final count = (_dailyCounts[key] ?? 0).toDouble();
      final x = 30 - i; // 1..30
      groups.add(BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: count,
            color: AppTheme.primaryGreen,
            width: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ));
    }

    final maxY = groups
        .map((g) => g.barRods.first.toY)
        .fold(0.0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY < 1 ? 5 : maxY * 1.2,
          barGroups: groups,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  final v = value.toInt();
                  if (v % 5 != 0) return const SizedBox.shrink();
                  return Text(
                    v.toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScanRecord>>(
        stream: _service.watchAllScans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Қате: ${snapshot.error}'));
          }

          final allRecords = snapshot.data ?? [];
          final filtered = _applyFilters(allRecords);

          return Column(
            children: [
              // ── Stats bar ──────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _StatCard(
                      label: 'Бүгін сканерленді',
                      value: _todayCount(allRecords).toString(),
                      icon: Icons.today,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      label: 'Үздік қалдық',
                      value: _topWaste(allRecords),
                      icon: Icons.star,
                      color: AppTheme.paper,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      label: 'Белсенді пайдаланушы',
                      value: _mostActiveUser(allRecords),
                      icon: Icons.person,
                      color: AppTheme.plastic,
                    ),
                  ],
                ),
              ),

              // ── Filter row ─────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<WasteCategory?>(
                        isExpanded: true,
                        value: _selectedCategory,
                        underline: const SizedBox.shrink(),
                        hint: const Text('Барлығы'),
                        items: [
                          const DropdownMenuItem<WasteCategory?>(
                            value: null,
                            child: Text('Барлығы'),
                          ),
                          ...WasteCategory.values.map(
                            (c) => DropdownMenuItem<WasteCategory?>(
                              value: c,
                              child: Text(
                                c == WasteCategory.recyclable
                                    ? 'Қайта өңделетін'
                                    : 'Қайта өңделмейтін',
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _pickDateRange,
                      icon: const Icon(Icons.date_range, size: 16),
                      label: Text(
                        _selectedDateRange == null
                            ? 'Күн аралығы'
                            : '${_fmt(_selectedDateRange!.start)} – ${_fmt(_selectedDateRange!.end)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (_selectedDateRange != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () =>
                            setState(() => _selectedDateRange = null),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── Scan list ──────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('Жазбалар табылмады'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (context, index) {
                          final r = filtered[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  _wasteTypeColor(r.wasteType)
                                      .withOpacity(0.15),
                              child: Icon(
                                Icons.recycling,
                                color: _wasteTypeColor(r.wasteType),
                              ),
                            ),
                            title: Text(
                              r.wasteName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userName(r.userId),
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _fmtFull(r.scannedAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen
                                        .withOpacity(0.12),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '+${r.pointsAwarded}',
                                    style: const TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _confirmDelete(r),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
              ),

              // ── Bar chart ──────────────────────────────────────
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Соңғы 30 күн',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBarChart(),
                  ],
                ),
              ),
            ],
          );
        },
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}';

  String _fmtFull(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Small stat card ────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
