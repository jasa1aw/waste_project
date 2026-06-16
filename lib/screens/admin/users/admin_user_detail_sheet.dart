import 'package:flutter/material.dart';
import 'package:razdelchik/models/app_user.dart';
import 'package:razdelchik/services/admin/admin_user_service.dart';

class AdminUserDetailSheet extends StatefulWidget {
  const AdminUserDetailSheet({
    super.key,
    required this.user,
    required this.adminEmail,
  });

  final AppUser user;
  final String adminEmail;

  @override
  State<AdminUserDetailSheet> createState() => _AdminUserDetailSheetState();
}

class _AdminUserDetailSheetState extends State<AdminUserDetailSheet> {
  final _deltaController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _service = AdminUserService();

  @override
  void dispose() {
    _deltaController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final delta = int.tryParse(_deltaController.text.trim());
    if (delta == null) return;
    setState(() => _loading = true);
    try {
      await _service.adjustEcoPoints(
        widget.adminEmail,
        widget.user.id,
        delta,
        _reasonController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Эко-балл сәтті өзгертілді')),
        );
        _deltaController.clear();
        _reasonController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(user.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(user.email,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            _InfoRow(label: 'Эко-балл', value: '${user.ecoPoints}'),
            _InfoRow(label: 'Деңгей', value: user.level),
            _InfoRow(
              label: 'Тіркелген күні',
              value:
                  '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}',
            ),
            _InfoRow(
              label: 'Күй',
              value: user.isBlocked ? 'Бұғатталған' : 'Белсенді',
              valueColor:
                  user.isBlocked ? theme.colorScheme.error : Colors.green,
            ),
            const Divider(height: 32),
            Text('Эко-балл реттеу', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _deltaController,
                    keyboardType:
                        const TextInputType.numberWithOptions(signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Өзгерту мөлшері (мысалы: 50 немесе -20)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Мән енгізіңіз';
                      }
                      if (int.tryParse(v.trim()) == null) {
                        return 'Бүтін сан енгізіңіз';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Себеп',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Себеп жазыңыз' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Сақтау'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
