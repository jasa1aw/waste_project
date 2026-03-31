import 'dart:io';
import 'package:flutter/material.dart';
import 'package:razdelchik/core/theme/app_theme.dart';
import 'package:razdelchik/models/scan_record.dart';
import 'package:razdelchik/models/waste_type.dart';
import 'package:razdelchik/widgets/common/soft_card.dart';

class ScanDetailScreen extends StatelessWidget {
  const ScanDetailScreen({super.key, required this.record});

  final ScanRecord record;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _colorForType(record.wasteType);
    final hasImage =
        record.imagePath.isNotEmpty && File(record.imagePath).existsSync();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: isDark
                ? AppTheme.surfaceDark
                : AppTheme.surfaceLight,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      size: 18, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage
                  ? Hero(
                      tag: 'scan_photo_${record.id}',
                      child: Image.file(
                        File(record.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholderHero(typeColor),
                      ),
                    )
                  : _placeholderHero(typeColor),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    record.wasteName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  // Type & category badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Badge(
                        icon: _iconForType(record.wasteType),
                        label: _labelForType(record.wasteType),
                        color: typeColor,
                      ),
                      _Badge(
                        icon: record.category == WasteCategory.recyclable
                            ? Icons.recycling
                            : Icons.delete_outline,
                        label: record.category == WasteCategory.recyclable
                            ? 'Қайта өңделетін'
                            : 'Қайта өңделмейтін',
                        color: record.category == WasteCategory.recyclable
                            ? Colors.teal
                            : Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info cards
                  SoftCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.star_rounded,
                          iconColor: Colors.amber,
                          label: 'Берілген ұпайлар',
                          value: '+${record.pointsAwarded}',
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          iconColor: AppTheme.primaryGreen,
                          label: 'Сканерлеу күні',
                          value: _formatDate(record.scannedAt),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.schedule_outlined,
                          iconColor: AppTheme.plastic,
                          label: 'Уақыт',
                          value: _formatTime(record.scannedAt),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Eco tip
                  SoftCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.eco,
                              color: AppTheme.primaryGreen, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Эко-кеңес',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _ecoTip(record.wasteType),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderHero(Color color) {
    return Container(
      color: color.withValues(alpha: 0.15),
      child: Center(
        child: Icon(Icons.photo_camera_outlined,
            size: 64, color: color.withValues(alpha: 0.4)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'қаңтар', 'ақпан', 'наурыз', 'сәуір', 'мамыр', 'маусым',
      'шілде', 'тамыз', 'қыркүйек', 'қазан', 'қараша', 'желтоқсан',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _ecoTip(WasteType type) {
    switch (type) {
      case WasteType.plastic:
        return 'Қайта өңдеуге тапсырмас бұрын пластикті жуыңыз. Қақпақтарын шешіп алыңыз — олар бөлек өңделеді.';
      case WasteType.paper:
        return 'Қағаз бен картон құрғақ әрі таза болуы керек. Ластанған қағаз қайта өңдеуге жарамайды.';
      case WasteType.glass:
        return 'Шыны сапасын жоғалтпай шексіз қайта өңделе береді. Оның таза екеніне көз жеткізіңіз.';
      case WasteType.metal:
        return 'Орын үнемдеу үшін алюминий қалбырларды қысуға болады. Металл — ең көп қайта өңделетін материалдардың бірі.';
      case WasteType.organic:
        return 'Органикалық қалдықтарды компост жасауға болады. Компост топырақты байытып, қоқыс полигондарындағы қалдықты азайтады.';
      case WasteType.unknown:
        return 'Егер қалдықтың түріне сенімді болмасаңыз, қаптамадағы таңбалауды тексеріңіз немесе жақын маңдағы экопунктке хабарласыңыз.';
    }
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

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
