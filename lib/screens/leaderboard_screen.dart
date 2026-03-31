import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razdelchik/models/leaderboard_entry.dart';
import 'package:razdelchik/services/leaderboard_service.dart';
import 'package:razdelchik/widgets/common/soft_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Глобальный рейтинг')),
      body: StreamBuilder<List<LeaderboardEntry>>(
        stream: LeaderboardService().watchTopUsers(limit: 100),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Ошибка загрузки рейтинга: ${snapshot.error}'));
          }

          final rows = snapshot.data ?? const <LeaderboardEntry>[];
          if (rows.isEmpty) {
            return const Center(
              child: Text(
                  'Рейтинг пока пуст. Сделайте первый скан и возглавьте таблицу.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final row = rows[index];
              final rank = index + 1;
              final isMe = me?.uid == row.userId;

              return SoftCard(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isMe
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.2)
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isMe
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isMe ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                              'Сканов: ${row.scansCount}  |  Streak: ${row.streakDays} дн.'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${row.ecoPoints}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
