import 'package:flutter/material.dart';
import 'package:razdelchik/models/recycling_point.dart';
import 'package:razdelchik/services/admin/admin_recycling_service.dart';
import 'package:razdelchik/core/theme/app_theme.dart';

const List<String> _kWasteTypes = [
  'Пластик',
  'Қағаз',
  'Шыны',
  'Металл',
  'Электроника',
  'Органика',
];

class AdminRecyclingFormSheet extends StatefulWidget {
  const AdminRecyclingFormSheet({super.key, this.point});

  final RecyclingPoint? point;

  @override
  State<AdminRecyclingFormSheet> createState() =>
      _AdminRecyclingFormSheetState();
}

class _AdminRecyclingFormSheetState extends State<AdminRecyclingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _service = AdminRecyclingService();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;

  late Set<String> _selectedTypes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.point;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _addressCtrl = TextEditingController(text: p?.address ?? '');
    _latCtrl =
        TextEditingController(text: p != null ? p.latitude.toString() : '');
    _lngCtrl =
        TextEditingController(text: p != null ? p.longitude.toString() : '');
    _selectedTypes = Set<String>.from(p?.acceptedTypes ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final point = RecyclingPoint(
      id: widget.point?.id ?? '',
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty
          ? null
          : _addressCtrl.text.trim(),
      latitude: double.parse(_latCtrl.text.trim()),
      longitude: double.parse(_lngCtrl.text.trim()),
      acceptedTypes: _selectedTypes.toList(),
    );

    try {
      if (widget.point == null) {
        await _service.addPoint(point);
      } else {
        await _service.updatePoint(point);
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.point == null
                  ? 'Пункт сәтті қосылды'
                  : 'Пункт сәтті жаңартылды',
            ),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Қате: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.point != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEdit ? 'Пунктті өңдеу' : 'Жаңа пункт қосу',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Атауы *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Атауын енгізіңіз' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Мекенжай',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Ендік *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ендікті енгізіңіз';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Жарамды сан';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Бойлық *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Бойлықты енгізіңіз';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Жарамды сан';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Қабылданатын түрлері',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _kWasteTypes.map((type) {
                  final selected = _selectedTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: selected,
                    selectedColor:
                        AppTheme.primaryGreen.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryGreen,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedTypes.add(type);
                        } else {
                          _selectedTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEdit ? 'Сақтау' : 'Қосу'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
