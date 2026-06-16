import 'package:flutter/material.dart';
import 'package:razdelchik/models/waste_item.dart';
import 'package:razdelchik/models/waste_type.dart';
import 'package:razdelchik/services/admin/admin_waste_service.dart';

class AdminWasteFormSheet extends StatefulWidget {
  const AdminWasteFormSheet({super.key, this.item});

  final WasteItem? item;

  @override
  State<AdminWasteFormSheet> createState() => _AdminWasteFormSheetState();
}

class _AdminWasteFormSheetState extends State<AdminWasteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _service = AdminWasteService();

  late final TextEditingController _nameController;
  late final TextEditingController _explanationController;
  late final TextEditingController _binColorController;

  late WasteType _selectedType;
  late WasteCategory _selectedCategory;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _explanationController =
        TextEditingController(text: item?.explanation ?? '');
    _binColorController = TextEditingController(text: item?.binColor ?? '');
    _selectedType = item?.type ?? WasteType.unknown;
    _selectedCategory = item?.category ?? WasteCategory.nonRecyclable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _explanationController.dispose();
    _binColorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final isEdit = widget.item != null;
      final item = WasteItem(
        id: widget.item?.id ?? '',
        name: _nameController.text.trim(),
        explanation: _explanationController.text.trim(),
        binColor: _binColorController.text.trim(),
        type: _selectedType,
        category: _selectedCategory,
        isFavorite: widget.item?.isFavorite ?? false,
        aiConfidence: widget.item?.aiConfidence,
        aiSuggestion: widget.item?.aiSuggestion,
      );

      if (isEdit) {
        await _service.updateItem(item);
      } else {
        await _service.addItem(item);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit
                ? 'Қалдық сәтті жаңартылды'
                : 'Қалдық сәтті қосылды'),
            backgroundColor: Colors.green,
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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.item != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEdit ? 'Қалдықты өзгерту' : 'Қалдық қосу',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Атауы',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Атауын енгізіңіз' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _explanationController,
              decoration: const InputDecoration(
                labelText: 'Түсіндірме',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Түсіндірме енгізіңіз'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _binColorController,
              decoration: const InputDecoration(
                labelText: 'Себет түсі',
                hintText: 'green, red, yellow... (ағылшынша енгізіңіз)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Себет түсін енгізіңіз'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<WasteType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Түрі',
                border: OutlineInputBorder(),
              ),
              items: WasteType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(_wasteTypeLabel(t)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<WasteCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Санаты',
                border: OutlineInputBorder(),
              ),
              items: WasteCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(_wasteCategoryLabel(c)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Жаңарту' : 'Қосу'),
            ),
          ],
        ),
      ),
    );
  }

  String _wasteTypeLabel(WasteType type) {
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
        return 'Органикалық';
      case WasteType.unknown:
        return 'Белгісіз';
    }
  }

  String _wasteCategoryLabel(WasteCategory category) {
    switch (category) {
      case WasteCategory.recyclable:
        return 'Қайта өңделетін';
      case WasteCategory.nonRecyclable:
        return 'Қайта өңделмейтін';
    }
  }
}
