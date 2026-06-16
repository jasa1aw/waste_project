import 'package:flutter/material.dart';

class AdminDataTable<T> extends StatelessWidget {
  const AdminDataTable({
    super.key,
    required this.rows,
    required this.columns,
    required this.rowBuilder,
    this.emptyText = 'Деректер жоқ',
  });

  final List<T> rows;
  final List<String> columns;
  final List<DataRow> Function(T item) rowBuilder;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: rows.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  emptyText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                columns: columns
                    .map(
                      (col) => DataColumn(
                        label: Text(
                          col,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                    .toList(),
                rows: rows.expand(rowBuilder).toList(),
              ),
            ),
    );
  }
}
