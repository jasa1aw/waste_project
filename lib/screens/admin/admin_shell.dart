import 'package:flutter/material.dart';
import 'package:razdelchik/core/theme/app_theme.dart';
import 'package:razdelchik/screens/admin/analytics/admin_analytics_screen.dart';
import 'package:razdelchik/screens/admin/audit/admin_audit_screen.dart';
import 'package:razdelchik/screens/admin/messages/admin_messages_screen.dart';
import 'package:razdelchik/screens/admin/recycling_points/admin_recycling_screen.dart';
import 'package:razdelchik/screens/admin/scans/admin_scans_screen.dart';
import 'package:razdelchik/screens/admin/users/admin_users_screen.dart';
import 'package:razdelchik/services/admin/admin_messages_service.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;
  final _messagesService = AdminMessagesService();

  static const _sections = [
    _AdminSection(title: 'Аналитика', icon: Icons.bar_chart_rounded),
    _AdminSection(title: 'Пайдаланушылар', icon: Icons.people_rounded),
    _AdminSection(title: 'Қабылдау пункттері', icon: Icons.location_on_rounded),
    _AdminSection(title: 'Сканерлер', icon: Icons.qr_code_scanner_rounded),
    _AdminSection(title: 'Тарих әрекеттері', icon: Icons.history_rounded),
    _AdminSection(title: 'Хабарламалар', icon: Icons.mail_outline_rounded),
  ];

  static const _screens = [
    AdminAnalyticsScreen(),
    AdminUsersScreen(),
    AdminRecyclingScreen(),
    AdminScansScreen(),
    AdminAuditScreen(),
    AdminMessagesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _messagesService.watchUnreadCount(),
      builder: (context, unreadSnap) {
        final unreadCount = unreadSnap.data ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(_sections[_selectedIndex].title),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_rounded,
                          size: 14, color: AppTheme.primaryGreen),
                      SizedBox(width: 4),
                      Text(
                        'ӘКІМШІ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          drawer: NavigationDrawer(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
              Navigator.pop(context);
            },
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 20, 16, 10),
                child: Text(
                  'Әкімші панелі',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const Divider(indent: 28, endIndent: 28),
              const SizedBox(height: 4),
              ..._sections.asMap().entries.map((entry) {
                final s = entry.value;
                final isMessages = s.title == 'Хабарламалар';
                return NavigationDrawerDestination(
                  icon: isMessages && unreadCount > 0
                      ? Badge(
                          label: Text('$unreadCount'),
                          child: Icon(s.icon),
                        )
                      : Icon(s.icon),
                  label: Text(s.title),
                );
              }),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        );
      },
    );
  }
}

class _AdminSection {
  const _AdminSection({required this.title, required this.icon});
  final String title;
  final IconData icon;
}
