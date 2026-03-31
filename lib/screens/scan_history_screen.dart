import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razdelchik/core/theme/app_theme.dart';
import 'package:razdelchik/models/scan_record.dart';
import 'package:razdelchik/models/waste_type.dart';
import 'package:razdelchik/screens/scan_detail_screen.dart'; // Added
import 'package:razdelchik/services/stats/scan_history_service.dart';
import 'package:razdelchik/widgets/common/soft_card.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen>
    with SingleTickerProviderStateMixin {
  final ScanHistoryService _service = ScanHistoryService();
  late final AnimationController _fadeController;
  WasteType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Сканерлеу тарихы')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline,
                  size: 64,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
              const SizedBox(height: 16),
              Text(
                'Сканерлеу тарихын көру үшін\nкіріңіз',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? const Color(0xFF121A16) : const Color(0xFFEAF8EE),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildFilterChips(context),
              Expanded(
                child: StreamBuilder<List<ScanRecord>>(
                  stream: _service.watchRecentScans(user.uid, limit: 100),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Қате: ${snapshot.error}'),
                      );
                    }

                    final allRecords = snapshot.data ?? [];
                    final records = _selectedFilter == null
                        ? allRecords
                        : allRecords
                            .where((r) => r.wasteType == _selectedFilter)
                            .toList();

                    if (records.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return FadeTransition(
                      opacity: _fadeController,
                      child: _buildRecordsList(context, records),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Сканерлеу тарихы',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = <(WasteType?, String, Color)>[
      (null, 'Барлығы', AppTheme.primaryGreen),
      (WasteType.plastic, 'Пластик', AppTheme.plastic),
      (WasteType.paper, 'Қағаз', AppTheme.paper),
      (WasteType.glass, 'Шыны', AppTheme.glass),
      (WasteType.metal, 'Металл', AppTheme.metal),
      (WasteType.organic, 'Органика', AppTheme.organic),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 0, 8),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          padding: const EdgeInsets.only(right: 16),
          itemBuilder: (context, index) {
            final (type, label, color) = filters[index];
            final isSelected = _selectedFilter == type;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = type;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : color.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_outlined,
              size: 48,
              color: AppTheme.primaryGreen.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedFilter != null
                ? 'Бұл типтегі жазбалар жоқ'
                : 'Әзірге сканерлеулер жоқ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Бастау үшін қалдықты суретке түсір!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context, List<ScanRecord> records) {
    // Group records by date
    final grouped = <String, List<ScanRecord>>{};
    for (final record in records) {
      final key = _dateGroupKey(record.scannedAt);
      grouped.putIfAbsent(key, () => []).add(record);
    }

    final sections = grouped.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = sections[sectionIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 10, left: 4),
              child: Text(
                section.key,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
              ),
            ),
            ...section.value.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              return TweenAnimationBuilder<double>(
                key: ValueKey(record.id),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + index * 60),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ScanRecordCard(record: record),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _dateGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDay = DateTime(date.year, date.month, date.day);

    final diff = today.difference(recordDay).inDays;
    if (diff == 0) return 'Бүгін';
    if (diff == 1) return 'Кеше';
    if (diff < 7) return '$diff күн бұрын';

    final months = [
      '', 'Қаңтар', 'Ақпан', 'Наурыз', 'Сәуір', 'Мамыр', 'Маусым',
      'Шілде', 'Тамыз', 'Қыркүйек', 'Қазан', 'Қараша', 'Желтоқсан',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

class _ScanRecordCard extends StatelessWidget {
  const _ScanRecordCard({required this.record});

  final ScanRecord record;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _colorForType(record.wasteType);
    final typeLabel = _labelForType(record.wasteType);
    final categoryLabel = record.category == WasteCategory.recyclable
        ? 'Қайта өңделетін'
        : 'Қайта өңделмейтін';
    final hasImage = record.imagePath.isNotEmpty &&
        File(record.imagePath).existsSync();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanDetailScreen(record: record),
          ),
        );
      },
      child: SoftCard(
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                child: SizedBox(
                  width: 100,
                  child: Hero(
                    tag: 'scan_photo_${record.id}',
                    child: hasImage
                        ? Image.file(
                            File(record.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _placeholderImage(typeColor),
                          )
                        : _placeholderImage(typeColor),
                  ),
                ),
              ),

              // Record details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Name & points row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              record.wasteName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 14, color: AppTheme.primaryGreen),
                                const SizedBox(width: 3),
                                Text(
                                  '+${record.pointsAwarded}',
                                  style: TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Type badge & category
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_iconForType(record.wasteType),
                                    size: 13, color: typeColor),
                                const SizedBox(width: 4),
                                Text(
                                  typeLabel,
                                  style: TextStyle(
                                    color: typeColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (record.category == WasteCategory.recyclable
                                        ? Colors.teal
                                        : Colors.redAccent)
                                    .withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                categoryLabel,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      record.category == WasteCategory.recyclable
                                          ? Colors.teal
                                          : Colors.redAccent,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Time
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 13,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(record.scannedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Chevron indicator
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage(Color color) {
    return Container(
      color: color.withValues(alpha: 0.12),
      child: Center(
        child: Icon(Icons.photo_camera_outlined,
            size: 32, color: color.withValues(alpha: 0.4)),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _colorForType(WasteType type) {
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
      case WasteType.unknown:
        return Colors.grey;
    }
  }

  IconData _iconForType(WasteType type) {
    switch (type) {
      case WasteType.plastic:
        return Icons.local_drink_outlined;
      case WasteType.paper:
        return Icons.description_outlined;
      case WasteType.glass:
        return Icons.wine_bar_outlined;
      case WasteType.metal:
        return Icons.hardware_outlined;
      case WasteType.organic:
        return Icons.spa_outlined;
      case WasteType.unknown:
        return Icons.help_outline;
    }
  }

  String _labelForType(WasteType type) {
    switch (type) {
      case WasteType.plastic:
        return 'Пластик';
      case WasteType.paper:
        return 'Қағаз';
      case WasteType.glass:
        return 'Шыны';
      case WasteType.metal:
        return 'Металл';
      case WasteType.organic:
        return 'Органика';
      case WasteType.unknown:
        return 'Белгісіз';
    }
  }
}
