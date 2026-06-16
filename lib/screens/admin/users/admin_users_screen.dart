import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razdelchik/models/app_user.dart';
import 'package:razdelchik/services/admin/admin_user_service.dart';
import 'package:razdelchik/widgets/admin/admin_data_table.dart';
import 'package:razdelchik/screens/admin/users/admin_user_detail_sheet.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  String get adminEmail =>
      FirebaseAuth.instance.currentUser?.email ?? 'admin';

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _service = AdminUserService();

  void _openDetail(AppUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AdminUserDetailSheet(
        user: user,
        adminEmail: widget.adminEmail,
      ),
    );
  }

  Future<void> _toggleBlock(AppUser user) async {
    try {
      await _service.toggleBlock(
        user.id,
        !user.isBlocked,
        adminEmail: widget.adminEmail,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: _service.watchAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Қате: ${snapshot.error}'));
        }
        final users = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: AdminDataTable<AppUser>(
            rows: users,
            columns: const [
              'Аты',
              'Электрондық пошта',
              'Эко-балл',
              'Күй',
              'Әрекет',
            ],
            rowBuilder: (user) {
              final hasData = user.name.trim().isNotEmpty ||
                  user.email.trim().isNotEmpty;
              if (!hasData) return const [];
              return [
              DataRow(
                onSelectChanged: (_) => _openDetail(user),
                cells: [
                  DataCell(Text(user.name)),
                  DataCell(Text(user.email)),
                  DataCell(Text('${user.ecoPoints}')),
                  DataCell(
                    Text(
                      user.isBlocked ? 'Бұғатталған' : 'Белсенді',
                      style: TextStyle(
                        color: user.isBlocked
                            ? Theme.of(context).colorScheme.error
                            : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      tooltip: user.isBlocked ? 'Бұғатты ашу' : 'Бұғаттау',
                      icon: Icon(
                        user.isBlocked ? Icons.lock_open : Icons.lock,
                        color: user.isBlocked
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _toggleBlock(user),
                    ),
                  ),
                ],
              ),
            ];
            },
          ),
        );
      },
    );
  }
}
