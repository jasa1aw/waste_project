import 'package:flutter/material.dart';
import 'package:razdelchik/models/waste_item.dart';
import 'package:razdelchik/models/waste_type.dart';
import 'package:razdelchik/services/admin/admin_waste_service.dart';
import 'package:razdelchik/screens/admin/waste_items/admin_waste_form_sheet.dart';

class AdminWasteScreen extends StatefulWidget {
  const AdminWasteScreen({super.key});

  @override
  State<AdminWasteScreen> createState() => _AdminWasteScreenState();
}

class _AdminWasteScreenState extends State<AdminWasteScreen>
    with SingleTickerProviderStateMixin {
  final _service = AdminWasteService();
  final _searchController = TextEditingController();
  late final TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _searchController.addListener(
        () => setState(() => _searchQuery = _searchController.text.trim()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openForm({WasteItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AdminWasteFormSheet(item: item),
    );
  }

  Future<void> _confirmDelete(WasteItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Жою'),
        content: Text('"${item.name}" қалдығын жойғыңыз келе ме?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Болдырмау'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Жою'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _service.softDeleteItem(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Қалдық жойылды'),
              backgroundColor: Colors.orange,
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
      }
    }
  }

  Color _parseBinColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String _categoryLabel(WasteCategory category) {
    switch (category) {
      case WasteCategory.recyclable:
        return 'Қайта өңделетін';
      case WasteCategory.nonRecyclable:
        return 'Қайта өңделмейтін';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isItemsTab = _tabController.index == 0;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Қалдықтар'),
            Tab(text: 'Санаттар'),
          ],
        ),
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  _WasteItemsTab(
                    service: _service,
                    searchController: _searchController,
                    searchQuery: _searchQuery,
                    onEdit: (item) => _openForm(item: item),
                    onDelete: _confirmDelete,
                    parseBinColor: _parseBinColor,
                    categoryLabel: _categoryLabel,
                  ),
                  _CategoriesTab(categoryLabel: _categoryLabel),
                ],
              ),
              if (isItemsTab)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    onPressed: () => _openForm(),
                    child: const Icon(Icons.add),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1 — Waste Items
// ---------------------------------------------------------------------------

class _WasteItemsTab extends StatelessWidget {
  const _WasteItemsTab({
    required this.service,
    required this.searchController,
    required this.searchQuery,
    required this.onEdit,
    required this.onDelete,
    required this.parseBinColor,
    required this.categoryLabel,
  });

  final AdminWasteService service;
  final TextEditingController searchController;
  final String searchQuery;
  final void Function(WasteItem) onEdit;
  final void Function(WasteItem) onDelete;
  final Color Function(String) parseBinColor;
  final String Function(WasteCategory) categoryLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Атауы бойынша іздеу...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<WasteItem>>(
            stream: service.watchAllItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Қате: ${snapshot.error}'));
              }
              final items = (snapshot.data ?? [])
                  .where((item) => searchQuery.isEmpty ||
                      item.name
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                  .toList();

              if (items.isEmpty) {
                return const Center(
                  child: Text('Қалдықтар табылмады'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _WasteItemCard(
                    item: item,
                    onEdit: () => onEdit(item),
                    onDelete: () => onDelete(item),
                    parseBinColor: parseBinColor,
                    categoryLabel: categoryLabel,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WasteItemCard extends StatelessWidget {
  const _WasteItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.parseBinColor,
    required this.categoryLabel,
  });

  final WasteItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color Function(String) parseBinColor;
  final String Function(WasteCategory) categoryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bin color dot
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 12),
              child: CircleAvatar(
                radius: 8,
                backgroundColor: parseBinColor(item.binColor),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      categoryLabel(item.category),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontSize: 11),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.explanation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Өзгерту',
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Жою',
                  iconSize: 20,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2 — Categories (informational)
// ---------------------------------------------------------------------------

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.categoryLabel});

  final String Function(WasteCategory) categoryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Қалдық санаттары',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Санаттар enum негізінде анықталған және өзгертілмейді.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WasteCategory.values
                .map((category) => Chip(
                      label: Text(categoryLabel(category)),
                      backgroundColor:
                          theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
