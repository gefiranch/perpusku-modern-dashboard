import 'package:projekakhirpamp/core/widgets/app_layout.dart';
import 'package:projekakhirpamp/core/widgets/record_collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_rack_provider.dart';
import '../../domain/models/category_rack_model.dart';
import 'category_rack_form_page.dart';

class CategoryRackListPage extends StatefulWidget {
  const CategoryRackListPage({super.key});
  @override
  State<CategoryRackListPage> createState() => _CategoryRackListPageState();
}

class _CategoryRackListPageState extends State<CategoryRackListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CategoryRackProvider>().fetchCategories();
    });
  }

  void _form([CategoryRackModel? item]) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => CategoryRackFormPage(category: item)),
  );
  Future<void> _delete(
    CategoryRackProvider provider,
    CategoryRackModel item,
  ) async {
    if (!await confirmRemoval(context, item.categoryName) || !mounted) return;
    try {
      await provider.deleteCategory(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil dihapus')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus kategori. Silakan coba lagi.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryRackProvider>();
    return WorkspacePage(
      appBar: AppBar(
        title: const Text('Kategori & Rak'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: provider.isLoading ? null : provider.fetchCategories,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? FeedbackState(
              title: provider.errorMessage!,
              action: provider.fetchCategories,
            )
          : provider.categories.isEmpty
          ? FeedbackState(
              title: 'Belum ada data kategori.',
              actionLabel: 'Tambah Kategori',
              action: () => _form(),
            )
          : RefreshIndicator(
              onRefresh: provider.fetchCategories,
              child: RecordCollection(
                headers: const ['Kategori', 'Lokasi Rak'],
                items: provider.categories
                    .map(
                      (item) => RecordItem(
                        title: item.categoryName,
                        subtitle: 'Lokasi: ${item.rackLocation}',
                        cells: [item.categoryName, item.rackLocation],
                        actions: [
                          IconButton(
                            tooltip: 'Edit kategori',
                            onPressed: () => _form(item),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Hapus kategori',
                            onPressed: provider.isSaving
                                ? null
                                : () => _delete(provider, item),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
      ),
    );
  }
}
