import 'package:projekakhirpamp/core/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/book_model.dart';
import '../providers/book_provider.dart';
import 'book_form_page.dart';

class BookDetailPage extends StatefulWidget {
  final BookModel book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late BookModel _currentBook;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Buku'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${_currentBook.title}" dari katalog perpustakaan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<BookProvider>(
                context,
                listen: false,
              );
              final success = await provider.deleteBook(_currentBook.id!);
              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Buku berhasil dihapus dari katalog.'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.errorMessage ?? 'Gagal menghapus buku.',
                    ),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookProvider = Provider.of<BookProvider>(context);

    // Dapatkan data buku terbaru jika sudah pernah diperbarui di provider
    if (_currentBook.id != null) {
      final updated = bookProvider.getBookById(_currentBook.id!);
      if (updated != null) {
        _currentBook = updated;
      }
    }

    Future<void> edit() async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookFormPage(book: _currentBook)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Buku')),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.menu_book_outlined, size: 28),
                    const SizedBox(height: 20),
                    Text(
                      _currentBook.title,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Oleh ${_currentBook.author}',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusBadge(_currentBook.category),
                        StatusBadge(
                          _currentBook.stock > 0
                              ? 'Stok: ${_currentBook.stock}'
                              : 'Stok habis',
                        ),
                      ],
                    ),
                    const Divider(height: 40),
                    Text('Informasi Buku', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 20),
                    for (final field in [
                      ('Kode Buku', _currentBook.bookCode),
                      ('Penulis', _currentBook.author),
                      ('Penerbit', _currentBook.publisher),
                      ('Tahun Terbit', '${_currentBook.publicationYear}'),
                      ('Kategori', _currentBook.category),
                      ('Lokasi Rak', _currentBook.rackLocation),
                      ('Jumlah Stok', '${_currentBook.stock} eksemplar'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(field.$1, style: theme.textTheme.bodySmall),
                            const SizedBox(height: 6),
                            Text(field.$2, style: theme.textTheme.titleMedium),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: bookProvider.isSaving ? null : edit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Informasi Buku'),
                ),
                OutlinedButton.icon(
                  onPressed: bookProvider.isSaving || _currentBook.id == null
                      ? null
                      : () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus Buku Dari Katalog'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
