import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razdelchik/core/theme/app_theme.dart';
import 'package:razdelchik/screens/auth/auth_screen.dart';
import 'package:razdelchik/screens/camera_screen.dart';
import 'package:razdelchik/screens/leaderboard_screen.dart';
import 'package:razdelchik/screens/map_screen.dart';
import 'package:razdelchik/screens/profile_screen.dart';
import 'package:razdelchik/screens/settings_screen.dart';
import 'package:razdelchik/screens/stats/stats_screen.dart';
import 'package:razdelchik/services/leaderboard_service.dart';
import 'package:razdelchik/services/stats/scan_history_service.dart';
import 'package:razdelchik/widgets/common/premium_action_button.dart';
import 'package:razdelchik/widgets/common/soft_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFEAF8EE)
                  : const Color(0xFF121A16),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _TopBar(user: user),
              const SizedBox(height: 20),
              Text(
                'Сортируй умно.\nЖиви экологично.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Быстро сканируй отходы и получай точные инструкции.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppTheme.textSecondaryLight
                          : AppTheme.textSecondaryDark,
                    ),
              ),
              const SizedBox(height: 26),
              PremiumActionButton(
                label: 'Сканировать',
                icon: Icons.center_focus_strong,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CameraScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _QuickTypesRow(),
              const SizedBox(height: 20),
              _StatsPreview(user: user),
              const SizedBox(height: 20),
              _EngagementHub(user: user),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: PremiumActionButton(
                      label: 'Профиль',
                      icon: Icons.person_outline,
                      backgroundColor: const Color(0xFF0D9488),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => user == null
                                ? const AuthScreen()
                                : const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PremiumActionButton(
                      label: 'Пункты приема',
                      icon: Icons.map_outlined,
                      backgroundColor: const Color(0xFF2563EB),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MapScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PremiumActionButton(
                      label: 'Настройки',
                      icon: Icons.tune,
                      backgroundColor: const Color(0xFF34A853),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.eco, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Waste Sorting Assistant',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                user?.email ?? 'Гость',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickTypesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = <(String, Color, IconData)>[
      ('Plastic', AppTheme.plastic, Icons.local_drink_outlined),
      ('Paper', AppTheme.paper, Icons.description_outlined),
      ('Glass', AppTheme.glass, Icons.wine_bar_outlined),
      ('Metal', AppTheme.metal, Icons.hardware_outlined),
      ('Organic', AppTheme.organic, Icons.spa_outlined),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map(
              (item) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: item.$2.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(item.$3, size: 16, color: item.$2),
                    const SizedBox(width: 6),
                    Text(
                      item.$1,
                      style: TextStyle(
                        color: item.$2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StatsPreview extends StatelessWidget {
  const _StatsPreview({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статистика', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Войдите, чтобы отслеживать прогресс и эко-поинты.'),
          ],
        ),
      );
    }

    return StreamBuilder<StatsSummary>(
      stream: ScanHistoryService().watchStatsSummary(user!.uid),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        return SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Статистика недели',
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StatsScreen()),
                      );
                    },
                    child: const Text('Подробнее'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricPill(
                      label: 'Отсортировано',
                      value: '${stats?.totalItems ?? 0}'),
                  _MetricPill(
                    label: 'Пластик',
                    value:
                        '${stats?.byType.values.fold<int>(0, (sum, count) => sum + count) ?? 0}',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EngagementHub extends StatelessWidget {
  const _EngagementHub({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final challenge = _challengeOfDay();

    return Column(
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Челлендж дня',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              Text(challenge),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Рейтинг пользователей',
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LeaderboardScreen()),
                      );
                    },
                    child: const Text('Открыть'),
                  ),
                ],
              ),
              if (user == null)
                const Text(
                    'Войдите, чтобы участвовать в рейтинге и видеть личный прогресс.')
              else
                StreamBuilder(
                  stream: LeaderboardService().watchMyEntry(user!.uid),
                  builder: (context, snapshot) {
                    final me = snapshot.data;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetricPill(
                            label: 'Твои очки', value: '${me?.ecoPoints ?? 0}'),
                        _MetricPill(
                            label: 'Streak',
                            value: '${me?.streakDays ?? 0} дн'),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _challengeOfDay() {
    const challenges = <String>[
      'Отсортируй 3 пластиковых предмета сегодня.',
      'Сделай 1 скан стекла и проверь правильный контейнер.',
      'Собери 20 eco-поинтов за один день.',
      'Добавь минимум 2 новых скана в историю.',
      'Проверь сортировку бумажной упаковки и тетрапака.',
    ];
    final day = DateTime.now().day;
    return challenges[day % challenges.length];
  }
}
