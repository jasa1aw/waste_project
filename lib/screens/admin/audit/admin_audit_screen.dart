import 'package:flutter/material.dart';
import 'package:razdelchik/models/audit_log_entry.dart';
import 'package:razdelchik/services/admin/admin_audit_service.dart';

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  final AdminAuditService _service = AdminAuditService();

  static const List<String> _actionOptions = [
    'Барлығы',
    'DELETE_USER',
    'UPDATE_USER',
    'BLOCK_USER',
    'UNBLOCK_USER',
    'DELETE_SCAN',
    'DELETE_RECYCLING_POINT',
    'ADD_RECYCLING_POINT',
    'UPDATE_RECYCLING_POINT',
  ];

  String _selectedAction = 'Барлығы';
  DateTimeRange? _dateRange;

  Stream<List<AuditLogEntry>> get _stream => _service.watchLogs(
        filterAction: _selectedAction,
        fromDate: _dateRange?.start,
        toDate: _dateRange?.end,
      );

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  void _clearDateRange() => setState(() => _dateRange = null);

String _labelForAction(String action) {
    switch (action.toUpperCase()) {
      case 'DELETE_USER':
        return 'Пайдаланушы жойылды';
      case 'UPDATE_USER':
        return 'Пайдаланушы жаңартылды';
      case 'BLOCK_USER':
      case 'BLOCK':
        return 'Пайдаланушы бұғатталды';
      case 'UNBLOCK_USER':
      case 'UNBLOCK':
        return 'Пайдаланушы бұғаттан шығарылды';
      case 'DELETE_SCAN':
        return 'Сканерлеу жойылды';
      case 'DELETE_RECYCLING_POINT':
      case 'DELETE_POINT':
        return 'Қабылдау нүктесі жойылды';
      case 'ADD_RECYCLING_POINT':
      case 'ADD_POINT':
        return 'Қабылдау нүктесі қосылды';
      case 'UPDATE_RECYCLING_POINT':
        return 'Қабылдау нүктесі жаңартылды';
      case 'ADJUST_ECO_POINTS':
      case 'adjust_eco_points':
        return 'Эко-ұпайлар түзетілді';
      default:
        return action;
    }
  }

  IconData _iconForAction(String action) {
    switch (action) {
      case 'delete_scan':
        return Icons.delete_outline;
      case 'block_user':
        return Icons.block;
      case 'adjust_eco_points':
        return Icons.eco_outlined;
      case 'add_point':
        return Icons.add_location_alt_outlined;
      case 'delete_point':
        return Icons.wrong_location_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Color _colorForAction(String action, ColorScheme cs) {
    switch (action) {
      case 'delete_scan':
      case 'delete_point':
        return Colors.red;
      case 'block_user':
        return Colors.orange;
      case 'adjust_eco_points':
        return Colors.green;
      case 'add_point':
        return cs.primary;
      default:
        return cs.secondary;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final mo = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '$d.$mo.$y $h:$mi';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return StreamBuilder<List<AuditLogEntry>>(
      stream: _stream,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? [];
        return Column(
          children: [
            _buildFilterRow(cs),
            const Divider(height: 1),
            Expanded(
              child: Builder(
                builder: (context) {
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
                              color: cs.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isPermission
                                  ? 'Қол жеткізу тыйым салынған'
                                  : 'Деректерді жүктеу қатесі',
                              style: tt.titleMedium?.copyWith(
                                color: cs.error,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isPermission
                                  ? 'Аудит журналын тек әкімші рөліндегі пайдаланушылар көре алады. '
                                    'Егер сіз әкімші болсаңыз, Firestore ережелері жаңартылмаған болуы мүмкін — '
                                    'firebase deploy --only firestore:rules пәрменін іске қосыңыз.'
                                  : err,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        'Жазбалар жоқ',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final e = entries[index];
                      final color = _colorForAction(e.action, cs);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.12),
                          child: Icon(
                            _iconForAction(e.action),
                            color: color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          _labelForAction(e.action),
                          style: tt.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.adminEmail,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                            ),
                            if (e.targetEntity.isNotEmpty)
                              Text(
                                'Нысан: ${e.targetEntity}',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.55),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (e.details.isNotEmpty)
                              Text(
                                e.details,
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.55),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 90,
                          child: Text(
                            _formatTimestamp(e.timestamp),
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        isThreeLine: e.targetEntity.isNotEmpty || e.details.isNotEmpty,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterRow(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedAction,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Іс-әрекет',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _actionOptions
                .map(
                  (a) => DropdownMenuItem(
                    value: a,
                    child: Text(
                      a == 'Барлығы' ? a : _labelForAction(a),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedAction = v);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  foregroundColor:
                      _dateRange != null ? cs.primary : null,
                ),
                onPressed: _pickDateRange,
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(
                  _dateRange == null
                      ? 'Күн таңдау'
                      : '${_formatDate(_dateRange!.start)} – ${_formatDate(_dateRange!.end)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              if (_dateRange != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Тазалау',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _clearDateRange,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}';
  }
}
