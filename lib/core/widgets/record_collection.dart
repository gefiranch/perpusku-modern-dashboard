import 'package:flutter/material.dart';

import 'app_layout.dart';

class RecordItem {
  const RecordItem({
    required this.title,
    required this.subtitle,
    required this.cells,
    required this.actions,
    this.onTap,
    this.badge,
    this.icon = Icons.menu_book_outlined,
  });
  final String title, subtitle;
  final List<String> cells;
  final List<Widget> actions;
  final VoidCallback? onTap;
  final String? badge;
  final IconData icon;
}

/// Desktop table; adaptive cards otherwise. Measures remaining content width.
class RecordCollection extends StatelessWidget {
  const RecordCollection({
    super.key,
    required this.headers,
    required this.items,
    this.grid = false,
  });
  final List<String> headers;
  final List<RecordItem> items;
  final bool grid;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      if (!grid &&
          (box.maxWidth >= 900 ||
              (MediaQuery.sizeOf(context).width >= 1024 &&
                  box.maxWidth >= 600))) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          child: Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: box.maxWidth - 48),
                child: DataTable(
                  showCheckboxColumn: false,
                  columnSpacing: 24,
                  horizontalMargin: 20,
                  dataRowMinHeight: 68,
                  dataRowMaxHeight: 100,
                  columns: [
                    ...headers.map((h) => DataColumn(label: Text(h))),
                    const DataColumn(label: Text('Aksi')),
                  ],
                  rows: items
                      .map(
                        (item) => DataRow(
                          onSelectChanged: item.onTap == null
                              ? null
                              : (_) => item.onTap!(),
                          cells: [
                            ...item.cells.asMap().entries.map(
                              (entry) => DataCell(
                                item.badge == entry.value
                                    ? StatusBadge(entry.value)
                                    : SizedBox(
                                        width: entry.key == 0 ? 200 : 130,
                                        child: Text(
                                          entry.value,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: item.actions,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        );
      }
      final columns = grid && box.maxWidth >= 600
          ? (box.maxWidth / 310).floor().clamp(2, 4)
          : 1;
      // Wrap gives cards natural heights at large text scales.
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: (box.maxWidth - 32 - (columns - 1) * 16) / columns,
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      onTap: item.onTap,
                      title: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(item.subtitle),
                          if (item.badge != null) ...[
                            const SizedBox(height: 10),
                            StatusBadge(item.badge!),
                          ],
                          const SizedBox(height: 8),
                          Wrap(spacing: 4, children: item.actions),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
    },
  );
}
