import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razdelchik/models/admin_message.dart';
import 'package:razdelchik/services/admin/admin_messages_service.dart';
import 'package:razdelchik/services/admin/admin_user_service.dart';

class AdminMessagesScreen extends StatelessWidget {
  const AdminMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AdminMessagesService();

    return StreamBuilder<List<AdminMessage>>(
      stream: service.getMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final err = snapshot.error.toString();
          final isPermission = err.contains('permission-denied') ||
              err.contains('PERMISSION_DENIED');
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPermission
                        ? Icons.lock_outline
                        : Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPermission
                        ? 'Қол жеткізу тыйым салынған'
                        : 'Деректерді жүктеу қатесі',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPermission
                        ? 'Хабарламаларды тек әкімші рөліндегі пайдаланушылар көре алады.'
                        : err,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return Center(
            child: Text(
              'Хабарламалар жоқ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final msg = messages[index];
            return _MessageCard(
              message: msg,
              service: service,
            );
          },
        );
      },
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.service});

  final AdminMessage message;
  final AdminMessagesService service;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: message.isUnread
              ? cs.primary.withOpacity(0.4)
              : cs.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          if (message.isUnread) {
            await service.markAsRead(message.id);
          }
          if (context.mounted) {
            await showDialog<void>(
              context: context,
              builder: (_) => _MessageDetailDialog(
                message: message,
                service: service,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      message.userEmail,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _StatusBadge(status: message.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                message.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(message.createdAt),
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '$d.$m.${local.year} $h:$mi';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'unread' => ('Оқылмаған', Colors.blue),
      'read' => ('Оқылған', Colors.orange),
      'resolved' => ('Шешілген', Colors.green),
      _ => (status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _MessageDetailDialog extends StatefulWidget {
  const _MessageDetailDialog({
    required this.message,
    required this.service,
  });

  final AdminMessage message;
  final AdminMessagesService service;

  @override
  State<_MessageDetailDialog> createState() => _MessageDetailDialogState();
}

class _MessageDetailDialogState extends State<_MessageDetailDialog> {
  bool _loading = false;
  final _userService = AdminUserService();

  String get _adminUid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _unblock() async {
    setState(() => _loading = true);
    try {
      final adminEmail =
          FirebaseAuth.instance.currentUser?.email ?? '';
      await _userService.toggleBlock(
        widget.message.userId,
        false,
        adminEmail: adminEmail,
      );
      await widget.service.resolveMessage(widget.message.id, _adminUid);
      if (mounted) Navigator.pop(context);
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

  Future<void> _dismiss() async {
    setState(() => _loading = true);
    try {
      await widget.service.resolveMessage(widget.message.id, _adminUid);
      if (mounted) Navigator.pop(context);
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final msg = widget.message;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Бұғаттан шығару сұранысы'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 18, color: cs.onSurface.withOpacity(0.6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    msg.userEmail,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${msg.userId}',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Хабарлама:',
              style: tt.labelMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(msg.message, style: tt.bodyMedium),
            ),
            if (msg.isResolved) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 16, color: Colors.green),
                  const SizedBox(width: 6),
                  Text('Шешілген', style: tt.bodySmall),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: msg.isResolved
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Жабу'),
              ),
            ]
          : [
              TextButton(
                onPressed: _loading ? null : _dismiss,
                child: const Text('Жабу'),
              ),
              FilledButton.icon(
                onPressed: _loading ? null : _unblock,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_open, size: 18),
                label: const Text('Бұғатты алу'),
              ),
            ],
    );
  }
}
